import 'package:flutter/material.dart';
import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Presentation/Chat_Bot/chat_history.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatBot extends StatefulWidget {
  final String initialQuestions;

  const ChatBot({super.key, required this.initialQuestions});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  List<ChatSession> chatSessions = [];
  final _scrollController = ScrollController();
  bool _isSendEnabled = false;

  final String _persona = "GTA San Andreas";

  String? _userId;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isSendEnabled = _controller.text.trim().isNotEmpty;
      });
    });
    _initUserId();

    _messages.add({"sender": "bot", "message": "${widget.initialQuestions}."});

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _initUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString("userId");

    if (storedId == null || storedId.isEmpty) {
      storedId = const Uuid().v4();
      await prefs.setString("userId", storedId);
    }

    setState(() {
      _userId = storedId;
    });
  }

  @override
  void dispose() {
    final hasUserMessage = _messages.any(
      (m) => m["sender"] == "user" && m["message"]!.trim().isNotEmpty,
    );
    final hasBotReply = _messages.any(
      (m) =>
          m["sender"] == "bot" &&
          m["message"]!.trim().isNotEmpty &&
          m["message"] != widget.initialQuestions,
    );

    if (hasUserMessage && hasBotReply) {
      ChatStorage.saveSession(ChatSession(messages: _messages));
    }
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (!_isSendEnabled) return;
    setState(() {
      _messages.add({"sender": "user", "message": text});
      _controller.clear();
    });

    _scrollToBottom();

    setState(() {
      _messages.add({"sender": "bot", "message": "..."});
    });
    _scrollToBottom();

    fetchBotReply(text, context).then((reply) {
      setState(() {
        _messages.removeLast();
        _messages.add({
          "sender": "bot",
          "message": reply ?? "Sorry, something went wrong.",
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<String?> fetchBotReply(
    String latestUserMessage,
    BuildContext context,
  ) async {
    if (_userId == null) return "Error: User ID not ready";

    final String persona = _persona;
    final String messageWithCode =
        "$latestUserMessage [CODE: ${widget.initialQuestions}]";
    final url = Uri.parse(
      'https://quiz-api-pudf.onrender.com/v1/apps/6836d0bb4c85b017bc545b4f/chat',
    );

    final payload = {
      "userId": _userId,
      "persona": persona,
      "message": messageWithCode,
    };

    print("Sending payload: ${jsonEncode(payload)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? botReply = data["data"]?["response"];
        return botReply?.isNotEmpty == true
            ? botReply
            : "Sorry, no response from the bot.";
      } else {
        return "Sorry, the chatbot is unavailable. (Error: ${response.statusCode})";
      }
    } catch (e) {
      print("Request failed: $e");
      return "Network error. Please try again.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Close",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const Text(
                      "AI Chat",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return const FractionallySizedBox(
                            heightFactor: 0.95,
                            child: ChatHistorySheet(),
                          );
                        },
                      ),
                      child: const Text(
                        "History",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      reverse: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ..._messages.map((msg) {
                            final isUser = msg["sender"] == "user";
                            return Row(
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isUser)
                                  CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardColor,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? Theme.of(context).cardColor
                                          : AppColors.primaryButton,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      msg["message"] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          if (_messages.isNotEmpty &&
                              _messages.last["sender"] == "bot")
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: [const SizedBox(width: 8)]),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(
                height: 1,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            hintText: "E.g., queries for question...",
                            hintStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: _isSendEnabled
                              ? AppColors.primaryButton
                              : Colors.grey,
                        ),
                        onPressed: _isSendEnabled ? _sendMessage : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> resetChatSession(BuildContext context) async {
    if (_userId == null) return;

    final url = Uri.parse(
      'https://quiz-api-pudf.onrender.com/v1/apps/6836d0bb4c85b017bc545b4f/reset',
    );
    final payload = {"userId": _userId};

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print("Chat reset successful");
      } else {
        print(
          "Failed to reset chat. Status: ${response.statusCode}, body: ${response.body}",
        );
      }
    } catch (e) {
      print("Reset request failed: $e");
    }
  }

  // Widget _suggestionChip(String text) {
  //   return ActionChip(
  //     label: Text(text, style: TextStyle(color: Theme.of(context).cardColor)),
  //     backgroundColor: ThemeColors.lightButtonColor(context),
  //     onPressed: () {
  //       _controller.text = text;
  //       _sendMessage();
  //     },
  //   );
  // }
}
