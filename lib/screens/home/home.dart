import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:usg_jub/constants/majors.dart';
import 'package:usg_jub/models/election.dart';
import 'package:usg_jub/screens/home/election_card.dart';
import 'package:usg_jub/screens/screens.dart';
import 'package:usg_jub/services/auth_service.dart';
import 'package:usg_jub/services/vote_service.dart';

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

class HomeController extends GetxController with StateMixin<List<Election>> {
  late List<Election> elections;
  late final VoteService vote;
  late List<String> locks;
  late final String voterId;
  late final String major;

  static HomeController get to => Get.find();

  @override
  void onInit() {
    elections = [];
    vote = Get.find<VoteService>();
    locks = [];
    voterId = Get.find<AuthService>().user!.uid;
    super.onInit();
  }

  @override
  void onReady() {
    try {
      change([], status: RxStatus.loading());
      init();
    } catch (e, s) {
      if (!kDebugMode) {
        Sentry.captureException(
          e,
          stackTrace: s,
        );
      }
      Get.offNamed(Screens.error);
    }
    super.onReady();
  }

  Future<void> init() async {
    var locksMap = await vote.getLocks(voterId);
    locks = List.castFrom<dynamic, String>(locksMap['locks'] ?? []);
    major = locksMap['major'] ?? Get.find<AuthService>().user!.displayName ?? 'none';
    getElections();
  }

  Future<void> getElections() async {
    change([], status: RxStatus.loading());
    try {
      elections = await vote.getElections();
      change(elections,
          status: elections.isEmpty ? RxStatus.empty() : RxStatus.success());
    } on Exception catch (e) {
      change([], status: RxStatus.error(e.toString()));
    }
  }

  void softRefresh() {
    change(elections, status: RxStatus.success());
  }

  bool isVoterLocked(String electionId) {
    return locks.contains(electionId);
  }
}

class CreateElectionDialogue extends StatelessWidget {
  final _btnController = RoundedLoadingButtonController();
  final DateTime firstDate = DateTime.now();
  final form = FormGroup({
    'title': FormControl<String>(validators: [Validators.required]),
    'major': FormControl<String>(validators: [Validators.required]),
    'startTime': FormControl<DateTime>(
        value: DateTime.now(), validators: [Validators.required]),
    'endTime': FormControl<DateTime>(
        value: DateTime.now(), validators: [Validators.required]),
  });

  CreateElectionDialogue({Key? key}) : super(key: key);

  String formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> handleCreate() async {
    if (form.valid) {
      List<String> major;
      switch (form.control('major').value) {
        case 'FAD':
          major = ['GEM', 'IBA', 'SMP', 'IRPH', 'PSY'];
          break;
        case 'FAM':
          major = ['IEM', 'MATH', 'CS', 'ECE', 'IMS'];
          break;
        case 'FAH':
          major = ['BCCB', 'CHEM', 'MCCB', 'EES', 'PHY'];
          break;
        default:
          major = [form.control('major').value];
          break;
      }
      var election = Election(
        '',
        form.control('title').value,
        [],
        {},
        0,
        form.control('startTime').value,
        form.control('endTime').value,
        major,
      );
      try {
        await Get.find<VoteService>().createElection(election);
        Get.back();
        HomeController.to.getElections();
        Get.snackbar(
            'Election created.', 'Added election with ID: ${election.id}');
      } on Exception catch (e) {
        Get.snackbar('Failed to create new election.', e.toString());
      }
    } else {
      _btnController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: form,
      child: Column(
        children: [
          ReactiveTextField<String>(
            formControlName: 'title',
            decoration: const InputDecoration(label: Text('Title')),
            textInputAction: TextInputAction.done,
            onSubmitted: form.control('title').unfocus,
          ),
          const SizedBox(height: 5),
          ReactiveDropdownField<String>(
            formControlName: 'major',
            decoration: const InputDecoration(labelText: 'Major'),
            items: majors
                .map((e) => DropdownMenuItem<String>(
                      child: Text(e),
                      value: e,
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          ReactiveDatePicker(
            formControlName: 'startTime',
            builder: (context, delegate, child) => TextButton.icon(
              onPressed: () => delegate.showPicker(),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                  'Starting Date: ${formatDate(form.control('startTime').value)}'),
            ),
            firstDate: firstDate,
            lastDate: firstDate.add(const Duration(days: 365)),
          ),
          const SizedBox(height: 10),
          ReactiveDatePicker(
            formControlName: 'endTime',
            builder: (context, delegate, child) => TextButton.icon(
              onPressed: () => delegate.showPicker(),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                  'Closing Date: ${formatDate(form.control('endTime').value)}'),
            ),
            firstDate: firstDate,
            lastDate: firstDate.add(const Duration(days: 365)),
          ),
          const SizedBox(height: 10),
          RoundedLoadingButton(
            color: Colors.blueGrey,
            width: 100,
            controller: _btnController,
            onPressed: handleCreate,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
