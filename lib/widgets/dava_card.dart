import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/dava.dart';
import '../screens/muvekkil_detail_screen.dart';

class DavaCard extends StatelessWidget {
  final Dava dava;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DavaCard({
    super.key,
    required this.dava,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        horizontalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A), // Koyu lacivert arka plan
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildStatusChip(),
                          const Spacer(),
                          _buildActions(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dava.baslik,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dava No: ${dava.davaNo}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (dava.muvekkil != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  dava.muvekkil!.basHarfler,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dava.muvekkil!.tamAd,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _showMuvekkilProfile(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Profil',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTurColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dava.turText,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getTurColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (dava.durusmaTarihi != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF374151).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.event,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(dava.durusmaTarihi!),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDurumColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        dava.durumText,
        style: TextStyle(
          fontSize: 10,
          color: _getDurumColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.chevron_right,
            size: 16,
            color: Colors.white,
          ),
        ),
        if (onDelete != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
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
        return const Color(0xFF6366F1);
      case DavaDurumu.kazanildi:
        return const Color(0xFF10B981);
      case DavaDurumu.kaybedildi:
        return const Color(0xFFEF4444);
      case DavaDurumu.uzlastirma:
        return const Color(0xFF06B6D4);
      case DavaDurumu.iptal:
        return const Color(0xFF6B7280);
    }
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
        return const Color(0xFF6366F1);
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
          davalar: [], // Bu dava ile ilgili davalar
          gorevler: [], // Bu müvekkil ile ilgili görevler
          etkinlikler: [], // Bu müvekkil ile ilgili etkinlikler
        ),
      ),
    );
  }
}
