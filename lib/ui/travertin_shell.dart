import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pose_launcher.dart';
import '../services/pose_preloader.dart';

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
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _asked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_asked) {
      _asked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _askCamSheet());
    }
  }

  Future<void> _askCamSheet() async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pour bien vous guider, autorisez la caméra.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Plus tard"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final ok = await PosePreloader.instance.requestCameraWarmup();
                      if (!mounted) return;
                      final msg = ok ? "Caméra autorisée ✅" : "Caméra refusée ❌";
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg))
                      );
                    },
                    child: const Text("Autoriser"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});
  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> {
  bool bleConnected = false;
  bool running = false;
  Duration elapsed = Duration.zero;
  late final _Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = _Ticker((d) {
      if (!running) return;
      setState(() => elapsed = d);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _toggleRun() {
    setState(() {
      running = !running;
      if (running) {
        elapsed = Duration.zero;
        _ticker.start();
      } else {
        _ticker.stop();
      }
    });
  }

  void _pause() {
    setState(() {
      running = false;
      _ticker.stop();
    });
  }

  void _stop() {
    setState(() {
      running = false;
      elapsed = Duration.zero;
      _ticker.stop();
    });
  }

  Future<void> _connectBle() async {
    // TODO: intégrer flutter_blue_plus (scan/connexion au spiromètre)
    setState(() => bleConnected = !bleConnected);
  }

  Future<void> _testMeasure() async {
    // TODO: lecture d'une caractéristique (PEF/FEV1) + affichage valeur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(bleConnected
          ? 'Mesure test déclenchée (placeholder).'
          : 'Connectez le spiromètre d\'abord.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ZenAppBar(title: 'Respiration'),
      ],
      // On garde ton shell et on remplit le contenu ci‑dessous
    ).copyWithBelow(
      // Contenu scrollable
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            // Sous-titre (comme dans ta capture)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Ex: 5s expiration • 3s pause • 5 cycles',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
              ),
            ),

            // Guide visuel respiration
            AspectRatio(
              aspectRatio:  36 / 9,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: KzColors.glacier.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('(Guide visuel respiration)',
                      style: GoogleFonts.inter(color: Colors.black54)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bloc Spiromètre BLE
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _BleRow(),
              ),
            ),
            const SizedBox(height: 16),

            // Chrono
            Center(
              child: Text(
                _fmt(elapsed),
                style: GoogleFonts.inter(
                    fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 1.0),
              ),
            ),
            const SizedBox(height: 12),

            // Barre d'actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KzColors.sage,
                      foregroundColor: KzColors.text,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _toggleRun,
                    icon: const Icon(Icons.timer_outlined),
                    label: Text(running ? 'Recommencer' : 'Lancer',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pause,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Pause', style: GoogleFonts.inter()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _stop,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Terminer', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- widgets internes ------------------------------------------------------

  Widget _BleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Spiromètre BLE',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 6),
          Text('État: ${bleConnected ? 'Connecté' : 'Non connecté'}',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
        ]),
        Wrap(spacing: 8, children: [
          OutlinedButton(
            onPressed: _connectBle,
            child: Text(bleConnected ? 'Déconnecter' : 'Connecter'),
          ),
          TextButton(onPressed: _testMeasure, child: const Text('Tester mesure')),
        ]),
      ],
    );
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

// Petit ticker minimaliste pour le chrono (évite d'ajouter une dépendance)
class _Ticker {
  _Ticker(this.onTick);
  final void Function(Duration) onTick;
  bool _running = false;
  DateTime? _start;

  void start() {
    if (_running) return;
    _running = true;
    _start = DateTime.now();
    _loop();
  }

  void _loop() async {
    while (_running) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      onTick(DateTime.now().difference(_start!));
    }
  }

  void stop() => _running = false;
  void dispose() => _running = false;
}

// --- petite extension utilitaire pour empiler sous _ZenAppBar ---------------
extension _WithBelow on Widget {
  /// Permet d'écrire: Column(...).copyWithBelow(Expanded(child: ...))
  Widget copyWithBelow(Widget below) => Column(children: [this, below]);
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
