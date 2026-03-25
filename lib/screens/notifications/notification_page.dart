import 'package:flutter/material.dart';
import '../../models/notification_model.dart';

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
//  STATIC NOTIFICATION DATA
//  Drop-in sample notifications so the page is
//  never blank during development / demo.
// ─────────────────────────────────────────────

List<AppNotification> get staticNotifications {
  final now = DateTime.now();
  return [
    // ── TODAY ──────────────────────────────────
    AppNotification(
      title: '🎉 Shortlisted at Google',
      body:
      'Congratulations! You\'ve been shortlisted for SWE Intern 2025 at Google. '
          'The recruiter will reach out within 3 business days.',
      time: now.subtract(const Duration(minutes: 2)),
    ),
    AppNotification(
      title: '📨 Application Submitted — Microsoft',
      body:
      'Your application for Software Engineer (New Grad) at Microsoft has been '
          'successfully submitted. Application ID: #MS-78412.',
      time: now.subtract(const Duration(minutes: 45)),
    ),
    AppNotification(
      title: '💼 New Job Alert — Amazon SDE',
      body:
      'Amazon is hiring SDE-1 in Bangalore. 3+ openings match your profile — '
          '92% fit score. Apply before the deadline closes.',
      time: now.subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      title: '🏆 Hackathon Reminder — Smart India',
      body:
      'Smart India Hackathon 2025 registration closes in 48 hours. Your team '
          '\'ByteBusters\' hasn\'t submitted the final problem statement yet.',
      time: now.subtract(const Duration(hours: 5)),
    ),
    AppNotification(
      title: '💬 Message from Infosys Recruiter',
      body:
      'Hi! I\'m Priya from Infosys Talent Acquisition. I\'d love to discuss the '
          'Systems Engineer role with you. Are you available this week?',
      time: now.subtract(const Duration(hours: 8)),
    ),
    AppNotification(
      title: '⚠️ Deadline Expiring — Flipkart Internship',
      body:
      'Your saved Flipkart Summer Internship application expires in 24 hours. '
          'Complete the coding assessment to stay in the running.',
      time: now.subtract(const Duration(hours: 11)),
    ),

    // ── EARLIER ─────────────────────────────────
    AppNotification(
      title: '🏫 New Internship — Swiggy Data Science',
      body:
      'Swiggy posted a 6-month Data Science internship (₹30K/month) matching your '
          'ML skills. 12 applicants so far — apply early!',
      time: now.subtract(const Duration(days: 1, hours: 3)),
    ),
    AppNotification(
      title: '❌ Application Update — Razorpay',
      body:
      'We regret to inform you that your application for Product Engineer at '
          'Razorpay was not selected this time. Keep building — we\'ll root for you.',
      time: now.subtract(const Duration(days: 2)),
    ),
    AppNotification(
      title: '👤 Profile 80% Complete',
      body:
      'Add your GitHub projects and a profile photo to boost your visibility to '
          'recruiters by up to 3×. Takes less than 2 minutes!',
      time: now.subtract(const Duration(days: 3)),
    ),
  ];
}

// ─────────────────────────────────────────────
//  NOTIFICATION THEME HELPER
// ─────────────────────────────────────────────

class _NTheme {
  final IconData icon;
  final Color    grad1, grad2, bg;
  const _NTheme(this.icon, this.grad1, this.grad2, this.bg);
}

