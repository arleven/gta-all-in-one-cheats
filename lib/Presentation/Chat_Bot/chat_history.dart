import 'package:flutter/material.dart';
import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Presentation/Chat_Bot/chat_view.dart';
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
      sessions = loaded.reversed.toList();
    });
  }

  void _openChatView(BuildContext context, List<Map<String, String>> messages) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ChatViewScreen(messages: messages),
        transitionsBuilder: (_, animation, __, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const Text(
                    "History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade700),
            sessions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "No chat history yet.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final preview = session.messages.firstWhere(
                          (m) => m["sender"] == "user",
                          orElse: () => {"message": ""},
                        )["message"];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6.0,
                          ),
                          child: GestureDetector(
                            onTap: () =>
                                _openChatView(context, session.messages),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryButton,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "General Chat",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          preview ?? '',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
  final List<Map<String, String>> messages;

  ChatSession({required this.messages});

  Map<String, dynamic> toJson() => {'messages': messages};

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    final messages = (json['messages'] as List)
        .map((e) => Map<String, String>.from(e))
        .toList();
    return ChatSession(messages: messages);
  }
}

class ChatStorage {
  static const String key = "chat_sessions";

  static Future<void> saveSession(ChatSession session) async {
    // Check if the session actually has meaningful chat
    final hasRealMessages = session.messages.any((m) {
      final text = (m["message"] ?? "").trim();
      final sender = m["sender"] ?? "";
      return text.isNotEmpty &&
          !text.toLowerCase().contains("ask me anything") &&
          sender.isNotEmpty;
    });

    // Only save if there's real conversation
    if (!hasRealMessages) return;

    final prefs = await SharedPreferences.getInstance();
    final existing = await getSessions();

    existing.add(session);
    final encoded = existing.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }

  static Future<List<ChatSession>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(key) ?? [];

    return encoded.map((str) => ChatSession.fromJson(jsonDecode(str))).toList();
  }

  static Future<void> clearAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
