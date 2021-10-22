// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Candidate _$CandidateFromJson(Map<String, dynamic> json) => Candidate(
      json['id'] as String,
      json['name'] as String,
      json['description'] as String,
      json['pictureUrl'] as String?,
    );

Map<String, dynamic> _$CandidateToJson(Candidate instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'pictureUrl': instance.pictureUrl,
    };
