import 'dava.dart';

enum EtkinlikTuru {
  durusma,
  toplanti,
  telefonGorusmesi,
  email,
  dosyaHazirlama,
  arastirma,
  diger
}

class Etkinlik {
  final int? id;
  final String baslik;
  final String? aciklama;
  final EtkinlikTuru tur;
  final DateTime baslangicTarihi;
  final DateTime? bitisTarihi;
  final int? davaId;
  final Dava? dava;
  final String? konum;
  final String? katilimcilar;
  final bool hatirlaticiVar;
  final DateTime? hatirlaticiTarihi;
  final String? notlar;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Etkinlik({
    this.id,
    required this.baslik,
    this.aciklama,
    required this.tur,
    required this.baslangicTarihi,
    this.bitisTarihi,
    this.davaId,
    this.dava,
    this.konum,
    this.katilimcilar,
    required this.hatirlaticiVar,
    this.hatirlaticiTarihi,
    this.notlar,
    required this.createdAt,
    this.updatedAt,
  });

  String get turText {
    switch (tur) {
      case EtkinlikTuru.durusma:
        return 'Duruşma';
      case EtkinlikTuru.toplanti:
        return 'Toplantı';
      case EtkinlikTuru.telefonGorusmesi:
        return 'Telefon Görüşmesi';
      case EtkinlikTuru.email:
        return 'E-posta';
      case EtkinlikTuru.dosyaHazirlama:
        return 'Dosya Hazırlama';
      case EtkinlikTuru.arastirma:
        return 'Araştırma';
      case EtkinlikTuru.diger:
        return 'Diğer';
    }
  }

  bool get bugun {
    final today = DateTime.now();
    return baslangicTarihi.year == today.year && 
           baslangicTarihi.month == today.month && 
           baslangicTarihi.day == today.day;
  }

  bool get yarin {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return baslangicTarihi.year == tomorrow.year && 
           baslangicTarihi.month == tomorrow.month && 
           baslangicTarihi.day == tomorrow.day;
  }

  bool get gecmis {
    return baslangicTarihi.isBefore(DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baslik': baslik,
      'aciklama': aciklama,
      'tur': tur.index,
      'baslangic_tarihi': baslangicTarihi.millisecondsSinceEpoch,
      'bitis_tarihi': bitisTarihi?.millisecondsSinceEpoch,
      'dava_id': davaId,
      'konum': konum,
      'katilimcilar': katilimcilar,
      'hatirlatici_var': hatirlaticiVar ? 1 : 0,
      'hatirlatici_tarihi': hatirlaticiTarihi?.millisecondsSinceEpoch,
      'notlar': notlar,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Etkinlik.fromMap(Map<String, dynamic> map) {
    return Etkinlik(
      id: map['id'],
      baslik: map['baslik'],
      aciklama: map['aciklama'],
      tur: EtkinlikTuru.values[map['tur']],
      baslangicTarihi: DateTime.fromMillisecondsSinceEpoch(map['baslangic_tarihi']),
      bitisTarihi: map['bitis_tarihi'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['bitis_tarihi']) 
          : null,
      davaId: map['dava_id'],
      konum: map['konum'],
      katilimcilar: map['katilimcilar'],
      hatirlaticiVar: map['hatirlatici_var'] == 1,
      hatirlaticiTarihi: map['hatirlatici_tarihi'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['hatirlatici_tarihi']) 
          : null,
      notlar: map['notlar'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at']) 
          : null,
    );
  }

  Etkinlik copyWith({
    int? id,
    String? baslik,
    String? aciklama,
    EtkinlikTuru? tur,
    DateTime? baslangicTarihi,
    DateTime? bitisTarihi,
    int? davaId,
    Dava? dava,
    String? konum,
    String? katilimcilar,
    bool? hatirlaticiVar,
    DateTime? hatirlaticiTarihi,
    String? notlar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Etkinlik(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      tur: tur ?? this.tur,
      baslangicTarihi: baslangicTarihi ?? this.baslangicTarihi,
      bitisTarihi: bitisTarihi ?? this.bitisTarihi,
      davaId: davaId ?? this.davaId,
      dava: dava ?? this.dava,
      konum: konum ?? this.konum,
      katilimcilar: katilimcilar ?? this.katilimcilar,
      hatirlaticiVar: hatirlaticiVar ?? this.hatirlaticiVar,
      hatirlaticiTarihi: hatirlaticiTarihi ?? this.hatirlaticiTarihi,
      notlar: notlar ?? this.notlar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
