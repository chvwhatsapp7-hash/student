import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS  (matches login / landing)
// ─────────────────────────────────────────────

const _kInk      = Color(0xFF0A0F1E);
const _kPrimary  = Color(0xFF1D4ED8);
const _kViolet   = Color(0xFF4F46E5);
const _kMuted    = Color(0xFF64748B);
const _kHint     = Color(0xFF94A3B8);
const _kBorder   = Color(0xFFE2E8F0);
const _kFill     = Color(0xFFF8FAFC);

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────

class _Perk {
  final String emoji, title, sub;
  const _Perk(this.emoji, this.title, this.sub);
}

const _perks = [
  _Perk('🚀', 'Unlimited applications',       'No daily caps — all 180+ companies'),
  _Perk('🤖', 'AI resume builder',            'ATS-optimised resumes in minutes'),
  _Perk('⚡', 'Early hackathon & PPO access', '24-hour head start before free users'),
  _Perk('🎯', '1-on-1 mentorship sessions',   '2 industry mentor bookings per month'),
  _Perk('🗺️', 'Full company map access',      'Live hiring status across 180+ companies'),
];

// ─────────────────────────────────────────────
//  PUBLIC SHOW HELPER
//  Call from anywhere:
//    showPremiumSheet(context);
// ─────────────────────────────────────────────

Future<void> showPremiumSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const PremiumBottomSheet(),
  );
}

// ─────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────

class PremiumBottomSheet extends StatefulWidget {
  const PremiumBottomSheet({super.key});

  @override
  State<PremiumBottomSheet> createState() => _PremiumBottomSheetState();
}

class _PremiumBottomSheetState extends State<PremiumBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
      ..forward();
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          constraints: BoxConstraints(maxHeight: sh * 0.88),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(color: _kBorder, borderRadius: BorderRadius.circular(4)),
              ),

              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroBanner(sw),
                      _buildOfferPill(sw),
                      _buildPerksList(sw),
                      _buildActionButtons(sw),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
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

  // ── Hero gradient banner ───────────────────

  Widget _buildHeroBanner(double sw) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: EdgeInsets.all(sw * 0.055),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(top: -24, right: -24,
              child: Container(width: 110, height: 110,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08)))),
          Positioned(bottom: -28, left: -12,
              child: Container(width: 76, height: 76,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('👑', style: TextStyle(fontSize: sw * 0.090)),
              SizedBox(height: sw * 0.018),
              Text(
                'Unlock NextStep\nPremium',
                style: TextStyle(
                  fontSize: sw * 0.060,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: sw * 0.016),
              Text(
                'Join 800+ students already accelerating\ntheir careers with full premium access.',
                style: TextStyle(
                  fontSize: sw * 0.030,
                  color: Colors.white.withValues(alpha: 0.72),
                  height: 1.5,
                ),
              ),
              SizedBox(height: sw * 0.030),
              Wrap(
                spacing: sw * 0.018,
                runSpacing: sw * 0.014,
                children: ['Jobs unlocked', 'AI resume', 'Early access', 'Mentorship']
                    .map((t) => Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.026, vertical: sw * 0.012),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Text(t,
                      style: TextStyle(fontSize: sw * 0.026,
                          fontWeight: FontWeight.w700, color: Colors.white)),
                ))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Limited-offer pill ─────────────────────

  Widget _buildOfferPill(double sw) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.045, sw * 0.034, 0, 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.030, vertical: sw * 0.014),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF9C3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFDE047)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔥', style: TextStyle(fontSize: sw * 0.030)),
            SizedBox(width: sw * 0.014),
            Text(
              'Limited offer — 40% off today only',
              style: TextStyle(
                fontSize: sw * 0.028,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF854D0E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Perks list ─────────────────────────────

  Widget _buildPerksList(double sw) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.045, sw * 0.030, sw * 0.045, 0),
      child: Column(children: _perks.map((p) => _perkRow(p, sw)).toList()),
    );
  }

  Widget _perkRow(_Perk p, double sw) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.020),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: sw * 0.090, height: sw * 0.090,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(p.emoji, style: TextStyle(fontSize: sw * 0.038))),
          ),
          SizedBox(width: sw * 0.028),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(p.title,
                          style: TextStyle(fontSize: sw * 0.034,
                              fontWeight: FontWeight.w700, color: _kInk)),
                    ),
                    Container(
                      width: sw * 0.050, height: sw * 0.050,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.check_rounded, color: _kViolet, size: sw * 0.028),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.006),
                Text(p.sub,
                    style: TextStyle(fontSize: sw * 0.027, color: _kMuted, height: 1.4)),
                SizedBox(height: sw * 0.016),
                Container(height: 0.5, color: _kBorder),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ─────────────────────────

  Widget _buildActionButtons(double sw) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.045, sw * 0.030, sw * 0.045, 0),
      child: Column(
        children: [
          // 1 — Get Premium (primary)
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 300));
              if (context.mounted) context.push('/premium/payment');
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: sw * 0.042),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kPrimary, _kViolet],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.34),
                    blurRadius: 16, offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: sw * 0.046),
                    SizedBox(width: sw * 0.018),
                    Text('Get Premium — View Plans',
                        style: TextStyle(fontSize: sw * 0.037,
                            fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: sw * 0.020),

          // 2 — Remind me later (secondary)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: sw * 0.036),
              decoration: BoxDecoration(
                color: _kFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kBorder, width: 1.5),
              ),
              child: Center(
                child: Text('Remind me later',
                    style: TextStyle(fontSize: sw * 0.034,
                        fontWeight: FontWeight.w700, color: _kMuted)),
              ),
            ),
          ),
          SizedBox(height: sw * 0.016),

          // 3 — Skip (tertiary)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: sw * 0.014),
              child: Center(
                child: Text('No thanks, continue for free',
                    style: TextStyle(fontSize: sw * 0.029,
                        fontWeight: FontWeight.w600, color: _kHint)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
