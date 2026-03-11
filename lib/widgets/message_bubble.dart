import 'dart:convert';
import 'package:flutter/material.dart';

const _vividPurple = Color(0xFF6C2EB9);
const _lightPurple = Color(0xFFA855F7);
const _glowPurple = Color(0xFFC084FC);
const _white = Color(0xFFF5F0FF);
const _whiteDim = Color(0x8FF5F0FF);

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  final bool isFirstInSequence;
  final String? userImage;
  final String? username;
  final String message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInSequence ? 14 : 3,
        left: isMe ? 60 : 0,
        right: isMe ? 0 : 60,
      ),
      child: isMe ? _buildMeBubble() : _buildOtherBubble(),
    );
  }

  Widget _buildMeBubble() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isFirstInSequence) ...[
          Text(
            username ?? '',
            style: const TextStyle(
              color: _glowPurple,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _BubbleBox(
              message: message,
              isMe: true,
              isFirstInSequence: isFirstInSequence,
            ),
            if (isFirstInSequence) ...[
              const SizedBox(width: 8),
              _Avatar(imageUrl: userImage),
            ] else
              const SizedBox(width: 40),
          ],
        ),
      ],
    );
  }

  Widget _buildOtherBubble() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFirstInSequence) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Avatar(imageUrl: userImage),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username ?? '',
                    style: const TextStyle(
                      color: _whiteDim,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _BubbleBox(
                    message: message,
                    isMe: false,
                    isFirstInSequence: true,
                  ),
                ],
              ),
            ],
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: _BubbleBox(
              message: message,
              isMe: false,
              isFirstInSequence: false,
            ),
          ),
      ],
    );
  }
}

class _BubbleBox extends StatelessWidget {
  const _BubbleBox({
    required this.message,
    required this.isMe,
    required this.isFirstInSequence,
  });

  final String message;
  final bool isMe;
  final bool isFirstInSequence;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.60,
      ),
      decoration: BoxDecoration(
        gradient: isMe
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
              )
            : null,
        color: isMe ? null : const Color(0xFF1E0C3C).withOpacity(0.85),
        border: isMe
            ? null
            : Border.all(color: _lightPurple.withOpacity(0.35), width: 1.2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMe || !isFirstInSequence ? 18 : 4),
          topRight: Radius.circular(!isMe || !isFirstInSequence ? 18 : 4),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
        boxShadow: isMe
            ? [
                BoxShadow(
                  color: _vividPurple.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Text(
        message,
        style: TextStyle(
          color: isMe ? Colors.white : _white,
          fontSize: 14,
          height: 1.4,
        ),
        softWrap: true,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isBase64 = imageUrl != null && imageUrl!.startsWith('data:image');

    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _lightPurple.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: _vividPurple.withOpacity(0.3), blurRadius: 8),
        ],
        color: const Color(0xFF2D1154),
      ),
      child: ClipOval(
        child: (imageUrl != null && imageUrl!.isNotEmpty)
            ? isBase64
                ? Image.memory(
                    base64Decode(imageUrl!.split(',').last),
                    width: 32, height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, s) =>
                        const Icon(Icons.person, color: _whiteDim, size: 18),
                  )
                : Image.network(
                    imageUrl!,
                    width: 32, height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, s) =>
                        const Icon(Icons.person, color: _whiteDim, size: 18),
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              color: _lightPurple, strokeWidth: 1.5),
                        ),
                      );
                    },
                  )
            : const Icon(Icons.person, color: _whiteDim, size: 18),
      ),
    );
  }
}
