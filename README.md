<h1 align="center">CRUD Sederhana menggunakan Firebase</h1>

Pada kesempatan kali ini saya akan mencoba untuk menampilkan apa yang telah saya buat yaitu Project CRUD (Create, Update, and Delete) sederhana menggunakan Flutter dan Firebase. Pertama-tama saya akan menampilkan source code untuk mengatur tampilan awal yang saya buat sebagai berikut:
<details>
  <summary>home_page.dart
    
  <p align="center">
  <img src="Picture/Tampilan Running.png" width="350">
</p>

  </summary>
  
  ```dart
import 'package:flutter/material.dart';
import 'package:crud_sederhana/model/mahasiswa_model.dart';
import 'package:crud_sederhana/service/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FirestoreService firestore = FirestoreService();
  final TextEditingController nama = TextEditingController();
  final TextEditingController nim = TextEditingController();
  final TextEditingController kelas = TextEditingController();

  //dialog form tambah & edit data
  void tampilkanForm({Mahasiswa? data}) {
    if (data != null) {
      nama.text = data.nama;
      nim.text = data.nim;
      kelas.text = data.kelas;
    } else {
      nama.clear();
      nim.clear();
      kelas.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data == null ? 'Tambah Mahasiswa' : 'Edit Mahasiswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nama,
              decoration: const InputDecoration(labelText: 'Nama Mahasiswa'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nim,
              decoration: const InputDecoration(labelText: 'NIM'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: kelas,
              decoration: const InputDecoration(labelText: 'Kelas'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final mahasiswa = Mahasiswa(
                id: data?.id ?? '',
                nama: nama.text,
                nim: nim.text,
                kelas: kelas.text,
              );
              if (data == null) {
                firestore.addMahasiswa(mahasiswa);
              } else {
                firestore.updateMahasiswa(mahasiswa);
              }
              Navigator.pop(context);
            },
            child: Text(data == null ? 'Simpan' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mahasiswa Firebase'),
        backgroundColor: Colors.deepOrange,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () => tampilkanForm(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Mahasiswa>>(
        stream: firestore.getMahasiswa(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final dataMahasiswa = snapshot.data!;
          return ListView.builder(
            itemCount: dataMahasiswa.length,
            itemBuilder: (context, index) {
              final m = dataMahasiswa[index];
              return ListTile(
                title: Text(m.nama),
                subtitle: Text('NIM: ${m.nim} | Kelas: ${m.kelas}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed:() => tampilkanForm(data: m),
                      icon: Icon(Icons.edit, color: Colors.blue),
                    ),
                    IconButton(
                      onPressed:() => firestore.deleteMahasiswa(m.id),
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                  ]
                ),
              );
            },
          );
        }),
    );
  }
}
```
</details>

Kemudian selanjutnya saya akan menampilkan code yang saya gunakan untuk menjadi jembatan atau penerjemah data antara Flutter dengan database Firebase. Sebagai berikut:
<details>

<summary>mahasiswa_model.dart</summary>

```dart
class Mahasiswa {
  String id;
  String nama;
  String nim;
  String kelas;

  Mahasiswa({
    required this.id,
    required this.nama,
    required this.nim,
    required this.kelas,
  });

  // Konversi data firestore ke object Mahasiswa
  factory Mahasiswa.fromMap(Map<String, dynamic> data, String id) {
    return Mahasiswa(
      id: id,
      // PERBAIKAN: Gunakan huruf Kapital di awal sesuai field di Firebase Anda
      nama: data['Nama'] ?? '',   
      nim: data['NIM'] ?? '',     
      kelas: data['Kelas'] ?? '', 
    );
  }

  // Konversi object Mahasiswa ke data firestore
  Map<String, dynamic> toMap() {
    return {
      'Nama': nama,
      'NIM': nim,
      'Kelas': kelas,
    };
  }
}
```
</details>

Selanjutnya saya membuat code yang berfungsi sebagai penghubung utama antara kode program Flutter yang di tulis pada VS Code dengan server layanan Firebase di cloud. Code nya sebagai berikut:
<details>

  <summary>firebase_options.dart</summary>

  ```dart
// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCXmkR8Md_x8GoUtJvT4VZI6N5B-4TNElU',
    appId: '1:306321474961:web:3594739d27d233f28fc630',
    messagingSenderId: '306321474961',
    projectId: 'crudmahasiswa-bcdd6',
    authDomain: 'crudmahasiswa-bcdd6.firebaseapp.com',
    storageBucket: 'crudmahasiswa-bcdd6.firebasestorage.app',
    measurementId: 'G-TM4HWJC7WJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-wXi7BWmpcFe04nQ3utIF55kWhilRmOQ',
    appId: '1:306321474961:android:91b7c0e8b39b0dd48fc630',
    messagingSenderId: '306321474961',
    projectId: 'crudmahasiswa-bcdd6',
    storageBucket: 'crudmahasiswa-bcdd6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCfqbXqnuSkE9dKH5hLUZGoQdzqD2fx-6E',
    appId: '1:306321474961:ios:231b3c14cfe554a78fc630',
    messagingSenderId: '306321474961',
    projectId: 'crudmahasiswa-bcdd6',
    storageBucket: 'crudmahasiswa-bcdd6.firebasestorage.app',
    iosBundleId: 'com.example.crudSederhana',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCfqbXqnuSkE9dKH5hLUZGoQdzqD2fx-6E',
    appId: '1:306321474961:ios:231b3c14cfe554a78fc630',
    messagingSenderId: '306321474961',
    projectId: 'crudmahasiswa-bcdd6',
    storageBucket: 'crudmahasiswa-bcdd6.firebasestorage.app',
    iosBundleId: 'com.example.crudSederhana',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCXmkR8Md_x8GoUtJvT4VZI6N5B-4TNElU',
    appId: '1:306321474961:web:d2ee4aa04d44ec118fc630',
    messagingSenderId: '306321474961',
    projectId: 'crudmahasiswa-bcdd6',
    authDomain: 'crudmahasiswa-bcdd6.firebaseapp.com',
    storageBucket: 'crudmahasiswa-bcdd6.firebasestorage.app',
    measurementId: 'G-M5LDL3WEF0',
  );
}
```
  
</details>

Berikut adalah implementasi CRUD yang saya buat:
<details>

<summary>firestore_service.dart</summary>

```dart

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
  ```

</details>

Setelah saya menambahkan data pada aplikasi Flutter tersebut, maka seperti ini tampilan nya:
<p align="left">
  <img src="Picture/Tampilan Firebase1.png" width="350">
  <img src="Picture/Tampilan Firebase2.png" width="350">
</p>
Jika saya menghapus data tersebut dari aplikasi maka kedua data tersebut akan menghilang. Terima kasih telah melihat proyek CRUD sederhana ini, Proyek ini merupakan hasil pembelajaran saya dalam mengeksplorasi ekosistem Flutter dan Firebase.


