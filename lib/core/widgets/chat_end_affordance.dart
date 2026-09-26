import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

/// Accessible floating action that returns a chat to its current end.
class ChatEndAffordance extends StatelessWidget {
  static const buttonKey = Key('chat-go-to-end');
  static const countKey = Key('chat-new-message-count');

  final int newMessageCount;
  final VoidCallback onPressed;

  const ChatEndAffordance({
    required this.newMessageCount,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final indicatorText = switch (newMessageCount) {
      0 => s.chatLatest,
      1 => s.chatOneNewMessage,
      _ => s.chatNewMessages(newMessageCount),
    };
    final semanticsValue = switch (newMessageCount) {
      0 => s.chatNoNewMessages,
      1 => s.chatOneNewMessage,
      _ => s.chatNewMessages(newMessageCount),
    };

    return Semantics(
      label: s.chatGoToEnd,
      value: semanticsValue,
      button: true,
      excludeSemantics: true,
      child: FloatingActionButton.extended(
        key: buttonKey,
        heroTag: null,
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_downward_rounded),
        label: Text(indicatorText, key: countKey),
      ),
    );
  }
}
