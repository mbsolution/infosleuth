import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/osint_service.dart';

/// Represents a single chat message.
class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Manages chat messages and calls the OSINT orchestrator.
class ChatProvider with ChangeNotifier {
  final List<Message> _messages = [];
  List<Message> get messages => List.unmodifiable(_messages);

  bool _isSending = false;
  bool get isSending => _isSending;

  /// Sends a user message and fetches the OSINT response.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _messages.add(Message(text: trimmed, isUser: true));
    _isSending = true;
    notifyListeners();

    try {
      final responseText = await OsintService.fetchResponse(trimmed);
      _messages.add(Message(text: responseText, isUser: false));
    } catch (e) {
      _messages.add(Message(text: 'Error: ${e.toString()}', isUser: false));
    }

    _isSending = false;
    notifyListeners();
  }

  /// Clears the chat history.
  void clear() {
    _messages.clear();
    notifyListeners();
  }
}

/// Chat screen with polished bubble UI and real API integration.
class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({Key? key}) : super(key: key);

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final messages = chat.messages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reverse Lookup Chat'),
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            icon: const Icon(Icons.delete_outline),
            onPressed: chat.clear,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser = msg.isUser;
                  final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
                  final bgColor = isUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant;
                  final textColor = isUser
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant;
                  final borderRadius = BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                    bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                  );

                  return Align(
                    alignment: align,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: borderRadius,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.text,
                            style: TextStyle(color: textColor, height: 1.3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(msg.timestamp),
                            style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type phone, email, address or question…',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: chat.isSending ? null : () => _send(context),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: chat.isSending
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                          : Theme.of(context).colorScheme.primary,
                      child: chat.isSending
                          ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send(BuildContext context) {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(text.trim());
    _controller.clear();
  }

  String _formatTimestamp(DateTime ts) {
    final h = ts.hour.toString().padLeft(2, '0');
    final m = ts.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
