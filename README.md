<h1 align="center">CRUD Sederhana menggunakan Firebase</h1>

Pada kesempatan kali ini saya akan mencoba untuk menampilkan apa yang telah saya buat yaitu Project CRUD (Create, Update, and Delete) sederhana menggunakan Flutter dan Firebase. Pertama-tama saya akan menampilkan source code untuk mengatur tampilan awal yang saya buat sebagai berikut:
<details>
  <summary>home_page.dart</summary>

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
</details>
<p align="center">
  <img src="Picture/Tampilan Running.png" width="300">
</p>