_NTheme _resolveTheme(String title) {
  final t = title.toLowerCase();
  if (t.contains('shortlist') || t.contains('selected') || t.contains('congrat') || t.contains('🎉'))
    return const _NTheme(Icons.verified_rounded,
        Color(0xFF16A34A), Color(0xFF059669), Color(0xFFF0FDF4));
  if (t.contains('submitted') || t.contains('application') || t.contains('applied') || t.contains('📨'))
    return const _NTheme(Icons.send_rounded,
        Color(0xFF1D4ED8), Color(0xFF4F46E5), Color(0xFFEFF6FF));
  if (t.contains('job') || t.contains('role') || t.contains('hiring') || t.contains('💼'))
    return const _NTheme(Icons.work_rounded,
        Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFFFFBEB));
  if (t.contains('hack') || t.contains('contest') || t.contains('compet') || t.contains('🏆'))
    return const _NTheme(Icons.emoji_events_rounded,
        Color(0xFFD97706), Color(0xFFB45309), Color(0xFFFFFBEB));
  if (t.contains('message') || t.contains('chat') || t.contains('recruiter') || t.contains('💬'))
    return const _NTheme(Icons.chat_bubble_rounded,
        Color(0xFF0891B2), Color(0xFF38BDF8), Color(0xFFEFF6FF));
  if (t.contains('deadline') || t.contains('reminder') || t.contains('expir') || t.contains('⚠'))
    return const _NTheme(Icons.alarm_rounded,
        Color(0xFFDC2626), Color(0xFFB91C1C), Color(0xFFFFF1F2));
  if (t.contains('intern') || t.contains('🏫'))
    return const _NTheme(Icons.school_rounded,
        Color(0xFF0D9488), Color(0xFF0891B2), Color(0xFFEFFCF9));
  if (t.contains('reject') || t.contains('not selected') || t.contains('❌'))
    return const _NTheme(Icons.cancel_rounded,
        Color(0xFFDC2626), Color(0xFFB91C1C), Color(0xFFFFF1F2));
  if (t.contains('profile') || t.contains('update') || t.contains('complete') || t.contains('👤'))
    return const _NTheme(Icons.person_rounded,
        Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFFF0F9FF));
  if (t.contains('payment') || t.contains('stipend') || t.contains('salary'))
    return const _NTheme(Icons.payments_rounded,
        Color(0xFF059669), Color(0xFF16A34A), Color(0xFFF0FDF4));
  if (t.contains('course') || t.contains('learn') || t.contains('class'))
    return const _NTheme(Icons.menu_book_rounded,
        Color(0xFF7C3AED), Color(0xFF6366F1), Color(0xFFF5F3FF));
  // default
  return const _NTheme(Icons.notifications_rounded,
      Color(0xFF1D4ED8), Color(0xFF4F46E5), Color(0xFFEFF6FF));
}

// ─────────────────────────────────────────────
//  NOTIFICATION PAGE
// ─────────────────────────────────────────────

class NotificationPage extends StatefulWidget {
  /// Pass your own list, or omit to use the built-in static sample data.
  final List<AppNotification>? notifications;

  const NotificationPage({super.key, this.notifications});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _headerAnim;
  final Set<int> _read = {};

