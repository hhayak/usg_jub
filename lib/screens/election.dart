import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:usg_jub/models/candidate.dart';
import 'package:usg_jub/models/election.dart';
import 'package:usg_jub/screens/home.dart';
import 'package:usg_jub/services/auth_service.dart';
import 'package:usg_jub/services/vote_service.dart';
import 'package:uuid/uuid.dart';

class ElectionPage extends StatelessWidget {
  final Election election;
  const ElectionPage({Key? key, required this.election}) : super(key: key);

  List<Widget> _buildCards(List<Candidate> candidates) {
    var cards = candidates
        .map((e) => CandidateCard(
              candidate: e,
              electionId: election.id,
              major:  election.major,
            ))
        .toList();
    if (Get.find<AuthService>().isAdmin ?? false) {
      cards.add(AddCandidateCard());
    }
    return cards;
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
      body: GetBuilder<ElectionController>(
        init: ElectionController(election),
        builder: (controller) => Wrap(
          children: _buildCards(controller.election.candidates),
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

class CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final String electionId;
  final String major;
  const CandidateCard(
      {Key? key, required this.candidate, required this.electionId, required this.major})
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
            child: Text(candidate.description),
          ),
        ],
      ),
      cancel: TextButton(
        onPressed: Get.back,
        child: const Text('Back'),
      ),
      confirm: ElevatedButton(
        onPressed: !Get.find<HomeController>().isVoterLocked(electionId) && Get.find<HomeController>().major == major ? handleVote : null,
        child: const Text('Vote'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
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
    );
  }
}

class AddCandidateCard extends CandidateCard {
  AddCandidateCard({Key? key})
      : super(key: key, candidate: Candidate('', '', '', ''), electionId: '', major: '');

  void handleAdd() {
    Get.defaultDialog(
        title: 'New Candidate', content: CreateCandidateDialogue());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.add),
              ),
              title: Text('New Candidate'),
            ),
            TextButton(
              onPressed: handleAdd,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateCandidateDialogue extends StatelessWidget {
  final _btnController = RoundedLoadingButtonController();
  final form = FormGroup({
    'name': FormControl<String>(validators: [Validators.required]),
    'description': FormControl<String>(validators: [Validators.required]),
    'picture': FormControl<XFile>(validators: [Validators.required]),
  });
  CreateCandidateDialogue({Key? key}) : super(key: key);

  Future<void> pickImage() async {
    var picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery);
    form.control('picture').updateValue(image);
  }

  Future<void> handleCreate() async {
    if (form.valid) {
      XFile picture = form.control('picture').value;
      var pictureBytes = await picture.readAsBytes();
      var id = const Uuid().v1();
      var pictureName = '$id.${picture.name.split('.').last}';
      var electionId = Get.find<ElectionController>().election.id;
      try {
        var pictureUrl = await Get.find<VoteService>()
            .uploadPicture(pictureBytes, pictureName, electionId);
        var candidate = Candidate(id, form.control('name').value,
            form.control('description').value, pictureUrl);
        await Get.find<VoteService>().addCandidate(electionId, candidate);
        Get.find<ElectionController>().election.candidates.add(candidate);
        Get.find<ElectionController>().update();
        Get.back();
        Get.snackbar('Success', 'Added candidate with ID: ${candidate.id}');
      } on Exception catch (e) {
        Get.snackbar('Failed to add new candidate.', e.toString());
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ReactiveValueListenableBuilder<XFile>(
            formControlName: 'picture',
            builder: (context, control, child) => CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                control.value?.path ?? '',
              ),
              onBackgroundImageError: (error, trace) => const FlutterLogo(),
              child: control.value == null
                  ? IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: pickImage,
                    )
                  : null,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ReactiveTextField<String>(
            formControlName: 'name',
            decoration: const InputDecoration(label: Text('Name')),
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            onSubmitted: () => form.focus('description'),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 600,
            child: ReactiveTextField<String>(
              formControlName: 'description',
              decoration: const InputDecoration(hintText: 'Description'),
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: 10,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
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
