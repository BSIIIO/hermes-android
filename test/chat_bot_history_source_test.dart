import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/chat_screen.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/desktop_gateway_client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_voice_composer_adapter.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'verbose_mode': false});
  });

  testWidgets(
    'a scoped bot chat takes its transcript from the gateway socket',
    (tester) async {
      final transcript = <Map<String, dynamic>>[
        {'role': 'user', 'content': 'remember this'},
        {'role': 'assistant', 'content': 'I remember'},
      ];
      final gateway = _FakeDesktopGateway(
        ('runtime-1', transcript),
        restMessages: <Map<String, dynamic>>[],
      );
      await _pumpBotChat(tester, gateway);

      // The resume carries the profile: without it the stored id does not
      // resolve and the gateway would answer 4007.
      expect(gateway.resumeCalls, [
        {'session_id': 'bot-chat-1', 'profile': 'cto'},
      ]);
      expect(gateway.restRequests, isEmpty);

      // The transcript the socket returned is what is on screen.
      expect(find.text('remember this'), findsOneWidget);
      expect(find.text('I remember'), findsOneWidget);
    },
  );

  testWidgets(
    'an unscoped chat still reads its history over REST',
    (tester) async {
      final restMessages = <Map<String, dynamic>>[
        {'id': 'm1', 'role': 'user', 'content': 'plain chat history'},
      ];
      final gateway = _FakeDesktopGateway(
        ('ignored', const []),
        restMessages: restMessages,
      );
      await _pumpChat(
        tester,
        gateway: gateway,
        session: const Session(
          id: 'plain-session',
          title: 'Plain chat',
          model: 'fixture-model',
          source: 'test',
          messageCount: 1,
          isActive: true,
          preview: '',
          startedAt: 1,
        ),
      );

      expect(gateway.resumeCalls, isEmpty);
      expect(gateway.restRequests, ['/api/sessions/plain-session/messages']);
      expect(find.text('plain chat history'), findsOneWidget);
    },
  );

  testWidgets(
    'a bot chat falls back to REST when the gateway socket has no transcript',
    (tester) async {
      // The socket answers but with an empty transcript — an older gateway, or
      // one that omitted the messages. REST must still get its chance, since
      // a bot with a genuinely empty history reads the same way.
      final gateway = _FakeDesktopGateway(
        ('runtime-1', const []),
        restMessages: <Map<String, dynamic>>[
          {'id': 'm1', 'role': 'user', 'content': 'history from REST'},
        ],
      );
      await _pumpBotChat(tester, gateway);

      expect(gateway.resumeCalls, isNotEmpty);
      expect(gateway.restRequests, ['/api/sessions/bot-chat-1/messages?profile=cto']);
      expect(find.text('history from REST'), findsOneWidget);
    },
  );

  testWidgets(
    'a bot chat stays usable when the gateway socket fails outright',
    (tester) async {
      final gateway = _FakeDesktopGateway(
        null, // throws on the history call
        restMessages: <Map<String, dynamic>>[],
      );
      await _pumpBotChat(tester, gateway);

      // No transcript from either side, but no error banner either: an empty
      // bot chat must still be a usable chat.
      expect(find.text('Composer'), findsNothing);
      expect(gateway.resumeCalls, isNotEmpty);
      expect(find.byType(TextField), findsOneWidget);
    },
  );
}

Future<void> _pumpBotChat(
  WidgetTester tester,
  _FakeDesktopGateway gateway,
) =>
    _pumpChat(
      tester,
      gateway: gateway,
      session: const Session(
        id: 'bot-chat-1',
        title: 'Bot Chat',
        model: 'fixture-model',
        source: 'gateway',
        messageCount: 2,
        isActive: true,
        preview: '',
        startedAt: 1,
        profile: 'cto',
      ),
    );

Future<void> _pumpChat(
  WidgetTester tester, {
  required _FakeDesktopGateway gateway,
  required Session session,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ChatScreen(
        connection: SavedConnection(
          id: 'bot-fixture',
          label: 'Bot fixture',
          host: 'bot.fixture',
          port: 8642,
          apiKey: 'fixture-key',
        ),
        session: session,
        testApiClient: ApiClient(
          baseUrl: 'http://bot.fixture:8642',
          apiKey: 'fixture-key',
          httpClient: _ScriptedHttpClient(gateway.restMessages)
            ..onRequest = gateway.recordRestRequest,
        ),
        testDesktopGateway: gateway,
        testVoiceComposerAdapter: FakeVoiceComposerAdapter(),
      ),
    ),
  );
  await _settle(tester);
}

/// Pumps until the screen has painted the transcript.
///
/// The history read is genuinely async (a real IO client behind the fake
/// transport), and the mock completes synchronously, so a couple of settles
/// are enough — but a bare `pumpAndSettle` can return before the state update
/// lands, which reads as "history is empty" when it is merely late.
Future<void> _settle(WidgetTester tester) async {
  // No `runAsync`: it unblocks platform channels (image_picker's
  // `getLostData`) that have no test implementation and would surface as
  // spurious MissingPluginExceptions. A plain settle is enough — the mock
  // HTTP client answers from an already-completed future.
  await tester.pumpAndSettle();
}

/// Serves the REST fallback exactly as the script dictates, and records every
/// request so a test can prove which transport was actually consulted.
class _ScriptedHttpClient extends http.BaseClient {
  _ScriptedHttpClient(this._messages);

  /// Invoked with each request's path+query so a test can assert which
  /// transport was consulted. The client is created inline where the widget
  /// is pumped, so a callback is the only way its owner can observe it.
  void Function(String)? onRequest;

  final List<Map<String, dynamic>> _messages;

  final List<String> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final pathWithQuery =
        '${request.url.path}${request.url.query.isEmpty ? '' : '?${request.url.query}'}';
    if (request.method == 'GET' && request.url.path.endsWith('/messages')) {
      onRequest?.call(pathWithQuery);
    requests.add(pathWithQuery);
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode({'data': _messages}))),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode({'error': 'unexpected request'}))),
      404,
      headers: {'content-type': 'application/json'},
    );
  }
}

class _FakeDesktopGateway implements DesktopGatewayClient {
  _FakeDesktopGateway(this._result, {required this.restMessages});

  /// The `(runtime id, transcript)` the socket answers with; null makes the
  /// history call throw, modelling a socket that never came up.
  final (String, List<Map<String, dynamic>>)? _result;

  /// What the REST fallback answers with.
  final List<Map<String, dynamic>> restMessages;

  final List<String> restRequests = [];

  /// Records every REST request the injected HTTP client actually made.
  void recordRestRequest(String pathWithQuery) =>
      restRequests.add(pathWithQuery);
  final List<Map<String, dynamic>> resumeCalls = [];

  @override
  Future<(String, List<Map<String, dynamic>>)> resumeSessionWithHistory(
    String sessionId, {
    String? profile,
  }) async {
    resumeCalls.add({'session_id': sessionId, 'profile': profile});
    return _result ?? (throw StateError('gateway offline'));
  }

  @override
  void setAsyncEventListener(DesktopAsyncEventCallback? listener) {}

  @override
  void setConnectionListener(DesktopConnectionCallback? listener) {}

  @override
  Future<void> ensureSession(
    String sessionId, {
    String? workingDirectory,
    String? profile,
  }) async {}

  @override
  void close() {}

  @override
  void noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
