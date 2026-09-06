import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'school_data.dart';
import '../../services/school_api_service.dart';

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────

enum NotifType { course, achievement, reminder, system }

enum NotifCategory { all, public, personal }

class SchoolNotif {
  final String id;
  final NotifType type;
  final NotifCategory category;
  final String title;
  final String body;
  final String timeAgo;
  final String? redirectTo;
  bool isRead;

  SchoolNotif({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.redirectTo,
    this.isRead = false,
  });
}

// ─────────────────────────────────────────────
//  PURE HELPERS
// ─────────────────────────────────────────────

String _emojiFor(NotifType t) {
  switch (t) {
    case NotifType.course:      return '📚';
    case NotifType.achievement: return '🏆';
    case NotifType.reminder:    return '📅';
    case NotifType.system:      return '🔔';
  }
}

String _labelFor(NotifType t) {
  switch (t) {
    case NotifType.course:      return 'Course';
    case NotifType.achievement: return 'Achievement';
    case NotifType.reminder:    return 'Reminder';
    case NotifType.system:      return 'System';
  }
}

Color _accentFor(NotifType t) {
  switch (t) {
    case NotifType.course:      return kPrimaryBlue;
    case NotifType.achievement: return const Color(0xFFFFB300);
    case NotifType.reminder:    return const Color(0xFF7B1FA2);
    case NotifType.system:      return const Color(0xFF2E7D32);
  }
}

Color _bgFor(NotifType t) {
  switch (t) {
    case NotifType.course:      return const Color(0xFFE8F1FE);
    case NotifType.achievement: return const Color(0xFFFFFDE7);
    case NotifType.reminder:    return const Color(0xFFF3E5F5);
    case NotifType.system:      return const Color(0xFFE6F4EA);
  }
}

NotifType _parseType(dynamic raw) {
  if (raw == null) return NotifType.system;
  final t = raw.toString().toLowerCase();
  if (t.contains('course') || t.contains('enroll') || t.contains('save')) return NotifType.course;
  if (t.contains('achieve') || t.contains('badge') || t.contains('level')) return NotifType.achievement;
  if (t.contains('remind') || t.contains('class') || t.contains('schedule')) return NotifType.reminder;
  return NotifType.system;
}

NotifCategory _parseCat(dynamic raw) {
  if (raw == null) return NotifCategory.public;
  return raw.toString().toLowerCase() == 'personal'
      ? NotifCategory.personal
      : NotifCategory.public;
}

String _parseTimeAgo(dynamic raw) {
  if (raw == null) return 'Just now';
  final dt = DateTime.tryParse(raw.toString());
  if (dt == null) return raw.toString();
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1)  return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24)   return '${diff.inHours} hr ago';
  if (diff.inDays == 1)    return 'Yesterday';
  return '${diff.inDays} days ago';
}

String? _parseRedirect(dynamic raw) {
  if (raw == null) return null;
  final r = raw.toString().toLowerCase();
  if (r.contains('course'))                   return '/school/courses';
  if (r.contains('achieve') || r.contains('profile')) return '/school/profile';
  return null;
}

bool _isToday(SchoolNotif n) =>
    n.timeAgo.contains('now') ||
        n.timeAgo.contains('min') ||
        n.timeAgo.contains('hr');

bool _isYesterday(SchoolNotif n) => n.timeAgo == 'Yesterday';

bool _isOlder(SchoolNotif n) => !_isToday(n) && !_isYesterday(n);

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class SchoolNotificationsScreen extends StatefulWidget {
  const SchoolNotificationsScreen({super.key});

  @override
  State<SchoolNotificationsScreen> createState() =>
      _SchoolNotificationsScreenState();
}

