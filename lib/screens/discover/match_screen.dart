import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../models/student_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/discover_provider.dart';
import '../../routes/app_routes.dart';

class MatchScreen extends StatefulWidget {
  final StudentProfile peer;

  const MatchScreen({super.key, required this.peer});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _msgController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
    _msgController.text =
        "Hey ${widget.peer.nickname}! Love that we both study ${widget.peer.interests.isNotEmpty ? widget.peer.interests.first : 'on campus'}!";
  }

  @override
  void dispose() {
    _msgController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _sendAndGoToChat() async {
    final chat = context.read<ChatProvider>();
    final myUid = context.read<AuthProvider>().currentUser.id;
    final users = [myUid, widget.peer.id]..sort();
    final matchId = '${users[0]}_${users[1]}';

    await chat.addMatchFromDiscover(widget.peer);

    final text = _msgController.text.trim();
    if (text.isNotEmpty) {
      await chat.sendMessage(conversationId: matchId, text: text);
      chat.setActiveConversation(matchId);
    }

    if (!mounted) return;
    context.read<DiscoverProvider>().clearMatchCelebration();
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(AppRoutes.chat, arguments: matchId);
  }

  void _keepSwiping() async {
    final chat = context.read<ChatProvider>();
    await chat.addMatchFromDiscover(widget.peer);
    if (!mounted) return;
    context.read<DiscoverProvider>().clearMatchCelebration();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: BauhausColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top geometric bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GeometricBrandMark(size: 14, spacing: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BauhausColors.primaryRed,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      'CAMPUS MATCH',
                      style: BauhausTextStyles.badge(color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                "IT'S A\nMATCH!",
                textAlign: TextAlign.center,
                style: BauhausTextStyles.hero(color: BauhausColors.primaryRed),
              ),

              const SizedBox(height: 8),

              Text(
                "You and ${widget.peer.name} liked each other's university profile.",
                textAlign: TextAlign.center,
                style: BauhausTextStyles.bodyMedium(),
              ),

              const SizedBox(height: 28),

              // Dual Geometric Avatars
              ScaleTransition(
                scale: _scaleAnim,
                child: Center(
                  child: SizedBox(
                    width: 260,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Left User Avatar (Circle)
                        Positioned(
                          left: 10,
                          child: BauhausAvatar(
                            imageUrl: currentUser.photos.isNotEmpty
                                ? currentUser.photos.first
                                : null,
                            initial: currentUser.nickname.isNotEmpty
                                ? currentUser.nickname[0]
                                : 'U',
                            size: 105,
                            isCircle: true,
                            backgroundColor: BauhausColors.primaryBlue,
                            borderWidth: 3.5,
                            shadowOffset: 6.0,
                            showVerifiedBadge: true,
                          ),
                        ),
                        // Right Peer Avatar (Square)
                        Positioned(
                          right: 10,
                          child: BauhausAvatar(
                            imageUrl: widget.peer.photos.isNotEmpty
                                ? widget.peer.photos.first
                                : null,
                            initial: widget.peer.nickname.isNotEmpty
                                ? widget.peer.nickname[0]
                                : 'P',
                            size: 105,
                            isCircle: false,
                            backgroundColor: BauhausColors.primaryYellow,
                            borderWidth: 3.5,
                            shadowOffset: 6.0,
                            showVerifiedBadge: true,
                          ),
                        ),
                        // Center Heart / Geometric Badge
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: BauhausColors.primaryRed,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: BauhausColors.border,
                                width: 2.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: BauhausColors.border,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Faculty connection tag
              Center(
                child: Wrap(
                  spacing: 6,
                  children: [
                    BauhausBadge(
                      label: currentUser.faculty,
                      variant: BauhausBadgeVariant.blue,
                    ),
                    const BauhausBadge(
                      label: '🤝',
                      variant: BauhausBadgeVariant.surface,
                    ),
                    BauhausBadge(
                      label: widget.peer.faculty,
                      variant: BauhausBadgeVariant.yellow,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Quick Icebreaker Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BauhausColors.surface,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: BauhausColors.border, width: 3.0),
                  boxShadow: const [
                    BoxShadow(
                      color: BauhausColors.border,
                      offset: Offset(5, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.chat,
                          size: 16,
                          color: BauhausColors.primaryRed,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'BREAK THE ICE WITH ${widget.peer.nickname.toUpperCase()}:',
                          style: BauhausTextStyles.badge(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _msgController,
                      maxLines: 2,
                      style: BauhausTextStyles.bodyMedium(),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: BauhausColors.background,
                        hintText: 'Write a quick hello...',
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                            color: BauhausColors.border,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              BauhausButton(
                text: 'SEND MESSAGE & CHAT',
                isFullWidth: true,
                height: 52,
                variant: BauhausButtonVariant.primaryRed,
                icon: const Icon(Icons.send, size: 18),
                onPressed: _sendAndGoToChat,
              ),

              const SizedBox(height: 12),

              BauhausButton.outline(
                text: 'KEEP SWIPING CAMPUS',
                isFullWidth: true,
                height: 50,
                onPressed: _keepSwiping,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
