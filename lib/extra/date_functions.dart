DateTime getFirstDayOfTheWeek(DateTime currentTime) {
  return currentTime.subtract(Duration(days: currentTime.weekday - 1));
}

DateTime getLastDayOfTheWeek(DateTime currentTime) {
  return currentTime
      .add(Duration(days: DateTime.daysPerWeek - currentTime.weekday));
}

DateTime getFirstDayOfTheMonth(DateTime currentTime) {
  return DateTime(currentTime.year, currentTime.month, 1);
}

DateTime getLastDayOfTheMonth(DateTime currentTime) {
  return DateTime(currentTime.year, currentTime.month + 1, 0);
}

bool isDateInRange(DateTime currentTime, DateTime start, DateTime end) {
  return (currentTime.millisecondsSinceEpoch >= start.millisecondsSinceEpoch) &&
      (currentTime.millisecondsSinceEpoch <= end.millisecondsSinceEpoch);
}

String getLastDateString(DateTime time) {
  DateTime now = DateTime.now();

  if (time.isBefore(now)) {
    Duration diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'Just Now';
    } else if (diff.inMinutes >= 1 && diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours == 1) {
      return '1 hour ago';
    } else if (diff.inHours >= 1 && diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return '${diff.inDays} day ago';
    } else if (diff.inDays > 1 && diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if ((diff.inDays / 7).floor() == 1) {
      return '1 week ago';
    } else if ((diff.inDays / 7).floor() > 1) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else if (diff.inDays == 30) {
      return '1 months ago';
    } else if (diff.inDays >= 30 && diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} months ago';
    } else if (diff.inDays == 365) {
      return '1 year ago';
    } else if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} years ago';
    }
  }

  return 'Never';
}
