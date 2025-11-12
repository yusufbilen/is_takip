import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/muvekkil.dart';
import '../models/dava.dart';
import '../models/gorev.dart';

class RecentActivities extends StatelessWidget {
  final List<Muvekkil> muvekkiller;
  final List<Dava> davalar;
  final List<Gorev> gorevler;

  const RecentActivities({
    super.key,
    required this.muvekkiller,
    required this.davalar,
    required this.gorevler,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son Aktiviteler',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white, // Beyaz başlık
            ),
          ),
          const SizedBox(height: 16),
          AnimationConfiguration.staggeredList(
            position: 0,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1E293B), // Koyu mavi kart arka planı
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (muvekkiller.isNotEmpty) ...[
                          _buildActivityItem(
                            context,
                            icon: Icons.person_add,
                            title: 'Yeni Müvekkil',
                            subtitle: muvekkiller.first.tamAd,
                            time: _formatDate(muvekkiller.first.createdAt),
                            color: const Color(0xFF10B981),
                          ),
                          if (davalar.isNotEmpty || gorevler.isNotEmpty)
                            const Divider(),
                        ],
                        if (davalar.isNotEmpty) ...[
                          _buildActivityItem(
                            context,
                            icon: Icons.folder,
                            title: 'Yeni Dava',
                            subtitle: davalar.first.baslik,
                            time: _formatDate(davalar.first.createdAt),
                            color: const Color(0xFF3B82F6),
                          ),
                          if (gorevler.isNotEmpty)
                            const Divider(),
                        ],
                        if (gorevler.isNotEmpty)
                          _buildActivityItem(
                            context,
                            icon: Icons.task,
                            title: 'Yeni Görev',
                            subtitle: gorevler.first.baslik,
                            time: _formatDate(gorevler.first.createdAt),
                            color: const Color(0xFFF59E0B),
                          ),
                        if (muvekkiller.isEmpty && davalar.isEmpty && gorevler.isEmpty)
                          _buildEmptyState(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Henüz aktivite yok',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'İlk müvekkil, dava veya görevinizi ekleyin',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
