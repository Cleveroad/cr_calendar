import 'package:jiffy/jiffy.dart';

extension Converting on DateTime {
  Jiffy toJiffy() => Jiffy(this);
}
