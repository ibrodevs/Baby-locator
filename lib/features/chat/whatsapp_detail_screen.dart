import 'package:flutter/material.dart';
import 'package:kid_security/l10n/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';

class WhatsAppDetailScreen extends StatelessWidget {
  const WhatsAppDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Text(
                    t.appName,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {}),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_whatsAppTitle(context),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text(_monitoringActive(context, '2m'),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                children: [
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Column(
                      children: [
                        _Ring(value: 0.92, label: '92', sub: _safetyScoreUpper(context)),
                        const SizedBox(height: 14),
                        Text(_conversationAnalysis(context),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text(
                          _conversationAnalysisSummary(context),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            StatusBadge(
                                text: _positiveIntent(context),
                                color: AppColors.success),
                            StatusBadge(
                                text: _homeworkLabel(context),
                                color: AppColors.textSecondaryLight),
                            StatusBadge(
                                text: _gamingLabel(context),
                                color: AppColors.textSecondaryLight),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(_todayAtTime(context, '4:15 PM'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 1.2,
                        )),
                  ),
                  const SizedBox(height: 10),
                  const _ChatMsg(
                      from: 'Alex',
                      textKey: _ChatMessageKey.historyAssignment,
                      mine: false),
                  _ChatMsg(
                      from: 'Leo',
                      textKey: _ChatMessageKey.almostFinish,
                      mine: true),
                  _ChatMsg(
                      from: 'Alex',
                      textKey: _ChatMessageKey.homeworkFirst,
                      mine: false,
                      keyword: _homeworkLabel(context).toLowerCase()),
                  Padding(
                    padding: const EdgeInsets.only(left: 44, bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text(_keywordLogged(context, _homeworkLabel(context)),
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6)),
                      ],
                    ),
                  ),
                  _ChatMsg(
                      from: 'Leo',
                      textKey: _ChatMessageKey.smartMove,
                      mine: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.value, required this.label, required this.sub});
  final double value;
  final String label;
  final String sub;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 10,
              backgroundColor: AppColors.dividerLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatMsg extends StatelessWidget {
  const _ChatMsg({
    required this.from,
    required this.textKey,
    required this.mine,
    this.keyword,
  });
  final String from;
  final _ChatMessageKey textKey;
  final bool mine;
  final String? keyword;

  @override
  Widget build(BuildContext context) {
    final text = switch (textKey) {
      _ChatMessageKey.historyAssignment => _msgHistoryAssignment(context),
      _ChatMessageKey.almostFinish => _msgAlmostFinish(context),
      _ChatMessageKey.homeworkFirst => _msgHomeworkFirst(context),
      _ChatMessageKey.smartMove => _msgSmartMove(context),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!mine) ...[
            const AvatarCircle(
                initials: 'A', color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: mine ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: mine
                    ? null
                    : [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: mine ? Colors.white : AppColors.textPrimaryLight,
                    fontSize: 14,
                  ),
                  children: _buildSpans(text, keyword, mine),
                ),
              ),
            ),
          ),
          if (mine) ...[
            const SizedBox(width: 8),
            const AvatarCircle(
                initials: 'L', color: AppColors.accent, size: 28),
          ],
        ],
      ),
    );
  }

  List<TextSpan> _buildSpans(String text, String? keyword, bool mine) {
    if (keyword == null) return [TextSpan(text: text)];
    final idx = text.toLowerCase().indexOf(keyword.toLowerCase());
    if (idx < 0) return [TextSpan(text: text)];
    return [
      TextSpan(text: text.substring(0, idx)),
      TextSpan(
        text: text.substring(idx, idx + keyword.length),
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: mine ? Colors.white : AppColors.primary,
          decoration: TextDecoration.underline,
        ),
      ),
      TextSpan(text: text.substring(idx + keyword.length)),
    ];
  }
}

enum _ChatMessageKey {
  historyAssignment,
  almostFinish,
  homeworkFirst,
  smartMove,
}

