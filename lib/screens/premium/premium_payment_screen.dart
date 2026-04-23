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
const _kRed     = Color(0xFFEF4444);
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

enum _PayMethod { upi, card, wallet }

const _methodLabels = {
  _PayMethod.upi:    'UPI',
  _PayMethod.card:   'Card',
  _PayMethod.wallet: 'Wallets',
};

const _methodIcons = {
  _PayMethod.upi:    Icons.qr_code_rounded,
  _PayMethod.card:   Icons.credit_card_rounded,
  _PayMethod.wallet: Icons.account_balance_wallet_rounded,
};

// ─────────────────────────────────────────────
//  WALLET OPTIONS
// ─────────────────────────────────────────────

class _Wallet {
  final String name, emoji, hint;
  const _Wallet(this.name, this.emoji, this.hint);
}

const _wallets = [
  _Wallet('PhonePe',    '🟣', 'PhonePe wallet balance'),
  _Wallet('Paytm',      '🔵', 'Paytm wallet balance'),
  _Wallet('Amazon Pay', '🟠', 'Amazon Pay balance'),
  _Wallet('Mobikwik',   '🟤', 'Mobikwik wallet'),
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

  int         _selectedPlan   = 1;
  _PayMethod  _selectedMethod = _PayMethod.upi;
  bool        _isLoading      = false;

  // UPI
  final _upiCtrl = TextEditingController();
  bool  _upiValid = false;

  // Card
  final _cardCtrl  = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl   = TextEditingController();
  final _nameCtrl  = TextEditingController();
  bool  _cardFlipped = false;

  // Wallet
  int _selectedWallet = 0;

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

    _upiCtrl.addListener(() {
      final v = _upiCtrl.text.trim();
      final valid = v.contains('@') && v.length > 4;
      if (valid != _upiValid) setState(() => _upiValid = valid);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _upiCtrl.dispose();
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────

  bool get _canPay {
    switch (_selectedMethod) {
      case _PayMethod.upi:
        return _upiValid;
      case _PayMethod.card:
        return _cardCtrl.text.replaceAll(' ', '').length == 16 &&
            _expiryCtrl.text.length == 5 &&
            _cvvCtrl.text.length >= 3 &&
            _nameCtrl.text.trim().length > 2;
      case _PayMethod.wallet:
        return true;
    }
  }

  // ── Pay action ────────────────────────────

  void _pay() {
    if (!_canPay) {
      _showValidationError();
      return;
    }
    HapticFeedback.mediumImpact();
    _simulatePayment();
  }

  void _showValidationError() {
    String msg;
    switch (_selectedMethod) {
      case _PayMethod.upi:
        msg = 'Please enter a valid UPI ID (e.g. name@upi)';
        break;
      case _PayMethod.card:
        msg = 'Please fill in all card details correctly';
        break;
      case _PayMethod.wallet:
        msg = 'Please select a wallet';
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _kRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
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

  void _showSuccessDialog() {
    final orderId = '#NS${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        plan: _plans[_selectedPlan],
        orderId: orderId,
      ),
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
                    SizedBox(height: sh * 0.018),
                    _orderSummary(sw),
                    SizedBox(height: sh * 0.018),
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
          border: Border.all(color: sel ? _kPrimary : _kBorder, width: sel ? 2.0 : 1.5),
          boxShadow: [
            BoxShadow(
              color: sel ? _kPrimary.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
              blurRadius: sel ? 24 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              Text(p.billingNote, style: TextStyle(fontSize: sw * 0.026, color: _kMuted)),
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
              Text(p.perMonth, style: TextStyle(fontSize: sw * 0.024, color: _kHint)),
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
        ]),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Quick UPI app launch
            _upiAppsRow(sw),
            SizedBox(height: sw * 0.022),
            Divider(color: _kBorder, height: 1),
            SizedBox(height: sw * 0.022),
            // Method tabs
            _methodTabs(sw),
            SizedBox(height: sw * 0.024),
            // Method-specific form
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
                      .animate(anim),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_selectedMethod),
                child: _buildMethodForm(sw),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _upiAppsRow(double sw) {
    final apps = [
      ('GPay',     '🟢', const Color(0xFF4285F4)),
      ('PhonePe',  '🟣', const Color(0xFF5F259F)),
      ('Paytm',    '🔵', const Color(0xFF00BAF2)),
      ('BHIM',     '🟠', const Color(0xFF00B050)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Pay with UPI app',
            style: TextStyle(fontSize: sw * 0.028, fontWeight: FontWeight.w700, color: _kInk)),
        SizedBox(width: sw * 0.012),
        Container(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.016, vertical: sw * 0.005),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('Fast', style: TextStyle(fontSize: sw * 0.022, fontWeight: FontWeight.w700,
              color: _kGreen)),
        ),
      ]),
      SizedBox(height: sw * 0.016),
      Row(children: apps.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              // In production: deep-link to the UPI app
            },
            child: Column(children: [
              Container(
                  width: sw * 0.130, height: sw * 0.130,
                  decoration: BoxDecoration(
                    color: a.$3.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: a.$3.withValues(alpha: 0.20)),
                  ),
                  child: Center(child: Text(a.$1[0],
                      style: TextStyle(fontSize: sw * 0.042, fontWeight: FontWeight.w800,
                          color: a.$3)))),
              SizedBox(height: sw * 0.008),
              Text(a.$1, style: TextStyle(fontSize: sw * 0.022, fontWeight: FontWeight.w600, color: _kMuted)),
            ]),
          ),
        );
      }).toList()),
    ]);
  }

  Widget _methodTabs(double sw) {
    return Row(children: _PayMethod.values.map((m) {
      final sel = _selectedMethod == m;
      final isLast = m == _PayMethod.wallet;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedMethod = m);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(right: !isLast ? sw * 0.016 : 0),
            padding: EdgeInsets.symmetric(vertical: sw * 0.020),
            decoration: BoxDecoration(
              color: sel ? _kLight : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sel ? _kPrimary : _kBorder, width: sel ? 1.5 : 1),
            ),
            child: Column(children: [
              Icon(_methodIcons[m]!, size: sw * 0.038, color: sel ? _kPrimary : _kMuted),
              SizedBox(height: sw * 0.006),
              Text(_methodLabels[m]!,
                  style: TextStyle(fontSize: sw * 0.020, fontWeight: FontWeight.w700,
                      color: sel ? _kPrimary : _kMuted),
                  textAlign: TextAlign.center),
            ]),
          ),
        ),
      );
    }).toList());
  }

  Widget _buildMethodForm(double sw) {
    switch (_selectedMethod) {
      case _PayMethod.upi:
        return _upiForm(sw);
      case _PayMethod.card:
        return _cardForm(sw);
      case _PayMethod.wallet:
        return _walletForm(sw);
    }
  }

  // ── UPI form ──────────────────────────────

  Widget _upiForm(double sw) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Enter UPI ID',
          style: TextStyle(fontSize: sw * 0.030, fontWeight: FontWeight.w700, color: _kInk)),
      SizedBox(height: sw * 0.012),
      _inputField(
        controller: _upiCtrl,
        hint: 'yourname@paytm / @okaxis / @ybl',
        prefix: Icon(Icons.alternate_email_rounded, color: _kMuted, size: sw * 0.042),
        suffix: _upiValid
            ? Icon(Icons.check_circle_rounded, color: _kGreen, size: sw * 0.040)
            : null,
        keyboard: TextInputType.emailAddress,
        sw: sw,
      ),
      SizedBox(height: sw * 0.010),
      Row(children: [
        Icon(Icons.info_outline_rounded, size: sw * 0.026, color: _kHint),
        SizedBox(width: sw * 0.010),
        Text('e.g. 9876543210@paytm, name@okaxis',
            style: TextStyle(fontSize: sw * 0.024, color: _kHint)),
      ]),
      SizedBox(height: sw * 0.018),
      _securityFooter(sw),
    ]);
  }

  // ── Card form ─────────────────────────────

  Widget _cardForm(double sw) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Visual card preview
      _cardPreview(sw),
      SizedBox(height: sw * 0.024),
      Text('Card number',
          style: TextStyle(fontSize: sw * 0.028, fontWeight: FontWeight.w700, color: _kInk)),
      SizedBox(height: sw * 0.010),
      _inputField(
        controller: _cardCtrl,
        hint: '1234  5678  9012  3456',
        prefix: Icon(Icons.credit_card_rounded, color: _kMuted, size: sw * 0.042),
        keyboard: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _CardNumberFormatter(),
          LengthLimitingTextInputFormatter(19),
        ],
        sw: sw,
        onChanged: (_) => setState(() {}),
      ),
      SizedBox(height: sw * 0.016),
      Text('Cardholder name',
          style: TextStyle(fontSize: sw * 0.028, fontWeight: FontWeight.w700, color: _kInk)),
      SizedBox(height: sw * 0.010),
      _inputField(
        controller: _nameCtrl,
        hint: 'Name as on card',
        prefix: Icon(Icons.person_outline_rounded, color: _kMuted, size: sw * 0.042),
        keyboard: TextInputType.name,
        sw: sw,
        onChanged: (_) => setState(() {}),
        textCapitalization: TextCapitalization.words,
      ),
      SizedBox(height: sw * 0.016),
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Expiry',
                style: TextStyle(fontSize: sw * 0.028, fontWeight: FontWeight.w700, color: _kInk)),
            SizedBox(height: sw * 0.010),
            _inputField(
              controller: _expiryCtrl,
              hint: 'MM/YY',
              prefix: Icon(Icons.calendar_today_rounded, color: _kMuted, size: sw * 0.038),
              keyboard: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _ExpiryFormatter(),
                LengthLimitingTextInputFormatter(5),
              ],
              sw: sw,
              onChanged: (_) => setState(() {}),
            ),
          ]),
        ),
        SizedBox(width: sw * 0.020),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CVV',
                style: TextStyle(fontSize: sw * 0.028, fontWeight: FontWeight.w700, color: _kInk)),
            SizedBox(height: sw * 0.010),
            _inputField(
              controller: _cvvCtrl,
              hint: '•••',
              prefix: Icon(Icons.lock_outline_rounded, color: _kMuted, size: sw * 0.038),
              keyboard: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              sw: sw,
              obscure: true,
              onFocusChange: (focused) => setState(() => _cardFlipped = focused),
              onChanged: (_) => setState(() {}),
            ),
          ]),
        ),
      ]),
      SizedBox(height: sw * 0.018),
      _securityFooter(sw),
    ]);
  }

  Widget _cardPreview(double sw) {
    final cardNum = _cardCtrl.text.isEmpty
        ? '•••• •••• •••• ••••'
        : _cardCtrl.text.padRight(19, '•').substring(0, 19);
    final name = _nameCtrl.text.isEmpty ? 'YOUR NAME' : _nameCtrl.text.toUpperCase();
    final expiry = _expiryCtrl.text.isEmpty ? 'MM/YY' : _expiryCtrl.text;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _cardFlipped
          ? _cardBack(sw)
          : Container(
        key: const ValueKey('front'),
        width: double.infinity,
        height: sw * 0.52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF312E81), Color(0xFF4338CA), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(children: [
          // Circle decorations
          Positioned(top: -20, right: -20,
              child: Container(width: sw * 0.38, height: sw * 0.38,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06)))),
          Positioned(bottom: -sw * 0.10, left: -sw * 0.04,
              child: Container(width: sw * 0.28, height: sw * 0.28,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04)))),
          Padding(
            padding: EdgeInsets.all(sw * 0.048),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('NextStep', style: TextStyle(fontSize: sw * 0.034,
                      fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                  // Chip
                  Container(width: sw * 0.080, height: sw * 0.060,
                    decoration: BoxDecoration(
                      color: _kGold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 1.5, height: sw * 0.036,
                          color: Colors.white.withValues(alpha: 0.6)),
                      SizedBox(width: 4),
                      Container(width: 1.5, height: sw * 0.036,
                          color: Colors.white.withValues(alpha: 0.6)),
                    ]),
                  ),
                ]),
                Text(cardNum,
                    style: TextStyle(fontSize: sw * 0.048, fontWeight: FontWeight.w700,
                        color: Colors.white, letterSpacing: sw * 0.006,
                        fontFamily: 'monospace')),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('CARDHOLDER', style: TextStyle(fontSize: sw * 0.020,
                        color: Colors.white.withValues(alpha: 0.55), letterSpacing: 0.5)),
                    SizedBox(height: 2),
                    Text(name, style: TextStyle(fontSize: sw * 0.028,
                        fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('EXPIRES', style: TextStyle(fontSize: sw * 0.020,
                        color: Colors.white.withValues(alpha: 0.55), letterSpacing: 0.5)),
                    SizedBox(height: 2),
                    Text(expiry, style: TextStyle(fontSize: sw * 0.028,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                  // Visa-style mark
                  Text('VISA', style: TextStyle(fontSize: sw * 0.034,
                      fontWeight: FontWeight.w800, color: Colors.white, fontStyle: FontStyle.italic)),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _cardBack(double sw) {
    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      height: sw * 0.52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: _kPrimary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(children: [
        SizedBox(height: sw * 0.060),
        Container(width: double.infinity, height: sw * 0.100, color: Colors.black.withValues(alpha: 0.40)),
        SizedBox(height: sw * 0.034),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.048),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.020, vertical: sw * 0.018),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('CVV', style: TextStyle(fontSize: sw * 0.026, color: _kMuted)),
              Text(_cvvCtrl.text.isEmpty ? '•••' : '•' * _cvvCtrl.text.length,
                  style: TextStyle(fontSize: sw * 0.032, fontWeight: FontWeight.w700, color: _kInk)),
            ]),
          ),
        ),
        SizedBox(height: sw * 0.024),
        Text('3 digits on the back of your card',
            style: TextStyle(fontSize: sw * 0.024, color: Colors.white.withValues(alpha: 0.55))),
      ]),
    );
  }

  // ── Wallet form ───────────────────────────

  Widget _walletForm(double sw) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Select wallet',
          style: TextStyle(fontSize: sw * 0.030, fontWeight: FontWeight.w700, color: _kInk)),
      SizedBox(height: sw * 0.016),
      ...List.generate(_wallets.length, (i) {
        final sel = _selectedWallet == i;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedWallet = i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.only(bottom: sw * 0.014),
            padding: EdgeInsets.symmetric(horizontal: sw * 0.028, vertical: sw * 0.020),
            decoration: BoxDecoration(
              color: sel ? _kLight : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sel ? _kPrimary : _kBorder, width: sel ? 1.5 : 1),
            ),
            child: Row(children: [
              Text(_wallets[i].emoji, style: TextStyle(fontSize: sw * 0.036)),
              SizedBox(width: sw * 0.018),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_wallets[i].name,
                    style: TextStyle(fontSize: sw * 0.030, fontWeight: FontWeight.w700,
                        color: sel ? _kPrimary : _kInk)),
                Text(_wallets[i].hint,
                    style: TextStyle(fontSize: sw * 0.024, color: _kMuted)),
              ])),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: sw * 0.048, height: sw * 0.048,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? _kPrimary : Colors.transparent,
                  border: Border.all(color: sel ? _kPrimary : _kBorder, width: 1.5),
                ),
                child: sel ? Icon(Icons.check_rounded, color: Colors.white, size: sw * 0.026) : null,
              ),
            ]),
          ),
        );
      }),
      SizedBox(height: sw * 0.012),
      _securityFooter(sw),
    ]);
  }

  // ── Order summary ─────────────────────────

  Widget _orderSummary(double sw) {
    final plan = _plans[_selectedPlan];
    final renewDate = _getRenewDate(plan.id);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.045),
      child: Container(
        padding: EdgeInsets.all(sw * 0.036),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F4FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kViolet.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Column(children: [
          Row(children: [
            Text('👑', style: TextStyle(fontSize: sw * 0.034)),
            SizedBox(width: sw * 0.014),
            Text('Order Summary',
                style: TextStyle(fontSize: sw * 0.030, fontWeight: FontWeight.w800, color: _kPrimary)),
          ]),
          SizedBox(height: sw * 0.018),
          Divider(color: _kViolet.withValues(alpha: 0.15)),
          SizedBox(height: sw * 0.014),
          _summaryRow('NextStep Premium (${plan.label})', plan.priceDisplay, sw, bold: true),
          SizedBox(height: sw * 0.010),
          _summaryRow('GST (0%)', '₹0', sw),
          SizedBox(height: sw * 0.010),
          Divider(color: _kViolet.withValues(alpha: 0.15)),
          SizedBox(height: sw * 0.010),
          _summaryRow('Total', plan.priceDisplay, sw, bold: true, highlight: true),
          SizedBox(height: sw * 0.014),
          Container(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.022, vertical: sw * 0.012),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Icon(Icons.autorenew_rounded, size: sw * 0.028, color: _kMuted),
              SizedBox(width: sw * 0.010),
              Text('Auto-renews on $renewDate · Cancel anytime',
                  style: TextStyle(fontSize: sw * 0.024, color: _kMuted)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _summaryRow(String label, String value, double sw,
      {bool bold = false, bool highlight = false}) {
    return Row(children: [
      Expanded(child: Text(label, style: TextStyle(
          fontSize: sw * 0.028,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: highlight ? _kPrimary : _kMuted))),
      Text(value, style: TextStyle(
          fontSize: bold ? sw * 0.032 : sw * 0.028,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          color: highlight ? _kPrimary : _kInk)),
    ]);
  }

  String _getRenewDate(String planId) {
    final now = DateTime.now();
    DateTime renew;
    switch (planId) {
      case 'monthly':   renew = DateTime(now.year, now.month + 1, now.day); break;
      case 'quarterly': renew = DateTime(now.year, now.month + 3, now.day); break;
      case 'yearly':    renew = DateTime(now.year + 1, now.month, now.day); break;
      default:          renew = DateTime(now.year, now.month + 1, now.day);
    }
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${renew.day} ${months[renew.month - 1]} ${renew.year}';
  }

  // ── Trust row ─────────────────────────────

  Widget _trustRow(double sw) {
    final items = [
      (Icons.cancel_outlined,      '₹0 cancellation'),
      (Icons.autorenew_rounded,    'Cancel anytime'),
      (Icons.verified_user_rounded,'7-day refund'),
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
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((e) => Column(children: [
              Container(
                  padding: EdgeInsets.all(sw * 0.022),
                  decoration: BoxDecoration(color: _kLight, shape: BoxShape.circle),
                  child: Icon(e.$1, color: _kPrimary, size: sw * 0.040)),
              SizedBox(height: sw * 0.008),
              Text(e.$2, style: TextStyle(fontSize: sw * 0.024, fontWeight: FontWeight.w700, color: _kMuted)),
            ])).toList()),
      ),
    );
  }

  // ── Pay button ────────────────────────────

  Widget _payButton(double sw) {
    final plan = _plans[_selectedPlan];
    final canPay = _canPay;
    final methodLabel = _selectedMethod == _PayMethod.wallet
        ? _wallets[_selectedWallet].name
        : _methodLabels[_selectedMethod]!;

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
              gradient: (_isLoading || !canPay)
                  ? const LinearGradient(colors: [Color(0xFF9CA3AF), Color(0xFF9CA3AF)])
                  : const LinearGradient(colors: [_kPrimary, _kViolet],
                  begin: Alignment.centerLeft, end: Alignment.centerRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: (_isLoading || !canPay) ? [] : [
                BoxShadow(color: _kPrimary.withValues(alpha: 0.38), blurRadius: 20, offset: const Offset(0, 8)),
                BoxShadow(color: _kViolet.withValues(alpha: 0.22), blurRadius: 32, offset: const Offset(0, 14)),
              ],
            ),
            child: Center(
              child: _isLoading
                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: sw * 0.050, height: sw * 0.050,
                    child: const CircularProgressIndicator(strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                SizedBox(width: sw * 0.020),
                Text('Processing payment…', style: TextStyle(fontSize: sw * 0.034,
                    fontWeight: FontWeight.w700, color: Colors.white)),
              ])
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.lock_rounded, color: Colors.white, size: sw * 0.042),
                SizedBox(width: sw * 0.016),
                Text('Pay ${plan.priceDisplay} · $methodLabel',
                    style: TextStyle(fontSize: sw * 0.036,
                        fontWeight: FontWeight.w800, color: Colors.white)),
              ]),
            ),
          ),
        ),
        SizedBox(height: sw * 0.016),
        // Razorpay badge
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.lock_outline_rounded, size: sw * 0.026, color: _kHint),
          SizedBox(width: sw * 0.010),
          Text('Secured by Razorpay · 256-bit SSL',
              style: TextStyle(fontSize: sw * 0.024, color: _kHint)),
        ]),
      ]),
    );
  }

  // ── Shared input field ────────────────────

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required double sw,
    Widget? prefix,
    Widget? suffix,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool obscure = false,
    ValueChanged<String>? onChanged,
    ValueChanged<bool>? onFocusChange,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    Widget field = Focus(
      onFocusChange: onFocusChange,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder, width: 1.5),
        ),
        child: Row(children: [
          if (prefix != null)
            Padding(padding: EdgeInsets.only(left: sw * 0.030), child: prefix),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              inputFormatters: inputFormatters,
              obscureText: obscure,
              textCapitalization: textCapitalization,
              onChanged: onChanged,
              style: TextStyle(fontSize: sw * 0.030, fontWeight: FontWeight.w600, color: _kInk),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: _kHint, fontSize: sw * 0.028),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: sw * 0.020, vertical: sw * 0.034),
              ),
            ),
          ),
          if (suffix != null)
            Padding(padding: EdgeInsets.only(right: sw * 0.020), child: suffix),
        ]),
      ),
    );
    return field;
  }

  Widget _securityFooter(double sw) {
    return Row(children: [
      Icon(Icons.lock_rounded, size: sw * 0.028, color: _kGreen),
      SizedBox(width: sw * 0.012),
      Expanded(child: Text('256-bit SSL · Razorpay PCI DSS compliant · Instant refunds',
          style: TextStyle(fontSize: sw * 0.024, color: _kMuted))),
    ]);
  }

  Widget _sectionLabel(String text, double sw) {
    return Text(text,
        style: TextStyle(fontSize: sw * 0.024, fontWeight: FontWeight.w800,
            color: _kMuted, letterSpacing: 0.9));
  }
}

