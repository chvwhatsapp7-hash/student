import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'post_comments_sheet.dart';
import 'post_share_sheet.dart';
import 'fullscreen_image_viewer.dart';
import '../services/social_post_service.dart';

class SocialPostCard extends StatefulWidget {
  final String postType; // 'job' or 'internship'
  final int id;
  final String title;
  final String company;
  final String location;
  final String? type;
  final String? primaryBadge; // e.g. "₹35,000/mo" or "₹12-18 LPA"
  final String? secondaryBadge; // e.g. "3 Months" or "0-2 Yrs Exp"
  final String? imageUrl;
  final String? companyLogo;
  final String description;
  final List<String> tags;
  final bool isSaved;
  final bool isApplied;
  final int initialLikesCount;
  final int initialCommentsCount;
  final int initialSharesCount;
  final bool initialIsLiked;
  final VoidCallback? onSave;
  final VoidCallback? onApply;
  final VoidCallback? onTap;

  const SocialPostCard({
    super.key,
    required this.postType,
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    this.type,
    this.primaryBadge,
    this.secondaryBadge,
    this.imageUrl,
    this.companyLogo,
    this.description = '',
    this.tags = const [],
    this.isSaved = false,
    this.isApplied = false,
    this.initialLikesCount = 0,
    this.initialCommentsCount = 0,
    this.initialSharesCount = 0,
    this.initialIsLiked = false,
    this.onSave,
    this.onApply,
    this.onTap,
  });

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likesCount;
  late int _commentsCount;
  late int _sharesCount;
  bool _isDescriptionExpanded = false;

