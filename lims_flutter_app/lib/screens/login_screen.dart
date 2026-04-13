import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────
//  NAZA ENVIRO – LIMS Mobile  |  Login Screen
// ─────────────────────────────────────────────────────────────────
//
//  pubspec.yaml dependencies:
//    google_fonts: ^6.1.0   (optional – for SpaceGrotesk)
//
//  pubspec.yaml assets:
//    assets:
//      - assets/images/naza_logo.png
//
// ─────────────────────────────────────────────────────────────────

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const NazaLimsApp());
}

class NazaLimsApp extends StatelessWidget {
  const NazaLimsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naza Enviro LIMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: AppColors.bg),
      home: const LoginScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Color tokens
// ─────────────────────────────────────────────────────────────────
class AppColors {
  static const bg          = Color(0xFFF0F4FF);
  static const surface     = Color(0xFFFFFFFF);
  static const blue        = Color(0xFF1E3A8A);
  static const blue2       = Color(0xFF2E4FC7);
  static const heroDark    = Color(0xFF0A1F5C);
  static const heroMid     = Color(0xFF2748B8);
  static const yellow      = Color(0xFFF5C400);
  static const yellow2     = Color(0xFFFFD700);
  static const text        = Color(0xFF0F172A);
  static const textMuted   = Color(0xFF64748B);
  static const textLight   = Color(0xFF94A3B8);
  static const borderInput = Color(0x211E3A8A);
  static const indigo50    = Color(0xFFEEF2FF);
  static const slate200    = Color(0xFFE2E8F0);
  static const slate300    = Color(0xFFCBD5E1);
}

// ─────────────────────────────────────────────────────────────────
//  Role
// ─────────────────────────────────────────────────────────────────
enum UserRole { analyst, manager, admin }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.analyst: return 'Lab Analyst';
      case UserRole.manager: return 'Lab Manager';
      case UserRole.admin:   return 'Admin';
    }
  }
}

