import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/monetization/marketplace_category.dart';
import 'screens/monetization/business_plans_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AsanColors.navyDeep,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await FirebaseService.initialize();
  runApp(const AsanApp());
}

/// ASAN marketplace — classifieds for buying, selling, and hiring.
class AsanApp extends StatelessWidget {
  const AsanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASAN',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _AsanScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AsanColors.navy,
        colorScheme: const ColorScheme.dark(
          primary: AsanColors.purple,
          secondary: AsanColors.pink,
          surface: AsanColors.navyLight,
          onSurface: AsanColors.cream,
        ),
        fontFamily: 'Segoe UI',
      ),
      home: const AsanShell(),
    );
  }
}

/// Enables drag scrolling with mouse/trackpad on web & desktop.
class _AsanScrollBehavior extends MaterialScrollBehavior {
  const _AsanScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

// ─── Palette (ASAN premium dark / neon) ───────────────────────────────────────

abstract final class AsanColors {
  static const navy = Color(0xFF070B1A);
  static const navyDeep = Color(0xFF05070F);
  static const navyLight = Color(0xFF0E1428);
  static const cream = Color(0xFFF4F7FF);
  static const muted = Color(0x8CF4F7FF);
  static const gold = Color(0xFFFFC83D);
  static const purple = Color(0xFF7B5CFF);
  static const pink = Color(0xFFFF5FA2);
  static const coral = Color(0xFFFF5F6D);
  static const cyan = Color(0xFF36D8FF);
  static const blue = Color(0xFF4DA3FF);
  static const green = Color(0xFF00E676);
  static const border = Color(0x1AFFFFFF);
  static const glass = Color(0x0DFFFFFF);
  static const glassStrong = Color(0x12FFFFFF);
  static const borderGlow = Color(0x737B5CFF);
}

// ─── Sample marketplace data ──────────────────────────────────────────────────

class Listing {
  const Listing({
    required this.title,
    required this.price,
    required this.location,
    required this.category,
    required this.accent,
    required this.icon,
    this.ago = 'Today',
  });

  final String title;
  final String price;
  final String location;
  final String category;
  final Color accent;
  final IconData icon;
  final String ago;
}

const featuredListings = <Listing>[
  Listing(
    title: 'Modern House',
    price: '£425,000',
    location: 'Manchester',
    category: 'Real Estate',
    accent: AsanColors.green,
    icon: Icons.home_rounded,
  ),
  Listing(
    title: 'BMW 320d M Sport',
    price: '£14,500',
    location: 'London, Ealing',
    category: 'Cars',
    accent: AsanColors.blue,
    icon: Icons.directions_car_rounded,
  ),
  Listing(
    title: 'iPhone 14 Pro',
    price: '£320',
    location: 'Birmingham',
    category: 'Buy & Sell',
    accent: AsanColors.purple,
    icon: Icons.phone_iphone_rounded,
  ),
  Listing(
    title: 'Nike Hoodie',
    price: '£45',
    location: 'Leeds',
    category: 'Buy & Sell',
    accent: AsanColors.pink,
    icon: Icons.checkroom_rounded,
  ),
];

class CategoryChip {
  const CategoryChip(this.id, this.label, this.icon, this.accent);
  final String id;
  final String label;
  final IconData icon;
  final Color accent;
}

const homeCategories = <CategoryChip>[
  CategoryChip('all', 'All', Icons.apps_rounded, AsanColors.gold),
  CategoryChip('buy_and_sell', 'Buy & Sell', Icons.shopping_bag_rounded, AsanColors.purple),
  CategoryChip('cars', 'Cars', Icons.directions_car_rounded, AsanColors.blue),
  CategoryChip('real_estate', 'Real Estate', Icons.home_rounded, AsanColors.green),
  CategoryChip('jobs', 'Jobs', Icons.work_rounded, AsanColors.cyan),
  CategoryChip('services', 'Services', Icons.handyman_rounded, AsanColors.coral),
];

class BrowseCategory {
  const BrowseCategory(this.id, this.label, this.icon, this.accent, this.count);
  final String id;
  final String label;
  final IconData icon;
  final Color accent;
  final int count;
}

const browseCategories = <BrowseCategory>[
  BrowseCategory('jobs', 'Jobs', Icons.work_outline_rounded, AsanColors.cyan, 0),
  BrowseCategory('services', 'Services', Icons.handyman_outlined, AsanColors.coral, 0),
  BrowseCategory('companies', 'Companies', Icons.apartment_rounded, AsanColors.blue, 0),
  BrowseCategory('shops', 'Shops', Icons.storefront_rounded, AsanColors.pink, 0),
  BrowseCategory('restaurants', 'Restaurants', Icons.restaurant_rounded, AsanColors.coral, 0),
  BrowseCategory('hotels', 'Hotels', Icons.hotel_rounded, AsanColors.purple, 0),
  BrowseCategory('doctors', 'Doctors', Icons.medical_services_rounded, AsanColors.green, 0),
  BrowseCategory('teachers', 'Teachers', Icons.school_rounded, AsanColors.cyan, 0),
  BrowseCategory('courses', 'Courses', Icons.menu_book_rounded, AsanColors.gold, 0),
  BrowseCategory('events', 'Events', Icons.event_rounded, AsanColors.pink, 0),
  BrowseCategory('freelancers', 'Freelancers', Icons.handshake_rounded, AsanColors.blue, 0),
  BrowseCategory('buy_and_sell', 'Buy & Sell', Icons.shopping_bag_outlined, AsanColors.purple, 0),
];

// ─── Shell + bottom nav ───────────────────────────────────────────────────────

class AsanShell extends StatefulWidget {
  const AsanShell({super.key});