  // Double-tap heart pop animation
  bool _showHeartAnimation = false;
  late AnimationController _heartAnimController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialIsLiked;
    _likesCount = widget.initialLikesCount;
    _commentsCount = widget.initialCommentsCount;
    _sharesCount = widget.initialSharesCount;

    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _heartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 40),
    ]).animate(_heartAnimController);

    _heartOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_heartAnimController);
  }

  @override
  void didUpdateWidget(covariant SocialPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLikesCount != widget.initialLikesCount) {
      _likesCount = widget.initialLikesCount;
    }
    if (oldWidget.initialIsLiked != widget.initialIsLiked) {
      _isLiked = widget.initialIsLiked;
    }
    if (oldWidget.initialCommentsCount != widget.initialCommentsCount) {
      _commentsCount = widget.initialCommentsCount;
    }
    if (oldWidget.initialSharesCount != widget.initialSharesCount) {
      _sharesCount = widget.initialSharesCount;
    }
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    super.dispose();
  }

  void _triggerLike({bool forceLikeOnly = false}) {
    HapticFeedback.lightImpact();

    if (forceLikeOnly && _isLiked) {
      // Already liked, just trigger heart pop
      _playHeartPop();
      return;
    }

    final willLike = forceLikeOnly ? true : !_isLiked;

    setState(() {
      _isLiked = willLike;
      _likesCount = willLike ? _likesCount + 1 : (_likesCount > 0 ? _likesCount - 1 : 0);
    });

    if (willLike) {
      _playHeartPop();
    }

    // Sync with backend API
    SocialPostService.toggleLike(
      postType: widget.postType,
      postId: widget.id,
    ).then((res) {
      if (mounted && res['likes_count'] != null) {
        setState(() {
          _isLiked = res['is_liked'] ?? willLike;
          _likesCount = res['likes_count'] ?? _likesCount;
        });
      }
    });
  }

  void _playHeartPop() {
    setState(() => _showHeartAnimation = true);
    _heartAnimController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _showHeartAnimation = false);
    });
  }

  void _openComments() {
    PostCommentsSheet.show(
      context,
      postType: widget.postType,
      postId: widget.id,
      postTitle: widget.title,
      initialCommentsCount: _commentsCount,
      onCommentsCountChanged: (newCount) {
        if (mounted) setState(() => _commentsCount = newCount);
      },
    );
  }

  void _openShare() {
    PostShareSheet.show(
      context,
      postType: widget.postType,
      postId: widget.id,
      title: widget.title,
      company: widget.company,
      onShareRecorded: (newCount) {
        if (mounted) setState(() => _sharesCount = newCount);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isJob = widget.postType.toLowerCase() == 'job';
    final primaryColor = isJob ? const Color(0xFF2563EB) : const Color(0xFF7C3AED);
    final accentColor = isJob ? const Color(0xFF38BDF8) : const Color(0xFFC084FC);
    final String heroTag = '${widget.postType}_image_${widget.id}';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isApplied
              ? primaryColor.withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
          width: widget.isApplied ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Applied Stripe Indicator ──
            if (widget.isApplied)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, accentColor],
                  ),
                ),
              ),

            // ── 1. Post Header (Company, Title, Time, Bookmark) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildCompanyAvatar(primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: widget.onTap,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.company,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified,
                                size: 15,
                                color: primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  widget.location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                ' • ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Text(
                                isJob ? '💼 Job' : '🎓 Internship',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bookmark Button
                  IconButton(
                    onPressed: widget.onSave,
                    icon: Icon(
                      widget.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: widget.isSaved ? primaryColor : Colors.grey.shade400,
                      size: 24,
                    ),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // ── 2. Post Title & Highlights ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: widget.onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Badges (Stipend/Salary, Duration/Exp, Type)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (widget.primaryBadge != null &&
                            widget.primaryBadge!.isNotEmpty)
                          _buildPill(
                            icon: Icons.payments_outlined,
                            label: widget.primaryBadge!,
                            bgColor: const Color(0xFFECFDF5),
                            textColor: const Color(0xFF047857),
                            borderColor: const Color(0xFFA7F3D0),
                          ),
                        if (widget.secondaryBadge != null &&
                            widget.secondaryBadge!.isNotEmpty)
                          _buildPill(
                            icon: Icons.schedule_outlined,
                            label: widget.secondaryBadge!,
                            bgColor: const Color(0xFFEFF6FF),
                            textColor: const Color(0xFF1D4ED8),
                            borderColor: const Color(0xFFBFDBFE),
                          ),
                        if (widget.type != null && widget.type!.isNotEmpty)
                          _buildPill(
                            icon: Icons.work_outline_rounded,
                            label: widget.type!,
                            bgColor: const Color(0xFFF3F4F6),
                            textColor: const Color(0xFF374151),
                            borderColor: const Color(0xFFE5E7EB),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── 3. Post Hero Media Image (With Double-Tap Heart) ──
            GestureDetector(
              onDoubleTap: () => _triggerLike(forceLikeOnly: true),
              onTap: () {
                if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
                  FullscreenImageViewer.open(
                    context,
                    imageUrl: widget.imageUrl!,
                    heroTag: heroTag,
                    title: widget.title,
                  );
                } else {
                  widget.onTap?.call();
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      minHeight: 180,
                      maxHeight: 240,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                    ),
                    child: widget.imageUrl != null &&
                            widget.imageUrl!.isNotEmpty
                        ? Hero(
                            tag: heroTag,
                            child: Image.network(
                              widget.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 200,
                                  color: const Color(0xFFF1F5F9),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (ctx, err, stack) =>
                                  _buildDefaultBanner(primaryColor, isJob),
                            ),
                          )
                        : _buildDefaultBanner(primaryColor, isJob),
                  ),

                  // Double-Tap Animated Floating Heart
                  if (_showHeartAnimation)
                    AnimatedBuilder(
                      animation: _heartAnimController,
                      builder: (ctx, child) {
                        return Opacity(
                          opacity: _heartOpacityAnimation.value,
                          child: Transform.scale(
                            scale: _heartScaleAnimation.value,
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFFEF4444),
                              size: 90,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 18,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            // ── 4. Post Description Snippet ──
            if (widget.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.description,
                      maxLines: _isDescriptionExpanded ? 10 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                    if (widget.description.length > 90)
                      GestureDetector(
                        onTap: () => setState(() =>
                            _isDescriptionExpanded = !_isDescriptionExpanded),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _isDescriptionExpanded ? 'show less' : '...more',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // ── 5. Tags / Skills ──
            if (widget.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: widget.tags.take(4).map((tag) {
                    return Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor.withValues(alpha: 0.9),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // ── 6. Social Action Bar (Like, Comment, Share & Apply) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Action buttons group (Like, Comment, Share)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Like Button
                        _buildActionButton(
                          icon: _isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          label: '$_likesCount',
                          color: _isLiked
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF475569),
                          onTap: () => _triggerLike(),
                        ),
                        const SizedBox(width: 2),

                        // Comment Button
                        _buildActionButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: '$_commentsCount',
                          color: const Color(0xFF475569),
                          onTap: _openComments,
                        ),
                        const SizedBox(width: 2),

                        // Share Button
                        _buildActionButton(
                          icon: Icons.share_outlined,
                          label: '$_sharesCount',
                          color: const Color(0xFF475569),
                          onTap: _openShare,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Apply / Details CTA Button
                  ElevatedButton(
                    onPressed: widget.onApply ?? widget.onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.isApplied ? const Color(0xFF10B981) : primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isApplied
                              ? Icons.check_circle_rounded
                              : Icons.send_rounded,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.isApplied ? 'Applied' : 'Apply Now',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyAvatar(Color primaryColor) {
    final initial = widget.company.isNotEmpty
        ? widget.company.substring(0, 1).toUpperCase()
        : 'C';

    if (widget.companyLogo != null && widget.companyLogo!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.companyLogo!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(initial, primaryColor),
        ),
      );
    }
    return _buildAvatarFallback(initial, primaryColor);
  }

  Widget _buildAvatarFallback(String initial, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 3.5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultBanner(Color primaryColor, bool isJob) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.85),
            primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              isJob ? Icons.work_rounded : Icons.school_rounded,
              size: 140,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isJob ? '🔥 HOT JOB OPENING' : '🚀 INTERNSHIP SPOTLIGHT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'at ${widget.company}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
