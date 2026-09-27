import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/models/session.dart';
import 'package:hermes_android/core/utils/bots_resolver.dart';

Session _session({
  required String id,
  required String title,
  int messageCount = 0,
  bool archived = false,
}) {
  return Session(
    id: id,
    title: title,
    model: 'step-5-preview',
    source: 'tui',
    messageCount: messageCount,
    isActive: true,
    preview: '',
    startedAt: 1790093382.0,
    archived: archived,
  );
}

void main() {
  group('botChatTitle', () {
    test('is the server-side identity of the canonical chat', () {
      expect(botChatTitle, 'Bot Chat');
    });
  });

  group('resolveBotChatSession', () {
    test('returns the canonical Bot Chat row', () {
      final sessions = [
        _session(id: '20260923_015651_ad378b', title: 'API key'),
        _session(
          id: '20260923_000929_e137a1',
          title: botChatTitle,
          messageCount: 256,
        ),
      ];

      final resolved = resolveBotChatSession(sessions);

      expect(resolved, isNotNull);
      expect(resolved!.id, '20260923_000929_e137a1');
      expect(resolved.messageCount, 256);
    });

    test('prefers the newest row when the title is duplicated', () {
      final sessions = [
        _session(id: 'older', title: botChatTitle, messageCount: 5),
        _session(id: 'newer', title: botChatTitle, messageCount: 9),
      ];

      expect(resolveBotChatSession(sessions)!.id, 'newer');
    });

    test('keeps the first row when turn counts tie', () {
      // A tie must not let insertion order decide by accident: `>` on the
      // message count means the earliest-stored row wins, deterministically.
      final sessions = [
        _session(id: 'first', title: botChatTitle, messageCount: 7),
        _session(id: 'second', title: botChatTitle, messageCount: 7),
      ];

      expect(resolveBotChatSession(sessions)!.id, 'first');
    });

    test('ignores a case-insensitive near miss', () {
      expect(
        resolveBotChatSession([_session(id: 'x', title: 'bot chat')]),
        isNull,
      );
      expect(
        resolveBotChatSession([_session(id: 'x', title: 'Bot  Chat')]),
        isNull,
      );
      expect(
        resolveBotChatSession([_session(id: 'x', title: 'Bot Chats')]),
        isNull,
      );
    });

    test('returns null without a Bot Chat row', () {
      expect(
        resolveBotChatSession([_session(id: 'x', title: 'Nothing')]),
        isNull,
      );
      expect(resolveBotChatSession(const <Session>[]), isNull);
    });

    test('ignores surrounding whitespace in the title', () {
      final resolved = resolveBotChatSession([
        _session(id: 'x', title: '  $botChatTitle  '),
      ]);

      expect(resolved!.id, 'x');
    });

    test('does not mutate the listing it is handed', () {
      final sessions = [
        _session(id: 'x', title: botChatTitle, messageCount: 3),
      ];
      final before = List<Session>.of(sessions);

      resolveBotChatSession(sessions);

      expect(sessions, equals(before));
    });
  });

  group('isBotChatSession', () {
    test('is the same exact match used to pick the row', () {
      expect(isBotChatSession(_session(id: 'a', title: 'Bot Chat')), isTrue);
      expect(
        isBotChatSession(_session(id: 'a', title: '  Bot Chat  ')),
        isTrue,
      );
      expect(isBotChatSession(_session(id: 'a', title: 'Bot Chats')), isFalse);
      expect(isBotChatSession(_session(id: 'a', title: 'bot chat')), isFalse);
    });
  });
}
