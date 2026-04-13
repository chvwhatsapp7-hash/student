import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
const kRose = Color(0xFFF43F5E);

// ─────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────

class Company {
  final int id;
  final String name;
  final String city;
  final String state;
  final String type;
  final String size;
  final int openings;
  final String domain;
  final String logo;
  final String desc;
  final String website;
  final double lat;
  final double lng;
  final List<String> tags;

  const Company({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.type,
    required this.size,
    required this.openings,
    required this.domain,
    required this.logo,
    required this.desc,
    required this.website,
    required this.lat,
    required this.lng,
    required this.tags,
  });
}

// ─────────────────────────────────────────────
//  STATIC FALLBACK DATA
// ─────────────────────────────────────────────

final List<Company> kCompanies = [
  const Company(
    id: 1,
    name: 'Infosys',
    city: 'Bengaluru',
    state: 'Karnataka',
    type: 'MNC',
    size: '300K+ employees',
    openings: 45,
    domain: 'IT Services',
    logo: '🔵',
    desc:
    'Global leader in digital services, consulting, and next-gen IT solutions for enterprises worldwide.',
    website: 'infosys.com',
    lat: 12.97,
    lng: 77.59,
    tags: ['Java', 'Cloud', 'SAP', 'AI/ML'],
  ),
  const Company(
    id: 2,
    name: 'Flipkart',
    city: 'Bengaluru',
    state: 'Karnataka',
    type: 'Unicorn',
    size: '30K+ employees',
    openings: 28,
    domain: 'E-Commerce',
    logo: '🟡',
    desc:
    "India's largest e-commerce marketplace, building the future of retail with cutting-edge tech.",
    website: 'flipkart.com',
    lat: 12.95,
    lng: 77.67,
    tags: ['React', 'Scala', 'Big Data', 'SDE'],
  ),
  const Company(
    id: 3,
    name: 'Zepto',
    city: 'Mumbai',
    state: 'Maharashtra',
    type: 'Startup',
    size: '3K+ employees',
    openings: 12,
    domain: 'Quick Commerce',
    logo: '⚡',
    desc:
    'Pioneering 10-minute grocery delivery across India with a tech-first logistics platform.',
    website: 'zepto.com',
    lat: 19.07,
    lng: 72.87,
    tags: ['Node.js', 'React Native', 'DevOps'],
  ),
  const Company(
    id: 4,
    name: 'ISRO',
    city: 'Bengaluru',
    state: 'Karnataka',
    type: 'Government',
    size: '16K+ employees',
    openings: 8,
    domain: 'Space & Research',
    logo: '🚀',
    desc:
    "India's national space research organisation, pushing boundaries in aerospace and satellite tech.",
    website: 'isro.gov.in',
    lat: 13.02,
    lng: 77.57,
    tags: ['C/C++', 'Embedded', 'VLSI', 'Aerospace'],
  ),
  const Company(
    id: 5,
    name: 'Razorpay',
    city: 'Bengaluru',
    state: 'Karnataka',
    type: 'Unicorn',
    size: '2.5K+ employees',
    openings: 18,
    domain: 'Fintech',
    logo: '💙',
    desc:
    'Full-stack financial solutions powering payments, banking, and payroll for 8M+ businesses.',
    website: 'razorpay.com',
    lat: 12.93,
    lng: 77.62,
    tags: ['Go', 'Python', 'Fintech', 'Backend'],
  ),
  const Company(
    id: 6,
    name: 'Ola Electric',
    city: 'Bengaluru',
    state: 'Karnataka',
    type: 'Startup',
    size: '4K+ employees',
    openings: 22,
    domain: 'EV / Clean Tech',
    logo: '🟢',
    desc:
    'Building the future of sustainable mobility with electric vehicles and clean energy solutions.',
    website: 'olaelectric.com',
    lat: 12.91,
    lng: 77.64,
    tags: ['Embedded', 'IoT', 'React', 'Python'],
  ),
];

const List<String> kFilters = [
  'All',
  'MNC',
  'Startup',
  'Unicorn',
  'Government',
];

class _TypeStyle {
  final Color bg, fg;
  const _TypeStyle({required this.bg, required this.fg});
}

