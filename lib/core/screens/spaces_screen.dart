import 'package:flutter/material.dart';

import '../models/session.dart';
import '../l10n/app_strings.dart';
import '../services/chat_space_store.dart';

class SpacesScreen extends StatefulWidget {
  final ChatSpaceStore store;
  final List<Session> sessions;
  final ValueChanged<ChatSpaceScope> onScopeSelected;

  const SpacesScreen({
    required this.store,
    required this.sessions,
    required this.onScopeSelected,
    super.key,
  });

  @override
  State<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends State<SpacesScreen> {
  ChatSpaceState? _state;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = await widget.store.load();
    if (mounted) setState(() => _state = state);
  }

  Future<void> _createSpace() async {
    var draft = '';
    String? error;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final s = AppStrings.of(dialogContext);
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(s.spacesNewDialogTitle),
            content: TextField(
              key: const Key('space-name'),
              autofocus: true,
              maxLength: 80,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: s.spacesNameLabel,
                errorText: error,
              ),
              onChanged: (value) => draft = value,
              onSubmitted: (value) {
                final normalized = value.trim();
                if (normalized.isEmpty) {
                  setDialogState(() => error = s.spacesNameRequired);
                } else {
                  Navigator.pop(dialogContext, normalized);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(s.commonCancel),
              ),
              FilledButton(
                onPressed: () {
                  final normalized = draft.trim();
                  if (normalized.isEmpty) {
                    setDialogState(() => error = s.spacesNameRequired);
                  } else {
                    Navigator.pop(dialogContext, normalized);
                  }
                },
                child: Text(s.projectsCreate),
              ),
            ],
          ),
        );
      },
    );
    if (name == null || !mounted) return;
    try {
      await widget.store.createSpace(name);
      await _load();
    } on FormatException catch (exception) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(exception.message.toString())));
    }
  }

  Future<void> _renameSpace(ChatSpace space) async {
    var draft = space.name;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final s = AppStrings.of(dialogContext);
        return AlertDialog(
          title: Text(s.spacesRenameDialogTitle),
          content: TextFormField(
            key: const Key('rename-space-name'),
            initialValue: space.name,
            autofocus: true,
            maxLength: 80,
            decoration: InputDecoration(labelText: s.spacesNameLabel),
            onChanged: (value) => draft = value,
            onFieldSubmitted: (value) =>
                Navigator.pop(dialogContext, value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(s.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, draft.trim()),
              child: Text(s.cronSaveAction),
            ),
          ],
        );
      },
    );
    if (name == null || name.isEmpty || !mounted) return;
    try {
      await widget.store.renameSpace(space.id, name);
      await _load();
    } on FormatException catch (exception) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(exception.message.toString())));
    }
  }

  String _countLabel(AppStrings s, int count) => count == 1
      ? s.projectsOneChat
      : s.projectsChatCount.replaceAll('{0}', '$count');

  String? _activityLabel(AppStrings s, double? timestamp) {
    if (timestamp == null) return null;
    final date = DateTime.fromMillisecondsSinceEpoch(
      (timestamp * 1000).toInt(),
    );
    final formatted = '${date.day}/${date.month}/${date.year}';
    return s.spacesLastActivity.replaceAll('{0}', formatted);
  }

  Widget _scopeTile({
    required Key key,
    required IconData icon,
    required String title,
    required int count,
    required ChatSpaceScope scope,
    Widget? trailing,
    String? detail,
  }) {
    return ListTile(
      key: key,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_countLabel(AppStrings.of(context), count)),
          if (detail != null) Text(detail),
        ],
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: () => widget.onScopeSelected(scope),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.spacesTitle),
        actions: [
          IconButton(
            key: const Key('create-space'),
            tooltip: s.spacesNewSpace,
            onPressed: _createSpace,
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
        ],
      ),
      body: state == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _scopeTile(
                  key: const Key('space-all'),
                  icon: Icons.forum_outlined,
                  title: s.spacesAllChats,
                  count: widget.sessions.length,
                  scope: const ChatSpaceScope.all(),
                ),
                _scopeTile(
                  key: const Key('space-unassigned'),
                  icon: Icons.inbox_outlined,
                  title: s.spacesUnassigned,
                  count: state
                      .sessionsFor(
                        widget.sessions,
                        const ChatSpaceScope.unassigned(),
                      )
                      .length,
                  scope: const ChatSpaceScope.unassigned(),
                ),
                if (state.spaces.isNotEmpty) const Divider(),
                for (final space in state.spaces)
                  _scopeTile(
                    key: Key('space-${space.id}'),
                    icon: Icons.folder_outlined,
                    title: space.name,
                    count: state
                        .sessionsFor(
                          widget.sessions,
                          ChatSpaceScope.space(space.id),
                        )
                        .length,
                    scope: ChatSpaceScope.space(space.id),
                    detail: _activityLabel(
                      s,
                      state.latestActivityFor(widget.sessions, space.id),
                    ),
                    trailing: PopupMenuButton<String>(
                      key: Key('space-menu-${space.id}'),
                      tooltip: s.spacesActions,
                      onSelected: (action) {
                        if (action == 'rename') _renameSpace(space);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'rename',
                          child: ListTile(
                            leading: const Icon(Icons.edit_outlined),
                            title: Text(s.spacesRename),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (state.spaces.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(s.spacesEmptyHint, textAlign: TextAlign.center),
                  ),
              ],
            ),
    );
  }
}
