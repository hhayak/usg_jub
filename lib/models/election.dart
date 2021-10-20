import 'package:json_annotation/json_annotation.dart';
import 'package:usg_jub/models/candidate.dart';

part 'election.g.dart';

@JsonSerializable()
class Election {
  String id;
  final String title;
  @JsonKey(toJson: listCandidateToJson, fromJson: listCandidateFromJson)
  final List<Candidate> candidates;
  final Map<String, int> votes;
  int totalVotes;
  final DateTime startTime;
  final DateTime endTime;
  bool isOpen;
  final Candidate? winner;
  final String major;

  static List<Map<String, dynamic>> listCandidateToJson(List<Candidate> e) =>
      e.map((c) => c.toJson()).toList();
  static List<Candidate> listCandidateFromJson(List<dynamic> e) =>
      e.map((c) => Candidate.fromJson(c)).toList();

  Election(this.id, this.title, this.candidates, this.votes, this.totalVotes,
      this.startTime, this.endTime, this.major,
      [this.winner, this.isOpen = false]);

  factory Election.fromJson(Map<String, dynamic> json) =>
      _$ElectionFromJson(json);

  Map<String, dynamic> toJson() => _$ElectionToJson(this);
}
