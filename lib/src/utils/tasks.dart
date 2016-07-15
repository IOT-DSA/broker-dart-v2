part of dsa.broker.utils;

typedef Future TaskRunner();

class TaskRunLoop {
  final Duration checkInterval;

  Map<String, TaskRunner> _runners = <String, TaskRunner>{};
  Set<String> _scheduled = new Set<String>();

  TaskRunLoop(this.checkInterval);

  void register(String name, TaskRunner runner) {
    if (_runners.containsKey(name)) {
      throw new Exception("Task '$name' already defined.");
    }

    _runners[name] = runner;
  }

  void unregister(String name) {
    _runners.remove(name);
  }

  bool hasTask(String name) => _runners.containsKey(name);
  bool isTaskScheduled(String name) => _scheduled.contains(name);
  bool get isActive => _timer != null && _timer.isActive;
  bool get hasTasksScheduled => _scheduled.isNotEmpty;

  Future start() async {
    await stop();
    _timer = new Timer(checkInterval, _run);
  }

  Future stop() async {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
  }

  Future _run([bool schedule = true]) async {
    if (_scheduled.isNotEmpty) {
      var now = _scheduled;
      _scheduled = new Set<String>();
      for (String taskName in now) {
        var runner = _runners[taskName];

        if (runner != null) {
          await runner();
        }
      }
    }

    if (schedule == true) {
      _timer = new Timer(checkInterval, _run);
    }
  }

  Timer _timer;

  Future run() async {
    await stop();
    await _run(false);
    await start();
  }

  Future schedule(String name) async {
    _scheduled.add(name);
  }
}
