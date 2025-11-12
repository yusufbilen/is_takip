import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

class YargitayService {
  static const String baseUrl = 'https://karararama.yargitay.gov.tr/';

  // Karar arama fonksiyonu
  Future<List<YargitayKarar>> aramaYap({
    String? aramaKelimesi,
    String? birim,
    String? esasNo,
    String? kararNo,
    String? kararTarihi,
    String? siralama = 'karar_tarihi',
    String? siralamaYonu = 'desc',
  }) async {
    try {
      // Yargıtay sitesine GET isteği gönder
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
          'Referer': 'https://karararama.yargitay.gov.tr/',
        },
      );

      if (response.statusCode == 200) {
        // HTML'den sonuçları parse et
        final document = html_parser.parse(response.body);
        
        // Önce tüm tabloları bul
        final tables = document.querySelectorAll('table');
        List<YargitayKarar> allKararlar = [];
        
        for (var table in tables) {
          final tbody = table.querySelector('tbody');
          if (tbody != null && tbody.children.isNotEmpty) {
            final kararlar = _parseKararTable(tbody);
            allKararlar.addAll(kararlar);
          }
        }
        
        // Eğer tablo bulunamadıysa, tüm linkleri kontrol et
        if (allKararlar.isEmpty) {
          final links = document.querySelectorAll('a[href*="karar"], a[href*="esas"], a[href*="detay"]');
          for (var link in links) {
            final baslik = link.text.trim();
            if (baslik.isNotEmpty && baslik.length > 10 && baslik.length < 200) {
              final href = link.attributes['href'] ?? '';
              final parent = link.parent;
              String birim = '';
              String esasNo = '';
              String kararNo = '';
              String tarih = '';
              
              if (parent != null) {
                final text = parent.text;
                // Birim bul
                final birimMatch = RegExp(r'(\d+\.\s*[^\n]+Dairesi|[^\n]+Kurulu)').firstMatch(text);
                if (birimMatch != null) birim = birimMatch.group(1)?.trim() ?? '';
                
                // Esas/Karar No bul
                final noMatches = RegExp(r'(\d{4}/\d+)').allMatches(text);
                if (noMatches.isNotEmpty) {
                  final matches = noMatches.toList();
                  esasNo = matches[0].group(1) ?? '';
                  if (matches.length > 1) kararNo = matches[1].group(1) ?? '';
                }
                
                // Tarih bul
                final tarihMatch = RegExp(r'(\d{2}\.\d{2}\.\d{4})').firstMatch(text);
                if (tarihMatch != null) tarih = tarihMatch.group(1) ?? '';
              }
              
              allKararlar.add(YargitayKarar(
                baslik: baslik,
                link: href.isNotEmpty && href.startsWith('http') 
                    ? href 
                    : (href.isNotEmpty ? '$baseUrl$href' : baseUrl),
                birim: birim,
                esasNo: esasNo,
                kararNo: kararNo,
                tarih: tarih,
              ));
              
              if (allKararlar.length >= 10) break;
            }
          }
        }
        
        return allKararlar.take(10).toList();
      } else {
        throw Exception('Arama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      print('Yargıtay arama hatası: $e');
      return [];
    }
  }

  // Tablodan karar sonuçlarını parse et (tbody veya table alabilir)
  List<YargitayKarar> _parseKararTable(html_dom.Element table) {
    final List<YargitayKarar> kararlar = [];
    // Eğer tbody ise direkt rows al, değilse tbody'yi bul
    final rows = table.localName == 'tbody' 
        ? table.querySelectorAll('tr')
        : table.querySelectorAll('tbody tr, tr');
    
    for (var row in rows) {
      try {
        final karar = _parseKararRow(row);
        if (karar != null) {
          kararlar.add(karar);
        }
      } catch (e) {
        print('Karar parse hatası: $e');
      }
    }
    
    return kararlar;
  }

  // Kartlardan karar sonuçlarını parse et
  List<YargitayKarar> _parseKararCards(List<html_dom.Element> cards) {
    final List<YargitayKarar> kararlar = [];
    
    for (var card in cards) {
      try {
        final karar = _parseKararCard(card);
        if (karar != null) {
          kararlar.add(karar);
        }
      } catch (e) {
        print('Karar card parse hatası: $e');
      }
    }
    
    return kararlar;
  }

