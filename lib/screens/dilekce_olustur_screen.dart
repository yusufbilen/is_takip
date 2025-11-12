import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class DilekceOlusturScreen extends StatefulWidget {
  const DilekceOlusturScreen({super.key});

  @override
  State<DilekceOlusturScreen> createState() => _DilekceOlusturScreenState();
}

class _DilekceOlusturScreenState extends State<DilekceOlusturScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mahkemeController = TextEditingController();
  final _davaliController = TextEditingController();
  final _davaciController = TextEditingController();
  final _konuController = TextEditingController();
  final _icerikController = TextEditingController();
  
  String _selectedDilekceTuru = 'Genel Dilekçe';
  String _selectedMahkemeTuru = 'Hukuk Mahkemesi';
  
  final List<String> _dilekceTurleri = [
    'Genel Dilekçe',
    'İstek Dilekçesi',
    'İtiraz Dilekçesi',
    'Temyiz Dilekçesi',
    'İstinaf Dilekçesi',
    'İptal Dilekçesi',
    'İcra Takip Dilekçesi',
  ];
  
  final List<String> _mahkemeTurleri = [
    'Hukuk Mahkemesi',
    'Ceza Mahkemesi',
    'İdare Mahkemesi',
    'Vergi Mahkemesi',
    'İş Mahkemesi',
    'Tüketici Mahkemesi',
  ];

  @override
  void dispose() {
    _mahkemeController.dispose();
    _davaliController.dispose();
    _davaciController.dispose();
    _konuController.dispose();
    _icerikController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _olusturDilekce() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // AI ile dilekçe yaz
        final result = await ApiService.aiDilekceYaz(
          dilekceTuru: _selectedDilekceTuru,
          mahkeme: '${_selectedMahkemeTuru}\n${_mahkemeController.text}',
          davaci: _davaciController.text,
          davali: _davaliController.text,
          konu: _konuController.text,
          ekBilgiler: _icerikController.text,
        );

        if (result['success'] == true) {
          final dilekce = result['dilekce_metni'] ?? _buildDilekce();
          
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            
            // Sonuç ekranına git
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DilekceSonucScreen(dilekce: dilekce),
              ),
            );
          }
        } else {
          throw Exception('Dilekçe oluşturulamadı');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Hata durumunda manuel dilekçe oluştur
          final dilekce = _buildDilekce();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DilekceSonucScreen(dilekce: dilekce),
            ),
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AI ile oluşturulamadı, manuel dilekçe hazırlandı: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  String _buildDilekce() {
    final tarih = DateFormat('dd.MM.yyyy').format(DateTime.now());
    
    return '''
${_selectedDilekceTuru.toUpperCase()}

${_selectedMahkemeTuru}
${_mahkemeController.text}

DAVALI: ${_davaliController.text}
DAVACI: ${_davaciController.text}

KONU: ${_konuController.text}

${'=' * 50}

${_icerikController.text}

${'=' * 50}

Tarih: $tarih

Saygılarımla,
Avukat
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Dilekçe Oluştur',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dilekçe Türü
                DropdownButtonFormField<String>(
                  value: _selectedDilekceTuru,
                  decoration: InputDecoration(
                    labelText: 'Dilekçe Türü',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  items: _dilekceTurleri.map((String tur) {
                    return DropdownMenuItem<String>(
                      value: tur,
                      child: Text(tur, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedDilekceTuru = newValue;
                      });
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Mahkeme Türü
                DropdownButtonFormField<String>(
                  value: _selectedMahkemeTuru,
                  decoration: InputDecoration(
                    labelText: 'Mahkeme Türü',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  items: _mahkemeTurleri.map((String tur) {
                    return DropdownMenuItem<String>(
                      value: tur,
                      child: Text(tur, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMahkemeTuru = newValue;
                      });
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Mahkeme Adı
                TextFormField(
                  controller: _mahkemeController,
                  decoration: InputDecoration(
                    labelText: 'Mahkeme Adı',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mahkeme adı gerekli';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Davacı
                TextFormField(
                  controller: _davaciController,
                  decoration: InputDecoration(
                    labelText: 'Davacı',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Davacı bilgisi gerekli';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Davalı
                TextFormField(
                  controller: _davaliController,
                  decoration: InputDecoration(
                    labelText: 'Davalı',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Davalı bilgisi gerekli';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Konu
                TextFormField(
                  controller: _konuController,
                  decoration: InputDecoration(
                    labelText: 'Konu',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konu gerekli';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // İçerik
                TextFormField(
                  controller: _icerikController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: 'Dilekçe İçeriği',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Dilekçe içeriği gerekli';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Oluştur Butonu
                ElevatedButton(
                  onPressed: _isLoading ? null : _olusturDilekce,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'AI ile Oluşturuluyor...',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'AI ile Dilekçe Oluştur',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dilekçe Sonuç Ekranı
class DilekceSonucScreen extends StatelessWidget {
  final String dilekce;

  const DilekceSonucScreen({super.key, required this.dilekce});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Oluşturulan Dilekçe',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Paylaşma işlevi
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              // PDF indirme işlevi
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SelectableText(
            dilekce,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

