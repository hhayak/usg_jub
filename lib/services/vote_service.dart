import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:usg_jub/models/candidate.dart';
import 'package:usg_jub/models/election.dart';

class VoteService extends GetxService {
  static const String collectionPath = 'elections';
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  late final CollectionReference<Election> collection;
  late final CollectionReference locks;

  VoteService(this.firestore, this.storage, [bool useEmulator = false]) {
    if (useEmulator) {
      try {
        firestore.useFirestoreEmulator('localhost', 8080);
        storage.useStorageEmulator('localhost', 9199);
      } catch (e) {
        //print('Firestore already configured');
      }
    }
    collection = firestore.collection(collectionPath).withConverter<Election>(
        fromFirestore: (snapshot, _) => Election.fromJson(snapshot.data()!),
        toFirestore: (election, _) => election.toJson());
    locks = firestore.collection('locks');
  }

  Future<void> createElection(Election election) async {
    DocumentReference<Election> newDoc;
    if (election.id.isEmpty) {
      newDoc = collection.doc();
      election.id = newDoc.id;
    } else {
      newDoc = collection.doc(election.id);
    }
    newDoc.set(election);
  }

  Future<void> deleteElection(String id) async {
    collection.doc(id).delete();
  }

  Future<void> openElection(String id) async {
    collection.doc(id).update({'isOpen': true});
  }

  Future<void> closeElection(String id) async {
    collection.doc(id).update({'isOpen': false});
  }

  Future<void> registerVote(
      String electionId, String candidateName, String voterId) async {
    await collection.doc(electionId).update({
      'votes.$candidateName': FieldValue.increment(1),
      'totalVotes': FieldValue.increment(1),
    });
    await locks.doc(voterId).update({
      'locks': FieldValue.arrayUnion([electionId])
    });
    FirebaseAnalytics.instance.logEvent(name: 'vote', parameters: {
      'electionId': electionId,
      'candidateName': candidateName,
    });
  }

  Future<void> addCandidate(String electionId, Candidate candidate) async {
    await collection.doc(electionId).update({
      'candidates': FieldValue.arrayUnion(
        [candidate.toJson()],
      ),
    });
  }

  Future<String> uploadPicture(
      Uint8List bytes, String pictureName, String electionId) async {
    var ref = storage.ref('public/elections/$electionId/$pictureName');
    var task = await ref.putData(bytes);
    return (await task.ref.getDownloadURL());
  }

  Future<List<Election>> getElections() async {
    var query = await collection.orderBy('isOpen', descending: true).get();
    var elections = query.docs.map((e) => e.data()).toList();
    return elections;
  }

  Future<List<Election>> getMajorElections(String major) async {
    var query = await collection.where('major', isEqualTo: major).get();
    var elections = query.docs.map((e) => e.data()).toList();
    return elections;
  }

  Future<Map<String, dynamic>> getLocks(String voterId) async {
    Map<String, dynamic> doc =
        (await locks.doc(voterId).get()).data() as Map<String, dynamic>;
    return doc;
  }
}
