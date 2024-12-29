import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  //post data
  Future addPersonalTask(
      Map<String, dynamic> userPersonalMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("PersonalTask")
        .doc(id)
        .set(userPersonalMap);
  }

  //fetch data
  Future<Stream<QuerySnapshot>> getTask(String task) async {
    return FirebaseFirestore.instance.collection(task).snapshots();
  }

  tickmethod(String id, String task) async {
    return await FirebaseFirestore.instance
        .collection(task)
        .doc(id)
        .update({"done": true});
  }

  updateTask(String id, String updatedTask) async {
    await FirebaseFirestore.instance
        .collection("PersonalTask")
        .doc(id)
        .update({"work": updatedTask});
  }

  Future addToDoneTask(Map<String, dynamic> userPersonalMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Done")
        .doc(id)
        .set(userPersonalMap);
  }

  removeMethod(String id, String task) async {
    return await FirebaseFirestore.instance.collection(task).doc(id).delete();
  }
}
