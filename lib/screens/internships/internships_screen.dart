import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../api_services/applications.dart';
import '../../api_services/authservice.dart';
import '../../widgets/social_post_card.dart';

// ═══════════════════════════════════════════
//  DESIGN TOKENS
// ═══════════════════════════════════════════
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

// ═══════════════════════════════════════════
//  INTERN FILTER MODEL
// ═══════════════════════════════════════════
class InternFilter {
  final String? type;
  final RangeValues stipendRange;
  final Set<String> selectedLocations;
  final Set<String> selectedCompanies;
  final Set<String> selectedRoles;

  InternFilter({
    this.type,
    this.stipendRange = const RangeValues(0, 100000),
    this.selectedLocations = const {},
    this.selectedCompanies = const {},
    this.selectedRoles = const {},
  });

  bool get isActive =>
      type != null ||
      stipendRange.start > 0 ||
      stipendRange.end < 100000 ||
      selectedLocations.isNotEmpty ||
      selectedCompanies.isNotEmpty ||
      selectedRoles.isNotEmpty;

  bool get hasActiveFilters => isActive;

  int get activeCount =>
      (type != null ? 1 : 0) +
      (stipendRange.start > 0 || stipendRange.end < 100000 ? 1 : 0) +
      selectedLocations.length +
      selectedCompanies.length +
      selectedRoles.length;

  InternFilter copyWith({
    String? type,
    bool clearType = false,
    RangeValues? stipendRange,
    Set<String>? selectedLocations,
    Set<String>? selectedCompanies,
    Set<String>? selectedRoles,
  }) =>
      InternFilter(
        type: clearType ? null : (type ?? this.type),
        stipendRange: stipendRange ?? this.stipendRange,
        selectedLocations: selectedLocations ?? this.selectedLocations,
        selectedCompanies: selectedCompanies ?? this.selectedCompanies,
        selectedRoles: selectedRoles ?? this.selectedRoles,
      );
}

// ═══════════════════════════════════════════
//  INTERNSHIP MODEL
// ═══════════════════════════════════════════
class Internship {
  final int id;
  final String title, company, location, stipend, type, duration, logo, desc;
  final int match;
  final List<String> tags;
  final bool remote;
  final String? imageUrl;
  final String? companyLogo;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;

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
    this.imageUrl,
    this.companyLogo,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
  });

  factory Internship.fromJson(Map<String, dynamic> json) => Internship(
    id: json['internship_id'] ?? 0,
    title: json['title'] ?? 'No title',
    company: json['company_name'] ?? (json['company'] is String ? json['company'] : 'Company ${json['company_id'] ?? 0}'),
    location: json['location'] ?? 'Remote',
    stipend: json['stipend'] != null ? '${json['stipend']}' : 'Unpaid',
    type: json['internship_type'] ?? 'Paid',
    duration: json['duration'] ?? '1 month',
    match: 0,
    logo: json['company_logo'] ?? '',
    tags: (json['skills'] as List<dynamic>? ?? [])
        .map<String>(
            (s) => s is Map ? s['name'].toString() : s.toString())
        .toList(),
    remote:
    json['location']?.toString().toLowerCase() == 'remote',
    desc: json['description'] ?? 'No description',
  );

  int get stipendInt =>
      int.tryParse(stipend.replaceAll(',', '').replaceAll(' ', '')) ?? 0;
}

// ═══════════════════════════════════════════
//  ICON SYSTEM
// ═══════════════════════════════════════════
class InternTheme {
  final IconData icon;
  final Color grad1, grad2;
  const InternTheme(this.icon, this.grad1, this.grad2);
}

