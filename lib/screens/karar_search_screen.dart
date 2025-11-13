import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/yargitay_service.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class KararSearchScreen extends StatefulWidget {
  const KararSearchScreen({super.key});

  @override
  State<KararSearchScreen> createState() => _KararSearchScreenState();
}

class _KararSearchScreenState extends State<KararSearchScreen> {
  final YargitayService _yargitayService = YargitayService();
  final TextEditingController _aramaController = TextEditingController();
  
  // Birim seçimi
  String? _selectedKurul;
  String? _selectedHukukDairesi;
  String? _selectedCezaDairesi;
  
  // Esas numarası
  final TextEditingController _esasYilController = TextEditingController();
  final TextEditingController _esasIlkSiraController = TextEditingController();
  final TextEditingController _esasSonSiraController = TextEditingController();
  
  // Karar numarası
  final TextEditingController _kararYilController = TextEditingController();
  final TextEditingController _kararIlkSiraController = TextEditingController();
  final TextEditingController _kararSonSiraController = TextEditingController();
  
  // Karar tarihi
  DateTime? _kararBaslangicTarihi;
  DateTime? _kararBitisTarihi;
  
  // Sıralama
  String _siralama = 'karar_tarihi';
  String _siralamaYonu = 'desc';
  
  bool _isLoading = false;
  bool _showWebView = false;
  bool _showSearchForm = false;
  List<YargitayKarar> _kararlar = [];
  List<YargitayKarar> _populerKararlar = [];
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F172A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            // Sayfa yüklendiğinde sonuçları ve popüler kararları çek
            if (url.contains('karararama.yargitay.gov.tr')) {
              // Sayfa tam yüklensin ve JavaScript çalışsın
              await Future.delayed(const Duration(seconds: 5));
              
              // Ana sayfadaysa popüler kararları yükle
              if (url == 'https://karararama.yargitay.gov.tr/' || 
                  url == 'https://karararama.yargitay.gov.tr') {
                await _loadPopulerKararlar();
              } else {
                // Arama sonuç sayfasındaysa sonuçları çek
                await _extractKararSonuclari();
              }
            }
            
