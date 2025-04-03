import 'dart:async';

class ChronoManager {
  static final ChronoManager _instance = ChronoManager._internal();

  factory ChronoManager() => _instance;

  ChronoManager._internal();

  late Timer _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;

  final StreamController<int> _elapsedTimeController = StreamController<int>.broadcast();

  Stream<int> get elapsedTimeStream => _elapsedTimeController.stream;

  int get elapsedSeconds => _elapsedSeconds;

  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      _elapsedTimeController.add(_elapsedSeconds); // Émet une mise à jour
    });
  }

  void stopTimer() {
    if (_isRunning) {
      _timer.cancel();
      _isRunning = false;
    }
  }

  void resetTimer() {
    stopTimer();
    _elapsedSeconds = 0;
    _elapsedTimeController.add(_elapsedSeconds); // Réinitialise la valeur
  }

  void dispose() {
    _elapsedTimeController.close(); // Libère le StreamController
  }

  String toString(){
    int tmp = _elapsedSeconds;
    String result =(tmp~/3600).toString() +"h";
    tmp = tmp%3600;
    result = result+ (tmp~/60).toString() + "m"+ (tmp%60).toString() + "s";
    return result;
  }
}
