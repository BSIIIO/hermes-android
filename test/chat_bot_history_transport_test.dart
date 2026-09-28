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
    'a scoped bot chat reads its transcript from the dashboard route',
    (tester) async {
      final gateway = _FakeDesktopGateway(('runtime-1', const []));
      final dashboard = _ScriptedDashboardClient(
        messages: <Map<String, dynamic>>[
          {
            'id': 'd1',
            'role': 'user',
            'content': 'remember this',
            'timestamp': '2026-09-28T10:00:00Z',
          },
          {
            'id': 'd2',
            'role': 'assistant',
            'content': 'I remember',
            'timestamp': '2026-09-28T10:00:05Z',
          },
        ],
      );
      await _pumpBotChat(tester, gateway, dashboard);

      // The resume still carries the profile: it binds the runtime session,
      // and without it the stored id does not resolve (gateway answers 4007).
      expect(gateway.resumeCalls, [
        {'session_id': 'bot-chat-1', 'profile': 'cto'},
      ]);
      // ...but the transcript now comes from the dashboard, not the socket.
      expect(dashboard.reads, [
        '/api/sessions/bot-chat-1/messages?profile=cto',
      ]);
      expect(gateway.restRequests, isEmpty);

      // Both turns render: the dashboard route returns the REST body shape
      // (`content`), which the bubbles speak natively.
      expect(find.text('remember this'), findsOneWidget);
      expect(find.text('I remember'), findsOneWidget);
    },
  );

  testWidgets(
    'an unscoped chat still reads its history over the mobile REST route',
    (tester) async {
      final gateway = _FakeDesktopGateway(('ignored', const []))
        ..restMessages = <Map<String, dynamic>>[
          {'id': 'm1', 'role': 'user', 'content': 'plain chat history'},
        ];
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

      // A plain chat still binds, it just has no profile to scope the resume
      // to, so the gateway resolves the id in its own store.
      expect(gateway.resumeCalls, [
        {'session_id': 'plain-session', 'profile': null},
      ]);
      expect(gateway.restRequests, [
        '/api/sessions/plain-session/messages',
      ]);
      expect(find.text('plain chat history'), findsOneWidget);
    },
  );

  testWidgets(
    'a bot transcript keeps its turns when the transport calls the body "text"',
    (tester) async {
      // A transcript can arrive as `{row_id, role, text, timestamp}` — body in
      // `text`, no `content`, and tool results as `role: "tool"`. The bubbles
      // read `content`, so a payload passed through untouched renders as
      // tool-activity cards while every user and assistant turn disappears.
      // Normalization bridges the two shapes.
      final gateway = _FakeDesktopGateway(('runtime-1', const []));
      final dashboard = _ScriptedDashboardClient(
        messages: <Map<String, dynamic>>[
          {'row_id': 1, 'role': 'user', 'text': 'who am i'},
          {'row_id': 2, 'role': 'assistant', 'text': 'The Boss'},
          {
            'row_id': 3,
            'role': 'tool',
            'text': 'source="shell"',
            'name': 'shell',
            'tool_call_id': 'tc1',
          },
        ],
      );
      await _pumpBotChat(tester, gateway, dashboard);

      expect(find.text('who am i'), findsOneWidget);
      expect(find.text('The Boss'), findsOneWidget);
      // The tool row still becomes an activity chip — rendered as a summary
      // ("Tool activity" + a count), not with its own name on screen. That is
      // the one part this shape renders natively, so it must survive the
      // normalization rather than being dropped as an unrecognized row.
      expect(find.text('Tool activity'), findsOneWidget);
      expect(find.text('1 completed'), findsOneWidget);
    },
  );

  testWidgets(
    'a bot chat falls back to the mobile REST route when the dashboard fails',
    (tester) async {
      final gateway = _FakeDesktopGateway(('runtime-1', const []))
        ..restMessages = <Map<String, dynamic>>[
          {'id': 'm1', 'role': 'user', 'content': 'history from REST'},
        ];
      final dashboard = _ScriptedDashboardClient(
        messages: const [],
        failWith: 500,
      );
      await _pumpBotChat(tester, gateway, dashboard);

      expect(dashboard.reads, isNotEmpty);
      expect(gateway.restRequests, ['/api/sessions/bot-chat-1/messages']);
      expect(find.text('history from REST'), findsOneWidget);
    },
  );

  testWidgets(
    'a bot chat stays usable when neither transport has a transcript',
    (tester) async {
      final gateway = _FakeDesktopGateway(('runtime-1', const []));
      final dashboard = _ScriptedDashboardClient(messages: const []);
      await _pumpBotChat(tester, gateway, dashboard);

      // No transcript from either side, but no error banner either: an empty
      // bot chat must still be a usable chat.
      expect(gateway.resumeCalls, isNotEmpty);
      expect(find.byType(TextField), findsOneWidget);
    },
  );
}

