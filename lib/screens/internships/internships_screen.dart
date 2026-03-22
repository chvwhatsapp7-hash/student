import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
const kTabs       = ['All', 'Paid', 'Unpaid'];

// ─────────────────────────────────────────────
//  MODEL — untouched
// ─────────────────────────────────────────────
class Internship {
  final int          id;
  final String       title;
  final String       company;
  final String       location;
  final String       stipend;
  final String       type;
  final String       duration;
  final int          match;
  final String       logo;
  final List<String> tags;
  final bool         remote;
  final String       desc;

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
      id:       json['internship_id'] ?? 0,
      title:    json['title'] ?? 'No title',
      company:  'Company ${json['company_id'] ?? 'Unknown'}',
      location: json['location'] ?? 'Remote',
      stipend:  json['stipend'] != null ? '₹${json['stipend']}' : 'Unpaid',
      type:     json['internship_type'] ?? 'Paid',
      duration: json['duration'] ?? '1 month',
      match:    0,
      logo:     '🟢',
      tags:     [],
      remote:   (json['location']?.toString().toLowerCase() == 'remote'),
      desc:     json['description'] ?? 'No description',
    );
  }
}

// ─────────────────────────────────────────────
//  ICON THEME SYSTEM — design only, untouched
// ─────────────────────────────────────────────
class _InternTheme {
  final IconData icon;
  final Color    grad1;
  final Color    grad2;
  const _InternTheme(this.icon, this.grad1, this.grad2);
}

