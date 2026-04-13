import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'school_data.dart';
import '../../services/school_api_service.dart';

// ─────────────────────────────────────────────
//  NOTIFICATION MODEL
// ─────────────────────────────────────────────

enum NotifType { course, challenge, achievement, reminder, system }

class SchoolNotif {
  final String id;
  final NotifType type;
  final String emoji;
  final String title;
  final String body;
  final String timeAgo;
  bool isRead;

  SchoolNotif({
    required this.id,
    required this.type,
    required this.emoji,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
  });
}

// ─────────────────────────────────────────────
//  STATIC DATA
// ─────────────────────────────────────────────

final List<SchoolNotif> _kNotifs = [
  SchoolNotif(
    id: '1', type: NotifType.challenge,
    emoji: '🔥', title: 'Daily Challenge Unlocked!',
    body: 'Your Python quiz challenge is ready. Complete it to earn +50 XP today.',
    timeAgo: 'Just now', isRead: false,
  ),
  SchoolNotif(
    id: '2', type: NotifType.course,
    emoji: '🐍', title: 'Class Starting Soon',
    body: 'Python Basics class starts in 30 minutes. Get your notes ready!',
    timeAgo: '28 min ago', isRead: false,
  ),
  SchoolNotif(
    id: '3', type: NotifType.achievement,
    emoji: '🏆', title: 'New Achievement Unlocked!',
    body: 'You\'ve earned the "7-Day Streak" badge. Keep the momentum going!',
    timeAgo: '1 hr ago', isRead: false,
  ),
  SchoolNotif(
    id: '4', type: NotifType.course,
    emoji: '🤖', title: 'New Course Available',
    body: 'Intro to AI & ML is now open for enrollment. Early bird slots filling fast!',
    timeAgo: '3 hrs ago', isRead: true,
  ),
  SchoolNotif(
    id: '5', type: NotifType.reminder,
    emoji: '📅', title: 'Upcoming: Scratch Programming',
    body: 'Your Wednesday 3:00 PM Scratch Programming class is tomorrow. Don\'t miss it!',
    timeAgo: '5 hrs ago', isRead: true,
  ),
  SchoolNotif(
    id: '6', type: NotifType.achievement,
    emoji: '⭐', title: 'Level Up!',
    body: 'You\'ve reached Level 5! You now have access to Intermediate courses.',
    timeAgo: 'Yesterday', isRead: true,
  ),
  SchoolNotif(
    id: '7', type: NotifType.system,
    emoji: '🎉', title: 'Welcome to TechPath!',
    body: 'Your account is all set. Explore courses, earn XP, and start your coding journey!',
    timeAgo: '2 days ago', isRead: true,
  ),
  SchoolNotif(
    id: '8', type: NotifType.course,
    emoji: '🎮', title: 'Assignment Graded',
    body: 'Your Scratch game project has been graded. You scored 92/100. Great work!',
    timeAgo: '3 days ago', isRead: true,
  ),
];

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class SchoolNotificationsScreen extends StatefulWidget {
  const SchoolNotificationsScreen({super.key});

  @override
  State<SchoolNotificationsScreen> createState() =>
      _SchoolNotificationsScreenState();
}

