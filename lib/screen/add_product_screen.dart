import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_services.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isLoading = false;

  static const cyanPrimary = Color(0xFF00BCD4);
  static const cyanDark = Color(0xFF006064);
  static const cyanLight = Color(0xFFE0F7FA);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ApiService.addProduct(
        name: _nameCtrl.text.trim(),
        price: int.parse(_priceCtrl.text.trim().replaceAll('.', '')),
        description: _descCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDec(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: cyanPrimary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: cyanPrimary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFB2EBF2)),
      ),
      filled: true,
      fillColor: cyanLight,
      labelStyle: const TextStyle(color: cyanDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAFB),
      appBar: AppBar(
        backgroundColor: cyanPrimary,
        foregroundColor: Colors.white,
        title: const Text('Tambah Produk',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cyanLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF80DEEA)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: cyanPrimary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Data yang sudah disimpan tidak dapat diedit. Pastikan data sudah benar.',
                        style: TextStyle(fontSize: 13, color: cyanDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nama Produk
              const Text('Nama Produk',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cyanDark,
                      fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: _inputDec(
                    'Nama Produk', 'Masukkan nama produk', Icons.label_outline),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 18),

              // Harga
              const Text('Harga (Rp)',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cyanDark,
                      fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDec(
                    'Harga', 'Contoh: 15000', Icons.price_change_outlined),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                  final price = int.tryParse(v.trim());
                  if (price == null || price <= 0) return 'Harga tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Deskripsi
              const Text('Deskripsi',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cyanDark,
                      fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tulis deskripsi produk...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: cyanPrimary, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFB2EBF2)),
                  ),
                  filled: true,
                  fillColor: cyanLight,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Deskripsi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cyanPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined),
                  label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Produk',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
