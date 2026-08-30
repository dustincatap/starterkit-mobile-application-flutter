// ignore_for_file: prefer-static-class

// Based from https://stackoverflow.com/a/73048760
// This file is used to set the threshold for the golden tests

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Works just like [LocalFileComparator] but includes a [threshold] that, when
/// exceeded, marks the test as a failure.
class GoldenFileComparatorWithThreshold extends LocalFileComparator {
  /// Threshold above which tests will be marked as failing.
  /// Ranges from 0 to 1, both inclusive.
  final double threshold;

  GoldenFileComparatorWithThreshold(super.testFile, this.threshold)
    : assert(threshold >= 0 && threshold <= 1, 'Threshold must be between 0 and 1');

  /// Copy of [LocalFileComparator]'s [compare] method, except for the fact that
  /// it checks if the [ComparisonResult.diffPercent] is not greater than
  /// [threshold] to decide whether this test is successful or a failure.
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(imageBytes, await getGoldenBytes(golden));

    if (!result.passed && result.diffPercent <= threshold) {
      debugPrint(
        'A difference of ${result.diffPercent * 100}% was found, but it is '
        'acceptable since it is not greater than the threshold of '
        '${threshold * 100}%',
      );

      return true;
    }

    if (!result.passed) {
      final String error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    return result.passed;
  }
}
