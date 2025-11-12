import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/muvekkil.dart';
import '../models/dava.dart';
import '../models/gorev.dart';
import '../models/etkinlik.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  // Veri listeleri
  List<Muvekkil> _muvekkiller = [];
  List<Dava> _davalar = [];
  List<Gorev> _gorevler = [];
  List<Etkinlik> _etkinlikler = [];
  Map<String, int> _dashboardStats = {};
  
  // Loading durumları
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Muvekkil> get muvekkiller => _muvekkiller;
  List<Dava> get davalar => _davalar;
  List<Gorev> get gorevler => _gorevler;
  List<Etkinlik> get etkinlikler => _etkinlikler;
  Map<String, int> get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Bugünkü etkinlikler
  List<Etkinlik> get bugunkuEtkinlikler {
    final today = DateTime.now();
    return _etkinlikler.where((etkinlik) => 
      etkinlik.baslangicTarihi.year == today.year &&
      etkinlik.baslangicTarihi.month == today.month &&
      etkinlik.baslangicTarihi.day == today.day
    ).toList();
  }
  
  // Acil görevler
  List<Gorev> get acilGorevler {
    return _gorevler.where((gorev) => 
      gorev.oncelik == GorevOnceligi.acil &&
      gorev.durum != GorevDurumu.tamamlandi
    ).toList();
  }
  
  // Geciken görevler
  List<Gorev> get gecikenGorevler {
    return _gorevler.where((gorev) => gorev.gecikmis).toList();
  }
  
  // Aktif davalar
  List<Dava> get aktifDavalar {
    return _davalar.where((dava) => 
      dava.durum == DavaDurumu.yeni ||
      dava.durum == DavaDurumu.devamEden ||
      dava.durum == DavaDurumu.durusmaBekleyen
    ).toList();
  }

  // Tüm verileri yükle
  Future<void> loadAllData() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadMuvekkiller(),
        _loadDavalar(),
        _loadGorevler(),
        _loadEtkinlikler(),
        _loadDashboardStats(),
      ]);
      _clearError();
    } catch (e) {
      _setError('Veriler yüklenirken hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Müvekkilleri yükle
  Future<void> _loadMuvekkiller() async {
    try {
      _muvekkiller = await _databaseService.getAllMuvekkil();
      notifyListeners();
    } catch (e) {
      throw Exception('Müvekkiller yüklenemedi: $e');
    }
  }

  // Davaları yükle
  Future<void> _loadDavalar() async {
    try {
      _davalar = await _databaseService.getAllDava();
      notifyListeners();
    } catch (e) {
      throw Exception('Davalar yüklenemedi: $e');
    }
  }

  // Görevleri yükle
  Future<void> _loadGorevler() async {
    try {
      _gorevler = await _databaseService.getAllGorev();
      notifyListeners();
    } catch (e) {
      throw Exception('Görevler yüklenemedi: $e');
    }
  }

  // Etkinlikleri yükle
  Future<void> _loadEtkinlikler() async {
    try {
      _etkinlikler = await _databaseService.getAllEtkinlik();
      notifyListeners();
    } catch (e) {
      throw Exception('Etkinlikler yüklenemedi: $e');
    }
  }

  // Dashboard istatistiklerini yükle
  Future<void> _loadDashboardStats() async {
    try {
      _dashboardStats = await _databaseService.getDashboardStats();
      notifyListeners();
    } catch (e) {
      throw Exception('İstatistikler yüklenemedi: $e');
    }
  }

  // Müvekkil ekle
  Future<void> addMuvekkil(Muvekkil muvekkil) async {
    try {
      await _databaseService.insertMuvekkil(muvekkil);
      await _loadMuvekkiller();
      await _loadDashboardStats();
    } catch (e) {
      _setError('Müvekkil eklenirken hata oluştu: $e');
    }
  }

  // Müvekkil güncelle
  Future<void> updateMuvekkil(Muvekkil muvekkil) async {
    try {
      await _databaseService.updateMuvekkil(muvekkil);
      await _loadMuvekkiller();
    } catch (e) {
      _setError('Müvekkil güncellenirken hata oluştu: $e');
    }
  }

  // Müvekkil sil
  Future<void> deleteMuvekkil(int id) async {
    try {
      await _databaseService.deleteMuvekkil(id);
      await _loadMuvekkiller();
      await _loadDashboardStats();
    } catch (e) {
      _setError('Müvekkil silinirken hata oluştu: $e');
    }
  }

  // Dava ekle
  Future<void> addDava(Dava dava) async {
    try {
      await _databaseService.insertDava(dava);
      await _loadDavalar();
      await _loadDashboardStats();
    } catch (e) {
      _setError('Dava eklenirken hata oluştu: $e');
    }
  }

  // Dava güncelle
  Future<void> updateDava(Dava dava) async {
    try {
      await _databaseService.updateDava(dava);
      await _loadDavalar();
    } catch (e) {
      _setError('Dava güncellenirken hata oluştu: $e');
    }
  }

  // Dava sil
  Future<void> deleteDava(int id) async {
    try {
      await _databaseService.deleteDava(id);
      await _loadDavalar();
      await _loadDashboardStats();
    } catch (e) {
      _setError('Dava silinirken hata oluştu: $e');
    }
  }

  // Görev ekle
  Future<void> addGorev(Gorev gorev) async {
    try {
      await _databaseService.insertGorev(gorev);
      await _loadGorevler();
      await _loadDashboardStats();
    } catch (e) {
      _setError('Görev eklenirken hata oluştu: $e');
    }
  }

  // Görev güncelle
  Future<void> updateGorev(Gorev gorev) async {
    try {
      await _databaseService.updateGorev(gorev);
      await _loadGorevler();
    } catch (e) {
      _setError('Görev güncellenirken hata oluştu: $e');
    }
  }

  // Görev sil
  Future<void> deleteGorev(int id) async {
    try {
      await _databaseService.deleteGorev(id);
      await _loadGorevler();
      await _loadDashboardStats();
    } catch (e) {
      _setError('Görev silinirken hata oluştu: $e');
    }
  }

  // Etkinlik ekle
  Future<void> addEtkinlik(Etkinlik etkinlik) async {
    try {
      await _databaseService.insertEtkinlik(etkinlik);
      await _loadEtkinlikler();
      await _loadDashboardStats();
    } catch (e) {
      _setError('Etkinlik eklenirken hata oluştu: $e');
    }
  }

  // Etkinlik güncelle
  Future<void> updateEtkinlik(Etkinlik etkinlik) async {
    try {
      await _databaseService.updateEtkinlik(etkinlik);
      await _loadEtkinlikler();
    } catch (e) {
      _setError('Etkinlik güncellenirken hata oluştu: $e');
    }
  }

  // Etkinlik sil
  Future<void> deleteEtkinlik(int id) async {
    try {
      await _databaseService.deleteEtkinlik(id);
      await _loadEtkinlikler();
      await _loadDashboardStats();
    } catch (e) {
      _setError('Etkinlik silinirken hata oluştu: $e');
    }
  }

  // Yardımcı metodlar
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Hata temizle
  void clearError() {
    _clearError();
  }
}
