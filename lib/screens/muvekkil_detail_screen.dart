import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../models/muvekkil.dart';
import '../models/dava.dart';
import '../models/gorev.dart';
import '../models/etkinlik.dart';
import '../widgets/dava_card.dart';
import '../widgets/gorev_card.dart';
import '../widgets/etkinlik_card.dart';
import '../screens/muvekkil_form_screen.dart';
import '../providers/app_provider.dart';

class MuvekkilDetailScreen extends StatelessWidget {
  final Muvekkil muvekkil;
  final List<Dava> davalar;
  final List<Gorev> gorevler;
  final List<Etkinlik> etkinlikler;

  const MuvekkilDetailScreen({
    super.key,
    required this.muvekkil,
    required this.davalar,
    required this.gorevler,
    required this.etkinlikler,
  });

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
        child:
        CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildMuvekkilInfo(),
                const SizedBox(height: 20),
                _buildStatsCards(),
                const SizedBox(height: 20),
                _buildDavalarSection(context),
                const SizedBox(height: 20),
                _buildGorevlerSection(context),
                const SizedBox(height: 20),
                _buildEtkinliklerSection(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF0F172A),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          onPressed: () => _editMuvekkil(context),
          icon: const Icon(Icons.edit, color: Colors.white),
        ),
        IconButton(
          onPressed: () => _deleteMuvekkil(context),
          icon: const Icon(Icons.delete, color: Colors.white),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '${muvekkil.ad} ${muvekkil.soyad}',
          style: const TextStyle(
            color: Colors.white, // Beyaz başlık
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A), // Indigo
                Color(0xFF374151), // Violet
                Color(0xFF059669), // Pink
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    '${muvekkil.ad[0]}${muvekkil.soyad[0]}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A), // Koyu lacivert arka plan
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Müvekkil Profili',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMuvekkilInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
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
            'Kişisel Bilgiler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'Ad Soyad', '${muvekkil.ad} ${muvekkil.soyad}'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.credit_card, 'TC Kimlik No', muvekkil.tc ?? 'Belirtilmemiş'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, 'Telefon', muvekkil.telefon ?? 'Belirtilmemiş'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email, 'E-posta', muvekkil.email ?? 'Belirtilmemiş'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'Adres', muvekkil.adres ?? 'Belirtilmemiş'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Toplam Dava',
              davalar.length.toString(),
              Icons.gavel,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Aktif Görev',
              gorevler.where((g) => g.durum == GorevDurumu.bekleyen || g.durum == GorevDurumu.devamEden).length.toString(),
              Icons.assignment,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Yaklaşan Etkinlik',
              etkinlikler.where((e) => e.baslangicTarihi.isAfter(DateTime.now())).length.toString(),
              Icons.event,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Koyu lacivert arka plan
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDavalarSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Davalar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => _showAllDavalar(context),
                child: const Text('Tümünü Gör', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (davalar.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Koyu lacivert arka plan
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.gavel_outlined, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Henüz dava eklenmemiş',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          else
            AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: davalar.take(3).map((dava) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DavaCard(dava: dava),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGorevlerSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Görevler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => _showAllGorevler(context),
                child: const Text('Tümünü Gör', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (gorevler.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Koyu lacivert arka plan
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.assignment_outlined, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Henüz görev eklenmemiş',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          else
            AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: gorevler.take(3).map((gorev) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GorevCard(gorev: gorev),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEtkinliklerSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Etkinlikler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () => _showAllEtkinlikler(context),
                child: const Text('Tümünü Gör', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (etkinlikler.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Koyu lacivert arka plan
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.event_outlined, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Henüz etkinlik eklenmemiş',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          else
            AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: etkinlikler.take(3).map((etkinlik) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: EtkinlikCard(etkinlik: etkinlik),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _shareMuvekkil(BuildContext context) {
    final shareText = '''
${muvekkil.ad} ${muvekkil.soyad} - Müvekkil Bilgileri

📞 Telefon: ${muvekkil.telefon}
📧 E-posta: ${muvekkil.email}
🏠 Adres: ${muvekkil.adres}
🆔 TC: ${muvekkil.tc}

📊 İstatistikler:
• Toplam Dava: ${davalar.length}
• Aktif Görev: ${gorevler.where((g) => g.durum == GorevDurumu.bekleyen || g.durum == GorevDurumu.devamEden).length}
• Yaklaşan Etkinlik: ${etkinlikler.where((e) => e.baslangicTarihi.isAfter(DateTime.now())).length}
''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Müvekkil bilgileri kopyalandı'),
        action: SnackBarAction(
          label: 'Paylaş',
          onPressed: () {
            // Share functionality would go here
          },
        ),
      ),
    );
  }

  void _showAllDavalar(BuildContext context) {
    // Navigate to dava list with this client filter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tüm davalar gösteriliyor')),
    );
  }

  void _showAllGorevler(BuildContext context) {
    // Navigate to gorev list with this client filter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tüm görevler gösteriliyor')),
    );
  }

  void _showAllEtkinlikler(BuildContext context) {
    // Navigate to etkinlik list with this client filter
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tüm etkinlikler gösteriliyor')),
    );
  }

  void _editMuvekkil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MuvekkilFormScreen(muvekkil: muvekkil),
      ),
    );
  }

  void _deleteMuvekkil(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Müvekkil Sil'),
          content: Text('${muvekkil.ad} ${muvekkil.soyad} adlı müvekkili silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                final appProvider = Provider.of<AppProvider>(context, listen: false);
                appProvider.deleteMuvekkil(muvekkil.id!);
                Navigator.of(context).pop(); // Dialog'u kapat
                Navigator.of(context).pop(); // Detail screen'i kapat
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Müvekkil başarıyla silindi'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