  @override
  State<AsanShell> createState() => _AsanShellState();
}

class _AsanShellState extends State<AsanShell> {
  int _tab = 0;

  static const _titles = ['Home', 'Search', 'Add Post', 'Inbox', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AsanColors.navy,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AmbientBackground(),
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: switch (_tab) {
                0 => 0, // Home
                1 => 1, // Search
                3 => 2, // Inbox
                4 => 3, // Profile
                _ => 0,
              },
              children: const [
                HomeScreen(),
                _PlaceholderScreen(
                  title: 'Search',
                  subtitle: 'Find cars, homes, jobs & more',
                  icon: Icons.search_rounded,
                  accent: AsanColors.cyan,
                ),
                _PlaceholderScreen(
                  title: 'Inbox',
                  subtitle: 'Messages from buyers & sellers',
                  icon: Icons.chat_bubble_outline_rounded,
                  accent: AsanColors.pink,
                ),
                ProfileTabScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AsanBottomBar(
        currentIndex: _tab,
        onTap: (i) {
          if (i == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add Post — coming soon'),
                backgroundColor: AsanColors.navyLight,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          setState(() => _tab = i);
        },
        labels: _titles,
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AsanColors.navyDeep, AsanColors.navy, Color(0xFF0A1024)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _GlowBlob(AsanColors.purple.withValues(alpha: 0.22), 260),
            ),
            Positioned(
              top: 220,
              left: -90,
              child: _GlowBlob(AsanColors.pink.withValues(alpha: 0.14), 220),
            ),
            Positioned(
              bottom: 120,
              right: -40,
              child: _GlowBlob(AsanColors.cyan.withValues(alpha: 0.10), 180),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob(this.color, this.size);
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)],
      ),
    );
  }
}

