import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/child_theme.dart';

class ChildAuthScreen extends StatelessWidget {
  const ChildAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    const palette = ChildPalette.girl;
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(primary: palette.primary),
        extensions: <ThemeExtension<dynamic>>[palette],
      ),
      child: Scaffold(
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
                        color: palette.primarySoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: palette.primary),
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
                          color: palette.primarySoft,
                          boxShadow: [
                            BoxShadow(
                              color: palette.primary.withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: palette.heroGradient,
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
                  style: TextStyle(
                    color: palette.titleColor,
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
  final _inviteCode = TextEditingController();
  final _regName = TextEditingController();
  bool _codeVerified = false;

  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _inviteCode.dispose();
    _regName.dispose();
    super.dispose();
  }

  void _proceedWithCode() {
    if (_inviteCode.text.trim().isEmpty) {
      setState(() => _err = S.of(context).invalidInviteCode);
      return;
    }
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
    final palette = ChildPalette.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_codeVerified) ...[
            // === REGISTER MODE — STEP 1: ENTER CODE ===
            Text(
              t.childRegisterTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: palette.titleColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.childRegisterSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
          ] else ...[
            // === REGISTER MODE — STEP 2: PROFILE ===
            Text(
              t.setupYourProfile,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: palette.titleColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.enterYourDetails,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
                  color: palette.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.vpn_key_rounded,
                        size: 16, color: palette.primary),
                    const SizedBox(width: 6),
                    Text(
                      _inviteCode.text.trim().toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: palette.primary,
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
                          size: 16, color: palette.primary),
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
    final palette = ChildPalette.of(context);
    return Material(
      color: palette.primary,
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
    this.textCapitalization = TextCapitalization.none,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final palette = ChildPalette.of(context);
    return TextField(
      controller: controller,
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
          child: Icon(icon, color: palette.primary, size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 0),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.dividerLight,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.dividerLight,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
      ),
    );
  }
}
