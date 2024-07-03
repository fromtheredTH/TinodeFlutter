// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileDto _$FileDtoFromJson(Map<String, dynamic> json) => FileDto(
      priority: fromJsonInt(json['priority']),
      url: json['url'] as String?,
      size: fromJsonInt(json['size']),
      type: json['type'] as String?,
      name: json['name'] as String?,
      is_blind: json['is_blind'] as bool?,
    );

Map<String, dynamic> _$FileDtoToJson(FileDto instance) => <String, dynamic>{
      'priority': toJsonInt(instance.priority),
      'url': instance.url,
      'size': toJsonInt(instance.size),
      'type': instance.type,
      'name': instance.name,
      'is_blind': instance.is_blind,
    };
