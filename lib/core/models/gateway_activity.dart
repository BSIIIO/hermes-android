import '../l10n/app_strings.dart';

enum GatewayToolActivityPhase {
  running,
  generating,
  progress,
  completed,
  failed,
}

class GatewayToolActivity {
  static const _maxNameLength = 120;
  static const _maxDetailLength = 500;

  final String? toolId;
  final String name;
  final GatewayToolActivityPhase phase;
  final String? detail;
  final double? durationSeconds;
  final String? emoji;

  const GatewayToolActivity({
    required this.name,
    required this.phase,
    this.toolId,
    this.detail,
    this.durationSeconds,
    this.emoji,
  });

  bool get isTerminal =>
      phase == GatewayToolActivityPhase.completed ||
      phase == GatewayToolActivityPhase.failed;

  bool get isFailed => phase == GatewayToolActivityPhase.failed;

  /// Localized tool name for display.
  ///
  /// The raw [name] comes from a gateway event and is a wire identifier, so
  /// only its humanized shape is produced here — never an English label.
  String displayName(AppStrings s) {
    final words = name.replaceAll(RegExp(r'[_-]+'), ' ').trim();
    if (words.isEmpty) return s.activityToolFallbackName;
    return words[0].toUpperCase() + words.substring(1);
  }

  /// Localized status line. Durations are formatted by this layer because they
  /// are numbers, not strings; the surrounding words are localized.
  String statusLabel(AppStrings s) {
    switch (phase) {
      case GatewayToolActivityPhase.running:
        return s.activityToolPhaseRunning;
      case GatewayToolActivityPhase.generating:
        return s.activityToolPhasePreparing;
      case GatewayToolActivityPhase.progress:
        return s.activityToolPhaseWorking;
      case GatewayToolActivityPhase.completed:
        return durationSeconds == null
            ? s.activityToolPhaseCompleted
            : s.activityToolCompletedIn.replaceAll(
                '{0}',
                _formatDuration(durationSeconds!),
              );
      case GatewayToolActivityPhase.failed:
        return durationSeconds == null
            ? s.activityToolPhaseFailed
            : s.activityToolFailedAfter.replaceAll(
                '{0}',
                _formatDuration(durationSeconds!),
              );
    }
  }

  static GatewayToolActivity? fromGatewayEvent(
    String eventType,
    Map<String, dynamic> data,
  ) {
    if (!eventType.startsWith('tool.')) return null;

    final toolId = _firstText(data, const [
      'tool_id',
      'toolCallId',
      'tool_call_id',
      'id',
    ]);
    final rawName = _firstText(data, const ['name', 'tool', 'label']) ?? 'tool';
    final name = _normalizeText(rawName, _maxNameLength) ?? 'tool';
    final durationSeconds = _duration(data['duration_s']);
    final error = _normalizeText(
      _firstText(data, const ['error']),
      _maxDetailLength,
    );

    final phase = _phaseFor(eventType, data['status']?.toString(), error);
    final detail = switch (phase) {
      GatewayToolActivityPhase.failed => error,
      GatewayToolActivityPhase.completed => _normalizeText(
        _firstText(data, const ['summary']),
        _maxDetailLength,
      ),
      GatewayToolActivityPhase.progress => _normalizeText(
        _firstText(data, const ['preview', 'detail']),
        _maxDetailLength,
      ),
      GatewayToolActivityPhase.generating => _normalizeText(
        _firstText(data, const ['preview', 'detail']),
        _maxDetailLength,
      ),
      GatewayToolActivityPhase.running => _normalizeText(
        _firstText(data, const ['context', 'detail']),
        _maxDetailLength,
      ),
    };

    return GatewayToolActivity(
      toolId: toolId,
      name: name,
      phase: phase,
      detail: detail,
      durationSeconds: durationSeconds,
      emoji: _normalizeText(_firstText(data, const ['emoji']), 8),
    );
  }

  GatewayToolActivity merge(GatewayToolActivity update) {
    return GatewayToolActivity(
      toolId: update.toolId ?? toolId,
      name: update.name == 'tool' && name != 'tool' ? name : update.name,
      phase: update.phase,
      detail: update.detail ?? detail,
      durationSeconds: update.durationSeconds ?? durationSeconds,
      emoji: update.emoji ?? emoji,
    );
  }

  static GatewayToolActivityPhase _phaseFor(
    String eventType,
    String? legacyStatus,
    String? error,
  ) {
    if (eventType == 'tool.complete') {
      return error == null
          ? GatewayToolActivityPhase.completed
          : GatewayToolActivityPhase.failed;
    }
    if (eventType == 'tool.generating') {
      return GatewayToolActivityPhase.generating;
    }
    if (eventType == 'tool.progress') {
      return GatewayToolActivityPhase.progress;
    }

    switch (legacyStatus?.trim().toLowerCase()) {
      case 'completed':
      case 'complete':
      case 'finished':
      case 'done':
        return GatewayToolActivityPhase.completed;
      case 'failed':
      case 'error':
        return GatewayToolActivityPhase.failed;
      case 'generating':
      case 'preparing':
        return GatewayToolActivityPhase.generating;
      case 'progress':
      case 'working':
        return GatewayToolActivityPhase.progress;
      default:
        return GatewayToolActivityPhase.running;
    }
  }

  static String? _firstText(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  static String? _normalizeText(String? value, int maxLength) {
    if (value == null) return null;
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return null;
    return normalized.length <= maxLength
        ? normalized
        : '${normalized.substring(0, maxLength - 1)}…';
  }

  static double? _duration(dynamic value) {
    if (value is num && value.isFinite && value >= 0) {
      return value.toDouble();
    }
    return null;
  }

  static String _formatDuration(double value) {
    if (value < 1) return '${(value * 1000).round()} ms';
    return '${value.toStringAsFixed(value < 10 ? 1 : 0)} s';
  }
}

class GatewayTurnStatus {
  static const _maxTextLength = 240;

  final String kind;
  final String text;

  const GatewayTurnStatus({required this.kind, required this.text});

  /// Parses a gateway status event. [s] must be the caller's live strings: this
  /// method is static and has no context, so the fallback text for a
  /// `compacting` / `compacted` kind can only be localized by the caller.
  static GatewayTurnStatus? fromGatewayEvent(
    String eventType,
    Map<String, dynamic> data,
    AppStrings s,
  ) {
    if (eventType != 'status.update' && eventType != 'thinking.delta') {
      return null;
    }

    final kind = eventType == 'thinking.delta'
        ? 'thinking'
        : _normalize(data['kind']?.toString(), 40) ?? 'status';
    final rawText = _normalize(data['text']?.toString(), _maxTextLength);
    final text = rawText ?? _fallbackText(s, kind);
    if (text == null) return null;
    return GatewayTurnStatus(kind: kind, text: text);
  }

  static String? _fallbackText(AppStrings s, String kind) {
    switch (kind) {
      case 'compacting':
        return s.activityTurnCompacting;
      case 'compacted':
        return s.activityTurnCompacted;
      default:
        return null;
    }
  }

  static String? _normalize(String? value, int maxLength) {
    if (value == null) return null;
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return null;
    return normalized.length <= maxLength
        ? normalized
        : '${normalized.substring(0, maxLength - 1)}…';
  }
}