InternTheme resolveInternTheme(String title, String company) {
  final t = title.toLowerCase();
  final c = company.toLowerCase();
  if (t.contains('software engineer') || t.contains('sde'))
    return const InternTheme(
        Icons.code, Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (t.contains('frontend') ||
      t.contains('front-end') ||
      t.contains('ui developer'))
    return const InternTheme(
        Icons.web, Color(0xFF0EA5E9), Color(0xFF38BDF8));
  if (t.contains('backend') ||
      t.contains('back-end') ||
      t.contains('server'))
    return const InternTheme(
        Icons.dns, Color(0xFF15803D), Color(0xFF22C55E));
  if (t.contains('full stack') || t.contains('fullstack'))
    return const InternTheme(
        Icons.layers, Color(0xFF1D4ED8), Color(0xFF7C3AED));
  if (t.contains('mobile') ||
      t.contains('android') ||
      t.contains('flutter'))
    return const InternTheme(
        Icons.phone_android, Color(0xFF0284C7), Color(0xFF38BDF8));
  if (t.contains('machine learning') || t.contains(' ml'))
    return const InternTheme(
        Icons.psychology, Color(0xFF6366F1), Color(0xFF8B5CF6));
  if (t.contains('data science') || t.contains('data analyst'))
    return const InternTheme(
        Icons.analytics, Color(0xFF7C3AED), Color(0xFF6366F1));
  if (t.contains('artificial intelligence') ||
      t.contains(' ai') ||
      t.contains('ai '))
    return const InternTheme(
        Icons.smart_toy, Color(0xFF4F46E5), Color(0xFF6366F1));
  if (t.contains('cloud') ||
      t.contains('aws') ||
      t.contains('azure') ||
      t.contains('gcp'))
    return const InternTheme(
        Icons.cloud, Color(0xFF0369A1), Color(0xFF0EA5E9));
  if (t.contains('devops') || t.contains('sre'))
    return const InternTheme(
        Icons.sync_alt, Color(0xFF059669), Color(0xFF10B981));
  if (t.contains('security') ||
      t.contains('cyber') ||
      t.contains('ethical'))
    return const InternTheme(
        Icons.shield, Color(0xFFB91C1C), Color(0xFFDC2626));
  if (t.contains('ui') ||
      t.contains('ux') ||
      t.contains('design') ||
      t.contains('figma'))
    return const InternTheme(
        Icons.brush, Color(0xFFEC4899), Color(0xFFF43F5E));
  if (t.contains('marketing') ||
      t.contains('growth') ||
      t.contains('seo'))
    return const InternTheme(
        Icons.trending_up, Color(0xFFD97706), Color(0xFFF59E0B));
  if (t.contains('testing') || t.contains('qa') || t.contains('quality'))
    return const InternTheme(
        Icons.bug_report, Color(0xFFB45309), Color(0xFFD97706));
  if (c.contains('google'))
    return const InternTheme(
        Icons.search, Color(0xFF1D4ED8), Color(0xFF0EA5E9));
  if (c.contains('microsoft'))
    return const InternTheme(
        Icons.window, Color(0xFF1D4ED8), Color(0xFF3B82F6));
  if (c.contains('amazon') || c.contains('aws'))
    return const InternTheme(
        Icons.cloud, Color(0xFFD97706), Color(0xFFF59E0B));
  return const InternTheme(
      Icons.work_outline, Color(0xFF1D4ED8), Color(0xFF6366F1));
}

// ═══════════════════════════════════════════
//  ICON TILE
// ═══════════════════════════════════════════
class InternIconTile extends StatelessWidget {
  final String title, company;
  final double size;
  const InternIconTile({
    required this.title,
    required this.company,
    this.size = 50,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = resolveInternTheme(title, company);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.grad1, theme.grad2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: theme.grad1.withOpacity(0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(theme.icon, color: Colors.white, size: size * 0.46),
    );
  }
}

// ═══════════════════════════════════════════
//  FILTER BOTTOM SHEET
// ═══════════════════════════════════════════
class _FilterSheet extends StatefulWidget {
  final InternFilter current;
  final List<String> allLocations;
  final List<String> allCompanies;
  final List<String> allRoles;
  final double maxStipend;

  const _FilterSheet({
    required this.current,
    required this.allLocations,
    required this.allCompanies,
    required this.allRoles,
    required this.maxStipend,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet>
    with SingleTickerProviderStateMixin {
  late InternFilter _draft;
  late TabController _tabCtrl;

  static const _sections = ['Type', 'Stipend', 'Location', 'Company', 'Role'];

  @override
  void initState() {
    super.initState();
    _draft = widget.current.copyWith();
    _tabCtrl = TabController(length: _sections.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  double get _effectiveMax =>
      widget.maxStipend > 0 ? widget.maxStipend : 100000;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      height: sh * 0.82,
      decoration: const BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin:
              EdgeInsets.only(top: sw * 0.03, bottom: sw * 0.02),
              width: sw * 0.10,
              height: 4,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.05, vertical: sw * 0.01),
            child: Row(
              children: [
                Container(
                  width: sw * 0.09,
                  height: sw * 0.09,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.tune_rounded,
                      color: Colors.white, size: sw * 0.045),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Internships',
                        style: TextStyle(
                          fontSize: sw * 0.042,
                          fontWeight: FontWeight.w800,
                          color: kInk,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Narrow down to your perfect match',
                        style:
                        TextStyle(fontSize: sw * 0.028, color: kMuted),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _draft = InternFilter()),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.03,
                        vertical: sw * 0.015),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20),
                      border:
                      Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded,
                            size: sw * 0.03,
                            color: const Color(0xFFDC2626)),
                        SizedBox(width: sw * 0.01),
                        Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: sw * 0.028,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sw * 0.02),
          SizedBox(
            height: sw * 0.10,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04, vertical: sw * 0.01),
              itemCount: _sections.length,
              separatorBuilder: (_, __) => SizedBox(width: sw * 0.02),
              itemBuilder: (_, i) {
                final active = _tabCtrl.index == i;
                return GestureDetector(
                  onTap: () {
                    setState(() => _tabCtrl.animateTo(i));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.04,
                        vertical: sw * 0.018),
                    decoration: BoxDecoration(
                      color: active ? kPrimary : kBgPage,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: active ? kPrimary : kBorder,
                          width: 1.5),
                    ),
                    child: Text(
                      _sections[i],
                      style: TextStyle(
                        fontSize: sw * 0.030,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : kMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _tabCtrl,
              builder: (_, __) => _buildSectionContent(sw),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                sw * 0.05, sw * 0.02, sw * 0.05, sw * 0.06),
            child: GestureDetector(
              onTap: () => Navigator.pop(context, _draft),
              child: Container(
                width: double.infinity,
                padding:
                EdgeInsets.symmetric(vertical: sw * 0.038),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, Color(0xFF6366F1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white, size: sw * 0.042),
                    SizedBox(width: sw * 0.02),
                    Text(
                      _draft.activeCount > 0
                          ? 'Apply ${_draft.activeCount} Filter${_draft.activeCount > 1 ? 's' : ''}'
                          : 'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: sw * 0.038,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(double sw) {
    switch (_tabCtrl.index) {
      case 0:
        return _buildTypeSection(sw);
      case 1:
        return _buildStipendSection(sw);
      case 2:
        return _buildMultiSelectSection(
          sw,
          label: 'Location',
          icon: Icons.location_on,
          items: widget.allLocations,
          selected: _draft.selectedLocations,
          onToggle: (v) => setState(() {
            final s = Set<String>.from(_draft.selectedLocations);
            s.contains(v) ? s.remove(v) : s.add(v);
            _draft = _draft.copyWith(selectedLocations: s);
          }),
        );
      case 3:
        return _buildMultiSelectSection(
          sw,
          label: 'Company',
          icon: Icons.business,
          items: widget.allCompanies,
          selected: _draft.selectedCompanies,
          onToggle: (v) => setState(() {
            final s = Set<String>.from(_draft.selectedCompanies);
            s.contains(v) ? s.remove(v) : s.add(v);
            _draft = _draft.copyWith(selectedCompanies: s);
          }),
        );
      case 4:
        return _buildMultiSelectSection(
          sw,
          label: 'Role',
          icon: Icons.work_outline,
          items: widget.allRoles,
          selected: _draft.selectedRoles,
          onToggle: (v) => setState(() {
            final s = Set<String>.from(_draft.selectedRoles);
            s.contains(v) ? s.remove(v) : s.add(v);
            _draft = _draft.copyWith(selectedRoles: s);
          }),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildTypeSection(double sw) {
    final options = [
      {
        'label': 'All Types',
        'sub': 'Show all internships',
        'icon': Icons.apps_rounded,
        'color': kPrimary,
        'value': null,
      },
      {
        'label': 'Paid',
        'sub': 'With stipend / salary',
        'icon': Icons.monetization_on_rounded,
        'color': kSuccess,
        'value': 'Paid',
      },
      {
        'label': 'Unpaid',
        'sub': 'Volunteer / experience',
        'icon': Icons.volunteer_activism_rounded,
        'color': const Color(0xFF7C3AED),
        'value': 'Unpaid',
      },
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(
          sw * 0.05, sw * 0.03, sw * 0.05, sw * 0.02),
      children: options.map((opt) {
        final val = opt['value'] as String?;
        final active = _draft.type == val;
        final color = opt['color'] as Color;
        return GestureDetector(
          onTap: () => setState(() {
            _draft = active
                ? _draft.copyWith(clearType: true)
                : _draft.copyWith(type: val);
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: EdgeInsets.only(bottom: sw * 0.025),
            padding: EdgeInsets.all(sw * 0.04),
            decoration: BoxDecoration(
              color:
              active ? color.withOpacity(0.08) : kBgPage,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? color : kBorder,
                width: active ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: sw * 0.11,
                  height: sw * 0.11,
                  decoration: BoxDecoration(
                    color: active
                        ? color.withOpacity(0.15)
                        : kBorder.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(opt['icon'] as IconData,
                      color: active ? color : kMuted,
                      size: sw * 0.050),
                ),
                SizedBox(width: sw * 0.035),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt['label'] as String,
                        style: TextStyle(
                          fontSize: sw * 0.036,
                          fontWeight: FontWeight.w800,
                          color: active ? color : kInk,
                        ),
                      ),
                      SizedBox(height: sw * 0.005),
                      Text(
                        opt['sub'] as String,
                        style: TextStyle(
                            fontSize: sw * 0.028, color: kMuted),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: sw * 0.055,
                  height: sw * 0.055,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                    active ? color : Colors.transparent,
                    border: Border.all(
                        color: active ? color : kHint, width: 2),
                  ),
                  child: active
                      ? Icon(Icons.check,
                      color: Colors.white, size: sw * 0.028)
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStipendSection(double sw) {
    final max = _effectiveMax;
    final ranges = [
      {'label': 'Any', 'range': RangeValues(0, max)},
      {'label': '₹0 – ₹5K', 'range': const RangeValues(0, 5000)},
      {'label': '₹5K – ₹15K', 'range': const RangeValues(5000, 15000)},
      {'label': '₹15K – ₹30K', 'range': const RangeValues(15000, 30000)},
      {'label': '₹30K – ₹50K', 'range': const RangeValues(30000, 50000)},
      {'label': '₹50K+', 'range': RangeValues(50000, max)},
    ];
    final cur = _draft.stipendRange;

    return ListView(
      padding: EdgeInsets.fromLTRB(
          sw * 0.05, sw * 0.03, sw * 0.05, sw * 0.02),
      children: [
        Text('Quick Ranges',
            style: TextStyle(
                fontSize: sw * 0.032,
                fontWeight: FontWeight.w700,
                color: kInk)),
        SizedBox(height: sw * 0.02),
        Wrap(
          spacing: sw * 0.02,
          runSpacing: sw * 0.015,
          children: ranges.map((r) {
            final rv = r['range'] as RangeValues;
            final active =
                cur.start == rv.start && cur.end == rv.end;
            return GestureDetector(
              onTap: () => setState(
                      () => _draft = _draft.copyWith(stipendRange: rv)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.035,
                    vertical: sw * 0.018),
                decoration: BoxDecoration(
                  color: active ? kPrimary : kBgPage,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: active ? kPrimary : kBorder,
                      width: 1.5),
                ),
                child: Text(
                  r['label'] as String,
                  style: TextStyle(
                    fontSize: sw * 0.030,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : kSlate,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: sw * 0.04),
        Text('Custom Range',
            style: TextStyle(
                fontSize: sw * 0.032,
                fontWeight: FontWeight.w700,
                color: kInk)),
        SizedBox(height: sw * 0.02),
        Container(
          padding: EdgeInsets.all(sw * 0.04),
          decoration: BoxDecoration(
            color: kBgPage,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stipendChip(
                      '₹${_formatNum(_draft.stipendRange.start.toInt())}',
                      sw),
                  Icon(Icons.arrow_forward,
                      size: sw * 0.04, color: kHint),
                  _stipendChip(
                      '₹${_formatNum(_draft.stipendRange.end.toInt())}',
                      sw),
                ],
              ),
              SizedBox(height: sw * 0.02),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: kPrimary,
                  inactiveTrackColor: kBorder,
                  thumbColor: kPrimary,
                  overlayColor: kPrimary.withOpacity(0.15),
                  rangeThumbShape:
                  const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 10),
                  trackHeight: 4,
                ),
                child: RangeSlider(
                  min: 0,
                  max: max,
                  divisions: 20,
                  values: _draft.stipendRange,
                  onChanged: (v) => setState(
                          () => _draft = _draft.copyWith(stipendRange: v)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stipendChip(String label, double sw) => Container(
    padding: EdgeInsets.symmetric(
        horizontal: sw * 0.03, vertical: sw * 0.015),
    decoration: BoxDecoration(
      color: kSelectedBg,
      borderRadius: BorderRadius.circular(8),
      border:
      Border.all(color: kPrimary.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: sw * 0.030,
        fontWeight: FontWeight.w800,
        color: kPrimary,
      ),
    ),
  );

  String _formatNum(int n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return '$n';
  }

  Widget _buildMultiSelectSection(
      double sw, {
        required String label,
        required IconData icon,
        required List<String> items,
        required Set<String> selected,
        required ValueChanged<String> onToggle,
      }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: sw * 0.10, color: kHint),
            SizedBox(height: sw * 0.02),
            Text('No $label data available',
                style: TextStyle(
                    fontSize: sw * 0.033, color: kMuted)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selected.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(
                sw * 0.05, sw * 0.03, sw * 0.05, 0),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: sw * 0.015,
                    runSpacing: sw * 0.012,
                    children: selected
                        .map((s) => Chip(
                      label: Text(
                        s,
                        style: TextStyle(
                          fontSize: sw * 0.028,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                      backgroundColor: kSelectedBg,
                      side: const BorderSide(
                          color: kPrimary, width: 1.2),
                      deleteIcon: Icon(Icons.close,
                          size: sw * 0.030,
                          color: kPrimary),
                      onDeleted: () => onToggle(s),
                      padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.01,
                          vertical: 0),
                      materialTapTargetSize:
                      MaterialTapTargetSize
                          .shrinkWrap,
                      visualDensity:
                      VisualDensity.compact,
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
                sw * 0.05, sw * 0.02, sw * 0.05, sw * 0.02),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              final isSelected = selected.contains(item);
              return GestureDetector(
                onTap: () => onToggle(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(bottom: sw * 0.018),
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04,
                      vertical: sw * 0.03),
                  decoration: BoxDecoration(
                    color: isSelected ? kSelectedBg : kBgPage,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? kPrimary : kBorder,
                      width: isSelected ? 1.8 : 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon,
                          size: sw * 0.038,
                          color: isSelected ? kPrimary : kHint),
                      SizedBox(width: sw * 0.025),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: sw * 0.033,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color:
                            isSelected ? kInk : kSlate,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 180),
                        width: sw * 0.055,
                        height: sw * 0.055,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? kPrimary
                              : Colors.transparent,
                          border: Border.all(
                              color: isSelected
                                  ? kPrimary
                                  : kHint,
                              width: 1.8),
                        ),
                        child: isSelected
                            ? Icon(Icons.check,
                            color: Colors.white,
                            size: sw * 0.030)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════
//  SCREEN
// ═══════════════════════════════════════════
class InternshipsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const InternshipsScreen({super.key, this.onBack});
  @override
  State<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen>
    with TickerProviderStateMixin {
  List<Internship> internships = [];
  final Set<int> saved = {};
  final Set<int> applied = {};
  final Map<int, AnimationController> cardAnims = {};
  String tab = 'All';
  String search = '';
  InternFilter filter = InternFilter();
  late AnimationController headerAnim;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  void _handleBack() {
    HapticFeedback.lightImpact();
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  List<String> get allLocations => internships
      .map((i) => i.location)
      .toSet()
      .where((l) => l.isNotEmpty)
      .toList()
    ..sort();

  List<String> get allCompanies => internships
      .map((i) => i.company)
      .toSet()
      .where((c) => c.isNotEmpty)
      .toList()
    ..sort();

  List<String> get allRoles => internships
      .map((i) => i.title)
      .toSet()
      .where((r) => r.isNotEmpty)
      .toList()
    ..sort();

  double get maxStipend {
    if (internships.isEmpty) return 100000;
    final m = internships
        .map((i) => i.stipendInt.toDouble())
        .reduce((a, b) => a > b ? a : b);
    return m > 0 ? m : 100000;
  }

  @override
  void initState() {
    super.initState();
    headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    loadAppliedInternships();
    fetchInternships();
  }

  @override
  void dispose() {
    headerAnim.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    for (final c in cardAnims.values) c.dispose();
    super.dispose();
  }

  Future<void> loadAppliedInternships() async {
    final appsData = await ApplicationsService.getApplications();
    if (appsData != null && appsData['success'] == true) {
      final dataList = appsData['data'] as List;
      if (mounted) {
        setState(() {
          applied.clear();
          applied.addAll(
            dataList
                .where((app) => app['internship_id'] != null)
                .map<int>((app) => app['internship_id'] as int),
          );
        });
      }
    }
  }

  Future<void> handleApply(int internshipId, String company) async {
    if (applied.contains(internshipId)) return;
    HapticFeedback.lightImpact();
    final result =
    await ApplicationsService.apply(internshipId: internshipId);
    if (result == 'Applied successfully') {
      if (mounted) setState(() => applied.add(internshipId));
      _showAppliedSnack(company);
    } else {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result), backgroundColor: kWarning),
        );
    }
  }

  Future<void> fetchInternships() async {
    if (mounted) setState(() => internships = []);
    try {
      final response = await AuthService().get('/bulk?type=internships');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        if (jsonData['success'] == true) {
          final List<dynamic> dataList = jsonData['data'];
          for (final c in cardAnims.values) c.dispose();
          cardAnims.clear();
          final newList =
          dataList.map((e) => Internship.fromJson(e)).toList();
          for (int i = 0; i < newList.length; i++) {
            final ctrl = AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 460),
            );
            cardAnims[newList[i].id] = ctrl;
            Future.delayed(
                Duration(milliseconds: 60 + i * 60), () {
              if (mounted) ctrl.forward();
            });
          }
          if (mounted) setState(() => internships = newList);
        } else {
          throw Exception('API returned success:false');
        }
      } else {
        throw Exception(
            'Failed to load internships: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching internships: $e');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('Failed to load internships: $e')),
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

  List<Internship> get filtered {
    var list = internships;
    final effectiveType =
        filter.type ?? (tab == 'All' ? null : tab);
    if (effectiveType != null) {
      list = list.where((i) => i.type == effectiveType).toList();
    }
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((i) {
        return i.title.toLowerCase().contains(q) ||
            i.company.toLowerCase().contains(q) ||
            i.location.toLowerCase().contains(q) ||
            i.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }
    final sr = filter.stipendRange;
    if (sr.start > 0 || sr.end < maxStipend) {
      list = list.where((i) {
        if (i.type != 'Paid') return sr.start == 0;
        return i.stipendInt >= sr.start &&
            i.stipendInt <= sr.end;
      }).toList();
    }
    if (filter.selectedLocations.isNotEmpty) {
      list = list
          .where((i) =>
          filter.selectedLocations.contains(i.location))
          .toList();
    }
    if (filter.selectedCompanies.isNotEmpty) {
      list = list
          .where((i) =>
          filter.selectedCompanies.contains(i.company))
          .toList();
    }
    if (filter.selectedRoles.isNotEmpty) {
      list = list
          .where(
              (i) => filter.selectedRoles.contains(i.title))
          .toList();
    }
    return list;
  }

  void _openFilterSheet() async {
    HapticFeedback.selectionClick();
    final result = await showModalBottomSheet<InternFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        current: filter,
        allLocations: allLocations,
        allCompanies: allCompanies,
        allRoles: allRoles,
        maxStipend: maxStipend,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        filter = result;
        if (result.type != null) {
          tab = result.type!;
        } else {
          tab = 'All';
        }
      });
    }
  }

  void _showDetailSheet(Internship intern) {
    final sw = MediaQuery.of(context).size.width;
    final theme = resolveInternTheme(intern.title, intern.company);
    final isPaid = intern.type == 'Paid';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.42,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: kCardBg,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: EdgeInsets.fromLTRB(
                sw * 0.05, 0, sw * 0.05, sw * 0.08),
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(
                      vertical: sw * 0.030),
                  width: sw * 0.10,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InternIconTile(
                    title: intern.title,
                    company: intern.company,
                    size: sw * 0.14,
                  ),
                  SizedBox(width: sw * 0.035),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          intern.title,
                          style: TextStyle(
                            fontSize: sw * 0.045,
                            fontWeight: FontWeight.w800,
                            color: kInk,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: sw * 0.008),
                        Text(
                          intern.company,
                          style: TextStyle(
                            fontSize: sw * 0.033,
                            color: kMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: sw * 0.020),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: sw * 0.033, color: kHint),
                            SizedBox(width: sw * 0.010),
                            Text(
                              intern.location,
                              style: TextStyle(
                                  fontSize: sw * 0.030,
                                  color: kMuted),
                            ),
                            if (intern.remote) ...[
                              SizedBox(width: sw * 0.020),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: sw * 0.020,
                                    vertical: sw * 0.008),
                                decoration: BoxDecoration(
                                  color: kSelectedBg,
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Remote',
                                  style: TextStyle(
                                    fontSize: sw * 0.025,
                                    fontWeight: FontWeight.w700,
                                    color: kPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.05),
              Container(
                padding: EdgeInsets.all(sw * 0.040),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.grad1.withOpacity(0.08),
                      theme.grad2.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: theme.grad1.withOpacity(0.20),
                      width: 1.5),
                ),
                child: Row(
                  children: [
                    _statItem(
                      isPaid
                          ? Icons.monetization_on
                          : Icons.favorite,
                      intern.stipend,
                      'Stipend',
                      sw,
                      iconColor: isPaid
                          ? kSuccess
                          : const Color(0xFF7C3AED),
                    ),
                    _vDivider(),
                    _statItem(Icons.schedule, intern.duration,
                        'Duration', sw),
                    _vDivider(),
                    _statItem(
                        Icons.work_outline, intern.type, 'Type', sw),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.05),
              Text(
                'Internship Details',
                style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w800,
                    color: kInk),
              ),
              SizedBox(height: sw * 0.030),
              Container(
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  children: [
                    _detailRow(Icons.location_on, 'Location',
                        intern.location, sw),
                    _dividerLine(),
                    _detailRow(Icons.schedule, 'Duration',
                        intern.duration, sw),
                    _dividerLine(),
                    _detailRow(Icons.currency_rupee, 'Stipend',
                        intern.stipend, sw),
                    _dividerLine(),
                    _detailRow(Icons.work_outline, 'Type',
                        intern.type, sw),
                    if (intern.remote) ...[
                      _dividerLine(),
                      _detailRow(Icons.wifi, 'Mode',
                          'Remote — work from anywhere', sw),
                    ],
                  ],
                ),
              ),
              if (intern.tags.isNotEmpty) ...[
                SizedBox(height: sw * 0.05),
                Text(
                  'Skills Required',
                  style: TextStyle(
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w800,
                      color: kInk),
                ),
                SizedBox(height: sw * 0.025),
                Wrap(
                  spacing: sw * 0.020,
                  runSpacing: sw * 0.020,
                  children: intern.tags
                      .map((t) => Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.030,
                        vertical: sw * 0.015),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.grad1.withOpacity(0.10),
                          theme.grad2.withOpacity(0.06),
                        ],
                      ),
                      borderRadius:
                      BorderRadius.circular(20),
                      border: Border.all(
                          color: theme.grad1
                              .withOpacity(0.25)),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: sw * 0.030,
                        fontWeight: FontWeight.w700,
                        color: theme.grad1,
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ],
              SizedBox(height: sw * 0.05),
              Text(
                'About the Role',
                style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w800,
                    color: kInk),
              ),
              SizedBox(height: sw * 0.025),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(sw * 0.035),
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Text(
                  intern.desc,
                  style: TextStyle(
                      fontSize: sw * 0.033,
                      color: kSlate,
                      height: 1.6),
                ),
              ),
              SizedBox(height: sw * 0.05),
              Text(
                'About the Company',
                style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w800,
                    color: kInk),
              ),
              SizedBox(height: sw * 0.025),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(sw * 0.035),
                decoration: BoxDecoration(
                  color: kBgPage,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InternIconTile(
                        title: intern.title,
                        company: intern.company,
                        size: sw * 0.10),
                    SizedBox(width: sw * 0.030),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            intern.company,
                            style: TextStyle(
                                fontSize: sw * 0.035,
                                fontWeight: FontWeight.w800,
                                color: kInk),
                          ),
                          SizedBox(height: sw * 0.010),
                          Text(
                            'This internship is offered by ${intern.company}. '
                                'Location: ${intern.location}. '
                                '${intern.remote ? 'This is a fully remote opportunity.' : ''}',
                            style: TextStyle(
                                fontSize: sw * 0.030,
                                color: kMuted,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.06),
              applied.contains(intern.id)
                  ? Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    vertical: sw * 0.035),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF86EFAC),
                      width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: kSuccess, size: sw * 0.045),
                    SizedBox(width: sw * 0.020),
                    Text(
                      'Application Submitted',
                      style: TextStyle(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w800,
                        color: kSuccess,
                      ),
                    ),
                  ],
                ),
              )
                  : GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await handleApply(
                      intern.id, intern.company);
                  _showApplyDialog(intern);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      vertical: sw * 0.038),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.grad1, theme.grad2],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius:
                    BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                        theme.grad1.withOpacity(0.30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send,
                          color: Colors.white,
                          size: sw * 0.040),
                      SizedBox(width: sw * 0.020),
                      Text(
                        'Apply for this Internship',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: sw * 0.038,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label,
      double sw,
      {Color iconColor = kPrimary}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: sw * 0.040, color: iconColor),
          SizedBox(height: sw * 0.012),
          Text(value,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  fontSize: sw * 0.030,
                  fontWeight: FontWeight.w800,
                  color: kInk)),
          Text(label,
              style:
              TextStyle(fontSize: sw * 0.025, color: kMuted)),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 36, color: kBorder);

  Widget _detailRow(
      IconData icon, String label, String value, double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.035, vertical: sw * 0.028),
      child: Row(
        children: [
          Container(
            width: sw * 0.070,
            height: sw * 0.070,
            decoration: BoxDecoration(
              color: kSelectedBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
            Icon(icon, size: sw * 0.035, color: kPrimary),
          ),
          SizedBox(width: sw * 0.025),
          Text(label,
              style: TextStyle(
                  fontSize: sw * 0.030,
                  color: kMuted,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: sw * 0.033,
                    fontWeight: FontWeight.w800,
                    color: kInk)),
          ),
        ],
      ),
    );
  }

  Widget _dividerLine() => Container(
    height: 1,
    color: const Color(0xFFF1F5F9),
    margin: const EdgeInsets.symmetric(horizontal: 14),
  );

  void _showApplyDialog(Internship intern) {
    final sw = MediaQuery.of(context).size.width;
    final theme =
    resolveInternTheme(intern.title, intern.company);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(sw * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: sw * 0.13,
                    height: sw * 0.13,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [theme.grad1, theme.grad2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color:
                            theme.grad1.withOpacity(0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: Icon(theme.icon,
                        color: Colors.white, size: sw * 0.065),
                  ),
                  SizedBox(width: sw * 0.035),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(intern.title,
                            style: TextStyle(
                                fontSize: sw * 0.040,
                                fontWeight: FontWeight.w800,
                                color: kInk)),
                        SizedBox(height: sw * 0.005),
                        Text(intern.company,
                            style: TextStyle(
                                fontSize: sw * 0.030,
                                color: kMuted,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: sw * 0.035),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(sw * 0.030),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF86EFAC), width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: kSuccess, size: sw * 0.045),
                    SizedBox(width: sw * 0.025),
                    Flexible(
                      child: Text(
                        'Application submitted successfully!',
                        style: TextStyle(
                          fontSize: sw * 0.033,
                          fontWeight: FontWeight.w700,
                          color: kSuccess,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sw * 0.040),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding:
                  EdgeInsets.symmetric(vertical: sw * 0.035),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [theme.grad1, theme.grad2],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: theme.grad1.withOpacity(0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Center(
                    child: Text('Got it!',
                        style: TextStyle(
                            fontSize: sw * 0.038,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppliedSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(message,
                style: const TextStyle(
                    fontWeight: FontWeight.w700)),
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

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final paidCount =
        internships.where((i) => i.type == 'Paid').length;
    final unpaidCount =
        internships.where((i) => i.type == 'Unpaid').length;
    final hasActiveFilter = filter.hasActiveFilters;

    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          // ── HEADER ──
          AnimatedBuilder(
            animation: headerAnim,
            builder: (_, child) =>
                Opacity(opacity: headerAnim.value, child: child),
            child: Container(
              color: kInk,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(sw * 0.05,
                      sw * 0.035, sw * 0.05, sw * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // ✅ Back button only shown when there is a route to pop to
                          if (context.canPop() || widget.onBack != null) ...[
                            GestureDetector(
                              onTap: _handleBack,
                              child: Container(
                                width: sw * 0.09,
                                height: sw * 0.09,
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.10),
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: sw * 0.040),
                              ),
                            ),
                            SizedBox(width: sw * 0.035),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Internships',
                                  style: TextStyle(
                                    fontSize: sw * 0.050,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                Text(
                                  'Real experience, real growth',
                                  style: TextStyle(
                                    fontSize: sw * 0.030,
                                    color: Colors.white
                                        .withOpacity(0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (saved.isNotEmpty)
                            AnimatedContainer(
                              duration:
                              const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.030,
                                  vertical: sw * 0.015),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.12),
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bookmark,
                                      color: kAccent,
                                      size: sw * 0.033),
                                  SizedBox(width: sw * 0.010),
                                  Text(
                                    '${saved.length} Saved',
                                    style: TextStyle(
                                      fontSize: sw * 0.030,
                                      fontWeight: FontWeight.w700,
                                      color: kAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: sw * 0.04),
                      Wrap(
                        spacing: sw * 0.025,
                        runSpacing: sw * 0.015,
                        children: [
                          _statPill(Icons.work_outline,
                              '${internships.length}', 'Total', sw),
                          _statPill(Icons.currency_rupee,
                              '$paidCount', 'Paid', sw),
                          _statPill(Icons.volunteer_activism,
                              '$unpaidCount', 'Unpaid', sw),
                          _statPill(
                            Icons.trending_up,
                            internships.isEmpty
                                ? '0'
                                : '${internships.map((e) => int.tryParse(e.stipend.replaceAll(',', '')) ?? 0).reduce((a, b) => a > b ? a : b)}',
                            'Max',
                            sw,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── SEARCH BAR + FILTER BUTTON ──
          Container(
            color: kCardBg,
            padding: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.028,
                sw * 0.04, sw * 0.028),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: sw * 0.118,
                    decoration: BoxDecoration(
                      color: kBgPage,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _searchFocus.hasFocus
                            ? kPrimary
                            : kBorder,
                        width: _searchFocus.hasFocus ? 2 : 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      onChanged: (v) =>
                          setState(() => search = v),
                      style: TextStyle(
                        fontSize: sw * 0.034,
                        fontWeight: FontWeight.w600,
                        color: kInk,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search role, company, city…',
                        hintStyle: TextStyle(
                            fontSize: sw * 0.032, color: kHint),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: search.isNotEmpty
                                ? kPrimary
                                : kMuted,
                            size: sw * 0.048),
                        suffixIcon: search.isNotEmpty
                            ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => search = '');
                            _searchFocus.unfocus();
                          },
                          child: Icon(Icons.close_rounded,
                              color: kMuted,
                              size: sw * 0.040),
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: sw * 0.01,
                            vertical: sw * 0.033),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.025),
                GestureDetector(
                  onTap: _openFilterSheet,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    width: sw * 0.118,
                    height: sw * 0.118,
                    decoration: BoxDecoration(
                      gradient: hasActiveFilter
                          ? const LinearGradient(
                        colors: [kPrimary, Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      color: hasActiveFilter ? null : kBgPage,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasActiveFilter ? kPrimary : kBorder,
                        width: hasActiveFilter ? 2 : 1.5,
                      ),
                      boxShadow: hasActiveFilter
                          ? [
                        BoxShadow(
                          color: kPrimary.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ]
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: hasActiveFilter
                              ? Colors.white
                              : kMuted,
                          size: sw * 0.048,
                        ),
                        if (filter.activeCount > 0)
                          Positioned(
                            top: sw * 0.015,
                            right: sw * 0.015,
                            child: Container(
                              width: sw * 0.038,
                              height: sw * 0.038,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${filter.activeCount}',
                                  style: TextStyle(
                                    fontSize: sw * 0.022,
                                    fontWeight: FontWeight.w900,
                                    color: kPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── ACTIVE FILTER CHIPS ──
          if (filter.hasActiveFilters)
            Container(
              color: kCardBg,
              height: sw * 0.10,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04,
                    vertical: sw * 0.012),
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      filter = InternFilter();
                      tab = 'All';
                    }),
                    child: Container(
                      margin:
                      EdgeInsets.only(right: sw * 0.018),
                      padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.030,
                          vertical: sw * 0.010),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFFCA5A5),
                            width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear_all_rounded,
                              size: sw * 0.030,
                              color: const Color(0xFFDC2626)),
                          SizedBox(width: sw * 0.010),
                          Text(
                            'Clear All',
                            style: TextStyle(
                              fontSize: sw * 0.028,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (filter.type != null)
                    _activeChip(
                        filter.type!,
                        Icons.work_rounded,
                            () => setState(() => filter =
                            filter.copyWith(clearType: true)),
                        sw),
                  if (filter.stipendRange.start > 0 ||
                      filter.stipendRange.end < maxStipend)
                    _activeChip(
                      '₹${_fmtNum(filter.stipendRange.start.toInt())} – ₹${_fmtNum(filter.stipendRange.end.toInt())}',
                      Icons.currency_rupee,
                          () => setState(() => filter = filter.copyWith(
                          stipendRange:
                          RangeValues(0, maxStipend))),
                      sw,
                    ),
                  ...filter.selectedLocations.map((l) =>
                      _activeChip(
                        l,
                        Icons.location_on,
                            () => setState(() {
                          final s = Set<String>.from(
                              filter.selectedLocations)
                            ..remove(l);
                          filter = filter.copyWith(
                              selectedLocations: s);
                        }),
                        sw,
                      )),
                  ...filter.selectedCompanies.map((c) =>
                      _activeChip(
                        c,
                        Icons.business,
                            () => setState(() {
                          final s = Set<String>.from(
                              filter.selectedCompanies)
                            ..remove(c);
                          filter = filter.copyWith(
                              selectedCompanies: s);
                        }),
                        sw,
                      )),
                  ...filter.selectedRoles.map((r) => _activeChip(
                    r,
                    Icons.work_outline,
                        () => setState(() {
                      final s = Set<String>.from(
                          filter.selectedRoles)
                        ..remove(r);
                      filter =
                          filter.copyWith(selectedRoles: s);
                    }),
                    sw,
                  )),
                ],
              ),
            ),

          // ── TAB SWITCHER ──
          Container(
            color: kCardBg,
            padding: EdgeInsets.fromLTRB(sw * 0.04, sw * 0.018,
                sw * 0.04, sw * 0.022),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(sw * 0.010),
                  decoration: BoxDecoration(
                    color: kBgPage,
                    borderRadius: BorderRadius.circular(14),
                    border:
                    Border.all(color: kBorder, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: kTabs.map((t) {
                      final active = tab == t;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            tab = t;
                            if (t == 'All') {
                              filter = filter.copyWith(
                                  clearType: true);
                            } else {
                              filter =
                                  filter.copyWith(type: t);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 240),
                          padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.040,
                              vertical: sw * 0.018),
                          decoration: BoxDecoration(
                            color: active
                                ? kPrimary
                                : Colors.transparent,
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontSize: sw * 0.033,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Colors.white
                                  : kMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.030,
                      vertical: sw * 0.015),
                  decoration: BoxDecoration(
                    color: hasActiveFilter || search.isNotEmpty
                        ? kSelectedBg
                        : kBgPage,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: hasActiveFilter ||
                            search.isNotEmpty
                            ? kPrimary.withOpacity(0.4)
                            : kBorder),
                  ),
                  child: Text(
                    '${filtered.length} result${filtered.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: sw * 0.030,
                      fontWeight: FontWeight.w700,
                      color: hasActiveFilter ||
                          search.isNotEmpty
                          ? kPrimary
                          : kMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: kBorder),

          // ── LIST ──
          Expanded(
            child: RefreshIndicator(
              color: kPrimary,
              onRefresh: () async {
                await fetchInternships();
                await loadAppliedInternships();
              },
              child: filtered.isEmpty
                  ? ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context)
                        .size
                        .height *
                        0.18,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: sw * 0.18,
                          height: sw * 0.18,
                          decoration: const BoxDecoration(
                            color: kSelectedBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.search_off,
                              color: kPrimary,
                              size: sw * 0.08),
                        ),
                        SizedBox(height: sw * 0.04),
                        Text(
                          'No internships found',
                          style: TextStyle(
                            fontSize: sw * 0.038,
                            fontWeight: FontWeight.w700,
                            color: kSlate,
                          ),
                        ),
                        SizedBox(height: sw * 0.015),
                        Text(
                          search.isNotEmpty
                              ? 'No results for "$search"'
                              : 'Try different filter settings',
                          style: TextStyle(
                              fontSize: sw * 0.030,
                              color: kMuted),
                        ),
                        SizedBox(height: sw * 0.04),
                        GestureDetector(
                          onTap: () => setState(() {
                            tab = 'All';
                            search = '';
                            _searchCtrl.clear();
                            filter = InternFilter();
                          }),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.05,
                                vertical: sw * 0.025),
                            decoration: BoxDecoration(
                              color: kPrimary,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Clear all filters',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: sw * 0.033,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  : ListView.builder(
                padding: EdgeInsets.fromLTRB(sw * 0.04,
                    sw * 0.035, sw * 0.04, sw * 0.06),
                itemCount: filtered.length,
                physics:
                const AlwaysScrollableScrollPhysics(),
                itemBuilder: (_, i) => InternshipCard(
                  internship: filtered[i],
                  sw: sw,
                  isSaved: saved.contains(filtered[i].id),
                  isApplied:
                  applied.contains(filtered[i].id),
                  ctrl: cardAnims[filtered[i].id],
                  onTap: () =>
                      _showDetailSheet(filtered[i]),
                  onSave: () {
                    HapticFeedback.selectionClick();
                    setState(
                          () => saved.contains(filtered[i].id)
                          ? saved.remove(filtered[i].id)
                          : saved.add(filtered[i].id),
                    );
                  },
                  onApply: () => handleApply(
                      filtered[i].id,
                      filtered[i].company),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeChip(String label, IconData icon,
      VoidCallback onRemove, double sw) {
    return Container(
      margin: EdgeInsets.only(right: sw * 0.015),
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.025, vertical: sw * 0.010),
      decoration: BoxDecoration(
        color: kSelectedBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: kPrimary.withOpacity(0.35), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: sw * 0.028, color: kPrimary),
          SizedBox(width: sw * 0.010),
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w700,
              color: kPrimary,
            ),
          ),
          SizedBox(width: sw * 0.010),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: sw * 0.028, color: kPrimary),
          ),
        ],
      ),
    );
  }

  String _fmtNum(int n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return '$n';
  }

  Widget _statPill(
      IconData icon, String num, String label, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.025, vertical: sw * 0.013),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: sw * 0.030, color: kAccent),
          SizedBox(width: sw * 0.010),
          Text(num,
              style: TextStyle(
                  fontSize: sw * 0.030,
                  fontWeight: FontWeight.w800,
                  color: kAccent)),
          SizedBox(width: sw * 0.008),
          Text(label,
              style: TextStyle(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.55))),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  INTERNSHIP CARD
// ═══════════════════════════════════════════
class InternshipCard extends StatefulWidget {
  final Internship internship;
  final double sw;
  final bool isSaved, isApplied;
  final AnimationController? ctrl;
  final VoidCallback onSave, onApply, onTap;

  const InternshipCard({
    required this.internship,
    required this.sw,
    required this.isSaved,
    required this.isApplied,
    required this.onSave,
    required this.onApply,
    required this.onTap,
    this.ctrl,
    super.key,
  });

  @override
  State<InternshipCard> createState() => _InternshipCardState();
}

class _InternshipCardState extends State<InternshipCard>
    with SingleTickerProviderStateMixin {
  bool btnPressed = false;
  late AnimationController btnCtrl;
  late Animation<double> btnScale;

  @override
  void initState() {
    super.initState();
    btnCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 140));
    btnScale = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: btnCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    btnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intern = widget.internship;
    final ctrl = widget.ctrl;

    final fade = ctrl != null
        ? CurvedAnimation(parent: ctrl, curve: Curves.easeOut)
        : const AlwaysStoppedAnimation<double>(1.0);
    final slide = ctrl != null
        ? Tween<Offset>(
        begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: ctrl, curve: Curves.easeOut))
        : const AlwaysStoppedAnimation<Offset>(Offset.zero);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: SocialPostCard(
          postType: 'internship',
          id: intern.id,
          title: intern.title,
          company: intern.company,
          location: intern.location,
          type: intern.type,
          primaryBadge: intern.stipend != 'Unpaid' ? '₹${intern.stipend}/mo' : 'Unpaid',
          secondaryBadge: intern.duration,
          imageUrl: intern.imageUrl,
          companyLogo: intern.companyLogo,
          description: intern.desc,
          tags: intern.tags,
          isSaved: widget.isSaved,
          isApplied: widget.isApplied,
          initialLikesCount: intern.likesCount,
          initialCommentsCount: intern.commentsCount,
          initialSharesCount: intern.sharesCount,
          initialIsLiked: intern.isLiked,
          onSave: widget.onSave,
          onApply: widget.onApply,
          onTap: widget.onTap,
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, double sw) =>
      Container(
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.020, vertical: sw * 0.013),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: sw * 0.030, color: kHint),
            SizedBox(width: sw * 0.010),
            Text(label,
                style: TextStyle(
                    fontSize: sw * 0.028,
                    fontWeight: FontWeight.w700,
                    color: kMuted)),
          ],
        ),
      );

  Widget _matchBadge(int match, double sw) {
    final color = match >= 90
        ? kSuccess
        : match >= 80
        ? kWarning
        : kMuted;
    final bg = match >= 90
        ? const Color(0xFFF0FDF4)
        : match >= 80
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFF1F5F9);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.025, vertical: sw * 0.013),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text('$match% Match',
          style: TextStyle(
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}