// ─────────────────────────────────────────────────────────────────
//  Login Screen
// ─────────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  UserRole _role         = UserRole.analyst;
  bool _obscure          = true;
  bool _isLoading        = false;

  late final AnimationController _animCtrl;
  late final Animation<Offset>   _slideAnim;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 550));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) setState(() => _isLoading = false);
    // TODO: navigate to dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const _HeroSection(),
            SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Expanded(
                  child: _FormCard(
                    role: _role,
                    onRoleChanged: (r) => setState(() => _role = r),
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    obscure: _obscure,
                    onToggleObscure: () => setState(() => _obscure = !_obscure),
                    isLoading: _isLoading,
                    onLogin: _handleLogin,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Hero Section
// ─────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.heroDark, AppColors.blue, AppColors.heroMid],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Grid
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          // Lab illustration
          Positioned.fill(child: CustomPaint(painter: _LabScenePainter())),
          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0A1F5C).withOpacity(0.6),
                    const Color(0xFF1E3A8A).withOpacity(0.3),
                    const Color(0xFF2748B8).withOpacity(0.1),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // Yellow bottom bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.yellow, AppColors.yellow2, Colors.transparent],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 4, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Brand row ──
                  Row(
                    children: [
                      // Logo tile — full-bleed with yellow border
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.yellow, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20, offset: const Offset(0, 4)),
                            BoxShadow(
                              color: AppColors.yellow.withOpacity(0.25),
                              blurRadius: 0, spreadRadius: 4),
                          ],
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(
                          'assets/images/naza_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Brand text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Naza Enviro',
                            style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700,
                              color: Colors.white, letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            'LIMS · MOBILE',
                            style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: 1.8, fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  // ── Headline ──
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 27, fontWeight: FontWeight.w800,
                        color: Colors.white, height: 1.22, letterSpacing: -0.3,
                      ),
                      children: [
                        TextSpan(text: 'Lab Intelligence,\n'),
                        TextSpan(
                          text: 'In Your Hands.',
                          style: TextStyle(color: AppColors.yellow),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── LIMS tagline pill ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withOpacity(0.15),
                      border: Border.all(color: AppColors.yellow.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.yellow,
                            boxShadow: [BoxShadow(color: AppColors.yellow, blurRadius: 6)],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'LABORATORY INFORMATION MANAGEMENT SYSTEM',
                            style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.92),
                              letterSpacing: 0.7, fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Feature chips ──
                  Wrap(
                    spacing: 7, runSpacing: 7,
                    children: const [
                      _FeatureChip(label: 'Sample Tracking'),
                      _FeatureChip(label: 'Analytics'),
                      _FeatureChip(label: 'QC & Compliance'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5, height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppColors.yellow),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8), letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Form Card
// ─────────────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final UserRole role;
  final ValueChanged<UserRole> onRoleChanged;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool isLoading;
  final VoidCallback onLogin;

  const _FormCard({
    required this.role, required this.onRoleChanged,
    required this.emailCtrl, required this.passwordCtrl,
    required this.obscure, required this.onToggleObscure,
    required this.isLoading, required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withOpacity(0.12),
            blurRadius: 24, offset: const Offset(0, -4)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Blue → blue2 → yellow top stripe
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.blue, AppColors.blue2, AppColors.yellow],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.slate300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Eyebrow
                  Row(
                    children: [
                      Container(
                        width: 18, height: 2,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.blue, AppColors.yellow]),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'SECURE ACCESS',
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w500,
                          color: AppColors.yellow, letterSpacing: 1.8,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Title
                  const Text(
                    'Welcome back 👋',
                    style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800,
                      color: AppColors.text, letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Role label
                  const Text(
                    'I AM A',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.textMuted, letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Role tabs
                  _RoleTabs(selected: role, onChanged: onRoleChanged),
                  const SizedBox(height: 20),

                  // Email
                  const _FieldLabel(text: 'EMAIL / ID'),
                  const SizedBox(height: 7),
                  _InputField(
                    controller: emailCtrl,
                    hint: 'your.name@nazaenviro.com',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your email' : null,
                  ),
                  const SizedBox(height: 14),

                  // Password
                  const _FieldLabel(text: 'PASSWORD'),
                  const SizedBox(height: 7),
                  _InputField(
                    controller: passwordCtrl,
                    hint: 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    obscure: obscure,
                    suffixLabel: obscure ? 'Show' : 'Hide',
                    onSuffixTap: onToggleObscure,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your password' : null,
                  ),

                  // Forgot
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.blue2,
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Sign In
                  _SignInButton(isLoading: isLoading, onTap: onLogin),
                  const SizedBox(height: 16),

                  // OR divider
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: AppColors.slate200)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or sign in with',
                          style: TextStyle(
                            fontSize: 12, color: AppColors.textLight,
                            fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(child: Container(height: 1, color: AppColors.slate200)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // SSO
                  _SSOButton(onTap: () {}),
                  const SizedBox(height: 24),

                  // Footer
                  const _Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Role Tabs
// ─────────────────────────────────────────────────────────────────
class _RoleTabs extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;
  const _RoleTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.indigo50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue.withOpacity(0.08), width: 1.5),
      ),
      child: Row(
        children: UserRole.values.map((role) {
          final active = role == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [AppColors.blue, AppColors.blue2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)
                      : null,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: active
                      ? [BoxShadow(
                          color: AppColors.blue.withOpacity(0.28),
                          blurRadius: 10, offset: const Offset(0, 2))]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  role.label,
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Field Label
// ─────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: AppColors.blue, letterSpacing: 0.4,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Input Field
// ─────────────────────────────────────────────────────────────────
class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final String? suffixLabel;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller, required this.hint, required this.icon,
    this.obscure = false, this.suffixLabel, this.onSuffixTap,
    this.keyboardType, this.validator,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: _focused ? AppColors.surface : AppColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused ? AppColors.blue : AppColors.borderInput,
            width: 1.5,
          ),
          boxShadow: _focused
              ? [BoxShadow(
                  color: AppColors.blue.withOpacity(0.08),
                  blurRadius: 0, spreadRadius: 3)]
              : null,
        ),
        child: Row(
          children: [
            // Yellow left stripe on focus
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 3,
              decoration: BoxDecoration(
                color: _focused ? AppColors.yellow : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              widget.icon, size: 18,
              color: _focused
                  ? AppColors.blue
                  : AppColors.textMuted.withOpacity(0.6),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                obscureText: widget.obscure,
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.text),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w400, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (widget.suffixLabel != null)
              GestureDetector(
                onTap: widget.onSuffixTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    widget.suffixLabel!,
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: AppColors.blue, letterSpacing: 0.2),
                  ),
                ),
              )
            else
              const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Sign In Button
// ─────────────────────────────────────────────────────────────────
class _SignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _SignInButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.blue, AppColors.blue2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withOpacity(0.38),
              blurRadius: 24, offset: const Offset(0, 6)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Top sheen
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
              ),
            ),
            // Yellow bottom glow line
            Positioned(
              bottom: 0, left: 40, right: 40,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.transparent, AppColors.yellow, Colors.transparent]),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Content
            Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: Colors.white, letterSpacing: 0.2),
                        ),
                        const SizedBox(width: 10),
                        // Yellow icon tile with blue arrow
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.yellow,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.yellow.withOpacity(0.4),
                                blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.blue, size: 17),
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

// ─────────────────────────────────────────────────────────────────
//  SSO Button
// ─────────────────────────────────────────────────────────────────
class _SSOButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SSOButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.blue.withOpacity(0.15), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue, AppColors.blue2],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withOpacity(0.3),
                    blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'N',
                style: TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Naza Enterprise SSO',
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Footer
// ─────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Blue→yellow→blue accent line
        Container(
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.blue,
                AppColors.yellow,
                AppColors.blue,
                Colors.transparent,
              ],
              stops: [0.0, 0.2, 0.5, 0.8, 1.0],
            ),
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 11, color: AppColors.textLight, height: 1.7),
            children: [
              TextSpan(text: 'Restricted to '),
              TextSpan(
                text: 'authorized personnel',
                style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w600),
              ),
              TextSpan(text: ' only.\nAll sessions are monitored & logged.'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.blue.withOpacity(0.06),
                AppColors.yellow.withOpacity(0.08),
              ],
            ),
            border: Border.all(color: AppColors.blue.withOpacity(0.12)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.blue, AppColors.yellow]),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Encrypted · ISO/IEC 27001',
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.blue),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Custom Painters
// ─────────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override bool shouldRepaint(_GridPainter _) => false;
}