const Map<String, _TypeStyle> _typeStyles = {
  'MNC': _TypeStyle(bg: Color(0xFFEFF6FF), fg: Color(0xFF1D4ED8)),
  'Startup': _TypeStyle(bg: Color(0xFFFFF7ED), fg: Color(0xFFC2410C)),
  'Unicorn': _TypeStyle(bg: Color(0xFFF5F3FF), fg: Color(0xFF6D28D9)),
  'Government': _TypeStyle(bg: Color(0xFFF0FDF4), fg: Color(0xFF15803D)),
};

_TypeStyle _style(String type) =>
    _typeStyles[type] ??
        const _TypeStyle(bg: Color(0xFFF1F5F9), fg: Color(0xFF475569));

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen>
    with TickerProviderStateMixin {
  int? _selected;
  String _view = 'list';
  String _filter = 'All';
  String _search = '';
  bool _isLoading = false;

  late AnimationController _headerAnim;
  final Map<int, AnimationController> _cardAnims = {};

  List<Company> _apiCompanies = [];

  List<Company> get _filtered {
    var list = _filter == 'All'
        ? _apiCompanies
        : _apiCompanies.where((c) => c.type == _filter).toList();

    if (_search.isNotEmpty) {
      list = list.where((c) {
        return c.name.toLowerCase().contains(_search.toLowerCase()) ||
            c.domain.toLowerCase().contains(_search.toLowerCase()) ||
            c.city.toLowerCase().contains(_search.toLowerCase());
      }).toList();
    }

    return list;
  }

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _initCardAnims();
    _fetchCompanies();
  }

  void _initCardAnims() {
    _cardAnims.clear();
    for (int i = 0; i < _apiCompanies.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      );
      _cardAnims[_apiCompanies[i].id] = ctrl;
      Future.delayed(Duration(milliseconds: 80 + i * 80), () {
        if (mounted) ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    for (final c in _cardAnims.values) c.dispose();
    super.dispose();
  }

  // ── FIX: use _apiCompanies, not kCompanies ──
  void _selectCompany(int id) {
    HapticFeedback.selectionClick();
    setState(() => _selected = id);
    final company = _apiCompanies.firstWhere(
          (c) => c.id == id,
      orElse: () => _apiCompanies.first,
    );
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            FadeTransition(
              opacity: animation,
              child: CompanyDetailScreen(company: company),
            ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => setState(() => _selected = null));
  }

  // ── API FETCH ─────────────────────────────

  Future<void> _fetchCompanies() async {
    setState(() => _isLoading = true);
    try {
      final response = await AuthService().get('/bulk?type=companies');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;

        if (jsonData['success'] == true) {
          final List<dynamic> dataList = jsonData['data'];

          final apiList = dataList.map((e) {
            final location = e['location'] ?? '';

            return Company(
              id: e['company_id'] ?? 0,
              name: e['name'] ?? '',
              city: location.contains(',')
                  ? location.split(',').first
                  : location,
              state: location.contains(',') ? location.split(',').last : '',
              type: e['industry'] ?? '',
              size: e['company_size'] ?? '',
              openings: 0,
              domain: e['industry'] ?? '',
              logo: '🏢',
              desc: e['description'] ?? '',
              website: e['website'] ?? '',
              lat: 0,
              lng: 0,
              tags: [],
            );
          }).toList();

          if (mounted) {
            setState(() {
              _apiCompanies = apiList;
              _isLoading = false;
            });
            _initCardAnims();
          }
        } else {
          throw Exception('API returned success=false');
        }
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - Invalid or expired token");
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load companies: $e')),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _view == 'list'
                ? _buildList()
                : _buildMapPlaceholder(),
          ),
        ],
      ),
    );
  }

  // ── LOADING STATE ──────────────────────────

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: 4,
      itemBuilder: (_, __) => _SkeletonCard(),
    );
  }

  // ── HEADER ─────────────────────────────────

  Widget _buildHeader() {
    final total = _apiCompanies.length;
    final openings = _apiCompanies.fold(0, (s, c) => s + c.openings);
    final cities = _apiCompanies.map((c) => c.city).toSet().length;

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
                            'Companies',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Discover where you want to work',
                            style: TextStyle(fontSize: 12, color: kHint),
                          ),
                        ],
                      ),
                    ),
                    // Refresh button
                    GestureDetector(
                      onTap: _fetchCompanies,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats row — driven by live API data
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _statPill(
                      Icons.business_rounded,
                      '$total',
                      'Companies',
                    ),
                    _statPill(
                      Icons.work_rounded,
                      openings > 0 ? '$openings' : '—',
                      'Open Roles',
                    ),
                    _statPill(
                      Icons.location_city_rounded,
                      cities > 0 ? '$cities' : '—',
                      'Cities',
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

  // ── SEARCH BAR ─────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: TextField(
        onChanged: (val) => setState(() => _search = val),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: kInk,
        ),
        decoration: InputDecoration(
          hintText: 'Search by company, domain or city…',
          hintStyle: const TextStyle(fontSize: 13, color: kHint),
          prefixIcon: const Icon(
            Icons.corporate_fare_rounded,
            color: kMuted,
            size: 20,
          ),
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
    );
  }

  // ── FILTER BAR ─────────────────────────────

  Widget _buildFilterBar() {
    return Container(
      color: kCardBg,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: kFilters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final f = kFilters[i];
            final selected = f == _filter;
            return GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: selected ? kPrimary : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected ? kPrimary : kBorder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    f,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : kMuted,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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
            const Text(
              'No companies found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kSlate,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() {
                _search = '';
                _filter = 'All';
              }),
              child: const Text(
                'Clear filters',
                style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final c = list[i];
        final ctrl = _cardAnims[c.id];
        final fade = ctrl != null
            ? CurvedAnimation(parent: ctrl, curve: Curves.easeOut)
            : const AlwaysStoppedAnimation<double>(1.0);
        final slide = ctrl != null
            ? Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut))
            : const AlwaysStoppedAnimation<Offset>(Offset.zero);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: _CompanyCard(
              company: c,
              isSelected: _selected == c.id,
              onTap: () => _selectCompany(c.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapPlaceholder() {
    return const Center(
      child: Text('Map view coming soon…', style: TextStyle(color: kMuted)),
    );
  }
}

// ─────────────────────────────────────────────
//  SKELETON CARD (loading placeholder)
// ─────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _box(double w, double h, {double r = 8}) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          color: Color.lerp(
            const Color(0xFFE2E8F0),
            const Color(0xFFF1F5F9),
            _anim.value,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _box(50, 50, r: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(140, 14),
                    const SizedBox(height: 8),
                    _box(100, 11),
                    const SizedBox(height: 6),
                    _box(80, 11),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _box(double.infinity, 1, r: 2),
          const SizedBox(height: 14),
          Row(
            children: [
              _box(90, 28, r: 8),
              const SizedBox(width: 8),
              _box(110, 28, r: 8),
              const SizedBox(width: 8),
              _box(70, 28, r: 8),
            ],
          ),
          const SizedBox(height: 12),
          _box(double.infinity, 40, r: 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COMPANY CARD
// ─────────────────────────────────────────────

class _CompanyCard extends StatelessWidget {
  final Company company;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompanyCard({
    required this.company,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = company;
    final ts = _style(c.type);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? kPrimary : kBorder,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: kPrimary.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP ROW: logo + name + type ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CompanyLogo(name: c.name, size: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: kInk,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: ts.bg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              c.type,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: ts.fg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: kRose,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${c.city}${c.state.isNotEmpty ? ', ${c.state.trim()}' : ''}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.category_rounded,
                            size: 13,
                            color: kPrimary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              c.domain,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kMuted,
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

            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // ── META CHIPS ──
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (c.size.isNotEmpty)
                  _metaChip(icon: Icons.groups_2_rounded, label: c.size),
                if (c.website.isNotEmpty)
                  _metaChip(icon: Icons.public_rounded, label: c.website),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: kSelectedBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kPrimary.withOpacity(0.20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 13, color: kPrimary),
                      const SizedBox(width: 4),
                      Text(
                        c.openings > 0 ? '${c.openings} openings' : 'Hiring',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── SKILL TAGS ──
            if (c.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: c.tags
                    .map(
                      (t) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kBorder),
                    ),
                    child: Text(
                      t,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kSlate,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ],

            const SizedBox(height: 12),

            // ── VIEW DETAILS BUTTON ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                )
                    : null,
                color: isSelected ? null : kSelectedBg,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? null : Border.all(color: kBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 15,
                    color: isSelected ? Colors.white : kPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'View Full Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : kPrimary,
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

  Widget _metaChip({required IconData icon, required String label}) {
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
          Icon(icon, size: 12, color: kMuted),
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

// ─────────────────────────────────────────────
//  COMPANY DETAIL SCREEN  (full-page push)
// ─────────────────────────────────────────────

class CompanyDetailScreen extends StatelessWidget {
  final Company company;

  const CompanyDetailScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final c = company;
    final ts = _style(c.type);
    final colors = _CompanyLogo._colorsFor(c.name);

    return Scaffold(
      backgroundColor: kBgPage,
      body: CustomScrollView(
        slivers: [
          // ── SLIVER APP BAR with gradient ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: colors[0],
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors[0], colors[1]],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Large logo
                        _CompanyLogo(name: c.name, size: 72),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.domain,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.75),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            c.type,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── BODY CONTENT ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── QUICK STATS ROW ──
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          icon: Icons.groups_2_rounded,
                          label: 'Team Size',
                          value: c.size.isNotEmpty ? c.size : '—',
                          iconColor: kPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard(
                          icon: Icons.bolt_rounded,
                          label: 'Openings',
                          value: c.openings > 0 ? '${c.openings}' : 'Hiring',
                          iconColor: kSuccess,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard(
                          icon: Icons.location_city_rounded,
                          label: 'City',
                          value: c.city.isNotEmpty ? c.city : '—',
                          iconColor: kRose,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── ABOUT ──
                  if (c.desc.isNotEmpty) ...[
                    _sectionHeader('About', Icons.info_outline_rounded),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kCardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: Text(
                        c.desc,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: kSlate,
                          height: 1.65,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── COMPANY INFO ──
                  _sectionHeader('Company Info', Icons.business_rounded),
                  const SizedBox(height: 10),
                  _infoCard([
                    if (c.size.isNotEmpty)
                      _InfoRow(
                        icon: Icons.groups_2_rounded,
                        label: 'Team Size',
                        value: c.size,
                      ),
                    if (c.domain.isNotEmpty)
                      _InfoRow(
                        icon: Icons.category_rounded,
                        label: 'Industry',
                        value: c.domain,
                      ),
                    if (c.type.isNotEmpty)
                      _InfoRow(
                        icon: Icons.corporate_fare_rounded,
                        label: 'Company Type',
                        value: c.type,
                        valueColor: ts.fg,
                      ),
                    if (c.city.isNotEmpty)
                      _InfoRow(
                        icon: Icons.location_on_rounded,
                        label: 'Location',
                        value:
                        '${c.city}${c.state.isNotEmpty ? ', ${c.state.trim()}' : ''}',
                      ),
                    if (c.website.isNotEmpty)
                      _InfoRow(
                        icon: Icons.public_rounded,
                        label: 'Website',
                        value: c.website,
                        valueColor: kPrimary,
                        isLast: true,
                      ),
                  ]),

                  const SizedBox(height: 20),

                  // ── SKILLS ──
                  if (c.tags.isNotEmpty) ...[
                    _sectionHeader(
                      'Required Skills',
                      Icons.code_rounded,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kCardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: c.tags.map((t) => _skillChip(t)).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── PERKS placeholder section ──
                  _sectionHeader('Why Join Us?', Icons.star_rounded),
                  const SizedBox(height: 10),
                  _perksCard(c),

                  const SizedBox(height: 28),

                  // ── CTA BUTTONS ──
                  Row(
                    children: [
                      Expanded(
                        child: _outlineButton(
                          icon: Icons.public_rounded,
                          label: 'Website',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _primaryButton(
                          icon: Icons.work_history_rounded,
                          label: c.openings > 0
                              ? 'View ${c.openings} Open Roles'
                              : 'View Open Roles',
                          onTap: () {},
                          colors: colors,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ────────────────────────────────

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: kSelectedBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: kPrimary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: kInk,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: kInk,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: kMuted),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(children: rows),
    );
  }

  Widget _skillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: kSelectedBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kPrimary.withOpacity(0.20)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: kPrimary,
        ),
      ),
    );
  }

  Widget _perksCard(Company c) {
    // Build context-aware perks from available data
    final perks = <Map<String, dynamic>>[];

    if (c.size.isNotEmpty) {
      perks.add({
        'icon': Icons.groups_2_rounded,
        'title': 'Large Team',
        'sub': 'Collaborate with ${c.size}',
      });
    }

    perks.add({
      'icon': Icons.trending_up_rounded,
      'title': 'Career Growth',
      'sub': 'Fast-track your career in ${c.domain}',
    });

    perks.add({
      'icon': Icons.lightbulb_rounded,
      'title': 'Innovation First',
      'sub': 'Work on cutting-edge projects',
    });

    if (c.openings > 0) {
      perks.add({
        'icon': Icons.bolt_rounded,
        'title': 'Actively Hiring',
        'sub': '${c.openings} open positions available',
      });
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: perks.asMap().entries.map((entry) {
          final p = entry.value;
          final isLast = entry.key == perks.length - 1;
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: kSelectedBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      p['icon'] as IconData,
                      size: 18,
                      color: kPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['title'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kInk,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          p['sub'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: kSuccess,
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 12),
                Container(height: 1, color: const Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _outlineButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: kPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required List<Color> colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  INFO ROW (used inside detail screen)
// ─────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 16, color: kPrimary),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kMuted,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? kInk,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: const Color(0xFFF1F5F9),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  COMPANY LOGO WIDGET
// ─────────────────────────────────────────────

class _CompanyLogo extends StatelessWidget {
  final String name;
  final double size;

  const _CompanyLogo({required this.name, required this.size});

  static const Map<String, List<Color>> _brandColors = {
    'infosys': [Color(0xFF007CC2), Color(0xFF005A8E)],
    'flipkart': [Color(0xFF2874F0), Color(0xFF1A5DC0)],
    'zepto': [Color(0xFFFF6B35), Color(0xFFE55A2B)],
    'isro': [Color(0xFF0B3D91), Color(0xFFFC3D21)],
    'razorpay': [Color(0xFF2D6BFF), Color(0xFF1A4FCC)],
    'ola electric': [Color(0xFF2ECC71), Color(0xFF1A9E52)],
    'tata': [Color(0xFF003399), Color(0xFF002270)],
    'wipro': [Color(0xFF341053), Color(0xFF1E0830)],
    'google': [Color(0xFF4285F4), Color(0xFF2A6AD4)],
    'microsoft': [Color(0xFF00A4EF), Color(0xFF0078D4)],
    'amazon': [Color(0xFFFF9900), Color(0xFFCC7700)],
    'swiggy': [Color(0xFFFC8019), Color(0xFFD96A10)],
    'zomato': [Color(0xFFE23744), Color(0xFFB82833)],
    'paytm': [Color(0xFF00B9F1), Color(0xFF0090C0)],
  };

  static const List<List<Color>> _fallback = [
    [Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
    [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    [Color(0xFF0D9488), Color(0xFF0F766E)],
    [Color(0xFFDB2777), Color(0xFF9D174D)],
    [Color(0xFFD97706), Color(0xFFB45309)],
    [Color(0xFF059669), Color(0xFF065F46)],
    [Color(0xFFDC2626), Color(0xFF991B1B)],
    [Color(0xFF2563EB), Color(0xFF1D4ED8)],
  ];

  // Static helper so CompanyDetailScreen can access colours too
  static List<Color> _colorsFor(String name) {
    final key = name.toLowerCase();
    for (final entry in _brandColors.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    final idx = (name.isNotEmpty ? name.codeUnitAt(0) : 65) % _fallback.length;
    return _fallback[idx];
  }

  List<Color> _colors() => _colorsFor(name);

  String _initials() {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors();
    final initials = _initials();
    final fontSize = size * 0.34;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.30),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