  List<AppNotification> get _notifications =>
      widget.notifications ?? staticNotifications;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  int get _unreadCount => _notifications.length - _read.length;

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw   = MediaQuery.of(context).size.width;
    final list = _notifications;

    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          _buildHeader(sw),
          Expanded(
            child: list.isEmpty
                ? _buildEmpty(sw)
                : _buildList(sw, list),
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
      builder: (_, child) =>
          Opacity(opacity: _headerAnim.value, child: child),
      child: Container(
        color: kInk,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                sw * 0.05, sw * 0.030, sw * 0.05, sw * 0.030),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: sw * 0.09, height: sw * 0.09,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: sw * 0.040),
                      ),
                    ),
                    SizedBox(width: sw * 0.030),
                    Container(
                      width: sw * 0.085, height: sw * 0.085,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text('⚡',
                            style: TextStyle(fontSize: sw * 0.040)),
                      ),
                    ),
                    SizedBox(width: sw * 0.025),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notifications',
                              style: TextStyle(
                                fontSize: sw * 0.045,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.4,
                              )),
                          Text('Stay on top of your career',
                              style: TextStyle(
                                fontSize: sw * 0.028,
                                color: Colors.white.withOpacity(0.50),
                              )),
                        ],
                      ),
                    ),
                    if (_unreadCount > 0)
                      GestureDetector(
                        onTap: () => setState(() {
                          for (int i = 0; i < _notifications.length; i++) {
                            _read.add(i);
                          }
                        }),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.030,
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

                Wrap(
                  spacing: sw * 0.020,
                  runSpacing: sw * 0.015,
                  children: [
                    _statPill(Icons.notifications_rounded,
                        '${_notifications.length}', 'Total', sw),
                    _statPill(Icons.mark_email_unread_rounded,
                        '$_unreadCount', 'Unread', sw,
                        numColor: _unreadCount > 0 ? kAccent : kHint),
                    _statPill(Icons.done_all_rounded,
                        '${_read.length}', 'Read', sw,
                        numColor: kSuccess),
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
          horizontal: sw * 0.030, vertical: sw * 0.013),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: sw * 0.030, color: numColor),
          SizedBox(width: sw * 0.013),
          Text(num,
              style: TextStyle(
                  fontSize: sw * 0.030,
                  fontWeight: FontWeight.w800,
                  color: numColor)),
          SizedBox(width: sw * 0.010),
          Text(label,
              style: TextStyle(
                fontSize: sw * 0.025,
                color: Colors.white.withOpacity(0.50),
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────────

  Widget _buildEmpty(double sw) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: sw * 0.22, height: sw * 0.22,
            decoration: const BoxDecoration(
                color: kSelectedBg, shape: BoxShape.circle),
            child: Icon(Icons.notifications_off_rounded,
                color: kPrimary, size: sw * 0.10),
          ),
          SizedBox(height: sw * 0.040),
          Text('All caught up!',
              style: TextStyle(
                fontSize: sw * 0.045,
                fontWeight: FontWeight.w800,
                color: kSlate,
              )),
          SizedBox(height: sw * 0.015),
          Text(
            'No notifications yet.\nWe\'ll let you know when something happens.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: sw * 0.033, color: kMuted, height: 1.55),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  NOTIFICATION LIST  (Today / Earlier groups)
  // ─────────────────────────────────────────────

  Widget _buildList(double sw, List<AppNotification> list) {
    final now     = DateTime.now();
    final today   = list.where((n) => now.difference(n.time).inHours < 24).toList();
    final earlier = list.where((n) => now.difference(n.time).inHours >= 24).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(
          sw * 0.040, sw * 0.030, sw * 0.040, sw * 0.060),
      children: [
        if (today.isNotEmpty) ...[
          _sectionLabel('Today', sw),
          SizedBox(height: sw * 0.015),
          ...today.map((n) => _buildCard(n, list.indexOf(n), sw)),
          SizedBox(height: sw * 0.025),
        ],
        if (earlier.isNotEmpty) ...[
          _sectionLabel('Earlier', sw),
          SizedBox(height: sw * 0.015),
          ...earlier.map((n) => _buildCard(n, list.indexOf(n), sw)),
        ],
      ],
    );
  }

  Widget _sectionLabel(String label, double sw) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
              fontSize: sw * 0.030,
              fontWeight: FontWeight.w800,
              color: kMuted,
              letterSpacing: 0.5,
            )),
        SizedBox(width: sw * 0.020),
        Expanded(child: Container(height: 1, color: kBorder)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  SINGLE NOTIFICATION CARD
  // ─────────────────────────────────────────────

  Widget _buildCard(AppNotification n, int index, double sw) {
    final theme   = _resolveTheme(n.title);
    final isRead  = _read.contains(index);
    final timeStr = _formatTime(n.time);

    return GestureDetector(
      onTap: () => setState(() => _read.add(index)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: sw * 0.025),
        decoration: BoxDecoration(
          color: isRead ? kCardBg : theme.bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead ? kBorder : theme.grad1.withOpacity(0.30),
            width: isRead ? 1.5 : 2,
          ),
          boxShadow: isRead
              ? null
              : [
            BoxShadow(
              color: theme.grad1.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
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
              padding: EdgeInsets.all(sw * 0.040),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Icon tile
                  Container(
                    width: sw * 0.12, height: sw * 0.12,
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
                          : [
                        BoxShadow(
                          color: theme.grad1.withOpacity(0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
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
                            if (!isRead) ...[
                              SizedBox(width: sw * 0.015),
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
                        SizedBox(height: sw * 0.015),

                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: sw * 0.028,
                                color: isRead ? kHint : kMuted),
                            SizedBox(width: sw * 0.010),
                            Text(timeStr,
                                style: TextStyle(
                                    fontSize: sw * 0.025,
                                    color: isRead ? kHint : kMuted,
                                    fontWeight: FontWeight.w600)),
                            const Spacer(),
                            if (isRead)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.done_all_rounded,
                                      size: sw * 0.028,
                                      color: kSuccess),
                                  SizedBox(width: sw * 0.008),
                                  Text('Read',
                                      style: TextStyle(
                                        fontSize: sw * 0.025,
                                        color: kSuccess,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ],
                              )
                            else
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.020,
                                    vertical: sw * 0.008),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [theme.grad1, theme.grad2]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('New',
                                    style: TextStyle(
                                      fontSize: sw * 0.022,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    )),
                              ),
                          ],
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
