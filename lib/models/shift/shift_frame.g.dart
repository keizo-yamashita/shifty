// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_frame.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShiftFrameImpl _$$ShiftFrameImplFromJson(Map<String, dynamic> json) =>
    _$ShiftFrameImpl(
      shiftId: json['shiftId'] as String,
      shiftName: json['shiftName'] as String,
      updateTime: DateTime.parse(json['updateTime'] as String),
      timeDivs: (json['timeDivs'] as List<dynamic>)
          .map((e) => TimeDivision.fromJson(e as Map<String, dynamic>))
          .toList(),
      dateTerm: (json['dateTerm'] as List<dynamic>)
          .map((e) => const DateTimeRangeConverter()
              .fromJson(e as Map<String, dynamic>))
          .toList(),
      assignTable: (json['assignTable'] as List<dynamic>)
          .map((e) =>
              (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
          .toList(),
      isTestMode: json['isTestMode'] as bool,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$ShiftFrameImplToJson(_$ShiftFrameImpl instance) =>
    <String, dynamic>{
      'shiftId': instance.shiftId,
      'shiftName': instance.shiftName,
      'updateTime': instance.updateTime.toIso8601String(),
      'timeDivs': instance.timeDivs,
      'dateTerm':
          instance.dateTerm.map(const DateTimeRangeConverter().toJson).toList(),
      'assignTable': instance.assignTable,
      'isTestMode': instance.isTestMode,
      'userId': instance.userId,
    };