            // Loading'i kapat (veri gelmese bile)
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'KararChannel',
        onMessageReceived: (JavaScriptMessage message) {
          // JavaScript'ten gelen verileri işle
          try {
            final data = jsonDecode(message.message);
            if (data['type'] == 'kararlar') {
              final List<dynamic> kararlarData = data['kararlar'];
              setState(() {
                _kararlar = kararlarData.map((k) => YargitayKarar(
                  baslik: k['baslik'] ?? '',
                  link: k['link'] ?? '',
                  birim: k['birim'] ?? '',
                  esasNo: k['esasNo'] ?? '',
                  kararNo: k['kararNo'] ?? '',
                  tarih: k['tarih'] ?? '',
                  kararMetni: k['kararMetni'],
                )).toList();
              });
            } else if (data['type'] == 'populerKararlar') {
              final List<dynamic> kararlarData = data['kararlar'];
              _handlePopulerKararlar(kararlarData);
            }
          } catch (e) {
            print('JavaScript channel hatası: $e');
          }
        },
      )
      ..loadRequest(Uri.parse('https://karararama.yargitay.gov.tr/'));
    // Popüler kararlar sayfa yüklendiğinde otomatik çekilecek
  }

  Future<void> _extractKararSonuclari() async {
    // JavaScript ile DataTable'dan verileri çek
    final script = '''
      (function() {
        function extractKararlar() {
          try {
            var kararlar = [];
            var table = document.querySelector('table#kt_datatable tbody, table.dataTable tbody, table tbody');
            
            if (table && table.children.length > 0) {
              var rows = table.querySelectorAll('tr');
              rows.forEach(function(row) {
                var cells = row.querySelectorAll('td');
                if (cells.length >= 2) {
                  var link = cells[0].querySelector('a') || cells[1].querySelector('a');
                  var baslik = link ? link.textContent.trim() : (cells[0].textContent.trim() || cells[1].textContent.trim());
                  var href = link ? (link.href || link.getAttribute('onclick')) : '';
                  
                  if (href && href.includes('onclick')) {
                    var match = href.match(/['"]([^'"]+)['"]/);
                    if (match) href = match[1];
                  }
                  
                  if (!href || !href.startsWith('http')) {
                    href = 'https://karararama.yargitay.gov.tr/';
                  }
                  
                  var birim = '';
                  var esasNo = '';
                  var kararNo = '';
                  var tarih = '';
                  
                  for (var i = 0; i < cells.length; i++) {
                    var text = cells[i].textContent.trim();
                    if (!text) continue;
                    
                    if (text.includes('Daire') || text.includes('Kurul') || text.includes('Genel')) {
                      birim = text;
                    } else if (text.match(/\\d{4}\\/\\d+/)) {
                      if (!esasNo) esasNo = text;
                      else if (!kararNo) kararNo = text;
                    } else if (text.match(/\\d{2}\\.\\d{2}\\.\\d{4}/)) {
                      tarih = text;
                    }
                  }
                  
                  if (baslik && baslik.length > 5) {
                    kararlar.push({
                      baslik: baslik,
                      link: href,
                      birim: birim,
                      esasNo: esasNo,
                      kararNo: kararNo,
                      tarih: tarih
                    });
                  }
                }
              });
            }
            
            if (kararlar.length > 0) {
              KararChannel.postMessage(JSON.stringify({
                type: 'kararlar',
                kararlar: kararlar
              }));
            }
          } catch(e) {
            console.error('Extract error: ' + e);
          }
        }
        
        // Elementlerin yüklenmesini bekle
        function waitForTable(callback, maxAttempts) {
          var attempts = 0;
          var interval = setInterval(function() {
            attempts++;
            var table = document.querySelector('table tbody');
            if ((table && table.children.length > 0) || attempts >= maxAttempts) {
              clearInterval(interval);
              callback();
            }
          }, 500);
        }
        
        waitForTable(extractKararlar, 10);
      })();
    ''';
    
    try {
      await Future.delayed(const Duration(seconds: 2));
      await _webViewController.runJavaScript(script);
    } catch (e) {
      print('JavaScript çalıştırma hatası: $e');
    }
  }

  Future<void> _loadPopulerKararlar() async {
    // Backend API'den popüler kararları çek
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.yargitayPopuler();
      
      if (result['success'] == true) {
        final sonuclar = result['sonuclar'] as List;
        setState(() {
          _populerKararlar = sonuclar.map((k) => YargitayKarar(
            baslik: k['baslik'] ?? '',
            link: k['link'] ?? '',
            birim: k['birim'] ?? '',
            esasNo: k['esas_no'] ?? '',
            kararNo: k['karar_no'] ?? '',
            tarih: k['tarih'] ?? '',
          )).toList();
          _isLoading = false;
        });
        
        print('${_populerKararlar.length} popüler karar bulundu');
      } else {
        // Fallback: Eski servisi kullan
        final kararlar = await _yargitayService.aramaYap();
        setState(() {
          if (kararlar.isNotEmpty) {
            _populerKararlar = kararlar.take(10).toList();
          } else {
            _populerKararlar = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Popüler karar yükleme hatası: $e');
      // Fallback: Eski servisi kullan
      try {
        final kararlar = await _yargitayService.aramaYap();
        setState(() {
          if (kararlar.isNotEmpty) {
            _populerKararlar = kararlar.take(10).toList();
          } else {
            _populerKararlar = [];
          }
          _isLoading = false;
        });
      } catch (e2) {
        setState(() {
          _isLoading = false;
          _populerKararlar = [];
        });
      }
    }
  }

  void _handlePopulerKararlar(List<dynamic> kararlarData) {
    setState(() {
      if (kararlarData.isNotEmpty) {
        _populerKararlar = kararlarData.map((k) => YargitayKarar(
          baslik: k['baslik'] ?? '',
          link: k['link'] ?? '',
          birim: k['birim'] ?? '',
          esasNo: k['esasNo'] ?? '',
          kararNo: k['kararNo'] ?? '',
          tarih: k['tarih'] ?? '',
          kararMetni: k['kararMetni'],
        )).toList();
      }
      _isLoading = false;
    });
    
    // Veri gelmediyse kullanıcıya bilgi ver
    if (kararlarData.isEmpty) {
      print('Popüler kararlar bulunamadı. WebView\'den veri çekilemedi.');
    }
  }


  @override
  void dispose() {
    _aramaController.dispose();
    _esasYilController.dispose();
    _esasIlkSiraController.dispose();
    _esasSonSiraController.dispose();
    _kararYilController.dispose();
    _kararIlkSiraController.dispose();
    _kararSonSiraController.dispose();
    super.dispose();
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
              _buildHeader(),
              if (!_showWebView) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_showSearchForm) _buildSearchForm(),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else if (_showSearchForm && _kararlar.isEmpty)
                          _buildEmptyState()
                        else if (_showSearchForm && _kararlar.isNotEmpty)
                          _buildKararList()
                        else
                          _buildPopulerKararlar(),
                      ],
                    ),
                  ),
                ),
              ] else
                Expanded(
                  child: Stack(
                    children: [
                      WebViewWidget(controller: _webViewController),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                    ],
                  ),
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
                  'Yargıtay Karar Arama',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Karar ve içtihat arama',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _showSearchForm ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _showSearchForm = !_showSearchForm;
                    if (!_showSearchForm) {
                      _kararlar = [];
                      _temizle();
                    }
                  });
                },
                tooltip: _showSearchForm ? 'Kapat' : 'Ara',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _showWebView ? Icons.list : Icons.public,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _showWebView = !_showWebView;
                  });
                },
                tooltip: _showWebView ? 'Liste Görünümü' : 'Web Görünümü',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionTitle('Arama Kriterleri'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _aramaController,
            label: 'Aranacak Kelime',
            icon: Icons.search,
            hintText: 'Karar içinde arayacağınız kelime',
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Birim Seçimi'),
          const SizedBox(height: 8),
          Text(
            '***Birim seçilmediğinde tüm birimlerde arama yapılır.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdownField<String?>(
            label: 'Kurul Seçiniz',
            icon: Icons.groups,
            value: _selectedKurul,
            items: [
              null,
              'Hukuk Genel Kurulu',
              'Ceza Genel Kurulu',
              'Ceza Daireleri Başkanlar Kurulu',
              'Hukuk Daireleri Başkanlar Kurulu',
              'Büyük Genel Kurulu',
            ],
            onChanged: (value) => setState(() => _selectedKurul = value),
            hint: 'Kurul seçiniz',
            itemBuilder: (value) => Text(
              value ?? 'Kurul seçiniz',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdownField<String?>(
            label: 'Hukuk Dairesi Seçiniz',
            icon: Icons.balance,
            value: _selectedHukukDairesi,
            items: [
              null,
              ...List.generate(23, (index) => '${index + 1}. Hukuk Dairesi'),
            ],
            onChanged: (value) => setState(() => _selectedHukukDairesi = value),
            hint: 'Hukuk Dairesi seçiniz',
            itemBuilder: (value) => Text(
              value ?? 'Hukuk Dairesi seçiniz',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          _buildDropdownField<String?>(
            label: 'Ceza Dairesi Seçiniz',
            icon: Icons.gavel,
            value: _selectedCezaDairesi,
            items: [
              null,
              ...List.generate(23, (index) => '${index + 1}. Ceza Dairesi'),
            ],
            onChanged: (value) => setState(() => _selectedCezaDairesi = value),
            hint: 'Ceza Dairesi seçiniz',
            itemBuilder: (value) => Text(
              value ?? 'Ceza Dairesi seçiniz',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Esas Numarası'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _esasYilController,
                  label: 'Esas Yılı',
                  icon: Icons.calendar_today,
                  hintText: 'Yıl',
                  keyboardType: TextInputType.number,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text('/', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _esasIlkSiraController,
                  label: 'İlk Sıra No',
                  icon: Icons.numbers,
                  hintText: 'İlk',
                  keyboardType: TextInputType.number,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text('-', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _esasSonSiraController,
                  label: 'Son Sıra No',
                  icon: Icons.numbers,
                  hintText: 'Son',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Karar Numarası'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _kararYilController,
                  label: 'Karar Yılı',
                  icon: Icons.calendar_today,
                  hintText: 'Yıl',
                  keyboardType: TextInputType.number,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text('/', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _kararIlkSiraController,
                  label: 'İlk Sıra No',
                  icon: Icons.numbers,
                  hintText: 'İlk',
                  keyboardType: TextInputType.number,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text('-', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _kararSonSiraController,
                  label: 'Son Sıra No',
                  icon: Icons.numbers,
                  hintText: 'Son',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Karar Tarihi'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Başlama Tarihi',
                  icon: Icons.calendar_today,
                  value: _kararBaslangicTarihi,
                  onChanged: (date) => setState(() => _kararBaslangicTarihi = date),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 30),
                child: Text('-', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              Expanded(
                child: _buildDateField(
                  label: 'Bitiş Tarihi',
                  icon: Icons.event_available,
                  value: _kararBitisTarihi,
                  onChanged: (date) => setState(() => _kararBitisTarihi = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Sıralama',
                  icon: Icons.sort,
                  value: _siralama,
                  items: const ['karar_tarihi', 'esas_no', 'karar_no'],
                  onChanged: (value) => setState(() => _siralama = value!),
                  itemBuilder: (value) {
                    switch (value) {
                      case 'karar_tarihi':
                        return const Text('Tarih', style: TextStyle(color: Colors.white, fontSize: 14));
                      case 'esas_no':
                        return const Text('Esas No', style: TextStyle(color: Colors.white, fontSize: 14));
                      case 'karar_no':
                        return const Text('Karar No', style: TextStyle(color: Colors.white, fontSize: 14));
                      default:
                        return Text(value, style: const TextStyle(color: Colors.white, fontSize: 14));
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Yön',
                  icon: Icons.arrow_upward,
                  value: _siralamaYonu,
                  items: const ['asc', 'desc'],
                  onChanged: (value) => setState(() => _siralamaYonu = value!),
                  itemBuilder: (value) {
                    return Text(
                      value == 'asc' ? 'Artan' : 'Azalan',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _aramaYap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white, width: 1),
                ),
              ),
              child: const Text(
                'Ara',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (_kararlar.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _temizle,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Temizle'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {double fontSize = 18}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String? hint,
    Widget Function(T)? itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      dropdownColor: const Color(0xFF0F172A),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white, fontSize: 14),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: itemBuilder != null
              ? itemBuilder(item)
              : Text(
                  item.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
        );
      }).toList(),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value != null
                        ? DateFormat('dd/MM/yyyy').format(value)
                        : 'Tarih Seçiniz',
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? Colors.white : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Karar Arama',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yargıtay kararlarını aramak için kriterleri doldurun',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPopulerKararlar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'En Çok Tıklanan Kararlar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_populerKararlar.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            ..._populerKararlar.map((karar) => _buildKararCard(karar)).toList(),
        ],
      ),
    );
  }

  Widget _buildKararList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _kararlar.map((karar) => _buildKararCard(karar)).toList(),
      ),
    );
  }

  Widget _buildKararCard(YargitayKarar karar) {
    return InkWell(
      onTap: () => _showKararDetay(karar),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    karar.baslik,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new, color: Colors.white, size: 20),
                  onPressed: () {
                    _webViewController.loadRequest(Uri.parse(karar.link));
                    setState(() {
                      _showWebView = true;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (karar.birim.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.business, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      karar.birim,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (karar.esasNo.isNotEmpty || karar.kararNo.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (karar.esasNo.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.numbers, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Esas: ${karar.esasNo}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (karar.kararNo.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.description, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Karar: ${karar.kararNo}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
            if (karar.tarih.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    karar.tarih,
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

  void _showKararDetay(YargitayKarar karar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _KararDetayScreen(karar: karar),
      ),
    );
  }

  Widget _buildDetayRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _aramaYap() async {
    // En az bir kriter kontrolü
    final hasAramaKelimesi = _aramaController.text.trim().isNotEmpty;
    final hasEsasNo = _esasYilController.text.trim().isNotEmpty ||
        _esasIlkSiraController.text.trim().isNotEmpty ||
        _esasSonSiraController.text.trim().isNotEmpty;
    final hasKararNo = _kararYilController.text.trim().isNotEmpty ||
        _kararIlkSiraController.text.trim().isNotEmpty ||
        _kararSonSiraController.text.trim().isNotEmpty;
    final hasTarih = _kararBaslangicTarihi != null || _kararBitisTarihi != null;
    final hasBirim = _selectedKurul != null ||
        _selectedHukukDairesi != null ||
        _selectedCezaDairesi != null;

    if (!hasAramaKelimesi &&
        !hasEsasNo &&
        !hasKararNo &&
        !hasTarih &&
        !hasBirim) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir arama kriteri girin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _kararlar = [];
      _showSearchForm = true; // Arama yapıldığında formu göster
    });

    // Birim seçimi - öncelik sırası: Kurul > Hukuk Dairesi > Ceza Dairesi
    String? selectedBirim;
    if (_selectedKurul != null) {
      selectedBirim = _selectedKurul;
    } else if (_selectedHukukDairesi != null) {
      selectedBirim = _selectedHukukDairesi;
    } else if (_selectedCezaDairesi != null) {
      selectedBirim = _selectedCezaDairesi;
    }

    // Esas numarası formatı: YIL/ILK_SIRA-SON_SIRA
    String? esasNo;
    if (_esasYilController.text.trim().isNotEmpty ||
        _esasIlkSiraController.text.trim().isNotEmpty ||
        _esasSonSiraController.text.trim().isNotEmpty) {
      final yil = _esasYilController.text.trim();
      final ilk = _esasIlkSiraController.text.trim();
      final son = _esasSonSiraController.text.trim();
      if (yil.isNotEmpty && ilk.isNotEmpty) {
        esasNo = son.isNotEmpty ? '$yil/$ilk-$son' : '$yil/$ilk';
      }
    }

    // Karar numarası formatı: YIL/ILK_SIRA-SON_SIRA
    String? kararNo;
    if (_kararYilController.text.trim().isNotEmpty ||
        _kararIlkSiraController.text.trim().isNotEmpty ||
        _kararSonSiraController.text.trim().isNotEmpty) {
      final yil = _kararYilController.text.trim();
      final ilk = _kararIlkSiraController.text.trim();
      final son = _kararSonSiraController.text.trim();
      if (yil.isNotEmpty && ilk.isNotEmpty) {
        kararNo = son.isNotEmpty ? '$yil/$ilk-$son' : '$yil/$ilk';
      }
    }

    // Tarih aralığı
    String? kararTarihi;
    if (_kararBaslangicTarihi != null || _kararBitisTarihi != null) {
      final baslangic = _kararBaslangicTarihi != null
          ? DateFormat('yyyy-MM-dd').format(_kararBaslangicTarihi!)
          : '';
      final bitis = _kararBitisTarihi != null
          ? DateFormat('yyyy-MM-dd').format(_kararBitisTarihi!)
          : '';
      kararTarihi = baslangic.isNotEmpty && bitis.isNotEmpty
          ? '$baslangic-$bitis'
          : baslangic.isNotEmpty
              ? baslangic
              : bitis;
    }

    try {
      // Backend API'den arama yap
      final result = await ApiService.yargitayArama(
        aranacakKelime: hasAramaKelimesi ? _aramaController.text.trim() : '',
        birim: selectedBirim ?? '',
        kurul: _selectedKurul ?? '',
        hukukDairesi: _selectedHukukDairesi ?? '',
        cezaDairesi: _selectedCezaDairesi ?? '',
        esasNo: esasNo ?? '',
        kararNo: kararNo ?? '',
        kararTarihiBaslangic: _kararBaslangicTarihi != null 
            ? DateFormat('dd.MM.yyyy').format(_kararBaslangicTarihi!) 
            : '',
        kararTarihiBitis: _kararBitisTarihi != null 
            ? DateFormat('dd.MM.yyyy').format(_kararBitisTarihi!) 
            : '',
        sirala: _siralama,
      );

      if (result['success'] == true) {
        final sonuclar = result['sonuclar'] as List;
        setState(() {
          _kararlar = sonuclar.map((k) => YargitayKarar(
            baslik: k['baslik'] ?? '',
            link: k['link'] ?? '',
            birim: k['birim'] ?? '',
            esasNo: k['esas_no'] ?? '',
            kararNo: k['karar_no'] ?? '',
            tarih: k['tarih'] ?? '',
          )).toList();
          _isLoading = false;
        });

        if (_kararlar.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sonuç bulunamadı'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_kararlar.length} karar bulundu'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } else {
        throw Exception(result['error'] ?? 'Arama başarısız');
      }
    } catch (e) {
      // Fallback: Eski servisi kullan
      try {
        final kararlar = await _yargitayService.aramaYap(
          aramaKelimesi: hasAramaKelimesi ? _aramaController.text.trim() : null,
          birim: selectedBirim,
          esasNo: esasNo,
          kararNo: kararNo,
          kararTarihi: kararTarihi,
          siralama: _siralama,
          siralamaYonu: _siralamaYonu,
        );

        setState(() {
          _kararlar = kararlar;
          _isLoading = false;
        });

        if (kararlar.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sonuç bulunamadı'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${kararlar.length} karar bulundu (Fallback)'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } catch (e2) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arama sırasında hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _temizle() {
    setState(() {
      _aramaController.clear();
      _esasYilController.clear();
      _esasIlkSiraController.clear();
      _esasSonSiraController.clear();
      _kararYilController.clear();
      _kararIlkSiraController.clear();
      _kararSonSiraController.clear();
      _selectedKurul = null;
      _selectedHukukDairesi = null;
      _selectedCezaDairesi = null;
      _kararBaslangicTarihi = null;
      _kararBitisTarihi = null;
      _siralama = 'karar_tarihi';
      _siralamaYonu = 'desc';
      _kararlar = [];
    });
  }
}

// Tam ekran karar detay ekranı (PDF okuyucu formatında)
class _KararDetayScreen extends StatelessWidget {
  final YargitayKarar karar;

  const _KararDetayScreen({required this.karar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Karar Detayı',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Text(
                karar.baslik,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Bilgiler
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    if (karar.birim.isNotEmpty) ...[
                      _buildInfoRow('Birim', karar.birim),
                      const SizedBox(height: 12),
                    ],
                    if (karar.esasNo.isNotEmpty) ...[
                      _buildInfoRow('Esas No', karar.esasNo),
                      const SizedBox(height: 12),
                    ],
                    if (karar.kararNo.isNotEmpty) ...[
                      _buildInfoRow('Karar No', karar.kararNo),
                      const SizedBox(height: 12),
                    ],
                    if (karar.tarih.isNotEmpty)
                      _buildInfoRow('Tarih', karar.tarih),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Karar Metni (PDF okuyucu formatında)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      karar.kararMetni ?? 'Karar metni yükleniyor...',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.8,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
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
    );
  }
}


