import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gorev.dart';
import '../models/dava.dart';
import '../providers/app_provider.dart';

class GorevFormScreen extends StatefulWidget {
  final Gorev? gorev;

  const GorevFormScreen({super.key, this.gorev});

  @override
  State<GorevFormScreen> createState() => _GorevFormScreenState();
}

class _GorevFormScreenState extends State<GorevFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _notlarController = TextEditingController();

  GorevDurumu _selectedDurum = GorevDurumu.bekleyen;
  GorevOnceligi _selectedOncelik = GorevOnceligi.normal;
  DateTime? _baslangicTarihi;
  DateTime? _bitisTarihi;
  DateTime? _hatirlaticiTarihi;
  bool _hatirlaticiVar = false;
  Dava? _selectedDava;

  @override
  void initState() {
    super.initState();
    if (widget.gorev != null) {
      _baslikController.text = widget.gorev!.baslik;
      _aciklamaController.text = widget.gorev!.aciklama ?? '';
      _notlarController.text = widget.gorev!.notlar ?? '';
      _selectedDurum = widget.gorev!.durum;
      _selectedOncelik = widget.gorev!.oncelik;
      _baslangicTarihi = widget.gorev!.baslangicTarihi;
      _bitisTarihi = widget.gorev!.bitisTarihi;
      _hatirlaticiVar = widget.gorev!.hatirlaticiVar;
      _hatirlaticiTarihi = widget.gorev!.hatirlaticiTarihi;
      _selectedDava = widget.gorev!.dava;
    }
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _aciklamaController.dispose();
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
              widget.gorev == null ? 'Yeni Görev' : 'Görev Düzenle',
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
                label: 'Görev Başlığı',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Görev başlığı gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _aciklamaController,
                label: 'Açıklama',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Durum ve Öncelik'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Durum',
                      icon: Icons.flag,
                      value: _selectedDurum,
                      items: GorevDurumu.values,
                      onChanged: (value) => setState(() => _selectedDurum = value!),
                      itemBuilder: (durum) => Text(_getDurumText(durum)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Öncelik',
                      icon: Icons.priority_high,
                      value: _selectedOncelik,
                      items: GorevOnceligi.values,
                      onChanged: (value) => setState(() => _selectedOncelik = value!),
                      itemBuilder: (oncelik) => Text(_getOncelikText(oncelik)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Tarih ve Saat'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Başlangıç Tarihi (Opsiyonel)',
                      icon: Icons.play_arrow,
                      value: _baslangicTarihi,
                      onChanged: (date) => setState(() => _baslangicTarihi = date),
                      isOptional: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      label: 'Bitiş Tarihi (Opsiyonel)',
                      icon: Icons.stop,
                      value: _bitisTarihi,
                      onChanged: (date) => setState(() => _bitisTarihi = date),
                      isOptional: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('İlgili Dava'),
              const SizedBox(height: 16),
              _buildDavaDropdown(),
              const SizedBox(height: 24),
              _buildSectionTitle('Notlar'),
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
                  'Görev için hatırlatıcı bildirimi',
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
        onPressed: _saveGorev,
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
          widget.gorev == null ? 'Görev Ekle' : 'Görev Güncelle',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _saveGorev() {
    if (_formKey.currentState!.validate()) {
      final gorev = Gorev(
        id: widget.gorev?.id,
        baslik: _baslikController.text.trim(),
        aciklama: _aciklamaController.text.trim().isEmpty ? null : _aciklamaController.text.trim(),
        durum: _selectedDurum,
        oncelik: _selectedOncelik,
        davaId: _selectedDava?.id,
        baslangicTarihi: _baslangicTarihi,
        bitisTarihi: _bitisTarihi,
        tamamlanmaTarihi: _selectedDurum == GorevDurumu.tamamlandi ? DateTime.now() : null,
        hatirlaticiVar: _hatirlaticiVar,
        hatirlaticiTarihi: _hatirlaticiVar ? _hatirlaticiTarihi : null,
        notlar: _notlarController.text.trim().isEmpty ? null : _notlarController.text.trim(),
        createdAt: widget.gorev?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.gorev == null) {
        context.read<AppProvider>().addGorev(gorev);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${gorev.baslik} görevi eklendi'),
            backgroundColor: Colors.white,
          ),
        );
      } else {
        context.read<AppProvider>().updateGorev(gorev);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${gorev.baslik} görevi güncellendi'),
            backgroundColor: Colors.white,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  String _getDurumText(GorevDurumu durum) {
    switch (durum) {
      case GorevDurumu.bekleyen:
        return 'Bekleyen';
      case GorevDurumu.devamEden:
        return 'Devam Eden';
      case GorevDurumu.tamamlandi:
        return 'Tamamlandı';
      case GorevDurumu.iptal:
        return 'İptal';
    }
  }

  String _getOncelikText(GorevOnceligi oncelik) {
    switch (oncelik) {
      case GorevOnceligi.dusuk:
        return 'Düşük';
      case GorevOnceligi.normal:
        return 'Normal';
      case GorevOnceligi.yuksek:
        return 'Yüksek';
      case GorevOnceligi.acil:
        return 'Acil';
    }
  }
}
