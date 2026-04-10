import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ─────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────

class TeamMember {
  final String name;
  final String role;
  final String homeCountry;
  final String university;
  final String hobbies;
  final String motto;
  final Color color;

  const TeamMember({
    required this.name,
    required this.role,
    required this.homeCountry,
    required this.university,
    required this.hobbies,
    required this.motto,
    required this.color,
  });

  String get initials => name
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0])
      .join();
}

const List<TeamMember> kTeam = [
  TeamMember(
    name: 'Tomáš Bartoš',
    role: 'Team Member',
    homeCountry: 'Country',
    university: 'University',
    hobbies: 'Hobbies',
    motto: 'Motto',
    color: Color(0xFF4FC3F7),
  ),
  TeamMember(
    name: 'Christian Model',
    role: 'Team Member',
    homeCountry: 'Germany',
    university: 'THWS',
    hobbies: 'Running, Photography, Soccer, Padel, Coding',
    motto: 'make it happen',
    color: Color(0xFFFF8A65),
  ),
  TeamMember(
    name: 'Pradip Pokhrel',
    role: 'Team Member',
    homeCountry: 'Country',
    university: 'University',
    hobbies: 'Hobbies',
    motto: 'Motto',
    color: Color(0xFF81C784),
  ),
  TeamMember(
    name: 'Manuel Stöth',
    role: 'Team Member',
    homeCountry: 'Country',
    university: 'University',
    hobbies: 'Hobbies',
    motto: 'Motto',
    color: Color(0xFFCE93D8),
  ),
  TeamMember(
    name: 'Tai Mai',
    role: 'Team Member',
    homeCountry: 'Country',
    university: 'University',
    hobbies: 'Hobbies',
    motto: 'Motto',
    color: Color(0xFFFFD54F),
  ),
];

// ─────────────────────────────────────────────
// App
// ─────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Group 7's App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3F7),
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF0F1117),
          surfaceContainerHighest: const Color(0xFF1A1D26),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1D26),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const TeamScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen>
    with SingleTickerProviderStateMixin {
  // Infinite scroll trick: start at a large multiple so both arrow directions work
  static const int _loopOffset = 5000;

  int _realIndex = 0;
  late final PageController _pageController;
  late final AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  int get _initialVirtualPage => _loopOffset * kTeam.length;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _initialVirtualPage,
      viewportFraction: 0.48,
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  int get _currentVirtualPage =>
      (_pageController.hasClients ? _pageController.page?.round() : null) ??
      _initialVirtualPage;

  void _navigate(int delta) {
    final target = _currentVirtualPage + delta;
    final newReal = target % kTeam.length;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
    if (newReal != _realIndex) {
      _fadeCtrl.forward(from: 0);
      setState(() => _realIndex = newReal);
    }
  }

  void _onPageChanged(int virtualPage) {
    final newReal = virtualPage % kTeam.length;
    if (newReal != _realIndex) {
      _fadeCtrl.forward(from: 0);
      setState(() => _realIndex = newReal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final member = kTeam[_realIndex];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            _AppHeader(accentColor: member.color),

            // ── Carousel ────────────────────────────────
            _Carousel(
              pageController: _pageController,
              currentIndex: _realIndex,
              accentColor: member.color,
              onPageChanged: _onPageChanged,
              onPrev: () => _navigate(-1),
              onNext: () => _navigate(1),
            ),

            // ── Content ─────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    children: [
                      _AvatarCard(member: member),
                      const SizedBox(height: 12),
                      _AboutCard(member: member),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  final Color accentColor;
  const _AppHeader({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: accentColor.withOpacity(0.35), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Glowing dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.7),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'GROUP 7',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: 3,
            ),
          ),
          const Spacer(),
          Text(
            '${kTeam.length} MEMBERS',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.28),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Carousel
// ─────────────────────────────────────────────

class _Carousel extends StatelessWidget {
  final PageController pageController;
  final int currentIndex;
  final Color accentColor;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _Carousel({
    required this.pageController,
    required this.currentIndex,
    required this.accentColor,
    required this.onPageChanged,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D26),
        border: Border(
          bottom: BorderSide(color: accentColor.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Prev arrow
          _ArrowButton(icon: Icons.chevron_left_rounded, onTap: onPrev),

          // Infinite name scroller
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: null, // null = infinite
              onPageChanged: onPageChanged,
              itemBuilder: (context, virtualIndex) {
                final realIndex = virtualIndex % kTeam.length;
                final isSelected = realIndex == currentIndex;
                final member = kTeam[realIndex];
                return Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isSelected
                        ? Text(
                            member.name,
                            key: const ValueKey('name'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              letterSpacing: 0.5,
                            ),
                          )
                        : Container(
                            key: ValueKey('init_$realIndex'),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: member.color.withOpacity(0.1),
                              border: Border.all(
                                color: member.color.withOpacity(0.35),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                member.initials,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: member.color.withOpacity(0.7),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          // Next arrow
          _ArrowButton(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 46,
        height: 52,
        child: Icon(icon, color: Colors.white.withOpacity(0.6), size: 26),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Avatar Card
// ─────────────────────────────────────────────

class _AvatarCard extends StatelessWidget {
  final TeamMember member;
  const _AvatarCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              member.color.withOpacity(0.14),
              const Color(0xFF1A1D26),
              const Color(0xFF1A1D26),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            // Rings + initials
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer subtle ring
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: member.color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                // Inner avatar circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: member.color.withOpacity(0.12),
                    border: Border.all(color: member.color, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: member.color.withOpacity(0.35),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      member.initials,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: member.color,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Name
            Text(
              member.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 8),

            // Role chip
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: member.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: member.color.withOpacity(0.45), width: 1),
              ),
              child: Text(
                member.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: member.color,
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// About Card
// ─────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  final TeamMember member;
  const _AboutCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(Icons.public_outlined, 'Home Country', member.homeCountry),
      _Item(Icons.school_outlined, 'University', member.university),
      _Item(Icons.favorite_border_rounded, 'Hobbies', member.hobbies),
      _Item(Icons.format_quote_outlined, 'Motto', member.motto),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title with accent bar
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: member.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'ABOUT ME',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2-column grid using Row pairs
            for (int i = 0; i < items.length; i += 2) ...[
              Row(
                children: [
                  Expanded(
                    child: _AboutTile(
                      item: items[i],
                      accentColor: member.color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (i + 1 < items.length)
                    Expanded(
                      child: _AboutTile(
                        item: items[i + 1],
                        accentColor: member.color,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
              if (i + 2 < items.length) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final String value;
  const _Item(this.icon, this.label, this.value);
}

class _AboutTile extends StatelessWidget {
  final _Item item;
  final Color accentColor;
  const _AboutTile({required this.item, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 12, color: accentColor.withOpacity(0.85)),
              const SizedBox(width: 5),
              Text(
                item.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: accentColor.withOpacity(0.85),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              item.value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}