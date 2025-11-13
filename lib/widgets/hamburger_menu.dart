import 'package:flutter/material.dart';
import '../screens/dilekce_olustur_screen.dart';
import '../screens/dilekce_sablonlari_screen.dart';
import '../screens/hesaplama_screen.dart';
import '../screens/mevzuat_arama_screen.dart';
import '../screens/ictihat_arama_screen.dart';
import '../screens/pratik_bilgiler_screen.dart';
import '../screens/sozlesme_olustur_screen.dart';
import '../screens/yazim_screen.dart';
import '../screens/hukuk_asistani_ai_screen.dart';

class HamburgerMenu extends StatelessWidget {
  const HamburgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hukuk Asistanı',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mevzuat ve Hukuk Araçları',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Dilekçe Bölümü
          _buildExpansionTile(
            context,
            title: 'Dilekçe',
            children: [
              _buildSubItem(context, 'Dilekçe Oluştur', const DilekceOlusturScreen()),
              _buildSubItem(context, 'Dilekçe Şablonları', const DilekceSablonlariScreen()),
              _buildSubItem(context, 'Dilekçe Geçmişi', const DilekceSablonlariScreen()),
            ],
          ),
          
          // Sözleşme Bölümü
          _buildExpansionTile(
            context,
            title: 'Sözleşme',
            children: [
              _buildSubItem(context, 'Sözleşme Oluştur', const SozlesmeOlusturScreen()),
              _buildSubItem(context, 'Sözleşme Şablonları', const SozlesmeOlusturScreen()),
              _buildSubItem(context, 'Sözleşme Türleri', const SozlesmeOlusturScreen()),
            ],
          ),
          
          // Hesaplama Bölümü
          _buildExpansionTile(
            context,
            title: 'Hesaplama',
            children: [
              _buildSubItemWithUrl(context, 'Faiz Hesaplama', 'faiz'),
              _buildSubItemWithUrl(context, 'Tazminat Hesaplama', 'tazminat'),
              _buildSubItemWithUrl(context, 'Nafaka Hesaplama', 'nafaka'),
              _buildSubItemWithUrl(context, 'Süre Hesaplama', 'sure'),
              _buildSubItemWithUrl(context, 'İnfaz Süresi Hesaplama', 'infaz-suresi'),
              _buildSubItemWithUrl(context, 'Miras Saklı Pay Hesaplama', 'miras-sakli-pay'),
              _buildSubItemWithUrl(context, 'Yerel Mahkeme - Hukuk Harç Hesaplama', 'yerel-mahkeme-harc'),
              _buildSubItemWithUrl(context, 'Bölge Adliye Mahkemesi - Hukuk Harç Hesaplama', 'bolge-adliye-harc'),
              _buildSubItemWithUrl(context, 'Yargıtay - Hukuk Harç Hesaplama', 'yargitay-harc'),
              _buildSubItemWithUrl(context, 'İdare Mahkemesi - Harç Hesaplama', 'idare-mahkemesi-harc'),
              _buildSubItemWithUrl(context, 'Bölge İdare Mahkemesi - Harç Hesaplama', 'bolge-idare-harc'),
              _buildSubItemWithUrl(context, 'Vergi Mahkemesi - Harç Hesaplama', 'vergi-mahkemesi-harc'),
              _buildSubItemWithUrl(context, 'Danıştay Dairesi - Harç Hesaplama', 'danistay-harc'),
              _buildSubItemWithUrl(context, 'Vekalet Ücreti Hesaplama', 'vekalet-ucreti'),
              _buildSubItemWithUrl(context, 'Arabuluculuk Tarifesi', 'arabuluculuk-tarifesi'),
              _buildSubItemWithUrl(context, 'Makbuz Hesaplama', 'makbuz'),
            ],
          ),
          
