import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/etkinlik.dart';
import '../models/dava.dart';
import '../providers/app_provider.dart';

class EtkinlikFormScreen extends StatefulWidget {
  final Etkinlik? etkinlik;

  const EtkinlikFormScreen({super.key, this.etkinlik});

  @override
  State<EtkinlikFormScreen> createState() => _EtkinlikFormScreenState();
}

class _EtkinlikFormScreenState extends State<EtkinlikFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _konumController = TextEditingController();
  final _katilimcilarController = TextEditingController();
  final _notlarController = TextEditingController();

  EtkinlikTuru _selectedTur = EtkinlikTuru.durusma;
  DateTime _baslangicTarihi = DateTime.now();
  DateTime? _bitisTarihi;
  DateTime? _hatirlaticiTarihi;
  bool _hatirlaticiVar = false;
  Dava? _selectedDava;

  @override
  void initState() {
    super.initState();
    if (widget.etkinlik != null) {
      _baslikController.text = widget.etkinlik!.baslik;
      _aciklamaController.text = widget.etkinlik!.aciklama ?? '';
      _konumController.text = widget.etkinlik!.konum ?? '';
      _katilimcilarController.text = widget.etkinlik!.katilimcilar ?? '';
      _notlarController.text = widget.etkinlik!.notlar ?? '';
      _selectedTur = widget.etkinlik!.tur;
      _baslangicTarihi = widget.etkinlik!.baslangicTarihi;
      _bitisTarihi = widget.etkinlik!.bitisTarihi;
      _hatirlaticiVar = widget.etkinlik!.hatirlaticiVar;
      _hatirlaticiTarihi = widget.etkinlik!.hatirlaticiTarihi;
      _selectedDava = widget.etkinlik!.dava;
    }
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _aciklamaController.dispose();
    _konumController.dispose();
    _katilimcilarController.dispose();
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
            child: Text(
              widget.etkinlik == null ? 'Yeni Etkinlik' : 'Etkinlik Düzenle',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
              _buildSectionTitle('Temel Bilgiler'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _baslikController,
                label: 'Etkinlik Başlığı',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Etkinlik başlığı gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Etkinlik Türü',
                icon: Icons.category,
                value: _selectedTur,
                items: EtkinlikTuru.values,
                onChanged: (value) => setState(() => _selectedTur = value!),
                itemBuilder: (tur) => Text(_getTurText(tur)),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _aciklamaController,
                label: 'Açıklama',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Tarih ve Saat'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Başlangıç Tarihi',
                      icon: Icons.calendar_today,
                      value: _baslangicTarihi,
                      onChanged: (date) => setState(() => _baslangicTarihi = date!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      label: 'Bitiş Tarihi (Opsiyonel)',
                      icon: Icons.event_available,
                      value: _bitisTarihi,
                      onChanged: (date) => setState(() => _bitisTarihi = date),
                      isOptional: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Detay Bilgiler'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _konumController,
                label: 'Konum',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _katilimcilarController,
                label: 'Katılımcılar',
                icon: Icons.people,
                hintText: 'Virgülle ayırarak katılımcıları yazın',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _notlarController,
                label: 'Notlar',
                icon: Icons.note,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Hatırlatıcı'),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text(
                  'Hatırlatıcı Ayarla',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Etkinlik için hatırlatıcı bildirimi',
                  style: TextStyle(color: Colors.white70),
                ),
                value: _hatirlaticiVar,
                onChanged: (value) => setState(() => _hatirlaticiVar = value),
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white.withOpacity(0.3),
                inactiveTrackColor: Colors.white.withOpacity(0.1),
              ),
              if (_hatirlaticiVar) ...[
                const SizedBox(height: 16),
                _buildDateField(
                  label: 'Hatırlatıcı Tarihi',
                  icon: Icons.notifications,
                  value: _hatirlaticiTarihi ?? DateTime.now().add(const Duration(hours: 1)),
                  onChanged: (date) => setState(() => _hatirlaticiTarihi = date),
                ),
              ],
              const SizedBox(height: 24),
              _buildSectionTitle('İlgili Dava'),
              const SizedBox(height: 16),
              _buildDavaDropdown(),
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      style: const TextStyle(color: Colors.white), // Beyaz yazı
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white), // Beyaz label
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white), // Beyaz icon
        filled: true,
        fillColor: Colors.white.withOpacity(0.1), // Hafif şeffaf arka plan
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 1), // Beyaz çerçeve
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 1), // Beyaz çerçeve
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 2), // Beyaz odaklanma
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required Widget Function(T) itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF0F172A), // Koyu lacivert dropdown arka plan
      isExpanded: true, // Dropdown'ı genişlet
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
      items: items.map((item) => DropdownMenuItem<T>(
        value: item,
        child: Container(
          width: double.infinity,
          child: itemBuilder(item),
        ),
      )).toList(),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    bool isOptional = false,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value != null 
                        ? '${value.day}/${value.month}/${value.year}'
                        : isOptional ? 'Seçiniz (Opsiyonel)' : 'Tarih Seçiniz',
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? Colors.white : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildDavaDropdown() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return DropdownButtonFormField<Dava?>(
          value: _selectedDava,
          onChanged: (dava) => setState(() => _selectedDava = dava),
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color(0xFF0F172A),
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'İlgili Dava (Opsiyonel)',
            labelStyle: const TextStyle(color: Colors.white),
            prefixIcon: const Icon(Icons.gavel, color: Colors.white),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
          items: [
            const DropdownMenuItem<Dava?>(
              value: null,
              child: Text('Dava Seçiniz', style: TextStyle(color: Colors.white)),
            ),
            ...provider.davalar.map((dava) => DropdownMenuItem<Dava?>(
              value: dava,
              child: Text(
                dava.baslik,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveEtkinlik,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white, width: 1),
          ),
        ),
        child: Text(
          widget.etkinlik == null ? 'Etkinlik Ekle' : 'Etkinlik Güncelle',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _saveEtkinlik() {
    if (_formKey.currentState!.validate()) {
      final etkinlik = Etkinlik(
        id: widget.etkinlik?.id,
        baslik: _baslikController.text.trim(),
        aciklama: _aciklamaController.text.trim().isEmpty ? null : _aciklamaController.text.trim(),
        tur: _selectedTur,
        baslangicTarihi: _baslangicTarihi,
        bitisTarihi: _bitisTarihi,
        davaId: _selectedDava?.id,
        konum: _konumController.text.trim().isEmpty ? null : _konumController.text.trim(),
        katilimcilar: _katilimcilarController.text.trim().isEmpty ? null : _katilimcilarController.text.trim(),
        hatirlaticiVar: _hatirlaticiVar,
        hatirlaticiTarihi: _hatirlaticiVar ? _hatirlaticiTarihi : null,
        notlar: _notlarController.text.trim().isEmpty ? null : _notlarController.text.trim(),
        createdAt: widget.etkinlik?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.etkinlik == null) {
        context.read<AppProvider>().addEtkinlik(etkinlik);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${etkinlik.baslik} etkinliği eklendi'),
            backgroundColor: Colors.white,
          ),
        );
      } else {
        context.read<AppProvider>().updateEtkinlik(etkinlik);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${etkinlik.baslik} etkinliği güncellendi'),
            backgroundColor: Colors.white,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  String _getTurText(EtkinlikTuru tur) {
    switch (tur) {
      case EtkinlikTuru.durusma:
        return 'Duruşma';
      case EtkinlikTuru.toplanti:
        return 'Toplantı';
      case EtkinlikTuru.telefonGorusmesi:
        return 'Telefon Görüşmesi';
      case EtkinlikTuru.email:
        return 'E-posta';
      case EtkinlikTuru.dosyaHazirlama:
        return 'Dosya Hazırlama';
      case EtkinlikTuru.arastirma:
        return 'Araştırma';
      case EtkinlikTuru.diger:
        return 'Diğer';
    }
  }
}
