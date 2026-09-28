/// Session model matching the Gateway API Server response format.
class Session {
  final String id;
  final String title;
  final String model;
  final String source;
  final int messageCount;
  final bool isActive;
  final String preview;
  final double startedAt;
  final double? endedAt;

  /// Most recent activity, in seconds since the epoch.
  ///
  /// The Gateway sends `last_active`; older gateways may not, so the parser
  /// falls back to [startedAt]. Every date grouping and "Recent" filter in
  /// the Chats browser ranks by this value.
  final double lastActive;

  /// Whether the user pinned the chat server-side.
  final bool pinned;

  /// Whether the Gateway archived the session.
  final bool archived;

  /// The Hermes profile that owns this chat, when it is not the launch one.
  ///
  /// Hermes keeps one session store per profile and resolves every
  /// profile-scoped call — `session.resume` included — by name. A bot's
  /// canonical `Bot Chat` lives in the bot's own profile, so opening it
  /// without this field makes the gateway look in the launch store and answer
  /// `session not found`, which the desktop client then answers by creating an
  /// unrelated new chat. Null means "the connection's own default profile",
  /// which is how every ordinary chat behaves.
  final String? profile;

  const Session({
    required this.id,
    required this.title,
    required this.model,
    required this.source,
    required this.messageCount,
    required this.isActive,
    required this.preview,
    required this.startedAt,
    this.endedAt,
    this.lastActive = 0,
    this.pinned = false,
    this.archived = false,
    this.profile,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    final endedAt = json['ended_at'];
    final startedAt = (json['started_at'] ?? 0).toDouble();
    final lastActive = (json['last_active'] ?? startedAt).toDouble();
    final profile = json['profile']?.toString().trim() ?? '';
    return Session(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      model: json['model'] ?? 'Default',
      source: json['source'] ?? '',
      messageCount: json['message_count'] ?? 0,
      isActive: endedAt == null,
      preview: json['preview'] ?? '',
      startedAt: startedAt,
      endedAt: endedAt?.toDouble(),
      lastActive: lastActive,
      pinned: json['pinned'] == true,
      archived: json['archived'] == true,
      // The server stamps every row with its owning profile, and labels the
      // launch profile `default`. Keep it only when it is a real other
      // profile, so an ordinary chat keeps the connection's own default.
      profile: profile.isEmpty || profile == 'default' ? null : profile,
    );
  }

  /// A copy with [profile] replaced.
  Session withProfile(String? profile) {
    final scope = profile?.trim();
    if (scope == this.profile) return this;
    return Session(
      id: id,
      title: title,
      model: model,
      source: source,
      messageCount: messageCount,
      isActive: isActive,
      preview: preview,
      startedAt: startedAt,
      endedAt: endedAt,
      lastActive: lastActive,
      pinned: pinned,
      archived: archived,
      profile: scope == null || scope.isEmpty ? null : scope,
    );
  }
}
