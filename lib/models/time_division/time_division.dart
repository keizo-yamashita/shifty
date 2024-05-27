import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_division.freezed.dart';
part 'time_division.g.dart';

@freezed
class TimeDivision with _$TimeDivision {
  const factory TimeDivision({
    required String name,
    required DateTime startTime,
    required DateTime endTime,
  }) = _TimeDivision;

  factory TimeDivision.fromJson(Map<String, dynamic> json) => _$TimeDivisionFromJson(json);
}