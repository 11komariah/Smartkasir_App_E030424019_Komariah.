import 'package:flutter/material.dart';

// [TITIK MASUK UTAMA APLIKASI FLUTTER]
void main() {
  runApp(const SmartMarginApp());
}

// [KUK 3.7] Konsep Objek & StatelessWidget sebagai kerangka dasar aplikasi
class SmartMarginApp extends StatelessWidget {
  const SmartMarginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartMargin UMKM Poliban',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1E3A8A),
        useMaterial3: true,
      ),
      home: const KalkulatorMarginScreen(),
    );
  }
}

class KalkulatorMarginScreen extends StatefulWidget {
  const KalkulatorMarginScreen({super.key});

  @override
  State<KalkulatorMarginScreen> createState() => _KalkulatorMarginScreenState();
}

class _KalkulatorMarginScreenState extends State<KalkulatorMarginScreen> {
  // [KUK 3.5] Deklarasi Konstanta (const) untuk aturan bisnis tetap
  static const double diskonTierGold = 0.10;
  static const double diskonTierSilver = 0.05;
  static const double bonusDiskonMember = 0.05;

  // Controller untuk menangkap teks dari form input pengguna
  final TextEditingController _namaController =
      TextEditingController(text: 'Kopi Arabika Banjar 250gr');
  final TextEditingController _modalController =
      TextEditingController(text: '35000');
  final TextEditingController _jualController =
      TextEditingController(text: '55000');
  final TextEditingController _jumlahController =
      TextEditingController(text: '10');

  // [KUK 3.5] Deklarasi Variabel dengan Tipe Data eksplisit (String, int, double, bool)
  String namaProduk = '';
  double hargaModal = 0.0;
  double hargaJual = 0.0;
  int jumlahBarang = 0;
  bool isMember = true;

  // Variabel hasil perhitungan
  double totalBelanjaKotor = 0.0;
  double nominalDiskon = 0.0;
  double totalBayarAkhir = 0.0;
  double labaBersih = 0.0;
  String infoTierDiskon = 'Belum dihitung';
  List<Map<String, dynamic>> proyeksiEnamBulan = [];

  // [KUK 3.4] Fungsi Alur Proses Perhitungan Utama
  void hitungTransaksiUMKM() {
    setState(() {
      namaProduk = _namaController.text.trim();
      hargaModal = double.tryParse(_modalController.text) ?? 0.0;
      hargaJual = double.tryParse(_jualController.text) ?? 0.0;
      jumlahBarang = int.tryParse(_jumlahController.text) ?? 0;

      double totalModal = hargaModal * jumlahBarang;
      totalBelanjaKotor = hargaJual * jumlahBarang;

      // [KUK 3.6 - Struktur Kondisi] Penentuan tier diskon UMKM
      double persenDiskon = 0.0;
      if (totalBelanjaKotor >= 500000) {
        persenDiskon = diskonTierGold;
        infoTierDiskon = 'Tier Gold (Diskon 10%)';
      } else if (totalBelanjaKotor >= 200000) {
        persenDiskon = diskonTierSilver;
        infoTierDiskon = 'Tier Silver (Diskon 5%)';
      } else {
        persenDiskon = 0.0;
        infoTierDiskon = 'Reguler (Diskon 0%)';
      }

      if (isMember) {
        persenDiskon += bonusDiskonMember;
        infoTierDiskon += ' + Member (5%)';
      }

      nominalDiskon = totalBelanjaKotor * persenDiskon;
      totalBayarAkhir = totalBelanjaKotor - nominalDiskon;
      labaBersih = totalBayarAkhir - totalModal;

      // [KUK 3.6 - Struktur Perulangan] Proyeksi pertumbuhan 6 bulan
      proyeksiEnamBulan.clear();
      for (int bulan = 1; bulan <= 6; bulan++) {
        double faktorNaik = 1.0 + ((bulan - 1) * 0.10);
        int estimasiUnit = (jumlahBarang * faktorNaik).round();
        double estimasiLaba = labaBersih * faktorNaik;
        proyeksiEnamBulan.add({
          'bulan': bulan,
          'unit': estimasiUnit,
          'laba': estimasiLaba,
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    hitungTransaksiUMKM();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartMargin & Diskon UMKM'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Input Parameter Transaksi Produk',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk UMKM (String)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _modalController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga Modal / HPP (double)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _jualController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga Jual Satuan (double)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Barang Terjual (int)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Pelanggan Member Aktif (bool isMember)'),
                      subtitle: const Text('Tambahan diskon ekstra +5%'),
                      value: isMember,
                      onChanged: (val) {
                        setState(() => isMember = val);
                        hitungTransaksiUMKM();
                      },
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: hitungTransaksiUMKM,
                        icon: const Icon(Icons.calculate),
                        label: const Text('HITUNG MARGIN & PROYEKSI'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFFEFF6FF),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2. Hasil Kalkulasi: $namaProduk',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Text('Status Diskon: $infoTierDiskon'),
                    Text('Total Belanja Kotor: Rp ${totalBelanjaKotor.toStringAsFixed(0)}'),
                    Text('Nominal Potongan Diskon: Rp ${nominalDiskon.toStringAsFixed(0)}'),
                    Text(
                      'Total Bayar Akhir: Rp ${totalBayarAkhir.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      'Laba Bersih Transaksi: Rp ${labaBersih.toStringAsFixed(0)} (${labaBersih >= 0 ? "PROFIT" : "RUGI"})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: labaBersih >= 0 ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '3. Proyeksi Pertumbuhan Laba 6 Bulan (Hasil Perulangan for):',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...proyeksiEnamBulan.map((item) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('B${item['bulan']}')),
                    title: Text('Bulan ke-${item['bulan']} (Target: ${item['unit']} unit)'),
                    trailing: Text(
                      'Laba: Rp ${(item['laba'] as double).toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
