import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/etkinlik.dart';
import '../widgets/etkinlik_card.dart';
import 'etkinlik_form_screen.dart';

class EtkinlikListScreen extends StatefulWidget {
  const EtkinlikListScreen({super.key});

  @override
  State<EtkinlikListScreen> createState() => _EtkinlikListScreenState();
}

class _EtkinlikListScreenState extends State<EtkinlikListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
              _buildSearchBar(),
              Expanded(
                child: _buildEtkinlikList(),
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
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Etkinlikler',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      '${provider.etkinlikler.length} etkinlik',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _addEtkinlik,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Koyu lacivert arka plan
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Etkinlik ara...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildEtkinlikList() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
            ),
          );
        }

        List<Etkinlik> filteredEtkinlikler = provider.etkinlikler.where((etkinlik) {
          final searchTerm = _searchController.text.toLowerCase();
          return etkinlik.baslik.toLowerCase().contains(searchTerm) ||
              (etkinlik.aciklama?.toLowerCase().contains(searchTerm) ?? false);
        }).toList();

        // Tarihe göre sırala
        filteredEtkinlikler.sort((a, b) => a.baslangicTarihi.compareTo(b.baslangicTarihi));

        if (filteredEtkinlikler.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filteredEtkinlikler.length,
          itemBuilder: (context, index) {
            final etkinlik = filteredEtkinlikler[index];
            return EtkinlikCard(
              etkinlik: etkinlik,
              onTap: () => _editEtkinlik(etkinlik),
              onDelete: () => _deleteEtkinlik(etkinlik),
            );
          },
        );
      },
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
              color: const Color(0xFF0F172A).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_outlined,
              size: 60,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz etkinlik yok',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk etkinliğinizi planlayarak başlayın',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addEtkinlik,
            icon: const Icon(Icons.add),
            label: const Text('Etkinlik Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addEtkinlik() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EtkinlikFormScreen(),
      ),
    );
  }

  void _editEtkinlik(Etkinlik etkinlik) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EtkinlikFormScreen(etkinlik: etkinlik),
      ),
    );
  }

  void _deleteEtkinlik(Etkinlik etkinlik) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etkinlik Sil'),
        content: Text('${etkinlik.baslik} etkinliğini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppProvider>().deleteEtkinlik(etkinlik.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${etkinlik.baslik} silindi'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}
