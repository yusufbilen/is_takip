class Muvekkil {
  final int? id;
  final String ad;
  final String soyad;
  final String? email;
  final String? telefon;
  final String? adres;
  final String? tc;
  final String? notlar;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? avatar;

  Muvekkil({
    this.id,
    required this.ad,
    required this.soyad,
    this.email,
    this.telefon,
    this.adres,
    this.tc,
    this.notlar,
    required this.createdAt,
    this.updatedAt,
    this.avatar,
  });

  String get tamAd => '$ad $soyad';
  String get basHarfler => '${ad.isNotEmpty ? ad[0] : ''}${soyad.isNotEmpty ? soyad[0] : ''}'.toUpperCase();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ad': ad,
      'soyad': soyad,
      'email': email,
      'telefon': telefon,
      'adres': adres,
      'tc_kimlik': tc,
      'notlar': notlar,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'avatar': avatar,
    };
  }

  factory Muvekkil.fromMap(Map<String, dynamic> map) {
    return Muvekkil(
      id: map['id'],
      ad: map['ad'],
      soyad: map['soyad'],
      email: map['email'],
      telefon: map['telefon'],
      adres: map['adres'],
      tc: map['tc_kimlik'],
      notlar: map['notlar'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at']) 
          : null,
      avatar: map['avatar'],
    );
  }

  Muvekkil copyWith({
    int? id,
    String? ad,
    String? soyad,
    String? email,
    String? telefon,
    String? adres,
    String? tc,
    String? notlar,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatar,
  }) {
    return Muvekkil(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      soyad: soyad ?? this.soyad,
      email: email ?? this.email,
      telefon: telefon ?? this.telefon,
      adres: adres ?? this.adres,
      tc: tc ?? this.tc,
      notlar: notlar ?? this.notlar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatar: avatar ?? this.avatar,
    );
  }
}
