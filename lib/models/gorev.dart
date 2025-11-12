import 'dava.dart';

enum GorevDurumu {
  bekleyen,
  devamEden,
  tamamlandi,
  iptal
}

enum GorevOnceligi {
  dusuk,
  normal,
  yuksek,
  acil
}

class Gorev {
  final int? id;
  final String baslik;
  final String? aciklama;
  final GorevDurumu durum;
  final GorevOnceligi oncelik;
  final int? davaId;
  final Dava? dava;
  final DateTime? baslangicTarihi;
  final DateTime? bitisTarihi;
  final DateTime? tamamlanmaTarihi;
  final bool hatirlaticiVar;
  final DateTime? hatirlaticiTarihi;
  final String? notlar;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Gorev({
    this.id,
    required this.baslik,
    this.aciklama,
    required this.durum,
    required this.oncelik,
    this.davaId,
    this.dava,
    this.baslangicTarihi,
    this.bitisTarihi,
    this.tamamlanmaTarihi,
    required this.hatirlaticiVar,
    this.hatirlaticiTarihi,
    this.notlar,
    required this.createdAt,
    this.updatedAt,
  });

  String get durumText {
    switch (durum) {
      case GorevDurumu.bekleyen:
        return 'Bekleyen';
      case GorevDurumu.devamEden:
        return 'Devam Eden';
      case GorevDurumu.tamamlandi:
        return 'Tamamlandı';
      case GorevDurumu.iptal:
        return 'İptal';
    }
  }

  String get oncelikText {
    switch (oncelik) {
      case GorevOnceligi.dusuk:
        return 'Düşük';
      case GorevOnceligi.normal:
        return 'Normal';
      case GorevOnceligi.yuksek:
        return 'Yüksek';
      case GorevOnceligi.acil:
        return 'Acil';
    }
  }

  bool get gecikmis {
    if (bitisTarihi == null || durum == GorevDurumu.tamamlandi) return false;
    return DateTime.now().isAfter(bitisTarihi!);
  }

  bool get bugunBitiyor {
    if (bitisTarihi == null) return false;
    final today = DateTime.now();
    final deadline = bitisTarihi!;
    return today.year == deadline.year && 
           today.month == deadline.month && 
           today.day == deadline.day;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baslik': baslik,
      'aciklama': aciklama,
      'durum': durum.index,
      'oncelik': oncelik.index,
      'dava_id': davaId,
      'baslangic_tarihi': baslangicTarihi?.millisecondsSinceEpoch,
      'bitis_tarihi': bitisTarihi?.millisecondsSinceEpoch,
      'tamamlanma_tarihi': tamamlanmaTarihi?.millisecondsSinceEpoch,
      'hatirlatici_var': hatirlaticiVar ? 1 : 0,
      'hatirlatici_tarihi': hatirlaticiTarihi?.millisecondsSinceEpoch,
      'notlar': notlar,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Gorev.fromMap(Map<String, dynamic> map) {
    return Gorev(
      id: map['id'],
      baslik: map['baslik'],
      aciklama: map['aciklama'],
      durum: GorevDurumu.values[map['durum']],
      oncelik: GorevOnceligi.values[map['oncelik']],
      davaId: map['dava_id'],
      baslangicTarihi: map['baslangic_tarihi'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['baslangic_tarihi']) 
          : null,
      bitisTarihi: map['bitis_tarihi'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['bitis_tarihi']) 
          : null,
      tamamlanmaTarihi: map['tamamlanma_tarihi'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['tamamlanma_tarihi']) 
          : null,
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

  Gorev copyWith({
    int? id,
    String? baslik,
    String? aciklama,
    GorevDurumu? durum,
    GorevOnceligi? oncelik,
    int? davaId,
    Dava? dava,
    DateTime? baslangicTarihi,
    DateTime? bitisTarihi,
    DateTime? tamamlanmaTarihi,
    bool? hatirlaticiVar,
    DateTime? hatirlaticiTarihi,
    String? notlar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Gorev(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      durum: durum ?? this.durum,
      oncelik: oncelik ?? this.oncelik,
      davaId: davaId ?? this.davaId,
      dava: dava ?? this.dava,
      baslangicTarihi: baslangicTarihi ?? this.baslangicTarihi,
      bitisTarihi: bitisTarihi ?? this.bitisTarihi,
      tamamlanmaTarihi: tamamlanmaTarihi ?? this.tamamlanmaTarihi,
      hatirlaticiVar: hatirlaticiVar ?? this.hatirlaticiVar,
      hatirlaticiTarihi: hatirlaticiTarihi ?? this.hatirlaticiTarihi,
      notlar: notlar ?? this.notlar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
