import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../api_services/authservice.dart';
import 'premium_helper.dart';

// ─────────────────────────────────────────────
//  TOKENS
// ─────────────────────────────────────────────

const _kBg      = Color(0xFFF5F4FF);
const _kInk     = Color(0xFF0A0A14);
const _kPrimary = Color(0xFF4338CA);
const _kViolet  = Color(0xFF6366F1);
const _kLight   = Color(0xFFEEF2FF);
const _kGold    = Color(0xFFF59E0B);
const _kGreen   = Color(0xFF10B981);
const _kMuted   = Color(0xFF6B7280);
const _kHint    = Color(0xFF9CA3AF);
const _kBorder  = Color(0xFFE5E7EB);
const _kWhite   = Color(0xFFFFFFFF);

// ─────────────────────────────────────────────
//  PLAN MODEL
// ─────────────────────────────────────────────

class _Plan {
  final String id, label, billingNote, priceDisplay, perMonth;
  final int    amountPaise;
  final String? saveBadge;
  final bool    isPopular;
  const _Plan({
    required this.id, required this.label, required this.billingNote,
    required this.priceDisplay, required this.perMonth, required this.amountPaise,
    this.saveBadge, this.isPopular = false,
  });
}

const _plans = [
  _Plan(id: 'monthly',   label: 'Monthly',   billingNote: 'Billed every month',
      priceDisplay: '₹199',   perMonth: '₹199/mo',  amountPaise: 19900),
  _Plan(id: 'quarterly', label: 'Quarterly', billingNote: 'Billed every 3 months',
      priceDisplay: '₹449',   perMonth: '₹150/mo',  amountPaise: 44900,
      saveBadge: 'Save 25%', isPopular: true),
  _Plan(id: 'yearly',    label: 'Yearly',    billingNote: 'Billed annually',
      priceDisplay: '₹1,499', perMonth: '₹125/mo',  amountPaise: 149900,
      saveBadge: 'Save 45%'),
];

// ─────────────────────────────────────────────
//  PAYMENT METHOD
// ─────────────────────────────────────────────

enum _PayMethod { upi, card, netBanking, wallet }

const _methodLabels = {
  _PayMethod.upi:        'UPI',
  _PayMethod.card:       'Card',
  _PayMethod.netBanking: 'Net Banking',
  _PayMethod.wallet:     'Wallets',
};

const _methodIcons = {
  _PayMethod.upi:        Icons.qr_code_rounded,
  _PayMethod.card:       Icons.credit_card_rounded,
  _PayMethod.netBanking: Icons.account_balance_rounded,
  _PayMethod.wallet:     Icons.account_balance_wallet_rounded,
};

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────

class PremiumPaymentScreen extends StatefulWidget {
  const PremiumPaymentScreen({super.key});
  @override
  State<PremiumPaymentScreen> createState() => _PremiumPaymentScreenState();
}

