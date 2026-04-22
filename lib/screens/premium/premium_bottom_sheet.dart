import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────

const _kInk = Color(0xFF0A0A14);
const _kPrimary = Color(0xFF6366F1);
const _kDeep = Color(0xFF4338CA);
const _kGold = Color(0xFFF59E0B);
const _kMuted = Color(0xFF6B7280);
const _kHint = Color(0xFF9CA3AF);
const _kBorder = Color(0xFFE5E7EB);
const _kFill = Color(0xFFF9FAFB);
const _kSurface = Color(0xFFFFFFFF);

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────

class _Perk {
  final String emoji, title, sub;
  const _Perk(this.emoji, this.title, this.sub);
}

const _perks = [
  _Perk('🚀', 'Unlimited applications', 'No daily caps — all 180+ companies'),
  _Perk('🤖', 'AI resume builder', 'ATS-optimised resumes in minutes'),
  _Perk(
    '⚡',
    'Early hackathon & PPO access',
    '24-hour head start before free users',
  ),
  _Perk(
    '🎯',
    '1-on-1 mentorship sessions',
    '2 industry mentor bookings per month',
  ),
  _Perk(
    '🗺️',
    'Full company map access',
    'Live hiring status across 180+ companies',
  ),
];

// ─────────────────────────────────────────────
//  PUBLIC SHOW HELPER
// ─────────────────────────────────────────────

Future<void> showPremiumSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.60),
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
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          constraints: BoxConstraints(maxHeight: sh * 0.90),
          decoration: const BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 14),
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(sw),
                      _buildOfferChip(sw),
                      _buildPerks(sw),
                      _buildButtons(sw),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom + 24,
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

  // ── Hero ──────────────────────────────────

  Widget _buildHero(double sw) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.all(sw * 0.052),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF4338CA), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Gold crown accent
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.022,
                vertical: sw * 0.010,
              ),
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kGold.withValues(alpha: 0.40)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: _kGold, size: sw * 0.028),
                  SizedBox(width: sw * 0.010),
                  Text(
                    'PREMIUM',
                    style: TextStyle(
                      fontSize: sw * 0.024,
                      fontWeight: FontWeight.w800,
                      color: _kGold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('👑', style: TextStyle(fontSize: sw * 0.085)),
              SizedBox(height: sw * 0.016),
              Text(
                'Unlock NextStep\nPremium',
                style: TextStyle(
                  fontSize: sw * 0.058,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.15,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: sw * 0.014),
              Text(
                'Join 800+ students accelerating\ntheir careers with full access.',
                style: TextStyle(
                  fontSize: sw * 0.029,
                  color: Colors.white.withValues(alpha: 0.70),
                  height: 1.5,
                ),
              ),
              SizedBox(height: sw * 0.028),
              Wrap(
                spacing: sw * 0.016,
                runSpacing: sw * 0.012,
                children:
                    ['Jobs unlocked', 'AI resume', 'Early access', 'Mentorship']
                        .map(
                          (t) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.024,
                              vertical: sw * 0.010,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                fontSize: sw * 0.025,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Offer chip ────────────────────────────

  Widget _buildOfferChip(double sw) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.045, sw * 0.030, 0, 0),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.028,
          vertical: sw * 0.012,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔥', style: TextStyle(fontSize: sw * 0.028)),
            SizedBox(width: sw * 0.012),
            Text(
              'Limited offer — 40% off today only',
              style: TextStyle(
                fontSize: sw * 0.027,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF92400E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Perks ─────────────────────────────────

  Widget _buildPerks(double sw) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.045, sw * 0.028, sw * 0.045, 0),
      child: Column(
        children: _perks
            .asMap()
            .entries
            .map((e) => _perkRow(e.value, e.key, sw))
            .toList(),
      ),
    );
  }

  Widget _perkRow(_Perk p, int idx, double sw) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + idx * 80),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - v)),
          child: child,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: sw * 0.018),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: sw * 0.088,
              height: sw * 0.088,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(p.emoji, style: TextStyle(fontSize: sw * 0.036)),
              ),
            ),
            SizedBox(width: sw * 0.026),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.title,
                          style: TextStyle(
                            fontSize: sw * 0.033,
                            fontWeight: FontWeight.w700,
                            color: _kInk,
                          ),
                        ),
                      ),
                      Container(
                        width: sw * 0.048,
                        height: sw * 0.048,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: _kPrimary,
                          size: sw * 0.026,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sw * 0.005),
                  Text(
                    p.sub,
                    style: TextStyle(
                      fontSize: sw * 0.026,
                      color: _kMuted,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: sw * 0.014),
                  Container(height: 0.5, color: _kBorder),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Buttons ───────────────────────────────

  Widget _buildButtons(double sw) {
    return Padding(
      padding: EdgeInsets.fromLTRB(sw * 0.045, sw * 0.028, sw * 0.045, 0),
      child: Column(
        children: [
          // Primary CTA
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 250));
              if (context.mounted) context.push('/premium/payment');
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: sw * 0.040),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.38),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(sw * 0.010),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: sw * 0.040,
                    ),
                  ),
                  SizedBox(width: sw * 0.016),
                  Text(
                    'View Plans & Get Premium',
                    style: TextStyle(
                      fontSize: sw * 0.036,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: sw * 0.018),

          // Secondary
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: sw * 0.034),
              decoration: BoxDecoration(
                color: _kFill,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _kBorder, width: 1.5),
              ),
              child: Center(
                child: Text(
                  'Remind me later',
                  style: TextStyle(
                    fontSize: sw * 0.033,
                    fontWeight: FontWeight.w700,
                    color: _kMuted,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: sw * 0.014),

          // Tertiary
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: sw * 0.012),
              child: Center(
                child: Text(
                  'No thanks, continue for free',
                  style: TextStyle(
                    fontSize: sw * 0.028,
                    fontWeight: FontWeight.w600,
                    color: _kHint,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