class AsanBottomBar extends StatelessWidget {
  const AsanBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.labels,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom > 0 ? bottom : 12),
      child: SizedBox(
        height: 72,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: AsanColors.glassStrong,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AsanColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: labels[0],
                    selected: currentIndex == 0,
                    accent: AsanColors.pink,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: Icons.search_rounded,
                    activeIcon: Icons.search_rounded,
                    label: labels[1],
                    selected: currentIndex == 1,
                    accent: AsanColors.cyan,
                    onTap: () => onTap(1),
                  ),
                  const SizedBox(width: 64),
                  _NavItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    activeIcon: Icons.chat_bubble_rounded,
                    label: labels[3],
                    selected: currentIndex == 3,
                    accent: AsanColors.pink,
                    onTap: () => onTap(3),
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: labels[4],
                    selected: currentIndex == 4,
                    accent: AsanColors.pink,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -8,
              child: GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AsanColors.purple, AsanColors.pink, AsanColors.coral],
                    ),
                    border: Border.all(color: AsanColors.navyDeep, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AsanColors.pink.withValues(alpha: 0.45),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? accent : AsanColors.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home (marketplace) ───────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _activeCategory = 'all';

  List<Listing> get _filteredFeatured {
    if (_activeCategory == 'all') return featuredListings;
    final label = homeCategories
        .firstWhere((c) => c.id == _activeCategory, orElse: () => homeCategories.first)
        .label;
    return featuredListings.where((l) => l.category == label).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: _HomeHeader()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: _SearchBar()),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        SliverToBoxAdapter(
          child: _CategoryRow(
            activeId: _activeCategory,
            onSelect: (id) => setState(() => _activeCategory = id),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Featured Listings',
            onViewAll: () {},
          ),
        ),
        const ContainedSliver(child: SizedBox(height: 14)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 248,
            child: _filteredFeatured.isEmpty
                ? const Center(
                    child: Text(
                      'No listings in this category yet',
                      style: TextStyle(color: AsanColors.muted),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredFeatured.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => FeaturedCard(listing: _filteredFeatured[i]),
                  ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(
          child: _SectionHeader(title: 'Browse by Category'),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: browseCategories
                  .map((c) => SizedBox(
                        width: (MediaQuery.sizeOf(context).width - 44) / 2,
                        child: BrowseCategoryTile(category: c),
                      ))
                  .toList(),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

/// Tiny helper so nested const lists stay tidy.
class ContainedSliver extends StatelessWidget {
  const ContainedSliver({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(child: child);
}

/// Official ASAN brand mark (navy A + gold wave + category arc).
class AsanLetterLogo extends StatelessWidget {
  const AsanLetterLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/asan-logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const AsanLetterLogo(size: 56),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ASAN',
                  style: TextStyle(
                    color: AsanColors.cream,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  'DISCOVER. CONNECT. GROW.',
                  style: TextStyle(
                    color: AsanColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          _IconChip(icon: Icons.notifications_none_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AsanColors.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AsanColors.border),
        ),
        child: Icon(icon, color: AsanColors.cream, size: 22),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AsanColors.glass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AsanColors.borderGlow.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: AsanColors.purple.withValues(alpha: 0.12),
              blurRadius: 18,
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AsanColors.cyan, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search cars, homes, jobs…',
                style: TextStyle(color: AsanColors.muted, fontSize: 15),
              ),
            ),
            Icon(Icons.tune_rounded, color: AsanColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.activeId, required this.onSelect});
  final String activeId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: homeCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final cat = homeCategories[i];
          final selected = cat.id == activeId;
          return GestureDetector(
            onTap: () => onSelect(cat.id),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: selected
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AsanColors.purple,
                              AsanColors.pink,
                              AsanColors.coral,
                            ],
                          )
                        : null,
                    color: selected ? null : AsanColors.glass,
                    border: Border.all(
                      color: selected ? Colors.transparent : cat.accent.withValues(alpha: 0.55),
                      width: 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AsanColors.pink.withValues(alpha: 0.35),
                              blurRadius: 16,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    cat.icon,
                    color: selected ? Colors.white : cat.accent,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat.label,
                  style: TextStyle(
                    color: selected ? AsanColors.cream : AsanColors.muted,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onViewAll});
  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AsanColors.cream,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: AsanColors.gold,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'View All',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class FeaturedCard extends StatefulWidget {
  const FeaturedCard({super.key, required this.listing});
  final Listing listing;

  @override
  State<FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<FeaturedCard> {
  bool _fav = false;

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    return Container(
      width: 176,
      decoration: BoxDecoration(
        color: AsanColors.glass,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AsanColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        l.accent.withValues(alpha: 0.35),
                        AsanColors.navyLight,
                      ],
                    ),
                  ),
                  child: Icon(l.icon, size: 48, color: l.accent.withValues(alpha: 0.9)),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => setState(() => _fav = !_fav),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                        border: Border.all(color: AsanColors.border),
                      ),
                      child: Icon(
                        _fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 16,
                        color: _fav ? AsanColors.pink : AsanColors.cream,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: l.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l.category,
                      style: const TextStyle(
                        color: AsanColors.navyDeep,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AsanColors.cream,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.price,
                  style: const TextStyle(
                    color: AsanColors.green,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l.location} · ${l.ago}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AsanColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BrowseCategoryTile extends StatelessWidget {
  const BrowseCategoryTile({super.key, required this.category});
  final BrowseCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AsanColors.glass,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: category.accent.withValues(alpha: 0.55), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: category.accent.withValues(alpha: 0.12),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: category.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: category.accent.withValues(alpha: 0.45)),
            ),
            child: Icon(category.icon, color: category.accent, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            category.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AsanColors.cream,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${category.count} listings',
            style: const TextStyle(color: AsanColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            color: AsanColors.cream,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Personal accounts are free. Business plans are Coming Soon.',
          style: TextStyle(color: AsanColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        _ProfileActionTile(
          icon: Icons.workspace_premium_rounded,
          accent: AsanColors.gold,
          title: 'Business Plans',
          subtitle: 'Coming Soon — notify us for every category',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BusinessPlansScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _ProfileActionTile(
          icon: Icons.verified_outlined,
          accent: AsanColors.cyan,
          title: 'Verification',
          subtitle: 'Free during launch across all categories',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification is free during launch'),
                backgroundColor: AsanColors.navyLight,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _ProfileActionTile(
          icon: Icons.grid_view_rounded,
          accent: AsanColors.purple,
          title: 'Categories',
          subtitle: '${MarketplaceCategory.all.length} marketplace categories',
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              backgroundColor: AsanColors.navyLight,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    const Text(
                      'ASAN categories',
                      style: TextStyle(
                        color: AsanColors.cream,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final c in MarketplaceCategory.all)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          c.label,
                          style: const TextStyle(color: AsanColors.cream),
                        ),
                        subtitle: Text(
                          c.id,
                          style: const TextStyle(
                            color: AsanColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AsanColors.glass,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AsanColors.cream,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AsanColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AsanColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.14),
                border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.5),
              ),
              child: Icon(icon, size: 40, color: accent),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: AsanColors.cream,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AsanColors.muted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
