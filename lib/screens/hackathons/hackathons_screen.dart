import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS — Engineering Theme
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
//  MODEL
// ─────────────────────────────────────────────

class Hackathon {
  final int          id;
  final String       title;
  final String       org;
  final String       date;
  final String       prize;
  final int          participants;
  final List<String> tags;
  final String       location;
  final String       logo;
  final bool         isOnline;
  final Color        accentColor;

  const Hackathon({
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
}

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────

final List<Hackathon> kHackathons = [
  const Hackathon(
    id: 1,
    title: 'Smart India Hackathon 2025',
    org: 'Government of India',
    date: 'Dec 2025',
    prize: '₹1 Lakh',
    participants: 50000,
    tags: ['AI', 'Govt', 'Social Impact'],
    location: 'Pan India',
    logo: '🇮🇳',
    isOnline: false,
    accentColor: Color(0xFF1D4ED8),
  ),
  const Hackathon(
    id: 2,
    title: 'HackWithInfy',
    org: 'Infosys',
    date: 'Feb 2026',
    prize: '₹50,000',
    participants: 10000,
    tags: ['Web', 'Mobile', 'Cloud'],
    location: 'Online',
    logo: '🔵',
    isOnline: true,
    accentColor: Color(0xFF0EA5E9),
  ),
  const Hackathon(
    id: 3,
    title: 'Flipkart GRiD 6.0',
    org: 'Flipkart',
    date: 'Mar 2026',
    prize: 'PPO + ₹75,000',
    participants: 25000,
    tags: ['ML', 'Systems', 'E-Commerce'],
    location: 'Bengaluru',
    logo: '🟡',
    isOnline: false,
    accentColor: Color(0xFFF59E0B),
  ),
  const Hackathon(
    id: 4,
    title: 'Code for Change',
    org: 'Google India',
    date: 'Apr 2026',
    prize: '\$5,000',
    participants: 8000,
    tags: ['Sustainability', 'AI', 'Web'],
    location: 'Hyderabad',
    logo: '🔶',
    isOnline: false,
    accentColor: Color(0xFF16A34A),
  ),
];

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

  late AnimationController _headerAnim;
  late AnimationController _bannerAnim;
  late Animation<double>   _bannerFade;
  late Animation<Offset>   _bannerSlide;

  final Map<int, AnimationController> _cardAnims = {};

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();

    _bannerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 560),
    );
    _bannerFade  = CurvedAnimation(parent: _bannerAnim, curve: Curves.easeOut);
    _bannerSlide = Tween<Offset>(
      begin: const Offset(0, 0.10), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _bannerAnim, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _bannerAnim.forward();
    });

    for (int i = 0; i < kHackathons.length; i++) {
      final c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480),
      );
      _cardAnims[kHackathons[i].id] = c;
      Future.delayed(Duration(milliseconds: 200 + i * 90), () {
        if (mounted) c.forward();
      });
    }
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _bannerAnim.dispose();
    for (final c in _cardAnims.values) c.dispose();
    super.dispose();
  }

  // ── build ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
              children: [
                FadeTransition(
                  opacity: _bannerFade,
                  child: SlideTransition(
                    position: _bannerSlide,
                    child: _buildHeroBanner(),
                  ),
                ),
                const SizedBox(height: 20),
                ...kHackathons.map((h) => _HackathonCard(
                  hackathon:  h,
                  isReminded: _reminded.contains(h.id),
                  ctrl:       _cardAnims[h.id],
                  onRemind:   () => _showReminderDialog(h),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ─────────────────────────────────

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) =>
          Opacity(opacity: _headerAnim.value, child: child),
      child: Container(
        color: kInk,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hackathons',
                              style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: Colors.white, letterSpacing: -0.4,
                              )),
                          Text(
                            'Compete, collaborate & win big',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    // Coming Soon badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kWarning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: kWarning.withOpacity(0.4), width: 1.5),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 12, color: kWarning),
                          SizedBox(width: 5),
                          Text('Coming Soon',
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800,
                                color: kWarning,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    _statPill('${kHackathons.length}', 'Hackathons'),
                    const SizedBox(width: 10),
                    _statPill('93K+', 'Participants'),
                    const SizedBox(width: 10),
                    _statPill('₹2L+', 'Total Prize'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statPill(String num, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(num,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  color: kAccent)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── HERO BANNER ────────────────────────────

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kInk,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🏆  Season 2025–26',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800,
                      color: kAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "India's biggest\ncoding battles\nare coming.",
                  style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: Colors.white, height: 1.3,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Set reminders and never miss\na registration deadline.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.60),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Trophy illustration
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 42)),
            ),
          ),
        ],
      ),
    );
  }

  // ── REMINDER DIALOG ────────────────────────

  void _showReminderDialog(Hackathon hack) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon ring
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: kSelectedBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBorder, width: 1.5),
                ),
                child: const Center(
                  child: Icon(Icons.notifications_active_rounded,
                      color: kPrimary, size: 28),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Set Reminder',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We'll notify you when registrations open for\n${hack.title}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: kMuted, height: 1.5),
              ),
              const SizedBox(height: 22),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text('Not Now',
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: kMuted,
                              )),
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
                        _showConfirmSnack(hack.title);
                      },
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text('Yes, Remind Me!',
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800,
                                color: Colors.white,
                              )),
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

  void _showConfirmSnack(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Reminder set for $title",
                style: const TextStyle(
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HACKATHON CARD WIDGET
// ─────────────────────────────────────────────

class _HackathonCard extends StatefulWidget {
  final Hackathon           hackathon;
  final bool                isReminded;
  final AnimationController? ctrl;
  final VoidCallback        onRemind;

  const _HackathonCard({
    required this.hackathon,
    required this.isReminded,
    required this.onRemind,
    this.ctrl,
  });

  @override
  State<_HackathonCard> createState() => _HackathonCardState();
}

class _HackathonCardState extends State<_HackathonCard>
    with SingleTickerProviderStateMixin {

  bool _btnPressed = false;
  late AnimationController _btnCtrl;
  late Animation<double>   _btnScale;

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 140),
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h    = widget.hackathon;
    final ctrl = widget.ctrl;

    final fade  = ctrl != null
        ? CurvedAnimation(parent: ctrl, curve: Curves.easeOut)
        : const AlwaysStoppedAnimation<double>(1.0);
    final slide = ctrl != null
        ? Tween<Offset>(
      begin: const Offset(0, 0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut))
        : const AlwaysStoppedAnimation<Offset>(Offset.zero);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── TOP ACCENT BAR ───────────────
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: h.accentColor,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── HEADER ROW ───────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo tile
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: kBgPage,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: kBorder),
                          ),
                          child: Center(
                            child: Text(h.logo,
                                style:
                                const TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: kInk,
                                  )),
                              const SizedBox(height: 3),
                              Text(h.org,
                                  style: const TextStyle(
                                      fontSize: 12, color: kMuted,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        // Online badge
                        if (h.isOnline)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: kBorder),
                            ),
                            child: const Text('Online',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: kPrimary,
                                )),
                          ),
                      ],
                    ),

                    // ── META ROW ─────────────────
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _metaChip(Icons.calendar_today_rounded,
                            h.date),
                        const SizedBox(width: 8),
                        _metaChip(Icons.emoji_events_rounded,
                            h.prize,
                            iconColor: kWarning),
                        const SizedBox(width: 8),
                        _metaChip(Icons.people_alt_rounded,
                            _formatCount(h.participants)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _metaChip(Icons.location_on_rounded,
                            h.location),
                      ],
                    ),

                    // ── DIVIDER ──────────────────
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      height: 1,
                      color: const Color(0xFFF1F5F9),
                    ),

                    // ── TAGS ─────────────────────
                    Wrap(
                      spacing: 7, runSpacing: 7,
                      children: h.tags.map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: kSelectedBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kBorder),
                        ),
                        child: Text(t,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kPrimary,
                            )),
                      )).toList(),
                    ),

                    // ── REMINDER BUTTON ──────────
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTapDown: widget.isReminded
                          ? null
                          : (_) {
                        _btnCtrl.forward();
                        setState(() => _btnPressed = true);
                      },
                      onTapUp: widget.isReminded
                          ? null
                          : (_) {
                        _btnCtrl.reverse();
                        setState(() => _btnPressed = false);
                        widget.onRemind();
                      },
                      onTapCancel: () {
                        _btnCtrl.reverse();
                        setState(() => _btnPressed = false);
                      },
                      child: ScaleTransition(
                        scale: _btnScale,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 13),
                          decoration: BoxDecoration(
                            color: widget.isReminded
                                ? const Color(0xFFF0FDF4)
                                : kPrimary,
                            borderRadius: BorderRadius.circular(14),
                            border: widget.isReminded
                                ? Border.all(
                                color: const Color(0xFF86EFAC),
                                width: 1.5)
                                : null,
                            boxShadow: widget.isReminded || _btnPressed
                                ? null
                                : [
                              BoxShadow(
                                color: kPrimary.withOpacity(0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isReminded
                                    ? Icons.check_circle_rounded
                                    : Icons.notifications_rounded,
                                size: 17,
                                color: widget.isReminded
                                    ? kSuccess
                                    : Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.isReminded
                                    ? 'Reminder Set!'
                                    : 'Remind Me Later',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: widget.isReminded
                                      ? kSuccess
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label,
      {Color iconColor = kHint}) {
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
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: kMuted)),
        ],
      ),
    );
  }

  String _formatCount(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(0)}K+' : '$n';
}