import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:usg_jub/constants/majors.dart';
import 'package:usg_jub/models/election.dart';
import 'package:usg_jub/screens/home/home_controller.dart';
import 'package:usg_jub/services/vote_service.dart';

class CreateElectionDialogue extends StatelessWidget {
  final List<String> majorsChoices = [
    ...majors,
    'FAD',
    'FAM',
    'FAH',
    'Everyone'
  ];
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
          major = fadMajors;
          break;
        case 'FAM':
          major = famMajors;
          break;
        case 'FAH':
          major = fahMajors;
          break;
        case 'Everyone':
          major = majors;
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
            items: majorsChoices
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
