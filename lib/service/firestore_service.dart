import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_sederhana/model/mahasiswa_model.dart';


class FirestoreService {
  final CollectionReference _mahasiswaCollection =
      FirebaseFirestore.instance.collection('mahasiswa');

//fungsi menambahkan data mahasiswa (create)
  Future<void> addMahasiswa(Mahasiswa mhs){
    return _mahasiswaCollection.add(mhs.toMap());
  }

//fungsi mengambil data mahasiswa (read)
Stream<List<Mahasiswa>> getMahasiswa(){
  return _mahasiswaCollection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return Mahasiswa.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  });
}
  
//fungsi mengupdate data mahasiswa (update)
  Future<void> updateMahasiswa(Mahasiswa mhs){
    return _mahasiswaCollection.doc(mhs.id).update(mhs.toMap());
  }

//fungsi menghapus data mahasiswa (delete)
  Future<void> deleteMahasiswa(String id){
    return _mahasiswaCollection.doc(id).delete();
  }
}