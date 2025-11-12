import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/dava.dart';
import '../models/muvekkil.dart';
import '../providers/app_provider.dart';

class DavaFormScreen extends StatefulWidget {
  final Dava? dava;

  const DavaFormScreen({super.key, this.dava});

  @override
  State<DavaFormScreen> createState() => _DavaFormScreenState();
}

class _DavaFormScreenState extends State<DavaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _davaNoController = TextEditingController();
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _mahkemeController = TextEditingController();
  final _hakimController = TextEditingController();
  final _karsiTarafController = TextEditingController();
  final _karsiTarafAvukatController = TextEditingController();
  final _ucretController = TextEditingController();
  final _notlarController = TextEditingController();

  DavaTuru _selectedDavaTuru = DavaTuru.medeniHukuk;
  DavaDurumu _selectedDavaDurumu = DavaDurumu.yeni;
  Muvekkil? _selectedMuvekkil;
  DateTime? _davaTarihi;
  DateTime? _durusmaTarihi;
  final _tcController = TextEditingController();

  // Türkiye'deki gerçek dava başlıkları
  final List<String> _ornekBasliklar = [
    'İşçi Alacakları Davası',
    'Kira Sözleşmesi İhlali Davası',
    'Boşanma Davası',
    'Velayet Davası',
    'Nafaka Davası',
    'Tazminat Davası',
    'Sözleşmeden Dönme Davası',
    'Sözleşme İhlali Davası',
    'Gayrimenkul Satış Sözleşmesi Davası',
    'Miras Paylaşım Davası',
    'Mirasın Reddi Davası',
    'Vasiyetname İptal Davası',
    'Şirket Ortaklığı Davası',
    'Şirket Kuruluş Davası',
    'Şirket Tasfiye Davası',
    'Ticari Sözleşme İhlali Davası',
    'Çek Keşideciye Rücu Davası',
    'Senet Alacak Davası',
    'Kira Bedeli Tahsil Davası',
    'Kira Sözleşmesi Fesih Davası',
    'Emlak Satış Sözleşmesi Davası',
    'Emlak Kiralaması Davası',
    'Kat Mülkiyeti Davası',
    'İmar Hukuku Davası',
    'Telif Hakkı İhlali Davası',
    'Marka İhlali Davası',
    'Patent İhlali Davası',
    'Vergi İhtilafı Davası',
    'Vergi Tarhiyat İptal Davası',
    'İdari İşlem İptal Davası',
    'Kamu Görevlisi Disiplin Davası',
    'Ceza Davası',
    'Hırsızlık Suç Davası',
    'Dolandırıcılık Suç Davası',
    'Yaralama Suç Davası',
    'Tehdit Suç Davası',
    'Hakaret Suç Davası',
    'Sosyal Güvenlik Prim Tahsil Davası',
    'İş Kazası Tazminat Davası',
    'Mobbing Tazminat Davası',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.dava != null) {
      _initializeForm();
    } else {
      _davaNoController.text = _generateDavaNo();
    }
  }

  void _initializeForm() {
    final dava = widget.dava!;
    _davaNoController.text = dava.davaNo;
    _baslikController.text = dava.baslik;
    _aciklamaController.text = dava.aciklama ?? '';
    _mahkemeController.text = dava.mahkeme ?? '';
    _hakimController.text = dava.hakim ?? '';
    _karsiTarafController.text = dava.karsiTaraf ?? '';
    _karsiTarafAvukatController.text = dava.karsiTarafAvukat ?? '';
    _ucretController.text = dava.ucret?.toString() ?? '';
    _notlarController.text = dava.notlar ?? '';
    _selectedDavaTuru = dava.tur;
    _selectedDavaDurumu = dava.durum;
    _selectedMuvekkil = dava.muvekkil;
    _davaTarihi = dava.davaTarihi;
    _durusmaTarihi = dava.durusmaTarihi;
  }

  String _generateDavaNo() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return '$year/$month/$day-$random';
  }

  @override
  void dispose() {
    _davaNoController.dispose();
    _baslikController.dispose();
    _aciklamaController.dispose();
    _mahkemeController.dispose();
    _hakimController.dispose();
    _karsiTarafController.dispose();
    _karsiTarafAvukatController.dispose();
    _ucretController.dispose();
    _notlarController.dispose();
    _tcController.dispose();
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
                child: Container(
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
              _buildSection(
                'Temel Bilgiler',
                [
                  _buildTextField(
                    controller: _davaNoController,
                    label: 'Dava No',
                    enabled: false,
                    icon: Icons.receipt_long,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _baslikController,
                    label: 'Dava Başlığı',
                    icon: Icons.title,
                    validator: (value) => value?.isEmpty == true ? 'Dava başlığı gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildOrnekBasliklar(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _aciklamaController,
                    label: 'Açıklama',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Dava Bilgileri',
                [
                  _buildDropdownField(
                    label: 'Dava Türü',
                    icon: Icons.category,
                    value: _selectedDavaTuru,
                    items: DavaTuru.values,
                    onChanged: (value) => setState(() => _selectedDavaTuru = value!),
                    itemBuilder: (item) => Dava.davaTuruToString(item),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Dava Durumu',
                    icon: Icons.timeline,
                    value: _selectedDavaDurumu,
                    items: DavaDurumu.values,
                    onChanged: (value) => setState(() => _selectedDavaDurumu = value!),
                    itemBuilder: (item) => Dava.davaDurumuToString(item),
                  ),
                  const SizedBox(height: 16),
                  _buildMuvekkilArama(),
                  const SizedBox(height: 16),
                  _buildDateField(
                    label: 'Dava Tarihi',
                    icon: Icons.calendar_today,
                    value: _davaTarihi,
                    onChanged: (date) => setState(() => _davaTarihi = date),
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    label: 'Duruşma Tarihi',
                    icon: Icons.event,
                    value: _durusmaTarihi,
                    onChanged: (date) => setState(() => _durusmaTarihi = date),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Mahkeme Bilgileri',
                [
                  _buildTextField(
                    controller: _mahkemeController,
                    label: 'Mahkeme',
                    icon: Icons.gavel,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _hakimController,
                    label: 'Hakim',
                    icon: Icons.person,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Karşı Taraf Bilgileri',
                [
                  _buildTextField(
                    controller: _karsiTarafController,
                    label: 'Karşı Taraf',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _karsiTarafAvukatController,
                    label: 'Karşı Taraf Avukatı',
                    icon: Icons.people,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Mali Bilgiler',
                [
                  _buildTextField(
                    controller: _ucretController,
                    label: 'Ücret (TL)',
                    icon: Icons.monetization_on,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Notlar',
                [
                  _buildTextField(
                    controller: _notlarController,
                    label: 'Notlar',
                    icon: Icons.note,
                    maxLines: 4,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                ),
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
              widget.dava == null ? 'Yeni Dava Ekle' : 'Dava Düzenle',
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

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Koyu lacivert kart arka planı
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Beyaz başlık
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
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
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      dropdownColor: Color(0xFF1E293B), // Koyu mavi dropdown arka planı
      style: const TextStyle(color: Colors.white), // Beyaz yazı
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white), // Beyaz label
        prefixIcon: Icon(icon, color: Colors.white), // Beyaz icon
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
        filled: true,
        fillColor: Colors.white.withOpacity(0.1), // Hafif şeffaf arka plan
      ),
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemBuilder(item),
            style: const TextStyle(color: Colors.white), // Beyaz yazı
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMuvekkilArama() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _tcController,
                    label: 'TC Kimlik No ile Ara',
                    icon: Icons.search,
                    keyboardType: TextInputType.number,
                    validator: (value) => _selectedMuvekkil == null ? 'Müvekkil seçin' : null,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _aramaMuvekkil(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
            if (_selectedMuvekkil != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Text(
                        '${_selectedMuvekkil!.ad[0]}${_selectedMuvekkil!.soyad[0]}',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedMuvekkil!.ad} ${_selectedMuvekkil!.soyad}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'TC: ${_selectedMuvekkil!.tc ?? 'Belirtilmemiş'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Tel: ${_selectedMuvekkil!.telefon ?? 'Belirtilmemiş'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _selectedMuvekkil = null),
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Veya',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: _buildMuvekkilDropdown(provider),
            ),
          ],
        );
      },
    );
  }

  void _aramaMuvekkil(AppProvider provider) {
    final tc = _tcController.text.trim();
    if (tc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen TC kimlik numarası girin')),
      );
      return;
    }

    final muvekkil = provider.muvekkiller.firstWhere(
      (m) => m.tc == tc,
      orElse: () => Muvekkil(
        ad: '',
        soyad: '',
        tc: null,
        telefon: null,
        email: null,
        adres: null,
        createdAt: DateTime.now(),
      ),
    );

    if (muvekkil.ad.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu TC kimlik numarasına sahip müvekkil bulunamadı')),
      );
    } else {
      setState(() => _selectedMuvekkil = muvekkil);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Müvekkil bulundu: ${muvekkil.ad} ${muvekkil.soyad}')),
      );
    }
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.white,
                  onPrimary: Color(0xFF0F172A),
                  surface: Color(0xFF0F172A),
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value != null ? DateFormat('dd.MM.yyyy').format(value) : label,
                style: TextStyle(
                  color: value != null ? Colors.white : Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnekBasliklar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Örnek Dava Başlıkları:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ornekBasliklar.take(6).map((baslik) {
              return InkWell(
                onTap: () => _baslikController.text = baslik,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    baslik,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _showTumBasliklar(),
            child: const Text('Tümünü Gör', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTumBasliklar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Örnek Dava Başlıkları',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _ornekBasliklar.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: ListTile(
                  title: Text(
                    _ornekBasliklar[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    _baslikController.text = _ornekBasliklar[index];
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Kapat',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveDava,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Dava Kaydet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _saveDava() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMuvekkil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir müvekkil seçin')),
      );
      return;
    }

    final dava = Dava(
      id: widget.dava?.id,
      davaNo: _davaNoController.text,
      baslik: _baslikController.text,
      aciklama: _aciklamaController.text.isEmpty ? null : _aciklamaController.text,
      durum: _selectedDavaDurumu,
      tur: _selectedDavaTuru,
      muvekkilId: _selectedMuvekkil!.id!,
      davaTarihi: _davaTarihi,
      durusmaTarihi: _durusmaTarihi,
      mahkeme: _mahkemeController.text.isEmpty ? null : _mahkemeController.text,
      hakim: _hakimController.text.isEmpty ? null : _hakimController.text,
      karsiTaraf: _karsiTarafController.text.isEmpty ? null : _karsiTarafController.text,
      karsiTarafAvukat: _karsiTarafAvukatController.text.isEmpty ? null : _karsiTarafAvukatController.text,
      ucret: _ucretController.text.isEmpty ? null : double.tryParse(_ucretController.text),
      notlar: _notlarController.text.isEmpty ? null : _notlarController.text,
      createdAt: widget.dava?.createdAt ?? DateTime.now(),
      muvekkil: _selectedMuvekkil,
    );

    try {
      if (widget.dava == null) {
        await context.read<AppProvider>().addDava(dava);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dava başarıyla eklendi')),
        );
      } else {
        await context.read<AppProvider>().updateDava(dava);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dava başarıyla güncellendi')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  // Müvekkil dropdown'ını güvenli şekilde oluştur
  Widget _buildMuvekkilDropdown(AppProvider provider) {
    // ID'ye göre benzersiz müvekkilleri filtrele
    final uniqueMuvekkiller = <int, Muvekkil>{};
    for (final muvekkil in provider.muvekkiller) {
      if (muvekkil.id != null) {
        uniqueMuvekkiller[muvekkil.id!] = muvekkil;
      }
    }

    // Seçili müvekkilin dropdown items içinde olup olmadığını kontrol et
    Muvekkil? validSelectedMuvekkil;
    if (_selectedMuvekkil != null && _selectedMuvekkil!.id != null) {
      validSelectedMuvekkil = uniqueMuvekkiller[_selectedMuvekkil!.id];
    }

    final items = <DropdownMenuItem<Muvekkil?>>[
      const DropdownMenuItem<Muvekkil?>(
        value: null,
        child: Text(
          'Müvekkil Seçin',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ];

    // Dropdown items oluştur
    for (final muvekkil in uniqueMuvekkiller.values) {
      items.add(
        DropdownMenuItem<Muvekkil?>(
          key: ValueKey('muvekkil_${muvekkil.id}'),
          value: muvekkil,
          child: Text(
            '${muvekkil.ad} ${muvekkil.soyad}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return DropdownButtonFormField<Muvekkil?>(
      value: validSelectedMuvekkil, // Sadece dropdown items içinde olan değeri kullan
      isExpanded: true,
      onChanged: (value) => setState(() => _selectedMuvekkil = value),
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF0F172A),
      decoration: InputDecoration(
        labelText: 'Müvekkil Seç',
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: const Icon(Icons.person, color: Colors.white),
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
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      items: items,
    );
  }

  // Benzersiz müvekkil listesi oluştur (eski metod - artık kullanılmıyor)
  List<Muvekkil> _getUniqueMuvekkiller(List<Muvekkil> muvekkiller) {
    final seenIds = <int>{};
    return muvekkiller.where((muvekkil) {
      if (muvekkil.id != null && !seenIds.contains(muvekkil.id)) {
        seenIds.add(muvekkil.id!);
        return true;
      }
      return false;
    }).toList();
  }
}