Future<void> _pumpBotChat(
  WidgetTester tester,
  _FakeDesktopGateway gateway,
  _ScriptedDashboardClient dashboard,
) =>
    _pumpChat(
      tester,
      gateway: gateway,
      dashboard: dashboard,
      session: const Session(
        id: 'bot-chat-1',
        title: 'Bot Chat',
        model: 'fixture-model',
        source: 'gateway',
        messageCount: 3,
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
  _ScriptedDashboardClient? dashboard,
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
          dashboardPortOverride: 9119,
          dashboardUsername: 'admin',
          dashboardPassword: 'admin',
        ),
        session: session,
        testApiClient: ApiClient(
          baseUrl: 'http://bot.fixture:8642',
          apiKey: 'fixture-key',
          httpClient: _ScriptedHttpClient(gateway.restMessages)
            ..onRequest = gateway.recordRestRequest,
        ),
        testDashboardClient: dashboard == null
            ? null
            : DashboardClient(
                host: 'bot.fixture',
                port: 9119,
                username: 'admin',
                password: 'admin',
                httpClient: dashboard,
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

/// Serves the mobile REST transcript the script dictates, recording the call
/// so a test can prove which transport was consulted.
class _ScriptedHttpClient extends http.BaseClient {
  _ScriptedHttpClient(this._messages);

  /// Invoked with each request's path+query. The client is built inline where
  /// the widget is pumped, so a callback is how its owner observes it.
  void Function(String)? onRequest;

  final List<Map<String, dynamic>> _messages;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final pathWithQuery = Uri.decodeFull(
      '${request.url.path}'
      '${request.url.hasQuery ? "?${request.url.query}" : ""}',
    );
    if (request.method == 'GET' && request.url.path.endsWith('/messages')) {
      onRequest?.call(pathWithQuery);
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode({'data': _messages}))),
      200,
      request: request,
      headers: {'content-type': 'application/json'},
    );
  }
}

/// Serves a dashboard-route transcript and records the request that asked.
///
/// The dashboard is the only transport whose `/api/sessions/{id}/messages`
/// honours `?profile=`, so a test observing this client proves that route was
/// the one consulted for a profile-scoped chat.
class _ScriptedDashboardClient extends http.BaseClient {
  _ScriptedDashboardClient({required this.messages, this.failWith});

  final List<Map<String, dynamic>> messages;

  /// When set, every request fails with this status, modelling a gateway with
  /// no dashboard route so the fallback can be exercised.
  final int? failWith;

  final List<String> requests = [];

  /// The reads the client actually issued, excluding the login round trip it
  /// performs first. Asserting on this proves which route was consulted.
  List<String> get reads => requests
      .where((path) => !path.contains('/auth/'))
      .toList(growable: false);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(
      Uri.decodeFull(
        '${request.url.path}'
        '${request.url.hasQuery ? "?${request.url.query}" : ""}',
      ),
    );
    // The dashboard client logs in with a password and will not issue a read
    // until it has the session cookie, so the login has to look like the real
    // one — otherwise it throws "no session cookie found" and every scoped
    // read silently degrades to the mobile REST route this test is proving is
    // NOT used.
    if (request.url.path.endsWith('/auth/password-login')) {
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode(const {'ok': true}))),
        200,
        request: request,
        headers: {
          'content-type': 'application/json',
          'set-cookie': 'hermes_session_at=fixture-session-token; Path=/; '
              'HttpOnly; SameSite=Lax',
        },
      );
    }
    final status = failWith;
    if (status != null) {
      return http.StreamedResponse(
        Stream.value(utf8.encode('{"detail":"dashboard unavailable"}')),
        status,
        request: request,
      );
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode({'messages': messages}))),
      200,
      request: request,
      headers: {'content-type': 'application/json'},
    );
  }
}

class _FakeDesktopGateway implements DesktopGatewayClient {
  _FakeDesktopGateway(this._result);

  final (String, List<Map<String, dynamic>>)? _result;

  /// `session.resume` calls the screen made, as the params it sent.
  final List<Map<String, dynamic>> resumeCalls = [];

  /// Mobile-REST reads, as path-with-query.
  final List<String> restRequests = [];

  /// What the mobile REST route answers with.
  List<Map<String, dynamic>> restMessages = [];

  void recordRestRequest(String pathWithQuery) =>
      restRequests.add(pathWithQuery);

  @override
  Future<void> ensureSession(
    String sessionId, {
    String? workingDirectory,
    String? profile,
  }) async {
    // The screen binds through `ensureSession`, which is what scopes the
    // runtime session to the profile that owns it — without the profile the
    // gateway resolves the stored id in the launch profile's store and
    // answers `session not found`, so this is the call under test.
    resumeCalls.add({'session_id': sessionId, 'profile': profile});
  }

  @override
  Future<(String, List<Map<String, dynamic>>)> resumeSessionWithHistory(
    String sessionId, {
    String? profile,
  }) async {
    resumeCalls.add({'session_id': sessionId, 'profile': profile});
    if (_result case final result?) return result;
    throw StateError('gateway offline');
  }

  @override
  void setAsyncEventListener(DesktopAsyncEventCallback? listener) {}

  @override
  void setConnectionListener(DesktopConnectionCallback? listener) {}

  @override
  void close() {}

  @override
  void noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
