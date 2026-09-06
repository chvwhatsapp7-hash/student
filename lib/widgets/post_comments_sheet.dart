import 'package:flutter/material.dart';
import '../models/post_comment.dart';
import '../services/social_post_service.dart';

class PostCommentsSheet extends StatefulWidget {
  final String postType;
  final int postId;
  final String postTitle;
  final int initialCommentsCount;
  final Function(int newCount)? onCommentsCountChanged;

  const PostCommentsSheet({
    super.key,
    required this.postType,
    required this.postId,
    required this.postTitle,
    this.initialCommentsCount = 0,
    this.onCommentsCountChanged,
  });

  static void show(
    BuildContext context, {
    required String postType,
    required int postId,
    required String postTitle,
    int initialCommentsCount = 0,
    Function(int newCount)? onCommentsCountChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PostCommentsSheet(
        postType: postType,
        postId: postId,
        postTitle: postTitle,
        initialCommentsCount: initialCommentsCount,
        onCommentsCountChanged: onCommentsCountChanged,
      ),
    );
  }

  @override
  State<PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends State<PostCommentsSheet> {
  final TextEditingController _commentCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  List<PostComment> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  late int _commentsCount;

  @override
  void initState() {
    super.initState();
    _commentsCount = widget.initialCommentsCount;
    _fetchComments();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoading = true);
    final list = await SocialPostService.getComments(
      postType: widget.postType,
      postId: widget.postId,
    );
    if (mounted) {
      setState(() {
        _comments = list;
        _commentsCount = list.length;
        _isLoading = false;
      });
      widget.onCommentsCountChanged?.call(_commentsCount);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _commentCtrl.clear();

    final newComment = await SocialPostService.addComment(
      postType: widget.postType,
      postId: widget.postId,
      content: text,
    );

    if (mounted) {
      setState(() {
        _isSending = false;
        if (newComment != null) {
          _comments.add(newComment);
          _commentsCount = _comments.length;
        } else {
          // Local fallback comment so user sees instant feedback
          _comments.add(PostComment(
            id: DateTime.now().millisecondsSinceEpoch,
            userId: 'me',
            authorName: 'You',
            authorEmail: '',
            content: text,
            createdAt: DateTime.now(),
          ));
          _commentsCount = _comments.length;
        }
      });

      widget.onCommentsCountChanged?.call(_commentsCount);

      // Scroll to bottom smoothly
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Drag Handle ──
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // ── Sheet Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comments ($_commentsCount)',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        widget.postTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // ── Comments List ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF6366F1),
                    ),
                  )
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.question_answer_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No comments yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Be the first to ask questions or share thoughts!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        itemCount: _comments.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (ctx, i) {
                          final c = _comments[i];
                          return _buildCommentTile(c);
                        },
                      ),
          ),

          // ── Comment Input Box ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF6366F1),
                    child: const Text(
                      'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: TextField(
                        controller: _commentCtrl,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendComment(),
                        decoration: const InputDecoration(
                          hintText: 'Add a comment or question...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _sendComment,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        ),
                      ),
                      child: _isSending
                          ? const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.arrow_upward_rounded,
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

  Widget _buildCommentTile(PostComment comment) {
    final initials = comment.authorName.isNotEmpty
        ? comment.authorName.substring(0, 1).toUpperCase()
        : 'U';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: _getAvatarColor(comment.authorName),
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            comment.authorName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          comment.timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF374151),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}
