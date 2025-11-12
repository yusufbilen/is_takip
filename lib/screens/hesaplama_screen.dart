import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class HesaplamaScreen extends StatefulWidget {
  final String hesaplamaTuru;
  final String title;

  const HesaplamaScreen({
    super.key,
    required this.hesaplamaTuru,
    required this.title,
  });

  @override
  State<HesaplamaScreen> createState() => _HesaplamaScreenState();
}

class _HesaplamaScreenState extends State<HesaplamaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _anaParaController = TextEditingController();
  final _faizOraniController = TextEditingController();
  final _gunController = TextEditingController();
  final _tarihController = TextEditingController();
  
  double _sonuc = 0.0;
  bool _hesaplandi = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _anaParaController.dispose();
    _faizOraniController.dispose();
    _gunController.dispose();
    _tarihController.dispose();
    super.dispose();
  }

  Future<void> _hesapla() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _hesaplandi = false;
      });

      try {
        Map<String, dynamic>? result;
        
        // Hesaplama türüne göre API çağrısı
        switch (widget.hesaplamaTuru) {
          case 'faiz':
            final anaPara = double.tryParse(_anaParaController.text) ?? 0;
            final faizOrani = double.tryParse(_faizOraniController.text) ?? 0;
            final gun = int.tryParse(_gunController.text) ?? 0;
            final faiz = (anaPara * faizOrani * gun) / (100 * 365);
            result = {'success': true, 'sonuc': anaPara + faiz};
            break;
            
          case 'harc':
          case 'yerel-mahkeme-harc':
          case 'bolge-adliye-harc':
          case 'yargitay-harc':
          case 'idare-mahkemesi-harc':
          case 'bolge-idare-harc':
          case 'vergi-mahkemesi-harc':
          case 'danistay-harc':
            final davaDegeri = double.tryParse(_anaParaController.text) ?? 0;
            final mahkemeTuru = widget.hesaplamaTuru.replaceAll('-harc', '').replaceAll('-', '_');
            result = await ApiService.hesaplaHarc(
              davaDegeri: davaDegeri,
              mahkemeTuru: mahkemeTuru,
            );
            break;
            
          case 'vekalet-ucreti':
            final davaDegeri = double.tryParse(_anaParaController.text) ?? 0;
            result = await ApiService.hesaplaVekaletUcreti(
              davaDegeri: davaDegeri,
              davaTuru: 'hukuk',
            );
            break;
            
          case 'arabuluculuk':
            final tarafSayisi = int.tryParse(_anaParaController.text) ?? 2;
            result = await ApiService.hesaplaArabuluculuk(
              tarafSayisi: tarafSayisi,
              uyusmazlikTuru: 'ticari',
            );
            break;
            
          case 'makbuz':
            final brutUcret = double.tryParse(_anaParaController.text) ?? 0;
            final stopajOrani = double.tryParse(_faizOraniController.text) ?? 20;
            result = await ApiService.hesaplaMakbuz(
              brutUcret: brutUcret,
              stopajOrani: stopajOrani,
            );
            break;
            
          default:
            // Varsayılan faiz hesaplama
            final anaPara = double.tryParse(_anaParaController.text) ?? 0;
            final faizOrani = double.tryParse(_faizOraniController.text) ?? 0;
            final gun = int.tryParse(_gunController.text) ?? 0;
            final faiz = (anaPara * faizOrani * gun) / (100 * 365);
            result = {'success': true, 'sonuc': anaPara + faiz};
        }

        if (result != null && result['success'] == true) {
          final resultMap = result!; // Null check'ten sonra non-null assertion
          setState(() {
            _sonuc = (resultMap['sonuc'] as num?)?.toDouble() ?? 
                     (resultMap['harc_tutari'] as num?)?.toDouble() ?? 
                     (resultMap['vekalet_ucreti'] as num?)?.toDouble() ?? 
                     (resultMap['arabuluculuk_ucreti'] as num?)?.toDouble() ?? 
                     (resultMap['net_ucret'] as num?)?.toDouble() ?? 0.0;
            _hesaplandi = true;
            _isLoading = false;
          });
        } else {
          throw Exception('Hesaplama başarısız');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hesaplama hatası: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
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
                // Ana Para
                TextFormField(
                  controller: _anaParaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Ana Para (TL)',
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
                      return 'Ana para gerekli';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Faiz Oranı
                TextFormField(
                  controller: _faizOraniController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Faiz Oranı (%)',
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
                      return 'Faiz oranı gerekli';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Gün
                TextFormField(
                  controller: _gunController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Gün Sayısı',
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
                      return 'Gün sayısı gerekli';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Hesapla Butonu
                ElevatedButton(
                  onPressed: _isLoading ? null : _hesapla,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Hesapla',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                
                if (_hesaplandi) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hesaplama Sonucu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Toplam Tutar:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(_sonuc)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

