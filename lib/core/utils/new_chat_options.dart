/// The decision layer behind Home's global **New** button.
///
/// The roadmap's Home offers exactly two creation modes — **Project chat** and
/// **Quick chat** — and they are not symmetric:
///
/// - a Project chat is durable, belongs to a server-owned Project, and
///   inherits that Project's context;
/// - a Quick chat is deliberately *unfiled*: it starts with no Project even
///   when one is active, is marked `Quick`, and auto-archives after
///   [kQuickChatRetention]. It never suppresses normal Hermes/Hindsight
///   memory — ephemeral is an organization state, not a memory policy.
///
/// Two rules are encoded here rather than in the widget, so they can be
/// asserted without pumping a frame:
///
/// 1. **Nothing is hidden.** A mode that cannot run right now is returned
///    disabled *with a reason*, per the roadmap's capability-discovery rule.
///    A gateway that has not been probed yet says so instead of claiming
///    Projects are unsupported.
/// 2. **Quick chat never inherits a Project.** Passing an active project is
///    silently ignored for [NewChatMode.quickChat] rather than quietly
///    polluting a durable Project list.
///
/// See `docs/ANDROID_DAILY_DRIVER_ROADMAP.md`.
library;

import '../l10n/app_strings.dart';
import '../models/hermes_project.dart';
import '../models/session.dart';
import '../services/projects_repository.dart';

/// How long a Quick chat stays out of the archive. Validated default: 72 h.
const Duration kQuickChatRetention = Duration(hours: 72);

/// The model a drafted chat uses when the caller pins none.
const String kDefaultChatModel = 'hermes-agent';

/// The three creation modes of the global New button.
enum NewChatMode {
  /// A durable chat inside a server-owned Project.
  projectChat,

  /// An unfiled, clearly marked chat that auto-archives after 72 hours.
  quickChat,

  /// A chat with a bot — one Hermes profile — in its canonical Bot Chat.
  ///
  /// The MVP opens the launch (default) profile directly, so there is no
  /// profile picker and no scope parameter here; switching profiles is a
  /// separate decision.
  botChat;

  /// User-visible label in the active language.
  String label(AppStrings s) {
    switch (this) {
      case NewChatMode.projectChat:
        return s.projectChat;
      case NewChatMode.quickChat:
        return s.quickChat;
      case NewChatMode.botChat:
        return s.newChatBotSession;
    }
  }

  /// User-visible description in the active language.
  String description(AppStrings s) {
    switch (this) {
      case NewChatMode.projectChat:
        return s.newChatModeProjectDescription;
      case NewChatMode.quickChat:
        return s.newChatModeQuickDescription;
      case NewChatMode.botChat:
        return s.newChatBotSessionDescription;
    }
  }
}

/// One entry of the New sheet, enabled or disabled with a stated reason.
class NewChatOption {
  final NewChatMode mode;
  final bool enabled;

  /// Why this mode cannot run right now. Always null when [enabled].
  final String? disabledReason;

  const NewChatOption({
    required this.mode,
    required this.enabled,
    this.disabledReason,
  });

  /// User-visible label in the active language.
  String label(AppStrings s) => mode.label(s);

  /// User-visible description in the active language.
  String description(AppStrings s) => mode.description(s);
}

/// Builds the New sheet entries for the current Projects state.
///
/// [projects] is the *active* (non-archived) listing; [isStale] means it came
/// from the offline cache, which deliberately does not disable anything — the
/// user may still start work in a project they already know about.
List<NewChatOption> buildNewChatOptions({
  required ProjectsSupport support,
  required List<HermesProject> projects,
  bool isStale = false,
  required AppStrings s,
}) {
  final usable = projects.where((project) => !project.archived).toList();

  String? projectChatBlocker;
  switch (support) {
    case ProjectsSupport.unknown:
      projectChatBlocker = s.newChatBlockerLoadingProjects;
    case ProjectsSupport.unsupported:
      projectChatBlocker = s.newChatBlockerGatewayTooOld;
    case ProjectsSupport.native:
      projectChatBlocker = usable.isEmpty
          ? s.newChatBlockerNoProjectsYet
          : null;
  }

  return [
    NewChatOption(
      mode: NewChatMode.projectChat,
      enabled: projectChatBlocker == null,
      disabledReason: projectChatBlocker,
    ),
    // Quick chat needs no project and no `projects.*` family, so a legacy
    // gateway must still be able to start work from Home.
    const NewChatOption(mode: NewChatMode.quickChat, enabled: true),
    // Bot chat needs no project either, and the MVP opens the launch profile
    // directly, so there is nothing to probe before offering it.
    const NewChatOption(mode: NewChatMode.botChat, enabled: true),
  ];
}

