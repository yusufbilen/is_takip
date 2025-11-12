// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Basit bildirim sistemi - şimdilik sadece console log
    print('Bildirim sistemi başlatıldı');
    
    _initialized = true;
  }

  void _onNotificationTapped(dynamic response) {
    // Bildirim tıklandığında yapılacak işlemler
    print('Bildirim tıklandı: $response');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    // Basit bildirim sistemi - şimdilik sadece console log
    print('Bildirim planlandı: $title - $body - $scheduledDate');
  }

  Future<void> cancelNotification(int id) async {
    print('Bildirim iptal edildi: $id');
  }

  Future<void> cancelAllNotifications() async {
    print('Tüm bildirimler iptal edildi');
  }

  Future<List<dynamic>> getPendingNotifications() async {
    return [];
  }

  // Görev hatırlatıcısı
  Future<void> scheduleTaskReminder({
    required int taskId,
    required String taskTitle,
    required DateTime reminderDate,
  }) async {
    await scheduleNotification(
      id: taskId + 10000, // Görev ID'lerini 10000 ile başlat
      title: 'Görev Hatırlatıcısı',
      body: 'Görev: $taskTitle',
      scheduledDate: reminderDate,
      payload: 'task_$taskId',
    );
  }

  // Etkinlik hatırlatıcısı
  Future<void> scheduleEventReminder({
    required int eventId,
    required String eventTitle,
    required DateTime reminderDate,
  }) async {
    await scheduleNotification(
      id: eventId + 20000, // Etkinlik ID'lerini 20000 ile başlat
      title: 'Etkinlik Hatırlatıcısı',
      body: 'Etkinlik: $eventTitle',
      scheduledDate: reminderDate,
      payload: 'event_$eventId',
    );
  }

  // Duruşma hatırlatıcısı
  Future<void> scheduleHearingReminder({
    required int caseId,
    required String caseTitle,
    required DateTime hearingDate,
  }) async {
    await scheduleNotification(
      id: caseId + 30000, // Dava ID'lerini 30000 ile başlat
      title: 'Duruşma Hatırlatıcısı',
      body: 'Dava: $caseTitle',
      scheduledDate: hearingDate,
      payload: 'hearing_$caseId',
    );
  }

  // Günlük özet bildirimi
  Future<void> scheduleDailySummary() async {
    await scheduleNotification(
      id: 99999,
      title: 'Günlük Özet',
      body: 'Bugünkü görevlerinizi ve etkinliklerinizi kontrol edin',
      scheduledDate: DateTime.now().add(const Duration(hours: 24)).copyWith(
        hour: 9,
        minute: 0,
        second: 0,
        millisecond: 0,
      ),
      payload: 'daily_summary',
    );
  }

  // Haftalık rapor bildirimi
  Future<void> scheduleWeeklyReport() async {
    await scheduleNotification(
      id: 99998,
      title: 'Haftalık Rapor',
      body: 'Bu haftaki çalışmalarınızın özetini görün',
      scheduledDate: _getNextMonday(),
      payload: 'weekly_report',
    );
  }

  DateTime _getNextMonday() {
    final now = DateTime.now();
    final daysUntilMonday = (8 - now.weekday) % 7;
    return now.add(Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday)).copyWith(
      hour: 10,
      minute: 0,
      second: 0,
      millisecond: 0,
    );
  }
}
