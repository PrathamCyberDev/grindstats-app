import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() {
  runApp(const GrindStatsApp());
}

class GrindStatsApp extends StatelessWidget {
  const GrindStatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrindStats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF001F3F),
          centerTitle: true,
        ),
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int pomodoros = 0;
  int runs = 0;
  int centuries = 0;

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pomodoros = prefs.getInt('pomodoros') ?? 0;
      runs = prefs.getInt('runs') ?? 0;
      centuries = prefs.getInt('centuries') ?? 0;
    });
  }

  Future<void> saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('pomodoros', pomodoros);
    prefs.setInt('runs', runs);
    prefs.setInt('centuries', centuries);
  }

  void addPomodoro() async {
    setState(() {
      pomodoros++;
      runs++;
      if (runs % 100 == 0) {
        centuries++;
        player.play(AssetSource('milestone.mp3'));
        _showMilestoneDialog();
      }
    });
    await saveStats();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔥 Pomodoro added 🔥'),
          backgroundColor: Colors.deepOrange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showMilestoneDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🏆 Milestone!"),
        content: Text("You've hit $centuries century${centuries > 1 ? 'ies' : 'y'}!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Keep Grinding!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🏏 GrindStats',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            tooltip: "Go to Pomodoro",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PomodoroPage(addPomodoro: addPomodoro)),
              );
            },
          ),
          // Removed milestone history button here
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset('assets/pratham.jpg', height: 140),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Prathamesh Khatawkar, 19",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Role: Showman", style: TextStyle(fontSize: 18)),
            const Text("About: Polymath, Grinder, Billionaire",
                style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            const Text(
              "\"Here to dominate. Relentlessly.\"",
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text("🏏 Runs: $runs", style: const TextStyle(fontSize: 22)),
            Text("💯 Centuries: $centuries", style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 30),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  '"Rise, my brother. Then rise again. Until rising is all we know."',
                  textStyle: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  speed: const Duration(milliseconds: 40),
                ),
              ],
              totalRepeatCount: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class PomodoroPage extends StatelessWidget {
  final VoidCallback addPomodoro;
  const PomodoroPage({super.key, required this.addPomodoro});

  void _confirmAndAddPomodoro(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Are you sure you want to add a Pomodoro?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              addPomodoro();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pomodoro")),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _confirmAndAddPomodoro(context),
          icon: const Icon(Icons.add),
          label: const Text("Add Pomodoro"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
    );
  }
}
