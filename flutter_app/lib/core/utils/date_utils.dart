class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date) {
    final months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}ч ${m.toString().padLeft(2, '0')}м';
    }
    return '${m}м ${s.toString().padLeft(2, '0')}с';
  }

  static String formatDurationHM(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}ч ${m}м';
    return '${m} мин';
  }

  static String weekDayShort(int weekday) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[(weekday - 1) % 7];
  }

  static List<DateTime> weekDays(DateTime reference) {
    final monday = reference.subtract(Duration(days: reference.weekday - 1));
    return List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i));
  }
}
