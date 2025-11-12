import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/muvekkil.dart';

class MuvekkilFormScreen extends StatefulWidget {
  final Muvekkil? muvekkil;

  const MuvekkilFormScreen({super.key, this.muvekkil});

  @override
  State<MuvekkilFormScreen> createState() => _MuvekkilFormScreenState();
}

class _MuvekkilFormScreenState extends State<MuvekkilFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonController = TextEditingController();
  final _adresController = TextEditingController();
  final _tcKimlikController = TextEditingController();
  final _notlarController = TextEditingController();

  bool get isEditing => widget.muvekkil != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _fillForm();
    }
  }

  void _fillForm() {
    final muvekkil = widget.muvekkil!;
    _adController.text = muvekkil.ad;
    _soyadController.text = muvekkil.soyad;
    _emailController.text = muvekkil.email ?? '';
    _telefonController.text = muvekkil.telefon ?? '';
    _adresController.text = muvekkil.adres ?? '';
    _tcKimlikController.text = muvekkil.tc ?? '';
    _notlarController.text = muvekkil.notlar ?? '';
  }

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    _adresController.dispose();
    _tcKimlikController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Koyu Lacivert
              Color(0xFF1E293B), // Koyu Mavi
              Color(0xFF334155), // Orta Koyu
              Color(0xFF0F172A), // Koyu Lacivert Background
            ],
            stops: [0.0, 0.3, 0.6, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Müvekkil Düzenle' : 'Yeni Müvekkil',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditing ? 'Müvekkil bilgilerini güncelleyin' : 'Yeni müvekkil ekleyin',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Koyu lacivert arka plan
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Kişisel Bilgiler'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _adController,
                      label: 'Ad',
                      hint: 'Müvekkilin adı',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ad gereklidir';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _soyadController,
                      label: 'Soyad',
                      hint: 'Müvekkilin soyadı',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Soyad gereklidir';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'E-posta',
                hint: 'ornek@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _telefonController,
                label: 'Telefon',
                hint: '+90 555 123 45 67',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _tcKimlikController,
                label: 'TC Kimlik No',
                hint: '12345678901',
                keyboardType: TextInputType.number,
                maxLength: 11,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length != 11) {
                      return 'TC Kimlik No 11 haneli olmalıdır';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'TC Kimlik No sadece rakam içermelidir';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Adres Bilgileri'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _adresController,
                label: 'Adres',
                hint: 'Müvekkilin adresi',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Notlar'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _notlarController,
                label: 'Notlar',
                hint: 'Müvekkil hakkında notlar...',
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.white, // Beyaz başlık
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.white, // Beyaz label
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          style: const TextStyle(color: Colors.white), // Beyaz yazı
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)), // Beyaz hint
            filled: true,
            fillColor: Colors.white.withOpacity(0.1), // Hafif şeffaf arka plan
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 1), // Beyaz çerçeve
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 1), // Beyaz çerçeve
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 2), // Beyaz odaklanma
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : _saveMuvekkil,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: provider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isEditing ? 'Güncelle' : 'Kaydet',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _saveMuvekkil() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final muvekkil = Muvekkil(
      id: widget.muvekkil?.id,
      ad: _adController.text.trim(),
      soyad: _soyadController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      telefon: _telefonController.text.trim().isEmpty ? null : _telefonController.text.trim(),
      adres: _adresController.text.trim().isEmpty ? null : _adresController.text.trim(),
      tc: _tcKimlikController.text.trim().isEmpty ? null : _tcKimlikController.text.trim(),
      notlar: _notlarController.text.trim().isEmpty ? null : _notlarController.text.trim(),
      createdAt: widget.muvekkil?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<AppProvider>();
    
    if (isEditing) {
      provider.updateMuvekkil(muvekkil);
    } else {
      provider.addMuvekkil(muvekkil);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Müvekkil güncellendi' : 'Müvekkil eklendi'),
        backgroundColor: Colors.white,
      ),
    );

    Navigator.pop(context);
  }
}
