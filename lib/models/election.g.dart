// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'election.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Election _$ElectionFromJson(Map<String, dynamic> json) => Election(
      json['id'] as String,
      json['title'] as String,
      Election.listCandidateFromJson(json['candidates'] as List),
      Map<String, int>.from(json['votes'] as Map),
      json['totalVotes'] as int,
      DateTime.parse(json['startTime'] as String),
      DateTime.parse(json['endTime'] as String),
      json['major'] as String,
      json['winner'] == null
          ? null
          : Candidate.fromJson(json['winner'] as Map<String, dynamic>),
      json['isOpen'] as bool? ?? false,
    );

Map<String, dynamic> _$ElectionToJson(Election instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'candidates': Election.listCandidateToJson(instance.candidates),
      'votes': instance.votes,
      'totalVotes': instance.totalVotes,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'isOpen': instance.isOpen,
      'winner': instance.winner,
      'major': instance.major,
    };
