import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/bots_gateway_client.dart';
import 'package:hermes_android/core/services/capability_registry.dart';
import 'package:hermes_android/core/services/ws_client.dart';

class _RecordingRpc {
  final List<({String method, Map<String, dynamic> params})> calls = [];
  final List<Map<String, dynamic>> responses;

  _RecordingRpc(this.responses);

  Future<Map<String, dynamic>> call(
    String method,
    Map<String, dynamic> params,
  ) async {
    calls.add((method: method, params: params));
    if (responses.isEmpty) {
      throw StateError('no canned response for $method');
    }
    return responses.removeAt(0);
  }
}

Map<String, dynamic> _ok(Map<String, dynamic> result) => {
  'jsonrpc': '2.0',
  'id': 1,
  'result': result,
};

Map<String, dynamic> _error(int code, String message) => {
  'jsonrpc': '2.0',
  'id': 1,
  'error': {'code': code, 'message': message},
};

/// One `profiles.list` row, shaped exactly like the live gateway returns it
/// (`workspace/probes/probe_bots_roster_path.py`, profile `default`).
Map<String, dynamic> _profileJson({
  String name = 'cto',
  String botTitle = '首席技术官（CTO）',
}) => {
  'name': name,
  'path': '/vol2/@appdata/trim.hermes/hermes/profiles/$name',
  'is_default': false,
  'model': 'step-5-preview',
  'provider': 'stepfun',
  'description': '技术最高负责人',
  'display_name': '',
  'skill_count': 429,
  'previous_names': <String>[],
  'role': null,
  'canonical_session': {
    'id': '20260923_000929_e137a1',
    'resolved_id': '20260923_000929_e137a1',
    'root_title': 'Bot Chat',
    'title': 'Bot Chat',
    'preview': '上一轮摘要',
    'started_at': 1790093382.7359495,
    'last_active': 1790354771.667808,
    'message_count': 256,
  },
  'ui_meta': {
    'hermes-bots': {
      'title': botTitle,
      'shape': 'pill',
      'color': '#ef4444',
      'imageKind': 'shape',
      'created': 1790093338660,
    },
  },
  'has_avatar': true,
};

