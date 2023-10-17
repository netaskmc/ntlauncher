import 'package:flutter/material.dart';

class Logger {
  late Function(String) _subscriber;

  void log(String message) {
    // ignore: avoid_print
    print(message);
    _subscriber(message);
  }

  Logger({required Function(String) subscriber, required String level}) {
    _subscriber = subscriber;
  }
}

class LogEntry {
  final String level;
  final String message;
  final DateTime time = DateTime.now();

  LogEntry(this.level, this.message);

  String localTimestamp() {
    String m =
        time.minute % 10 == time.minute ? "0${time.minute}" : "${time.minute}";
    String s =
        time.second % 10 == time.second ? "0${time.second}" : "${time.second}";
    return "${time.hour}:$m:$s";
  }

  @override
  String toString() {
    return "(${localTimestamp()}) [$level] $message";
  }
}

class Log {
  static final List<Function(String, String)> _subscribers = [];

  static final List<LogEntry> _logs = [];

  static Logger info = _makeLogger("INFO");
  static Logger warn = _makeLogger("WARN");
  static Logger error = _makeLogger("ERROR");
  static Logger debug = _makeLogger("DEBUG");

  static void subscribe(Function(String, String) callback) {
    _subscribers.add(callback);
  }

  static void unsubscribe(Function(String, String) callback) {
    _subscribers.remove(callback);
  }

  static void _callback(String s, String level) {
    _logs.add(LogEntry(level, s));
    for (var subscriber in _subscribers) {
      subscriber(level, s);
    }
  }

  static Logger _makeLogger(String level) {
    return Logger(
      subscriber: (s) => _callback(s, level),
      level: level,
    );
  }
}

class LogProvider with ChangeNotifier {
  List<LogEntry> get logs => Log._logs;

  LogProvider() {
    Log.subscribe((s, level) => notifyListeners());
    notifyListeners();
  }
}
