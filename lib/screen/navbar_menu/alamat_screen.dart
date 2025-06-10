import 'package:project_skripsi/screen/gabriel/core/app_export.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Model Alamat
class Alamat {
  final int? id;
  final String label;
  final String alamat;
  final String kota;
  final String provinsi;
  final String kodePos;
  final String noTelp;
  final bool isPrimary;
  String username;

  Alamat({
    this.id,
    required this.label,
    required this.alamat,
    required this.kota,
    required this.provinsi,
    required this.kodePos,
    required this.noTelp,
    required this.username,
    this.isPrimary = false,
  });

  factory Alamat.fromJson(Map<String, dynamic> json) {
    return Alamat(
      id: json['id'],
      label: json['label'] ?? '',
      alamat: json['alamat'] ?? '',
      kota: json['kota'] ?? '',
      provinsi: json['provinsi'] ?? '',
      kodePos: json['kode_pos'] ?? '',
      noTelp: json['no_telp'] ?? '',
      isPrimary: json['is_primary'] == 1 ? true : false,
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'alamat': alamat,
      'kota': kota,
      'provinsi': provinsi,
      'kode_pos': kodePos,
      'no_telp': noTelp,
      'is_primary': isPrimary,
      'username': username,
    };
  }
}

// API Service
class AlamatService {
  static String baseUrl = '${API.BASE_URL}/api/toko';

