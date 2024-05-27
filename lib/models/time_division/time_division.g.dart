// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_division.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeDivisionImpl _$$TimeDivisionImplFromJson(Map<String, dynamic> json) =>
    _$TimeDivisionImpl(
      name: json['name'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
    );

Map<String, dynamic> _$$TimeDivisionImplToJson(_$TimeDivisionImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
    };
