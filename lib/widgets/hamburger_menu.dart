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
          _buildSectionTitle('Dilekçe'),
          _buildMenuItem(
            context,
            icon: Icons.description,
            title: 'Dilekçe Oluştur',
            subtitle: 'Hukuki dilekçe hazırlama',
            screen: const DilekceOlusturScreen(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.folder_open,
            title: 'Dilekçe Şablonları',
            subtitle: 'Hazır dilekçe şablonları',
            screen: const DilekceSablonlariScreen(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.history,
            title: 'Dilekçe Geçmişi',
            subtitle: 'Oluşturduğunuz dilekçeler',
            screen: const DilekceSablonlariScreen(), // Geçici olarak aynı ekran
          ),
          
          const Divider(color: Colors.white24),
          
          // Sözleşme Bölümü
          _buildSectionTitle('Sözleşme'),
          _buildMenuItem(
            context,
            icon: Icons.description,
            title: 'Sözleşme Oluştur',
            subtitle: 'Hukuki sözleşme hazırlama',
            screen: const SozlesmeOlusturScreen(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.folder_special,
            title: 'Sözleşme Şablonları',
            subtitle: 'Hazır sözleşme şablonları',
            screen: const SozlesmeOlusturScreen(), // Geçici
          ),
          _buildMenuItem(
            context,
            icon: Icons.category,
            title: 'Sözleşme Türleri',
            subtitle: 'Kira, satış, hizmet vb.',
            screen: const SozlesmeOlusturScreen(), // Geçici
          ),
          
          const Divider(color: Colors.white24),
          
          // Hesaplama Bölümü
          _buildSectionTitle('Hesaplama'),
          _buildMenuItem(
            context,
            icon: Icons.calculate,
            title: 'Faiz Hesaplama',
            subtitle: 'Yasal faiz hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hukuk-asistani/hesaplama/faiz',
          ),
          _buildMenuItem(
            context,
            icon: Icons.trending_up,
            title: 'Tazminat Hesaplama',
            subtitle: 'Maddi ve manevi tazminat',
            url: 'https://mevzuat.sinerjias.com.tr/hukuk-asistani/hesaplama/tazminat',
          ),
          _buildMenuItem(
            context,
            icon: Icons.account_balance_wallet,
            title: 'Nafaka Hesaplama',
            subtitle: 'Nafaka miktarı hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hukuk-asistani/hesaplama/nafaka',
          ),
          _buildMenuItem(
            context,
            icon: Icons.calendar_today,
            title: 'Süre Hesaplama',
            subtitle: 'Yasal süre hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hukuk-asistani/hesaplama/sure',
          ),
          _buildMenuItem(
            context,
            icon: Icons.timer,
            title: 'İnfaz Süresi Hesaplama',
            subtitle: 'İnfaz süresi hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hesaplama/infaz-suresi',
          ),
          _buildMenuItem(
            context,
            icon: Icons.account_balance,
            title: 'Miras Saklı Pay Hesaplama',
            subtitle: 'Miras saklı pay hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hesaplama/miras-sakli-pay',
          ),
          _buildMenuItem(
            context,
            icon: Icons.gavel,
            title: 'Yerel Mahkeme - Hukuk Harç Hesaplama',
            subtitle: 'Yerel mahkeme harç hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hesaplama/yerel-mahkeme-harc',
          ),
          _buildMenuItem(
            context,
            icon: Icons.balance,
            title: 'Bölge Adliye Mahkemesi - Hukuk Harç Hesaplama',
            subtitle: 'İstinaf harç hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hesaplama/bolge-adliye-harc',
          ),
          _buildMenuItem(
            context,
            icon: Icons.scale,
            title: 'Yargıtay - Hukuk Harç Hesaplama',
            subtitle: 'Yargıtay harç hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hesaplama/yargitay-harc',
          ),
          _buildMenuItem(
            context,
            icon: Icons.business,
            title: 'İdare Mahkemesi - Harç Hesaplama',
            subtitle: 'İdare mahkemesi harç hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hesaplama/idare-mahkemesi-harc',
          ),
          _buildMenuItem(
            context,
            icon: Icons.business,
            title: 'Bölge İdare Mahkemesi - Harç Hesaplama',
            subtitle: 'Bölge idare mahkemesi harç hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hesaplama/bolge-idare-harc',
          ),
          _buildMenuItem(
            context,
            icon: Icons.receipt,
            title: 'Vergi Mahkemesi - Harç Hesaplama',
            subtitle: 'Vergi mahkemesi harç hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hesaplama/vergi-mahkemesi-harc',
          ),
          _buildMenuItem(
            context,
            icon: Icons.account_balance,
            title: 'Danıştay Dairesi - Harç Hesaplama',
            subtitle: 'Danıştay harç hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hesaplama/danistay-harc',
          ),
          _buildMenuItem(
            context,
            icon: Icons.attach_money,
            title: 'Vekalet Ücreti Hesaplama',
            subtitle: 'Vekalet ücreti hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hesaplama/vekalet-ucreti',
          ),
          _buildMenuItem(
            context,
            icon: Icons.handshake,
            title: 'Arabuluculuk Tarifesi',
            subtitle: 'Arabuluculuk ücret tarifesi',
            url: 'https://mevzuat.sinerjias.com.tr/hesaplama/arabuluculuk-tarifesi',
          ),
          _buildMenuItem(
            context,
            icon: Icons.receipt_long,
            title: 'Makbuz Hesaplama',
            subtitle: 'Makbuz hesaplama',
            url: 'https://mevzuat.sinerjias.com.tr/hesaplama/makbuz',
          ),
          
          const Divider(color: Colors.white24),
          
          // Mevzuat Bölümü
          _buildSectionTitle('Mevzuat'),
          _buildMenuItem(
            context,
            icon: Icons.book,
            title: 'Kanun',
            subtitle: 'Türk hukuk kanunları',
            screen: MevzuatAramaScreen(title: 'Kanun', mevzuatTuru: 'Kanun'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.description,
            title: 'Cumhurbaşkanlığı Kararnamesi',
            subtitle: 'Cumhurbaşkanlığı kararnameleri',
            screen: MevzuatAramaScreen(title: 'Cumhurbaşkanlığı Kararnamesi', mevzuatTuru: 'Cumhurbaşkanlığı Kararnamesi'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.article,
            title: 'Kanun Hükmünde Kararname',
            subtitle: 'KHK mevzuatı',
            screen: MevzuatAramaScreen(title: 'Kanun Hükmünde Kararname', mevzuatTuru: 'KHK'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.gavel,
            title: 'Yönetmelik',
            subtitle: 'Yönetmelik ve tüzükler',
            screen: MevzuatAramaScreen(title: 'Yönetmelik', mevzuatTuru: 'Yönetmelik'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.verified,
            title: 'Cumhurbaşkanlığı Kararı',
            subtitle: 'Cumhurbaşkanlığı kararları',
            screen: MevzuatAramaScreen(title: 'Cumhurbaşkanlığı Kararı', mevzuatTuru: 'Cumhurbaşkanlığı Kararı'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.public,
            title: 'Uluslararası Anlaşmalar ve Sözleşmeler',
            subtitle: 'Uluslararası anlaşmalar',
            screen: MevzuatAramaScreen(title: 'Uluslararası Anlaşmalar', mevzuatTuru: 'Uluslararası Anlaşma'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.group,
            title: 'Bakanlar Kurulu Kararı',
            subtitle: 'Bakanlar kurulu kararları',
            screen: MevzuatAramaScreen(title: 'Bakanlar Kurulu Kararı', mevzuatTuru: 'Bakanlar Kurulu Kararı'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.search,
            title: 'Mevzuat Arama',
            subtitle: 'Mevzuat içinde arama',
            screen: MevzuatAramaScreen(title: 'Mevzuat Arama', mevzuatTuru: 'Tümü'),
          ),
          
          const Divider(color: Colors.white24),
          
          // İçtihat Bölümü
          _buildSectionTitle('İçtihat'),
          _buildMenuItem(
            context,
            icon: Icons.gavel,
            title: 'Yüksek Mahkeme Kararları',
            subtitle: 'Yargıtay ve Danıştay kararları',
            screen: IctihatAramaScreen(title: 'Yüksek Mahkeme Kararları'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.balance,
            title: 'İstinaf Kararları',
            subtitle: 'Bölge adliye mahkemesi kararları',
            screen: IctihatAramaScreen(title: 'İstinaf Kararları'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.pause_circle,
            title: 'Yürütmeyi Durdurma Kararları',
            subtitle: 'Yürütmeyi durdurma kararları',
            screen: IctihatAramaScreen(title: 'Yürütmeyi Durdurma Kararları'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.business,
            title: 'Kurum Kararları',
            subtitle: 'Kurum ve kuruluş kararları',
            screen: IctihatAramaScreen(title: 'Kurum Kararları'),
          ),
          
          const Divider(color: Colors.white24),
          
          // Yazım Bölümü
          _buildSectionTitle('Yazım'),
          _buildMenuItem(
            context,
            icon: Icons.edit,
            title: 'Yazım Araçları',
            subtitle: 'Hukuki yazım araçları',
            screen: const YazimScreen(),
          ),
          
          const Divider(color: Colors.white24),
          
          // Pratik Bilgiler Bölümü
          _buildSectionTitle('Pratik Bilgiler'),
          _buildMenuItem(
            context,
            icon: Icons.info,
            title: 'Genel Bilgiler',
            subtitle: 'Genel hukuk bilgileri',
            screen: PratikBilgilerScreen(title: 'Genel Bilgiler'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.rule,
            title: 'Avukatlık Kuralları',
            subtitle: 'Avukatlık meslek kuralları',
            screen: PratikBilgilerScreen(title: 'Avukatlık Kuralları'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.attach_money,
            title: 'Avukatlık Ücret Tarifesi',
            subtitle: 'Avukatlık ücret tarifesi',
            screen: PratikBilgilerScreen(title: 'Avukatlık Ücret Tarifesi'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.trending_up,
            title: 'Döviz Kurları',
            subtitle: 'Güncel döviz kurları',
            screen: PratikBilgilerScreen(title: 'Döviz Kurları'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.swap_horiz,
            title: 'Döviz Dönüştürücü',
            subtitle: 'Döviz dönüştürme aracı',
            screen: PratikBilgilerScreen(title: 'Döviz Dönüştürücü'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.book,
            title: 'Sözlük',
            subtitle: 'Hukuk terimleri sözlüğü',
            screen: PratikBilgilerScreen(title: 'Sözlük'),
          ),
          
          const Divider(color: Colors.white24),
          
          // Hukuk Asistanı Bölümü
          _buildSectionTitle('Hukuk Asistanı'),
          _buildMenuItem(
            context,
            icon: Icons.gavel,
            title: 'İçtihat Asistanı',
            subtitle: 'İçtihat araştırma asistanı',
            screen: HukukAsistaniAIScreen(title: 'İçtihat Asistanı', asistanTuru: 'ictihat'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.book,
            title: 'Mevzuat Asistanı',
            subtitle: 'Mevzuat araştırma asistanı',
            screen: HukukAsistaniAIScreen(title: 'Mevzuat Asistanı', asistanTuru: 'mevzuat'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.edit,
            title: 'Dilekçe Asistanı',
            subtitle: 'Dilekçe hazırlama asistanı',
            screen: HukukAsistaniAIScreen(title: 'Dilekçe Asistanı', asistanTuru: 'dilekce'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.description,
            title: 'Sözleşme Asistanı',
            subtitle: 'Sözleşme hazırlama asistanı',
            screen: HukukAsistaniAIScreen(title: 'Sözleşme Asistanı', asistanTuru: 'sozlesme'),
          ),
          
          const Divider(color: Colors.white24),
          
          // Diğer Araçlar
          _buildSectionTitle('Diğer Araçlar'),
          _buildMenuItem(
            context,
            icon: Icons.calendar_month,
            title: 'Dava Takvimi',
            subtitle: 'Dava süreleri ve takvim',
            url: 'https://mevzuat.sinerjias.com.tr/hukuk-asistani/takvim',
          ),
          _buildMenuItem(
            context,
            icon: Icons.article,
            title: 'Makaleler',
            subtitle: 'Hukuk makaleleri',
            url: 'https://mevzuat.sinerjias.com.tr/makaleler',
          ),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Yardım',
            subtitle: 'Kullanım kılavuzu',
            url: 'https://mevzuat.sinerjias.com.tr/yardim',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? url,
    Widget? screen,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.white.withOpacity(0.5),
      ),
      onTap: () {
        Navigator.pop(context);
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        } else if (url != null) {
          // Hesaplama ekranları için
          if (title.contains('Hesaplama')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HesaplamaScreen(
                  hesaplamaTuru: title.toLowerCase(),
                  title: title,
                ),
              ),
            );
          } else if (title.contains('Mevzuat') || title.contains('Kanun') || title.contains('Yönetmelik')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MevzuatAramaScreen(
                  title: title,
                  mevzuatTuru: title,
                ),
              ),
            );
          } else if (title.contains('İçtihat') || title.contains('Karar')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IctihatAramaScreen(
                  title: title,
                ),
              ),
            );
          } else if (title.contains('Pratik Bilgiler') || title.contains('Genel Bilgiler') || 
                     title.contains('Avukatlık') || title.contains('Döviz') || title.contains('Sözlük')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PratikBilgilerScreen(
                  title: title,
                ),
              ),
            );
          }
        }
      },
    );
  }
}

