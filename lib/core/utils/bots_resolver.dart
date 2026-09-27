import '../models/session.dart';

/// The exact title of a bot's canonical conversation.
///
/// Hermes Bot Mode gives every profile exactly one canonical session and the
/// gateway identifies it by this title. The gateway also hides it from an
/// ordinary `session.list` — it only appears with `include_hidden` — so any
/// surface that owns it must ask for it by title, together with that flag.
///
/// Measured on 0.21.5 (`workspace/probes/probe_bots_roster_path.py`): a plain
/// listing returns 174 rows with no `Bot Chat`, while `include_hidden`
/// returns 177 and reveals it.
const String botChatTitle = 'Bot Chat';

/// Whether [session] is a bot's canonical conversation.
///
/// An exact, case-sensitive match on purpose: a profile may legitimately own
/// a conversation called "bot chat" that is something else entirely.
bool isBotChatSession(Session session) =>
    session.title.trim() == botChatTitle;

/// A bot's canonical chat resolved from a profile-scoped listing.
class BotChatResolution {
  /// The stored session id, which is what `session.resume` takes.
  final String id;

  /// Number of stored turns in the resolved row.
  final int messageCount;

  const BotChatResolution({required this.id, required this.messageCount});
}

/// Picks the canonical Bot Chat out of a profile-scoped listing.
///
/// A strictly greater comparison keeps the winner deterministic when two rows
/// tie on turns: the earliest row in the listing wins rather than whichever
/// one happened to be iterated last.
///
/// [Session] carries no `resolved_id`, so a compression lineage tip is not
/// visible here; callers resume [BotChatResolution.id] and let the gateway
/// follow the tip itself, which it does for a canonical row.
BotChatResolution? resolveBotChatSession(List<Session> sessions) {
  BotChatResolution? best;
  for (final session in sessions) {
    if (!isBotChatSession(session)) continue;
    final candidate = BotChatResolution(
      id: session.id,
      messageCount: session.messageCount,
    );
    if (best == null || candidate.messageCount > best.messageCount) {
      best = candidate;
    }
  }
  return best;
}
