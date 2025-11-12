import 'package:flutter/material.dart';

class DilekceSablonlariScreen extends StatelessWidget {
  const DilekceSablonlariScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sablonlar = [
      {'baslik': 'Genel Dilekçe Şablonu', 'aciklama': 'Genel amaçlı dilekçe şablonu'},
      {'baslik': 'İstek Dilekçesi', 'aciklama': 'Resmi kurumlara yapılan istek dilekçesi'},
      {'baslik': 'İtiraz Dilekçesi', 'aciklama': 'Kararlara itiraz dilekçesi'},
      {'baslik': 'Temyiz Dilekçesi', 'aciklama': 'Yargıtay temyiz dilekçesi'},
      {'baslik': 'İstinaf Dilekçesi', 'aciklama': 'Bölge adliye mahkemesi istinaf dilekçesi'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Dilekçe Şablonları',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sablonlar.length,
          itemBuilder: (context, index) {
            final sablon = sablonlar[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.description, color: Colors.white70),
                title: Text(
                  sablon['baslik'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  sablon['aciklama'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                onTap: () {
                  // Şablonu aç
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

