import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback? onAddMuvekkil;
  final VoidCallback? onAddDava;
  final VoidCallback? onAddGorev;
  final VoidCallback? onAddEtkinlik;

  const QuickActions({
    super.key,
    this.onAddMuvekkil,
    this.onAddDava,
    this.onAddGorev,
    this.onAddEtkinlik,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı İşlemler',
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
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                context,
                                icon: Icons.person_add,
                                title: 'Müvekkil',
                                subtitle: 'Ekle',
                                color: const Color(0xFF10B981),
                                onTap: onAddMuvekkil,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                context,
                                icon: Icons.folder_open,
                                title: 'Dava',
                                subtitle: 'Aç',
                                color: const Color(0xFF3B82F6),
                                onTap: onAddDava,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                context,
                                icon: Icons.add_task,
                                title: 'Görev',
                                subtitle: 'Oluştur',
                                color: const Color(0xFFF59E0B),
                                onTap: onAddGorev,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                context,
                                icon: Icons.event,
                                title: 'Etkinlik',
                                subtitle: 'Planla',
                                color: const Color(0xFF374151),
                                onTap: onAddEtkinlik,
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
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent, // Şeffaf iç
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFF10B981), // Yeşil çerçeve
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF10B981), // Yeşil arka plan
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Color(0xFF10B981), // Yeşil yazı
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Color(0xFF10B981), // Yeşil yazı
              ),
            ),
          ],
        ),
      ),
    );
  }
}
