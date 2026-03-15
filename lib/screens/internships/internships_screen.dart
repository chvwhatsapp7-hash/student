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

class Internship {
  final int          id;
  final String       title;
  final String       company;
  final String       location;
  final String       stipend;
  final String       type;       // 'Paid' | 'Unpaid'
  final String       duration;
  final int          match;
  final String       logo;
  final List<String> tags;
  final bool         remote;
  final String       desc;

  const Internship({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.stipend,
    required this.type,
    required this.duration,
    required this.match,
    required this.logo,
    required this.tags,
    required this.remote,
    required this.desc,
  });
}

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────

final List<Internship> kInternships = [
  const Internship(
    id: 1, logo: '🩷', title: 'Frontend Intern',
    company: 'Myntra', location: 'Bengaluru',
    stipend: '₹20,000/mo', type: 'Paid',
    duration: '3 months', match: 94,
    tags: ['React', 'CSS', 'TypeScript'],
    remote: false,
    desc: "Work on Myntra's customer-facing web experience with a world-class design team.",
  ),
  const Internship(
    id: 2, logo: '🔵', title: 'ML Research Intern',
    company: 'Microsoft Research', location: 'Hyderabad',
    stipend: '₹35,000/mo', type: 'Paid',
    duration: '6 months', match: 89,
    tags: ['Python', 'Deep Learning', 'PyTorch'],
    remote: true,
    desc: 'Contribute to cutting-edge ML research projects alongside world-class scientists.',
  ),
  const Internship(
    id: 3, logo: '🦊', title: 'Open Source Contributor',
    company: 'Mozilla Foundation', location: 'Remote',
    stipend: 'Unpaid', type: 'Unpaid',
    duration: '2 months', match: 85,
    tags: ['JavaScript', 'HTML', 'Open Source'],
    remote: true,
    desc: 'Contribute to Firefox and other open-source projects that shape the web.',
  ),
  const Internship(
    id: 4, logo: '💚', title: 'Social Impact Tech Intern',
    company: 'TechForGood NGO', location: 'Delhi',
    stipend: 'Unpaid + Certificate', type: 'Unpaid',
    duration: '1 month', match: 75,
    tags: ['Python', 'Data', 'Impact'],
    remote: false,
    desc: 'Use technology to drive social change and gain meaningful real-world experience.',
  ),
  const Internship(
    id: 5, logo: '🟠', title: 'Backend Intern',
    company: 'Swiggy', location: 'Bengaluru',
    stipend: '₹30,000/mo', type: 'Paid',
    duration: '4 months', match: 82,
    tags: ['Go', 'Microservices', 'AWS'],
    remote: false,
    desc: 'Build scalable backend systems serving millions of food delivery orders daily.',
  ),
];

