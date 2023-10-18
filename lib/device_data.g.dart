// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceTimeSeriesData _$DeviceTimeSeriesDataFromJson(
        Map<String, dynamic> json) =>
    DeviceTimeSeriesData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      heartRate: json['heartRate'] as int? ?? 0,
      deviceOn: json['deviceOn'] as bool? ?? false,
      positiveEmission: json['positiveEmission'] as bool? ?? false,
      negativeEmission: json['negativeEmission'] as bool? ?? false,
      positiveEmissionDuration: json['positiveEmissionDuration'] as int? ?? 10,
      negativeEmissionDuration: json['negativeEmissionDuration'] as int? ?? 10,
      periodicEmissionTimerLength:
          json['periodicEmissionTimerLength'] as int? ?? 30 * 60,
      periodicEmission: json['periodicEmission'] as bool? ?? false,
    );

Map<String, dynamic> _$DeviceTimeSeriesDataToJson(
        DeviceTimeSeriesData instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'heartRate': instance.heartRate,
      'deviceOn': instance.deviceOn,
      'positiveEmission': instance.positiveEmission,
      'negativeEmission': instance.negativeEmission,
      'positiveEmissionDuration': instance.positiveEmissionDuration,
      'negativeEmissionDuration': instance.negativeEmissionDuration,
      'periodicEmissionTimerLength': instance.periodicEmissionTimerLength,
      'periodicEmission': instance.periodicEmission,
    };
