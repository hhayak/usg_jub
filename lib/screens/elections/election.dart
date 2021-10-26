import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usg_jub/models/candidate.dart';
import 'package:usg_jub/models/election.dart';
import 'package:usg_jub/screens/elections/add_candidate.dart';
import 'package:usg_jub/screens/elections/candidate_card.dart';
import 'package:usg_jub/services/auth_service.dart';

class ElectionPage extends StatelessWidget {
  final Election election;
  const ElectionPage({Key? key, required this.election}) : super(key: key);

  List<Widget> _buildCards(List<Candidate> candidates) {
    var cards = candidates
        .map((e) => CandidateCard(
              candidate: e,
              electionId: election.id,
              major: election.major,
            ))
        .toList();
    return cards;
  }

  void handleAdd() {
    Get.defaultDialog(
        title: 'New Candidate', content: CreateCandidateDialogue());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(election.title),
        leading: BackButton(
          onPressed: Get.back,
        ),
      ),
      floatingActionButton: Get.find<AuthService>().isAdmin!
          ? FloatingActionButton(
              onPressed: handleAdd,
              child: const Icon(Icons.add),
              tooltip: 'Add Candidate',
            )
          : null,
      body: SingleChildScrollView(
        child: GetBuilder<ElectionController>(
          init: ElectionController(election),
          builder: (controller) => Center(
            child: Wrap(
              children: _buildCards(controller.election.candidates),
            ),
          ),
        ),
      ),
    );
  }
}

class ElectionController extends GetxController
    with StateMixin<List<Candidate>> {
  final Election election;

  ElectionController(this.election);
}
