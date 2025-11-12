import 'muvekkil.dart';

enum DavaDurumu {
  yeni,
  devamEden,
  durusmaBekleyen,
  kararBekleyen,
  kazanildi,
  kaybedildi,
  uzlastirma,
  iptal
}

enum DavaTuru {
  // Ceza Hukuku
  ceza,
  
  // Medeni Hukuk
  medeniHukuk,
  borclarHukuku,
  esyaHukuku,
  
  // Ticaret Hukuku
  ticaretHukuku,
  sirketlerHukuku,
  
  // İş Hukuku
  isHukuku,
  sosyalGuvenlik,
  
  // Aile Hukuku
  aileHukuku,
  mirasHukuku,
  
  // Gayrimenkul Hukuku
  gayrimenkulHukuku,
  
  // Fikri Mülkiyet
  fikriMulkiyet,
  patentMarka,
  
  // Vergi Hukuku
  vergiHukuku,
  
  // İdari Hukuk
  idareHukuku,
  
  // Diğer
  diger
}

class Dava {
  final int? id;
  final String davaNo;
  final String baslik;
  final String? aciklama;
  final DavaDurumu durum;
  final DavaTuru tur;
  final int muvekkilId;
  final Muvekkil? muvekkil;
  final DateTime? davaTarihi;
  final DateTime? durusmaTarihi;
  final String? mahkeme;
  final String? hakim;
  final String? karsiTaraf;
  final String? karsiTarafAvukat;
  final double? ucret;
  final String? notlar;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? dosyaYolu;

  Dava({
    this.id,
    required this.davaNo,
    required this.baslik,
    this.aciklama,
    required this.durum,
    required this.tur,
    required this.muvekkilId,
    this.muvekkil,
    this.davaTarihi,
    this.durusmaTarihi,
    this.mahkeme,
    this.hakim,
    this.karsiTaraf,
    this.karsiTarafAvukat,
    this.ucret,
    this.notlar,
    required this.createdAt,
    this.updatedAt,
    this.dosyaYolu,
  });

  String get durumText {
    switch (durum) {
      case DavaDurumu.yeni:
        return 'Yeni';
      case DavaDurumu.devamEden:
        return 'Devam Eden';
      case DavaDurumu.durusmaBekleyen:
        return 'Duruşma Bekleyen';
      case DavaDurumu.kararBekleyen:
        return 'Karar Bekleyen';
      case DavaDurumu.kazanildi:
        return 'Kazanıldı';
      case DavaDurumu.kaybedildi:
        return 'Kaybedildi';
      case DavaDurumu.uzlastirma:
        return 'Uzlaştırma';
      case DavaDurumu.iptal:
        return 'İptal';
    }
  }

