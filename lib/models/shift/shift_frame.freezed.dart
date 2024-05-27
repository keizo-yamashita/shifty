// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shift_frame.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShiftFrame _$ShiftFrameFromJson(Map<String, dynamic> json) {
  return _ShiftFrame.fromJson(json);
}

/// @nodoc
mixin _$ShiftFrame {
  String get shiftId => throw _privateConstructorUsedError;
  String get shiftName => throw _privateConstructorUsedError;
  DateTime get updateTime => throw _privateConstructorUsedError;
  List<TimeDivision> get timeDivs => throw _privateConstructorUsedError;
  @DateTimeRangeConverter()
  List<DateTimeRange> get dateTerm => throw _privateConstructorUsedError;
  List<List<int>> get assignTable => throw _privateConstructorUsedError;
  bool get isTestMode => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShiftFrameCopyWith<ShiftFrame> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShiftFrameCopyWith<$Res> {
  factory $ShiftFrameCopyWith(
          ShiftFrame value, $Res Function(ShiftFrame) then) =
      _$ShiftFrameCopyWithImpl<$Res, ShiftFrame>;
  @useResult
  $Res call(
      {String shiftId,
      String shiftName,
      DateTime updateTime,
      List<TimeDivision> timeDivs,
      @DateTimeRangeConverter() List<DateTimeRange> dateTerm,
      List<List<int>> assignTable,
      bool isTestMode,
      String userId});
}

/// @nodoc
class _$ShiftFrameCopyWithImpl<$Res, $Val extends ShiftFrame>
    implements $ShiftFrameCopyWith<$Res> {
  _$ShiftFrameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shiftId = null,
    Object? shiftName = null,
    Object? updateTime = null,
    Object? timeDivs = null,
    Object? dateTerm = null,
    Object? assignTable = null,
    Object? isTestMode = null,
    Object? userId = null,
  }) {
    return _then(_value.copyWith(
      shiftId: null == shiftId
          ? _value.shiftId
          : shiftId // ignore: cast_nullable_to_non_nullable
              as String,
      shiftName: null == shiftName
          ? _value.shiftName
          : shiftName // ignore: cast_nullable_to_non_nullable
              as String,
      updateTime: null == updateTime
          ? _value.updateTime
          : updateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      timeDivs: null == timeDivs
          ? _value.timeDivs
          : timeDivs // ignore: cast_nullable_to_non_nullable
              as List<TimeDivision>,
      dateTerm: null == dateTerm
          ? _value.dateTerm
          : dateTerm // ignore: cast_nullable_to_non_nullable
              as List<DateTimeRange>,
      assignTable: null == assignTable
          ? _value.assignTable
          : assignTable // ignore: cast_nullable_to_non_nullable
              as List<List<int>>,
      isTestMode: null == isTestMode
          ? _value.isTestMode
          : isTestMode // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShiftFrameImplCopyWith<$Res>
    implements $ShiftFrameCopyWith<$Res> {
  factory _$$ShiftFrameImplCopyWith(
          _$ShiftFrameImpl value, $Res Function(_$ShiftFrameImpl) then) =
      __$$ShiftFrameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String shiftId,
      String shiftName,
      DateTime updateTime,
      List<TimeDivision> timeDivs,
      @DateTimeRangeConverter() List<DateTimeRange> dateTerm,
      List<List<int>> assignTable,
      bool isTestMode,
      String userId});
}

/// @nodoc
class __$$ShiftFrameImplCopyWithImpl<$Res>
    extends _$ShiftFrameCopyWithImpl<$Res, _$ShiftFrameImpl>
    implements _$$ShiftFrameImplCopyWith<$Res> {
  __$$ShiftFrameImplCopyWithImpl(
      _$ShiftFrameImpl _value, $Res Function(_$ShiftFrameImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shiftId = null,
    Object? shiftName = null,
    Object? updateTime = null,
    Object? timeDivs = null,
    Object? dateTerm = null,
    Object? assignTable = null,
    Object? isTestMode = null,
    Object? userId = null,
  }) {
    return _then(_$ShiftFrameImpl(
      shiftId: null == shiftId
          ? _value.shiftId
          : shiftId // ignore: cast_nullable_to_non_nullable
              as String,
      shiftName: null == shiftName
          ? _value.shiftName
          : shiftName // ignore: cast_nullable_to_non_nullable
              as String,
      updateTime: null == updateTime
          ? _value.updateTime
          : updateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      timeDivs: null == timeDivs
          ? _value._timeDivs
          : timeDivs // ignore: cast_nullable_to_non_nullable
              as List<TimeDivision>,
      dateTerm: null == dateTerm
          ? _value._dateTerm
          : dateTerm // ignore: cast_nullable_to_non_nullable
              as List<DateTimeRange>,
      assignTable: null == assignTable
          ? _value._assignTable
          : assignTable // ignore: cast_nullable_to_non_nullable
              as List<List<int>>,
      isTestMode: null == isTestMode
          ? _value.isTestMode
          : isTestMode // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShiftFrameImpl extends _ShiftFrame {
  const _$ShiftFrameImpl(
      {required this.shiftId,
      required this.shiftName,
      required this.updateTime,
      required final List<TimeDivision> timeDivs,
      @DateTimeRangeConverter() required final List<DateTimeRange> dateTerm,
      required final List<List<int>> assignTable,
      required this.isTestMode,
      required this.userId})
      : _timeDivs = timeDivs,
        _dateTerm = dateTerm,
        _assignTable = assignTable,
        super._();

  factory _$ShiftFrameImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShiftFrameImplFromJson(json);

  @override
  final String shiftId;
  @override
  final String shiftName;
  @override
  final DateTime updateTime;
  final List<TimeDivision> _timeDivs;
  @override
  List<TimeDivision> get timeDivs {
    if (_timeDivs is EqualUnmodifiableListView) return _timeDivs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeDivs);
  }

  final List<DateTimeRange> _dateTerm;
  @override
  @DateTimeRangeConverter()
  List<DateTimeRange> get dateTerm {
    if (_dateTerm is EqualUnmodifiableListView) return _dateTerm;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dateTerm);
  }

  final List<List<int>> _assignTable;
  @override
  List<List<int>> get assignTable {
    if (_assignTable is EqualUnmodifiableListView) return _assignTable;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignTable);
  }

  @override
  final bool isTestMode;
  @override
  final String userId;

  @override
  String toString() {
    return 'ShiftFrame(shiftId: $shiftId, shiftName: $shiftName, updateTime: $updateTime, timeDivs: $timeDivs, dateTerm: $dateTerm, assignTable: $assignTable, isTestMode: $isTestMode, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShiftFrameImpl &&
            (identical(other.shiftId, shiftId) || other.shiftId == shiftId) &&
            (identical(other.shiftName, shiftName) ||
                other.shiftName == shiftName) &&
            (identical(other.updateTime, updateTime) ||
                other.updateTime == updateTime) &&
            const DeepCollectionEquality().equals(other._timeDivs, _timeDivs) &&
            const DeepCollectionEquality().equals(other._dateTerm, _dateTerm) &&
            const DeepCollectionEquality()
                .equals(other._assignTable, _assignTable) &&
            (identical(other.isTestMode, isTestMode) ||
                other.isTestMode == isTestMode) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      shiftId,
      shiftName,
      updateTime,
      const DeepCollectionEquality().hash(_timeDivs),
      const DeepCollectionEquality().hash(_dateTerm),
      const DeepCollectionEquality().hash(_assignTable),
      isTestMode,
      userId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShiftFrameImplCopyWith<_$ShiftFrameImpl> get copyWith =>
      __$$ShiftFrameImplCopyWithImpl<_$ShiftFrameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShiftFrameImplToJson(
      this,
    );
  }
}

abstract class _ShiftFrame extends ShiftFrame {
  const factory _ShiftFrame(
      {required final String shiftId,
      required final String shiftName,
      required final DateTime updateTime,
      required final List<TimeDivision> timeDivs,
      @DateTimeRangeConverter() required final List<DateTimeRange> dateTerm,
      required final List<List<int>> assignTable,
      required final bool isTestMode,
      required final String userId}) = _$ShiftFrameImpl;
  const _ShiftFrame._() : super._();

  factory _ShiftFrame.fromJson(Map<String, dynamic> json) =
      _$ShiftFrameImpl.fromJson;

  @override
  String get shiftId;
  @override
  String get shiftName;
  @override
  DateTime get updateTime;
  @override
  List<TimeDivision> get timeDivs;
  @override
  @DateTimeRangeConverter()
  List<DateTimeRange> get dateTerm;
  @override
  List<List<int>> get assignTable;
  @override
  bool get isTestMode;
  @override
  String get userId;
  @override
  @JsonKey(ignore: true)
  _$$ShiftFrameImplCopyWith<_$ShiftFrameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
