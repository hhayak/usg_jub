import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usg_jub/models/candidate.dart';
import 'package:usg_jub/screens/home/home.dart';
import 'package:usg_jub/services/auth_service.dart';
import 'package:usg_jub/services/vote_service.dart';

class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final String electionId;
  final List<String> major;
  const CandidateCard(
      {Key? key,
      required this.candidate,
      required this.electionId,
      required this.major})
      : super(key: key);

  Future<void> handleConfirmVote() async {
    try {
      await Get.find<VoteService>().registerVote(
          electionId, candidate.name, Get.find<AuthService>().user!.uid);
      Get.find<HomeController>().locks.add(electionId);
      Get.find<HomeController>().softRefresh();
      Get.back(closeOverlays: true);
      Get.snackbar(
          'Vote registered', "Your vote has been submitted successfully!");
    } catch (e) {
      Get.back(closeOverlays: true);
      Get.snackbar('Voting failed',
          "We could not submit your vote. Please try again later or contact an admin.");
    }
  }

  Future<void> handleVote() async {
    Get.defaultDialog(
        title: 'Confirm your vote?',
        middleText: 'You are voting for: ${candidate.name}',
        cancel: TextButton(
          onPressed: Get.back,
          child: const Text('Cancel'),
        ),
        confirm: ElevatedButton(
          onPressed: handleConfirmVote,
          child: const Text('Confirm'),
        ),
        onConfirm: handleConfirmVote);
  }

  void showDescription() {
    Get.defaultDialog(
      title: candidate.name,
      content: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              candidate.pictureUrl ?? '',
            ),
            onBackgroundImageError: (error, trace) => const FlutterLogo(),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: Get.width / 2,
            height: Get.height / 2,
            child: SingleChildScrollView(
              child: Text(candidate.description),
            ),
          ),
        ],
      ),
      cancel: TextButton(
        onPressed: Get.back,
        child: const Text('Back'),
      ),
      confirm: ElevatedButton(
        onPressed: !Get.find<HomeController>().isVoterLocked(electionId) &&
                major.contains(Get.find<HomeController>().major)
            ? handleVote
            : null,
        child: const Text('Vote'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    candidate.pictureUrl ?? '',
                  ),
                  onBackgroundImageError: (error, trace) => const FlutterLogo(),
                ),
                title: Text(candidate.name),
              ),
              TextButton(
                  onPressed: showDescription,
                  child: const Text('Read Description')),
            ],
          ),
        ),
      ),
    );
  }
}