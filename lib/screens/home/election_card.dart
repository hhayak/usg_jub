import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usg_jub/models/election.dart';
import 'package:usg_jub/screens/elections/election.dart';
import 'package:usg_jub/screens/home/home_controller.dart';
import 'package:usg_jub/services/auth_service.dart';
import 'package:usg_jub/services/vote_service.dart';

enum ManageOptions { open, close, delete, candidates }

class ElectionCard extends StatelessWidget {
  final Election election;
  const ElectionCard({Key? key, required this.election}) : super(key: key);

  void goToElection() {
    Get.to(() => ElectionPage(election: election),
        routeName: 'election/${election.id}', transition: Transition.native);
  }

  void showResults() {
    var results = '';
    var entries = election.votes.entries.toList()
      ..sort((e1, e2) => e1.value.compareTo(e2.value));
    for (var candidate in entries) {
      results = results + '${candidate.key}: ${candidate.value}\n';
    }
    Get.defaultDialog(
        title: 'Vote results of ${election.title}',
        middleText: results,
        textCancel: 'Hide');
  }

  String formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(election.title),
            isThreeLine: true,
            subtitle: Text(
                '${election.major}\nStarting Date: ${formatDate(election.startTime)}\nClosing Date: ${formatDate(election.endTime)}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Text('Total votes: ${election.totalVotes}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: election.isOpen &&
                          election.major
                              .contains(Get.find<HomeController>().major) &&
                          !Get.find<HomeController>().isVoterLocked(election.id)
                      ? goToElection
                      : null,
                  child: Text('Vote (${election.isOpen ? 'Open' : 'Closed'})'),
                ),
                TextButton(
                  onPressed: election.isOpen ? null : showResults,
                  child: const Text('Show Results'),
                ),
                if (Get.find<AuthService>().isAdmin ?? false) ...{
                  PopupMenuButton<ManageOptions>(
                    itemBuilder: (context) => <PopupMenuEntry<ManageOptions>>[
                      const PopupMenuItem<ManageOptions>(
                        value: ManageOptions.open,
                        child: Text('Open'),
                      ),
                      const PopupMenuItem<ManageOptions>(
                        value: ManageOptions.close,
                        child: Text('Close'),
                      ),
                      const PopupMenuItem<ManageOptions>(
                        value: ManageOptions.delete,
                        child: Text('Delete'),
                      ),
                      const PopupMenuItem<ManageOptions>(
                        value: ManageOptions.candidates,
                        child: Text('Manage Candidates'),
                      ),
                    ],
                    onSelected: (option) async {
                      switch (option) {
                        case ManageOptions.open:
                          await Get.find<VoteService>()
                              .openElection(election.id);
                          Get.find<HomeController>().getElections();
                          break;
                        case ManageOptions.close:
                          await Get.find<VoteService>()
                              .closeElection(election.id);
                          Get.find<HomeController>().getElections();
                          break;
                        case ManageOptions.delete:
                          await Get.find<VoteService>()
                              .deleteElection(election.id);
                          Get.find<HomeController>().getElections();
                          break;
                        case ManageOptions.candidates:
                          goToElection();
                          break;
                        default:
                      }
                    },
                  ),
                }
              ],
            ),
          ),
        ],
      ),
    );
  }
}
