
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usg_jub/models/candidate.dart';
import 'package:usg_jub/models/election.dart';

class VoteService {
  static const String collectionPath = 'elections';
  final FirebaseFirestore firestore;
  late final CollectionReference<Election> collection;
  late final CollectionReference locks;

  VoteService(this.firestore, [bool useEmulator = false]) {
    if (useEmulator) {
      try {
        firestore.useFirestoreEmulator('localhost', 8080);
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
      String electionId, String candidateId, String voterId) async {
    await collection.doc(electionId).update({
      'votes.$candidateId': FieldValue.increment(1),
      'totalVotes': FieldValue.increment(1),
    });
    locks.doc(voterId).set({
      'locks': FieldValue.arrayUnion([electionId])
    });
  }

  Future<void> addCandidate(String electionId, Candidate candidate) async {
    await collection.doc(electionId).update({
      'candidates': FieldValue.arrayUnion(
        [candidate.toJson()],
      ),
    });
  }

  Future<List<Election>> getElections() async {
    var query = await collection.get();
    var elections = query.docs.map((e) => e.data()).toList();
    return elections;
  }

  Future<List<Election>> getMajorElections(String major) async {
    var query = await collection.where('major', isEqualTo: major).get();
    var elections = query.docs.map((e) => e.data()).toList();
    return elections;
  }

  Future<List<String>> getLocks(String voterId) async {
    Map<String, dynamic> doc =
        (await locks.doc(voterId).get()).data() as Map<String, dynamic>;
    List list = doc['locks'];
    return list.map((e) => e.toString()).toList();
  }
}