          // Mevzuat Bölümü
          _buildExpansionTile(
            context,
            title: 'Mevzuat',
            children: [
              _buildSubItem(context, 'Kanun', MevzuatAramaScreen(title: 'Kanun', mevzuatTuru: 'Kanun')),
              _buildSubItem(context, 'Cumhurbaşkanlığı Kararnamesi', MevzuatAramaScreen(title: 'Cumhurbaşkanlığı Kararnamesi', mevzuatTuru: 'Cumhurbaşkanlığı Kararnamesi')),
              _buildSubItem(context, 'Kanun Hükmünde Kararname', MevzuatAramaScreen(title: 'Kanun Hükmünde Kararname', mevzuatTuru: 'KHK')),
              _buildSubItem(context, 'Yönetmelik', MevzuatAramaScreen(title: 'Yönetmelik', mevzuatTuru: 'Yönetmelik')),
              _buildSubItem(context, 'Cumhurbaşkanlığı Kararı', MevzuatAramaScreen(title: 'Cumhurbaşkanlığı Kararı', mevzuatTuru: 'Cumhurbaşkanlığı Kararı')),
              _buildSubItem(context, 'Uluslararası Anlaşmalar ve Sözleşmeler', MevzuatAramaScreen(title: 'Uluslararası Anlaşmalar', mevzuatTuru: 'Uluslararası Anlaşma')),
              _buildSubItem(context, 'Bakanlar Kurulu Kararı', MevzuatAramaScreen(title: 'Bakanlar Kurulu Kararı', mevzuatTuru: 'Bakanlar Kurulu Kararı')),
              _buildSubItem(context, 'Mevzuat Arama', MevzuatAramaScreen(title: 'Mevzuat Arama', mevzuatTuru: 'Tümü')),
            ],
          ),
          
          // İçtihat Bölümü
          _buildExpansionTile(
            context,
            title: 'İçtihat',
            children: [
              _buildSubItem(context, 'Yüksek Mahkeme Kararları', IctihatAramaScreen(title: 'Yüksek Mahkeme Kararları')),
              _buildSubItem(context, 'İstinaf Kararları', IctihatAramaScreen(title: 'İstinaf Kararları')),
              _buildSubItem(context, 'Yürütmeyi Durdurma Kararları', IctihatAramaScreen(title: 'Yürütmeyi Durdurma Kararları')),
              _buildSubItem(context, 'Kurum Kararları', IctihatAramaScreen(title: 'Kurum Kararları')),
            ],
          ),
          
          // Yazım Bölümü
          _buildExpansionTile(
            context,
            title: 'Yazım',
            children: [
              _buildSubItem(context, 'Yazım Araçları', const YazimScreen()),
            ],
          ),
          
          // Pratik Bilgiler Bölümü
          _buildExpansionTile(
            context,
            title: 'Pratik Bilgiler',
            children: [
              _buildSubItem(context, 'Genel Bilgiler', PratikBilgilerScreen(title: 'Genel Bilgiler')),
              _buildSubItem(context, 'Avukatlık Kuralları', PratikBilgilerScreen(title: 'Avukatlık Kuralları')),
              _buildSubItem(context, 'Avukatlık Ücret Tarifesi', PratikBilgilerScreen(title: 'Avukatlık Ücret Tarifesi')),
              _buildSubItem(context, 'Döviz Kurları', PratikBilgilerScreen(title: 'Döviz Kurları')),
              _buildSubItem(context, 'Döviz Dönüştürücü', PratikBilgilerScreen(title: 'Döviz Dönüştürücü')),
              _buildSubItem(context, 'Sözlük', PratikBilgilerScreen(title: 'Sözlük')),
            ],
          ),
          
          // Hukuk Asistanı Bölümü
          _buildExpansionTile(
            context,
            title: 'Hukuk Asistanı',
            children: [
              _buildSubItem(context, 'İçtihat Asistanı', HukukAsistaniAIScreen(title: 'İçtihat Asistanı', asistanTuru: 'ictihat')),
              _buildSubItem(context, 'Mevzuat Asistanı', HukukAsistaniAIScreen(title: 'Mevzuat Asistanı', asistanTuru: 'mevzuat')),
              _buildSubItem(context, 'Dilekçe Asistanı', HukukAsistaniAIScreen(title: 'Dilekçe Asistanı', asistanTuru: 'dilekce')),
              _buildSubItem(context, 'Sözleşme Asistanı', HukukAsistaniAIScreen(title: 'Sözleşme Asistanı', asistanTuru: 'sozlesme')),
            ],
          ),
          
          // Diğer Araçlar
          _buildExpansionTile(
            context,
            title: 'Diğer Araçlar',
            children: [
              _buildSubItemWithUrl(context, 'Dava Takvimi', 'takvim'),
              _buildSubItemWithUrl(context, 'Makaleler', 'makaleler'),
              _buildSubItemWithUrl(context, 'Yardım', 'yardim'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconColor: Colors.white70,
      collapsedIconColor: Colors.white54,
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      childrenPadding: const EdgeInsets.only(left: 24, right: 16, bottom: 4),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      children: children,
    );
  }

  Widget _buildSubItem(BuildContext context, String title, Widget screen) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSubItemWithUrl(BuildContext context, String title, String hesaplamaTuru) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HesaplamaScreen(
              hesaplamaTuru: hesaplamaTuru,
              title: title,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
