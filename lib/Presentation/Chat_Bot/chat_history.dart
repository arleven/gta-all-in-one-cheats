import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Presentation/Chat_Bot/chat_view.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatHistorySheet extends StatefulWidget {
  const ChatHistorySheet({super.key});

  @override
  State<ChatHistorySheet> createState() => _ChatHistorySheetState();
}

class _ChatHistorySheetState extends State<ChatHistorySheet> {
  List<ChatSession> sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final loaded = await ChatStorage.getSessions();
    setState(() {
      sessions = loaded;
    });
  }

  void _openChatView(BuildContext context, ChatSession session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatViewScreen(messages: session.messages),
      ),
    );
  }

  Future<void> _deleteSession(ChatSession session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Delete Chat?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete this history?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ChatStorage.deleteSession(session.id);
      await _loadSessions();
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Clear All?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "This will delete all saved chat sessions permanently.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete All",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ChatStorage.clearAllSessions();
      setState(() => sessions.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        child: Text("Chat History"),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: sessions.isEmpty ? null : _clearAll,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade700),
            sessions.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(height: 16),
                          const DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            child: Text("No chat history yet"),
                          ),
                          const SizedBox(height: 8),
                          const DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                            ),
                            child: Text("Your chat sessions will appear here"),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];

                        final firstUserMessage = session.messages.firstWhere(
                          (m) => m["sender"] == "user",
                          orElse: () => {"message": "New conversation"},
                        )["message"];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Dismissible(
                            key: Key(session.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) => _deleteSession(session),
                            child: Material(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                splashColor: Colors.white12,
                                onTap: () => _openChatView(context, session),
                                child: ListTile(
                                  title: Text(
                                    "History ${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    firstUserMessage ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(
                                    session.timeLabel,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                  leading: Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryButton,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.shadowBorder,
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.smart_toy_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      onPressed: sessions.isEmpty
                                          ? null
                                          : _clearAll,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class ChatSession {
  final String id;
  final List<Map<String, String>> messages;
  final String? title;
  final DateTime timestamp;

  ChatSession({
    required this.id,
    required this.messages,
    this.title,
    required this.timestamp,
  });

  String get timeLabel {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return "Now";
    if (diff.inHours < 1) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
  }

  int get messageCount => messages.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'messages': messages,
    'title': title,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    final messages = (json['messages'] as List)
        .map((e) => Map<String, String>.from(e))
        .toList();
    return ChatSession(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      messages: messages,
      title: json['title'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

class ChatStorage {
  static const String key = "chat_sessions";

  static Future<void> saveSession(ChatSession session) async {
    if (session.messages.length <= 1) return;

    final prefs = await SharedPreferences.getInstance();
    final existing = await getSessions();

    existing.removeWhere((s) => s.id == session.id);
    existing.add(session);

    existing.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final encoded = existing.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }

  static Future<List<ChatSession>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(key) ?? [];
    final sessions = encoded
        .map((str) => ChatSession.fromJson(jsonDecode(str)))
        .toList();

    sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sessions;
  }

  static Future<void> clearAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> deleteSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getSessions();
    existing.removeWhere((session) => session.id == sessionId);

    final encoded = existing.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }
}
