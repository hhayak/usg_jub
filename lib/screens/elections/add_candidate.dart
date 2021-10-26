import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:usg_jub/models/candidate.dart';
import 'package:usg_jub/screens/elections/candidate_card.dart';
import 'package:usg_jub/screens/elections/election.dart';
import 'package:usg_jub/services/vote_service.dart';
import 'package:uuid/uuid.dart';

class AddCandidateCard extends CandidateCard {
  AddCandidateCard({Key? key})
      : super(
            key: key,
            candidate: Candidate('', '', '', ''),
            electionId: '',
            major: []);

  void handleAdd() {
    Get.defaultDialog(
        title: 'New Candidate', content: CreateCandidateDialogue());
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: CircleAvatar(
                radius: 30,
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
    var image = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 100,
        maxWidth: 100,
        imageQuality: 10);
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