class _PremiumPaymentScreenState extends State<PremiumPaymentScreen>
    with SingleTickerProviderStateMixin {

  int         _selectedPlan   = 1;
  _PayMethod  _selectedMethod = _PayMethod.upi;
  bool        _isLoading      = false;

  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 60), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  // ── Pay action ────────────────────────────

  void _pay() {
    HapticFeedback.mediumImpact();
    if (_selectedMethod == _PayMethod.upi) {
      _showUpiDialog();
    } else {
      // For other methods, simulate payment directly
      _simulatePayment();
    }
  }

  void _simulatePayment() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () async {
      await PremiumHelper.setPremium();
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSuccessDialog();
    });
  }

  // ── UPI dialog ────────────────────────────

  void _showUpiDialog() {
    final upiCtrl = TextEditingController();
    final sw = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          child: Container(
            decoration: BoxDecoration(
              color: _kWhite,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 40, offset: const Offset(0, 16)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top accent bar
                Container(height: 4,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [_kPrimary, _kViolet]),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    )),

                Padding(
                  padding: EdgeInsets.fromLTRB(sw * 0.060, sw * 0.052, sw * 0.060, sw * 0.052),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(children: [
                        Container(
                            padding: EdgeInsets.all(sw * 0.022),
                            decoration: BoxDecoration(color: _kLight, borderRadius: BorderRadius.circular(14)),
                            child: Text('📲', style: TextStyle(fontSize: sw * 0.040))),
                        SizedBox(width: sw * 0.020),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Pay via UPI',
                              style: TextStyle(fontSize: sw * 0.038, fontWeight: FontWeight.w800, color: _kInk)),
                          Text('Instant & secure payment',
                              style: TextStyle(fontSize: sw * 0.026, color: _kMuted)),
                        ])),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                              width: sw * 0.080, height: sw * 0.080,
                              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), shape: BoxShape.circle),
                              child: Icon(Icons.close_rounded, color: _kMuted, size: sw * 0.036)),
                        ),
                      ]),

                      SizedBox(height: sw * 0.034),

                      // Amount summary chip
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(sw * 0.036),
                        decoration: BoxDecoration(
                          color: _kLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _kViolet.withValues(alpha: 0.25)),
                        ),
                        child: Row(children: [
                          Text('👑', style: TextStyle(fontSize: sw * 0.038)),
                          SizedBox(width: sw * 0.018),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${_plans[_selectedPlan].label} Plan',
                                style: TextStyle(fontSize: sw * 0.030, fontWeight: FontWeight.w700, color: _kInk)),
                            Text(_plans[_selectedPlan].billingNote,
                                style: TextStyle(fontSize: sw * 0.024, color: _kMuted)),
                          ])),
                          Text(_plans[_selectedPlan].priceDisplay,
                              style: TextStyle(fontSize: sw * 0.042, fontWeight: FontWeight.w800, color: _kPrimary)),
                        ]),
                      ),

                      SizedBox(height: sw * 0.030),

                      // UPI ID input
                      Text('Your UPI ID',
                          style: TextStyle(fontSize: sw * 0.030, fontWeight: FontWeight.w700, color: _kInk)),
                      SizedBox(height: sw * 0.012),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _kBorder, width: 1.5),
                        ),
                        child: Row(children: [
                          Padding(
                              padding: EdgeInsets.only(left: sw * 0.030),
                              child: Icon(Icons.alternate_email_rounded, color: _kMuted, size: sw * 0.042)),
                          Expanded(
                            child: TextField(
                              controller: upiCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(fontSize: sw * 0.030, fontWeight: FontWeight.w600, color: _kInk),
                              decoration: InputDecoration(
                                hintText: 'yourname@upi',
                                hintStyle: TextStyle(color: _kHint, fontSize: sw * 0.028),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.020, vertical: sw * 0.034),
                              ),
                            ),
                          ),
                        ]),
                      ),

                      SizedBox(height: sw * 0.010),
                      Row(children: [
                        Icon(Icons.info_outline_rounded, size: sw * 0.026, color: _kHint),
                        SizedBox(width: sw * 0.010),
                        Text('e.g. mobilenumber@paytm, name@okaxis',
                            style: TextStyle(fontSize: sw * 0.024, color: _kHint)),
                      ]),

                      SizedBox(height: sw * 0.034),

                      // Pay button inside dialog
                      GestureDetector(
                        onTap: () {
                          if (upiCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Please enter your UPI ID'),
                                backgroundColor: Colors.red.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          _simulatePayment();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: sw * 0.040),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_kPrimary, _kViolet],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: _kPrimary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.lock_rounded, color: Colors.white, size: sw * 0.038),
                            SizedBox(width: sw * 0.016),
                            Text('Pay ${_plans[_selectedPlan].priceDisplay} Securely',
                                style: TextStyle(fontSize: sw * 0.036, fontWeight: FontWeight.w800, color: Colors.white)),
                          ]),
                        ),
                      ),

                      SizedBox(height: sw * 0.022),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.security_rounded, size: sw * 0.024, color: _kHint),
                        SizedBox(width: sw * 0.010),
                        Text('256-bit SSL encrypted · PCI DSS compliant',
                            style: TextStyle(fontSize: sw * 0.024, color: _kHint)),
                      ]),
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

  // ── Success dialog ────────────────────────

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SuccessDialog(),
    ).then((_) {
      if (mounted) context.go('/engineering');
    });
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _kBg,
        body: Column(children: [
          _navBar(sw),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(children: [
                    SizedBox(height: sh * 0.022),
                    _plansSection(sw),
                    SizedBox(height: sh * 0.022),
                    _paymentSection(sw),
                    SizedBox(height: sh * 0.022),
                    _trustRow(sw),
                    SizedBox(height: sh * 0.018),
                    _payButton(sw),
                    SizedBox(height: sh * 0.040),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Nav bar ───────────────────────────────

  Widget _navBar(double sw) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.045, vertical: sw * 0.032),
        child: Row(children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
                width: sw * 0.090, height: sw * 0.090,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: sw * 0.036)),
          ),
          SizedBox(width: sw * 0.026),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Choose Your Plan',
                style: TextStyle(fontSize: sw * 0.040, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: -0.3)),
            Text('Cancel anytime · No hidden fees',
                style: TextStyle(fontSize: sw * 0.025,
                    color: Colors.white.withValues(alpha: 0.65), fontWeight: FontWeight.w600)),
          ])),
          // Crown badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.022, vertical: sw * 0.012),
            decoration: BoxDecoration(
              color: _kGold.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kGold.withValues(alpha: 0.40)),
            ),
            child: Text('👑', style: TextStyle(fontSize: sw * 0.032)),
          ),
        ]),
      ),
    );
  }

  // ── Plans section ─────────────────────────

  Widget _plansSection(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.045),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('SELECT A PLAN', sw),
        SizedBox(height: sw * 0.018),
        ...List.generate(_plans.length, (i) => _planCard(_plans[i], i, sw)),
      ]),
    );
  }

  Widget _planCard(_Plan p, int i, double sw) {
    final sel = _selectedPlan == i;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlan = i);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: EdgeInsets.only(bottom: sw * 0.022),
        padding: EdgeInsets.all(sw * 0.038),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFEEF2FF) : _kWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? _kPrimary : _kBorder,
            width: sel ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: sel ? _kPrimary.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
              blurRadius: sel ? 24 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.isPopular) ...[
              Container(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.022, vertical: sw * 0.008),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_kPrimary, _kViolet]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('⭐ MOST POPULAR',
                      style: TextStyle(fontSize: sw * 0.022, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: 0.5))),
              SizedBox(height: sw * 0.016),
            ],
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.label,
                    style: TextStyle(fontSize: sw * 0.038, fontWeight: FontWeight.w800,
                        color: sel ? _kPrimary : _kInk)),
                SizedBox(height: sw * 0.005),
                Text(p.billingNote,
                    style: TextStyle(fontSize: sw * 0.026, color: _kMuted)),
                if (p.saveBadge != null) ...[
                  SizedBox(height: sw * 0.010),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.018, vertical: sw * 0.007),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(p.saveBadge!,
                          style: TextStyle(fontSize: sw * 0.024, fontWeight: FontWeight.w800,
                              color: const Color(0xFF065F46)))),
                ],
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(p.priceDisplay,
                    style: TextStyle(fontSize: sw * 0.048, fontWeight: FontWeight.w800,
                        color: sel ? _kPrimary : _kInk, letterSpacing: -0.5)),
                Text(p.perMonth,
                    style: TextStyle(fontSize: sw * 0.024, color: _kHint)),
              ]),
              SizedBox(width: sw * 0.022),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: sw * 0.052, height: sw * 0.052,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? _kPrimary : Colors.transparent,
                  border: Border.all(color: sel ? _kPrimary : _kBorder, width: 2),
                ),
                child: sel ? Icon(Icons.check_rounded, color: Colors.white, size: sw * 0.028) : null,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Payment section ───────────────────────

  Widget _paymentSection(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.045),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('PAYMENT METHOD', sw),
        SizedBox(height: sw * 0.018),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(sw * 0.036),
          decoration: BoxDecoration(
            color: _kWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kBorder, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // UPI apps row
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children:
              ['GPay', 'PhonePe', 'Paytm', 'BHIM'].map((app) => _upiAppChip(app, sw)).toList()),

              SizedBox(height: sw * 0.022),
              Divider(color: _kBorder, height: 1),
              SizedBox(height: sw * 0.022),

              // Method tabs
              Row(children: _PayMethod.values.map((m) {
                final sel = _selectedMethod == m;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedMethod = m);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: m != _PayMethod.wallet ? sw * 0.016 : 0),
                      padding: EdgeInsets.symmetric(vertical: sw * 0.020),
                      decoration: BoxDecoration(
                        color: sel ? _kLight : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sel ? _kPrimary : _kBorder, width: sel ? 1.5 : 1),
                      ),
                      child: Column(children: [
                        Icon(_methodIcons[m]!, size: sw * 0.038,
                            color: sel ? _kPrimary : _kMuted),
                        SizedBox(height: sw * 0.006),
                        Text(_methodLabels[m]!,
                            style: TextStyle(fontSize: sw * 0.020, fontWeight: FontWeight.w700,
                                color: sel ? _kPrimary : _kMuted),
                            textAlign: TextAlign.center),
                      ]),
                    ),
                  ),
                );
              }).toList()),

              SizedBox(height: sw * 0.022),
              Divider(color: _kBorder, height: 1),
              SizedBox(height: sw * 0.016),

              // Security footer
              Row(children: [
                Icon(Icons.lock_rounded, size: sw * 0.028, color: _kGreen),
                SizedBox(width: sw * 0.012),
                Expanded(child: Text('256-bit SSL · Razorpay PCI DSS compliant · Instant refunds',
                    style: TextStyle(fontSize: sw * 0.024, color: _kMuted))),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _upiAppChip(String name, double sw) {
    final icons = {'GPay': '🟢', 'PhonePe': '🟣', 'Paytm': '🔵', 'BHIM': '🟠'};
    return Column(children: [
      Container(
          width: sw * 0.120, height: sw * 0.120,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder),
          ),
          child: Center(child: Text(icons[name]!, style: TextStyle(fontSize: sw * 0.040)))),
      SizedBox(height: sw * 0.008),
      Text(name, style: TextStyle(fontSize: sw * 0.022, fontWeight: FontWeight.w600, color: _kMuted)),
    ]);
  }

  // ── Trust row ─────────────────────────────

  Widget _trustRow(double sw) {
    final items = [
      (Icons.cancel_outlined,         '₹0 cancellation'),
      (Icons.autorenew_rounded,        'Cancel anytime'),
      (Icons.verified_user_rounded,    '7-day refund'),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.045),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: sw * 0.028),
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kBorder, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((e) => Column(children: [
            Container(
                padding: EdgeInsets.all(sw * 0.022),
                decoration: BoxDecoration(color: _kLight, shape: BoxShape.circle),
                child: Icon(e.$1, color: _kPrimary, size: sw * 0.040)),
            SizedBox(height: sw * 0.008),
            Text(e.$2,
                style: TextStyle(fontSize: sw * 0.024, fontWeight: FontWeight.w700, color: _kMuted)),
          ])).toList(),
        ),
      ),
    );
  }

  // ── Pay button ────────────────────────────

  Widget _payButton(double sw) {
    final plan = _plans[_selectedPlan];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.045),
      child: Column(children: [
        GestureDetector(
          onTap: _isLoading ? null : _pay,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: sw * 0.042),
            decoration: BoxDecoration(
              gradient: _isLoading
                  ? const LinearGradient(colors: [Color(0xFF9CA3AF), Color(0xFF9CA3AF)])
                  : const LinearGradient(colors: [_kPrimary, _kViolet],
                  begin: Alignment.centerLeft, end: Alignment.centerRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: _isLoading ? [] : [
                BoxShadow(color: _kPrimary.withValues(alpha: 0.38), blurRadius: 20, offset: const Offset(0, 8)),
                BoxShadow(color: _kViolet.withValues(alpha: 0.22), blurRadius: 32, offset: const Offset(0, 14)),
              ],
            ),
            child: Center(
              child: _isLoading
                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                    width: sw * 0.050, height: sw * 0.050,
                    child: const CircularProgressIndicator(strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                SizedBox(width: sw * 0.020),
                Text('Processing…', style: TextStyle(fontSize: sw * 0.034,
                    fontWeight: FontWeight.w700, color: Colors.white)),
              ])
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.lock_rounded, color: Colors.white, size: sw * 0.042),
                SizedBox(width: sw * 0.016),
                Text('Pay ${plan.priceDisplay} · ${_methodLabels[_selectedMethod]}',
                    style: TextStyle(fontSize: sw * 0.036,
                        fontWeight: FontWeight.w800, color: Colors.white)),
              ]),
            ),
          ),
        ),
        SizedBox(height: sw * 0.016),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.lock_outline_rounded, size: sw * 0.026, color: _kHint),
          SizedBox(width: sw * 0.010),
          Text('Encrypted & secure · Cancel anytime',
              style: TextStyle(fontSize: sw * 0.024, color: _kHint)),
        ]),
      ]),
    );
  }

  // ── Helpers ───────────────────────────────

  Widget _sectionLabel(String text, double sw) {
    return Text(text,
        style: TextStyle(fontSize: sw * 0.024, fontWeight: FontWeight.w800,
            color: _kMuted, letterSpacing: 0.9));
  }
}

