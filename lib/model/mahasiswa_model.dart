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