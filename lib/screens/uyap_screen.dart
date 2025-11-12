import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/uyap_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UyapScreen extends StatefulWidget {
  const UyapScreen({super.key});

  @override
  State<UyapScreen> createState() => _UyapScreenState();
}

class _UyapScreenState extends State<UyapScreen> {
  final UyapService _uyapService = UyapService();
  final TextEditingController _tcController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _showLoginForm = false;
  bool _obscurePassword = true;
  List<UyapDosya> _dosyalar = [];
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView hata: ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://avukatbeta.uyap.gov.tr/'));
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await _uyapService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
      
      if (loggedIn) {
        await _loadDosyalar();
      }
    }
  }

  Future<void> _login() async {
    // WebView ile e-devlet girişi yap
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _EdevletLoginScreen(
          onLoginSuccess: () async {
            if (mounted) {
              setState(() {
                _isLoggedIn = true;
              });
              await _loadDosyalar();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Giriş başarılı'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _loadDosyalar() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Önce giriş durumunu kontrol et
      final isLoggedIn = await _uyapService.isLoggedIn();
      if (!mounted) return;
      
      if (!isLoggedIn) {
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oturum bulunamadı. Lütfen tekrar giriş yapın.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // UYAP portalını WebView'de göster
      // Dosyalar WebView içinden görüntülenecek
      if (mounted) {
        setState(() {
          _dosyalar = [];
        });
      }
      
      // WebView'i UYAP ana sayfasına yönlendir
      await _webViewController.loadRequest(
        Uri.parse('https://avukatbeta.uyap.gov.tr/main/avukat/index.jsp')
      );
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _uyapService.logout();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _dosyalar = [];
        _showLoginForm = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çıkış yapıldı'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
              Color(0xFF0F172A),
            ],
            stops: [0.0, 0.3, 0.6, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoggedIn ? _buildDosyaListesi() : _buildLoginScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UYAP Dosyalarım',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoggedIn ? '${_dosyalar.length} dosya' : 'E-devlet ile giriş yapın',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
              tooltip: 'Çıkış Yap',
            ),
        ],
      ),
    );
  }

  Widget _buildLoginScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.account_balance,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'UYAP Avukat Portal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'E-devlet bilgilerinizle giriş yaparak\nUYAP dosyalarınıza erişin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _tcController,
                  decoration: InputDecoration(
                    labelText: 'TC Kimlik No',
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'E-devlet Şifresi',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Giriş Yap',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => _EdevletLoginScreen(
                            onLoginSuccess: () async {
                              setState(() {
                                _isLoggedIn = true;
                              });
                              await _loadDosyalar();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Giriş başarılı'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login, color: Colors.white70),
                    label: const Text(
                      'E-devlet ile Giriş Yap',
                      style: TextStyle(color: Colors.white70),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDosyaListesi() {
    // UYAP portalını WebView içinde göster
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: WebViewWidget(controller: _webViewController),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDosyaCard(UyapDosya dosya) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showDosyaDetay(dosya),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dosya.baslik,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getDurumColor(dosya.durum).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getDurumColor(dosya.durum),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    dosya.durum,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDurumColor(dosya.durum),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.description, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  'Dosya No: ${dosya.dosyaNo}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.balance, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dosya.mahkeme,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (dosya.sonIslemTarihi != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'Son İşlem: ${DateFormat('dd.MM.yyyy').format(dosya.sonIslemTarihi!)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDurumColor(String durum) {
    switch (durum.toLowerCase()) {
      case 'aktif':
      case 'devam ediyor':
        return Colors.green;
      case 'beklemede':
        return Colors.orange;
      case 'kapalı':
      case 'sonuçlandı':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _showDosyaDetay(UyapDosya dosya) {
    // Dosya detay ekranına git
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _UyapDosyaDetayScreen(dosyaId: dosya.dosyaId),
      ),
    );
  }

  @override
  void dispose() {
    _tcController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Dosya Detay Ekranı
class _UyapDosyaDetayScreen extends StatefulWidget {
  final String dosyaId;

  const _UyapDosyaDetayScreen({required this.dosyaId});

  @override
  State<_UyapDosyaDetayScreen> createState() => _UyapDosyaDetayScreenState();
}

class _UyapDosyaDetayScreenState extends State<_UyapDosyaDetayScreen> {
  final UyapService _uyapService = UyapService();
  UyapDosyaDetay? _detay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetay();
  }

  Future<void> _loadDetay() async {
    try {
      final detay = await _uyapService.getDosyaDetay(widget.dosyaId);
      setState(() {
        _detay = detay;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detay yüklenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Dosya Detayı'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : _detay == null
              ? const Center(
                  child: Text(
                    'Detay bulunamadı',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dosya Bilgileri
                      _buildInfoCard('Dosya No', _detay!.dosyaNo),
                      _buildInfoCard('Mahkeme', _detay!.mahkeme),
                      _buildInfoCard('Hakim', _detay!.hakim),
                      _buildInfoCard('Durum', _detay!.durum),
                      
                      // Taraflar
                      if (_detay!.taraflar.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Taraflar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        ..._detay!.taraflar.map((taraf) => _buildTarafCard(taraf)),
                      ],
                      
                      // Duruşmalar
                      if (_detay!.durusmalar.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Duruşmalar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        ..._detay!.durusmalar.map((durusma) => _buildDurusmaCard(durusma)),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarafCard(UyapTaraf taraf) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              taraf.ad,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              taraf.tip,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurusmaCard(UyapDurusma durusma) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${DateFormat('dd.MM.yyyy').format(durusma.tarih)} - ${durusma.saat}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Salon: ${durusma.salon}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          Text(
            'Durum: ${durusma.durum}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// E-devlet Giriş Ekranı
class _EdevletLoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const _EdevletLoginScreen({required this.onLoginSuccess});

  @override
  State<_EdevletLoginScreen> createState() => _EdevletLoginScreenState();
}

class _EdevletLoginScreenState extends State<_EdevletLoginScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) async {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
            
            // Chrome error sayfalarını ve hata sayfalarını yok say
            if (url.contains('chrome-error://') || 
                url.contains('error') ||
                url.contains('hata')) {
              return;
            }
            
            // E-devlet giriş sayfasına yönlendirildiyse, kullanıcı e-devlet ile giriş yapacak
            if (url.contains('turkiye.gov.tr') || url.contains('giris.turkiye.gov.tr')) {
              print('E-devlet giriş sayfasına yönlendirildi');
              return; // E-devlet sayfasında giriş kontrolü yapma
            }
            
            // UYAP portal ana sayfasına geldiğinde kontrol et
            if (url.contains('avukatbeta.uyap.gov.tr') && 
                !url.contains('giris') &&
                !url.contains('login') &&
                !url.contains('hata') &&
                !url.contains('error')) {
              
              // Biraz bekle ki sayfa tam yüklensin
              await Future.delayed(const Duration(milliseconds: 2000));
              if (!mounted) return;
              
              // JavaScript ile sayfa içeriğini kontrol et
              try {
                final pageContent = await _webViewController.runJavaScriptReturningResult(
                  'document.body ? document.body.innerText : ""'
                );
                
                if (!mounted) return;
                
                // Giriş başarılı kontrolü - UYAP ana sayfasında belirli kelimeler olmalı
                final content = pageContent.toString().toLowerCase();
                
                print('Sayfa içeriği uzunluğu: ${content.length}');
                print('URL: $url');
                
                // Giriş başarısız işaretleri
                final hasError = content.contains('hata') || 
                               content.contains('yanlış') || 
                               content.contains('geçersiz') ||
                               content.contains('giriş yapınız') ||
                               (content.contains('login') && content.length < 200) ||
                               (content.contains('giriş sayfası') && content.length < 200) ||
                               url.contains('giris') ||
                               url.contains('login') ||
                               url.contains('hata');
                
                // Giriş başarılı işaretleri (daha esnek)
                final hasSuccess = (content.contains('dosya') || 
                                   content.contains('dava') || 
                                   content.contains('portal') ||
                                   content.contains('avukat') ||
                                   content.contains('ana sayfa') ||
                                   content.contains('menü') ||
                                   content.contains('işlemler') ||
                                   content.contains('sistem') ||
                                   url.contains('/main/avukat') ||
                                   url.contains('/anasayfa') ||
                                   url.contains('/index.jsp')) &&
                                  !hasError &&
                                  content.length > 50; // Minimum içerik
                
                print('hasSuccess: $hasSuccess, hasError: $hasError');
                
                if (hasSuccess && mounted) {
                  // Session cookie'lerini kaydet
                  await _saveSessionCookies();
                  if (mounted) {
                    widget.onLoginSuccess();
                  }
                } else if (hasError && mounted) {
                  // Giriş başarısız - kullanıcıya bilgi ver
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Giriş başarısız. Lütfen bilgilerinizi kontrol edin.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else if (!hasError && content.length > 50 && mounted) {
                  // Belirsiz durum - URL kontrolü yap
                  if (url.contains('/main/avukat') || 
                      url.contains('/anasayfa') ||
                      url.contains('/index.jsp') ||
                      (url.contains('avukatbeta.uyap.gov.tr') && 
                       !url.contains('giris') && 
                       !url.contains('login'))) {
                    await _saveSessionCookies();
                    widget.onLoginSuccess();
                  }
                }
              } catch (e) {
                print('Giriş kontrolü hatası: $e');
                // Hata durumunda URL kontrolü yap
                if (url.contains('/main/avukat') || 
                    url.contains('/anasayfa') ||
                    url.contains('/index.jsp') ||
                    (url.contains('avukatbeta.uyap.gov.tr') && 
                     !url.contains('giris') && 
                     !url.contains('login'))) {
                  if (mounted) {
                    await _saveSessionCookies();
                    if (mounted) {
                      widget.onLoginSuccess();
                    }
                  }
                }
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Vatandaş portalına yönlendirmeyi engelle
            if (request.url.contains('vatandas.uyap.gov.tr')) {
              return NavigationDecision.prevent;
            }
            
            // E-devlet giriş sayfasına izin ver
            if (request.url.contains('turkiye.gov.tr') || 
                request.url.contains('giris.turkiye.gov.tr')) {
              return NavigationDecision.navigate;
            }
            
            // Sadece avukat portal sayfalarına izin ver
            if (request.url.contains('avukatbeta.uyap.gov.tr')) {
              return NavigationDecision.navigate;
            }
            
            // Diğer UYAP sayfalarını engelle
            if (request.url.contains('uyap.gov.tr') && 
                !request.url.contains('avukatbeta')) {
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://avukatbeta.uyap.gov.tr/'));
  }

  Future<void> _saveSessionCookies() async {
    try {
      // Önce mevcut URL'yi kontrol et
      final currentUrl = await _webViewController.currentUrl();
      
      // Chrome error sayfalarında veya geçersiz URL'lerde cookie okuma
      if (currentUrl == null || 
          currentUrl.contains('chrome-error://') ||
          currentUrl.contains('error://') ||
          !currentUrl.contains('avukatbeta.uyap.gov.tr')) {
        print('Geçersiz URL, cookie okunmayacak: $currentUrl');
        // Sadece session durumunu kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('uyap_logged_in', true);
        await prefs.setString('uyap_login_time', DateTime.now().toIso8601String());
        return;
      }
      
      // WebView'den cookie'leri al (hata durumunda sessizce geç)
      try {
        // Sadece geçerli sayfalarda cookie oku
        final cookies = await _webViewController.runJavaScriptReturningResult(
          'try { document.cookie; } catch(e) { ""; }'
        );
        
        if (cookies != null && 
            cookies.toString().isNotEmpty && 
            cookies.toString() != '""' &&
            cookies.toString() != 'null') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('uyap_cookies', cookies.toString());
          print('Cookie kaydedildi: ${currentUrl}');
        }
      } catch (cookieError) {
        // Cookie okuma hatası - sessizce geç (normal olabilir)
        print('Cookie okunamadı (normal olabilir): $cookieError');
      }
      
      // Session durumunu kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('uyap_logged_in', true);
      await prefs.setString('uyap_login_time', DateTime.now().toIso8601String());
    } catch (e) {
      print('Session kaydetme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'E-devlet ile Giriş',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned.fill(
              child: WebViewWidget(controller: _webViewController),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

