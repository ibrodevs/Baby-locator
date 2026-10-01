# Исправление isMonitoringTool — 1 октября 2026

## Выдача файлов 20 и 21

По запросу пользователя подготовлены два отдельно подписанных AAB с
versionName `1.0.7`, кодами 20 и 21. Финальные файлы и инструкция находятся в
`../Google-Play-1.0.7/`:

- `baby-locator-1.0.7-v20.aab`: SHA-256 `120c01289ccbf73be4898203532555de1a7947779e4c5be4d62bdbfb2578d39b`.
- `baby-locator-1.0.7-v21.aab`: SHA-256 `a6e794f91f50c87db595f1b4b2862d7b293c1ff7bb11a933ec4001302ad2d9ae`.
- [Пошаговая инструкция для Play Console](../Google-Play-1.0.7/ИНСТРУКЦИЯ.md).
- `verification/`: отдельные отчёты и манифесты AAB/APK для обеих версий.

У обоих AAB проверены метаданные, подпись и совпадение сертификата с предыдущим
ключом загрузки. Манифесты AAB отличаются только versionCode.
Version 21 собрана через `flutter build appbundle --release --build-name=1.0.7 --build-number=21`;
`pubspec.yaml` затем обновлён до `1.0.7+21`.
Для проверки сохранённой версии 20 используйте `--expected-version-code 20`.
По последнему запросу пользователя переданы файлы для самостоятельной загрузки;
отправка на рассмотрение не выполнена.

## Подтверждённая проблема

В локальных AAB `versionCode=18` и `versionCode=19` параметр
`isMonitoringTool=child_monitoring` находился непосредственно под `<manifest>`.
Это установлено через `bundletool dump manifest` для обоих готовых файлов,
а не только по исходному XML. Ошибку структуры в исходнике скрывал
`tools:ignore="WrongManifestParent"`.

В Android метаданные приложения должны быть дочерним элементом
`<application>`. Пример в справке Google Play сокращён и не является
основанием для переноса `<meta-data>` в корень манифеста.

Прежний preflight искал две строки через `grep`, поэтому пропускал неправильное
расположение, значения в разных элементах и старый AAB с другой версией.
Кроме того, Flutter при наличии нескольких AAB в каталоге вывода сообщал имя
старого `app-release-v18.aab`, хотя новый файл `app-release.aab` содержал код 20.
Старые AAB сохранены в `build/monitoring-audit/rejected/`; для загрузки выделен
однозначно названный файл ниже.

## Изменения и проверенный файл

В общем манифесте для всех вариантов сборки:

```xml
<application ...>
    <meta-data
        android:name="isMonitoringTool"
        android:value="child_monitoring" />
</application>
```

`android/app/build.gradle.kts` проверяет объединённый манифест через
`SingleArtifact.MERGED_MANIFEST` до упаковки. Задачи
`verifyReleaseMonitoringManifest`, `verifyDebugMonitoringManifest` и
`verifyProfileMonitoringManifest` требуют ровно один флаг на уровне приложения
с буквальным значением `child_monitoring`. Проверка не исправляет XML молча:
при ошибке сборка завершается с `GradleException`.

| Поле | Проверенное значение |
| --- | --- |
| AAB | `build/google-play/v20/baby-locator-1.0.7-v20.aab` |
| applicationId | `com.company.familysecurity` |
| versionName / versionCode | `1.0.7` / `20` |
| SHA-256 файла | `120c01289ccbf73be4898203532555de1a7947779e4c5be4d62bdbfb2578d39b` |
| SHA-256 сертификата загрузки | `97fad0260aa333502d0f8075ed6d959705963be11fef9c5dc576493ca610891b` |
| Декларация | `manifest/application/meta-data`, `isMonitoringTool=child_monitoring` |

Выполнено:

- `flutter build appbundle --release` завершился успешно.
- Проверены объединённые манифесты Release, Debug и Profile.
- `bundletool validate` и `jarsigner -verify` прошли; сертификат AAB совпадает с v18.
- Манифест распакован непосредственно из финального AAB.
- Через `bundletool build-apks --mode=universal` получен диагностический APK;
  `apkanalyzer manifest print` подтвердил флаг под `<application>` и в APK.
  Этот диагностический APK подписан debug-ключом только для локальной проверки;
  в Google Play предназначен AAB с сертификатом загрузки из таблицы.
- Семь регрессионных тестов XML-валидатора прошли.
- Отрицательная интеграционная проверка: перенос флага обратно в корень
  действительно остановил Gradle. После восстановления проверка снова прошла.
- Оба старых AAB 18/19 отклоняются новым валидатором именно из-за структуры XML.
- Preflight финального файла: 28 проверок пройдено, 0 ошибок.

Машинный отчёт и извлечённый манифест:
`build/google-play/v20/verification.json`, `build/google-play/v20/AndroidManifest.xml`.
Логи проверок: `build/monitoring-audit/`.
Эти проверки подтверждают исправление декларации и целостность артефакта;
они не являются подтверждением всей политики или одобрением Google Play.

## Состояние Play Console при проверке

| Трек | Обнаружено 1 октября 2026 | Что требуется |
| --- | --- | --- |
| Production | Рабочий выпуск 18 (1.0.7) отклонён | Заменить выпуском 20, не сохранять AAB 18 |
| Internal testing | Активен выпуск 2 (1.0.1), доступен тестировщикам | Заменить выпуском 20 или деактивировать |
| Closed testing — Alpha | Активен выпуск 2 (1.0.1) | Заменить выпуском 20 или деактивировать |
| Open testing | Трек приостановлен; выпуск 19 (1.0.7) отклонён | Не возвращать в распространение 19; использовать исправленный AAB при возобновлении |

Манифест версии 2 не извлекался: наличие флага в ней не подтверждено.
В Git флаг уже присутствовал под `<application>` до локального переноса в корень,
поэтому нельзя объяснять все предыдущие отказы только текущей ошибкой XML.
Активные старые тестовые версии — отдельное условие повторной отправки:
Google прямо требует декларацию во всех кодах версий во всех треках.

Создан проект рабочего выпуска 20 (ещё без загруженного AAB).
Загрузка через расширение Chrome заблокирована разрешением локальных файлов;
повторная отправка на рассмотрение пока не выполнена.

## Проверка следующих релизов

Использовать Java 17 и официальный [bundletool](https://github.com/google/bundletool/releases/tag/1.18.3).
JAR можно положить в `build/tools/bundletool-all-1.18.3.jar` либо задать
`BUNDLETOOL_JAR`.

```bash
flutter build appbundle --release
python3 -m unittest discover -s scripts -p 'test_*.py' -v
bash scripts/google_play_preflight.sh build/app/outputs/bundle/release/app-release.aab
```

Валидатор сравнивает версию AAB с `pubspec.yaml`. Для намеренного
`--build-number` можно отдельно вызвать
`scripts/verify_monitoring_manifest.py --bundle PATH --expected-version-code N`.
Номер N должен быть неиспользованным и больше предыдущего в Play Console.
Нельзя определять версию только по имени файла или старому отчёту.

Перед повторной отправкой проверить каждый активный трек, исключить старые
нарушающие AAB из сохраняемых артефактов и отправить изменения на рассмотрение.
Исторические записи в библиотеке не равны активному распространению;
удалять историю всех прежних релизов не требуется.

## Первичные источники

- [Google Play: Use of the isMonitoringTool Flag](https://support.google.com/googleplay/android-developer/answer/12955211?hl=en)
- [Android: допустимые родители meta-data](https://developer.android.com/guide/topics/manifest/meta-data-element)
- [Google Play: Stalkerware](https://support.google.com/googleplay/android-developer/answer/9888380#commercial-spyware)
