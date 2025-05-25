import 'package:project_skripsi/screen/gabriel/core/app_export.dart';

class OthersScreen extends StatefulWidget {
  @override
  _OthersScreenState createState() => _OthersScreenState();
}

// Fungsi untuk membuat teks dengan indentasi rapi
Widget _buildIndentedText(String bullet, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 12),
      Text(bullet),
      SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          textAlign: TextAlign.justify,
        ),
      ),
    ],
  );
}

class _OthersScreenState extends State<OthersScreen> {
  bool isSupportExpanded = true;
  bool isTermsExpanded = true;

  final List<Widget> supportWidget = [
    Center(
      child: Container(
          margin: EdgeInsets.fromLTRB(10.h, 20.v, 10.h, 20.v),
          child: Image.asset(
            'assets/images/support.jpg',
          )),
    ),
    Text(
        'Kemudahan dan Kepraktisan, itulah yang dicari masyarakat sekarang ini.'
        'Guna memenuhi kebutuhan itu, Tiara Gatzu Grup meluncurkan Aplikasi '
        'Member untuk memberikan kemudahan transaksi bagi para konsumen '
        'setia Tiara Gatzu Grup. Kami juga ingin menawarkan kenyamanan, karena '
        'aplikasi member ini mempunyai banyak manfaat. Dengan Aplikasi Member, '
        'pelanggan bisa :\n'),
    _buildIndentedText('1.', 'Mengumpulkan point stiker,'),
    _buildIndentedText('2.', 'Melihat Jumlah dan riwayat point stiker,'),
    _buildIndentedText('3.', 'Penukaran hadiah stiker secara online.'),
    SizedBox(height: 16),
    Text(
      'Ini akan menjadi lebih cepat dan mudah untuk digunakan. Hal ini juga '
      'menjadikan kami semakin mendekatkan diri dengan konsumen.\n',
      textAlign: TextAlign.justify,
    ),
  ];

