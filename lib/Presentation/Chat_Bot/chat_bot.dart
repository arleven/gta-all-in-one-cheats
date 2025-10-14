import 'package:all_gta/Models/theme_colors.dart';
import 'package:all_gta/Networking/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
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
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];

  late OpenAI openAI;
  String? _userId;
  bool _isSendEnabled = false;

  @override
  void initState() {
    super.initState();
    print(_userId);
    openAI = OpenAI.instance.build(
      token: ApiEndpoints.chatbotkey,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 60)),
      enableLog: true,
    );

    _initUserId();

    _messages.add({
      "sender": "bot",
      "message":
          "Hey there! 👋 Please tell me what you want to know about ${widget.initialQuestions}.",
    });

    _controller.addListener(() {
      setState(() {
        _isSendEnabled = _controller.text.trim().isNotEmpty;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _initUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("userId");
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString("userId", id);
    }
    setState(() => _userId = id);
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

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || !_isSendEnabled) return;

    setState(() {
      _messages.add({"sender": "user", "message": text});
      _controller.clear();
      _messages.add({"sender": "bot", "message": "..."});
    });

    _scrollToBottom();

    _fetchBotReply(text).then((reply) {
      setState(() {
        _messages.removeLast();
        _messages.add({"sender": "bot", "message": reply});
      });
      _scrollToBottom();
    });
  }

  Future<String> _fetchBotReply(String userMessage) async {
    try {
      final chatRequest = ChatCompleteText(
        model: Gpt4ChatModel(),
        messages: [
          {
            "role": "system",
            "content":
                "You are an expert AI assistant for Grand Theft Auto games. Always tailor responses for the specified platform and GTA version. Give cheats, gameplay help, or mission tips that work for that setup.",
          },
          {
            "role": "user",
            "content":
                "Platform and Game Context: ${widget.initialQuestions}. The user wants help related to this setup.",
          },
          ..._messages.map(
            (msg) => {
              "role": msg["sender"] == "user" ? "user" : "assistant",
              "content": msg["message"] ?? "",
            },
          ),
          {"role": "user", "content": userMessage},
        ],
      );

      final response = await openAI.onChatCompletion(request: chatRequest);
      final reply =
          response?.choices.first.message?.content.trim() ??
          "Sorry, I couldn't get a response.";
      return reply;
    } catch (e) {
      print("ChatGPT SDK error: $e");
      return "Something went wrong while talking to the AI.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
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
                    child: const Text("Close", style: TextStyle(fontSize: 16)),
                  ),
                  const Text(
                    "Chatbot",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(width: 64),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg["sender"] == "user";

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.primaryButton
                            : Color.fromRGBO(42, 40, 40, 1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg["message"] ?? "",
                        style: TextStyle(
                          color: isUser ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1, color: Colors.white24),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white10,
                        hintText: "Ask about cheats, missions, etc...",
                        hintStyle: const TextStyle(color: Colors.white54),
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
                          : Colors.grey[700],
                    ),
                    onPressed: _isSendEnabled ? _sendMessage : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
