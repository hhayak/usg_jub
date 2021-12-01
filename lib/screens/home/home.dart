import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:usg_jub/constants/majors.dart';
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

  Future<String?> getMajor() async {
    final majorControl = FormControl<String>();
    var selectedMajor = await Get.defaultDialog<String>(
      title: 'Select your Major',
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: ReactiveDropdownField<String>(
          formControl: majorControl,
          decoration: const InputDecoration(labelText: 'Major'),
          items: majors
              .map((e) => DropdownMenuItem<String>(
                    child: Text(e),
                    value: e,
                  ))
              .toList(),
        ),
      ),
      textConfirm: 'Confirm',
      confirm: ElevatedButton(
        onPressed: () => Get.back<String?>(result: majorControl.value),
        child: const Text('Confirm'),
      ),
    );

    return selectedMajor;
  }

  Future<void> editMajor() async {
    var major = await getMajor();
    if (major != null) {
      await AuthService.to.setMajor(HomeController.to.voterId, major);
      HomeController.to.major = major;
      HomeController.to.softRefresh();
    }
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Your Major: ${Get.find<HomeController>().major}'),
                    IconButton(
                      onPressed:
                          HomeController.to.major.isEmpty ? editMajor : null,
                      icon: Icon(
                        HomeController.to.major.isEmpty
                            ? Icons.edit
                            : Icons.lock_rounded,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (Get.find<AuthService>().isAdmin!) ...{
                      IconButton(
                        onPressed: openElectionCreation,
                        icon: const Icon(Icons.add_rounded),
                        tooltip: 'New Election',
                      ),
                    },
                    IconButton(
                      onPressed: HomeController.to.getElections,
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh',
                    ),
                    IconButton(
                      onPressed: handleLogout,
                      color: Colors.red,
                      icon: const Icon(Icons.logout_rounded),
                      tooltip: 'Logout',
                    ),
                  ],
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      ElectionCard(election: elections![index]),
                  itemCount: elections!.length,
                  shrinkWrap: true,
                ),
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
