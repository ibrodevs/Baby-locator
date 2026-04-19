import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_providers.dart';
import '../../core/theme/app_colors.dart';

/// Kid-friendly auth screen with two modes: Sign In and Register (with invite code).
class ChildAuthScreen extends StatelessWidget {
  const ChildAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fun stacked circles
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primarySoft,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.navy],
                        ),
                      ),
                      child: const Icon(Icons.child_care_rounded,
                          size: 44, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                t.childAuthTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                t.childAuthSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 36),

              // Auth form (login / register toggle)
              const Expanded(child: _ChildAuthBody()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildAuthBody extends ConsumerStatefulWidget {
  const _ChildAuthBody();

  @override
  ConsumerState<_ChildAuthBody> createState() => _ChildAuthBodyState();
}

class _ChildAuthBodyState extends ConsumerState<_ChildAuthBody> {
  bool _isRegister = false;

  // Login fields
  final _loginUsername = TextEditingController();
  final _loginPassword = TextEditingController();

  // Register fields
  final _inviteCode = TextEditingController();
  final _regName = TextEditingController();
  final _regUsername = TextEditingController();
  final _regPassword = TextEditingController();
  bool _codeVerified = false;

  bool _busy = false;
  String? _err;

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await ref.read(sessionProvider.notifier).login(
            username: _loginUsername.text.trim(),
            password: _loginPassword.text,
          );
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _proceedWithCode() {
    if (_inviteCode.text.trim().isEmpty) return;
    setState(() {
      _codeVerified = true;
      _err = null;
    });
  }

  Future<void> _register() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await ref.read(sessionProvider.notifier).registerChild(
            code: _inviteCode.text.trim(),
            username: _regUsername.text.trim(),
            password: _regPassword.text,
            displayName: _regName.text.trim(),
          );
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isRegister) ...[
            // === LOGIN MODE ===
            _KidField(
              controller: _loginUsername,
              label: t.username,
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 14),
            _KidField(
              controller: _loginPassword,
              label: t.password,
              icon: Icons.lock_rounded,
              obscure: true,
            ),
            const SizedBox(height: 20),
            if (_err != null) _ErrorBox(message: _err!),
            _BigButton(
              label: t.childSignIn,
              icon: Icons.login_rounded,
              busy: _busy,
              onTap: _login,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => setState(() {
                  _isRegister = true;
                  _err = null;
                  _codeVerified = false;
                }),
                child: Text(
                  t.dontHaveCode,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ] else if (!_codeVerified) ...[
            // === REGISTER MODE — STEP 1: ENTER CODE ===
            Text(
              t.childRegisterTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.childRegisterSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            _KidField(
              controller: _inviteCode,
              label: t.inviteCode,
              icon: Icons.vpn_key_rounded,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            if (_err != null) _ErrorBox(message: _err!),
            _BigButton(
              label: t.next,
              icon: Icons.arrow_forward_rounded,
              busy: _busy,
              onTap: _proceedWithCode,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => setState(() {
                  _isRegister = false;
                  _err = null;
                }),
                child: Text(
                  t.alreadyHaveAccount,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ] else ...[
            // === REGISTER MODE — STEP 2: PROFILE ===
            Text(
              t.setupYourProfile,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.enterYourDetails,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            // Show the entered code as a chip
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.vpn_key_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      _inviteCode.text.trim().toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() {
                        _codeVerified = false;
                        _err = null;
                      }),
                      child: Icon(Icons.edit_rounded,
                          size: 16, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _KidField(
              controller: _regName,
              label: t.displayNameHint,
              icon: Icons.badge_rounded,
            ),
            const SizedBox(height: 14),
            _KidField(
              controller: _regUsername,
              label: t.username,
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 14),
            _KidField(
              controller: _regPassword,
              label: t.password,
              icon: Icons.lock_rounded,
              obscure: true,
            ),
            const SizedBox(height: 20),
            if (_err != null) _ErrorBox(message: _err!),
            _BigButton(
              label: t.register,
              icon: Icons.how_to_reg_rounded,
              busy: _busy,
              onTap: _register,
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message,
            style: const TextStyle(color: AppColors.danger, fontSize: 13)),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.label,
    required this.icon,
    required this.busy,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _KidField extends StatelessWidget {
  const _KidField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.textCapitalization = TextCapitalization.none,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      autocorrect: false,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 42, minHeight: 0),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.dividerLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.dividerLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