String _lang(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

String _pick(BuildContext context, Map<String, String> values) =>
    values[_lang(context)] ?? values['en']!;

String _whatsAppTitle(BuildContext context) => _pick(context, {
      'en': 'WhatsApp: Leo & Alex',
      'ru': 'WhatsApp: Лео и Алекс',
    });

String _monitoringActive(BuildContext context, String time) =>
    _pick(context, {
      'ar': 'المراقبة نشطة · آخر مزامنة منذ $time',
      'az': 'Monitorinq aktivdir · Son sinxronizasiya $time əvvəl',
      'de': 'Überwachung aktiv · Zuletzt vor $time synchronisiert',
      'en': 'Monitoring active · Last synced $time ago',
      'es': 'Monitorización activa · Última sincronización hace $time',
      'fr': 'Surveillance active · Dernière synchro il y a $time',
      'hy': 'Դիտարկումն ակտիվ է · Վերջին համաժամեցումը $time առաջ',
      'it': 'Monitoraggio attivo · Ultima sincronizzazione $time fa',
      'ka': 'მონიტორინგი აქტიურია · ბოლო სინქრონიზაცია $time წინ',
      'kk': 'Бақылау белсенді · Соңғы синхрондау $time бұрын',
      'ky': 'Байкоо активдүү · Акыркы шайкештештирүү $time мурун',
      'pl': 'Monitoring aktywny · Ostatnia synchronizacja $time temu',
      'pt': 'Monitoramento ativo · Última sincronização há $time',
      'ru': 'Мониторинг активен · Последняя синхронизация $time назад',
      'tg': 'Назорат фаъол аст · Ҳамоҳангсозии охирин $time пеш',
      'tk': 'Gözegçilik işjeň · Soňky utgaşdyrma $time öň',
      'uz': 'Monitoring faol · Oxirgi sinxronlash $time oldin',
    });

String _safetyScoreUpper(BuildContext context) => _pick(context, {
      'en': 'SAFETY SCORE',
      'ru': 'ИНДЕКС БЕЗОПАСНОСТИ',
    });

String _conversationAnalysis(BuildContext context) => _pick(context, {
      'en': 'Conversation Analysis',
      'ru': 'Анализ переписки',
    });

String _conversationAnalysisSummary(BuildContext context) => _pick(context, {
      'en':
          'AI detected a constructive discussion about academic responsibilities. Interaction remains high-trust and low-risk.',
      'ru':
          'ИИ обнаружил конструктивное обсуждение учебных обязанностей. Общение остаётся доверительным и с низким риском.',
    });

String _positiveIntent(BuildContext context) => _pick(context, {
      'en': 'POSITIVE INTENT',
      'ru': 'ПОЗИТИВНОЕ НАМЕРЕНИЕ',
    });

String _homeworkLabel(BuildContext context) => _pick(context, {
      'en': 'HOMEWORK',
      'ru': 'ДОМАШНЕЕ ЗАДАНИЕ',
    });

String _gamingLabel(BuildContext context) => _pick(context, {
      'en': 'GAMING',
      'ru': 'ИГРЫ',
    });

String _todayAtTime(BuildContext context, String time) => _pick(context, {
      'en': 'TODAY, $time',
      'ru': 'СЕГОДНЯ, $time',
    });

String _keywordLogged(BuildContext context, String keyword) =>
    _pick(context, {
      'en': 'KEYWORD LOGGED: $keyword',
      'ru': 'ЗАФИКСИРОВАНО КЛЮЧЕВОЕ СЛОВО: $keyword',
    });

String _msgHistoryAssignment(BuildContext context) => _pick(context, {
      'en':
          'Hey Leo, did you finish the history assignment for tomorrow? It’s huge.',
      'ru':
          'Привет, Лео, ты закончил задание по истории на завтра? Оно огромное.',
    });

String _msgAlmostFinish(BuildContext context) => _pick(context, {
      'en':
          'Almost. Just need to finish the part about the industrial revolution. Want to jump on Discord after?',
      'ru':
          'Почти. Осталось закончить часть про промышленную революцию. Потом зайдём в Discord?',
    });

String _msgHomeworkFirst(BuildContext context) => _pick(context, {
      'en':
          "Sure, but let's do homework first so we don't get in trouble. My mom is checking my grades today.",
      'ru':
          'Конечно, но давай сначала сделаем домашку, чтобы не попасть в неприятности. Мама сегодня проверяет мои оценки.',
    });

String _msgSmartMove(BuildContext context) => _pick(context, {
      'en': "Smart move. I'll message you when I'm done.",
      'ru': 'Хорошая мысль. Напишу тебе, когда закончу.',
    });
