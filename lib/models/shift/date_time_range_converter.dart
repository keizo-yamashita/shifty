
import 'package:json_annotation/json_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

class DateTimeRangeConverter implements JsonConverter<DateTimeRange, Map<String, dynamic>> {
  const DateTimeRangeConverter();

  @override
  DateTimeRange fromJson(Map<String, dynamic> json) {
    return DateTimeRange(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson(DateTimeRange object) {
    return {
      'start': object.start.toIso8601String(),
      'end': object.end.toIso8601String(),
    };
  }
}