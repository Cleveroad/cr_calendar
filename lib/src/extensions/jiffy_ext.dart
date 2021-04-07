import 'package:jiffy/jiffy.dart';

extension Ranging on Jiffy {
  // ignore: type_annotate_public_apis
  bool isInRange(first, second) {
    return isSameOrAfter(first) && isSameOrBefore(second);
  }
}
