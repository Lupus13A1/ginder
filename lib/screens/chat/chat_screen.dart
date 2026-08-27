import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_bottom_sheet.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../safety/report_dialog.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showEmojiTray = false;

  final List<String> _icebreakers = [
    "☕ Wanna grab matcha at the central library?",
    "📚 How's your midterm prep going?",
    "🎨 Love your design taste!",
    "🏸 Up for badminton after class?",
  ];

  final List<String> _emojis = [
    '👋',
    '☕',
    '🎨',
    '✨',
    '📚',
    '🍕',
    '🔥',
    '💯',
    '🎧',
    '⚡',
    '💙',
    '🎉',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().setActiveConversation(widget.conversationId);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage({String? customText, String? icebreaker}) {
    final text = customText ?? _textController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    context.read<ChatProvider>().sendMessage(
      conversationId: widget.conversationId,
      text: text,
      icebreakerTag: icebreaker,
    );

    _textController.clear();
    setState(() => _showEmojiTray = false);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _openPeerProfile() {
    final conv = context.read<ChatProvider>().getConversationById(
      widget.conversationId,
    );
    if (conv == null) return;
    final peer = conv.peer;

    BauhausBottomSheet.show(
      context: context,
      title: '${peer.nickname.toUpperCase()} (PROFILE)',
      headerColor: BauhausColors.primaryYellow,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BauhausAvatar(
                imageUrl: peer.photos.isNotEmpty ? peer.photos.first : null,
                initial: peer.nickname[0],
                size: 70,
                isCircle: false,
                backgroundColor: BauhausColors.primaryBlue,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${peer.name}, ${peer.age}',
                      style: BauhausTextStyles.headlineMedium(),
                    ),
                    const SizedBox(height: 4),
                    BauhausBadge(
                      label: peer.faculty,
                      variant: BauhausBadgeVariant.red,
                    ),
                    const SizedBox(height: 4),
                    Text(peer.major, style: BauhausTextStyles.bodyMedium()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('CAMPUS BIO', style: BauhausTextStyles.badge()),
          const SizedBox(height: 4),
          Text(peer.bio, style: BauhausTextStyles.bodyMedium()),
          const SizedBox(height: 16),
          Text('INTERESTS', style: BauhausTextStyles.badge()),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: peer.interests
                .map(
                  (i) => BauhausBadge(
                    label: i,
                    variant: BauhausBadgeVariant.surface,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          BauhausButton.outline(
            text: 'REPORT OR BLOCK STUDENT',
            isFullWidth: true,
            onPressed: () {
              Navigator.of(context).pop();
              ReportUserDialog.show(context, reportedStudent: peer);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final conv = chatProvider.getConversationById(widget.conversationId);

    if (conv == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('CHAT')),
        body: const Center(child: Text('Conversation not found')),
      );
    }

    final peer = conv.peer;

    return Scaffold(
      backgroundColor: BauhausColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          decoration: const BoxDecoration(
            color: BauhausColors.surface,
            border: Border(
              bottom: BorderSide(color: BauhausColors.border, width: 3.0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: BauhausColors.foreground,
                    ),
                    onPressed: () {
                      chatProvider.setActiveConversation(null);
                      Navigator.of(context).pop();
                    },
                  ),
                  GestureDetector(
                    onTap: _openPeerProfile,
                    child: Row(
                      children: [
                        BauhausAvatar(
                          imageUrl: peer.photos.isNotEmpty
                              ? peer.photos.first
                              : null,
                          initial: peer.nickname[0],
                          size: 40,
                          isCircle: true,
                          backgroundColor: BauhausColors.primaryBlue,
                          borderWidth: 2.0,
                          shadowOffset: 0,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  peer.name.toUpperCase(),
                                  style: BauhausTextStyles.title().copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: conv.isOnline
                                        ? Colors.green
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: BauhausColors.border,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              peer.faculty,
                              style: BauhausTextStyles.caption(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.shield_outlined,
                      color: BauhausColors.primaryRed,
                    ),
                    tooltip: 'Safety & Report',
                    onPressed: () =>
                        ReportUserDialog.show(context, reportedStudent: peer),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              itemCount: conv.messages.length,
              itemBuilder: (context, index) {
                final message = conv.messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Icebreaker Suggestions Bar
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _icebreakers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final icebreaker = _icebreakers[index];
                return GestureDetector(
                  onTap: () => _sendMessage(
                    customText: icebreaker,
                    icebreaker: 'ICEBREAKER',
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: BauhausColors.cardYellow,
                      borderRadius: BorderRadius.zero,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      icebreaker,
                      style: BauhausTextStyles.badge(
                        color: BauhausColors.foreground,
                      ).copyWith(fontSize: 11),
                    ),
                  ),
                );
              },
            ),
          ),

          // Emoji Tray (Collapsible)
          if (_showEmojiTray)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: BauhausColors.surface,
                border: Border(
                  top: BorderSide(color: BauhausColors.border, width: 2.0),
                ),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: _emojis.map((emoji) {
                  return GestureDetector(
                    onTap: () => _sendMessage(customText: emoji),
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  );
                }).toList(),
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: const BoxDecoration(
              color: BauhausColors.surface,
              border: Border(
                top: BorderSide(color: BauhausColors.border, width: 3.0),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Emoji button
                  IconButton(
                    icon: Icon(
                      _showEmojiTray
                          ? Icons.keyboard
                          : Icons.sentiment_satisfied_alt,
                      color: BauhausColors.foreground,
                    ),
                    onPressed: () =>
                        setState(() => _showEmojiTray = !_showEmojiTray),
                  ),
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: BauhausTextStyles.bodyMedium(),
                      decoration: const InputDecoration(
                        hintText: 'Type campus message...',
                        filled: true,
                        fillColor: BauhausColors.background,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                            color: BauhausColors.border,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                            color: BauhausColors.border,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                            color: BauhausColors.primaryBlue,
                            width: 2.5,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send Button
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: BauhausColors.primaryRed,
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: BauhausColors.border,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
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

  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.isFromMe;
    final timeStr =
        '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? BauhausColors.primaryBlue : BauhausColors.surface,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: BauhausColors.border, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: BauhausColors.border,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: BauhausTextStyles.bodyMedium(
                color: isMe ? Colors.white : BauhausColors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: BauhausTextStyles.caption(
                    color: isMe ? Colors.white70 : Colors.grey.shade600,
                  ).copyWith(fontSize: 9),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: msg.isRead
                        ? BauhausColors.primaryYellow
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
