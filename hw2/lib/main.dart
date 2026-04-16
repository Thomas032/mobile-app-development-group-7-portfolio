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
  final String? imagePath;

  const TeamMember({
    required this.name,
    required this.role,
    required this.homeCountry,
    required this.university,
    required this.hobbies,
    required this.motto,
    required this.color,
    this.imagePath,
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
    name: 'Christian Model',
    role: 'Team Member',
    homeCountry: 'Germany',
    university: 'THWS',
    hobbies: 'Running, Photography, Soccer, Padel, Coding',
    motto: 'make it happen',
    color: Color(0xFFFF8A65),
    imagePath: 'assets/images/christian.jpg',
  ),
  TeamMember(
    name: 'Tomáš Bartoš',
    role: 'Team Member',
    homeCountry: 'Country',
    university: 'TAMK',
    hobbies: 'Hobbies',
    motto: 'Motto',
    color: Color(0xFF4FC3F7),
  ),
  TeamMember(
    name: 'Pradip Pokhrel',
    role: 'Team Member',
    homeCountry: 'Nepal',
    university: 'TAMK',
    hobbies: 'Hobbies',
    motto: 'Motto',
    color: Color(0xFF81C784),
  ),
  TeamMember(
    name: 'Manuel Stöth',
    role: 'Team Member',
    homeCountry: 'Germany',
    university: 'THWS',
    hobbies: 'Coding, Saxophone, Gaming',
    motto: 'Motto',
    color: Color(0xFFCE93D8),
  ),
  TeamMember(
    name: 'Tai Mai',
    role: 'Team Member',
    homeCountry: 'Country',
    university: 'TAMK',
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
        colorSchemeSeed: const Color(0xFF4FC3F7),
        brightness: Brightness.dark,
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

class _TeamScreenState extends State<TeamScreen> {
  int _currentIndex = 0;

  void _goToPrevious() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + kTeam.length) % kTeam.length;
    });
  }

  void _goToNext() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % kTeam.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final member = kTeam[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group 7'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 52,
              backgroundColor: member.color,
              backgroundImage: member.imagePath != null
                  ? AssetImage(member.imagePath!)
                  : null,
              child: member.imagePath == null
                  ? Text(
                      member.initials,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              member.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),

            // Role chip
            Chip(label: Text(member.role)),
            const SizedBox(height: 16),

            const Divider(),

            // Info card
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.flag_outlined),
                    title: const Text('Home Country'),
                    subtitle: Text(member.homeCountry),
                  ),
                  ListTile(
                    leading: const Icon(Icons.school_outlined),
                    title: const Text('University'),
                    subtitle: Text(member.university),
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite_outline),
                    title: const Text('Hobbies'),
                    subtitle: Text(member.hobbies),
                  ),
                  ListTile(
                    leading: const Icon(Icons.format_quote_outlined),
                    title: const Text('Motto'),
                    subtitle: Text(member.motto),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Navigation bar at the bottom
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              iconSize: 32,
              onPressed: _goToPrevious,
            ),
            Text(
              '${_currentIndex + 1} / ${kTeam.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              iconSize: 32,
              onPressed: _goToNext,
            ),
          ],
        ),
      ),
    );
  }
}
