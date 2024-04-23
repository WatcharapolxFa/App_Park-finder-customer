import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkfinder_customer/models/message_model.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.reserveID,
    required this.senderID,
    required this.receiverID,
  });

  final String reserveID;
  final String senderID;
  final String receiverID;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> messages = [];
  bool _isLoadMessage = false;
  late ChatService chatService;

  @override
  void initState() {
    super.initState();
    chatService = ChatService(
      reserveID: widget.reserveID,
      senderID: widget.senderID,
      receiverID: widget.receiverID,
      onMessageReceived: (Message message) {
        if (mounted) {
          setState(() {
            messages.add(message);
            _scrollToBottom();
          });
        }
      },
      onHistoryReceived: (List<Message> messageHistory) {
        if (mounted) {
          setState(() {
            messages = messageHistory;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Connection error: $error")),
          );
        }
      },
    );
    loadMessage();
  }

  void loadMessage() async {
    setState(() {
      _isLoadMessage = true;
    });
    await chatService.retrieveMessageLog();
    if (!mounted) return;
    setState(() {
      _isLoadMessage = false;
    });
  }

  @override
  void dispose() {
    _messageInputController.dispose();
    _scrollController.dispose();
    chatService.dispose();
    super.dispose();
  }

  bool get _isMessageNotEmpty => _messageInputController.text.trim().isNotEmpty;

  void _handleSendMessage() {
    if (_isMessageNotEmpty) {
      chatService.sendMessage(_messageInputController.text.trim());
      _messageInputController.clear();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final bottomOffset = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        bottomOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
        backgroundColor: AppColor.appPrimaryColor,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (_isLoadMessage)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isSender = message.senderId == widget.senderID;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isSender
                              ? AppColor.appPrimaryColor
                              : const Color.fromARGB(255, 255, 255, 255),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: isSender
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: TextStyle(
                                fontSize: 15,
                                color: isSender ? Colors.white : Colors.black,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                DateFormat('HH:mm').format(message.time),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color.fromARGB(255, 205, 205, 205)),
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
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 8, bottom: 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageInputController,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      enableSuggestions: true,
                      onChanged: (text) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'กรุณาพิมพ์ข้อความ ...',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_isMessageNotEmpty) {
                        _handleSendMessage();
                      }
                    },
                    icon: const Icon(Icons.send),
                    color: _isMessageNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
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
