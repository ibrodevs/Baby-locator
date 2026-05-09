// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SAr extends S {
  SAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Family security';

  @override
  String get signInOrCreate => 'سجّل الدخول أو أنشئ حساب والد';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get createParentAccount => 'إنشاء حساب والد';

  @override
  String get childrenSignInHint =>
      'يسجّل الأطفال الدخول ببيانات الاعتماد التي أنشأها والدهم.';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get displayName => 'الاسم المعروض';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get navMap => 'الخريطة';

  @override
  String get navActivity => 'النشاط';

  @override
  String get navChat => 'المحادثة';

  @override
  String get navStats => 'الإحصاءات';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get waitingForLocation => 'في انتظار مشاركة الأطفال لموقعهم...';

  @override
  String get addChildToTrack => 'أضف طفلاً لبدء التتبع';

  @override
  String get manageChildren => 'إدارة الأطفال';

  @override
  String get loud => 'صوت عالٍ';

  @override
  String get around => 'حول';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String messageChild(String childName) {
    return 'مراسلة $childName';
  }

  @override
  String get history => 'السجل';

  @override
  String lastUpdated(String time) {
    return 'آخر تحديث: $time';
  }

  @override
  String get statusActive => 'نشط';

  @override
  String get statusPaused => 'متوقف';

  @override
  String get statusOffline => 'غير متصل';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int minutes) {
    return 'منذ $minutes د';
  }

  @override
  String hoursAgo(int hours) {
    return 'منذ $hours س';
  }

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get addChildToSeeActivity => 'أضف طفلاً لمشاهدة النشاط';

  @override
  String get activity => 'النشاط';

  @override
  String get today => 'اليوم';

  @override
  String get leftArea => 'غادر المنطقة';

  @override
  String get arrivedAtLocation => 'وصل إلى الموقع';

  @override
  String get phoneCharging => 'الهاتف قيد الشحن';

  @override
  String batteryReached(int battery) {
    return 'وصلت البطارية إلى $battery%';
  }

  @override
  String get batteryLow => 'البطارية منخفضة';

  @override
  String batteryDropped(int battery) {
    return 'انخفضت البطارية إلى $battery%';
  }

  @override
  String get currentLocationTitle => 'الموقع الحالي';

  @override
  String get locationShared => 'تمت مشاركة الموقع';

  @override
  String get batteryStatus => 'حالة البطارية';

  @override
  String batteryAt(int battery) {
    return 'البطارية عند $battery%';
  }

  @override
  String noActivityYet(String childName) {
    return 'لا يوجد نشاط بعد. ستظهر الأحداث عندما يشارك $childName موقعه.';
  }

  @override
  String get safeZones => 'الأماكن';

  @override
  String get addNew => 'إضافة جديد';

  @override
  String get noSafeZonesYet => 'لا توجد أماكن بعد';

  @override
  String zone(String zoneName) {
    return 'المكان: $zoneName';
  }

  @override
  String get editZone => 'تعديل المكان';

  @override
  String get activeToday => 'نشط اليوم';

  @override
  String get inactiveToday => 'غير نشط اليوم';

  @override
  String get disabled => 'معطّل';

  @override
  String get dailySafetyScore => 'درجة الأمان اليومية';

  @override
  String get noLocationUpdatesYet => 'لا توجد تحديثات للموقع اليوم';

  @override
  String safetyScoreDetails(int inZoneUpdates, int totalUpdates) {
    return '$inZoneUpdates من $totalUpdates تحديثاً كانت داخل المناطق الآمنة اليوم';
  }

  @override
  String coverage(int percent) {
    return 'التغطية: $percent%';
  }

  @override
  String currentZone(String zoneName) {
    return 'المكان الحالي: $zoneName';
  }

  @override
  String get addSafeZone => 'إضافة مكان جديد';

  @override
  String get editSafeZone => 'تعديل المكان';

  @override
  String get deleteZoneTitle => 'حذف المكان؟';

  @override
  String get deleteZoneMessage => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get zoneEnabled => 'المكان مفعّل';

  @override
  String get zoneName => 'اسم المكان';

  @override
  String get zoneNameHint => 'مثلاً: المنزل، المدرسة';

  @override
  String get activeWhen => 'نشط عند';

  @override
  String get always => 'دائماً';

  @override
  String get daysOfWeek => 'أيام الأسبوع';

  @override
  String get chooseAtLeastOneDay => 'اختر يوماً واحداً على الأقل لهذا الجدول.';

  @override
  String get radius => 'النطاق';

  @override
  String get locationMoveMap => 'الموقع (حرّك الخريطة لتحديد نقطة المركز)';

  @override
  String get moveMapToSetCenter => 'حرّك الخريطة لتحديد مركز المكان';

  @override
  String get createSafeZone => 'إنشاء مكان';

  @override
  String get updateSafeZone => 'تحديث المكان';

  @override
  String get pleaseEnterZoneName => 'يرجى إدخال اسم المكان';

  @override
  String get chooseAtLeastOneDayError => 'اختر يوماً نشطاً واحداً على الأقل';

  @override
  String get addChildToChat => 'أضف طفلاً لبدء المحادثة';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد. قل مرحباً!';

  @override
  String get sendMessage => 'اكتب رسالة...';

  @override
  String failedToSend(String error) {
    return 'فشل الإرسال: $error';
  }

  @override
  String helloUser(String name) {
    return 'مرحباً، $name!';
  }

  @override
  String get kidMode => 'وضع الطفل';

  @override
  String get myLocation => 'موقعي';

  @override
  String get waitingForGps => 'في انتظار GPS...';

  @override
  String sharedWithParent(String time) {
    return 'تمت المشاركة مع الوالد · $time';
  }

  @override
  String get notSharedYet => 'لم تتم المشاركة بعد';

  @override
  String get imSafe => 'أنا بأمان';

  @override
  String get sos => 'SOS';

  @override
  String get sentImSafe => 'تم إرسال \"أنا بأمان\" إلى والدك';

  @override
  String get sosMessage => 'SOS! أحتاج إلى مساعدة!';

  @override
  String sosLocation(String address) {
    return ' الموقع: $address';
  }

  @override
  String get sosSent => 'تم إرسال SOS — سيتم إشعار الوالد';

  @override
  String get allowUsageAccess => 'السماح بالوصول إلى استخدام التطبيقات';

  @override
  String get usageAccessDescription =>
      'يتيح ذلك للوحة تحكم الوالد عرض بيانات وقت الشاشة الفعلية وقيود التطبيقات من هذا الهاتف.';

  @override
  String get openUsageAccess => 'فتح وصول الاستخدام';

  @override
  String syncError(String error) {
    return 'خطأ في المزامنة: $error';
  }

  @override
  String get iphoneLimitation => 'قيود iPhone';

  @override
  String get iphoneUsageDescription =>
      'لا يوجد في iPhone شاشة وصول للاستخدام بأسلوب Android. يتطلب وقت الشاشة لكل تطبيق والحظر المباشر للتطبيقات واجهات برمجة Screen Time من Apple وصلاحيات خاصة، لذا لا يعمل هذا الزر على iOS.';

  @override
  String get turnOnLocation => 'تشغيل خدمات الموقع';

  @override
  String get locationIsOff => 'الموقع معطّل. فعّله للمشاركة مع الوالد.';

  @override
  String get openLocationSettings => 'فتح إعدادات الموقع';

  @override
  String get locationBlocked => 'إذن الموقع محظور';

  @override
  String get enableLocationAccess =>
      'فعّل الوصول إلى الموقع في إعدادات النظام.';

  @override
  String get openAppSettings => 'فتح إعدادات التطبيق';

  @override
  String get allowLocationToShare => 'اسمح بالموقع للمشاركة';

  @override
  String get grantLocationPermission =>
      'امنح الإذن حتى يتمكن والدك من معرفة مكانك.';

  @override
  String get allowLocation => 'السماح بالموقع';

  @override
  String get myChildren => 'أطفالي';

  @override
  String get addChild => 'إضافة طفل';

  @override
  String get noChildrenYet =>
      'لا يوجد أطفال بعد. اضغط على \"إضافة طفل\" لإنشاء حساب.';

  @override
  String get parentAccount => 'حساب الوالد';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get deleteChildTitle => 'حذف الطفل؟';

  @override
  String deleteChildMessage(String childName) {
    return 'حذف $childName وجميع سجلات النشاط المرتبطة؟';
  }

  @override
  String childDeleted(String childName) {
    return 'تم حذف $childName';
  }

  @override
  String failedToDeleteChild(String error) {
    return 'فشل حذف الطفل: $error';
  }

  @override
  String get avatarUpdated => 'تم تحديث الصورة الرمزية';

  @override
  String failedGeneric(String error) {
    return 'فشل: $error';
  }

  @override
  String get createChildAccount => 'إنشاء حساب طفل';

  @override
  String get childSignInHint => 'سيسجّل طفلك الدخول بهذه البيانات على جهازه.';

  @override
  String get displayNameHint => 'الاسم المعروض (مثلاً: علي)';

  @override
  String get create => 'إنشاء';

  @override
  String get editChildProfile => 'تعديل ملف الطفل';

  @override
  String get save => 'حفظ';

  @override
  String get deleteChild => 'حذف الطفل';

  @override
  String get track => 'تتبع';

  @override
  String get edit => 'تعديل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get parent => 'الوالد';

  @override
  String get child => 'الطفل';

  @override
  String get editProfileDetails => 'تعديل تفاصيل الملف الشخصي';

  @override
  String get account => 'الحساب';

  @override
  String get manageChildrenMenu => 'إدارة الأطفال';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get pushNotifications => 'إشعارات الدفع';

  @override
  String get locationAlerts => 'تنبيهات الموقع';

  @override
  String get batteryAlerts => 'تنبيهات البطارية';

  @override
  String get safeZoneAlerts => 'تنبيهات الأماكن';

  @override
  String get notificationPermissionRequired =>
      'إذن الإشعارات مطلوب لإرسال التنبيهات';

  @override
  String get general => 'عام';

  @override
  String get language => 'اللغة';

  @override
  String get systemDefault => 'لغة النظام';

  @override
  String get helpAndSupport => 'المساعدة والدعم';

  @override
  String get about => 'حول';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get appVersion => 'Family security v1.0.0';

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get updateProfileHint => 'حدّث اسمك المعروض واسم المستخدم.';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get usernameCannotBeEmpty => 'لا يمكن أن يكون اسم المستخدم فارغاً';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي';

  @override
  String failedToUploadAvatar(String error) {
    return 'فشل رفع الصورة الرمزية: $error';
  }

  @override
  String get parentProfile => 'ملف الوالد';

  @override
  String get addChildForStats => 'أضف حساب طفل أولاً لعرض الإحصاءات المباشرة.';

  @override
  String get insights => 'رؤى';

  @override
  String childStats(String childName) {
    return 'إحصاءات $childName';
  }

  @override
  String get deviceStatus => 'حالة الجهاز';

  @override
  String batteryPercent(int battery) {
    return 'البطارية $battery%';
  }

  @override
  String get batteryUnknown => 'البطارية غير معروفة';

  @override
  String synced(String time) {
    return 'تمت المزامنة $time';
  }

  @override
  String get noDeviceSyncYet => 'لا توجد مزامنة للجهاز بعد';

  @override
  String get usageAccessGranted => 'تم منح وصول الاستخدام';

  @override
  String get usageAccessNeeded => 'وصول الاستخدام مطلوب';

  @override
  String get iosUsageAccessNote =>
      'هذا الجهاز iPhone. لا يوفر iOS وصول الاستخدام بأسلوب Android، لذا لا تستطيع هذه التطبيقات فتح شاشة الإذن تلك. يتطلب وقت شاشة iPhone وحظر التطبيقات صلاحيات Screen Time من Apple وتكاملاً أصلياً منفصلاً.';

  @override
  String get androidUsageAccessNote =>
      'افتح تطبيق الطفل على الهاتف واسمح بوصول الاستخدام. بعد ذلك، ستتزامن بيانات وقت الشاشة وقيود التطبيقات والتقويم تلقائياً.';

  @override
  String get dailyUsage => 'الاستخدام اليومي';

  @override
  String usageOfLimit(String total, String limit) {
    return '$total من $limit مستخدم';
  }

  @override
  String usageOnDate(String total, String date) {
    return '$total في $date';
  }

  @override
  String get allLimitsInRange => 'جميع القيود المفعّلة ضمن النطاق';

  @override
  String appLimitExceeded(int count) {
    return 'تجاوز حد $count تطبيق اليوم';
  }

  @override
  String get setAppLimitsHint =>
      'ضع قيوداً للتطبيقات أدناه لتحويل هذا إلى هدف حقيقي.';

  @override
  String get weeklyUsage => 'الاستخدام الأسبوعي';

  @override
  String get usageCalendar => 'تقويم الاستخدام';

  @override
  String get noAppUsageData =>
      'لا توجد بيانات استخدام للتطبيقات لهذا اليوم بعد.';

  @override
  String get grantUsageAccessHint =>
      'امنح وصول الاستخدام على هاتف الطفل لمشاهدة بيانات التطبيقات الفعلية وإدارة القيود.';

  @override
  String get iosAppLimitsUnavailable =>
      'هذا الهاتف iPhone. لا يحتوي إصدار التطبيق الحالي على تكامل مع Apple Screen Time، لذا فإن استخدام التطبيق لكل برنامج والقيود المباشرة غير متاحة على iOS.';

  @override
  String get enableDailyLimit => 'تفعيل الحد اليومي';

  @override
  String get dailyLimit => 'الحد اليومي';

  @override
  String get saveLimit => 'حفظ الحد';

  @override
  String get manageAppLimits => 'إدارة قيود التطبيقات';

  @override
  String appUsedOnDate(String appName, String date) {
    return '$appName في $date';
  }

  @override
  String limitMinutes(String time) {
    return 'الحد $time';
  }

  @override
  String get noLimit => 'بلا حد';

  @override
  String usageTodayOverLimit(String time) {
    return '$time اليوم · تجاوز الحد';
  }

  @override
  String usageToday(String time) {
    return '$time اليوم';
  }

  @override
  String limitSavedFor(String appName) {
    return 'تم حفظ الحد لـ $appName';
  }

  @override
  String limitDisabledFor(String appName) {
    return 'تم تعطيل الحد لـ $appName';
  }

  @override
  String couldNotSaveLimit(String error) {
    return 'تعذّر حفظ الحد: $error';
  }

  @override
  String get mon => 'الإث';

  @override
  String get tue => 'الثل';

  @override
  String get wed => 'الأر';

  @override
  String get thu => 'الخم';

  @override
  String get fri => 'الجم';

  @override
  String get sat => 'السب';

  @override
  String get sun => 'الأح';

  @override
  String get over => 'تجاوز';

  @override
  String get onboardingTitle => 'أهلاً بك!';

  @override
  String get onboardingSubtitle => 'من أنت؟';

  @override
  String get iAmParent => 'أنا ولي أمر';

  @override
  String get iAmChild => 'أنا طفل';

  @override
  String get parentSignIn => 'تسجيل الدخول';

  @override
  String get parentCreateAccount => 'إنشاء حساب';

  @override
  String get parentAuthSubtitle => 'أدِر عائلتك واحمها';

  @override
  String get childSignIn => 'تسجيل الدخول';

  @override
  String get childAuthTitle => 'مرحباً!';

  @override
  String get childAuthSubtitle => 'اطلب من ولي أمرك بيانات تسجيل الدخول';

  @override
  String get childNavSettings => 'الإعدادات';

  @override
  String get childProfile => 'الملف الشخصي';

  @override
  String get childSettingsTitle => 'الإعدادات';

  @override
  String get childLogout => 'تسجيل الخروج';

  @override
  String get inviteChild => 'دعوة طفل';

  @override
  String get inviteTitle => 'ادعُ الأطفال وأفراد الأسرة الآخرين إلى دائرتك';

  @override
  String get inviteSubtitle =>
      'يحتاج أفراد عائلتك إلى تثبيت التطبيق والانضمام إلى الدائرة باستخدام الرمز';

  @override
  String get inviteCodeLabel => 'الرمز صالح لمدة 3 أيام';

  @override
  String get shareCode => 'مشاركة الرمز';

  @override
  String get getHelp => 'الحصول على المساعدة';

  @override
  String get generateCode => 'توليد الرمز';

  @override
  String get codeCopied => 'تم نسخ الرمز إلى الحافظة';

  @override
  String inviteShareText(String code) {
    return 'انضم إلى دائرة عائلتي في Family security! استخدم رمز الدعوة: $code\n\nhttp://89.108.81.151/invite/$code';
  }

  @override
  String failedToGenerateCode(String error) {
    return 'فشل في إنشاء الرمز: $error';
  }

  @override
  String get childRegisterTitle => 'انضم إلى الأسرة';

  @override
  String get childRegisterSubtitle => 'أدخل رمز الدعوة من أحد والديك';

  @override
  String get inviteCode => 'رمز الدعوة';

  @override
  String get next => 'التالي';

  @override
  String get setupYourProfile => 'إعداد ملفك الشخصي';

  @override
  String get enterYourDetails => 'أدخل اسمك المعروض';

  @override
  String get register => 'التسجيل';

  @override
  String get invalidInviteCode => 'رمز الدعوة غير صالح أو منتهي الصلاحية';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get dontHaveCode => 'لديك رمز دعوة؟ سجّل';

  @override
  String get placesOnMap => 'الأماكن على الخريطة';

  @override
  String get placesAndChildren => 'الأماكن والأطفال';

  @override
  String placesCount(int count) {
    return 'الأماكن: $count';
  }

  @override
  String activeTodayCount(int count) {
    return 'النشطة اليوم: $count';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get createPlaceHint =>
      'أنشئ مكانًا لتلقي إشعارات عند وصول طفلك أو مغادرته.';

  @override
  String get untitledPlace => 'مكان بدون اسم';

  @override
  String get placeDeleted => 'تم حذف المكان.';

  @override
  String get editLabel => 'تعديل';

  @override
  String get disabledSchedule => 'معطّل';

  @override
  String get noDaysSelected => 'لم يتم اختيار أيام';

  @override
  String radiusSummary(String radius, String schedule) {
    return 'نصف القطر $radius • $schedule';
  }

  @override
  String get proActive => 'برو نشط';

  @override
  String get freePlan => 'الخطة المجانية';

  @override
  String get manageSubscription => 'إدارة الاشتراك';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get skip => 'تخطي';

  @override
  String get getPremium => 'الحصول على الباقة المميزة';

  @override
  String get monthly => 'شهري';

  @override
  String get yearly => 'سنوي';

  @override
  String get bestValue => 'أفضل قيمة';

  @override
  String get perMonth => 'في الشهر';

  @override
  String get perYearSave58 => 'سنويًا · وفّر 58%';

  @override
  String get paywallProductName => 'Family Security Pro';

  @override
  String get paywallUpgrade => 'ترقية';

  @override
  String paywallBestValueSave(int percent) {
    return 'أفضل قيمة · وفّر $percent%';
  }

  @override
  String get paywallBenefitAddChildren =>
      'أضف أطفالاً متعددين إلى حساب عائلي واحد';

  @override
  String get paywallBenefitUnlockTools =>
      'افتح مراقبة الصوت والخريطة المباشرة والسجل والإحصائيات وأدوات الإنذار';

  @override
  String get paywallBenefitFullDashboard =>
      'احتفظ بلوحة تحكم الوالدين كاملة دون قيود الخطة المجانية';

  @override
  String get paywallBenefitAudio => 'تسجيل الصوت المحيطي بالقرب من جهاز الطفل';

  @override
  String get paywallBenefitAppLimits =>
      'حدود التطبيقات وتحليلات الاستخدام وسجل الحركة';

  @override
  String get paywallBenefitAlarm =>
      'صفارة إنذار صوتية وإنجازات وضوابط متقدمة للوالدين';

  @override
  String get paywallIncludedWithPro => 'مضمّن مع Pro';

  @override
  String get paywallPlansTitle => 'الخطط المتاحة';

  @override
  String get paywallRecommended => 'موصى به';

  @override
  String paywallPerMonthEquivalent(String price) {
    return '$price ما يعادل شهريًا';
  }

  @override
  String get paywallChooseYourPlan => 'اختر خطتك';

  @override
  String get paywallChoosePlanDescription =>
      'اختر خطة Family Security Pro الشهرية أو السنوية التي تناسب عائلتك.';

  @override
  String get paywallLoadingPlans => 'جارٍ تحميل خطط الاشتراك...';

  @override
  String get paywallNoOffering => 'لا يوجد عرض متاح حاليًا.';

  @override
  String get paywallPlatformOnly =>
      'جدران الدفع متاحة فقط على iOS وAndroid في هذا الإصدار.';

  @override
  String get subscriptionRestored => 'تمت استعادة اشتراكك.';

  @override
  String get noSubscriptionFound => 'لم يتم العثور على اشتراك نشط لاستعادته.';

  @override
  String get subscriptionNowActive => 'Family Security Pro نشط الآن.';

  @override
  String get purchaseEntitlementPending =>
      'اكتمل الشراء، لكن الاشتراك لم يصبح نشطًا بعد.';

  @override
  String get premiumTitleAdditionalChildren => 'فتح المزيد من ملفات الأطفال';

  @override
  String get premiumTitleLiveMap => 'فتح خريطة الأسرة المباشرة';

  @override
  String get premiumTitleMovementHistory => 'فتح سجل الحركة';

  @override
  String get premiumTitleAudioMonitoring => 'فتح الصوت المحيطي المباشر';

  @override
  String get premiumTitleScreenTime => 'فتح ضوابط وقت الشاشة';

  @override
  String get premiumTitleAppStats => 'فتح تحليلات استخدام التطبيقات';

  @override
  String get premiumTitleAchievements => 'فتح الإنجازات والمكافآت';

  @override
  String get premiumTitleLoudAlarm => 'فتح صفارة الإنذار الصوتية عن بُعد';

  @override
  String get premiumTitleFullMenu => 'فتح قائمة الوالدين الكاملة';

  @override
  String get premiumTitleGeneric => 'فتح Family Security Pro';

  @override
  String get premiumSubtitleAdditionalChildren =>
      'يمكن للحسابات المجانية إدارة طفل واحد فقط. قم بالترقية لإضافة العائلة بأكملها.';

  @override
  String get premiumSubtitleLiveMap =>
      'اطّلع على مواقع الأطفال الفورية وحالتهم والإجراءات عن بُعد من خريطة واحدة.';

  @override
  String get premiumSubtitleMovementHistory =>
      'راجع المسارات التاريخية وتشغيل الحركة والتحقيق في تغييرات الموقع.';

  @override
  String get premiumSubtitleAudioMonitoring =>
      'استمع إلى الأصوات المحيطة بالقرب من الطفل عند الحاجة إلى السياق الفوري.';

  @override
  String get premiumSubtitleScreenTime =>
      'حدد حدودًا يومية للتطبيقات وحجب التطبيقات وفرض عادات أكثر صحة.';

  @override
  String get premiumSubtitleAppStats =>
      'اطلع على تحليلات الاستخدام والاتجاهات ورؤى السلوك على مستوى التطبيق.';

  @override
  String get premiumSubtitleAchievements =>
      'استخدم المهام والنجوم والمكافآت لبناء عادات إيجابية لطفلك.';

  @override
  String get premiumSubtitleLoudAlarm =>
      'قم بتشغيل صفارة إنذار عالية عن بُعد للمساعدة في تحديد موقع جهاز الطفل بسرعة.';

  @override
  String get premiumSubtitleFullMenu =>
      'قائمة الوالدين المتقدمة وعناصر التحكم وأدوات المراقبة هي جزء من Pro.';

  @override
  String get premiumSubtitleGeneric =>
      'قم بالترقية إلى Family Security Pro لفتح أدوات الرقابة الأبوية المتقدمة.';

  @override
  String get seePlans => 'عرض الخطط';
}
