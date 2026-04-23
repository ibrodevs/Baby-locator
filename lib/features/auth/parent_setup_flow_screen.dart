import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers/session_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_feedback.dart';

class ParentSetupFlowScreen extends ConsumerStatefulWidget {
  const ParentSetupFlowScreen({
    super.key,
    required this.onFinished,
  });

  final VoidCallback onFinished;

  @override
  ConsumerState<ParentSetupFlowScreen> createState() =>
      _ParentSetupFlowScreenState();
}

class _ParentSetupFlowScreenState extends ConsumerState<ParentSetupFlowScreen> {
  final TextEditingController _childNameController = TextEditingController();

  int _stepIndex = 0;
  String? _childGender;
  XFile? _avatarFile;
  String? _inviteCode;
  bool _busy = false;

  static const int _stepCount = 5;

  @override
  void dispose() {
    _childNameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    if (picked == null || !mounted) return;
    setState(() => _avatarFile = picked);
  }

  Future<void> _continue() async {
    if (_stepIndex == 0) {
      if (_childGender == null) {
        showAppSnackBar(
          context,
          'Выберите вариант: сын или дочка.',
          type: AppFeedbackType.warning,
        );
        return;
      }
      setState(() => _stepIndex = 1);
      return;
    }

    if (_stepIndex == 1) {
      if (_childNameController.text.trim().isEmpty) {
        showAppSnackBar(
          context,
          'Введите имя ребёнка.',
          type: AppFeedbackType.warning,
        );
        return;
      }
      setState(() => _stepIndex = 2);
      return;
    }

    if (_stepIndex == 2) {
      await _completeSetup();
      return;
    }

    if (_stepIndex == 3) {
      setState(() => _stepIndex = 4);
      return;
    }

    widget.onFinished();
  }

  void _goBack() {
    if (_busy || _stepIndex == 0 || _stepIndex >= 3) return;
    setState(() => _stepIndex -= 1);
  }

  Future<void> _completeSetup() async {
    setState(() => _busy = true);
    try {
      final child = await ApiClient.instance.createChild(
        displayName: _childNameController.text.trim(),
        gender: _childGender,
      );
      final childId = child['id'] as int;

      if (_avatarFile != null) {
        await ApiClient.instance.uploadChildAvatar(
          childId,
          File(_avatarFile!.path),
        );
      }

      final invite =
          await ApiClient.instance.generateInviteCode(childId: childId);

      await ref.read(parentChildrenProvider.notifier).refresh();
      ref.read(selectedChildIdProvider.notifier).state = childId;

      if (!mounted) return;
      setState(() {
        _inviteCode = invite['code'] as String?;
        _stepIndex = 3;
      });
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Не удалось завершить настройку: $e',
        type: AppFeedbackType.error,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _copyCode() {
    final code = _inviteCode;
    if (code == null) return;
    Clipboard.setData(ClipboardData(text: code));
    showAppSnackBar(
      context,
      'Код скопирован.',
      type: AppFeedbackType.success,
    );
  }

  void _shareInvite() {
    final code = _inviteCode;
    if (code == null) return;
    SharePlus.instance.share(
      ShareParams(
        text:
            'Установите Kid Security на телефон ребёнка и введите код: $code\n\nhttps://backend21.pythonanywhere.com/invite/$code',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentName = ref.watch(sessionProvider).user?.displayName ?? '';
    final titleName =
        parentName.trim().isNotEmpty ? parentName.trim() : 'родитель';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (_stepIndex > 0 && _stepIndex < 4)
                        IconButton(
                          onPressed: _busy ? null : _goBack,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        )
                      else
                        const SizedBox(width: 48),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Настройка семьи',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Поможем быстро подключить ребёнка, $titleName.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: (_stepIndex + 1) / _stepCount,
                      backgroundColor: Colors.white,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  key: ValueKey(_stepIndex),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: _buildStep(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _busy ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _buttonLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _buttonLabel {
    return switch (_stepIndex) {
      0 => 'Продолжить',
      1 => 'Сохранить имя',
      2 => 'Завершить настройку',
      3 => 'Дальше',
      _ => 'Открыть приложение',
    };
  }

  Widget _buildStep() {
    return switch (_stepIndex) {
      0 => _buildGenderStep(),
      1 => _buildNameStep(),
      2 => _buildPhotoStep(),
      3 => _buildCongratsStep(),
      _ => _buildInviteStep(),
    };
  }

  Widget _buildGenderStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepHeading(
          title: 'У вас сын или дочка?',
          subtitle: 'С этого начнем создание профиля ребёнка.',
        ),
        const SizedBox(height: 24),
        _ChoiceCard(
          selected: _childGender == 'boy',
          icon: Icons.male_rounded,
          title: 'Сын',
          subtitle: 'Создать профиль мальчика',
          onTap: () => setState(() => _childGender = 'boy'),
        ),
        const SizedBox(height: 14),
        _ChoiceCard(
          selected: _childGender == 'girl',
          icon: Icons.female_rounded,
          title: 'Дочка',
          subtitle: 'Создать профиль девочки',
          onTap: () => setState(() => _childGender = 'girl'),
        ),
      ],
    );
  }

  Widget _buildNameStep() {
    final exampleName = _childGender == 'girl' ? 'Катя' : 'Иван';
    final label = _childGender == 'girl' ? 'дочку' : 'сына';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeading(
          title: 'Как зовут вашего $label?',
          subtitle: 'Это имя сразу увидит ребёнок после входа по коду.',
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.dividerLight),
          ),
          child: TextField(
            controller: _childNameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: exampleName,
            ),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepHeading(
          title: 'Добавим фото',
          subtitle:
              'Это фото появится в профиле ребёнка. Можно пропустить и добавить позже.',
        ),
        const SizedBox(height: 24),
        Expanded(
          child: InkWell(
            onTap: _pickPhoto,
            borderRadius: BorderRadius.circular(32),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.dividerLight),
              ),
              child: Center(
                child: _avatarFile == null
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_a_photo_rounded,
                            size: 44,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Выбрать фото',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.file(
                              File(_avatarFile!.path),
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Нажмите, чтобы выбрать другое фото',
                            style: TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCongratsStep() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.successSoft,
              child: Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 42,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Поздравляем!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Профиль ребёнка уже готов. Осталось подключить телефон ребёнка по коду.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteStep() {
    final childName = _childNameController.text.trim();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepHeading(
            title: 'Установите приложение для ребёнка',
            subtitle:
                'Откройте приложение на телефоне ${childName.isEmpty ? 'ребёнка' : childName} и введите этот код.',
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _copyCode,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  const Text(
                    'Числовой код',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _inviteCode ?? '------',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copy_rounded,
                          size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Нажмите, чтобы скопировать',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: _shareInvite,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.share_rounded),
              label: const Text(
                'Пригласить ребёнка',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text(
              'На телефоне ребёнка теперь не нужен логин и пароль: достаточно открыть приложение и ввести код.',
              style: TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.navy,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Ink(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.dividerLight,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
