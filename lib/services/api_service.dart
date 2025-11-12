import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Backend API base URL - Environment'a göre otomatik seçilir
  // Production: Heroku, Railway, Render gibi bir bulut servise deploy edildiğinde
  // Development: Local development için
  
  // Environment kontrolü
  static const bool _isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  
  // Production URL (bulut sunucuya deploy edildiğinde buraya URL'i yazın)
  // Örnekler:
  // Render (ÜCRETSİZ): https://your-project.onrender.com/api
  // Railway (Ücretli): https://your-project.railway.app/api
  // Fly.io (ÜCRETSİZ): https://your-app.fly.dev/api
  // Heroku (Ücretli): https://your-app.herokuapp.com/api
  static const String _productionUrl = 'https://dava-takip-backend.onrender.com/api';
  
  // Development URL'leri
  static const String _androidEmulatorUrl = 'http://10.0.2.2:5000/api';
  static const String _iosSimulatorUrl = 'http://localhost:5000/api';
  static const String _physicalDeviceUrl = 'http://192.168.1.100:5000/api'; // TODO: Bilgisayarınızın IP'sini yazın
  
  // Platform kontrolü
  static String get baseUrl {
    if (_isProduction) {
      return _productionUrl;
    }
    
    // Development modunda platform'a göre seç
    // Not: Platform kontrolü için kullanıcı manuel olarak değiştirmeli
    // Veya build-time'da environment variable ile belirlenebilir
    
    // Production modunda production URL'i kullan
    // Development için Android emülatör URL'i
    // Fiziksel cihaz kullanıyorsanız _physicalDeviceUrl'i kullanın
    
    // Şimdilik production URL'i kullan (deploy edildi)
    return _productionUrl;
    
    // Development için (local backend):
    // return _androidEmulatorUrl;
    
    // Fiziksel cihaz için:
    // return _physicalDeviceUrl;
  }

  // ==================== HESAPLAMA MODÜLLERİ ====================

  static Future<Map<String, dynamic>> hesaplaInfazSuresi({
    required double cezaSuresi,
    required bool denetimliSerbestlik,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hesaplama/infaz-suresi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ceza_suresi': cezaSuresi,
          'denetimli_serbestlik': denetimliSerbestlik,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Hesaplama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  static Future<Map<String, dynamic>> hesaplaMirasSakliPay({
    required double toplamMiras,
    required String mirasciTuru,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hesaplama/miras-sakli-pay'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'toplam_miras': toplamMiras,
          'mirasci_turu': mirasciTuru,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Hesaplama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  static Future<Map<String, dynamic>> hesaplaHarc({
    required double davaDegeri,
    required String mahkemeTuru,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hesaplama/harc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dava_degeri': davaDegeri,
          'mahkeme_turu': mahkemeTuru,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Hesaplama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  static Future<Map<String, dynamic>> hesaplaVekaletUcreti({
    required double davaDegeri,
    required String davaTuru,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hesaplama/vekalet-ucreti'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dava_degeri': davaDegeri,
          'dava_turu': davaTuru,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Hesaplama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  static Future<Map<String, dynamic>> hesaplaArabuluculuk({
    required int tarafSayisi,
    required String uyusmazlikTuru,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hesaplama/arabuluculuk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'taraf_sayisi': tarafSayisi,
          'uyusmazlik_turu': uyusmazlikTuru,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Hesaplama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  static Future<Map<String, dynamic>> hesaplaMakbuz({
    required double brutUcret,
    required double stopajOrani,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hesaplama/makbuz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'brut_ucret': brutUcret,
          'stopaj_orani': stopajOrani,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Hesaplama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  // ==================== DÖVİZ ====================

  static Future<Map<String, dynamic>> getDovizKurlari() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doviz/kurlar'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Döviz kurları alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  static Future<Map<String, dynamic>> donusturDoviz({
    required double miktar,
    required String from,
    required String to,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/doviz/donustur'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'miktar': miktar,
          'from': from,
          'to': to,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Dönüştürme başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  // ==================== MEVZUAT ====================

  static Future<Map<String, dynamic>> aramaMevzuat({
    required String query,
    String tur = 'tumu',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mevzuat/arama?q=$query&tur=$tur'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Arama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  // ==================== İÇTİHAT ====================

  static Future<Map<String, dynamic>> aramaIctihat({
    required String query,
    String tur = 'tumu',
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ictihat/arama?q=$query&tur=$tur'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Arama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  // ==================== PRATİK BİLGİLER ====================

  static Future<Map<String, dynamic>> getGenelBilgiler() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pratik-bilgiler/genel'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Bilgiler alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  static Future<Map<String, dynamic>> getAvukatlikKurallari() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pratik-bilgiler/avukatlik-kurallari'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Kurallar alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  static Future<Map<String, dynamic>> getSozluk({String? query}) async {
    try {
      final uri = query != null
          ? Uri.parse('$baseUrl/pratik-bilgiler/sozluk?q=$query')
          : Uri.parse('$baseUrl/pratik-bilgiler/sozluk');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Sözlük alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  // ==================== YAZIM ====================

  static Future<Map<String, dynamic>> getYazimSablonlari() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/yazim/sablonlar'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Şablonlar alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  // ==================== AI CHAT ====================

  static Future<Map<String, dynamic>> aiChat({
    required String message,
    required String asistanTuru,
    List<Map<String, String>>? history,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'asistan_turu': asistanTuru,
          'history': history ?? [],
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('AI yanıtı alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  // ==================== AI DİLEKÇE YAZMA ====================

  static Future<Map<String, dynamic>> aiDilekceYaz({
    required String dilekceTuru,
    required String mahkeme,
    required String davaci,
    required String davali,
    required String konu,
    String ekBilgiler = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/dilekce-yaz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dilekce_turu': dilekceTuru,
          'mahkeme': mahkeme,
          'davaci': davaci,
          'davali': davali,
          'konu': konu,
          'ek_bilgiler': ekBilgiler,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Dilekçe oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  // ==================== YARGITAY KARAR ARAMA ====================

  static Future<Map<String, dynamic>> yargitayArama({
    String aranacakKelime = '',
    String birim = '',
    String kurul = '',
    String hukukDairesi = '',
    String cezaDairesi = '',
    String esasNo = '',
    String kararNo = '',
    String kararTarihiBaslangic = '',
    String kararTarihiBitis = '',
    String sirala = 'esas_no',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/yargitay/arama'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aranacak_kelime': aranacakKelime,
          'birim': birim,
          'kurul': kurul,
          'hukuk_dairesi': hukukDairesi,
          'ceza_dairesi': cezaDairesi,
          'esas_no': esasNo,
          'karar_no': kararNo,
          'karar_tarihi_baslangic': kararTarihiBaslangic,
          'karar_tarihi_bitis': kararTarihiBitis,
          'sirala': sirala,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Yargıtay arama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }

  static Future<Map<String, dynamic>> yargitayPopuler() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/yargitay/populer'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Popüler kararlar alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API hatası: $e');
    }
  }
}