_InternTheme _resolveInternTheme(String title, String company) {
  final t = title.toLowerCase();
  final c = company.toLowerCase();

  if (t.contains('software engineer') || t.contains('sde'))
    return const _InternTheme(Icons.code,                    Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (t.contains('frontend') || t.contains('front-end') || t.contains('ui developer'))
    return const _InternTheme(Icons.web,                     Color(0xFF0EA5E9), Color(0xFF38BDF8));
  if (t.contains('backend') || t.contains('back-end') || t.contains('server'))
    return const _InternTheme(Icons.dns,                     Color(0xFF15803D), Color(0xFF22C55E));
  if (t.contains('full stack') || t.contains('fullstack'))
    return const _InternTheme(Icons.layers,                  Color(0xFF1D4ED8), Color(0xFF7C3AED));
  if (t.contains('mobile') || t.contains('android') || t.contains('flutter'))
    return const _InternTheme(Icons.phone_android,           Color(0xFF0284C7), Color(0xFF38BDF8));
  if (t.contains('ios') || t.contains('swift'))
    return const _InternTheme(Icons.phone_iphone,            Color(0xFF374151), Color(0xFF6B7280));
  if (t.contains('machine learning') || t.contains(' ml '))
    return const _InternTheme(Icons.psychology,              Color(0xFF6366F1), Color(0xFF8B5CF6));
  if (t.contains('deep learning') || t.contains('neural'))
    return const _InternTheme(Icons.hub,                     Color(0xFF7C3AED), Color(0xFF4F46E5));
  if (t.contains('data science') || t.contains('data analyst'))
    return const _InternTheme(Icons.analytics,               Color(0xFF7C3AED), Color(0xFF6366F1));
  if (t.contains('data engineer'))
    return const _InternTheme(Icons.storage,                 Color(0xFF0369A1), Color(0xFF0284C7));
  if (t.contains('artificial intelligence') || t.contains(' ai') || t.contains('ai '))
    return const _InternTheme(Icons.smart_toy,               Color(0xFF4F46E5), Color(0xFF6366F1));
  if (t.contains('nlp') || t.contains('natural language'))
    return const _InternTheme(Icons.chat_bubble_outline,     Color(0xFF8B5CF6), Color(0xFFA855F7));
  if (t.contains('research'))
    return const _InternTheme(Icons.biotech,                 Color(0xFF0891B2), Color(0xFF0E7490));
  if (t.contains('cloud') || t.contains('aws') || t.contains('azure') || t.contains('gcp'))
    return const _InternTheme(Icons.cloud,                   Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('devops') || t.contains('sre'))
    return const _InternTheme(Icons.sync_alt,                Color(0xFF059669), Color(0xFF10B981));
  if (t.contains('docker') || t.contains('kubernetes'))
    return const _InternTheme(Icons.view_in_ar,              Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('security') || t.contains('cyber') || t.contains('ethical'))
    return const _InternTheme(Icons.shield,                  Color(0xFFB91C1C), Color(0xFFDC2626));
  if (t.contains('ui') || t.contains('ux') || t.contains('design') || t.contains('figma'))
    return const _InternTheme(Icons.brush,                   Color(0xFFEC4899), Color(0xFFF43F5E));
  if (t.contains('product manager') || t.contains('product management'))
    return const _InternTheme(Icons.inventory_2,             Color(0xFFD97706), Color(0xFFF59E0B));
  if (t.contains('marketing') || t.contains('growth') || t.contains('seo'))
    return const _InternTheme(Icons.trending_up,             Color(0xFFD97706), Color(0xFFF59E0B));
  if (t.contains('content') || t.contains('writer'))
    return const _InternTheme(Icons.edit_note,               Color(0xFF7C3AED), Color(0xFFA855F7));
  if (t.contains('finance') || t.contains('accounting'))
    return const _InternTheme(Icons.account_balance,         Color(0xFF065F46), Color(0xFF059669));
  if (t.contains('sales') || t.contains('business development'))
    return const _InternTheme(Icons.handshake,               Color(0xFF7C3AED), Color(0xFF6366F1));
  if (t.contains('hr') || t.contains('human resource'))
    return const _InternTheme(Icons.people,                  Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('testing') || t.contains('qa') || t.contains('quality'))
    return const _InternTheme(Icons.bug_report,              Color(0xFFB45309), Color(0xFFD97706));
  if (t.contains('social') || t.contains('ngo') || t.contains('impact'))
    return const _InternTheme(Icons.volunteer_activism,      Color(0xFF059669), Color(0xFF10B981));
  if (t.contains('open source') || t.contains('contributor'))
    return const _InternTheme(Icons.terminal,                Color(0xFF374151), Color(0xFF4B5563));
  if (t.contains('blockchain') || t.contains('web3'))
    return const _InternTheme(Icons.link,                    Color(0xFF7C3AED), Color(0xFF6366F1));
  if (c.contains('google'))
    return const _InternTheme(Icons.search,                  Color(0xFF1D4ED8), Color(0xFF0EA5E9));
  if (c.contains('microsoft'))
    return const _InternTheme(Icons.window,                  Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (c.contains('amazon') || c.contains('aws'))
    return const _InternTheme(Icons.cloud,                   Color(0xFFD97706), Color(0xFFF59E0B));
  if (c.contains('flipkart'))
    return const _InternTheme(Icons.shopping_bag,            Color(0xFFD97706), Color(0xFFF59E0B));
  if (c.contains('razorpay') || c.contains('paytm'))
    return const _InternTheme(Icons.account_balance_wallet,  Color(0xFF1D4ED8), Color(0xFF6366F1));
  if (c.contains('swiggy') || c.contains('zomato'))
    return const _InternTheme(Icons.delivery_dining,         Color(0xFFDC2626), Color(0xFFEF4444));

  return const _InternTheme(Icons.work_outline,              Color(0xFF1D4ED8), Color(0xFF6366F1));
}

class _InternIconTile extends StatelessWidget {
  final String title;
  final String company;
  const _InternIconTile({required this.title, required this.company});

  @override
  Widget build(BuildContext context) {
    final theme = _resolveInternTheme(title, company);
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.grad1, theme.grad2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.grad1.withValues(alpha: 0.28),
            blurRadius: 8, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(theme.icon, color: Colors.white, size: 24),
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

  // state — untouched
  List<Internship>                    _internships = [];
  final Set<int>                      _saved       = {};
  final Set<int>                      _applied     = {};
  final Map<int, AnimationController> _cardAnims   = {};
  String                              _tab         = 'All';
  String                              _search      = '';
  late AnimationController            _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();
    _fetchInternships();  // ← API — untouched
  }

  // ── API FETCH — completely untouched ─────────
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
                vsync: this, duration: const Duration(milliseconds: 460),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to load internships: $e')),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // _filtered — untouched
  List<Internship> get _filtered {
    var list = _tab == 'All'
        ? _internships
        : _internships.where((i) => i.type == _tab).toList();
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
  void dispose() {
    _headerAnim.dispose();
    for (final c in _cardAnims.values) c.dispose();
    super.dispose();
  }

  // ── TAP CARD → DETAIL SHEET (NEW) ───────────
  // Shows full internship details + company info on card tap.
  // Apply button inside sheet calls the same onApply logic.

  void _showDetailSheet(Internship intern) {
    final theme  = _resolveInternTheme(intern.title, intern.company);
    final isPaid = intern.type == 'Paid';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize:     0.40,
        maxChildSize:     0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: EdgeInsets.zero,
            children: [

              // ── Gradient header ─────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.grad1.withValues(alpha: 0.08),
                      theme.grad2.withValues(alpha: 0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: kBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // Gradient top accent line
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.grad1, theme.grad2],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Company icon + title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InternIconTile(
                            title: intern.title, company: intern.company),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(intern.title,
                                  style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800,
                                    color: kInk, letterSpacing: -0.3,
                                  )),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.apartment_rounded,
                                      size: 13, color: kMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(intern.company,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13, color: kMuted,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Paid / Unpaid badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? const Color(0xFFF0FDF4)
                                      : const Color(0xFFFAF5FF),
                                  borderRadius: BorderRadius.circular(20),
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
                                          : Icons.volunteer_activism_rounded,
                                      size: 12,
                                      color: isPaid
                                          ? kSuccess
                                          : const Color(0xFF7C3AED),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isPaid ? 'Paid Internship' : 'Unpaid / Volunteer',
                                      style: TextStyle(
                                        fontSize: 11, fontWeight: FontWeight.w700,
                                        color: isPaid
                                            ? kSuccess
                                            : const Color(0xFF7C3AED),
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
                  ],
                ),
              ),

              // ── Details section ──────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Key info grid
                    Container(
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(
                        children: [
                          _detailRow(
                            Icons.payments_rounded,
                            'Stipend', intern.stipend,
                            isFirst: true,
                          ),
                          _detailDivider(),
                          _detailRow(
                            Icons.pin_drop_rounded,
                            'Location', intern.location,
                          ),
                          _detailDivider(),
                          _detailRow(
                            Icons.hourglass_bottom_rounded,
                            'Duration', intern.duration,
                          ),
                          _detailDivider(),
                          _detailRow(
                            Icons.badge_rounded,
                            'Type', intern.type,
                          ),
                          if (intern.remote) ...[
                            _detailDivider(),
                            _detailRow(
                              Icons.wifi_rounded,
                              'Work Mode', 'Remote — work from anywhere',
                              isLast: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // About the role
                    const Text('About the Role',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800,
                          color: kInk,
                        )),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kBgPage,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                      ),
                      child: Text(
                        intern.desc.isEmpty
                            ? 'No description available for this internship.'
                            : intern.desc,
                        style: const TextStyle(
                          fontSize: 13, color: kSlate,
                          height: 1.65, fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Skills / tags
                    if (intern.tags.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      const Text('Skills Required',
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: kInk,
                          )),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: intern.tags.map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: kSelectedBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kBorder),
                          ),
                          child: Text(t,
                              style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: kPrimary,
                              )),
                        )).toList(),
                      ),
                    ],

                    // Remote note
                    if (intern.remote) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kSelectedBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.laptop_mac_rounded,
                                color: kPrimary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This is a remote internship. Work from anywhere in India.',
                                style: const TextStyle(
                                  fontSize: 12, color: kPrimary,
                                  fontWeight: FontWeight.w600, height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Apply / Applied button ──────────
                    StatefulBuilder(
                      builder: (ctx, setBtn) {
                        final isApplied = _applied.contains(intern.id);
                        return GestureDetector(
                          onTap: isApplied
                              ? null
                              : () {
                            Navigator.pop(context);
                            setState(() => _applied.add(intern.id));
                            _showApplyDialog(intern);
                            _showAppliedSnack(intern.company);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              gradient: isApplied
                                  ? null
                                  : LinearGradient(
                                colors: [theme.grad1, theme.grad2],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              color: isApplied
                                  ? const Color(0xFFF0FDF4)
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              border: isApplied
                                  ? Border.all(
                                  color: const Color(0xFF86EFAC),
                                  width: 1.5)
                                  : null,
                              boxShadow: isApplied
                                  ? null
                                  : [
                                BoxShadow(
                                  color: theme.grad1.withValues(alpha: 0.30),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isApplied
                                        ? Icons.verified_rounded
                                        : Icons.rocket_launch_rounded,
                                    color: isApplied
                                        ? kSuccess : Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isApplied
                                        ? 'Already Applied'
                                        : 'Apply for this Internship',
                                    style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w800,
                                      color: isApplied
                                          ? kSuccess : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── detail row helper ───────────────────────

  Widget _detailRow(IconData icon, String label, String value,
      {bool isFirst = false, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: kSelectedBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: kPrimary),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: kMuted, fontWeight: FontWeight.w600)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: kInk,
                )),
          ),
        ],
      ),
    );
  }

  Widget _detailDivider() =>
      Container(height: 1, color: kBorder,
          margin: const EdgeInsets.symmetric(horizontal: 16));

  // ── APPLY DIALOG — untouched logic ───────────
  void _showApplyDialog(Internship intern) {
    final theme = _resolveInternTheme(intern.title, intern.company);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.grad1, theme.grad2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: theme.grad1.withValues(alpha: 0.28),
                          blurRadius: 8, offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(theme.icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(intern.title,
                            style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800,
                              color: kInk,
                            )),
                        const SizedBox(height: 2),
                        Text(intern.company,
                            style: const TextStyle(
                                fontSize: 12, color: kMuted,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _dialogRow(Icons.pin_drop_rounded,       'Location',  intern.location),
              _dialogRow(Icons.hourglass_bottom_rounded,'Duration',  intern.duration),
              _dialogRow(Icons.payments_rounded,        'Stipend',   intern.stipend),
              _dialogRow(Icons.badge_rounded,           'Type',      intern.type),
              if (intern.remote)
                _dialogRow(Icons.wifi_rounded, 'Mode', 'Remote — work from anywhere'),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('About the Role',
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800,
                          color: kInk,
                        )),
                    const SizedBox(height: 6),
                    Text(intern.desc,
                        style: const TextStyle(
                            fontSize: 12, color: kSlate, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF86EFAC), width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: kSuccess, size: 18),
                    SizedBox(width: 10),
                    Text('Application submitted successfully!',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: kSuccess,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.grad1, theme.grad2],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: theme.grad1.withValues(alpha: 0.28),
                        blurRadius: 10, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('Got it!',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: kSelectedBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: kPrimary, size: 15),
          ),
          const SizedBox(width: 10),
          Text('$label  ',
              style: const TextStyle(
                  fontSize: 12, color: kMuted, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: kInk,
                ),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // _showAppliedSnack — untouched
  void _showAppliedSnack(String company) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
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

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final paidCount   = _internships.where((i) => i.type == 'Paid').length;
    final unpaidCount = _internships.where((i) => i.type == 'Unpaid').length;

    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          // ── HEADER ─────────────────────────────
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
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded,
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
                                Text('Real experience, real growth',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.55),
                                    )),
                              ],
                            ),
                          ),
                          if (_saved.isNotEmpty)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bookmarks_rounded,
                                      color: kAccent, size: 13),
                                  const SizedBox(width: 4),
                                  Text('${_saved.length} Saved',
                                      style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w700,
                                        color: kAccent,
                                      )),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Stats — Wrap prevents overflow
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          _statPill(Icons.cases_rounded,
                              '${_internships.length}', 'Total'),
                          _statPill(Icons.payments_rounded,
                              '$paidCount', 'Paid'),
                          _statPill(Icons.volunteer_activism_rounded,
                              '$unpaidCount', 'Unpaid'),
                          _statPill(
                            Icons.trending_up_rounded,
                            _internships.isEmpty
                                ? '₹0'
                                : '₹${_internships.map((e) => int.tryParse(e.stipend.replaceAll('₹', '')) ?? 0).reduce((a, b) => a > b ? a : b)}',
                            'Max',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── SEARCH ─────────────────────────────
          Container(
            color: kCardBg,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: kInk),
              decoration: InputDecoration(
                hintText: 'Search by role, company or skill…',
                hintStyle: const TextStyle(fontSize: 13, color: kHint),
                prefixIcon: const Icon(Icons.saved_search_rounded,
                    color: kMuted, size: 22),
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
          ),

          // ── TAB SWITCHER ───────────────────────
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
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? kPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(t,
                              style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: active ? Colors.white : kMuted,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: kSelectedBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kBorder),
                  ),
                  child: Text('${_filtered.length} results',
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: kPrimary,
                      )),
                ),
              ],
            ),
          ),

          // ── LIST ───────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: const BoxDecoration(
                        color: kSelectedBg, shape: BoxShape.circle),
                    child: const Icon(Icons.search_off_rounded,
                        color: kPrimary, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text('No internships found',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: kSlate)),
                  const SizedBox(height: 6),
                  const Text('Try a different filter or keyword',
                      style: TextStyle(fontSize: 12, color: kMuted)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => setState(() {
                      _tab    = 'All';
                      _search = '';
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('Clear filters',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
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
                isSaved:    _saved.contains(_filtered[i].id),
                isApplied:  _applied.contains(_filtered[i].id),
                ctrl:       _cardAnims[_filtered[i].id],
                // NEW: tap card → detail sheet
                onTap: () => _showDetailSheet(_filtered[i]),
                onSave: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _saved.contains(_filtered[i].id)
                        ? _saved.remove(_filtered[i].id)
                        : _saved.add(_filtered[i].id);
                  });
                },
                // onApply — untouched logic
                onApply: () {
                  HapticFeedback.lightImpact();
                  setState(() => _applied.add(_filtered[i].id));
                  _showApplyDialog(_filtered[i]);
                  _showAppliedSnack(_filtered[i].company);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String num, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: kAccent),
          const SizedBox(width: 4),
          Text(num,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: kAccent)),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.55),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  INTERNSHIP CARD