// ─────────────────────────────────────────────
//  TEXT FORMATTERS
// ─────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue current) {
    final digits = current.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return current.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue current) {
    final digits = current.text.replaceAll('/', '');
    if (digits.length >= 3) {
      final str = '${digits.substring(0, 2)}/${digits.substring(2)}';
      return current.copyWith(
        text: str,
        selection: TextSelection.collapsed(offset: str.length),
      );
    }
    return current;
  }
}

// ─────────────────────────────────────────────
//  SUCCESS DIALOG
// ─────────────────────────────────────────────

class _SuccessDialog extends StatefulWidget {
  final _Plan plan;
  final String orderId;
  const _SuccessDialog({required this.plan, required this.orderId});
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
    for (int i = 0; i < 50; i++) {
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
              Container(
                decoration: BoxDecoration(
                  color: _kWhite,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 50, offset: const Offset(0, 20)),
                  ],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(height: 5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [_kPrimary, _kViolet, Color(0xFF8B5CF6)]),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      )),
                  Padding(
                    padding: EdgeInsets.fromLTRB(sw * 0.060, sw * 0.050, sw * 0.060, sw * 0.050),
                    child: Column(children: [
                      Container(
                          width: sw * 0.200, height: sw * 0.200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: _kViolet.withValues(alpha: 0.25), width: 3),
                            boxShadow: [BoxShadow(color: _kPrimary.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: Center(child: Text('👑', style: TextStyle(fontSize: sw * 0.090)))),
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
                      SizedBox(height: sw * 0.024),
                      // Verified chip
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.040, vertical: sw * 0.018),
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
                      SizedBox(height: sw * 0.018),
                      // Order details
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(sw * 0.030),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _kBorder),
                        ),
                        child: Column(children: [
                          _detailRow('Order ID', widget.orderId, sw),
                          SizedBox(height: sw * 0.010),
                          _detailRow('Plan', '${widget.plan.label} — ${widget.plan.priceDisplay}', sw),
                          SizedBox(height: sw * 0.010),
                          _detailRow('Receipt', 'Sent to your email', sw, icon: Icons.email_outlined),
                        ]),
                      ),
                      SizedBox(height: sw * 0.030),
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
                            boxShadow: [BoxShadow(color: _kPrimary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
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
                ]),
              ),
              // Confetti
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _confettiCtrl,
                    builder: (_, __) => CustomPaint(
                      painter: _ConfettiPainter(
                        particles: _confettiList,
                        progress: _confettiCtrl.value,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, double sw, {IconData? icon}) {
    return Row(children: [
      if (icon != null) ...[
        Icon(icon, size: sw * 0.028, color: _kMuted),
        SizedBox(width: sw * 0.010),
      ],
      Text('$label: ', style: TextStyle(fontSize: sw * 0.026, color: _kMuted)),
      Expanded(
        child: Text(value,
            style: TextStyle(fontSize: sw * 0.026, fontWeight: FontWeight.w700, color: _kInk),
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
//  CONFETTI PAINTER (unchanged, kept as-is)
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
          const Color(0xFF6366F1), const Color(0xFFF59E0B), const Color(0xFF10B981),
          const Color(0xFFEF4444), const Color(0xFF3B82F6), const Color(0xFFF472B6),
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
      final t   = (progress * p.speed).clamp(0.0, 1.0);
      final y   = p.startY + t * 1.4;
      final x   = p.x + sin(t * 10 + p.wobble * 100) * p.wobble;
      final rot = p.rotation + t * p.rotSpeed;
      final alpha = t < 0.7 ? 1.0 : (1.0 - (t - 0.7) / 0.3);
      if (y < 0 || y > 1.1) continue;
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(rot);
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
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