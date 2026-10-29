/// اشتراك النسخة التجريبية.
///
/// خلال مرحلة التجارب يكون القفل معطلاً بالكامل.
/// عند تفعيل الاشتراكات لاحقاً سيتم ربط هذه الطبقة بخدمة الإدارة
/// من دون تغيير شاشات المحاسبة الأساسية.
abstract final class SubscriptionGate {
  static const bool enforcementEnabled = false;

  static bool canUseApp({
    required bool hasActiveSubscription,
  }) {
    if (!enforcementEnabled) return true;
    return hasActiveSubscription;
  }
}
