import 'package:json_annotation/json_annotation.dart';

import '../helpers/bind_json.dart';

part 'file_dto.g.dart';

@JsonSerializable()
class FileDto {
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int priority;
  String? url;
  @JsonKey(fromJson: fromJsonInt, toJson: toJsonInt)
  int size;
  String? type;
  String? name;
  bool? is_blind;

  FileDto({required this.priority, this.url, required this.size, this.type, this.name, this.is_blind});

  factory FileDto.fromJson(Map<String, dynamic> json) => _$FileDtoFromJson(json);

  Map<String, dynamic> toJson() => {
    'priority': priority,
    'url': url ?? "",
    'size': size,
    'type': type,
    'name': name,
    'is_blind': is_blind
  };
}