// ─────────────────────────────────────────────
class _InternshipCard extends StatefulWidget {
  final Internship           internship;
  final bool                 isSaved;
  final bool                 isApplied;
  final AnimationController? ctrl;
  final VoidCallback         onSave;
  final VoidCallback         onApply;
  final VoidCallback         onTap;   // NEW: tap card → detail sheet

  const _InternshipCard({
    required this.internship,
    required this.isSaved,
    required this.isApplied,
    required this.onSave,
    required this.onApply,
    required this.onTap,
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
  void dispose() { _btnCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final intern = widget.internship;
    final ctrl   = widget.ctrl;
    final theme  = _resolveInternTheme(intern.title, intern.company);

    final fade  = ctrl != null
        ? CurvedAnimation(parent: ctrl, curve: Curves.easeOut)
        : const AlwaysStoppedAnimation<double>(1.0);
    final slide = ctrl != null
        ? Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut))
        : const AlwaysStoppedAnimation<Offset>(Offset.zero);

    final isPaid = intern.type == 'Paid';

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: GestureDetector(
          onTap: widget.onTap,   // ← tap anywhere on card → detail sheet
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              gradient: widget.isApplied
                  ? LinearGradient(
                colors: [
                  theme.grad1.withValues(alpha: 0.09),
                  theme.grad2.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color:         widget.isApplied ? null : kCardBg,
              borderRadius:  BorderRadius.circular(20),
              border: Border.all(
                color: widget.isApplied
                    ? theme.grad1.withValues(alpha: 0.50)
                    : kBorder,
                width: widget.isApplied ? 2 : 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Applied top accent strip
                if (widget.isApplied)
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.grad1, theme.grad2],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // TOP ROW
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InternIconTile(
                              title: intern.title, company: intern.company),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(intern.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800, fontSize: 14,
                                      color: kInk,
                                    )),
                                const SizedBox(height: 3),
                                Text(intern.company,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: kMuted, fontSize: 12,
                                    )),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.pin_drop_rounded,
                                        size: 12, color: kHint),
                                    const SizedBox(width: 3),
                                    Text(intern.location,
                                        style: const TextStyle(
                                            fontSize: 12, color: kMuted)),
                                    if (intern.remote) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: kSelectedBg,
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.wifi_rounded,
                                                size: 10, color: kPrimary),
                                            SizedBox(width: 3),
                                            Text('Remote',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: kPrimary,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Bookmark
                          GestureDetector(
                            onTap: widget.onSave,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                color: widget.isSaved
                                    ? kSelectedBg : kBgPage,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: widget.isSaved ? kPrimary : kBorder,
                                ),
                              ),
                              child: Icon(
                                widget.isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_outline_rounded,
                                size: 17,
                                color: widget.isSaved ? kPrimary : kHint,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // DESCRIPTION preview
                      const SizedBox(height: 10),
                      Text(intern.desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: kHint, height: 1.5)),

