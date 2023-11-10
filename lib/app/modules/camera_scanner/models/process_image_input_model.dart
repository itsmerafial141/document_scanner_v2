import 'dart:isolate';

import 'package:simple_edge_detection/simple_edge_detection.dart';

class ProcessImageInput {
  ProcessImageInput({
    required this.inputPath,
    required this.edgeDetectionResult,
    required this.sendPort,
  });

  String inputPath;
  EdgeDetectionResult edgeDetectionResult;
  SendPort sendPort;
}
