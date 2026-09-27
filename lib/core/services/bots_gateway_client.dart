import 'capability_registry.dart';
import 'projects_gateway_client.dart' show GatewayRpcCall;
import 'ws_client.dart';

/// A JSON-RPC error code meaning the gateway does not implement the method.
const int _unknownMethodCode = -32601;

/// Thrown when the gateway predates the Bot Mode roster.
///
/// A compatibility signal, not a failure: the caller shows the Bots pane as
/// unavailable *with a reason* instead of an error.
class BotsUnsupportedException implements Exception {
  final String method;
  final String message;

  const BotsUnsupportedException(this.method, this.message);

  @override
  String toString() => 'BotsUnsupportedException($method): $message';
}

/// One Hermes profile as a Bot Mode bot.
///
/// A bot IS a Hermes profile — its own home, config, memory, skills and chat
/// history. Everything Hermes Bot Mode presents (`title`, `color`) lives in
/// the profile's `ui_meta['hermes-bots']` block; the launch profile itself
/// carries an empty `title` there, so [displayTitle] falls back to [name].
class HermesBot {
  /// Profile name; the identity of every profile-scoped RPC.
  final String name;

  /// Presentation title from the Bot Mode block, or [name] when absent.
  final String displayTitle;

  /// One or two sentences describing the bot's role.
  final String description;

  /// The profile's pinned default model, or null when it inherits one.
  final String? model;

  /// The provider behind [model], or null.
  final String? provider;

  /// Number of skills installed in this profile.
  final int skillCount;

  /// Whether the profile carries an avatar asset.
  final bool hasAvatar;

  /// Accent colour from the Bot Mode block (`#rrggbb`), or null.
  final String? colorHex;

  /// Stored id of the canonical `Bot Chat`, or null when never used.
  ///
  /// The gateway hides the canonical chat from an ordinary listing, so this
  /// is the only cheap way to know whether one exists. It is a `stored` id,
  /// so it must still go through `session.resume`.
  final String? botChatSessionId;

  /// Preview of the newest turn in [botChatSessionId].
  final String botChatPreview;

  /// Number of stored turns in [botChatSessionId].
  final int botChatMessageCount;

  /// Whether Hermes Bot Mode manages this profile.
  final bool isBotManaged;

  const HermesBot({
    required this.name,
    required this.displayTitle,
    required this.description,
    required this.model,
    required this.provider,
    required this.skillCount,
    required this.hasAvatar,
    required this.colorHex,
    required this.botChatSessionId,
    required this.botChatPreview,
    required this.botChatMessageCount,
    required this.isBotManaged,
  });

  /// Parses one `profiles.list` row.
  ///
  /// Every optional field degrades to a usable value rather than throwing: a
  /// single malformed row must not take the whole roster down.
  factory HermesBot.fromJson(Map<String, dynamic> json) {
    final uiMeta = (json['ui_meta'] as Map?)?.cast<String, dynamic>();
    final botsBlock = (uiMeta?['hermes-bots'] as Map?)
        ?.cast<String, dynamic>();
    final canonical =
        (json['canonical_session'] as Map?)?.cast<String, dynamic>();
    final name = json['name']?.toString().trim() ?? '';
    final botTitle = botsBlock?['title']?.toString().trim() ?? '';

    return HermesBot(
      name: name,
      // The launch profile stores an empty title, so the profile name is the
      // only identity it has. Rendering a blank row instead would look like a
      // broken app rather than an un-branded bot.
      displayTitle: botTitle.isEmpty ? name : botTitle,
      description: json['description']?.toString().trim() ?? '',
      model: _nonEmpty(json['model']),
      provider: _nonEmpty(json['provider']),
      skillCount: (json['skill_count'] as num?)?.toInt() ?? 0,
      hasAvatar: json['has_avatar'] == true,
      colorHex: _nonEmpty(botsBlock?['color']),
      botChatSessionId: _nonEmpty(canonical?['id']),
      botChatPreview: canonical?['preview']?.toString() ?? '',
      botChatMessageCount:
          (canonical?['message_count'] as num?)?.toInt() ?? 0,
      isBotManaged: botsBlock != null,
    );
  }