  static Future<List<Alamat>> getAlamat() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/getAlamat?username=${await LocalData.getData('user')}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) ?? [];
        return data.map((json) => Alamat.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load alamat');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<bool> createAlamat(Alamat alamat) async {
    alamat.username = await LocalData.getData('user');
    print(alamat.toJson());

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/createAlamat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(alamat.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateAlamat(Alamat alamat) async {
    alamat.username = await LocalData.getData('user');
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updateAlamat/${alamat.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(alamat.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteAlamat(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteAlamat/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// Main CRUD Alamat Screen
class AlamatScreen extends StatefulWidget {
  const AlamatScreen({Key? key}) : super(key: key);

  @override
  State<AlamatScreen> createState() => _AlamatScreenState();
}

class _AlamatScreenState extends State<AlamatScreen> {
  List<Alamat> alamatList = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAlamat();
  }

  Future<void> _loadAlamat() async {
    setState(() {
      isLoading = true;
    });

    try {
      final alamats = await AlamatService.getAlamat();
      setState(() {
        alamatList = alamats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Gagal memuat data alamat: $e');
    }
  }

  Future<void> _deleteAlamat(int id) async {
    final confirmed = await _showDeleteDialog();
    if (confirmed == true) {
      final success = await AlamatService.deleteAlamat(id);
      if (success) {
        _showSuccessSnackBar('Alamat berhasil dihapus');
        _loadAlamat();
      } else {
        _showErrorSnackBar('Gagal menghapus alamat');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<bool?> _showDeleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Konfirmasi Hapus'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin menghapus alamat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<Alamat> get filteredAlamat {
    if (searchQuery.isEmpty) return alamatList;
    return alamatList.where((alamat) {
      return alamat.label.toLowerCase().contains(searchQuery.toLowerCase()) ||
          alamat.alamat.toLowerCase().contains(searchQuery.toLowerCase()) ||
          alamat.kota.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            'Kelola Alamat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${filteredAlamat.length} alamat',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari alamat...',
                          hintStyle: const TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF4F46E5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                      ),
                    )
                  : filteredAlamat.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadAlamat,
                          color: const Color(0xFF4F46E5),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: filteredAlamat.length,
                            itemBuilder: (context, index) {
                              final alamat = filteredAlamat[index];
                              return _buildAlamatCard(alamat);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FormAlamatScreen(),
              ),
            );
            if (result == true) {
              _loadAlamat();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: const Text(
            'Tambah Alamat',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off,
              size: 60,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum Ada Alamat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan alamat pertama Anda',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlamatCard(Alamat alamat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: alamat.isPrimary
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFECFDF5),
                  Color(0xFFF0FDF4),
                ],
              )
            : null,
        color: alamat.isPrimary ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: alamat.isPrimary
                ? const Color(0xFF10B981).withOpacity(0.1)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: alamat.isPrimary
            ? Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
                width: 1.5,
              )
            : Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background pattern for primary address
            if (alamat.isPrimary)
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981).withOpacity(0.05),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    children: [
                      // Icon Container
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: alamat.isPrimary
                                ? [
                                    const Color(0xFF10B981),
                                    const Color(0xFF059669),
                                  ]
                                : [
                                    const Color(0xFF6366F1),
                                    const Color(0xFF4F46E5),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (alamat.isPrimary
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF4F46E5))
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          alamat.isPrimary
                              ? Icons.home_rounded
                              : Icons.location_on_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Label and Phone Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  alamat.label,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (alamat.isPrimary) ...[
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF10B981),
                                          Color(0xFF059669),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF10B981)
                                              .withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'Utama',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_rounded,
                                  size: 14,
                                  color: const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  alamat.noTelp,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Menu Button
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.1),
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FormAlamatScreen(alamat: alamat),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  _loadAlamat();
                                }
                              });
                            } else if (value == 'delete') {
                              _deleteAlamat(alamat.id!);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit_rounded,
                                        color: Color(0xFF4F46E5), size: 18),
                                    SizedBox(width: 12),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: const Row(
                                  children: [
                                    Icon(Icons.delete_rounded,
                                        color: Color(0xFFEF4444), size: 18),
                                    SizedBox(width: 12),
                                    Text(
                                      'Hapus',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Address Details Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: alamat.isPrimary
                          ? Colors.white.withOpacity(0.7)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: alamat.isPrimary
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Address Icon and Label
                        Row(
                          children: [
                            Icon(
                              Icons.location_city_rounded,
                              size: 16,
                              color: const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Alamat Lengkap',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Full Address
                        Text(
                          alamat.alamat,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // City, Province, Postal Code
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: alamat.isPrimary
                                ? const Color(0xFF10B981).withOpacity(0.1)
                                : const Color(0xFFE2E8F0).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.map_rounded,
                                size: 14,
                                color: alamat.isPrimary
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${alamat.kota}, ${alamat.provinsi} ${alamat.kodePos}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: alamat.isPrimary
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Form Alamat Screen (Create/Update)
class FormAlamatScreen extends StatefulWidget {
  final Alamat? alamat;

  const FormAlamatScreen({Key? key, this.alamat}) : super(key: key);

  @override
  State<FormAlamatScreen> createState() => _FormAlamatScreenState();
}

class _FormAlamatScreenState extends State<FormAlamatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kotaController = TextEditingController(text: 'Denpasar');
  final _provinsiController = TextEditingController(text: 'Bali');
  final _kodePosController = TextEditingController();
  final _noTelpController = TextEditingController();
  bool _isPrimary = false;
  bool _isLoading = false;

  bool get isEdit => widget.alamat != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _labelController.text = widget.alamat!.label;
      _alamatController.text = widget.alamat!.alamat;
      _kotaController.text = widget.alamat!.kota;
      _provinsiController.text = widget.alamat!.provinsi;
      _kodePosController.text = widget.alamat!.kodePos;
      _noTelpController.text = widget.alamat!.noTelp;
      _isPrimary = widget.alamat!.isPrimary;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _alamatController.dispose();
    _kotaController.dispose();
    _provinsiController.dispose();
    _kodePosController.dispose();
    _noTelpController.dispose();
    super.dispose();
  }

  Future<void> _saveAlamat() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final alamat = Alamat(
      id: isEdit ? widget.alamat!.id : null,
      label: _labelController.text.trim(),
      alamat: _alamatController.text.trim(),
      kota: _kotaController.text.trim(),
      provinsi: _provinsiController.text.trim(),
      kodePos: _kodePosController.text.trim(),
      noTelp: _noTelpController.text.trim(),
      username: await LocalData.getData('user'),
      isPrimary: _isPrimary,
    );

    bool success;
    if (isEdit) {
      success = await AlamatService.updateAlamat(alamat);
    } else {
      success = await AlamatService.createAlamat(alamat);
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Alamat berhasil diupdate' : 'Alamat berhasil ditambahkan',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Gagal mengupdate alamat' : 'Gagal menambahkan alamat',
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Alamat' : 'Tambah Alamat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // label Label
                      _buildFormField(
                        label: 'Label Alamat',
                        controller: _labelController,
                        hint: 'Rumah, Kantor, dll.',
                        icon: Icons.label_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'label label alamat harus diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Alamat Lengkap
                      _buildFormField(
                        label: 'Alamat Lengkap',
                        controller: _alamatController,
                        hint: 'Jl. Contoh No. 123, RT/RW 01/02',
                        icon: Icons.location_on_outlined,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alamat lengkap harus diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Kota dan Provinsi Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormField(
                              label: 'Kota',
                              controller: _kotaController,
                              hint: 'Jakarta',
                              icon: Icons.location_city_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Kota harus diisi';
                                }
                                return null;
                              },
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildFormField(
                              label: 'Provinsi',
                              controller: _provinsiController,
                              hint: 'DKI Jakarta',
                              icon: Icons.map_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Provinsi harus diisi';
                                }
                                return null;
                              },
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Kode Pos dan No Telp Row
                      _buildFormField(
                        label: 'Kode Pos',
                        controller: _kodePosController,
                        hint: '12345',
                        icon: Icons.local_post_office_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kode pos harus diisi';
                          }
                          if (value.length != 5) {
                            return 'Kode pos harus 5 digit';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildFormField(
                        label: 'No. Telepon',
                        controller: _noTelpController,
                        hint: '081234567890',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'No. telepon harus diisi';
                          }
                          if (value.length < 10) {
                            return 'No. telepon minimal 10 digit';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      // Primary Address Toggle
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.home,
                                color: Color(0xFF10B981),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jadikan Alamat Utama',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Alamat utama akan digunakan sebagai default',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isPrimary,
                              onChanged: (value) {
                                setState(() {
                                  _isPrimary = value;
                                });
                              },
                              activeColor: const Color(0xFF10B981),
                              activeTrackColor:
                                  const Color(0xFF10B981).withOpacity(0.3),
                              inactiveThumbColor: const Color(0xFF94A3B8),
                              inactiveTrackColor: const Color(0xFFE2E8F0),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Action Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _isLoading ? null : _saveAlamat,
                child: Container(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEdit ? Icons.save : Icons.add_location,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEdit ? 'Simpan Perubahan' : 'Tambah Alamat',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false, // Tambahkan ini
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly, // Terapkan di sini
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF4F46E5),
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF4F46E5),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
