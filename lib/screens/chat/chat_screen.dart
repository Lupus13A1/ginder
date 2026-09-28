import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_snackbar.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/image_upload_service.dart';
import '../../models/student_profile.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_dialog.dart';
import '../../widgets/bauhaus_bottom_sheet.dart';
import '../safety/report_dialog.dart';
import '../profile/profile_preview_dialog.dart';

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

  bool _isUploadingImage = false;
  int _lastMessageCount = 0;

  void _sendMessage({String? customText, String? icebreaker}) async {
    final text = customText ?? _textController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    _textController.clear();
    setState(() => _showEmojiTray = false);

    await context.read<ChatProvider>().sendMessage(
      conversationId: widget.conversationId,
      text: text,
      icebreakerTag: icebreaker,
    );

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<void> _sendImageMessage() async {
    if (_isUploadingImage) return;

    final source = await ImageUploadService.showImageSourceDialog(context);
    if (source == null) return;

    final picked = await ImageUploadService.pickImage(source);
    if (picked == null) return;

    setState(() => _isUploadingImage = true);

    final result = await ImageUploadService.uploadImage(picked);

    if (!mounted) return;
    setState(() => _isUploadingImage = false);

    if (result.isSuccess && result.url != null) {
      await context.read<ChatProvider>().sendMessage(
        conversationId: widget.conversationId,
        text: '',
        imageUrl: result.url!,
      );
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } else {
      BauhausSnackBar.showError(
        context,
        result.errorMessage ?? 'Failed to upload photo',
      );
    }
  }

  void _openPeerProfile() {
    final conv = context.read<ChatProvider>().getConversationById(
      widget.conversationId,
    );
    if (conv == null) return;
    final peer = conv.peer;
    ProfilePreviewDialog.show(
      context,
      peer,
      onUnmatchedOrBlocked: () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  void _showChatSafetyOptions(StudentProfile peer) {
    BauhausBottomSheet.show(
      context: context,
      title: 'CHAT & SAFETY OPTIONS',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary Action: UNMATCH (prominent, accessible)
          BauhausButton(
            text: 'UNMATCH',
            variant: BauhausButtonVariant.black,
            isFullWidth: true,
            icon: const Icon(Icons.heart_broken_outlined, size: 18),
            onPressed: () {
              Navigator.of(context).pop();
              _confirmUnmatchChat(peer);
            },
          ),
          const SizedBox(height: 10),
          // Secondary Action: BLOCK (lower visual weight)
          BauhausButton.outline(
            text: 'BLOCK ${peer.nickname.toUpperCase()}',
            isFullWidth: true,
            icon: const Icon(
              Icons.block,
              size: 18,
              color: BauhausColors.primaryRed,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _confirmBlockChat(peer);
            },
          ),
          const SizedBox(height: 10),
          // Tertiary Action: REPORT
          BauhausButton(
            text: 'REPORT STUDENT / INCIDENT',
            variant: BauhausButtonVariant.ghost,
            isFullWidth: true,
            icon: Icon(
              Icons.flag_outlined,
              size: 18,
              color: BauhausColors.foreground,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              ReportUserDialog.show(context, reportedStudent: peer);
            },
          ),
        ],
      ),
    );
  }

  void _confirmUnmatchChat(StudentProfile peer) {
    BauhausDialog.show(
      context: context,
      title: 'Unmatch Student',
      headerColor: BauhausColors.primaryYellow,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BauhausColors.cardYellow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.heart_broken_outlined,
              size: 32,
              color: BauhausColors.foreground,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Unmatch with ${peer.name.toUpperCase()}?',
            textAlign: TextAlign.center,
            style: BauhausTextStyles.title(),
          ),
          const SizedBox(height: 8),
          Text(
            'Unmatching will remove your conversation history. You may still encounter each other again in Discover in the future.',
            textAlign: TextAlign.center,
            style: BauhausTextStyles.bodyMedium(),
          ),
        ],
      ),
      primaryActionText: 'UNMATCH',
      primaryActionVariant: BauhausButtonVariant.black,
      secondaryActionText: 'CANCEL',
      onPrimaryAction: () async {
        Navigator.of(context).pop(); // dismiss dialog
        final chat = context.read<ChatProvider>();
        await chat.unmatch(
          conversationId: widget.conversationId,
          peerUid: peer.id,
        );
        if (mounted) {
          Navigator.of(context).pop(); // pop ChatScreen back to Matches
          BauhausSnackBar.showSuccess(
            context,
            'Unmatched with ${peer.nickname}',
          );
        }
      },
    );
  }

  void _confirmBlockChat(StudentProfile peer) {
    BauhausDialog.show(
      context: context,
      title: 'Block Student',
      headerColor: BauhausColors.primaryRed,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BauhausColors.primaryRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.block,
              size: 32,
              color: BauhausColors.primaryRed,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Block ${peer.name.toUpperCase()}?',
            textAlign: TextAlign.center,
            style: BauhausTextStyles.title(),
          ),
          const SizedBox(height: 8),
          Text(
            'Blocking will immediately unmatch and delete all chat history. This student will never appear in your Discover swipe feed or match with you again.',
            textAlign: TextAlign.center,
            style: BauhausTextStyles.bodyMedium(),
          ),
        ],
      ),
      primaryActionText: 'BLOCK USER',
      primaryActionVariant: BauhausButtonVariant.primaryRed,
      secondaryActionText: 'CANCEL',
      onPrimaryAction: () async {
        Navigator.of(context).pop(); // dismiss dialog
        final auth = context.read<AuthProvider>();
        final chat = context.read<ChatProvider>();
        await auth.blockUser(peer.id);
        await chat.block(
          conversationId: widget.conversationId,
          peerUid: peer.id,
        );
        if (mounted) {
          Navigator.of(context).pop(); // pop ChatScreen back to Matches
          BauhausSnackBar.showError(
            context,
            'Blocked ${peer.nickname}. You will not see this student again.',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final conv = chatProvider.getConversationById(widget.conversationId);

    if (conv == null) {
      return Scaffold(
        backgroundColor: BauhausColors.background,
        appBar: AppBar(
          backgroundColor: BauhausColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: BauhausColors.foreground),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('CAMPUS CHAT', style: BauhausTextStyles.headlineMedium()),
        ),
        body: Center(
          child: chatProvider.isLoading
              ? const CircularProgressIndicator(
                  color: BauhausColors.primaryRed,
                  strokeWidth: 3.0,
                )
              : Text(
                  'Conversation not found',
                  style: BauhausTextStyles.bodyMedium(),
                ),
        ),
      );
    }

    if (conv.messages.length != _lastMessageCount) {
      _lastMessageCount = conv.messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    final peer = conv.peer;

    return Scaffold(
      backgroundColor: BauhausColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          decoration: BoxDecoration(
            color: BauhausColors.surface,
            border: Border(
              bottom: BorderSide(color: BauhausColors.border, width: 1.0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
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
                          borderWidth: 1.0,
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
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: BauhausColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        Icons.more_horiz,
                        color: BauhausColors.foreground,
                        size: 20,
                      ),
                    ),
                    tooltip: 'More Options',
                    onPressed: () => _showChatSafetyOptions(peer),
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
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: BauhausColors.cardYellow,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
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
              decoration: BoxDecoration(
                color: BauhausColors.surface,
                border: Border(
                  top: BorderSide(color: BauhausColors.border, width: 1.0),
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
            decoration: BoxDecoration(
              color: BauhausColors.surface,
              border: Border(
                top: BorderSide(color: BauhausColors.border, width: 1.0),
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
                  // Image attachment button
                  IconButton(
                    icon: _isUploadingImage
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: BauhausColors.primaryRed,
                            ),
                          )
                        : Icon(
                            Icons.add_photo_alternate_outlined,
                            color: BauhausColors.foreground,
                          ),
                    tooltip: 'Send Photo',
                    onPressed: _isUploadingImage ? null : _sendImageMessage,
                  ),
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: BauhausTextStyles.bodyMedium(),
                      decoration: InputDecoration(
                        hintText: 'Type campus message...',
                        filled: true,
                        fillColor: BauhausColors.background,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: BauhausColors.border,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: BauhausColors.border,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: BauhausColors.primaryBlue,
                            width: 1.5,
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
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
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
          borderRadius: isMe
              ? const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
          border: Border.all(
            color: isMe ? BauhausColors.primaryBlue : BauhausColors.border,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (msg.imageUrl != null && msg.imageUrl!.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BauhausColors.border, width: 1.0),
                ),
                child: Image.network(
                  msg.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey.shade200,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, size: 24, color: Colors.grey),
                        SizedBox(width: 6),
                        Text('Image failed to load'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (msg.text.isNotEmpty)
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