const List<String> kTabs = ['All', 'Paid', 'Unpaid'];

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class InternshipsScreen extends StatefulWidget {
  const InternshipsScreen({super.key});

  @override
  State<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen>
    with TickerProviderStateMixin {

  String     _tab    = 'All';
  String     _search = '';
  final Set<int> _saved   = {};
  final Set<int> _applied = {};

  late AnimationController _headerAnim;

  final Map<int, AnimationController> _cardAnims = {};

  List<Internship> get _filtered {
    var list = _tab == 'All'
        ? kInternships
        : kInternships.where((i) => i.type == _tab).toList();
    if (_search.isNotEmpty) {
      list = list.where((i) =>
      i.title.toLowerCase().contains(_search.toLowerCase()) ||
          i.company.toLowerCase().contains(_search.toLowerCase()) ||
          i.tags.any((t) =>
              t.toLowerCase().contains(_search.toLowerCase()))).toList();
    }
    return list;
  }

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();

    for (int i = 0; i < kInternships.length; i++) {
      final c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 460),
      );
      _cardAnims[kInternships[i].id] = c;
      Future.delayed(Duration(milliseconds: 180 + i * 80), () {
        if (mounted) c.forward();
      });
    }
  }

  @override
  void dispose() {
    _headerAnim.dispose();
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
          _buildSearchBar(),
          _buildTabSwitcher(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // ── HEADER ─────────────────────────────────

  Widget _buildHeader() {
    final paidCount   = kInternships.where((i) => i.type == 'Paid').length;
    final unpaidCount = kInternships.where((i) => i.type == 'Unpaid').length;

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
                            Icons.arrow_back_ios_new,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Internships',
                              style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: Colors.white, letterSpacing: -0.4,
                              )),
                          const Text('Real experience, real growth',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    // Saved count badge
                    if (_saved.isNotEmpty)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_saved.length} Saved',
                          style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: kAccent,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    _statPill('${kInternships.length}', 'Total'),
                    const SizedBox(width: 10),
                    _statPill('$paidCount', 'Paid'),
                    const SizedBox(width: 10),
                    _statPill('$unpaidCount', 'Unpaid'),
                    const SizedBox(width: 10),
                    _statPill('₹35K', 'Max Stipend'),
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(num,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800,
                  color: kAccent)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── SEARCH BAR ─────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
        decoration: InputDecoration(
          hintText: 'Search by role, company or skill…',
          hintStyle: const TextStyle(fontSize: 13, color: kHint),
          prefixIcon: const Icon(Icons.search,
              color: kMuted, size: 20),
          filled: true,
          fillColor: kBgPage,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kBorder, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kBorder, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kPrimary, width: 2),
          ),
        ),
      ),
    );
  }

  // ── TAB SWITCHER ───────────────────────────

  Widget _buildTabSwitcher() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Pill switcher
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: kBgPage,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: kTabs.map((t) {
                final active = _tab == t;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _tab = t);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? kPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: active ? Colors.white : kMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Spacer(),
          // Count chip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: kSelectedBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder),
            ),
            child: Text(
              '${_filtered.length} results',
              style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: kPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── LIST ───────────────────────────────────

  Widget _buildList() {
    final list = _filtered;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text('No internships found',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: kSlate)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() {
                _tab    = 'All';
                _search = '';
              }),
              child: const Text('Clear filters',
                  style: TextStyle(
                      color: kPrimary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: list.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (_, i) => _InternshipCard(
        internship: list[i],
        isSaved:    _saved.contains(list[i].id),
        isApplied:  _applied.contains(list[i].id),
        ctrl:       _cardAnims[list[i].id],
        onSave: () {
          HapticFeedback.selectionClick();
          setState(() {
            _saved.contains(list[i].id)
                ? _saved.remove(list[i].id)
                : _saved.add(list[i].id);
          });
        },
        onApply: () {
          HapticFeedback.lightImpact();
          setState(() => _applied.add(list[i].id));
          _showAppliedSnack(list[i].company);
        },
      ),
    );
  }

  void _showAppliedSnack(String company) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text('Application sent to $company!',
                style: const TextStyle(fontWeight: FontWeight.w700)),
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
//  INTERNSHIP CARD WIDGET
// ─────────────────────────────────────────────

class _InternshipCard extends StatefulWidget {
  final Internship          internship;
  final bool                isSaved;
  final bool                isApplied;
  final AnimationController? ctrl;
  final VoidCallback        onSave;
  final VoidCallback        onApply;

  const _InternshipCard({
    required this.internship,
    required this.isSaved,
    required this.isApplied,
    required this.onSave,
    required this.onApply,
    this.ctrl,
  });

  @override
  State<_InternshipCard> createState() => _InternshipCardState();
}

class _InternshipCardState extends State<_InternshipCard>
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
    final intern = widget.internship;
    final isPaid = intern.type == 'Paid';
    final ctrl   = widget.ctrl;

    final fade  = ctrl != null
        ? CurvedAnimation(parent: ctrl, curve: Curves.easeOut)
        : const AlwaysStoppedAnimation<double>(1.0);
    final slide = ctrl != null
        ? Tween<Offset>(
      begin: const Offset(0, 0.12), end: Offset.zero,
    ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut))
        : const AlwaysStoppedAnimation<Offset>(Offset.zero);

    // Match colour
    final matchColor = intern.match >= 90
        ? kSuccess
        : intern.match >= 80
        ? kWarning
        : kMuted;
    final matchBg = intern.match >= 90
        ? const Color(0xFFF0FDF4)
        : intern.match >= 80
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFF1F5F9);

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

              // ── TOP ROW ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
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
                        child: Text(intern.logo,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(intern.title,
                              style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800,
                                color: kInk,
                              )),
                          const SizedBox(height: 2),
                          Text(intern.company,
                              style: const TextStyle(
                                  fontSize: 12, color: kMuted,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 12, color: kHint),
                              const SizedBox(width: 3),
                              Text(intern.location,
                                  style: const TextStyle(
                                      fontSize: 12, color: kMuted)),
                              const SizedBox(width: 8),
                              if (intern.remote)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kSelectedBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Remote',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: kPrimary,
                                      )),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bookmark button
                    GestureDetector(
                      onTap: widget.onSave,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: widget.isSaved ? kSelectedBg : kBgPage,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.isSaved ? kPrimary : kBorder,
                          ),
                        ),
                        child: Icon(
                          widget.isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border,
                          size: 17,
                          color: widget.isSaved ? kPrimary : kHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── META CHIPS ───────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _metaChip(Icons.schedule, intern.duration),
                    const SizedBox(width: 7),
                    // Stipend chip — coloured by type
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPaid
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFDDD6FE),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPaid
                                ? Icons.monetization_on_rounded
                                : Icons.favorite_rounded,
                            size: 12,
                            color: isPaid
                                ? kSuccess
                                : const Color(0xFF7C3AED),
                          ),
                          const SizedBox(width: 4),
                          Text(intern.stipend,
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800,
                                color: isPaid
                                    ? kSuccess
                                    : const Color(0xFF7C3AED),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── DESCRIPTION ──────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(
                  intern.desc,
                  style: const TextStyle(
                      fontSize: 12, color: kHint, height: 1.5),
                ),
              ),

              // ── DIVIDER ──────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                height: 1, color: const Color(0xFFF1F5F9),
              ),

              // ── TAGS + MATCH + APPLY ──────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    // Tags
                    Expanded(
                      child: Wrap(
                        spacing: 6, runSpacing: 6,
                        children: intern.tags
                            .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kBorder),
                          ),
                          child: Text(t,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: kSlate,
                              )),
                        ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Match + Apply column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Match badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: matchBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${intern.match}% match',
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800,
                              color: matchColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Apply button
                        GestureDetector(
                          onTapDown: widget.isApplied
                              ? null
                              : (_) {
                            _btnCtrl.forward();
                            setState(() => _btnPressed = true);
                          },
                          onTapUp: widget.isApplied
                              ? null
                              : (_) {
                            _btnCtrl.reverse();
                            setState(() => _btnPressed = false);
                            widget.onApply();
                          },
                          onTapCancel: () {
                            _btnCtrl.reverse();
                            setState(() => _btnPressed = false);
                          },
                          child: ScaleTransition(
                            scale: _btnScale,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: widget.isApplied
                                    ? const Color(0xFFF0FDF4)
                                    : kPrimary,
                                borderRadius: BorderRadius.circular(30),
                                border: widget.isApplied
                                    ? Border.all(
                                    color: const Color(0xFF86EFAC),
                                    width: 1.5)
                                    : null,
                                boxShadow: widget.isApplied || _btnPressed
                                    ? null
                                    : [
                                  BoxShadow(
                                    color: kPrimary.withOpacity(0.28),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.isApplied)
                                    const Icon(Icons.check,
                                        size: 13, color: kSuccess),
                                  if (widget.isApplied)
                                    const SizedBox(width: 4),
                                  Text(
                                    widget.isApplied
                                        ? 'Applied!'
                                        : 'Apply Now',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: widget.isApplied
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: kMuted)),
        ],
      ),
    );
  }
}
