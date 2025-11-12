import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/gorev.dart';

class GorevCard extends StatelessWidget {
  final Gorev gorev;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;

  const GorevCard({
    super.key,
    required this.gorev,
    this.onTap,
    this.onDelete,
    this.onComplete,
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
                          _buildPriorityChip(),
                          const SizedBox(width: 8),
                          _buildActions(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        gorev.baslik,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (gorev.aciklama != null && gorev.aciklama!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          gorev.aciklama!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (gorev.dava != null) ...[
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
                                gorev.dava!.baslik,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
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
                          if (gorev.bitisTarihi != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getDateColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getDateIcon(),
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(gorev.bitisTarihi!),
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
                          const Spacer(),
                          if (gorev.hatirlaticiVar && gorev.hatirlaticiTarihi != null)
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
                                    Icons.notifications,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(gorev.hatirlaticiTarihi!),
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
                      if (gorev.durum != GorevDurumu.tamamlandi && onComplete != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onComplete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Colors.white, width: 1),
                              ),
                            ),
                            child: const Text(
                              'Tamamla',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDurumColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        gorev.durumText,
        style: TextStyle(
          fontSize: 10,
          color: _getDurumColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getOncelikColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getOncelikIcon(),
            size: 10,
            color: _getOncelikColor(),
          ),
          const SizedBox(width: 4),
          Text(
            gorev.oncelikText,
            style: TextStyle(
              fontSize: 10,
              color: _getOncelikColor(),
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

  Color _getDurumColor() {
    switch (gorev.durum) {
      case GorevDurumu.bekleyen:
        return const Color(0xFF3B82F6);
      case GorevDurumu.devamEden:
        return const Color(0xFFF59E0B);
      case GorevDurumu.tamamlandi:
        return const Color(0xFF10B981);
      case GorevDurumu.iptal:
        return const Color(0xFF6B7280);
    }
  }

  Color _getOncelikColor() {
    switch (gorev.oncelik) {
      case GorevOnceligi.dusuk:
        return const Color(0xFF6B7280);
      case GorevOnceligi.normal:
        return const Color(0xFF3B82F6);
      case GorevOnceligi.yuksek:
        return const Color(0xFFF59E0B);
      case GorevOnceligi.acil:
        return const Color(0xFFEF4444);
    }
  }

  IconData _getOncelikIcon() {
    switch (gorev.oncelik) {
      case GorevOnceligi.dusuk:
        return Icons.keyboard_arrow_down;
      case GorevOnceligi.normal:
        return Icons.remove;
      case GorevOnceligi.yuksek:
        return Icons.keyboard_arrow_up;
      case GorevOnceligi.acil:
        return Icons.priority_high;
    }
  }

  Color _getDateColor() {
    if (gorev.gecikmis) {
      return const Color(0xFFEF4444);
    } else if (gorev.bugunBitiyor) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFF64748B);
    }
  }

  IconData _getDateIcon() {
    if (gorev.gecikmis) {
      return Icons.warning;
    } else if (gorev.bugunBitiyor) {
      return Icons.schedule;
    } else {
      return Icons.event;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Yarın';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
