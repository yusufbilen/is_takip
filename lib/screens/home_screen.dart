import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/app_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_activities.dart';
import '../widgets/upcoming_events.dart';
import '../screens/muvekkil_list_screen.dart';
import '../screens/dava_list_screen.dart';
import '../screens/gorev_list_screen.dart';
import '../screens/etkinlik_list_screen.dart';
import '../screens/uyap_screen.dart';
import '../screens/karar_search_screen.dart';
import '../widgets/hamburger_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadAllData();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HamburgerMenu(),
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
          child: Builder(
            builder: (context) => Column(
              children: [
                // Hamburger menü butonu
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      _buildDashboardTab(),
                      const MuvekkilListScreen(),
                      const DavaListScreen(),
                      const GorevListScreen(),
                      const KararSearchScreen(),
                      const UyapScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard, 'Ana Ekran', 0),
                _buildNavItem(Icons.people, 'Müvekkil', 1),
                _buildNavItem(Icons.folder, 'Dava', 2),
                _buildNavItem(Icons.task, 'Görev', 3),
                _buildNavItem(Icons.gavel, 'Karar', 4),
                _buildNavItem(Icons.account_balance, 'UYAP', 5),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDashboardTab() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  _buildStatsGrid(provider),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildRecentActivities(provider),
                  const SizedBox(height: 24),
                  _buildUpcomingEvents(provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(AppProvider provider) {
    final stats = provider.dashboardStats;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        DashboardCard(
          title: 'Toplam Müvekkil',
          value: '${stats['muvekkil'] ?? 0}',
          icon: Icons.people,
          color: const Color(0xFF10B981),
          onTap: () => setState(() => _currentIndex = 1),
        ),
        DashboardCard(
          title: 'Aktif Dava',
          value: '${stats['dava'] ?? 0}',
          icon: Icons.folder,
          color: const Color(0xFF3B82F6),
          onTap: () => setState(() => _currentIndex = 2),
        ),
        DashboardCard(
          title: 'Bekleyen Görev',
          value: '${stats['aktifGorev'] ?? 0}',
          icon: Icons.task,
          color: const Color(0xFFF59E0B),
          onTap: () => setState(() => _currentIndex = 3),
        ),
        DashboardCard(
          title: 'Bugünkü Etkinlik',
          value: '${stats['bugunEtkinlik'] ?? 0}',
          icon: Icons.event,
          color: const Color(0xFF374151),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EtkinlikListScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return QuickActions(
      onAddMuvekkil: () => setState(() => _currentIndex = 1),
      onAddDava: () => setState(() => _currentIndex = 2),
      onAddGorev: () => setState(() => _currentIndex = 3),
      onAddEtkinlik: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EtkinlikListScreen()),
        );
      },
    );
  }

  Widget _buildRecentActivities(AppProvider provider) {
    return RecentActivities(
      muvekkiller: provider.muvekkiller.take(3).toList(),
      davalar: provider.davalar.take(3).toList(),
      gorevler: provider.gorevler.take(3).toList(),
    );
  }

  Widget _buildUpcomingEvents(AppProvider provider) {
    return UpcomingEvents(
      etkinlikler: provider.bugunkuEtkinlikler,
      gecikenGorevler: provider.gecikenGorevler,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
