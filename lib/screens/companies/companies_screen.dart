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
//  STATIC DATA
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
//  COMPANIES SCREEN
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

  late AnimationController _headerAnim;
  final Map<int, AnimationController> _cardAnims = {};

  List<Company> _apiCompanies = [];

  List<Company> get _filtered {
    var list = _filter == 'All'
        ? kCompanies
        : kCompanies.where((c) => c.type == _filter).toList();
    if (_search.isNotEmpty) {
      list = list
          .where(
            (c) =>
                c.name.toLowerCase().contains(_search.toLowerCase()) ||
                c.domain.toLowerCase().contains(_search.toLowerCase()) ||
                c.city.toLowerCase().contains(_search.toLowerCase()),
          )
          .toList();
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
    for (int i = 0; i < kCompanies.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      );
      _cardAnims[kCompanies[i].id] = ctrl;
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

  void _selectCompany(int id) {
    HapticFeedback.selectionClick();
    setState(() => _selected = id);
    _showDetailSheet(kCompanies.firstWhere((c) => c.id == id));
  }

  // ── API FETCH ───────────────────────────────

  Future<void> _fetchCompanies() async {
    try {
      final response = await http.get(
        Uri.parse('https://studenthub-backend-woad.vercel.app/api/companies'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final List<dynamic> dataList = jsonData['data'];
          final apiList = dataList
              .map(
                (e) => Company(
                  id: e['company_id'] ?? 0,
                  name: e['name'] ?? '',
                  city: e['location']?.split(',').first ?? '',
                  state: e['location']?.split(',').last ?? '',
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
                ),
              )
              .toList();

          setState(() {
            _apiCompanies = apiList;

            // Compare static vs API
            final staticNames = kCompanies
                .map((e) => e.name.toLowerCase())
                .toList();
            final apiNames = _apiCompanies
                .map((e) => e.name.toLowerCase())
                .toList();

            final missingInApi = kCompanies
                .where((c) => !apiNames.contains(c.name.toLowerCase()))
                .toList();
            final missingInStatic = _apiCompanies
                .where((c) => !staticNames.contains(c.name.toLowerCase()))
                .toList();

            debugPrint(
              'Missing in API: ${missingInApi.map((e) => e.name).toList()}',
            );
            debugPrint(
              'Missing in static: ${missingInStatic.map((e) => e.name).toList()}',
            );
          });
        } else {
          throw Exception('API returned success=false');
        }
      } else {
        throw Exception('Failed to load companies: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching companies: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load companies: $e')));
    }
  }

  // ─────────────────────────────────────────────
  //  BUILD UI
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
            child: _view == 'list' ? _buildList() : _buildMapPlaceholder(),
          ),
        ],
      ),
    );
  }

  // ── HEADER ──────────────────────────────────
  Widget _buildHeader() {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut),
      axisAlignment: -1.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text(
              'Companies',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(_view == 'list' ? Icons.map : Icons.list),
              onPressed: () =>
                  setState(() => _view = _view == 'list' ? 'map' : 'list'),
            ),
          ],
        ),
      ),
    );
  }

  // ── SEARCH BAR ──────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search companies...',
          filled: true,
          fillColor: kCardBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: (val) => setState(() => _search = val),
      ),
    );
  }

  // ── FILTER BAR ──────────────────────────────
  Widget _buildFilterBar() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final f = kFilters[i];
          final selected = _filter == f;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? kSelectedBg : kCardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? kPrimary : kBorder),
              ),
              child: Text(
                f,
                style: TextStyle(color: selected ? kPrimary : kMuted),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: kFilters.length,
      ),
    );
  }

  // ── COMPANY LIST ────────────────────────────
  Widget _buildList() {
    final list = _filtered;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final c = list[i];
        return FadeTransition(
          opacity:
              _cardAnims[c.id]?.drive(CurveTween(curve: Curves.easeOut)) ??
              kAlwaysCompleteAnim,
          child: _CompanyCard(company: c, onTap: () => _selectCompany(c.id)),
        );
      },
    );
  }

  static final kAlwaysCompleteAnim = AlwaysStoppedAnimation(1.0);

  Widget _buildMapPlaceholder() {
    return const Center(
      child: Text('Map view coming soon...', style: TextStyle(color: kMuted)),
    );
  }

  void _showDetailSheet(Company c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(c.desc),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: c.tags.map((t) => Chip(label: Text(t))).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'Website: ${c.website}',
              style: const TextStyle(color: kPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Company company;
  final VoidCallback onTap;
  const _CompanyCard({required this.company, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final style = _style(company.type);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Text(company.logo, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${company.city}, ${company.state}',
                    style: const TextStyle(color: kMuted),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: style.bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      company.type,
                      style: TextStyle(color: style.fg),
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
}
