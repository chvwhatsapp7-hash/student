import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/notification_model.dart';
import '../../api_services/authservice.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kInk        = Color(0xFF0F172A);
const kSlate      = Color(0xFF334155);
const kMuted      = Color(0xFF64748B);
const kHint       = Color(0xFF94A3B8);
const kBgPage     = Color(0xFFF0F4F8);
const kCardBg     = Color(0xFFFFFFFF);
const kBorder     = Color(0xFFE2E8F0);
const kPrimary    = Color(0xFF1D4ED8);
const kAccent     = Color(0xFF38BDF8);
const kSuccess    = Color(0xFF16A34A);
const kWarning    = Color(0xFFF59E0B);
const kSelectedBg = Color(0xFFEFF6FF);

// ─────────────────────────────────────────────
//  NOTIFICATION TYPES  (maps to backend 'type')
// ─────────────────────────────────────────────

enum NotifType {
  course,
  internship,
  job,
  company,
  hackathon,
  achievement,
  application,
  enrollment,
  saved,
  general,
}

NotifType _parseType(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'course':           return NotifType.course;
    case 'internship':       return NotifType.internship;
    case 'job':              return NotifType.job;
    case 'company':          return NotifType.company;
    case 'hackathon':        return NotifType.hackathon;
    case 'achievement':      return NotifType.achievement;
    case 'application':      return NotifType.application;
    case 'enrollment':       return NotifType.enrollment;
    case 'saved':            return NotifType.saved;
    default:                 return NotifType.general;
  }
}

// ─────────────────────────────────────────────
//  NOTIFICATION THEME HELPER
// ─────────────────────────────────────────────

class _NTheme {
  final IconData icon;
  final Color    grad1, grad2, bg;
  const _NTheme(this.icon, this.grad1, this.grad2, this.bg);
}

_NTheme _themeForType(NotifType type) {
  switch (type) {
    case NotifType.course:
      return const _NTheme(Icons.menu_book_rounded,
          Color(0xFF7C3AED), Color(0xFF6366F1), Color(0xFFF5F3FF));
    case NotifType.internship:
      return const _NTheme(Icons.work_outline_rounded,
          Color(0xFF0D9488), Color(0xFF0891B2), Color(0xFFEFFCF9));
    case NotifType.job:
      return const _NTheme(Icons.business_center_rounded,
          Color(0xFF1D4ED8), Color(0xFF4F46E5), Color(0xFFEFF6FF));
    case NotifType.company:
      return const _NTheme(Icons.apartment_rounded,
          Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFFFFBEB));
    case NotifType.hackathon:
      return const _NTheme(Icons.emoji_events_rounded,
          Color(0xFFDC2626), Color(0xFFB91C1C), Color(0xFFFFF1F2));
    case NotifType.achievement:
      return const _NTheme(Icons.military_tech_rounded,
          Color(0xFFB45309), Color(0xFFD97706), Color(0xFFFFFBEB));
    case NotifType.application:
      return const _NTheme(Icons.send_rounded,
          Color(0xFF059669), Color(0xFF16A34A), Color(0xFFF0FDF4));
    case NotifType.enrollment:
      return const _NTheme(Icons.school_rounded,
          Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFFF0F9FF));
    case NotifType.saved:
      return const _NTheme(Icons.bookmark_rounded,
          Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFFF5F3FF));
    case NotifType.general:
      return const _NTheme(Icons.notifications_rounded,
          Color(0xFF1D4ED8), Color(0xFF4F46E5), Color(0xFFEFF6FF));
  }
}

// ─────────────────────────────────────────────
//  FILTER TABS
// ─────────────────────────────────────────────

enum _FilterTab { all, publicN, personal }

// ─────────────────────────────────────────────
//  NOTIFICATION PAGE
// ─────────────────────────────────────────────

class NotificationPage extends StatefulWidget {
  final List<AppNotification>? notifications;
  const NotificationPage({super.key, this.notifications});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _headerAnim;
  final Set<String> _read = {};

