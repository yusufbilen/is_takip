import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PratikBilgilerScreen extends StatefulWidget {
  final String title;

  const PratikBilgilerScreen({
    super.key,
    required this.title,
  });

  @override
  State<PratikBilgilerScreen> createState() => _PratikBilgilerScreenState();
}

class _PratikBilgilerScreenState extends State<PratikBilgilerScreen> {
  String _icerik = 'Yükleniyor...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      Map<String, dynamic>? result;
      
      switch (widget.title) {
        case 'Genel Bilgiler':
          result = await ApiService.getGenelBilgiler();
          break;
        case 'Avukatlık Kuralları':
          result = await ApiService.getAvukatlikKurallari();
          break;
        case 'Sözlük':
          result = await ApiService.getSozluk();
          break;
        default:
          _icerik = _getContent(widget.title);
          setState(() {
            _isLoading = false;
          });
          return;
      }

      if (result != null && result['success'] == true) {
        final resultMap = result!; // Null check'ten sonra non-null assertion
        setState(() {
          if (widget.title == 'Sözlük') {
            final sozluk = resultMap['sozluk'] as Map<String, dynamic>?;
            if (sozluk != null) {
              _icerik = sozluk.entries
                  .map((e) => '${e.key.toUpperCase()}: ${e.value}')
                  .join('\n\n');
            } else {
              _icerik = _getContent(widget.title);
            }
          } else {
            _icerik = resultMap['icerik'] as String? ?? _getContent(widget.title);
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _icerik = _getContent(widget.title);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _icerik = _getContent(widget.title);
        _isLoading = false;
      });
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _icerik,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getContent(String title) {
    switch (title) {
      case 'Genel Bilgiler':
        return '''
Avukatlık mesleği, hukuki danışmanlık ve temsil hizmetleri sunan önemli bir meslektir. Avukatlar, müvekkillerinin haklarını korumak ve hukuki süreçlerde temsil etmekle yükümlüdür.

Avukatlık mesleğinin temel ilkeleri:
- Bağımsızlık
- Meslek sırrı
- Müvekkil menfaatini ön planda tutma
- Etik kurallara uyma
''';
      case 'Avukatlık Kuralları':
        return '''
Avukatlık Kanunu ve Türkiye Barolar Birliği Meslek Kuralları çerçevesinde avukatların uyması gereken kurallar:

1. Meslek sırrı saklama yükümlülüğü
2. Müvekkil menfaatini koruma
3. Reklam yasağı
4. Etik kurallara uyma
5. Meslek onuruna uygun davranma
''';
      case 'Avukatlık Ücret Tarifesi':
        return '''
Avukatlık ücretleri, dava tutarına ve işin niteliğine göre belirlenir. Minimum ücret tarifesi Türkiye Barolar Birliği tarafından belirlenir.

Ücret hesaplama yöntemleri:
- Dava tutarına göre yüzdelik
- Saatlik ücret
- Sabit ücret
- Başarı ücreti (belirli durumlarda)
''';
      case 'Döviz Kurları':
        return '''
Güncel döviz kurları Türkiye Cumhuriyet Merkez Bankası tarafından belirlenir ve günlük olarak güncellenir.

Ana döviz kurları:
- USD/TL
- EUR/TL
- GBP/TL
- CHF/TL
''';
      case 'Döviz Dönüştürücü':
        return '''
Döviz dönüştürücü aracı ile farklı para birimleri arasında dönüştürme yapabilirsiniz.

Desteklenen para birimleri:
- Türk Lirası (TRY)
- Amerikan Doları (USD)
- Euro (EUR)
- İngiliz Sterlini (GBP)
- İsviçre Frangı (CHF)
''';
      case 'Sözlük':
        return '''
Hukuk terimleri sözlüğü, hukuki kavramların açıklamalarını içerir.

Önemli hukuk terimleri:
- Dava: Hukuki uyuşmazlıkların çözümü için başvurulan yargı yolu
- İstinaf: Bölge adliye mahkemelerine yapılan başvuru
- Temyiz: Yargıtay'a yapılan başvuru
- İcra: Borçların zorla tahsili
''';
      default:
        return 'Bu bölüm için içerik hazırlanıyor...';
    }
  }
}