  final List<Widget> termsWidget = [
    Center(
      child: Container(
          margin: EdgeInsets.fromLTRB(10.h, 20.v, 10.h, 20.v),
          child: Image.asset(
            'assets/images/term_of_use.jpg',
          )),
    ),
    Text(
      'KETENTUAN UMUM\n',
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
    ),
    Text(
      '1.	Perusahaan adalah CV. Tiara Dalung Permai sebagai penerbit kartu anggota untuk menjalankan program-program pemasaran yang ditujukan kepada pelanggan yang berbelanja di lokasi-lokasi yang bekerjasama dengan perusahaan.\n\n'
      '2.	Lokasi adalah tempat kartu tersebut bisa digunakan yaitu Tiara Gatzu, Tiara Monang Maning, dan Toko Soputan Fresh.\n\n'
      '3.	Sticker Card adalah kartu member yang diterbitkan oleh perusahaan yang ditujukan kepada pelanggan yang memenuhi persyaratan untuk mengumpulkan point sticker. Nantinya dapat ditukarkan dengan hadiah yang disediakan selanjutnya disebut kartu.\n\n'
      '4.	Cazh Back Card adalah kartu member yang diterbitkan oleh Perusahaan yang ditujukan kepada pelanggan yang memenihi persyaratan untuk mengumpulkan point cashback. Nantinya dapat digunakan untuk mendapatkan potongan pembayaran selanjutnya disebut Kartu.\n\n'
      '5.	Keanggotaan terbuka untuk konsumen dan telah memiliki Kartu Tanda Penduduk (“KTP”) atau tanda pengenal lain yang sah dan masih berlaku, Nama yang dituliskan pada saat pendaftaran harus sama dengan nama yang tercantum pada tanda pengenal yang diberikan.\n\n'
      '6.	Kartu hanya dapat dipergunakan oleh nama yang tertera pada Kartu untuk maksud dan tujuan yang terkait dengan keanggotaan Kartu. Anggota Kartu bertanggungjawab penuh atas penggunaan Kartu, Keanggotaan Kartu tidak dapat dipindahtangankan atau diperjualbelikan serta penggunanya tunduk pada ketentuan yang ditentukan oleh Perusahaan dan tunduk pada hukum yang berlaku di Negara Republik Indonesia.\n\n'
      '7.	Perusahaan berhak menolak formulir pendaftaran yang tidak lengkap dan tidak memenuhi persyaratan tanpa pemberitahuan.\n\n'
      '8.	Biaya pembuatan dan perpanjangan Cazhback Card Rp 10.000.\n\n'
      '9.	Perusahaan setiap saat berhak untuk membuat dan atau mengubah dan atau mengartikan dan atau menerapkan kebijakan dan mekanisme untuk Keanggotaan Kartu.\n\n'
      '10.	Kartu adalah milik Perusahaan, apabila menemukan harap mengembalikan ke Lokasi.\n\n'
      '11.	Dalam hal terapat klausul pada Syarat dan Ketentuan keanggotaan Kartu ini yang bertentangan dengan undang-undang yang berlaku, maka hal ini tidak akan mempengaruhi efektifitas klausul-klausul lain yang tidak bertentangan dengan undang-undang yang berlaku.\n\n'
      '12.	Program-program pemasaran atau program Kartu lainnya yang dilaksanakan oleh Perusahaan hanya berlaku bagi anggota Kartu yang ditentukan dalam program tersebut.\n\n'
      '13.	Perusahaan tidak bertanggung jawab atas segala risiko yang ditimbulkan akibat penyalahgunaan keanggotaan Kartu, termasuk jika terjadi kehilangan dan terjadi pengurangan pada point Kartu.\n\n'
      '14.	Apabila terjadi kerusakan/kehilangan wajib melaporkan dan dikenakan biaya atas pergantian Kartu sebesar Rp 10.000.\n\n'
      '15.	Laporan kehilangan/pemblokiran dapat melalui Customer Service di nomor 0361-4189-18 atau WHATSAPP 0361-4189-18 pada hari kerja (Senin-Sabtu pk. 08.00 sd 15.00). Jika melewati jam tersebut diatas maka akan diproses keesokan harinya dan segala risiko menjadi tanggung jawab pemilik Kartu.\n\n'
      '16.	Perusahaan berhak untuk melakukan pemeriksaan terhadap data anggota Kartu setiap saat, tanpa memerlukan ijin dari anggota Kartu. Apabila terdapat ketidaksesuaian informasi atau data, maka pemberian manfaat dan keistimewaan akan ditunda sampai Perusahaan mengeluarkan keputusan mengenai hal itu.\n\n'
      '17.	Perusahaan memiliki kewenangan untuk melakukan tindakan apapun terhadap tiap pelanggaran perarturan dan ketentuan keanggotaan Kartu.\n\n'
      '18.	Semua keputusan yang dibuat oleh Perusahaan yang berkaitan dengan keanggotaan Kartu bersifat mutlak dan tidak dapat diganggu gugat.\n\n'
      '19.	Segala perselisihan yang timbul antara Perusahaan dan anggota Kartu akan diselesaikan melalui musyawarah untuk mencapai mufakat. Apabila tidak tercapai kesepakatan maka penyelesaiannya akan dilakukan melalui Pengadilan Negeri Denpasar.\n\n',
      textAlign: TextAlign.justify,
    ),
    Text(
      'KETENTUAN KHUSUS\n',
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('A. Persyaratan untuk menjadi Anggota Kartu:\n'),
        _buildIndentedText('a.',
            'Mengisi formulir pendaftaran dengan jujur, akurat, dan lengkap.'),
        _buildIndentedText('b.',
            'Menyerahkan dan menunjukkan tanda pengenal yang masih berlaku.'),
        SizedBox(height: 16),
        Text('B. Periode Pengumpulan Poin Stiker:\n'),
        _buildIndentedText('a.', 'Bulan Desember sd Mei.'),
        _buildIndentedText('b.', 'Bulan Juni sd November.'),
        _buildIndentedText('c.',
            'Untuk Cazhback Card, apabila Kartu dalam keadaan aktif maka sisa poin akan digabungkan ke periode berikutnya.'),
        SizedBox(height: 16),
        Text('C. Perolehan Poin:\n'),
        _buildIndentedText('a.',
            'Poin diperoleh dari pembayaran pembelanjaan (“Transaksi”) melalui mesin register kasir di lokasi.'),
        _buildIndentedText('b.',
            'Untuk dapat memperoleh Poin, Anggota Kartu terlebih dahulu menunjukkan Kartu kepada kasir sebelum melakukan Transaksi.'),
        _buildIndentedText(
            'c.', 'Poin tidak dapat dipindahtangankan atau diperjualbelikan.'),
        _buildIndentedText('d.',
            'Penghitungan Poin tidak berhubungan dengan alat pembayaran yang dipergunakan, kecuali jika ditentukan lain oleh Perusahaan.'),
        _buildIndentedText('e.',
            'Penghitungan Poin dilakukan per Transaksi dengan pembelian setiap kelipatan Rp 5.000,- akan mendapatkan 1 Poin.'),
        _buildIndentedText('f.',
            'Transaksi dengan menukarkan Point Cazhback tidak akan mendapatkan Point Cazhback lagi.'),
        _buildIndentedText('g.',
            'Minimal 100 Point Cazhback dapat dibelanjakan, jika kurang dari 100 maka akan hangus di akhir periode.'),
        _buildIndentedText('h.',
            'Anggota kartu dapat mengetahui jumlah Poin yang dikumpulkan melalui ASM.'),
        SizedBox(height: 16),
        Text('D. Penukaran/Penggunaan Poin:\n'),
        _buildIndentedText('a.',
            'Penukaran atau penggunaan Poin harus dilakukan oleh Anggota Kartu yang namanya tercantum pada Kartu.'),
        _buildIndentedText('b.',
            'Poin Cazhback tidak dapat ditukarkan dengan produk lainnya (Hadiah Stiker).'),
        _buildIndentedText('c.',
            'Untuk melakukan penukaran, Kartu harus dalam keadaan aktif dan jumlah Poin Cazhback mencukupi.'),
        _buildIndentedText('d.',
            'Point Cazhback tidak dapat ditukar dengan uang tunai dan hanya dapat digunakan sesuai ketentuan Perusahaan.'),
        _buildIndentedText('e.',
            'Nilai dan penukaran Point Cazhback sesuai ketentuan yang ditetapkan Perusahaan dan dapat berubah sewaktu-waktu.'),
        _buildIndentedText('f.',
            'Point Cazhback dan Point Sticker tidak bisa dipindahkan ataupun digabungkan.'),
        SizedBox(height: 16),
        Text('E. Perubahan Data Pribadi Anggota Kartu:\n'
            'Anggota Kartu dapat melakukan perubahan data pribadi dengan cara-cara sebagai berikut :\n'),
        _buildIndentedText('a.',
            'Anggota Kartu datang langsung ke Counter Sticker dan menyampaikan perubahan data kepada Petugas.'),
        _buildIndentedText('b.',
            'Anggota Kartu dapat mengirim perubahan data melalui fax ke nomor +62361418901 dengan melampirkan fotokopi Kartu dan KTP.'),
        _buildIndentedText('c.',
            'Ketentuan dan persyaratan ini merupakan satu kesatuan dan bagian yang tidak terpisahkan dari form permohonan Cazh Back.'),
      ],
    ),
    Text(
      '\n\nKetentuan Pengambilan Hadiah Online\n',
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
    ),
    Text(
      '1.	Hadiah yang tersedia tergantung stok dari masing – masing lokasi.\n\n'
      '2.	Pelanggan tidak bisa memilih hadiah yang tersedia pada lokasi yang berbeda.\n\n'
      '3.	Pengambilan hadiah di lokasi minimal 1 jam dan maksimal 7 hari setelah pemesanan melalui online.\n\n'
      '4.	Point Sticker dari tiap hadiah sewaktu – waktu bisa berubah tanpa pemberitahuan.\n\n'
      '5.	Jenis hadiah tergantung stok dan bisa tidak tersedia kembali.\n\n'
      '6.	Data yang diinput harus sama dengan yang terdaftar di system, jika berbeda maka pelanggan wajib melakukan update data ke lokasi dan sementara tidak dapat melakukan penukaran.\n\n',
      textAlign: TextAlign.justify,
    ),
    Text(
      'Cara Pengambilan Hadiah\n',
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
    ),
    Text(
      '1.	Pelanggan wajib login dengan menggunakan nomor kartu, nomor HP dan tanggal lahir sesuai data pada Kartu.\n\n'
      '2.	Pelanggan memilih lokasi pengambilan hadiah.\n\n'
      '3.	Pelanggan memilih hadiah yang diinginkan.\n\n'
      '4.	Jika nilai point tidak mencukupi maka system akan menolak permintaan penukaran hadiah.\n\n'
      '5.	Jika sudah selesai maka pelanggan, masuk ke keranjang belanja, dan memilih tombol “Proses Penukaran” untuk melanjutkan.\n\n'
      '6.	Setelah menekan tombol “Proses Penukaran”, maka akan tampil bukti penukaran  (catat / simpan kode penukaran sebagai bukti pengambilan).',
      textAlign: TextAlign.justify,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Others Screen'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExpandableSection(
                title: 'Support',
                isExpanded: isSupportExpanded,
                onTap: () {
                  setState(() {
                    isSupportExpanded = !isSupportExpanded;
                  });
                },
                content: supportWidget,
              ),
              // Divider(
              //   color: Colors.black,
              //   thickness: 1,
              //   height: 20,
              // ),
              isSupportExpanded ? Container() : const SizedBox(height: 16),
              _buildExpandableSection(
                title: 'Term Of Use',
                isExpanded: isTermsExpanded,
                onTap: () {
                  setState(() {
                    isTermsExpanded = !isTermsExpanded;
                  });
                },
                content: termsWidget,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk bagian yang dapat diperluas/tutup
  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required Function() onTap,
    required List<Widget> content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.purple,
              ),
            ],
          ),
        ),
        if (isExpanded)
          Container(
            padding: EdgeInsets.fromLTRB(
                10.adaptSize, 18.adaptSize, 10.adaptSize, 10.adaptSize),
            margin: EdgeInsets.all(10.adaptSize),
            child: Column(
              children: content,
            ),
          ),
      ],
    );
  }
}
