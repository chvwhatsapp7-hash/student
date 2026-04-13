import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../api_services/authservice.dart';
import 'premium_helper.dart';

// ─────────────────────────────────────────────
//  TOKENS
// ─────────────────────────────────────────────

const _kInk     = Color(0xFF0A0F1E);
const _kPrimary = Color(0xFF1D4ED8);
const _kViolet  = Color(0xFF4F46E5);
const _kAccent  = Color(0xFF38BDF8);
const _kMuted   = Color(0xFF64748B);
const _kHint    = Color(0xFF94A3B8);
const _kBorder  = Color(0xFFE2E8F0);
const _kFill    = Color(0xFFF8FAFC);
const _kPageBg  = Color(0xFFF0F4F8);

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
//  SCREEN
// ─────────────────────────────────────────────

class PremiumPaymentScreen extends StatefulWidget {
  const PremiumPaymentScreen({super.key});
  @override
  State<PremiumPaymentScreen> createState() => _PremiumPaymentScreenState();
}

class _PremiumPaymentScreenState extends State<PremiumPaymentScreen>
    with SingleTickerProviderStateMixin {

  int  _selectedPlan = 1;
  bool _isLoading    = false;
  late Razorpay _razorpay;
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset>  _slide;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 80), () { if (mounted) _ctrl.forward(); });

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,   _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onWallet);
  }

  @override
  void dispose() { _ctrl.dispose(); _razorpay.clear(); super.dispose(); }

  // ── Razorpay events ───────────────────────

  void _onSuccess(PaymentSuccessResponse r) async {
    debugPrint('✅ Payment: ${r.paymentId}');
    // TODO: POST r.paymentId + plan id to your backend for server-side verification.
    // After backend confirms, call setPremium() below.
    await PremiumHelper.setPremium();
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSuccessDialog();
  }

  void _onError(PaymentFailureResponse r) {
    if (!mounted) return;
    _snack('Payment failed: ${r.message}', error: true);
    setState(() => _isLoading = false);
  }

  void _onWallet(ExternalWalletResponse r) =>
      debugPrint('Wallet: ${r.walletName}');

  // ── Open Razorpay ─────────────────────────

  void _pay() {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    final plan = _plans[_selectedPlan];
    try {
      _razorpay.open({
        'key':         'YOUR_RAZORPAY_KEY_ID', // 🔑 replace
        'amount':      plan.amountPaise,
        'currency':    'INR',
        'name':        'NextStep Premium',
        'description': '${plan.label} subscription',
        'prefill': {
          'name':  AuthService().fullName ?? '',
          'email': '',   // fill from your user object
        },
        'theme': {'color': '#1D4ED8'},
        // 'order_id': 'order_XXX', // from your backend Orders API
      });
    } catch (e) {
      _snack('Could not open payment. Please try again.', error: true);
      setState(() => _isLoading = false);
    }
  }

  // ── Helpers ───────────────────────────────

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      backgroundColor: error ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  void _showSuccessDialog() {
    final sw = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(height: 5,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [_kPrimary, _kViolet]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
            Padding(
              padding: EdgeInsets.fromLTRB(sw * 0.06, 24, sw * 0.06, 24),
              child: Column(children: [
                Container(
                    width: sw * 0.18, height: sw * 0.18,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        color: const Color(0xFFEEF2FF),
                        border: Border.all(color: _kViolet.withValues(alpha: 0.3), width: 2)),
                    child: Center(child: Text('👑', style: TextStyle(fontSize: sw * 0.090)))),
                SizedBox(height: sw * 0.04),
                Text('You\'re Premium!',
                    style: TextStyle(fontSize: sw * 0.048, fontWeight: FontWeight.w800, color: _kInk)),
                SizedBox(height: sw * 0.016),
                Text('Welcome to NextStep Premium.\nAll features are now unlocked.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: sw * 0.030, color: _kMuted, height: 1.6)),
                SizedBox(height: sw * 0.048),
                GestureDetector(
                  onTap: () { Navigator.pop(context); context.go('/engineering'); },
                  child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: sw * 0.036),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_kPrimary, _kViolet],
                              begin: Alignment.centerLeft, end: Alignment.centerRight),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: _kPrimary.withValues(alpha: 0.28),
                              blurRadius: 10, offset: const Offset(0, 4))]),
                      child: Center(child: Text('Explore Premium Features',
                          style: TextStyle(fontSize: sw * 0.036,
                              fontWeight: FontWeight.w800, color: Colors.white)))),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kPageBg,
        body: Column(children: [
          _navBar(sw),
          Expanded(
            child: FadeTransition(opacity: _fade, child: SlideTransition(position: _slide,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _miniHero(sw),
                  SizedBox(height: sh * 0.022),
                  _plansSection(sw),
                  SizedBox(height: sh * 0.022),
                  _paymentSection(sw),
                  SizedBox(height: sh * 0.022),
                  _trustRow(sw),
                  SizedBox(height: sh * 0.014),
                  _payButton(sw),
                  SizedBox(height: sh * 0.035),
                ]),
              ),
            )),
          ),
        ]),
      ),
    );
  }

  // ── Nav bar ────────────────────────────────

  Widget _navBar(double sw) {
    return Container(
      color: _kInk,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.045, vertical: sw * 0.036),
        child: Row(children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
                width: sw * 0.092, height: sw * 0.092,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
                child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: sw * 0.038)),
          ),
          SizedBox(width: sw * 0.030),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Choose Your Plan',
                style: TextStyle(fontSize: sw * 0.042, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: -0.3)),
            Text('Cancel anytime · No hidden fees',
                style: TextStyle(fontSize: sw * 0.026, color: _kAccent, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    );
  }

  // ── Mini hero ──────────────────────────────

  Widget _miniHero(double sw) {
    return Container(
      margin: EdgeInsets.fromLTRB(sw * 0.045, sw * 0.045, sw * 0.045, 0),
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF4F46E5), Color(0xFF7C3AED)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Text('👑', style: TextStyle(fontSize: sw * 0.065)),
        SizedBox(width: sw * 0.030),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NextStep Premium',
              style: TextStyle(fontSize: sw * 0.040,
                  fontWeight: FontWeight.w800, color: Colors.white)),
          SizedBox(height: sw * 0.008),
          Text('Unlimited jobs · AI resume · Mentorship · Early access',
              style: TextStyle(fontSize: sw * 0.026,
                  color: Colors.white.withValues(alpha: 0.72), height: 1.4)),
        ])),
      ]),
    );
  }

  // ── Plans ─────────────────────────────────

  Widget _plansSection(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.045),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SELECT A PLAN',
            style: TextStyle(fontSize: sw * 0.025, fontWeight: FontWeight.w800,
                color: _kMuted, letterSpacing: 0.8)),
        SizedBox(height: sw * 0.022),
        ...List.generate(_plans.length, (i) => _planCard(_plans[i], i, sw)),
      ]),
    );
  }

  Widget _planCard(_Plan p, int i, double sw) {
    final sel = _selectedPlan == i;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: sw * 0.028),
        padding: EdgeInsets.all(sw * 0.040),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: sel ? _kPrimary : _kBorder, width: sel ? 2.0 : 1.5),
            boxShadow: [BoxShadow(
                color: sel ? _kPrimary.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.04),
                blurRadius: sel ? 20 : 8, offset: const Offset(0, 4))]),
        child: Column(children: [
          if (p.isPopular) ...[
            Align(alignment: Alignment.centerLeft,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.026, vertical: sw * 0.010),
                    decoration: BoxDecoration(color: _kPrimary, borderRadius: BorderRadius.circular(20)),
                    child: Text('MOST POPULAR',
                        style: TextStyle(fontSize: sw * 0.022, fontWeight: FontWeight.w800,
                            color: Colors.white, letterSpacing: 0.5)))),
            SizedBox(height: sw * 0.018),
          ],
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.label,
                  style: TextStyle(fontSize: sw * 0.040, fontWeight: FontWeight.w800, color: _kInk)),
              SizedBox(height: sw * 0.006),
              Text(p.billingNote,
                  style: TextStyle(fontSize: sw * 0.028, color: _kMuted)),
              if (p.saveBadge != null) ...[
                SizedBox(height: sw * 0.010),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.022, vertical: sw * 0.008),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(p.saveBadge!,
                        style: TextStyle(fontSize: sw * 0.026, fontWeight: FontWeight.w800,
                            color: const Color(0xFF15803D)))),
              ],
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(p.priceDisplay,
                  style: TextStyle(fontSize: sw * 0.052, fontWeight: FontWeight.w800,
                      color: _kPrimary, letterSpacing: -0.5)),
              Text(p.perMonth,
                  style: TextStyle(fontSize: sw * 0.026, color: _kHint)),
            ]),
            SizedBox(width: sw * 0.025),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: sw * 0.055, height: sw * 0.055,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? _kPrimary : Colors.transparent,
                  border: Border.all(color: sel ? _kPrimary : _kBorder, width: 2)),
              child: sel ? Icon(Icons.check_rounded, color: Colors.white, size: sw * 0.030) : null,
            ),
          ]),
        ]),
      ),
    );
  }

  // ── Payment section ───────────────────────

  Widget _paymentSection(double sw) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.045),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('PAYMENT METHOD',
            style: TextStyle(fontSize: sw * 0.025, fontWeight: FontWeight.w800,
                color: _kMuted, letterSpacing: 0.8)),
        SizedBox(height: sw * 0.022),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(sw * 0.040),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _kBorder, width: 1.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.026, vertical: sw * 0.014),
                  decoration: BoxDecoration(color: const Color(0xFF072654),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('razorpay',
                      style: TextStyle(fontSize: sw * 0.030, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: -0.3))),
              SizedBox(width: sw * 0.020),
              Text('Secure checkout', style: TextStyle(fontSize: sw * 0.028, color: _kMuted)),
            ]),
            SizedBox(height: sw * 0.028),
            Wrap(spacing: sw * 0.016, runSpacing: sw * 0.014, children: [
              _chip('UPI',               Icons.qr_code_rounded,              sw, sel: true),
              _chip('Credit / Debit',    Icons.credit_card_rounded,           sw),
              _chip('Net banking',       Icons.account_balance_rounded,       sw),
              _chip('Wallets',           Icons.account_balance_wallet_rounded, sw),
            ]),
            SizedBox(height: sw * 0.022),
            Divider(color: _kBorder, height: 1),
            SizedBox(height: sw * 0.016),
            Row(children: [
              Icon(Icons.lock_outline_rounded, size: sw * 0.030, color: _kHint),
              SizedBox(width: sw * 0.012),
              Expanded(child: Text('256-bit SSL · Razorpay PCI DSS compliant',
                  style: TextStyle(fontSize: sw * 0.026, color: _kHint))),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _chip(String label, IconData icon, double sw, {bool sel = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.024, vertical: sw * 0.012),
      decoration: BoxDecoration(
          color: sel ? const Color(0xFFEFF6FF) : _kFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? _kPrimary : _kBorder, width: 1.5)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: sw * 0.030, color: sel ? _kPrimary : _kMuted),
        SizedBox(width: sw * 0.012),
        Text(label,
            style: TextStyle(fontSize: sw * 0.026, fontWeight: FontWeight.w700,
                color: sel ? _kPrimary : _kMuted)),
      ]),
    );
  }

  // ── Trust row ─────────────────────────────

  Widget _trustRow(double sw) {
    final items = [
      (Icons.cancel_outlined,       '₹0 cancellation'),
      (Icons.autorenew_rounded,     'Cancel anytime'),
      (Icons.verified_user_rounded, '7-day money back'),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.045),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((e) => Column(children: [
          Icon(e.$1, color: _kPrimary, size: sw * 0.046),
          SizedBox(height: sw * 0.008),
          Text(e.$2,
              style: TextStyle(fontSize: sw * 0.026, fontWeight: FontWeight.w700, color: _kMuted)),
        ])).toList(),
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
            padding: EdgeInsets.symmetric(vertical: sw * 0.044),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_kPrimary, _kViolet],
                    begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: _kPrimary.withValues(alpha: 0.36),
                      blurRadius: 20, offset: const Offset(0, 8)),
                  BoxShadow(color: _kViolet.withValues(alpha: 0.20),
                      blurRadius: 30, offset: const Offset(0, 14)),
                ]),
            child: Center(child: _isLoading
                ? SizedBox(width: sw * 0.055, height: sw * 0.055,
                child: const CircularProgressIndicator(strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.lock_outline_rounded, color: Colors.white, size: sw * 0.046),
              SizedBox(width: sw * 0.018),
              Text('Pay ${plan.priceDisplay} via Razorpay',
                  style: TextStyle(fontSize: sw * 0.038,
                      fontWeight: FontWeight.w800, color: Colors.white)),
            ])),
          ),
        ),
        SizedBox(height: sw * 0.018),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.lock_outline_rounded, size: sw * 0.028, color: _kHint),
          SizedBox(width: sw * 0.012),
          Text('Encrypted & secure · Cancel anytime',
              style: TextStyle(fontSize: sw * 0.026, color: _kHint)),
        ]),
      ]),
    );
  }
}