  List<AppNotification> _all      = [];
  List<AppNotification> _filtered = [];
  bool        _isLoading   = true;
  bool        _isRefreshing = false;
  _FilterTab  _activeTab   = _FilterTab.all;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();
    _loadNotifs();
  }

  // ─────────────────────────────────────────────
  //  DATA LOADING
  // ─────────────────────────────────────────────

  Future<void> _loadNotifs({bool refresh = false}) async {
    if (refresh) setState(() => _isRefreshing = true);

    try {
      final res = await AuthService().get('/getNotifications');
      if (res.statusCode == 200) {
        final raw = res.data;
        final List data = raw is List
            ? raw
            : (raw['data'] ?? raw['notifications'] ?? []);

        final parsed = data.map<AppNotification>((f) {
          final id     = f['notification_id']?.toString() ?? UniqueKey().toString();
          final isRead = f['is_read'] == 1 || f['is_read'] == true;
          if (isRead) _read.add(id);
          return AppNotification(
            id:         id,
            title:      f['title']       ?? 'Notification',
            body:       f['message']     ?? '',
            time:       DateTime.tryParse(f['created_at'].toString()) ?? DateTime.now(),
            isRead:     isRead,
            type:       f['type']?.toString(),
            category:   f['category']?.toString(),
            redirectTo: f['redirect_to']?.toString(),
          );
        }).toList();

        if (mounted) {
          setState(() {
            _all         = parsed;
            _isLoading   = false;
            _isRefreshing = false;
          });
          _applyFilter(_activeTab);
        }
        return;
      }
    } catch (_) {}


    // API failed — show empty state
    if (mounted) {
      setState(() {
        _all          = [];
        _isLoading    = false;
        _isRefreshing = false;
      });
      _applyFilter(_activeTab);
    }
  }

  void _applyFilter(_FilterTab tab) {
    setState(() {
      _activeTab = tab;
      switch (tab) {
        case _FilterTab.all:
          _filtered = List.from(_all);
          break;
        case _FilterTab.publicN:
          _filtered = _all.where((n) =>
          (n.category ?? '').toLowerCase() == 'public').toList();
          break;
        case _FilterTab.personal:
          _filtered = _all.where((n) =>
          (n.category ?? '').toLowerCase() == 'personal').toList();
          break;
      }
    });
  }

  // ─────────────────────────────────────────────
  //  READ MANAGEMENT
  // ─────────────────────────────────────────────

  void _markAllRead() {
    HapticFeedback.lightImpact();
    AuthService().put('/notifications/read-all', {});
    setState(() {
      for (final n in _all) {
        if (n.id != null) _read.add(n.id!);
      }
    });
  }

  void _markRead(String id) {
    if (_read.contains(id)) return;
    HapticFeedback.selectionClick();
    AuthService().put('/notifications', {'notification_id': id});
    setState(() => _read.add(id));
  }

  // ─────────────────────────────────────────────
  //  NAVIGATION
  // ─────────────────────────────────────────────

  void _navigate(AppNotification n) {
    if (n.id != null) _markRead(n.id!);

    final dest = (n.redirectTo ?? '').toLowerCase();
    if (dest.isEmpty) return;

    // Map redirect destination to named routes or push accordingly.
    // Adjust route names to match your app's router configuration.
    final routeMap = {
      'jobs':         '/jobs',
      'internships':  '/internships',
      'companies':    '/companies',
      'hackathons':   '/hackathons',
      'courses':      '/courses',
      'achievements': '/achievements',
      'applications': '/applications',
      'enrollments':  '/enrollments',
    };

    final route = routeMap[dest];
    if (route != null && mounted) {
      Navigator.pushNamed(context, route);
    }
  }

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────

  int get _unreadCount {
    return _all.where((n) => n.id == null || !_read.contains(n.id)).length;
  }

  int get _filteredUnread {
    return _filtered.where((n) => n.id == null || !_read.contains(n.id)).length;
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          _buildHeader(sw),
          _buildFilterTabs(sw),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : RefreshIndicator(
              color: kPrimary,
              onRefresh: () => _loadNotifs(refresh: true),
              child: _filtered.isEmpty
                  ? _buildEmpty(sw)
                  : _buildList(sw, _filtered),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────

  Widget _buildHeader(double sw) {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) => Opacity(opacity: _headerAnim.value, child: child),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 15),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('🔔',
                            style: TextStyle(fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Notifications',
                                  style: TextStyle(
                                    fontSize: sw * 0.047,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.4,
                                  )),
                              if (_unreadCount > 0) ...[
                                SizedBox(width: sw * 0.015),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: sw * 0.018,
                                      vertical: sw * 0.005),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('$_unreadCount',
                                      style: TextStyle(
                                        fontSize: sw * 0.024,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      )),
                                ),
                              ],
                            ],
                          ),
                          Text('Your career activity feed',
                              style: TextStyle(
                                fontSize: sw * 0.028,
                                color: Colors.white.withOpacity(0.50),
                              )),
                        ],
                      ),
                    ),
                    if (_unreadCount > 0)
                      GestureDetector(
                        onTap: _markAllRead,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.028,
                              vertical: sw * 0.015),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.20)),
                          ),
                          child: Text('Mark all read',
                              style: TextStyle(
                                fontSize: sw * 0.025,
                                fontWeight: FontWeight.w700,
                                color: kAccent,
                              )),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: sw * 0.030),

                // Stat pills
                Wrap(
                  spacing: sw * 0.018,
                  runSpacing: sw * 0.013,
                  children: [
                    _statPill(Icons.notifications_rounded,
                        '${_all.length}', 'Total', sw),
                    _statPill(Icons.mark_email_unread_rounded,
                        '$_unreadCount', 'Unread', sw,
                        numColor: _unreadCount > 0 ? const Color(0xFFFCA5A5) : kHint),
                    _statPill(Icons.campaign_rounded,
                        '${_all.where((n) => (n.category ?? '').toLowerCase() == 'public').length}',
                        'Public', sw, numColor: kAccent),
                    _statPill(Icons.person_rounded,
                        '${_all.where((n) => (n.category ?? '').toLowerCase() == 'personal').length}',
                        'Personal', sw, numColor: const Color(0xFF86EFAC)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statPill(
      IconData icon, String num, String label, double sw,
      {Color numColor = kAccent}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.030, vertical: sw * 0.012),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: sw * 0.028, color: numColor),
          SizedBox(width: sw * 0.010),
          Text(num,
              style: TextStyle(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w800,
                  color: numColor)),
          SizedBox(width: sw * 0.008),
          Text(label,
              style: TextStyle(
                fontSize: sw * 0.024,
                color: Colors.white.withOpacity(0.50),
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FILTER TABS
  // ─────────────────────────────────────────────

  Widget _buildFilterTabs(double sw) {
    final tabs = [
      (_FilterTab.all,      'All',      Icons.apps_rounded),
      (_FilterTab.publicN,  'Public',   Icons.campaign_rounded),
      (_FilterTab.personal, 'Personal', Icons.person_rounded),
    ];

    return Container(
      color: kInk,
      padding: EdgeInsets.fromLTRB(
          sw * 0.040, 0, sw * 0.040, sw * 0.028),
      child: Row(
        children: tabs.map((t) {
          final isActive = _activeTab == t.$1;

          // Count for badge
          int count = 0;
          if (t.$1 == _FilterTab.all)      count = _all.length;
          if (t.$1 == _FilterTab.publicN)  count = _all.where((n) => (n.category ?? '').toLowerCase() == 'public').length;
          if (t.$1 == _FilterTab.personal) count = _all.where((n) => (n.category ?? '').toLowerCase() == 'personal').length;

          return Expanded(
            child: GestureDetector(
              onTap: () => _applyFilter(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.only(
                    right: t.$1 != _FilterTab.personal ? sw * 0.020 : 0),
                padding: EdgeInsets.symmetric(vertical: sw * 0.022),
                decoration: BoxDecoration(
                  color: isActive ? kPrimary : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive ? kPrimary : Colors.white.withOpacity(0.12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(t.$3,
                        size: sw * 0.030,
                        color: isActive ? Colors.white : Colors.white.withOpacity(0.50)),
                    SizedBox(width: sw * 0.010),
                    Text(t.$2,
                        style: TextStyle(
                          fontSize: sw * 0.028,
                          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                          color: isActive ? Colors.white : Colors.white.withOpacity(0.50),
                        )),
                    if (count > 0) ...[
                      SizedBox(width: sw * 0.010),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.013, vertical: sw * 0.003),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withOpacity(0.25)
                              : Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('$count',
                            style: TextStyle(
                              fontSize: sw * 0.022,
                              fontWeight: FontWeight.w800,
                              color: isActive ? Colors.white : Colors.white.withOpacity(0.60),
                            )),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────────

  Widget _buildEmpty(double sw) {
    return ListView(
      children: [
        SizedBox(height: sw * 0.20),
        Center(
          child: Column(
            children: [
              Container(
                width: sw * 0.22, height: sw * 0.22,
                decoration: const BoxDecoration(
                    color: kSelectedBg, shape: BoxShape.circle),
                child: Icon(Icons.notifications_off_rounded,
                    color: kPrimary, size: sw * 0.10),
              ),
              SizedBox(height: sw * 0.040),
              Text(
                _activeTab == _FilterTab.all
                    ? 'All caught up!'
                    : _activeTab == _FilterTab.publicN
                    ? 'No public notifications'
                    : 'No personal notifications',
                style: TextStyle(
                  fontSize: sw * 0.045,
                  fontWeight: FontWeight.w800,
                  color: kSlate,
                ),
              ),
              SizedBox(height: sw * 0.015),
              Text(
                'Pull down to refresh\nor check back later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: sw * 0.033, color: kMuted, height: 1.55),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  NOTIFICATION LIST
  // ─────────────────────────────────────────────

  Widget _buildList(double sw, List<AppNotification> list) {
    final now     = DateTime.now();
    final today   = list.where((n) => now.difference(n.time).inHours < 24).toList();
    final earlier = list.where((n) => now.difference(n.time).inHours >= 24).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
          sw * 0.040, sw * 0.030, sw * 0.040, sw * 0.060),
      children: [
        if (_isRefreshing)
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: sw * 0.020),
              child: SizedBox(
                width: sw * 0.060, height: sw * 0.060,
                child: const CircularProgressIndicator(
                    color: kPrimary, strokeWidth: 2),
              ),
            ),
          ),
        if (today.isNotEmpty) ...[
          _sectionLabel('Today', _filteredUnread > 0 ? '$_filteredUnread new' : null, sw),
          SizedBox(height: sw * 0.015),
          ...today.map((n) => _buildCard(n, sw)),
          SizedBox(height: sw * 0.025),
        ],
        if (earlier.isNotEmpty) ...[
          _sectionLabel('Earlier', null, sw),
          SizedBox(height: sw * 0.015),
          ...earlier.map((n) => _buildCard(n, sw)),
        ],
      ],
    );
  }

  Widget _sectionLabel(String label, String? badge, double sw) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
              fontSize: sw * 0.030,
              fontWeight: FontWeight.w800,
              color: kMuted,
              letterSpacing: 0.5,
            )),
        if (badge != null) ...[
          SizedBox(width: sw * 0.015),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.018, vertical: sw * 0.005),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge,
                style: TextStyle(
                  fontSize: sw * 0.022,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                )),
          ),
        ],
        SizedBox(width: sw * 0.020),
        Expanded(child: Container(height: 1, color: kBorder)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  SINGLE NOTIFICATION CARD
  // ─────────────────────────────────────────────

  Widget _buildCard(AppNotification n, double sw) {
    final nType  = _parseType(n.type);
    final theme  = _themeForType(nType);
    final isRead = n.id != null ? _read.contains(n.id) : false;
    final timeStr = _formatTime(n.time);
    final isPersonal = (n.category ?? '').toLowerCase() == 'personal';

    return GestureDetector(
      onTap: () => _navigate(n),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(bottom: sw * 0.025),
        decoration: BoxDecoration(
          color: isRead ? kCardBg : theme.bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead ? kBorder : theme.grad1.withOpacity(0.30),
            width: isRead ? 1.5 : 2,
          ),
          boxShadow: isRead
              ? [BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2))]
              : [BoxShadow(
              color: theme.grad1.withOpacity(0.12),
              blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            // Gradient accent bar for unread
            if (!isRead)
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [theme.grad1, theme.grad2]),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18)),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(sw * 0.038),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon tile
                      Container(
                        width: sw * 0.120, height: sw * 0.120,
                        decoration: BoxDecoration(
                          gradient: isRead
                              ? null
                              : LinearGradient(
                            colors: [theme.grad1, theme.grad2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          color: isRead ? kBgPage : null,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isRead
                              ? null
                              : [BoxShadow(
                              color: theme.grad1.withOpacity(0.30),
                              blurRadius: 8,
                              offset: const Offset(0, 3))],
                        ),
                        child: Icon(theme.icon,
                            color: isRead ? kMuted : Colors.white,
                            size: sw * 0.055),
                      ),
                      SizedBox(width: sw * 0.030),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(n.title,
                                      style: TextStyle(
                                        fontSize: sw * 0.035,
                                        fontWeight: isRead
                                            ? FontWeight.w600
                                            : FontWeight.w800,
                                        color: isRead ? kSlate : kInk,
                                        height: 1.3,
                                      )),
                                ),
                                SizedBox(width: sw * 0.010),
                                // Unread dot
                                if (!isRead)
                                  Container(
                                    width: sw * 0.022,
                                    height: sw * 0.022,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [theme.grad1, theme.grad2]),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: sw * 0.010),
                            Text(n.body,
                                style: TextStyle(
                                  fontSize: sw * 0.030,
                                  color: isRead ? kHint : kMuted,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: sw * 0.020),

                  // Bottom meta row
                  Row(
                    children: [
                      // Category chip
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.018,
                            vertical: sw * 0.007),
                        decoration: BoxDecoration(
                          color: isPersonal
                              ? kSuccess.withOpacity(0.10)
                              : kPrimary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPersonal ? Icons.person_rounded : Icons.campaign_rounded,
                              size: sw * 0.022,
                              color: isPersonal ? kSuccess : kPrimary,
                            ),
                            SizedBox(width: sw * 0.006),
                            Text(
                              isPersonal ? 'Personal' : 'Public',
                              style: TextStyle(
                                fontSize: sw * 0.022,
                                fontWeight: FontWeight.w700,
                                color: isPersonal ? kSuccess : kPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: sw * 0.012),

                      // Type chip
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.018,
                            vertical: sw * 0.007),
                        decoration: BoxDecoration(
                          color: theme.grad1.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _typeLabel(nType),
                          style: TextStyle(
                            fontSize: sw * 0.022,
                            fontWeight: FontWeight.w700,
                            color: theme.grad1,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Time
                      Icon(Icons.access_time_rounded,
                          size: sw * 0.026, color: isRead ? kHint : kMuted),
                      SizedBox(width: sw * 0.008),
                      Text(timeStr,
                          style: TextStyle(
                              fontSize: sw * 0.025,
                              color: isRead ? kHint : kMuted,
                              fontWeight: FontWeight.w600)),

                      SizedBox(width: sw * 0.015),

                      // Read/New badge
                      if (isRead)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.done_all_rounded,
                                size: sw * 0.026, color: kSuccess),
                          ],
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.018,
                              vertical: sw * 0.006),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [theme.grad1, theme.grad2]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('New',
                              style: TextStyle(
                                fontSize: sw * 0.020,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              )),
                        ),
                    ],
                  ),

                  // Tap to view hint (only when redirect is available)
                  if ((n.redirectTo ?? '').isNotEmpty) ...[
                    SizedBox(height: sw * 0.015),
                    Row(
                      children: [
                        Icon(Icons.arrow_forward_rounded,
                            size: sw * 0.026, color: theme.grad1.withOpacity(0.60)),
                        SizedBox(width: sw * 0.008),
                        Text(
                          'Tap to view ${_destLabel(n.redirectTo ?? '')}',
                          style: TextStyle(
                            fontSize: sw * 0.025,
                            fontWeight: FontWeight.w600,
                            color: theme.grad1.withOpacity(0.70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  LABEL HELPERS
  // ─────────────────────────────────────────────

  String _typeLabel(NotifType t) {
    switch (t) {
      case NotifType.course:      return 'Course';
      case NotifType.internship:  return 'Internship';
      case NotifType.job:         return 'Job';
      case NotifType.company:     return 'Company';
      case NotifType.hackathon:   return 'Hackathon';
      case NotifType.achievement: return 'Achievement';
      case NotifType.application: return 'Application';
      case NotifType.enrollment:  return 'Enrollment';
      case NotifType.saved:       return 'Saved';
      case NotifType.general:     return 'General';
    }
  }

  String _destLabel(String dest) {
    final map = {
      'jobs':         '→ Jobs',
      'internships':  '→ Internships',
      'companies':    '→ Companies',
      'hackathons':   '→ Hackathons',
      'courses':      '→ Courses',
      'achievements': '→ Achievements',
      'applications': '→ Applications',
      'enrollments':  '→ Enrollments',
    };
    return map[dest.toLowerCase()] ?? '→ Details';
  }

  // ─────────────────────────────────────────────
  //  TIME FORMATTER
  // ─────────────────────────────────────────────

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60)  return 'Just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)    return '${diff.inHours}h ago';
    if (diff.inDays == 1)     return 'Yesterday';
    if (diff.inDays < 7)      return '${diff.inDays}d ago';
    if (diff.inDays < 30)     return '${(diff.inDays / 7).floor()}w ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
