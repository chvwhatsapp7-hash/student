import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../notifications/notification_page.dart';

import '../../api_services/authservice.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const kInk = Color(0xFF0F172A);
const kSlate = Color(0xFF334155);
const kMuted = Color(0xFF64748B);
const kHint = Color(0xFF94A3B8);
const kBgPage = Color(0xFFF0F4F8);
const kCardBg = Color(0xFFFFFFFF);
const kBorder = Color(0xFFE2E8F0);
const kPrimary = Color(0xFF1D4ED8);
const kAccent = Color(0xFF38BDF8);
const kSuccess = Color(0xFF16A34A);
const kWarning = Color(0xFFF59E0B);
const kSelectedBg = Color(0xFFEFF6FF);

// ─────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────

class Hackathon {
  final int id;
  final String title;
  final String org;
  final String date;
  final String prize;
  final int participants;
  final List<String> tags;
  final String location;
  final String logo;
  final bool isOnline;
  final Color accentColor;

  Hackathon({
    required this.id,
    required this.title,
    required this.org,
    required this.date,
    required this.prize,
    required this.participants,
    required this.tags,
    required this.location,
    required this.logo,
    required this.isOnline,
    required this.accentColor,
  });

  factory Hackathon.fromApi(Map<String, dynamic> json) {
    final start = json['start_date'] ?? '';
    final end = json['end_date'] ?? '';
    final dateStr = start.isNotEmpty
        ? "${DateTime.parse(start).day}-${DateTime.parse(start).month}-${DateTime.parse(start).year} "
              "to ${DateTime.parse(end).day}-${DateTime.parse(end).month}-${DateTime.parse(end).year}"
        : "TBD";

    final location = json['location'] ?? 'Online';
    final mode = json['mode'] ?? '';
    bool isOnline =
        mode.toLowerCase() == 'online' || location.toLowerCase() == 'online';

    final orgColors = {
      'Google': kPrimary,
      'Microsoft': Color(0xFF107C10),
      'GitHub': Colors.black,
      'Flipkart': Color(0xFFFFC107),
      'Apollo Hospitals': Color(0xFF16A34A),
      'Tesla Energy': Color(0xFFE62E2E),
      'Polygon': Color(0xFF8247E5),
      'Y Combinator': Color(0xFFFF6F00),
      'Paytm': Color(0xFF0078D4),
      'Government of India': Color(0xFFFF9933),
    };

    String orgName = json['organizer'] ?? 'Organizer';

    // ✅ read themes/tags dynamically from API
    // change 'themes' to whatever key your API returns
    List<String> tags = (json['themes'] as List<dynamic>? ?? [])
        .map<String>((t) => t is Map ? t['name'].toString() : t.toString())
        .toList();

    // fallback if API returns empty
    if (tags.isEmpty) tags = ['General'];

    return Hackathon(
      id: json['hackathon_id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      org: orgName,
      date: dateStr,
      prize: json['prize_pool'] ?? 'N/A',
      participants: json['participants'] ?? 1000,
      tags: tags,
      location: location,
      logo: orgName.isNotEmpty ? orgName[0] : '🏆',
      isOnline: isOnline,
      accentColor: orgColors[orgName] ?? kAccent,
    );
  }
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class HackathonsScreen extends StatefulWidget {
  const HackathonsScreen({super.key});

  @override
  State<HackathonsScreen> createState() => _HackathonsScreenState();
}

class _HackathonsScreenState extends State<HackathonsScreen>
    with TickerProviderStateMixin {
  final Set<int> _reminded = {};
  List<Hackathon> _hackathons = [];
  bool _loading = true;

  late AnimationController _headerAnim;
  late List<AnimationController> _cardAnims;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _cardAnims = [];
    _fetchHackathons();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    for (final c in _cardAnims) c.dispose();
    super.dispose();
  }

  void _startCardAnims() {
    _cardAnims = List.generate(_hackathons.length, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 480),
      );
      Future.delayed(Duration(milliseconds: 60 + i * 70), () {
        if (mounted) ctrl.forward();
      });
      return ctrl;
    });
  }

  // ── API FETCH ───────────────────────────────

  Future<void> _fetchHackathons() async {
    try {
      final res = await AuthService().get('/hackathons');
      if (res.statusCode == 200) {
        final data = res.data['data'] as List;
        final hackathons = data.map((e) => Hackathon.fromApi(e)).toList();
        if (mounted) {
          setState(() {
            _hackathons = hackathons;
            _loading = false;
          });
          _startCardAnims();
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: _loading
          ? _buildShimmer()
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                    children: [
                      ..._hackathons.asMap().entries.map((entry) {
                        final i = entry.key;
                        final h = entry.value;
                        final ctrl = i < _cardAnims.length
                            ? _cardAnims[i]
                            : null;
                        final fade = ctrl != null
                            ? CurvedAnimation(
                                parent: ctrl,
                                curve: Curves.easeOut,
                              )
                            : const AlwaysStoppedAnimation<double>(1.0);
                        final slide = ctrl != null
                            ? Tween<Offset>(
                                begin: const Offset(0, 0.12),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: ctrl,
                                  curve: Curves.easeOut,
                                ),
                              )
                            : const AlwaysStoppedAnimation<Offset>(Offset.zero);
                        return FadeTransition(
                          opacity: fade,
                          child: SlideTransition(
                            position: slide,
                            child: _HackathonCard(
                              hackathon: h,
                              isReminded: _reminded.contains(h.id),
                              onRemind: () => _showReminderDialog(h),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── SHIMMER LOADING ─────────────────────────

  Widget _buildShimmer() {
    return Column(
      children: [
        Container(
          color: kInk,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 110,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(120, 20),
                  const SizedBox(height: 8),
                  _shimmerBox(180, 14),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (_, __) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              height: 160,
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: kBorder,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _shimmerBox(50, 50, radius: 14),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _shimmerBox(160, 14),
                                const SizedBox(height: 6),
                                _shimmerBox(100, 11),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _shimmerBox(double.infinity, 38, radius: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmerBox(double w, double h, {double radius = 8}) {
    return Container(
      width: w == double.infinity ? null : w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) => Opacity(opacity: _headerAnim.value, child: child),
      child: Container(
        color: kInk,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hackathons',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Compete, collaborate & win big',
                            style: TextStyle(fontSize: 12, color: kHint),
                          ),
                        ],
                      ),
                    ),
                    // live badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: kSuccess.withOpacity(0.40),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: kSuccess,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Live',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: kSuccess,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // stats
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _statPill(
                      Icons.emoji_events_rounded,
                      '${_hackathons.length}',
                      'Hackathons',
                    ),
                    _statPill(Icons.groups_2_rounded, '93K+', 'Participants'),
                    _statPill(
                      Icons.currency_rupee_rounded,
                      '2L+',
                      'Prize Pool',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statPill(IconData icon, String num, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: kAccent),
          const SizedBox(width: 5),
          Text(
            num,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: kAccent,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── REMINDER DIALOG ─────────────────────────

  void _showReminderDialog(Hackathon hack) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBorder, width: 1.5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: kPrimary,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Set Reminder',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We'll notify you when registrations open for\n${hack.title}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: kMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            'Not Now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _reminded.add(hack.id));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Reminder set for ${hack.title}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: kSuccess,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            'Yes, Remind Me!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HACKATHON CARD
// ─────────────────────────────────────────────

class _HackathonCard extends StatelessWidget {
  final Hackathon hackathon;
  final bool isReminded;
  final VoidCallback onRemind;

  const _HackathonCard({
    required this.hackathon,
    required this.isReminded,
    required this.onRemind,
  });

  @override
  Widget build(BuildContext context) {
    final h = hackathon;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // accent top bar
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: h.accentColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP ROW: logo + title + online badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // logo tile
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: h.accentColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: h.accentColor.withOpacity(0.25),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          h.logo,
                          style: TextStyle(
                            fontSize: 22,
                            color: h.accentColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: kInk,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.business_rounded,
                                size: 12,
                                color: kMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  h.org,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // online / offline badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: h.isOnline
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            h.isOnline
                                ? Icons.wifi_rounded
                                : Icons.location_on_rounded,
                            size: 10,
                            color: h.isOnline ? kPrimary : kSuccess,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            h.isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: h.isOnline ? kPrimary : kSuccess,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // INFO CHIPS: date + prize + location
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _infoChip(Icons.calendar_today_rounded, h.date, kMuted),
                    _infoChip(Icons.emoji_events_rounded, h.prize, kWarning),
                    _infoChip(
                      Icons.location_on_rounded,
                      h.location,
                      const Color(0xFFF43F5E),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ✅ THEME TAGS — dynamic from API
                if (h.tags.isNotEmpty)
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: h.tags
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: kSelectedBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kBorder),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: kPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 14),

                // REMIND ME BUTTON
                GestureDetector(
                  onTap: onRemind,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isReminded ? const Color(0xFFF0FDF4) : kPrimary,
                      borderRadius: BorderRadius.circular(14),
                      border: isReminded
                          ? Border.all(
                              color: const Color(0xFF86EFAC),
                              width: 1.5,
                            )
                          : null,
                      boxShadow: isReminded
                          ? null
                          : [
                              BoxShadow(
                                color: kPrimary.withOpacity(0.28),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isReminded
                              ? Icons.check_circle_rounded
                              : Icons.notifications_active_rounded,
                          size: 17,
                          color: isReminded ? kSuccess : Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isReminded ? 'Reminder Set!' : 'Remind Me Later',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isReminded ? kSuccess : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kMuted,
            ),
          ),
        ],
      ),
    );
  }
}