class _LabScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2;
    final fill   = Paint()..style = PaintingStyle.fill;

    // Bench
    fill.color = const Color(0x880A1E50);
    canvas.drawRect(Rect.fromLTWH(0, size.height - 52, size.width, 52), fill);
    fill.color = const Color(0x33F5C400);
    canvas.drawRect(Rect.fromLTWH(0, size.height - 52, size.width, 3), fill);

    // Erlenmeyer flask (left)
    stroke.color = const Color(0x70FDE68A);
    fill.color   = const Color(0x44F5C400);
    final flask = Path()
      ..moveTo(46, 120)..lineTo(46, 168)
      ..lineTo(30, 192)..quadraticBezierTo(22, 210, 22, 226)
      ..lineTo(22, 232)..quadraticBezierTo(22, 242, 56, 242)
      ..quadraticBezierTo(90, 242, 88, 232)..lineTo(88, 226)
      ..quadraticBezierTo(88, 210, 80, 192)..lineTo(64, 168)
      ..lineTo(64, 120)..close();
    canvas.drawPath(flask, fill);
    canvas.drawPath(flask, stroke);
    fill.color = const Color(0x77F5C400);
    final liquid = Path()
      ..moveTo(44, 175)..quadraticBezierTo(30, 198, 28, 218)
      ..lineTo(28, 226)..quadraticBezierTo(28, 232, 56, 232)
      ..quadraticBezierTo(84, 232, 82, 226)..lineTo(82, 218)
      ..quadraticBezierTo(80, 198, 66, 175)..close();
    canvas.drawPath(liquid, fill);

    // Beaker (center)
    stroke.color = const Color(0x706EE7B7);
    fill.color   = const Color(0x3310B981);
    final beaker = Path()
      ..moveTo(157, 135)..lineTo(157, 232)
      ..quadraticBezierTo(157, 240, 185, 240)
      ..quadraticBezierTo(213, 240, 213, 232)..lineTo(213, 135)..close();
    canvas.drawPath(beaker, fill);
    canvas.drawPath(beaker, stroke);
    fill.color = const Color(0x6010B981);
    canvas.drawRect(const Rect.fromLTWH(160, 175, 50, 57), fill);
    stroke.color = Colors.white.withOpacity(0.28)..strokeWidth = 1;
    for (final y in [160.0, 185.0, 210.0]) {
      canvas.drawLine(Offset(205, y), Offset(213, y), stroke);
    }

    // Test tubes (right)
    final tubeColors = [
      const Color(0xFF93C5FD),
      const Color(0xFFFDE68A),
      const Color(0xFF6EE7B7),
    ];
    final tubeXs   = [268.0, 297.0, 326.0];
    final tubeFill = [0.55, 0.72, 0.38];
    for (int i = 0; i < 3; i++) {
      final x = tubeXs[i];
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 113, 20, 88), const Radius.circular(10));
      fill.color = tubeColors[i].withOpacity(0.12);
      canvas.drawRRect(rr, fill);
      stroke.color = tubeColors[i].withOpacity(0.4)..strokeWidth = 1;
      canvas.drawRRect(rr, stroke);
      final h = 88 * tubeFill[i];
      fill.color = tubeColors[i].withOpacity(0.55);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 1, 113 + (88 - h), 18, h), const Radius.circular(9)),
        fill);
    }

    // Round flask (right)
    stroke.color = const Color(0x7093C5FD)..strokeWidth = 1.2;
    fill.color   = const Color(0x223B82F6);
    canvas.drawCircle(const Offset(350, 210), 28, fill);
    canvas.drawCircle(const Offset(350, 210), 28, stroke);
    fill.color = const Color(0x553B82F6);
    final rflask = Path()
      ..moveTo(329, 196)..quadraticBezierTo(323, 210, 328, 224)
      ..quadraticBezierTo(336, 236, 350, 236)
      ..quadraticBezierTo(364, 236, 372, 224)
      ..quadraticBezierTo(377, 210, 371, 196)..close();
    canvas.drawPath(rflask, fill);
    fill.color = const Color(0x1593C5FD);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(344, 160, 12, 36), const Radius.circular(5)), fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(341, 158, 18, 6), const Radius.circular(3)), fill);

    // Molecule nodes top-right (faint)
    canvas.saveLayer(Rect.largest, Paint()..color = Colors.white.withOpacity(0.28));
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke..strokeWidth = 1
      ..color = const Color(0x4793C5FD);
    final nodes = [
      [290.0, 22.0, 5.0, 0xFF93C5FD],
      [318.0, 44.0, 7.0, 0xFFFDE68A],
      [348.0, 22.0, 5.0, 0xFF6EE7B7],
      [322.0, 78.0, 4.0, 0xFFC4B5FD],
      [272.0, 52.0, 4.0, 0xFFFDA4AF],
    ];
    for (final e in [[0,1],[1,2],[1,3],[0,4]]) {
      canvas.drawLine(
        Offset(nodes[e[0]][0], nodes[e[0]][1]),
        Offset(nodes[e[1]][0], nodes[e[1]][1]),
        edgePaint);
    }
    for (final n in nodes) {
      fill.color = Color(n[3].toInt());
      canvas.drawCircle(Offset(n[0], n[1]), n[2], fill);
    }
    canvas.restore();

    // DNA helix (left, very faint)
    final h1 = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5
      ..color = const Color(0x2293C5FD);
    final h2 = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5
      ..color = const Color(0x22FDE68A);
    final p1 = Path()..moveTo(18, 60);
    final p2 = Path()..moveTo(30, 60);
    for (int i = 0; i < 4; i++) {
      final y0 = 60.0 + i * 30;
      p1.quadraticBezierTo(30, y0 + 15, 18, y0 + 30);
      p2.quadraticBezierTo(18, y0 + 15, 30, y0 + 30);
    }
    canvas.drawPath(p1, h1);
    canvas.drawPath(p2, h2);
    final cross = Paint()..color = Colors.white.withOpacity(0.13)..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(Offset(18, 72 + i * 30), Offset(30, 72 + i * 30), cross);
    }
  }
  @override bool shouldRepaint(_LabScenePainter _) => false;
}
