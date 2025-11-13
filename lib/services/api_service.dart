import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

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
      } else if (response.statusCode == 502 || response.statusCode == 503) {
        throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
      } else {
        throw Exception('Hesaplama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('502') || e.toString().contains('503')) {
        throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
      }
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
      } else if (response.statusCode == 502 || response.statusCode == 503) {
        throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
      } else {
        throw Exception('Hesaplama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('502') || e.toString().contains('503')) {
        throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
      }
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
      } else if (response.statusCode == 502 || response.statusCode == 503) {
        throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
      } else {
        throw Exception('Hesaplama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('502') || e.toString().contains('503')) {
        throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
      }
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
      } else if (response.statusCode == 502 || response.statusCode == 503) {
        throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
      } else {
        throw Exception('Hesaplama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('502') || e.toString().contains('503')) {
        throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
      }
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
      } else if (response.statusCode == 502 || response.statusCode == 503) {
        throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
      } else {
        throw Exception('Hesaplama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('502') || e.toString().contains('503')) {
        throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
      }
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

  // ==================== BACKEND WAKE UP ====================

  static Future<void> wakeUpBackend() async {
    // Backend'i uyandırmak için agresif bir yaklaşım
    // Render'ın uyanması için birden fazla istek gönder
    print('Backend uyandırılıyor...');
    
    try {
      // İlk wake-up isteği (uzun timeout)
      try {
        await http.get(
          Uri.parse('$baseUrl/wake'),
        ).timeout(
          const Duration(seconds: 60), // Render'ın uyanması için daha uzun timeout
          onTimeout: () {
            print('Wake-up timeout (backend uyku modunda, normal)');
            throw TimeoutException('Wake-up timeout');
          },
        );
        print('Wake-up isteği 1 başarılı');
      } catch (e) {
        print('Wake-up isteği 1 başarısız (normal): $e');
      }
      
      // 5 saniye bekle
      await Future.delayed(const Duration(seconds: 5));
      
      // İkinci wake-up isteği (health check)
      try {
        await http.get(
          Uri.parse('$baseUrl/health'),
        ).timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            print('Health check timeout (backend uyku modunda, normal)');
            throw TimeoutException('Health check timeout');
          },
        );
        print('Backend uyandı!');
      } catch (e) {
        print('Health check başarısız (backend hala uyku modunda olabilir): $e');
      }
      
      // 5 saniye daha bekle (backend'in tamamen uyanması için)
      await Future.delayed(const Duration(seconds: 5));
      
    } catch (e) {
      // Hata olsa bile devam et, asıl istek yapılacak
      print('Wake-up genel hatası (normal): $e');
    }
  }

  // ==================== AI CHAT ====================

  static Future<Map<String, dynamic>> aiChat({
    required String message,
    required String asistanTuru,
    List<Map<String, String>>? history,
  }) async {
    // Önce backend'i uyandırmaya çalış
    await wakeUpBackend();
    
    // Retry mekanizması ile 5 kez deneme (Render uyku modundan uyanması için)
    int maxRetries = 5;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        final response = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'asistan_turu': asistanTuru,
          'history': history ?? [],
        }),
      ).timeout(
        const Duration(seconds: 120), // Render uyku modundan uyanması için daha uzun timeout
        onTimeout: () {
          throw TimeoutException('İstek zaman aşımına uğradı. Render sunucusu uyku modunda olabilir. Lütfen tekrar deneyin (ilk istek 30-60 saniye sürebilir).');
        },
      );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 502 || response.statusCode == 503) {
          // 502/503 hatası alındı, retry yap
          retryCount++;
          if (retryCount < maxRetries) {
            print('502/503 hatası, ${retryCount + 1}. deneme yapılıyor...');
            await Future.delayed(Duration(seconds: 10 + (retryCount * 5))); // Her retry'da daha uzun bekle (10, 15, 20, 25, 30 saniye)
            continue;
          }
          throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
        } else {
          throw Exception('AI yanıtı alınamadı: ${response.statusCode}');
        }
      } catch (e) {
        if (e is TimeoutException) {
          retryCount++;
          if (retryCount < maxRetries) {
            print('Timeout hatası, ${retryCount + 1}. deneme yapılıyor...');
            await Future.delayed(Duration(seconds: 10 + (retryCount * 5))); // Her retry'da daha uzun bekle
            continue;
          }
          throw e;
        }
        
        if (e.toString().contains('502') || e.toString().contains('503')) {
          retryCount++;
          if (retryCount < maxRetries) {
            print('502/503 hatası, ${retryCount + 1}. deneme yapılıyor...');
            await Future.delayed(Duration(seconds: 5 * retryCount));
            continue;
          }
          throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
        }
        
        // Diğer hatalar için retry yapma
        throw Exception('API hatası: $e');
      }
    }
    
    // Tüm retry'lar başarısız oldu
    throw Exception('Backend sunucusuna bağlanılamadı. Lütfen daha sonra tekrar deneyin.');
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
    // Önce backend'i uyandırmaya çalış
    await wakeUpBackend();
    
    // Retry mekanizması ile 5 kez deneme (Render uyku modundan uyanması için)
    int maxRetries = 5;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        print('API çağrısı başlatılıyor (${retryCount + 1}. deneme): $baseUrl/ai/dilekce-yaz');
        
        final requestBody = {
          'dilekce_turu': dilekceTuru,
          'mahkeme': mahkeme,
          'davaci': davaci,
          'davali': davali,
          'konu': konu,
          'ek_bilgiler': ekBilgiler,
        };
        
        print('Request body: ${jsonEncode(requestBody)}');
        
        final response = await http.post(
          Uri.parse('$baseUrl/ai/dilekce-yaz'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        ).timeout(
          const Duration(seconds: 120), // Render uyku modundan uyanması için daha uzun timeout
          onTimeout: () {
            print('API timeout: 120 saniye aşıldı');
            throw TimeoutException('Dilekçe oluşturma zaman aşımına uğradı. Render sunucusu uyku modunda olabilir. Lütfen tekrar deneyin (ilk istek 30-60 saniye sürebilir).');
          },
        );

        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

        if (response.statusCode == 200) {
          final decodedResponse = jsonDecode(response.body);
          print('Decoded response success: ${decodedResponse['success']}');
          return decodedResponse;
        } else if (response.statusCode == 502 || response.statusCode == 503) {
          // 502/503 hatası alındı, retry yap
          retryCount++;
          if (retryCount < maxRetries) {
            print('502/503 hatası, ${retryCount + 1}. deneme yapılıyor...');
            await Future.delayed(Duration(seconds: 5 * retryCount));
            continue;
          }
          print('502/503 hatası: Backend uyku modunda');
          throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
        } else {
          print('HTTP hatası: ${response.statusCode} - ${response.body}');
          throw Exception('Dilekçe oluşturulamadı: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('API catch hatası: $e');
        
        if (e is TimeoutException) {
          retryCount++;
          if (retryCount < maxRetries) {
            print('Timeout hatası, ${retryCount + 1}. deneme yapılıyor...');
            await Future.delayed(Duration(seconds: 10 + (retryCount * 5))); // Her retry'da daha uzun bekle
            continue;
          }
          throw e;
        }
        
        if (e.toString().contains('502') || e.toString().contains('503')) {
          retryCount++;
          if (retryCount < maxRetries) {
            print('502/503 hatası, ${retryCount + 1}. deneme yapılıyor...');
            await Future.delayed(Duration(seconds: 5 * retryCount));
            continue;
          }
          throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
        }
        
        // Diğer hatalar için retry yapma
        throw Exception('API hatası: $e');
      }
    }
    
    // Tüm retry'lar başarısız oldu
    throw Exception('Dilekçe oluşturulamadı. Backend sunucusuna bağlanılamadı. Lütfen daha sonra tekrar deneyin.');
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
    // Önce backend'i uyandırmaya çalış
    await wakeUpBackend();
    
    // Retry mekanizması ile 5 kez deneme (Render uyku modundan uyanması için)
    int maxRetries = 5;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
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
        ).timeout(
          const Duration(seconds: 120), // Render uyku modundan uyanması için daha uzun timeout
          onTimeout: () {
            throw TimeoutException('Arama zaman aşımına uğradı. Render sunucusu uyku modunda olabilir. Lütfen tekrar deneyin (ilk istek 30-60 saniye sürebilir).');
          },
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 502 || response.statusCode == 503) {
          // 502/503 hatası alındı, retry yap
          retryCount++;
          if (retryCount < maxRetries) {
            print('502/503 hatası, ${retryCount + 1}. deneme yapılıyor...');
            await Future.delayed(Duration(seconds: 5 * retryCount));
            continue;
          }
          throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
        } else {
          throw Exception('Yargıtay arama başarısız: ${response.statusCode}');
        }
      } catch (e) {
        if (e is TimeoutException) {
          retryCount++;
          if (retryCount < maxRetries) {
            print('Timeout hatası, ${retryCount + 1}. deneme yapılıyor...');
            await Future.delayed(Duration(seconds: 10 + (retryCount * 5))); // Her retry'da daha uzun bekle
            continue;
          }
          throw e;
        }
        
        if (e.toString().contains('502') || e.toString().contains('503')) {
          retryCount++;
          if (retryCount < maxRetries) {
            print('502/503 hatası, ${retryCount + 1}. deneme yapılıyor...');
            await Future.delayed(Duration(seconds: 5 * retryCount));
            continue;
          }
          throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
        }
        
        // Diğer hatalar için retry yapma
        throw Exception('API hatası: $e');
      }
    }
    
    // Tüm retry'lar başarısız oldu
    throw Exception('Yargıtay arama başarısız. Backend sunucusuna bağlanılamadı. Lütfen daha sonra tekrar deneyin.');
  }

  static Future<Map<String, dynamic>> yargitayPopuler() async {
    // Önce backend'i uyandırmaya çalış
    await wakeUpBackend();
    
    // Retry mekanizması ile 5 kez deneme (Render uyku modundan uyanması için)
    int maxRetries = 5;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/yargitay/populer'),
        ).timeout(
          const Duration(seconds: 120), // Render uyku modundan uyanması için daha uzun timeout
          onTimeout: () {
            throw TimeoutException('Popüler kararlar yüklenirken zaman aşımına uğradı. Render sunucusu uyku modunda olabilir. Lütfen tekrar deneyin.');
          },
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else if (response.statusCode == 502 || response.statusCode == 503) {
          // 502/503 hatası alındı, retry yap
          retryCount++;
          if (retryCount < maxRetries) {
            print('502/503 hatası, ${retryCount + 1}. deneme yapılıyor...');
            await Future.delayed(Duration(seconds: 5 * retryCount));
            continue;
          }
          throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
        } else {
          throw Exception('Popüler kararlar alınamadı: ${response.statusCode}');
        }
      } catch (e) {
        if (e is TimeoutException) {
          retryCount++;
          if (retryCount < maxRetries) {
            print('Timeout hatası, ${retryCount + 1}. deneme yapılıyor...');
            await Future.delayed(Duration(seconds: 10 + (retryCount * 5))); // Her retry'da daha uzun bekle
            continue;
          }
          throw e;
        }
        
        if (e.toString().contains('502') || e.toString().contains('503')) {
          retryCount++;
          if (retryCount < maxRetries) {
            print('502/503 hatası, ${retryCount + 1}. deneme yapılıyor...');
            await Future.delayed(Duration(seconds: 5 * retryCount));
            continue;
          }
          throw Exception('Backend sunucusu uyku modunda. Lütfen 30-60 saniye bekleyip tekrar deneyin.');
        }
        
        // Diğer hatalar için retry yapma
        throw Exception('API hatası: $e');
      }
    }
    
    // Tüm retry'lar başarısız oldu
    throw Exception('Popüler kararlar yüklenemedi. Backend sunucusuna bağlanılamadı. Lütfen daha sonra tekrar deneyin.');
  }
}