                      // "Tap to view details" hint
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.open_in_new_rounded,
                              size: 11, color: kPrimary.withValues(alpha: 0.70)),
                          const SizedBox(width: 4),
                          Text('Tap card for full details',
                              style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600,
                                color: kPrimary.withValues(alpha: 0.70),
                              )),
                        ],
                      ),

                      // META CHIPS
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 7, runSpacing: 6,
                        children: [
                          _chip(Icons.hourglass_bottom_rounded, intern.duration),
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
                                      : Icons.volunteer_activism_rounded,
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
                          for (final t in intern.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: kBorder),
                              ),
                              child: Text(t,
                                  style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700,
                                    color: kSlate,
                                  )),
                            ),
                        ],
                      ),

                      // DIVIDER
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        height: 1,
                        color: const Color(0xFFF1F5F9),
                      ),

                      // BOTTOM ROW
                      Row(
                        children: [
                          if (widget.isApplied)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [theme.grad1, theme.grad2]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      color: Colors.white, size: 12),
                                  SizedBox(width: 5),
                                  Text('Applied',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                            )
                          else if (intern.match > 0)
                            _matchBadge(intern.match),
                          const Spacer(),
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
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: widget.isApplied
                                      ? null
                                      : LinearGradient(
                                    colors: [theme.grad1, theme.grad2],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  color: widget.isApplied
                                      ? const Color(0xFFF0FDF4)
                                      : null,
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
                                      color: theme.grad1
                                          .withValues(alpha: 0.28),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.isApplied
                                          ? Icons.verified_rounded
                                          : Icons.rocket_launch_rounded,
                                      size: 14,
                                      color: widget.isApplied
                                          ? kSuccess : Colors.white,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      widget.isApplied
                                          ? 'Applied ✓'
                                          : 'Apply Now',
                                      style: TextStyle(
                                        color: widget.isApplied
                                            ? kSuccess : Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
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
          Icon(icon, size: 12, color: kHint),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: kMuted)),
        ],
      ),
    );
  }

  Widget _matchBadge(int match) {
    final color = match >= 90 ? kSuccess : match >= 80 ? kWarning : kMuted;
    final bg    = match >= 90
        ? const Color(0xFFF0FDF4)
        : match >= 80
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFF1F5F9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text('$match% Match',
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
