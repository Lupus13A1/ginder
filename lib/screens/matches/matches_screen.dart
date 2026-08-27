import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../models/match_model.dart';
import '../../providers/chat_provider.dart';
import '../../routes/app_routes.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final allConversations = chatProvider.conversations;

    final filteredConversations = allConversations.where((c) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return c.peer.name.toLowerCase().contains(q) ||
          c.peer.nickname.toLowerCase().contains(q) ||
          c.peer.faculty.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: BauhausColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: BauhausColors.surface,
                border: Border(
                  bottom: BorderSide(color: BauhausColors.border, width: 3.0),
                ),
              ),
              child: Row(
                children: [
                  const GeometricBrandMark(size: 13, spacing: 5),
                  const SizedBox(width: 10),
                  Text(
                    'MATCHES & CHATS',
                    style: BauhausTextStyles.headlineMedium().copyWith(
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  if (chatProvider.totalUnreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: BauhausColors.primaryRed,
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${chatProvider.totalUnreadCount} NEW',
                        style: BauhausTextStyles.badge(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: BauhausTextStyles.bodyMedium(),
                decoration: InputDecoration(
                  hintText: 'Search campus matches by name or faculty...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: BauhausColors.foreground,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: BauhausColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(
                      color: BauhausColors.border,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                children: [
                  // New Matches Horizontal Section
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        color: BauhausColors.primaryRed,
                        margin: const EdgeInsets.only(right: 6),
                      ),
                      Text(
                        'NEW MATCHES (${allConversations.length})',
                        style: BauhausTextStyles.badge().copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: allConversations.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final conv = allConversations[index];
                        final peer = conv.peer;
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.chat, arguments: conv.id);
                          },
                          child: Column(
                            children: [
                              BauhausAvatar(
                                imageUrl: peer.photos.isNotEmpty
                                    ? peer.photos.first
                                    : null,
                                initial: peer.nickname[0],
                                size: 58,
                                isCircle: true,
                                backgroundColor: index % 2 == 0
                                    ? BauhausColors.primaryBlue
                                    : BauhausColors.primaryYellow,
                                borderWidth: 2.5,
                                shadowOffset: 3.0,
                                showVerifiedBadge: peer.isVerifiedStudent,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                peer.nickname.toUpperCase(),
                                style: BauhausTextStyles.badge().copyWith(
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(
                    thickness: 2.0,
                    color: BauhausColors.border,
                    height: 24,
                  ),

                  // Active Conversations Header
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        color: BauhausColors.primaryBlue,
                        margin: const EdgeInsets.only(right: 6),
                      ),
                      Text(
                        'CONVERSATIONS',
                        style: BauhausTextStyles.badge().copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Conversations list
                  if (filteredConversations.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: BauhausColors.surface,
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'No campus conversations found',
                          style: BauhausTextStyles.bodyMedium(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredConversations.map(
                      (conv) => _buildConversationTile(conv),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(MatchConversation conv) {
    final peer = conv.peer;
    final lastMsg = conv.lastMessage;
    final hasUnread = conv.unreadCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: hasUnread ? BauhausColors.cardYellow : BauhausColors.surface,
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
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          leading: BauhausAvatar(
            imageUrl: peer.photos.isNotEmpty ? peer.photos.first : null,
            initial: peer.nickname[0],
            size: 48,
            isCircle: false,
            backgroundColor: BauhausColors.primaryBlue,
            borderWidth: 2.0,
            shadowOffset: 0,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  peer.name.toUpperCase(),
                  style: BauhausTextStyles.title().copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              BauhausBadge(
                label: peer.faculty.split(' ').first,
                variant: BauhausBadgeVariant.red,
                fontSize: 9,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              lastMsg != null
                  ? lastMsg.text
                  : 'Matched! Say hello to ${peer.nickname}.',
              style:
                  BauhausTextStyles.bodyMedium(
                    color: hasUnread
                        ? BauhausColors.foreground
                        : Colors.grey.shade700,
                  ).copyWith(
                    fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 12,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: hasUnread
              ? Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: BauhausColors.primaryRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: BauhausColors.border, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '${conv.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : const Icon(
                  Icons.chevron_right,
                  color: BauhausColors.foreground,
                  size: 20,
                ),
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.chat, arguments: conv.id);
          },
        ),
      ),
    );
  }
}
