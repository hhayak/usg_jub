import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:usg_jub/models/election.dart';
import 'package:usg_jub/screens/screens.dart';
import 'package:usg_jub/services/auth_service.dart';
import 'package:usg_jub/services/vote_service.dart';

class HomeController extends GetxController with StateMixin<List<Election>> {
  late List<Election> elections;
  late final VoteService vote;
  late List<String> locks;
  late final String voterId;
  late String major;

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
    major =
        locksMap['major'] ?? Get.find<AuthService>().user!.displayName ?? '';
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
