import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pose_launcher.dart';

// ---------- Palette ----------
class KzColors {
  static const beige = Color(0xFFF5F3EF);
  static const sage  = Color(0xFFC8D3C0);
  static const glacier = Color(0xFFD6E4EC);
  static const text = Color(0xFF333333);
  static const card = Colors.white;
}

// ---------- Shell principal ----------
class NavShell extends StatefulWidget {
  const NavShell({super.key});
  @override
  State<NavShell> createState() => _NavShellState();
}

class _NavShellState extends State<NavShell> {
  Future<void> _openPose() => openPose(context); // délègue au launcher
  int _index = 0;
  late final List<Widget> _pages = const [
    HomePage(),
    ExercisesPage(),
    TrackingPage(),
    BreathingPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: TravertinPainter(seed: 42),
        child: SafeArea(child: _pages[_index]),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: 'Exercices'),
                BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Suivi'),
                BottomNavigationBarItem(icon: Icon(Icons.favorite_outline_rounded), label: 'Respire'),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Pages ----------
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ZenAppBar(title: 'KAISEN'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              ZenCard(
                icon: Icons.fitness_center_rounded,
                title: 'Exercices',
                subtitle: 'Caméra IA, corrections en direct',
                accent: KzColors.sage,
                onTap: () => openPose(context), // ← ouvre la vue pose
              ),
              ZenCard(
                icon: Icons.insights_rounded,
                title: 'Suivi douleur',
                subtitle: 'EVA avant/après, progression',
                accent: KzColors.glacier,
              ),
              ZenCard(
                icon: Icons.favorite_outline_rounded,
                title: 'Respiration',
                subtitle: 'Timers guidés • spiromètre',
                accent: KzColors.sage,
              ),
              ZenCard(
                icon: Icons.groups_rounded,
                title: 'Groupes (hôpital)',
                subtitle: 'Multi-patients • grand écran',
                accent: KzColors.glacier,
              ),
              ZenCard(
                icon: Icons.settings_rounded,
                title: 'Profil & Réglages',
                subtitle: 'Compte, casting écran, abonnement',
                accent: KzColors.sage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExercisesPage extends StatelessWidget {
  const ExercisesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _SimplePage(
      title: 'Exercices',
      child: Column(
        children: [
          const _ListTileZen(
            icon: Icons.directions_run_rounded,
            title: 'Squat assisté IA',
            subtitle: 'Détection des angles genou/hanche',
          ),
          const _ListTileZen(
            icon: Icons.accessibility_new_rounded,
            title: 'Élévation jambe',
            subtitle: 'Côté gauche/droit, 3x12',
          ),
          const _ListTileZen(
            icon: Icons.self_improvement_rounded,
            title: 'Étirement dos',
            subtitle: 'Respiration contrôlée',
          ),
          const SizedBox(height: 12),
          _PrimaryButton(
            label: 'Démarrer la caméra IA',
            onPressed: () => openPose(context), // même bouton pour Web/Mobile
          ),
        ],
      ),
    );
  }
}

class TrackingPage extends StatelessWidget {
  const TrackingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _SimplePage(
      title: 'Suivi douleur',
      child: Column(
        children: [
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EVA (0–10)', style: Theme.of(context).textTheme.titleMedium),
                  Slider(value: 3.5, min: 0, max: 10, onChanged: (_) {}),
                  const Text('Avant séance: 3.5 • Après séance: 2.0'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BreathingPage extends StatelessWidget {
  const BreathingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      title: 'Respiration',
      child: Text('Timers guidés & spiromètre BLE (à intégrer)'),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      title: 'Profil',
      child: Text('Infos patient, abonnement, réglages'),
    );
  }
}

// ---------- Composants ----------
class _ZenAppBar extends StatelessWidget {
  final String title;
  const _ZenAppBar({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: KzColors.text),
      ),
    );
  }
}

class _SimplePage extends StatelessWidget {
  final String title;
  final Widget child;
  const _SimplePage({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ZenAppBar(title: title),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [child])),
      ],
    );
  }
}

class ZenCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accent;
  final VoidCallback? onTap; // autoriser onTap dans ZenCard
  const ZenCard({super.key, required this.icon, required this.title, this.subtitle, required this.accent, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap, // utilisation du callback
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: KzColors.text),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                  if (subtitle != null)
                    Text(subtitle!, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54)),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListTileZen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _ListTileZen({required this.icon, required this.title, this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: KzColors.text),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: GoogleFonts.inter(fontSize: 13, color: Colors.black54))
            : null,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity, // optionnel: bouton pleine largeur
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: KzColors.sage,
          foregroundColor: KzColors.text,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed, // ✅ on garde le callback passé
        child: Text(
          label,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ---------- Fond Travertin ----------
class TravertinPainter extends CustomPainter {
  final int seed;
  TravertinPainter({this.seed = 0});
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [KzColors.beige, Colors.white],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    final r = Random(seed);
    for (int i = 0; i < 150; i++) {
      final dx = r.nextDouble() * size.width;
      final dy = r.nextDouble() * size.height;
      final radius = r.nextDouble() * 1.2 + 0.3;
      final dotPaint = Paint()..color = Colors.black.withOpacity(0.03);
      canvas.drawCircle(Offset(dx, dy), radius, dotPaint);
    }
  }
  @override
  bool shouldRepaint(covariant TravertinPainter oldDelegate) => false;
}