  // Kart elementinden karar parse et
  YargitayKarar? _parseKararCard(html_dom.Element card) {
    try {
      final baslikElement = card.querySelector('h3, h4, .baslik, .title, a');
      final baslik = baslikElement?.text.trim() ?? '';
      
      if (baslik.isEmpty) return null;
      
      final link = baslikElement?.attributes['href'] ?? '';
      final birim = card.querySelector('.birim, .daire, [data-birim]')?.text.trim() ?? '';
      final esasNo = card.querySelector('.esas, [data-esas]')?.text.trim() ?? '';
      final kararNo = card.querySelector('.karar, [data-karar]')?.text.trim() ?? '';
      final tarih = card.querySelector('.tarih, [data-tarih]')?.text.trim() ?? '';
      
      return YargitayKarar(
        baslik: baslik,
        link: link.isNotEmpty ? (link.startsWith('http') ? link : '$baseUrl$link') : baseUrl,
        birim: birim,
        esasNo: esasNo,
        kararNo: kararNo,
        tarih: tarih,
      );
    } catch (e) {
      return null;
    }
  }


  // Tek bir karar satırını parse et
  YargitayKarar? _parseKararRow(html_dom.Element row) {
    try {
      // Tüm hücreleri al
      final cells = row.querySelectorAll('td');
      if (cells.length < 3) return null;
      
      // İlk hücre genellikle başlık/link içerir
      final linkElement = cells[0].querySelector('a');
      final baslik = linkElement?.text.trim() ?? cells[0].text.trim();
      final href = linkElement?.attributes['href'] ?? '';
      
      // Diğer hücrelerden bilgileri çıkar
      String birim = '';
      String esasNo = '';
      String kararNo = '';
      String tarih = '';
      
      for (var cell in cells) {
        final text = cell.text.trim();
        if (text.contains('Daire') || text.contains('Kurul')) {
          birim = text;
        } else if (text.contains('/') && text.length < 20) {
          if (esasNo.isEmpty) {
            esasNo = text;
          } else {
            kararNo = text;
          }
        } else if (text.contains('.') && text.length == 10) {
          tarih = text;
        }
      }
      
      if (baslik.isEmpty) return null;

      return YargitayKarar(
        baslik: baslik,
        link: href.isNotEmpty ? (href.startsWith('http') ? href : '$baseUrl$href') : baseUrl,
        birim: birim,
        esasNo: esasNo,
        kararNo: kararNo,
        tarih: tarih,
      );
    } catch (e) {
      print('Row parse hatası: $e');
      return null;
    }
  }

  String? _extractText(html_dom.Element element, String className) {
    return element.querySelector('.$className')?.text.trim();
  }

  // Birim listesi
  static List<String> getBirimler() {
    return [
      'Tüm Birimler',
      'Hukuk Genel Kurulu',
      'Ceza Genel Kurulu',
      '1. Hukuk Dairesi',
      '2. Hukuk Dairesi',
      '3. Hukuk Dairesi',
      '4. Hukuk Dairesi',
      '5. Hukuk Dairesi',
      '6. Hukuk Dairesi',
      '7. Hukuk Dairesi',
      '8. Hukuk Dairesi',
      '9. Hukuk Dairesi',
      '10. Hukuk Dairesi',
      '11. Hukuk Dairesi',
      '12. Hukuk Dairesi',
      '13. Hukuk Dairesi',
      '14. Hukuk Dairesi',
      '15. Hukuk Dairesi',
      '16. Hukuk Dairesi',
      '17. Hukuk Dairesi',
      '18. Hukuk Dairesi',
      '19. Hukuk Dairesi',
      '20. Hukuk Dairesi',
      '21. Hukuk Dairesi',
      '22. Hukuk Dairesi',
      '23. Hukuk Dairesi',
      '1. Ceza Dairesi',
      '2. Ceza Dairesi',
      '3. Ceza Dairesi',
      '4. Ceza Dairesi',
      '5. Ceza Dairesi',
      '6. Ceza Dairesi',
      '7. Ceza Dairesi',
      '8. Ceza Dairesi',
      '9. Ceza Dairesi',
      '10. Ceza Dairesi',
      '11. Ceza Dairesi',
      '12. Ceza Dairesi',
      '13. Ceza Dairesi',
      '14. Ceza Dairesi',
      '15. Ceza Dairesi',
      '16. Ceza Dairesi',
      '17. Ceza Dairesi',
      '18. Ceza Dairesi',
      '19. Ceza Dairesi',
      '20. Ceza Dairesi',
      '21. Ceza Dairesi',
      '22. Ceza Dairesi',
      '23. Ceza Dairesi',
    ];
  }
}

// Karar modeli
class YargitayKarar {
  final String baslik;
  final String link;
  final String birim;
  final String esasNo;
  final String kararNo;
  final String tarih;
  final String? kararMetni;

  YargitayKarar({
    required this.baslik,
    required this.link,
    required this.birim,
    required this.esasNo,
    required this.kararNo,
    required this.tarih,
    this.kararMetni,
  });
}

