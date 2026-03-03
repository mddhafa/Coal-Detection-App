import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class YoloTflite {
  late final Interpreter _interpreter;
  late final List<int> inputShape;
  late final List<int> outputShape;

  Future<void> load() async {
    _interpreter = await Interpreter.fromAsset(
      'models/best_float32.tflite',
      options: InterpreterOptions()..threads = 4,
    );

    inputShape = _interpreter.getInputTensor(0).shape;
    outputShape = _interpreter.getOutputTensor(0).shape;

    // Contoh output:
    // input:  [1, 640, 640, 3] atau [1, 3, 640, 640]
    // output: [1, 7, 34000] atau [1, 34000, 7] dll
    // Print ini dulu biar decode akurat.
    // ignore: avoid_print
    print('inputShape=$inputShape outputShape=$outputShape');
  }

  /// input: Float32List sesuai shape input model
  /// output: Float32List sesuai output tensor
  Float32List run(Float32List inputBuffer) {
    final outputSize = outputShape.reduce((a, b) => a * b);
    final output = Float32List(outputSize);

    _interpreter.run(
      inputBuffer.reshape(inputShape),
      output.reshape(outputShape),
    );
    return output;
  }

  void close() => _interpreter.close();
}

extension ReshapeExt on Float32List {
  Object reshape(List<int> shape) =>
      this; // tflite_flutter menerima typed list + shape
}
