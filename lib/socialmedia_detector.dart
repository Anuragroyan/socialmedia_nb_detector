import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SocialMediaClassifier {
  late List<String> classes;
  late List<double> classLogPrior;
  late List<List<double>> featureLogProb;
  late Map<String, int> vocabulary;

  /// Load the model JSON from assets
  Future<void> loadModel(String assetPath) async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> data = json.decode(jsonStr);

    classes = List<String>.from(data['classes']);
    classLogPrior = List<double>.from(data['class_log_prior']);
    featureLogProb = (data['feature_log_prob'] as List)
        .map<List<double>>((row) => List<double>.from(row))
        .toList();
    vocabulary = Map<String, int>.from(data['vocabulary']);
  }

  /// Predict which social media platform the text is from
  String predictPlatform(String text) {
    final tokens = _tokenize(text);

    // If no recognizable tokens, return unknown
    if (tokens.isEmpty || tokens.every((t) => !vocabulary.containsKey(t))) {
      return "unknown";
    }

    final vector = List<int>.filled(vocabulary.length, 0);
    for (final token in tokens) {
      final idx = vocabulary[token];
      if (idx != null) vector[idx] += 1;
    }

    final scores = List<double>.generate(classes.length, (i) => classLogPrior[i]);
    for (int i = 0; i < classes.length; i++) {
      for (int j = 0; j < vector.length; j++) {
        scores[i] += vector[j] * featureLogProb[i][j];
      }
    }

    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final maxIndex = scores.indexOf(maxScore);
    return maxIndex >= 0 && maxIndex < classes.length
        ? classes[maxIndex]
        : "unknown";
  }

  List<String> _tokenize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }
}

class SocialMediaDetector {
  final _clf = SocialMediaClassifier();

  Future<void> loadModel(String path) async => await _clf.loadModel(path);

  Future<String> predict(String text) async {
    return _clf.predictPlatform(text);
  }
}