/// Convenience over [buildNewChatOptions] reading a [ProjectsView] directly,
/// so a caller cannot drift from the repository's own view of support.
List<NewChatOption> buildNewChatOptionsFor(
  ProjectsView view, {
  required AppStrings s,
}) {
  return buildNewChatOptions(
    support: view.support,
    projects: view.projects,
    isStale: view.isStale,
    s: s,
  );
}

/// A chat about to be opened: the local [Session] plus its organization state.
class NewChatDraft {
  final Session session;
  final NewChatMode mode;

  /// The owning Project, or null for a Quick chat.
  final String? projectId;

  /// Project label carried into the sticky Chat context header.
  final String? projectName;

  /// The owning Project's working directory on the gateway host. Used as the
  /// session `cwd` fallback binding when the gateway lacks
  /// `projects.assign_session` (stock Hermes groups sessions under a project
  /// by cwd via `project_for_path`).
  final String? projectWorkingDirectory;

  /// When a Quick chat becomes eligible for auto-archive. Null when durable.
  final DateTime? expiresAt;

  const NewChatDraft({
    required this.session,
    required this.mode,
    this.projectId,
    this.projectName,
    this.projectWorkingDirectory,
    this.expiresAt,
  });

  bool get isQuick => mode == NewChatMode.quickChat;
}

/// Drafts the session a New button tap opens.
///
/// [sessionId] is generated by the caller (`GatewayChatClient.generateSessionId`
/// in the app) so this stays a pure function and the id can be pinned in tests.
NewChatDraft buildNewChatDraft({
  required NewChatMode mode,
  required String sessionId,
  required DateTime now,
  HermesProject? project,
  String? model,
  required AppStrings s,
}) {
  final id = sessionId.trim();
  if (id.isEmpty) {
    throw ArgumentError.value(sessionId, 'sessionId', 'must not be blank');
  }

  final isQuick = mode == NewChatMode.quickChat;
  // A bot chat is as unfiled as a quick one — it talks to a profile, not to a
  // project — so it too needs no project to exist before it can be drafted.
  final needsProject = !isQuick && mode != NewChatMode.botChat;
  if (needsProject && project == null) {
    throw ArgumentError.notNull('project');
  }

  // A bot chat is titled by its bot, so a project passed in must not leak into
  // it; only projectChat may inherit the caller's project.
  final inheritsProject = needsProject;
  final projectName = inheritsProject ? project?.name.trim() ?? '' : '';
  final title = isQuick
      ? s.quickChat
      : (projectName.isEmpty
            ? s.newChatUntitled
            : s.newChatTitled.replaceAll('{0}', projectName));

  return NewChatDraft(
    session: Session(
      id: id,
      title: title,
      model: model ?? kDefaultChatModel,
      source: 'mobile',
      messageCount: 0,
      isActive: true,
      preview: '',
      startedAt: now.millisecondsSinceEpoch / 1000.0,
    ),
    mode: mode,
    // A Quick chat never inherits the active project, even when one is passed.
    projectId: inheritsProject ? project!.id : null,
    projectName: inheritsProject && projectName.isNotEmpty
        ? projectName
        : null,
    projectWorkingDirectory: inheritsProject
        ? project!.workingDirectory
        : null,
    expiresAt: isQuick ? now.add(kQuickChatRetention) : null,
  );
}