class _SchoolNotificationsScreenState extends State<SchoolNotificationsScreen>
    with TickerProviderStateMixin {

  // ── Data ───────────────────────────────────
  List<SchoolNotif> _all = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  NotifCategory _filter = NotifCategory.all;

  // ── Animations ─────────────────────────────
  late AnimationController _headerAnim;
  late AnimationController _tabsAnim;
  List<AnimationController> _itemCtls = [];
  List<Animation<double>>   _itemFade = [];
  List<Animation<Offset>>   _itemSlide = [];

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    )..forward();

    _tabsAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 450),
    );

    // Slight delay so header animates in first, then tabs reveal
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _tabsAnim.forward();
    });

    _loadNotifs();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _tabsAnim.dispose();
    for (final c in _itemCtls) c.dispose();
    super.dispose();
  }

  // ── Load ───────────────────────────────────

  Future<void> _loadNotifs({bool refresh = false}) async {
    if (refresh) setState(() => _isRefreshing = true);

    try {
      List<dynamic> raw;
      if (_filter == NotifCategory.all) {
        raw = await SchoolApiService.instance.getNotifications();
      } else {
        raw = await SchoolApiService.instance
            .getNotificationsByCategory(_filter.name); // 'public' or 'personal'
      }

      final parsed = raw.whereType<Map<String, dynamic>>().map((f) {
        return SchoolNotif(
          id:         f['notification_id']?.toString() ?? UniqueKey().toString(),
          type:       _parseType(f['type']),
          category:   _parseCat(f['category']),
          title:      f['title'] ?? 'Notification',
          body:       f['message'] ?? '',
          timeAgo:    _parseTimeAgo(f['created_at']),
          redirectTo: _parseRedirect(f['redirect']),
          isRead:     f['is_read'] == 1 || f['is_read'] == true,
        );
      }).toList();

      final notifs = parsed;

      if (mounted) {
        setState(() {
          _all = notifs;
          _isLoading = false;
          _isRefreshing = false;
        });
        _animateItems(_visible);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _all = [];
          _isLoading = false;
          _isRefreshing = false;
        });
        _animateItems(_visible);
      }
    }
  }

  void _animateItems(List<SchoolNotif> items) {
    for (final c in _itemCtls) c.dispose();
    _itemCtls = List.generate(
      items.length,
          (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 400)),
    );
    _itemFade = _itemCtls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _itemSlide = _itemCtls
        .map((c) => Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    for (int i = 0; i < items.length; i++) {
      Future.delayed(Duration(milliseconds: 60 + i * 55), () {
        if (mounted) _itemCtls[i].forward();
      });
    }
  }

  // ── Computed ───────────────────────────────

  List<SchoolNotif> get _visible {
    if (_filter == NotifCategory.all) return _all;
    return _all.where((n) => n.category == _filter).toList();
  }

  int get _totalUnread => _all.where((n) => !n.isRead).length;

  int _unreadFor(NotifCategory cat) {
    if (cat == NotifCategory.all) return _totalUnread;
    return _all.where((n) => n.category == cat && !n.isRead).length;
  }

  // ── Actions ────────────────────────────────

  void _switchFilter(NotifCategory cat) {
    if (_filter == cat) return;
    HapticFeedback.selectionClick();
    setState(() {
      _filter = cat;
      _isLoading = true;
    });
    _loadNotifs();
  }

  void _markAllRead() {
    HapticFeedback.lightImpact();
    SchoolApiService.instance.markAllNotificationsRead();
    setState(() {
      for (final n in _all) n.isRead = true;
    });
  }

  void _onTap(SchoolNotif n) {
    HapticFeedback.selectionClick();
    if (!n.isRead) {
      SchoolApiService.instance.markNotificationRead(n.id);
      setState(() => n.isRead = true);
    }
    if (n.redirectTo != null && n.redirectTo!.isNotEmpty) {
      context.push(n.redirectTo!);
    }
  }

  // ─────────────────────────────────────────
  //  ROOT BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(children: [
        _buildHeader(),
        _buildFilterRow(),
        Expanded(
          child: _isLoading
              ? _buildShimmer()
              : RefreshIndicator(
            color: kPrimaryBlue,
            backgroundColor: Colors.white,
            onRefresh: () => _loadNotifs(refresh: true),
            child: _buildFeed(),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) => Opacity(
        opacity: _headerAnim.value,
        child: Transform.translate(
          offset: Offset(0, -10 * (1 - _headerAnim.value)),
          child: child,
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryBlue, kDeepBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
            child: Row(children: [
              // ── Back ──────────────────────
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (context.canPop()) context.pop();
                  else context.go('/school/layout');
                },
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 13, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),

              // ── Title + subtitle ──────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: -0.3,
                        ),
                      ),
                      if (_totalUnread > 0) ...[
                        const SizedBox(width: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_totalUnread new',
                            style: const TextStyle(
                              fontSize: 9.5, fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ]),
                    Text(
                      _isRefreshing
                          ? 'Refreshing…'
                          : _totalUnread > 0
                          ? '$_totalUnread unread'
                          : 'All caught up!',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Mark all read ─────────────
              if (_totalUnread > 0)
                GestureDetector(
                  onTap: _markAllRead,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 9.5, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  FILTER CHIPS ROW
  // ─────────────────────────────────────────

  Widget _buildFilterRow() {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _tabsAnim, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
            .animate(CurvedAnimation(parent: _tabsAnim, curve: Curves.easeOut)),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: Row(children: [
            _chip('All',      NotifCategory.all,      Icons.notifications_rounded),
            const SizedBox(width: 8),
            _chip('Public',   NotifCategory.public,   Icons.campaign_rounded),
            const SizedBox(width: 8),
            _chip('Personal', NotifCategory.personal, Icons.person_rounded),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String label, NotifCategory cat, IconData icon) {
    final active = _filter == cat;
    final count  = _unreadFor(cat);

    return GestureDetector(
      onTap: () => _switchFilter(cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? kPrimaryBlue : kBgPage,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? kPrimaryBlue : kCardBorder,
            width: 1.2,
          ),
          boxShadow: active
              ? [BoxShadow(
              color: kPrimaryBlue.withValues(alpha: 0.28),
              blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: active ? Colors.white : kTextMuted),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: active ? Colors.white : kTextMuted,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withValues(alpha: 0.28)
                    : kPrimaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w800,
                  color: active ? Colors.white : kPrimaryBlue,
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  FEED
  // ─────────────────────────────────────────

  Widget _buildFeed() {
    final items = _visible;
    if (items.isEmpty) return _buildEmpty();

    final today     = items.where(_isToday).toList();
    final yesterday = items.where(_isYesterday).toList();
    final older     = items.where(_isOlder).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        if (today.isNotEmpty) ...[
          _section('Today'),
          ...today.map(_card),
        ],
        if (yesterday.isNotEmpty) ...[
          if (today.isNotEmpty) const SizedBox(height: 6),
          _section('Yesterday'),
          ...yesterday.map(_card),
        ],
        if (older.isNotEmpty) ...[
          if (today.isNotEmpty || yesterday.isNotEmpty) const SizedBox(height: 6),
          _section('Earlier'),
          ...older.map(_card),
        ],
      ],
    );
  }

  // ── Section label ──────────────────────────

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10, top: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5, fontWeight: FontWeight.w800,
          color: kTextMuted, letterSpacing: 1.0,
        ),
      ),
    );
  }

  // ── Notification card ──────────────────────

  Widget _card(SchoolNotif n) {
    final items  = _visible;
    final idx    = items.indexOf(n);
    final accent = _accentFor(n.type);
    final bg     = _bgFor(n.type);
    final hasAnim = idx >= 0 && idx < _itemFade.length;

    final inner = GestureDetector(
      onTap: () => _onTap(n),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: n.isRead ? kCardBg : const Color(0xFFF0F6FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: n.isRead ? kCardBorder : accent.withValues(alpha: 0.35),
            width: n.isRead ? 1.0 : 1.5,
          ),
          boxShadow: n.isRead
              ? [BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6, offset: const Offset(0, 2))]
              : [BoxShadow(
              color: accent.withValues(alpha: 0.10),
              blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onTap(n),
            borderRadius: BorderRadius.circular(18),
            splashColor: accent.withValues(alpha: 0.08),
            highlightColor: accent.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Icon bubble ─────────────
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(_emojiFor(n.type),
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── Content ─────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(
                              n.title,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: n.isRead
                                    ? FontWeight.w700
                                    : FontWeight.w800,
                                color: kTextDark,
                              ),
                            ),
                          ),
                          if (!n.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ]),
                        const SizedBox(height: 4),
                        Text(
                          n.body,
                          style: const TextStyle(
                            fontSize: 12, color: kTextMuted, height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),

                        // ── Meta row ────────────
                        Row(children: [
                          Icon(Icons.access_time_rounded,
                              size: 11,
                              color: kTextMuted.withValues(alpha: 0.65)),
                          const SizedBox(width: 3),
                          Text(
                            n.timeAgo,
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: kTextMuted.withValues(alpha: 0.65),
                            ),
                          ),
                          const Spacer(),

                          // Category badge
                          _metaBadge(
                            n.category == NotifCategory.personal
                                ? 'Personal' : 'Public',
                            n.category == NotifCategory.personal
                                ? kPrimaryBlue
                                : const Color(0xFF2E7D32),
                            n.category == NotifCategory.personal
                                ? const Color(0xFFE8F1FE)
                                : const Color(0xFFE6F4EA),
                          ),
                          const SizedBox(width: 5),

                          // Type chip
                          _metaBadge(_labelFor(n.type), accent, bg),

                          // Arrow if navigable
                          if (n.redirectTo != null) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: kTextMuted.withValues(alpha: 0.45)),
                          ],
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!hasAnim) return inner;
    return FadeTransition(
      opacity: _itemFade[idx],
      child: SlideTransition(position: _itemSlide[idx], child: inner),
    );
  }

  Widget _metaBadge(String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5, fontWeight: FontWeight.w800, color: color,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SHIMMER  (loading skeleton)
  // ─────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      itemCount: 5,
      itemBuilder: (_, i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: 1.0),
          duration: Duration(milliseconds: 800 + i * 120),
          curve: Curves.easeInOut,
          builder: (_, v, __) => Opacity(
            opacity: v,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kCardBorder),
              ),
              child: Row(children: [
                _sBox(48, 48, 14),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sBox(double.infinity, 13, 6),
                      const SizedBox(height: 8),
                      _sBox(220, 11, 6),
                      const SizedBox(height: 4),
                      _sBox(160, 11, 6),
                      const SizedBox(height: 10),
                      _sBox(80, 10, 6),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _sBox(double w, double h, double r) => Container(
    width: w, height: h,
    margin: const EdgeInsets.only(bottom: 2),
    decoration: BoxDecoration(
      color: kCardBorder.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(r),
    ),
  );

  // ─────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────

  Widget _buildEmpty() {
    final Map<NotifCategory, (String, String, String)> msgs = {
      NotifCategory.all: ('🔔', 'No notifications yet',
      'Your activity and platform updates will appear here.'),
      NotifCategory.public: ('📢', 'No public announcements',
      'New courses and platform news will show up here.'),
      NotifCategory.personal: ('🎯', 'No personal activity yet',
      'Enroll in a course or earn a badge to see updates here.'),
    };
    final m = msgs[_filter]!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Column(children: [
          Container(
            width: 84, height: 84,
            decoration: BoxDecoration(
              color: kBgPage, shape: BoxShape.circle,
              border: Border.all(color: kCardBorder, width: 2),
            ),
            child: Center(
              child: Text(m.$1, style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 18),
          Text(m.$2,
              style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800, color: kTextDark,
              )),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(m.$3,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13, color: kTextMuted, height: 1.55,
                )),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _loadNotifs(refresh: true),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              decoration: BoxDecoration(
                color: kPrimaryBlue,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryBlue.withValues(alpha: 0.30),
                    blurRadius: 12, offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text('Refresh',
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
            ),
          ),
        ]),
      ],
    );
  }
}