  String get turText {
    return davaTuruToString(tur);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dava_no': davaNo,
      'baslik': baslik,
      'aciklama': aciklama,
      'durum': durum.index,
      'tur': tur.index,
      'muvekkil_id': muvekkilId,
      'dava_tarihi': davaTarihi?.millisecondsSinceEpoch,
      'durusma_tarihi': durusmaTarihi?.millisecondsSinceEpoch,
      'mahkeme': mahkeme,
      'hakim': hakim,
      'karsi_taraf': karsiTaraf,
      'karsi_taraf_avukat': karsiTarafAvukat,
      'ucret': ucret,
      'notlar': notlar,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'dosya_yolu': dosyaYolu,
    };
  }

  factory Dava.fromMap(Map<String, dynamic> map) {
    return Dava(
      id: map['id'],
      davaNo: map['dava_no'],
      baslik: map['baslik'],
      aciklama: map['aciklama'],
      durum: DavaDurumu.values[map['durum']],
      tur: DavaTuru.values[map['tur']],
      muvekkilId: map['muvekkil_id'],
      davaTarihi: map['dava_tarihi'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dava_tarihi']) 
          : null,
      durusmaTarihi: map['durusma_tarihi'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['durusma_tarihi']) 
          : null,
      mahkeme: map['mahkeme'],
      hakim: map['hakim'],
      karsiTaraf: map['karsi_taraf'],
      karsiTarafAvukat: map['karsi_taraf_avukat'],
      ucret: map['ucret'],
      notlar: map['notlar'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at']) 
          : null,
      dosyaYolu: map['dosya_yolu'],
    );
  }

  Dava copyWith({
    int? id,
    String? davaNo,
    String? baslik,
    String? aciklama,
    DavaDurumu? durum,
    DavaTuru? tur,
    int? muvekkilId,
    Muvekkil? muvekkil,
    DateTime? davaTarihi,
    DateTime? durusmaTarihi,
    String? mahkeme,
    String? hakim,
    String? karsiTaraf,
    String? karsiTarafAvukat,
    double? ucret,
    String? notlar,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? dosyaYolu,
  }) {
    return Dava(
      id: id ?? this.id,
      davaNo: davaNo ?? this.davaNo,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      durum: durum ?? this.durum,
      tur: tur ?? this.tur,
      muvekkilId: muvekkilId ?? this.muvekkilId,
      muvekkil: muvekkil ?? this.muvekkil,
      davaTarihi: davaTarihi ?? this.davaTarihi,
      durusmaTarihi: durusmaTarihi ?? this.durusmaTarihi,
      mahkeme: mahkeme ?? this.mahkeme,
      hakim: hakim ?? this.hakim,
      karsiTaraf: karsiTaraf ?? this.karsiTaraf,
      karsiTarafAvukat: karsiTarafAvukat ?? this.karsiTarafAvukat,
      ucret: ucret ?? this.ucret,
      notlar: notlar ?? this.notlar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dosyaYolu: dosyaYolu ?? this.dosyaYolu,
    );
  }

  // Dava türü string dönüştürme
  static String davaTuruToString(DavaTuru tur) {
    switch (tur) {
      case DavaTuru.ceza:
        return 'Ceza Hukuku';
      case DavaTuru.medeniHukuk:
        return 'Medeni Hukuk';
      case DavaTuru.borclarHukuku:
        return 'Borçlar Hukuku';
      case DavaTuru.esyaHukuku:
        return 'Eşya Hukuku';
      case DavaTuru.ticaretHukuku:
        return 'Ticaret Hukuku';
      case DavaTuru.sirketlerHukuku:
        return 'Şirketler Hukuku';
      case DavaTuru.isHukuku:
        return 'İş Hukuku';
      case DavaTuru.sosyalGuvenlik:
        return 'Sosyal Güvenlik';
      case DavaTuru.aileHukuku:
        return 'Aile Hukuku';
      case DavaTuru.mirasHukuku:
        return 'Miras Hukuku';
      case DavaTuru.gayrimenkulHukuku:
        return 'Gayrimenkul Hukuku';
      case DavaTuru.fikriMulkiyet:
        return 'Fikri Mülkiyet';
      case DavaTuru.patentMarka:
        return 'Patent & Marka';
      case DavaTuru.vergiHukuku:
        return 'Vergi Hukuku';
      case DavaTuru.idareHukuku:
        return 'İdari Hukuk';
      case DavaTuru.diger:
        return 'Diğer';
    }
  }

  // Dava durumu string dönüştürme
  static String davaDurumuToString(DavaDurumu durum) {
    switch (durum) {
      case DavaDurumu.yeni:
        return 'Yeni';
      case DavaDurumu.devamEden:
        return 'Devam Eden';
      case DavaDurumu.durusmaBekleyen:
        return 'Duruşma Bekleyen';
      case DavaDurumu.kararBekleyen:
        return 'Karar Bekleyen';
      case DavaDurumu.kazanildi:
        return 'Kazanıldı';
      case DavaDurumu.kaybedildi:
        return 'Kaybedildi';
      case DavaDurumu.uzlastirma:
        return 'Uzlaştırma';
      case DavaDurumu.iptal:
        return 'İptal';
    }
  }
}