// ─────────────────────────────────────────────
//  SUCCESS DIALOG WITH CONFETTI
// ─────────────────────────────────────────────

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();
  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with TickerProviderStateMixin {

  late AnimationController _scaleCtrl;
  late AnimationController _confettiCtrl;
  late Animation<double>   _scaleAnim;
  late Animation<double>   _fadeAnim;

  final _random = Random();
  final List<_Confetti> _confettiList = [];

  @override
  void initState() {
    super.initState();

    // Generate confetti particles
    for (int i = 0; i < 40; i++) {
      _confettiList.add(_Confetti(random: _random));
    }

    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));

    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut);

    _scaleCtrl.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _confettiCtrl.forward();
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.06),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main card
              Container(
                decoration: BoxDecoration(
                  color: _kWhite,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 50, offset: const Offset(0, 20)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(height: 5,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [_kPrimary, _kViolet, Color(0xFF8B5CF6)]),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                        )),
                    Padding(
                      padding: EdgeInsets.fromLTRB(sw * 0.060, sw * 0.050, sw * 0.060, sw * 0.050),
                      child: Column(children: [
                        // Crown icon
                        Container(
                            width: sw * 0.200, height: sw * 0.200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: _kViolet.withValues(alpha: 0.25), width: 3),
                              boxShadow: [
                                BoxShadow(color: _kPrimary.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: Center(child: Text('👑',
                                style: TextStyle(fontSize: sw * 0.090)))),

                        SizedBox(height: sw * 0.034),

                        Text('Payment Successful!',
                            style: TextStyle(fontSize: sw * 0.046, fontWeight: FontWeight.w800,
                                color: _kInk, letterSpacing: -0.5)),

                        SizedBox(height: sw * 0.010),

                        Text('Welcome to NextStep Premium 🎉',
                            style: TextStyle(fontSize: sw * 0.030, fontWeight: FontWeight.w700,
                                color: _kViolet)),

                        SizedBox(height: sw * 0.016),

                        Text('All premium features are now unlocked.\nYour career journey just levelled up!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: sw * 0.027, color: _kMuted, height: 1.6)),

                        SizedBox(height: sw * 0.030),

                        // Green success check
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: sw * 0.040, vertical: sw * 0.020),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.check_circle_rounded, color: _kGreen, size: sw * 0.036),
                            SizedBox(width: sw * 0.016),
                            Text('Transaction verified & confirmed',
                                style: TextStyle(fontSize: sw * 0.026, fontWeight: FontWeight.w700,
                                    color: const Color(0xFF065F46))),
                          ]),
                        ),

                        SizedBox(height: sw * 0.036),

                        // CTA
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: sw * 0.038),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_kPrimary, _kViolet],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: _kPrimary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
                              ],
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('🚀', style: TextStyle(fontSize: sw * 0.034)),
                              SizedBox(width: sw * 0.016),
                              Text('Explore Premium Features',
                                  style: TextStyle(fontSize: sw * 0.034,
                                      fontWeight: FontWeight.w800, color: Colors.white)),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),

              // Confetti layer (overlay)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _confettiCtrl,
                    builder: (_, __) {
                      return CustomPaint(
                        painter: _ConfettiPainter(
                          particles: _confettiList,
                          progress: _confettiCtrl.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CONFETTI PAINTER
// ─────────────────────────────────────────────

class _Confetti {
  final double x, startY, size, speed, wobble, rotation, rotSpeed;
  final Color color;

  _Confetti({required Random random})
      : x       = random.nextDouble(),
        startY  = -0.1 - random.nextDouble() * 0.3,
        size    = 6 + random.nextDouble() * 8,
        speed   = 0.4 + random.nextDouble() * 0.6,
        wobble  = random.nextDouble() * 0.08,
        rotation = random.nextDouble() * 2 * 3.14159,
        rotSpeed = (random.nextDouble() - 0.5) * 6,
        color   = [
          const Color(0xFF6366F1),
          const Color(0xFFF59E0B),
          const Color(0xFF10B981),
          const Color(0xFFEF4444),
          const Color(0xFF3B82F6),
          const Color(0xFFF472B6),
          const Color(0xFFA855F7),
        ][random.nextInt(7)];
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t     = (progress * p.speed).clamp(0.0, 1.0);
      final y     = p.startY + t * 1.4;
      final x     = p.x + sin(t * 10 + p.wobble * 100) * p.wobble;
      final rot   = p.rotation + t * p.rotSpeed;
      final alpha = t < 0.7 ? 1.0 : (1.0 - (t - 0.7) / 0.3);

      if (y < 0 || y > 1.1) continue;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(rot);

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      // Alternate between rect and circle
      if (particles.indexOf(p) % 3 == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55),
            const Radius.circular(2),
          ),
          paint,
        );
      } else if (particles.indexOf(p) % 3 == 1) {
        canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
      } else {
        final path = Path()
          ..moveTo(0, -p.size * 0.5)
          ..lineTo(p.size * 0.3, p.size * 0.5)
          ..lineTo(-p.size * 0.3, p.size * 0.5)
          ..close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}