class AlertNotificationService {
  final Map<int, double> _thresholdsByRoute = {};
  final Map<int, double> _lastNotifiedPriceByRoute = {};

  double? getThreshold(int routeId) => _thresholdsByRoute[routeId];

  void setThreshold(int routeId, double thresholdKzt) {
    _thresholdsByRoute[routeId] = thresholdKzt;
    // Сбрасываем историю уведомлений при установке нового порога
    _lastNotifiedPriceByRoute.remove(routeId);
  }

  /// Проверяет, нужно ли отправлять уведомление пользователю.
  /// Исключает повторную отправку, если мы уже уведомляли об этой или более низкой цене.
  bool shouldNotify({
    required int routeId,
    required double currentFreshPriceKzt,
    required bool isFresh,
  }) {
    if (!isFresh) return false;

    final threshold = _thresholdsByRoute[routeId];
    if (threshold == null || currentFreshPriceKzt > threshold) {
      return false;
    }

    final lastNotified = _lastNotifiedPriceByRoute[routeId];
    if (lastNotified != null && currentFreshPriceKzt >= lastNotified) {
      // Повторное уведомление блокируется (дедупликация)
      return false;
    }

    _lastNotifiedPriceByRoute[routeId] = currentFreshPriceKzt;
    return true;
  }
}
