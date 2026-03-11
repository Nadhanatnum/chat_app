import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  final _focusNode = FocusNode();
  var _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text.trim();
    if (enteredMessage.isEmpty) return;

    _messageController.clear();
    _focusNode.requestFocus();

    setState(() => _isSending = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      await FirebaseFirestore.instance.collection('chat').add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData.data()!['username'],
        'userImage': userData.data()!['image_url'],
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E0C3C),
        border: Border(
          top: BorderSide(color: const Color(0xFFA855F7).withOpacity(0.20)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6C2EB9).withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFA855F7).withOpacity(0.25),
                ),
              ),
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter &&
                      !HardwareKeyboard.instance.isShiftPressed) {
                    _submitMessage();
                  }
                },
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  autofocus: true,
                  style: const TextStyle(
                    color: Color(0xFFF5F0FF),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Send a message...',
                    hintStyle: TextStyle(
                      color: const Color(0xFFF5F0FF).withOpacity(0.35),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isSending ? null : _submitMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isSending
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF9333EA), Color(0xFFC084FC)],
                      ),
                color: _isSending
                    ? const Color(0xFF6C2EB9).withOpacity(0.3)
                    : null,
                boxShadow: _isSending
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFFA855F7).withOpacity(0.45),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Color(0xFFC084FC),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