  static String? _nonEmpty(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

/// Read-only access to the Bot Mode roster.
///
/// Modelled on `ProjectsGatewayClient`: one RPC family, one probe method, an
/// unknown-method answer downgraded to [BotsUnsupportedException], and a
/// transport failure that leaves the verdict unknown so a reconnect can still
/// discover support.
class BotsGatewayClient {
  static const _probeMethod = 'profiles.list';

  final GatewayRpcCall _call;

  /// Optional shared registry, so one probe informs the whole app.
  final CapabilityRegistry? capabilities;

  bool? _supported;

  BotsGatewayClient(this._call, {this.capabilities});

  /// The last known support verdict without contacting the gateway.
  bool? get cachedSupport => _supported;

  /// Whether the gateway exposes the `profiles.*` roster.
  ///
  /// Only a definitive answer is cached: an unknown-method reply is a no,
  /// anything else retries so a temporary failure cannot poison the pane.
  Future<bool> isSupported() async {
    final known = _supported;
    if (known != null) return known;
    try {
      await list();
      return true;
    } on BotsUnsupportedException {
      return false;
    }
  }

  /// Every profile on the gateway, the default profile included.
  Future<List<HermesBot>> list() async {
    final result = await _request(_probeMethod, const {});
    final rows = result['profiles'];
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map((row) => HermesBot.fromJson(Map<String, dynamic>.from(row)))
        .where((bot) => bot.name.isNotEmpty)
        .toList(growable: false);
  }

  /// The editor snapshot of one bot: description, soul, model pin, skills.
  Future<HermesBotDetail> describe({required String bot}) async {
    final result = await _request(
      'profiles.describe',
      {'name': _requireBot(bot)},
    );
    return HermesBotDetail.fromJson(bot.trim(), result);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    Map<String, dynamic> params,
  ) async {
    final registry = capabilities;
    if (registry != null && registry.isUnsupported(method)) {
      if (method == _probeMethod) _supported = false;
      throw BotsUnsupportedException(
        method,
        'This gateway does not support $method',
      );
    }
    final Map<String, dynamic> response;
    try {
      response = await _call(method, params);
    } catch (error) {
      registry?.recordFailure(method, error);
      rethrow;
    }
    final envelopeError = response['error'];
    if (envelopeError != null) {
      final rpcError = envelopeError is Map
          ? JsonRpcError.fromGateway(
              method,
              envelopeError,
              fallbackMessage: 'Gateway profiles call failed',
            )
          : JsonRpcError(method, 'Gateway profiles call failed');
      registry?.recordFailure(method, rpcError);
      if (_isUnknownMethod(rpcError)) {
        if (method == _probeMethod) _supported = false;
        throw BotsUnsupportedException(method, rpcError.message);
      }
      // A real profiles error still proves the RPC family exists.
      _supported = true;
      throw rpcError;
    }
    _supported = true;
    registry?.recordSuccess(method);
    final result = response['result'];
    return result is Map
        ? Map<String, dynamic>.from(result)
        : <String, dynamic>{};
  }

  static bool _isUnknownMethod(JsonRpcError error) {
    if (error.code == _unknownMethodCode) return true;
    final message = error.message.toLowerCase();
    return message.contains('unknown method') ||
        message.contains('method not found');
  }

  static String _requireBot(String bot) {
    final trimmed = bot.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(bot, 'bot', 'A bot profile name is required');
    }
    return trimmed;
  }
}

/// The read-only detail of one bot.
///
/// Carries only what a roster row shows; the rest of the profile editor stays
/// on the dashboard.
class HermesBotDetail {
  final String name;
  final String description;
  final String soul;
  final String modelProvider;
  final String modelDefault;
  final int enabledSkillCount;

  const HermesBotDetail({
    required this.name,
    required this.description,
    required this.soul,
    required this.modelProvider,
    required this.modelDefault,
    required this.enabledSkillCount,
  });

  factory HermesBotDetail.fromJson(String name, Map<String, dynamic> json) {
    final model = (json['model'] as Map?)?.cast<String, dynamic>();
    final skills = (json['skills'] as List?) ?? const [];
    return HermesBotDetail(
      name: name,
      description: json['description']?.toString().trim() ?? '',
      soul: json['soul']?.toString() ?? '',
      modelProvider: model?['provider']?.toString().trim() ?? '',
      modelDefault: model?['default']?.toString().trim() ?? '',
      enabledSkillCount: skills
          .whereType<Map>()
          .where((row) => row['enabled'] == true)
          .length,
    );
  }
}
