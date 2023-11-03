import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'Counts.g.dart';

@riverpod
class Counts extends _$Counts {
  @override
  int build() {
    return 0;
  }

  void iteratecount() {
    state++;
  }

  void decrementcount() {
    state--;
  }
}
