// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_division.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimeDivision _$TimeDivisionFromJson(Map<String, dynamic> json) {
  return _TimeDivision.fromJson(json);
}

/// @nodoc
mixin _$TimeDivision {
  String get name => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimeDivisionCopyWith<TimeDivision> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeDivisionCopyWith<$Res> {
  factory $TimeDivisionCopyWith(
          TimeDivision value, $Res Function(TimeDivision) then) =
      _$TimeDivisionCopyWithImpl<$Res, TimeDivision>;
  @useResult
  $Res call({String name, DateTime startTime, DateTime endTime});
}

/// @nodoc
class _$TimeDivisionCopyWithImpl<$Res, $Val extends TimeDivision>
    implements $TimeDivisionCopyWith<$Res> {
  _$TimeDivisionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? startTime = null,
    Object? endTime = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeDivisionImplCopyWith<$Res>
    implements $TimeDivisionCopyWith<$Res> {
  factory _$$TimeDivisionImplCopyWith(
          _$TimeDivisionImpl value, $Res Function(_$TimeDivisionImpl) then) =
      __$$TimeDivisionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, DateTime startTime, DateTime endTime});
}

/// @nodoc
class __$$TimeDivisionImplCopyWithImpl<$Res>
    extends _$TimeDivisionCopyWithImpl<$Res, _$TimeDivisionImpl>
    implements _$$TimeDivisionImplCopyWith<$Res> {
  __$$TimeDivisionImplCopyWithImpl(
      _$TimeDivisionImpl _value, $Res Function(_$TimeDivisionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? startTime = null,
    Object? endTime = null,
  }) {
    return _then(_$TimeDivisionImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeDivisionImpl implements _TimeDivision {
  const _$TimeDivisionImpl(
      {required this.name, required this.startTime, required this.endTime});

  factory _$TimeDivisionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeDivisionImplFromJson(json);

  @override
  final String name;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;

  @override
  String toString() {
    return 'TimeDivision(name: $name, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeDivisionImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, startTime, endTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeDivisionImplCopyWith<_$TimeDivisionImpl> get copyWith =>
      __$$TimeDivisionImplCopyWithImpl<_$TimeDivisionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeDivisionImplToJson(
      this,
    );
  }
}

abstract class _TimeDivision implements TimeDivision {
  const factory _TimeDivision(
      {required final String name,
      required final DateTime startTime,
      required final DateTime endTime}) = _$TimeDivisionImpl;

  factory _TimeDivision.fromJson(Map<String, dynamic> json) =
      _$TimeDivisionImpl.fromJson;

  @override
  String get name;
  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  @JsonKey(ignore: true)
  _$$TimeDivisionImplCopyWith<_$TimeDivisionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
