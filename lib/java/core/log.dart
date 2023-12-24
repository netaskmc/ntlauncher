class CoreMsg {
  final String rawMessage;
  final String type = '';

  CoreMsg(this.rawMessage);

  get _parsedMessage {
    var split = rawMessage.split(': ');
    if (split.length < 2) return ('', rawMessage);
    return (split[0], split.sublist(1).join(': '));
  }

  String get message => _parsedMessage.$2;
  String get level => _parsedMessage.$1;

  @override
  String toString() => message;

  factory CoreMsg.fromRaw(String raw) {
    if (raw.startsWith('LOG')) {
      return CoreLog(CoreMsg(raw));
    } else if (raw.startsWith('GAME LOG')) {
      return CoreGameLog(CoreMsg(raw));
    } else if (raw.startsWith('ERROR')) {
      return CoreError(CoreMsg(raw));
    } else if (raw.startsWith('PROGRESS')) {
      return CoreProgress(CoreMsg(raw));
    } else {
      return CoreMsg(raw);
    }
  }
}

class CoreLog extends CoreMsg {
  @override
  get type => 'LOG';
  CoreLog(CoreMsg msg) : super(msg.rawMessage);
}

class CoreGameLog extends CoreMsg {
  @override
  get type => 'GAME LOG';
  CoreGameLog(CoreMsg msg) : super(msg.rawMessage);
}

class CoreError extends CoreMsg {
  @override
  get type => 'ERROR';
  CoreError(CoreMsg msg) : super(msg.rawMessage);
}

class CoreProgress extends CoreMsg {
  @override
  get type => 'PROGRESS';
  CoreProgress(CoreMsg msg) : super(msg.rawMessage);

  (int, int) get asPair {
    var split = message.split('/').map((e) => int.parse(e)).toList();
    int current = split[0];
    int total = 0;
    if (split.length != 1) {
      total = split[1];
    }
    return (current, total);
  }

  double get asFraction {
    var (current, total) = asPair;
    if (total == 0) return 0;
    return (current / total).clamp(0, 1);
  }

  String get stage => level.split(" ").last;

  @override
  String toString() =>
      "Installing ${stage.toLowerCase()}: ${asPair.$2 == 0 ? 'please wait...' : '${(asFraction * 100).floor()}%'}";
}