class _SchoolNotificationsScreenState
    extends State<SchoolNotificationsScreen>
    with TickerProviderStateMixin {

  List<SchoolNotif> _notifs = [];
  bool _isLoading = true;
  late AnimationController _headerAnim;

  late List<AnimationController> _itemAnims;
  late List<Animation<double>>   _itemFade;
  late List<Animation<Offset>>   _itemSlide;

  @override
  void initState() {
    super.initState();
    _loadNotifs();

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _itemAnims = List.generate(
      _notifs.length,
          (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 420),
      ),
    );
    _itemFade  = _itemAnims.map((c) =>
        CurvedAnimation(parent: c, curve: Curves.easeOut)).toList();
    _itemSlide = _itemAnims.map((c) =>
        Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut))).toList();

    for (int i = 0; i < _notifs.length; i++) {
      Future.delayed(Duration(milliseconds: 80 + i * 60), () {
        if (mounted) _itemAnims[i].forward();
      });
    }
  }

  Future<void> _loadNotifs() async {
    final fetched = await SchoolApiService.instance.getNotifications();
    List<SchoolNotif> parsed = [];
    if (fetched.isNotEmpty) {
      for (var f in fetched) {
        if (f is Map<String, dynamic>) {
          parsed.add(SchoolNotif(
            id: f['notification_id']?.toString() ?? UniqueKey().toString(),
            type: _parseType(f['type']),
            emoji: '🔔', // fallback 
            title: f['title'] ?? 'Notification',
            body: f['message'] ?? '',
            timeAgo: 'Just now',
            isRead: f['is_read'] == 1 || f['is_read'] == true,
          ));
        }
      }
    } else {
      parsed = List.from(_kNotifs); // fallback to offline dummy data to preserve UI preview
    }
    
    if (mounted) {
      setState(() {
        _notifs = parsed;
        _isLoading = false;
        
        // Re-init animations
        _itemAnims = List.generate(
          _notifs.length,
          (_) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 420),
          ),
        );
        _itemFade = _itemAnims.map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut)).toList();
        _itemSlide = _itemAnims.map((c) => Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut))).toList();
            
        for (int i = 0; i < _notifs.length; i++) {
          Future.delayed(Duration(milliseconds: 80 + i * 60), () {
            if (mounted) _itemAnims[i].forward();
          });
        }
      });
    }
  }
  
  NotifType _parseType(dynamic type) {
    if (type == null) return NotifType.system;
    final t = type.toString().toLowerCase();
    if (t.contains('course')) return NotifType.course;
    if (t.contains('hackathon')) return NotifType.challenge;
    if (t.contains('job') || t.contains('internship')) return NotifType.achievement;
    return NotifType.system;
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    for (final c in _itemAnims) c.dispose();
    super.dispose();
  }

  int get _unreadCount => _notifs.where((n) => !n.isRead).length;

  void _markAllRead() {
    HapticFeedback.lightImpact();
    SchoolApiService.instance.markAllNotificationsRead();
    setState(() {
      for (final n in _notifs) n.isRead = true;
    });
  }

  void _markRead(String id) {
    SchoolApiService.instance.markNotificationRead(id);
    setState(() {
      final notif = _notifs.firstWhere((n) => n.id == id, orElse: () => _notifs.first);
      notif.isRead = true;
    });
  }

  // ── Type → accent colour ──────────────────

  Color _accentFor(NotifType t) {
    switch (t) {
      case NotifType.course:      return kPrimaryBlue;
      case NotifType.challenge:   return const Color(0xFFE65100);
      case NotifType.achievement: return const Color(0xFFFFB300);
      case NotifType.reminder:    return const Color(0xFF7B1FA2);
      case NotifType.system:      return const Color(0xFF2E7D32);
    }
  }

  Color _bgFor(NotifType t) {
    switch (t) {
      case NotifType.course:      return const Color(0xFFE8F1FE);
      case NotifType.challenge:   return const Color(0xFFFFF3E0);
      case NotifType.achievement: return const Color(0xFFFFFDE7);
      case NotifType.reminder:    return const Color(0xFFF3E5F5);
      case NotifType.system:      return const Color(0xFFE6F4EA);
    }
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Group into Today vs Earlier
    final today   = _notifs.where((n) =>
    n.timeAgo.contains('now') ||
        n.timeAgo.contains('min') ||
        n.timeAgo.contains('hr')).toList();
    final earlier = _notifs.where((n) =>
    n.timeAgo == 'Yesterday' ||
        n.timeAgo.contains('day')).toList();

    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(children: [
        _buildHeader(),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
            children: [
              if (today.isNotEmpty) ...[
                _sectionLabel('Today'),
                const SizedBox(height: 10),
                ...today.map((n) => _notifCard(n)),
                const SizedBox(height: 20),
              ],
              if (earlier.isNotEmpty) ...[
                _sectionLabel('Earlier'),
                const SizedBox(height: 10),
                ...earlier.map((n) => _notifCard(n)),
              ],
              if (_notifs.isEmpty)
                _emptyState(),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Header ─────────────────────────────────

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) => Opacity(
        opacity: _headerAnim.value,
        child: Transform.translate(
          offset: Offset(0, -8 * (1 - _headerAnim.value)),
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
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Row(children: [
              // Back button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (context.canPop()) context.pop();
                  else context.go('/school/layout');
                },
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: -0.3),
                    ),
                    if (_unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_unreadCount new',
                          style: const TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    _unreadCount > 0
                        ? '$_unreadCount unread notifications'
                        : 'All caught up!',
                    style: TextStyle(fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.72)),
                  ),
                ]),
              ),
              // Mark all read button
              if (_unreadCount > 0)
                GestureDetector(
                  onTap: _markAllRead,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Section label ──────────────────────────

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
            color: kTextMuted, letterSpacing: 0.4));
  }

  // ── Notification card ──────────────────────

  Widget _notifCard(SchoolNotif n) {
    final idx   = _notifs.indexOf(n);
    final accent = _accentFor(n.type);
    final bg     = _bgFor(n.type);

    return FadeTransition(
      opacity: idx < _itemFade.length ? _itemFade[idx] : const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(
        position: idx < _itemSlide.length ? _itemSlide[idx] : const AlwaysStoppedAnimation(Offset.zero),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _markRead(n.id);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: n.isRead ? kCardBg : const Color(0xFFF0F6FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: n.isRead ? kCardBorder : accent.withValues(alpha: 0.35),
                width: n.isRead ? 1.0 : 1.5,
              ),
              boxShadow: n.isRead
                  ? []
                  : [BoxShadow(
                  color: accent.withValues(alpha: 0.08),
                  blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Emoji icon
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(n.emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text(n.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: n.isRead ? FontWeight.w700 : FontWeight.w800,
                            color: kTextDark,
                          )),
                    ),
                    // Unread dot
                    if (!n.isRead)
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ]),
                  const SizedBox(height: 4),
                  Text(n.body,
                      style: const TextStyle(fontSize: 12,
                          color: kTextMuted, height: 1.45),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.access_time_rounded,
                        size: 11, color: kTextMuted.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(n.timeAgo,
                        style: TextStyle(fontSize: 11,
                            color: kTextMuted.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    // Type chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _labelFor(n.type),
                        style: TextStyle(fontSize: 10,
                            fontWeight: FontWeight.w800, color: accent),
                      ),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  String _labelFor(NotifType t) {
    switch (t) {
      case NotifType.course:      return 'Course';
      case NotifType.challenge:   return 'Challenge';
      case NotifType.achievement: return 'Achievement';
      case NotifType.reminder:    return 'Reminder';
      case NotifType.system:      return 'System';
    }
  }

  // ── Empty state ────────────────────────────

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(children: [
        const Text('🔔', style: TextStyle(fontSize: 52)),
        const SizedBox(height: 16),
        const Text("You're all caught up!",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                color: kTextDark)),
        const SizedBox(height: 8),
        Text('No new notifications right now.',
            style: TextStyle(fontSize: 13, color: kTextMuted)),
      ]),
    );
  }
}
