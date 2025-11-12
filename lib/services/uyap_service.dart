import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:shared_preferences/shared_preferences.dart';

class UyapService {
  static const String baseUrl = 'https://uyap.gov.tr';
  static const String avukatPortalUrl = 'https://avukatbeta.uyap.gov.tr';
  static const String edevletGirisUrl = 'https://giris.turkiye.gov.tr/Giris/gir';
  
  // E-devlet kimlik doğrulama için token
  String? _authToken;
  String? _sessionId;
  
  // E-devlet ile giriş yap
  Future<bool> loginWithEdevlet({
    required String tcKimlik,
    required String password,
  }) async {
    try {
      // E-devlet giriş sayfasını çek
      final response = await http.get(
        Uri.parse('$avukatPortalUrl/giris'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );
      
      if (response.statusCode == 200) {
        // Session ID'yi al
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          final sessionMatch = RegExp(r'JSESSIONID=([^;]+)').firstMatch(cookies);
          if (sessionMatch != null) {
            _sessionId = sessionMatch.group(1);
          }
        }
        
        // E-devlet giriş formunu gönder
        final loginResponse = await http.post(
          Uri.parse('$avukatPortalUrl/giris'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Cookie': 'JSESSIONID=$_sessionId',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
          body: {
            'tcKimlik': tcKimlik,
            'password': password,
          },
        );
        
        if (loginResponse.statusCode == 200) {
          // Token'ı kaydet
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('uyap_token', _authToken ?? '');
          await prefs.setString('uyap_session', _sessionId ?? '');
          
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('UYAP giriş hatası: $e');
      return false;
    }
  }
  
  // Dosya listesini çek
  Future<List<UyapDosya>> getDosyalar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionId = prefs.getString('uyap_session');
      final cookies = prefs.getString('uyap_cookies');
      
      if (_sessionId == null && cookies == null) {
        throw Exception('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
      }
      
      // UYAP portalından dosya listesini çekmek için HTML parse et
      // Not: UYAP'ın resmi API'si olmayabilir, bu yüzden WebView kullanımı önerilir
      final response = await http.get(
        Uri.parse('$avukatPortalUrl/main/avukat/index.jsp'),
        headers: {
          'Cookie': 'JSESSIONID=$_sessionId',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> dosyalar = data['data'] ?? [];
          return dosyalar.map((d) => UyapDosya.fromMap(d)).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Dosya listesi çekme hatası: $e');
      return [];
    }
  }
  
  // Dosya detayını çek
  Future<UyapDosyaDetay?> getDosyaDetay(String dosyaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionId = prefs.getString('uyap_session');
      
      if (_sessionId == null) {
        throw Exception('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
      }
      
      final response = await http.get(
        Uri.parse('$avukatPortalUrl/api/dosya/$dosyaId'),
        headers: {
          'Cookie': 'JSESSIONID=$_sessionId',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return UyapDosyaDetay.fromMap(data['data']);
        }
      }
      
      return null;
    } catch (e) {
      print('Dosya detay çekme hatası: $e');
      return null;
    }
  }
  
  // Çıkış yap
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uyap_token');
    await prefs.remove('uyap_session');
    _authToken = null;
    _sessionId = null;
  }
  
  // Oturum kontrolü
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString('uyap_session');
    return _sessionId != null;
  }
}

// UYAP Dosya Modeli
class UyapDosya {
  final String dosyaId;
  final String dosyaNo;
  final String baslik;
  final String mahkeme;
  final String durum;
  final DateTime? sonIslemTarihi;
  final String? vekil;
  
  UyapDosya({
    required this.dosyaId,
    required this.dosyaNo,
    required this.baslik,
    required this.mahkeme,
    required this.durum,
    this.sonIslemTarihi,
    this.vekil,
  });
  
  factory UyapDosya.fromMap(Map<String, dynamic> map) {
    return UyapDosya(
      dosyaId: map['dosyaId'] ?? '',
      dosyaNo: map['dosyaNo'] ?? '',
      baslik: map['baslik'] ?? '',
      mahkeme: map['mahkeme'] ?? '',
      durum: map['durum'] ?? '',
      sonIslemTarihi: map['sonIslemTarihi'] != null
          ? DateTime.parse(map['sonIslemTarihi'])
          : null,
      vekil: map['vekil'],
    );
  }
}

// UYAP Dosya Detay Modeli
class UyapDosyaDetay {
  final String dosyaId;
  final String dosyaNo;
  final String baslik;
  final String mahkeme;
  final String hakim;
  final String durum;
  final List<UyapTaraf> taraflar;
  final List<UyapEvrak> evraklar;
  final List<UyapDurusma> durusmalar;
  final List<UyapSafahat> safahatlar;
  
  UyapDosyaDetay({
    required this.dosyaId,
    required this.dosyaNo,
    required this.baslik,
    required this.mahkeme,
    required this.hakim,
    required this.durum,
    required this.taraflar,
    required this.evraklar,
    required this.durusmalar,
    required this.safahatlar,
  });
  
  factory UyapDosyaDetay.fromMap(Map<String, dynamic> map) {
    return UyapDosyaDetay(
      dosyaId: map['dosyaId'] ?? '',
      dosyaNo: map['dosyaNo'] ?? '',
      baslik: map['baslik'] ?? '',
      mahkeme: map['mahkeme'] ?? '',
      hakim: map['hakim'] ?? '',
      durum: map['durum'] ?? '',
      taraflar: (map['taraflar'] as List<dynamic>?)
          ?.map((t) => UyapTaraf.fromMap(t))
          .toList() ?? [],
      evraklar: (map['evraklar'] as List<dynamic>?)
          ?.map((e) => UyapEvrak.fromMap(e))
          .toList() ?? [],
      durusmalar: (map['durusmalar'] as List<dynamic>?)
          ?.map((d) => UyapDurusma.fromMap(d))
          .toList() ?? [],
      safahatlar: (map['safahatlar'] as List<dynamic>?)
          ?.map((s) => UyapSafahat.fromMap(s))
          .toList() ?? [],
    );
  }
}

class UyapTaraf {
  final String ad;
  final String tip; // davaci, davali, katilan, vs.
  final String? vekil;
  
  UyapTaraf({
    required this.ad,
    required this.tip,
    this.vekil,
  });
  
  factory UyapTaraf.fromMap(Map<String, dynamic> map) {
    return UyapTaraf(
      ad: map['ad'] ?? '',
      tip: map['tip'] ?? '',
      vekil: map['vekil'],
    );
  }
}

class UyapEvrak {
  final String evrakId;
  final String evrakNo;
  final String baslik;
  final DateTime tarih;
  final String? dosyaUrl;
  
  UyapEvrak({
    required this.evrakId,
    required this.evrakNo,
    required this.baslik,
    required this.tarih,
    this.dosyaUrl,
  });
  
  factory UyapEvrak.fromMap(Map<String, dynamic> map) {
    return UyapEvrak(
      evrakId: map['evrakId'] ?? '',
      evrakNo: map['evrakNo'] ?? '',
      baslik: map['baslik'] ?? '',
      tarih: DateTime.parse(map['tarih']),
      dosyaUrl: map['dosyaUrl'],
    );
  }
}

class UyapDurusma {
  final String durusmaId;
  final DateTime tarih;
  final String saat;
  final String salon;
  final String durum;
  
  UyapDurusma({
    required this.durusmaId,
    required this.tarih,
    required this.saat,
    required this.salon,
    required this.durum,
  });
  
  factory UyapDurusma.fromMap(Map<String, dynamic> map) {
    return UyapDurusma(
      durusmaId: map['durusmaId'] ?? '',
      tarih: DateTime.parse(map['tarih']),
      saat: map['saat'] ?? '',
      salon: map['salon'] ?? '',
      durum: map['durum'] ?? '',
    );
  }
}

class UyapSafahat {
  final String safahatId;
  final DateTime tarih;
  final String aciklama;
  
  UyapSafahat({
    required this.safahatId,
    required this.tarih,
    required this.aciklama,
  });
  
  factory UyapSafahat.fromMap(Map<String, dynamic> map) {
    return UyapSafahat(
      safahatId: map['safahatId'] ?? '',
      tarih: DateTime.parse(map['tarih']),
      aciklama: map['aciklama'] ?? '',
    );
  }
}

