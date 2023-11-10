import 'dart:isolate';

class EdgeDetectionInput {
  EdgeDetectionInput({
    required this.inputPath,
    required this.sendPort,
  });

  String inputPath;
  SendPort sendPort;
}
