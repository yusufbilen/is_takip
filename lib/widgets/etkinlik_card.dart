import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/etkinlik.dart';

class EtkinlikCard extends StatelessWidget {
  final Etkinlik etkinlik;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const EtkinlikCard({
    super.key,
    required this.etkinlik,
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
                          _buildTypeChip(),
                          const Spacer(),
                          _buildTimeChip(),
                          const SizedBox(width: 8),
                          _buildActions(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        etkinlik.baslik,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (etkinlik.aciklama != null && etkinlik.aciklama!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          etkinlik.aciklama!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (etkinlik.dava != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.folder,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                etkinlik.dava!.baslik,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (etkinlik.konum != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 12,
                                    color: Color(0xFF10B981),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    etkinlik.konum!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (etkinlik.katilimcilar != null && etkinlik.katilimcilar!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.people,
                                    size: 12,
                                    color: Color(0xFF374151),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    etkinlik.katilimcilar!,
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
                      if (etkinlik.hatirlaticiVar && etkinlik.hatirlaticiTarihi != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.notifications,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hatırlatıcı: ${_formatDateTime(etkinlik.hatirlaticiTarihi!)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getTurColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTurIcon(),
            size: 12,
            color: _getTurColor(),
          ),
          const SizedBox(width: 4),
          Text(
            etkinlik.turText,
            style: TextStyle(
              fontSize: 10,
              color: _getTurColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getTimeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTimeIcon(),
            size: 12,
            color: _getTimeColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _formatTime(etkinlik.baslangicTarihi),
            style: TextStyle(
              fontSize: 10,
              color: _getTimeColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

  Color _getTurColor() {
    switch (etkinlik.tur) {
      case EtkinlikTuru.durusma:
        return const Color(0xFFEF4444);
      case EtkinlikTuru.toplanti:
        return const Color(0xFF3B82F6);
      case EtkinlikTuru.telefonGorusmesi:
        return const Color(0xFF10B981);
      case EtkinlikTuru.email:
        return const Color(0xFF374151);
      case EtkinlikTuru.dosyaHazirlama:
        return const Color(0xFFF59E0B);
      case EtkinlikTuru.arastirma:
        return const Color(0xFF06B6D4);
      case EtkinlikTuru.diger:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getTurIcon() {
    switch (etkinlik.tur) {
      case EtkinlikTuru.durusma:
        return Icons.gavel;
      case EtkinlikTuru.toplanti:
        return Icons.people;
      case EtkinlikTuru.telefonGorusmesi:
        return Icons.phone;
      case EtkinlikTuru.email:
        return Icons.email;
      case EtkinlikTuru.dosyaHazirlama:
        return Icons.description;
      case EtkinlikTuru.arastirma:
        return Icons.search;
      case EtkinlikTuru.diger:
        return Icons.event;
    }
  }

  Color _getTimeColor() {
    if (etkinlik.gecmis) {
      return const Color(0xFF6B7280);
    } else if (etkinlik.bugun) {
      return const Color(0xFFF59E0B);
    } else if (etkinlik.yarin) {
      return const Color(0xFF3B82F6);
    } else {
      return const Color(0xFF64748B);
    }
  }

  IconData _getTimeIcon() {
    if (etkinlik.gecmis) {
      return Icons.history;
    } else if (etkinlik.bugun) {
      return Icons.today;
    } else if (etkinlik.yarin) {
      return Icons.event_available;
    } else {
      return Icons.schedule;
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Bugün ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yarın ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün sonra ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
    }
  }
}