void main() {
  group('HermesBot', () {
    test('reads the Bot Mode presentation block', () {
      final bot = HermesBot.fromJson(_profileJson());

      expect(bot.name, 'cto');
      expect(bot.displayTitle, '首席技术官（CTO）');
      expect(bot.description, '技术最高负责人');
      expect(bot.model, 'step-5-preview');
      expect(bot.skillCount, 429);
      expect(bot.hasAvatar, isTrue);
      expect(bot.botChatSessionId, '20260923_000929_e137a1');
      expect(bot.botChatPreview, '上一轮摘要');
      expect(bot.botChatMessageCount, 256);
      expect(bot.colorHex, '#ef4444');
    });

    test('falls back to the profile name without a Bot Mode block', () {
      // `ui_meta` and `canonical_session` are independent keys, so dropping
      // the presentation block must not also lose the chat identity: a bot can
      // own a canonical chat while carrying no branding at all.
      final bot = HermesBot.fromJson(_profileJson()..remove('ui_meta'));

      expect(bot.displayTitle, 'cto');
      expect(bot.colorHex, isNull);
      expect(bot.isBotManaged, isFalse);
      expect(bot.botChatSessionId, '20260923_000929_e137a1');
    });

    test('a canonical session absent entirely means no chat yet', () {
      final bot = HermesBot.fromJson(_profileJson()
        ..remove('canonical_session'));

      expect(bot.botChatSessionId, isNull);
      expect(bot.botChatMessageCount, 0);
      expect(bot.botChatPreview, '');
      // Branding survives on its own terms.
      expect(bot.displayTitle, '首席技术官（CTO）');
      expect(bot.colorHex, '#ef4444');
    });

    test('a bot-managed profile is one carrying the block', () {
      expect(HermesBot.fromJson(_profileJson()).isBotManaged, isTrue);
      expect(
        HermesBot.fromJson(_profileJson()..remove('ui_meta')).isBotManaged,
        isFalse,
      );
    });

    test('an empty Bot Mode title falls back to the profile name', () {
      // The live default profile carries `title: ""`, so the bot's identity
      // must degrade to its profile name rather than rendering a blank row.
      final bot = HermesBot.fromJson(_profileJson(botTitle: '  '));

      expect(bot.displayTitle, 'cto');
    });

    test('a blank canonical session id means no chat exists yet', () {
      final json = _profileJson();
      json['canonical_session'] = {
        'id': '   ',
        'title': 'Bot Chat',
        'preview': '',
        'message_count': 0,
      };

      expect(HermesBot.fromJson(json).botChatSessionId, isNull);
    });

    test('a row with no name is not a bot', () {
      final json = _profileJson()..['name'] = '  ';

      expect(HermesBot.fromJson(json).name, '');
    });
  });

  group('BotsGatewayClient', () {
    test('lists the roster through profiles.list', () async {
      final rpc = _RecordingRpc([
        _ok({
          'profiles': [_profileJson()],
          'bot_mode_protocol': true,
        }),
      ]);
      final client = BotsGatewayClient(rpc.call);

      final roster = await client.list();

      expect(rpc.calls.single.method, 'profiles.list');
      expect(rpc.calls.single.params, isEmpty);
      expect(roster.single.displayTitle, '首席技术官（CTO）');
    });

    test('drops rows that carry no usable name', () async {
      final rpc = _RecordingRpc([
        _ok({
          'profiles': [
            _profileJson()..['name'] = '   ',
            _profileJson(name: 'cpo', botTitle: '首席产品官（CPO）'),
          ],
        }),
      ]);
      final client = BotsGatewayClient(rpc.call);

      final roster = await client.list();

      expect(roster.map((bot) => bot.name), ['cpo']);
    });

    test('reports an unsupported gateway instead of crashing', () async {
      final rpc = _RecordingRpc([
        _error(-32601, 'unknown method: profiles.list'),
      ]);
      final client = BotsGatewayClient(rpc.call);

      await expectLater(
        client.list(),
        throwsA(isA<BotsUnsupportedException>()),
      );
      expect(await client.isSupported(), isFalse);
    });

    test('a transport failure is not treated as unsupported', () async {
      var calls = 0;
      final client = BotsGatewayClient((method, params) async {
        calls++;
        throw JsonRpcError(
          method,
          'Desktop gateway connection closed',
          reason: 'connection_closed',
        );
      });

      await expectLater(client.list(), throwsA(isA<JsonRpcError>()));
      await expectLater(client.list(), throwsA(isA<JsonRpcError>()));
      expect(calls, 2);
      expect(client.cachedSupport, isNull);
    });

    test('reads a profile editor snapshot through profiles.describe', () async {
      final rpc = _RecordingRpc([
        _ok({
          'name': 'cto',
          'description': '技术最高负责人',
          'soul': '## Role',
          'model': {'provider': 'stepfun', 'default': 'step-5-preview'},
          'skills': [
            {'name': 'hermes-agent', 'enabled': true},
            {'name': 'other', 'enabled': false},
          ],
        }),
      ]);
      final client = BotsGatewayClient(rpc.call);

      final detail = await client.describe(bot: 'cto');

      expect(rpc.calls.single.method, 'profiles.describe');
      expect(rpc.calls.single.params, {'name': 'cto'});
      expect(detail.soul, '## Role');
      expect(detail.modelDefault, 'step-5-preview');
      expect(detail.enabledSkillCount, 1);
    });

    test('caches the unsupported verdict without repeating the probe', () async {
      final rpc = _RecordingRpc([
        _error(-32601, 'Unknown method: profiles.list'),
      ]);
      final client = BotsGatewayClient(rpc.call);

      expect(await client.isSupported(), isFalse);
      expect(await client.isSupported(), isFalse);
      expect(rpc.calls, hasLength(1));
    });

    test('a successful call teaches the shared registry', () async {
      final registry = CapabilityRegistry();
      final rpc = _RecordingRpc([
        _ok({'profiles': const [], 'bot_mode_protocol': true}),
      ]);
      final client = BotsGatewayClient(rpc.call, capabilities: registry);

      await client.list();

      expect(
        registry.supportFor('profiles.list'),
        CapabilitySupport.supported,
      );
    });

    test('a domain error still proves the method exists', () async {
      final registry = CapabilityRegistry();
      final rpc = _RecordingRpc([_error(5061, 'roster unavailable')]);
      final client = BotsGatewayClient(rpc.call, capabilities: registry);

      await expectLater(client.list(), throwsA(isA<JsonRpcError>()));

      expect(
        registry.supportFor('profiles.list'),
        CapabilitySupport.supported,
      );
    });

    test('a blank bot name is rejected before touching the gateway', () async {
      final rpc = _RecordingRpc([]);
      final client = BotsGatewayClient(rpc.call);

      await expectLater(
        client.describe(bot: '  '),
        throwsA(isA<ArgumentError>()),
      );
      expect(rpc.calls, isEmpty);
    });
  });
}
