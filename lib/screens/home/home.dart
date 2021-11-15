import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usg_jub/screens/home/create_election_dialogue.dart';
import 'package:usg_jub/screens/home/election_card.dart';
import 'package:usg_jub/screens/home/home_controller.dart';
import 'package:usg_jub/screens/screens.dart';
import 'package:usg_jub/services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> handleLogout() async {
    await Get.find<AuthService>().logout();
    Get.offAllNamed(Screens.login);
  }

  Future<void> openElectionCreation() async {
    Get.defaultDialog(title: 'New Election', content: CreateElectionDialogue());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Get.find<HomeController>().obx(
        (elections) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/usg_logo.png',
                  height: 200,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      ElectionCard(election: elections![index]),
                  itemCount: elections!.length,
                  shrinkWrap: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (Get.find<AuthService>().isAdmin!) ...{
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: openElectionCreation,
                          child: const Text('New Election'),
                        ),
                      ),
                    },
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: Get.find<HomeController>().getElections,
                        child: const Text('Refresh'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: handleLogout,
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
                Text(
                    'Your selected major: ${Get.find<HomeController>().major}'),
              ],
            ),
          ),
        ),
        onEmpty: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/usg_logo.png',
                height: 200,
              ),
              const SizedBox(
                height: 50,
              ),
              const Text('No elections found.'),
              if (Get.find<AuthService>().isAdmin!) ...{
                ElevatedButton(
                    onPressed: openElectionCreation,
                    child: const Text('Create new election')),
              }
            ],
          ),
        ),
        onLoading: const Center(
          child: CircularProgressIndicator(),
        ),
        onError: (error) => Center(
          child: Text('Failed to load elections: $error'),
        ),
      ),
    );
  }
}