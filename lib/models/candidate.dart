import 'package:json_annotation/json_annotation.dart';

part 'candidate.g.dart';

@JsonSerializable()
class Candidate {
  final String id;
  final String name;
  final String description;
  final String? pictureUrl;

  Candidate(this.id, this.name, this.description, [this.pictureUrl]);

  factory Candidate.fromJson(Map<String, dynamic> json) =>
      _$CandidateFromJson(json);

  Map<String, dynamic> toJson() => _$CandidateToJson(this);
}
