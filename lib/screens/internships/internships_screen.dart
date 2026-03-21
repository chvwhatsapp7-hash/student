import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
const kTabs = ['All', 'Paid', 'Unpaid'];

// ─────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────
class Internship {
  final int id;
  final String title;
  final String company;
  final String location;
  final String stipend;
  final String type; // Paid / Unpaid
  final String duration;
  final int match; // default 0
  final String logo;
  final List<String> tags;
  final bool remote;
  final String desc;

  Internship({
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

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      id: json['internship_id'] ?? 0,
      title: json['title'] ?? 'No title',
      company: 'Company ${json['company_id'] ?? 'Unknown'}',
      location: json['location'] ?? 'Remote',
      stipend: json['stipend'] != null ? '₹${json['stipend']}' : 'Unpaid',
      type: json['internship_type'] ?? 'Paid', // default Paid
      duration: json['duration'] ?? '1 month',
      match: 0, // API doesn't provide match
      logo: '🟢', // default icon
      tags: [], // API doesn't provide tags
      remote: (json['location']?.toString().toLowerCase() == 'remote'),
      desc: json['description'] ?? 'No description',
    );
  }
}

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
  List<Internship> _internships = [];
  final Set<int> _saved = {};
  final Set<int> _applied = {};
  final Map<int, AnimationController> _cardAnims = {};
  String _tab = 'All';
  String _search = '';
  late AnimationController _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fetchInternships();
  }

  Future<void> _fetchInternships() async {
    try {
      final response = await http.get(
        Uri.parse('https://studenthub-backend-woad.vercel.app/api/internships'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final List<dynamic> dataList = jsonData['data'];

          setState(() {
            _internships = dataList.map((e) => Internship.fromJson(e)).toList();

            for (int i = 0; i < _internships.length; i++) {
              final ctrl = AnimationController(
                vsync: this,
                duration: const Duration(milliseconds: 460),
              );
              _cardAnims[_internships[i].id] = ctrl;
              Future.delayed(Duration(milliseconds: 180 + i * 80), () {
                if (mounted) ctrl.forward();
              });
            }
          });
        } else {
          throw Exception('API returned success=false');
        }
      } else {
        throw Exception('Failed to load internships: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching internships: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load internships: $e')));
    }
  }

  List<Internship> get _filtered {
    var list = _tab == 'All'
        ? _internships
        : _internships.where((i) => i.type == _tab).toList();
    if (_search.isNotEmpty) {
      list = list
          .where(
            (i) =>
                i.title.toLowerCase().contains(_search.toLowerCase()) ||
                i.company.toLowerCase().contains(_search.toLowerCase()) ||
                i.tags.any(
                  (t) => t.toLowerCase().contains(_search.toLowerCase()),
                ),
          )
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    for (final c in _cardAnims.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paidCount = _internships.where((i) => i.type == 'Paid').length;
    final unpaidCount = _internships.where((i) => i.type == 'Unpaid').length;

    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          // HEADER
          AnimatedBuilder(
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
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Internships',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const Text(
                                  'Real experience, real growth',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_saved.isNotEmpty)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_saved.length} Saved',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kAccent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _statPill('${_internships.length}', 'Total'),
                          const SizedBox(width: 10),
                          _statPill('$paidCount', 'Paid'),
                          const SizedBox(width: 10),
                          _statPill('$unpaidCount', 'Unpaid'),
                          const SizedBox(width: 10),
                          _statPill(
                            _internships.isEmpty
                                ? '₹0'
                                : _internships
                                      .map(
                                        (e) =>
                                            int.tryParse(
                                              e.stipend.replaceAll('₹', ''),
                                            ) ??
                                            0,
                                      )
                                      .reduce((a, b) => a > b ? a : b)
                                      .toString(),
                            'Max Stipend',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // SEARCH
          Container(
            color: kCardBg,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kInk,
              ),
              decoration: InputDecoration(
                hintText: 'Search by role, company or skill…',
                hintStyle: const TextStyle(fontSize: 13, color: kHint),
                prefixIcon: const Icon(Icons.search, color: kMuted, size: 20),
                filled: true,
                fillColor: kBgPage,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
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
          ),
          // TAB SWITCHER
          Container(
            color: kCardBg,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
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
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: active ? kPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : kMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: kSelectedBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kBorder),
                  ),
                  child: Text(
                    '${_filtered.length} results',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // LIST
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        const Text(
                          'No internships found',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: kSlate,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => setState(() {
                            _tab = 'All';
                            _search = '';
                          }),
                          child: const Text(
                            'Clear filters',
                            style: TextStyle(
                              color: kPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemCount: _filtered.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (_, i) => _InternshipCard(
                      internship: _filtered[i],
                      isSaved: _saved.contains(_filtered[i].id),
                      isApplied: _applied.contains(_filtered[i].id),
                      ctrl: _cardAnims[_filtered[i].id],
                      onSave: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _saved.contains(_filtered[i].id)
                              ? _saved.remove(_filtered[i].id)
                              : _saved.add(_filtered[i].id);
                        });
                      },
                      onApply: () {
                        HapticFeedback.lightImpact();
                        setState(() => _applied.add(_filtered[i].id));
                        _showAppliedSnack(_filtered[i].company);
                      },
                    ),
                  ),
          ),
        ],
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
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAppliedSnack(String company) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              'Application sent to $company!',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  INTERNSHIP CARD
// ─────────────────────────────────────────────
class _InternshipCard extends StatefulWidget {
  final Internship internship;
  final bool isSaved;
  final bool isApplied;
  final AnimationController? ctrl;
  final VoidCallback onSave;
  final VoidCallback onApply;

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
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _btnScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intern = widget.internship;
    final ctrl = widget.ctrl;
    final fade = ctrl != null
        ? CurvedAnimation(parent: ctrl, curve: Curves.easeOut)
        : const AlwaysStoppedAnimation(1.0);
    final slide = ctrl != null
        ? Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut))
        : const AlwaysStoppedAnimation<Offset>(Offset.zero);

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

    final isPaid = intern.type == 'Paid';

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
              // TOP ROW
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(intern.logo),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            intern.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            intern.company,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: kMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onSave,
                      child: Icon(
                        widget.isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: widget.isSaved ? kPrimary : kMuted,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // DESCRIPTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(intern.desc, style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 10),
              // TAGS & LOCATION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (intern.remote)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kSelectedBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Remote',
                          style: TextStyle(fontSize: 11, color: kPrimary),
                        ),
                      ),
                    for (final t in intern.tags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kSelectedBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(fontSize: 11, color: kPrimary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // STATS ROW
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: matchBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${intern.match}% Match',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: matchColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      intern.stipend,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // APPLY BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTapDown: (_) => _btnCtrl.forward(),
                  onTapUp: (_) => _btnCtrl.reverse(),
                  onTapCancel: () => _btnCtrl.reverse(),
                  onTap: widget.onApply,
                  child: ScaleTransition(
                    scale: _btnScale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: widget.isApplied
                            ? kMuted.withOpacity(0.3)
                            : kPrimary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.isApplied ? 'Applied' : 'Apply Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
