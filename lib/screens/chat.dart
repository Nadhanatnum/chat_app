import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // gradient bg
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0520),
                  Color(0xFF1A0A2E),
                  Color(0xFF0D0520)
                ],
              ),
            ),
          ),
          // subtle glow top
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF6C2EB9).withOpacity(0.25),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                const Expanded(child: ChatMessages()),
                const NewMessage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0C3C).withOpacity(0.85),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFA855F7).withOpacity(0.20),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // logo icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA855F7).withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          // title
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              children: [
                TextSpan(
                  text: 'Flutter',
                  style: TextStyle(color: Color(0xFFF5F0FF)),
                ),
                TextSpan(
                  text: 'Chat',
                  style: TextStyle(color: Color(0xFFC084FC)),
                ),
              ],
            ),
          ),
          const Spacer(),
          // logout button
          GestureDetector(
            onTap: () => FirebaseAuth.instance.signOut(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C2EB9).withOpacity(0.15),
                border: Border.all(
                  color: const Color(0xFFA855F7).withOpacity(0.25),
                ),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFA855F7),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
