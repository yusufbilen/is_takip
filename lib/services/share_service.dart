import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/muvekkil.dart';
import '../models/dava.dart';
import '../models/gorev.dart';
import '../models/etkinlik.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  // Müvekkil bilgilerini paylaş
  Future<void> shareMuvekkil(Muvekkil muvekkil) async {
    final content = '''
MÜVEKKİL BİLGİLERİ
═══════════════════

Ad Soyad: ${muvekkil.tamAd}
E-posta: ${muvekkil.email ?? 'Belirtilmemiş'}
Telefon: ${muvekkil.telefon ?? 'Belirtilmemiş'}
TC Kimlik: ${muvekkil.tc ?? 'Belirtilmemiş'}

Adres:
${muvekkil.adres ?? 'Belirtilmemiş'}

Notlar:
${muvekkil.notlar ?? 'Not bulunmuyor'}

Kayıt Tarihi: ${_formatDate(muvekkil.createdAt)}
''';

    await Share.share(content, subject: 'Müvekkil Bilgileri - ${muvekkil.tamAd}');
  }

  // Dava bilgilerini paylaş
  Future<void> shareDava(Dava dava) async {
    final content = '''
DAVA BİLGİLERİ
══════════════

Dava No: ${dava.davaNo}
Başlık: ${dava.baslik}
Durum: ${dava.durumText}
Tür: ${dava.turText}

Müvekkil: ${dava.muvekkil?.tamAd ?? 'Belirtilmemiş'}

Dava Tarihi: ${dava.davaTarihi != null ? _formatDate(dava.davaTarihi!) : 'Belirtilmemiş'}
Duruşma Tarihi: ${dava.durusmaTarihi != null ? _formatDate(dava.durusmaTarihi!) : 'Belirtilmemiş'}

Mahkeme: ${dava.mahkeme ?? 'Belirtilmemiş'}
Hakim: ${dava.hakim ?? 'Belirtilmemiş'}

Karşı Taraf: ${dava.karsiTaraf ?? 'Belirtilmemiş'}
Karşı Taraf Avukatı: ${dava.karsiTarafAvukat ?? 'Belirtilmemiş'}

Ücret: ${dava.ucret != null ? '₺${dava.ucret!.toStringAsFixed(2)}' : 'Belirtilmemiş'}

Açıklama:
${dava.aciklama ?? 'Açıklama bulunmuyor'}

Notlar:
${dava.notlar ?? 'Not bulunmuyor'}

Oluşturulma Tarihi: ${_formatDate(dava.createdAt)}
''';

    await Share.share(content, subject: 'Dava Bilgileri - ${dava.baslik}');
  }

  // Görev listesini paylaş
  Future<void> shareGorevList(List<Gorev> gorevler) async {
    final content = '''
GÖREV LİSTESİ
═════════════

Toplam Görev: ${gorevler.length}

${gorevler.map((gorev) => '''
${gorev.baslik}
Durum: ${gorev.durumText}
Öncelik: ${gorev.oncelikText}
${gorev.bitisTarihi != null ? 'Son Tarih: ${_formatDate(gorev.bitisTarihi!)}' : ''}
${gorev.aciklama != null ? 'Açıklama: ${gorev.aciklama}' : ''}
${gorev.dava != null ? 'İlgili Dava: ${gorev.dava!.baslik}' : ''}
─────────────────────────────────
''').join('\n')}
''';

    await Share.share(content, subject: 'Görev Listesi');
  }

  // Etkinlik listesini paylaş
  Future<void> shareEtkinlikList(List<Etkinlik> etkinlikler) async {
    final content = '''
ETKİNLİK LİSTESİ
════════════════

Toplam Etkinlik: ${etkinlikler.length}

${etkinlikler.map((etkinlik) => '''
${etkinlik.baslik}
Tür: ${etkinlik.turText}
Tarih: ${_formatDateTime(etkinlik.baslangicTarihi)}
${etkinlik.konum != null ? 'Konum: ${etkinlik.konum}' : ''}
${etkinlik.katilimcilar != null ? 'Katılımcılar: ${etkinlik.katilimcilar}' : ''}
${etkinlik.aciklama != null ? 'Açıklama: ${etkinlik.aciklama}' : ''}
${etkinlik.dava != null ? 'İlgili Dava: ${etkinlik.dava!.baslik}' : ''}
─────────────────────────────────
''').join('\n')}
''';

    await Share.share(content, subject: 'Etkinlik Listesi');
  }

  // PDF olarak dava raporu oluştur ve paylaş
  Future<void> shareDavaReport(Dava dava) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'DAVA RAPORU',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Dava No: ${dava.davaNo}',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Başlık: ${dava.baslik}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'Durum: ${dava.durumText}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'Tür: ${dava.turText}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Müvekkil: ${dava.muvekkil?.tamAd ?? 'Belirtilmemiş'}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'Dava Tarihi: ${dava.davaTarihi != null ? _formatDate(dava.davaTarihi!) : 'Belirtilmemiş'}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'Duruşma Tarihi: ${dava.durusmaTarihi != null ? _formatDate(dava.durusmaTarihi!) : 'Belirtilmemiş'}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Mahkeme: ${dava.mahkeme ?? 'Belirtilmemiş'}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'Hakim: ${dava.hakim ?? 'Belirtilmemiş'}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Karşı Taraf: ${dava.karsiTaraf ?? 'Belirtilmemiş'}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'Karşı Taraf Avukatı: ${dava.karsiTarafAvukat ?? 'Belirtilmemiş'}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Ücret: ${dava.ucret != null ? '₺${dava.ucret!.toStringAsFixed(2)}' : 'Belirtilmemiş'}',
                style: pw.TextStyle(fontSize: 14),
              ),
              if (dava.aciklama != null && dava.aciklama!.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Text(
                  'Açıklama:',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  dava.aciklama!,
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
              if (dava.notlar != null && dava.notlar!.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Text(
                  'Notlar:',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  dava.notlar!,
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
              pw.SizedBox(height: 20),
              pw.Text(
                'Rapor Tarihi: ${_formatDate(DateTime.now())}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/dava_raporu_${dava.davaNo}.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Dava raporu - ${dava.baslik}',
      subject: 'Dava Raporu - ${dava.davaNo}',
    );
  }

  // Genel rapor oluştur ve paylaş
  Future<void> shareGeneralReport({
    required List<Muvekkil> muvekkiller,
    required List<Dava> davalar,
    required List<Gorev> gorevler,
    required List<Etkinlik> etkinlikler,
  }) async {
    final content = '''
AVUKAT İŞ TAKİP RAPORU
══════════════════════

Rapor Tarihi: ${_formatDate(DateTime.now())}

GENEL İSTATİSTİKLER
───────────────────
• Toplam Müvekkil: ${muvekkiller.length}
• Toplam Dava: ${davalar.length}
• Toplam Görev: ${gorevler.length}
• Toplam Etkinlik: ${etkinlikler.length}

AKTİF DAVALAR
─────────────
${davalar.where((d) => d.durum.index < 5).map((d) => '• ${d.baslik} (${d.durumText})').join('\n')}

BEKLEYEN GÖREVLER
─────────────────
${gorevler.where((g) => g.durum != GorevDurumu.tamamlandi).map((g) => '• ${g.baslik} (${g.oncelikText})').join('\n')}

BUGÜNKÜ ETKİNLİKLER
───────────────────
${etkinlikler.where((e) => e.bugun).map((e) => '• ${e.baslik} (${_formatTime(e.baslangicTarihi)})').join('\n')}

GEÇİKEN GÖREVLER
────────────────
${gorevler.where((g) => g.gecikmis).map((g) => '• ${g.baslik} - Son tarih: ${g.bitisTarihi != null ? _formatDate(g.bitisTarihi!) : 'Belirtilmemiş'}').join('\n')}
''';

    await Share.share(content, subject: 'Avukat İş Takip Raporu');
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${_formatDate(date)} $hour:$minute';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
