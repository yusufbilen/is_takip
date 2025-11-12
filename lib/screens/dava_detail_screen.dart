import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dava.dart';
import '../screens/muvekkil_detail_screen.dart';
import '../screens/dava_form_screen.dart';
import '../providers/app_provider.dart';

class DavaDetailScreen extends StatelessWidget {
  final Dava dava;

  const DavaDetailScreen({super.key, required this.dava});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Koyu Lacivert
              Color(0xFF1E293B), // Koyu Mavi
              Color(0xFF334155), // Orta Koyu
              Color(0xFF0F172A), // Koyu Lacivert Background
            ],
            stops: [0.0, 0.3, 0.6, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildMuvekkilCard(context),
            const SizedBox(height: 20),
            _buildDavaInfoCard(),
            const SizedBox(height: 20),
            _buildMahkemeInfoCard(),
            const SizedBox(height: 20),
            _buildKarsiTarafCard(),
            const SizedBox(height: 20),
            _buildMaliInfoCard(),
            const SizedBox(height: 20),
            _buildNotlarCard(),
            const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white, // Beyaz başlık
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Dava Detayı',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white, // Beyaz başlık
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _editDava(context),
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _deleteDava(context),
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _shareDava(context),
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Koyu lacivert kart arka planı
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTurColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dava.turText,
                  style: TextStyle(
                    color: _getTurColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getDurumColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dava.durumText,
                  style: TextStyle(
                    color: _getDurumColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            dava.baslik,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Beyaz yazı
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dava No: ${dava.davaNo}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          if (dava.aciklama != null) ...[
            const SizedBox(height: 12),
            Text(
              dava.aciklama!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMuvekkilCard(BuildContext context) {
    if (dava.muvekkil == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.person_outline, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              'Müvekkil bilgisi bulunamadı',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Koyu lacivert kart arka planı
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: const Text(
                  'Müvekkil Bilgileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Beyaz yazı
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showMuvekkilProfile(context),
                icon: const Icon(Icons.person, size: 16),
                label: const Text('Profil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF0F172A).withOpacity(0.1),
                child: Text(
                  dava.muvekkil!.basHarfler,
                  style: const TextStyle(
                    color: Colors.white, // Beyaz yazı
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dava.muvekkil!.tamAd,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Beyaz yazı
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'TC: ${dava.muvekkil!.tc ?? 'Belirtilmemiş'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Tel: ${dava.muvekkil!.telefon ?? 'Belirtilmemiş'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDavaInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Koyu lacivert kart arka planı
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dava Bilgileri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Beyaz yazı
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Dava Türü', dava.turText, Icons.category),
          if (dava.davaTarihi != null)
            _buildInfoRow('Dava Tarihi', _formatDate(dava.davaTarihi!), Icons.calendar_today),
          if (dava.durusmaTarihi != null)
            _buildInfoRow('Duruşma Tarihi', _formatDate(dava.durusmaTarihi!), Icons.event),
        ],
      ),
    );
  }

  Widget _buildMahkemeInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Koyu lacivert kart arka planı
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mahkeme Bilgileri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Beyaz yazı
            ),
          ),
          const SizedBox(height: 16),
          if (dava.mahkeme != null)
            _buildInfoRow('Mahkeme', dava.mahkeme!, Icons.gavel),
          if (dava.hakim != null)
            _buildInfoRow('Hakim', dava.hakim!, Icons.person),
        ],
      ),
    );
  }

  Widget _buildKarsiTarafCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Koyu lacivert kart arka planı
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Karşı Taraf Bilgileri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Beyaz yazı
            ),
          ),
          const SizedBox(height: 16),
          if (dava.karsiTaraf != null)
            _buildInfoRow('Karşı Taraf', dava.karsiTaraf!, Icons.person_outline),
          if (dava.karsiTarafAvukat != null)
            _buildInfoRow('Karşı Taraf Avukatı', dava.karsiTarafAvukat!, Icons.people),
        ],
      ),
    );
  }

  Widget _buildMaliInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Koyu lacivert kart arka planı
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mali Bilgiler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Beyaz yazı
            ),
          ),
          const SizedBox(height: 16),
          if (dava.ucret != null)
            _buildInfoRow('Ücret', '${dava.ucret!.toStringAsFixed(2)} TL', Icons.monetization_on),
        ],
      ),
    );
  }

  Widget _buildNotlarCard() {
    if (dava.notlar == null || dava.notlar!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Koyu lacivert kart arka planı
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notlar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Beyaz yazı
            ),
          ),
          const SizedBox(height: 16),
          Text(
            dava.notlar!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0F172A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // Beyaz yazı
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTurColor() {
    switch (dava.tur) {
      case DavaTuru.ceza:
        return const Color(0xFFEF4444);
      case DavaTuru.medeniHukuk:
        return const Color(0xFF3B82F6);
      case DavaTuru.borclarHukuku:
        return const Color(0xFF1E40AF);
      case DavaTuru.esyaHukuku:
        return const Color(0xFF2563EB);
      case DavaTuru.ticaretHukuku:
        return const Color(0xFFF59E0B);
      case DavaTuru.sirketlerHukuku:
        return const Color(0xFFD97706);
      case DavaTuru.isHukuku:
        return const Color(0xFF10B981);
      case DavaTuru.sosyalGuvenlik:
        return const Color(0xFF059669);
      case DavaTuru.aileHukuku:
        return const Color(0xFF059669);
      case DavaTuru.mirasHukuku:
        return const Color(0xFF06B6D4);
      case DavaTuru.gayrimenkulHukuku:
        return const Color(0xFF84CC16);
      case DavaTuru.fikriMulkiyet:
        return const Color(0xFF0F172A);
      case DavaTuru.patentMarka:
        return const Color(0xFF7C3AED);
      case DavaTuru.vergiHukuku:
        return const Color(0xFFF97316);
      case DavaTuru.idareHukuku:
        return const Color(0xFF374151);
      case DavaTuru.diger:
        return const Color(0xFF6B7280);
    }
  }

  Color _getDurumColor() {
    switch (dava.durum) {
      case DavaDurumu.yeni:
        return const Color(0xFF3B82F6);
      case DavaDurumu.devamEden:
        return const Color(0xFFF59E0B);
      case DavaDurumu.durusmaBekleyen:
        return const Color(0xFF374151);
      case DavaDurumu.kararBekleyen:
        return const Color(0xFF06B6D4);
      case DavaDurumu.kazanildi:
        return const Color(0xFF10B981);
      case DavaDurumu.kaybedildi:
        return const Color(0xFFEF4444);
      case DavaDurumu.uzlastirma:
        return const Color(0xFF059669);
      case DavaDurumu.iptal:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showMuvekkilProfile(BuildContext context) {
    if (dava.muvekkil == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MuvekkilDetailScreen(
          muvekkil: dava.muvekkil!,
          davalar: [], // Bu müvekkil ile ilgili davalar
          gorevler: [], // Bu müvekkil ile ilgili görevler
          etkinlikler: [], // Bu müvekkil ile ilgili etkinlikler
        ),
      ),
    );
  }

  void _shareDava(BuildContext context) {
    final shareText = '''
${dava.baslik}

Dava No: ${dava.davaNo}
Dava Türü: ${dava.turText}
Durum: ${dava.durumText}
${dava.muvekkil != null ? 'Müvekkil: ${dava.muvekkil!.tamAd}' : ''}
${dava.mahkeme != null ? 'Mahkeme: ${dava.mahkeme}' : ''}
${dava.davaTarihi != null ? 'Dava Tarihi: ${_formatDate(dava.davaTarihi!)}' : ''}
''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dava bilgileri kopyalandı'),
        action: SnackBarAction(
          label: 'Paylaş',
          onPressed: () {
            // Share functionality would go here
          },
        ),
      ),
    );
  }

  void _editDava(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DavaFormScreen(dava: dava),
      ),
    );
  }

  void _deleteDava(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dava Sil'),
          content: Text('${dava.baslik} adlı davayı silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if (dava.id != null) {
                  final appProvider = Provider.of<AppProvider>(context, listen: false);
                  appProvider.deleteDava(dava.id!);
                  Navigator.of(context).pop(); // Dialog'u kapat
                  Navigator.of(context).pop(); // Detail screen'i kapat
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dava başarıyla silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
