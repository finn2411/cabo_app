import 'package:flutter/material.dart';

// App entry point. Flutter starts here.
void main() {
  // runApp mounts the root widget into the screen.
  runApp(const CaboApp());
}

// ===== Theme =====

// Central place for app colors to keep the style consistent.
class CaboColors {
  static const Color paper = Color(0xFFF6F1E4);
  static const Color ink = Color(0xFF2E2A24);
  static const Color feltGreen = Color(0xFF3E9A78);
  static const Color deepGreen = Color(0xFF2E7D62);
  static const Color orange = Color(0xFFE26A2C);
  static const Color butter = Color(0xFFFFF4D6);
}

const String _fontBaloo2 = 'Baloo2';
const String _fontLilitaOne = 'LilitaOne';

ThemeData _buildTheme() {
  final TextTheme base = ThemeData(fontFamily: _fontBaloo2).textTheme;
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: CaboColors.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: CaboColors.feltGreen,
      brightness: Brightness.light,
    ),
    textTheme: base.copyWith(
      titleLarge: TextStyle(
        fontFamily: _fontLilitaOne,
        fontSize: 28,
        color: CaboColors.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontLilitaOne,
        fontSize: 20,
        color: CaboColors.ink,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: CaboColors.feltGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: _fontLilitaOne,
        fontSize: 22,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CaboColors.orange,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: _fontLilitaOne,
          fontSize: 18,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CaboColors.ink,
        side: const BorderSide(color: CaboColors.orange, width: 2),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(
          fontFamily: _fontBaloo2,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CaboColors.butter,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

// ===== Models =====

// Simple data model for a player and their total score.
class PlayerScore {
  PlayerScore({
    required this.name,
    this.total = 0,
    this.resetUsed = false,
  });

  final String name;
  int total;

  // True once the "exact 100 -> reset to 50" rule has been used.
  bool resetUsed;
}

// Immutable snapshot used for the winner screen.
class FinalScore {
  FinalScore({required this.name, required this.total});

  final String name;
  final int total;
}

// ===== App Root =====

// Root widget that configures theme and sets the first screen.
class CaboApp extends StatelessWidget {
  const CaboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CABO',
      theme: _buildTheme(),
      // The initial screen the user sees.
      home: const CaboHomePage(),
    );
  }
}

// ===== Screens =====

// Home screen with a single action button.
class CaboHomePage extends StatelessWidget {
  const CaboHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CaboBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.63,
                  child: Image.asset(
                    'assets/logo/cabo_logo.png',
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigator pushes a new screen on top of the stack.
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PlayerSetupScreen(),
                    ),
                  );
                },
                child: const Text('Start Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Player setup screen with a simple list and add button.
class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  // Mutable list of player names for this setup screen.
  final List<String> _players = <String>[];
  // Controls the text field input so we can read and clear it.
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Adds a player name from the input field into the list.
  void _addPlayer() {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    setState(() {
      _players.add(name);
      _nameController.clear();
    });
  }

  // Starts the game only when the player count is valid.
  void _startGame() {
    if (_players.length < 2 || _players.length > 6) {
      return;
    }
    // Push the scoring screen and pass a copy of the list.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScoringScreen(players: List<String>.from(_players)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CaboBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add 2–6 players',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Player name',
                ),
                onSubmitted: (_) => _addPlayer(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _addPlayer,
                child: const Text('Add Player'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                // Disable until there are 2–6 players.
                onPressed: _players.length >= 2 && _players.length <= 6
                    ? _startGame
                    : null,
                child: const Text('Start Game'),
              ),
              const SizedBox(height: 16),
              Text(
                'Players:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _players.length,
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 8,
                  ),
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          _players[index],
                          style: const TextStyle(
                            fontFamily: _fontBaloo2,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: CaboColors.ink,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Scoring screen: enter round points and update totals with Cabo rules.
class ScoringScreen extends StatefulWidget {
  const ScoringScreen({super.key, required this.players});

  // Player names passed in from setup.
  final List<String> players;

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

// Private State class holds mutable data for the scoring screen.
class _ScoringScreenState extends State<ScoringScreen> {
  // Convert player names to mutable score objects.
  late final List<PlayerScore> _scores =
      widget.players.map((name) => PlayerScore(name: name)).toList();

  // One text controller per player for round input.
  late final List<TextEditingController> _roundControllers = List.generate(
    widget.players.length,
    (_) => TextEditingController(),
  );

  // Which player called Cabo this round (index into _scores).
  int? _caboCallerIndex;

  // History stack for undo (each entry stores totals + reset flags).
  final List<_RoundSnapshot> _history = <_RoundSnapshot>[];

  // Lock inputs once the game ends.
  bool _gameOver = false;

  @override
  void dispose() {
    for (final controller in _roundControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // SnackBar is a quick message at the bottom of the screen.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Applies the "exact 100" rule (once only).
  // If the player hits 100 the second time, the game ends.
  bool _applyExact100Rule(PlayerScore player) {
    if (player.total == 100) {
      if (player.resetUsed) {
        return true; // Game over condition.
      }
      player.total = 50;
      player.resetUsed = true;
    }
    return false;
  }

  // Check if the game is over and show the winner screen.
  void _checkGameOverAndShowWinner() {
    if (_gameOver) {
      return;
    }
    final int lowestTotal =
        _scores.map((p) => p.total).reduce((a, b) => a < b ? a : b);
    final List<String> winners =
        _scores.where((p) => p.total == lowestTotal).map((p) => p.name).toList();
    final List<FinalScore> finalScores = _scores
        .map((p) => FinalScore(name: p.name, total: p.total))
        .toList();

    setState(() {
      _gameOver = true;
    });

    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WinnerScreen(
          winners: winners,
          scores: finalScores,
        ),
      ),
    );
  }

  // Saves the current totals so we can restore them on Undo.
  void _saveSnapshot() {
    _history.add(
      _RoundSnapshot(
        totals: _scores.map((p) => p.total).toList(),
        resetUsed: _scores.map((p) => p.resetUsed).toList(),
      ),
    );
  }

  // Restores the most recent snapshot of totals.
  void _undoLastRound() {
    if (_history.isEmpty) {
      return;
    }
    final _RoundSnapshot last = _history.removeLast();
    setState(() {
      for (int i = 0; i < _scores.length; i++) {
        _scores[i].total = last.totals[i];
        _scores[i].resetUsed = last.resetUsed[i];
      }
      _gameOver = false;
    });
  }

  // Parse round inputs and apply Cabo rules.
  void _submitRound() {
    if (_caboCallerIndex == null) {
      _showMessage('Select the Cabo caller for this round.');
      return;
    }

    // Save current totals so Undo can restore them.
    _saveSnapshot();

    // Parse round points (empty => 0).
    final List<int> roundPoints = List<int>.generate(_scores.length, (i) {
      final String text = _roundControllers[i].text.trim();
      return int.tryParse(text) ?? 0;
    });

    final int lowest = roundPoints.reduce((a, b) => a < b ? a : b);
    final List<int> lowestIndexes = <int>[];
    for (int i = 0; i < roundPoints.length; i++) {
      if (roundPoints[i] == lowest) {
        lowestIndexes.add(i);
      }
    }

    bool gameOver = false;

    // setState tells Flutter to rebuild the UI with new values.
    setState(() {
      for (int i = 0; i < _scores.length; i++) {
        final PlayerScore player = _scores[i];
        int add = roundPoints[i];

        final bool isCaller = i == _caboCallerIndex;
        final bool isLowest = lowestIndexes.contains(i);
        final bool hasTie = lowestIndexes.length > 1;

        if (hasTie) {
          // Tie case:
          // If caller is tied for lowest, only caller gets 0, others keep points.
          // If caller is NOT tied for lowest, all lowest get 0.
          if (isCaller && isLowest) {
            add = 0;
          } else if (!isCaller && isLowest && _caboCallerIndex != null) {
            // Caller is not in the tie => all tied lowest get 0.
            add = 0;
          }
        } else {
          // Single lowest: lowest player gets 0.
          if (isLowest) {
            add = 0;
          }
        }

        // Caller penalty if not lowest (add +5).
        if (isCaller && !isLowest) {
          add += 5;
        }

        player.total += add;

        // Exact 100 reset (once). If hit 100 second time => game over.
        if (_applyExact100Rule(player)) {
          gameOver = true;
        }

        // Over 100 ends the game immediately.
        if (player.total > 100) {
          gameOver = true;
        }

        _roundControllers[i].clear();
      }
    });

    if (gameOver) {
      _checkGameOverAndShowWinner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CaboBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Enter round points',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              const Text('Tap a player to call CABO.'),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _scores.length,
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 8,
                  ),
                  itemBuilder: (context, index) {
                    final player = _scores[index];
                    final bool isCaller = _caboCallerIndex == index;
                    return InkWell(
                      onTap: _gameOver
                          ? null
                          : () => setState(() {
                                _caboCallerIndex = index;
                              }),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: isCaller
                              ? Border.all(
                                  color: CaboColors.orange,
                                  width: 3,
                                )
                              : null,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      player.name,
                                      style: const TextStyle(
                                        fontFamily: _fontBaloo2,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: CaboColors.ink,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      player.total.toString(),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontFamily: _fontLilitaOne,
                                        fontSize: 18,
                                        color: CaboColors.ink,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _roundControllers[index],
                                      enabled: !_gameOver,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText: 'Score',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCaller)
                              Positioned(
                                left: 90,
                                bottom: 20,
                                child: Text(
                                  'CABO!',
                                  style: const TextStyle(
                                    fontFamily: _fontLilitaOne,
                                    fontSize: 26,
                                    color: CaboColors.orange,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _gameOver || _history.isEmpty
                          ? null
                          : _undoLastRound,
                      child: const Text('Undo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _gameOver ? null : _submitRound,
                      child: const Text('Submit Round'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stores a snapshot of totals to support Undo.
class _RoundSnapshot {
  _RoundSnapshot({required this.totals, required this.resetUsed});

  final List<int> totals;
  final List<bool> resetUsed;
}

// Winner screen styled to match the paperlike theme.
class WinnerScreen extends StatelessWidget {
  const WinnerScreen({super.key, required this.winners, required this.scores});

  final List<String> winners;
  final List<FinalScore> scores;

  @override
  Widget build(BuildContext context) {
    final String titleText = winners.length == 1 ? 'Winner' : 'Winners';
    final List<FinalScore> sortedScores = List<FinalScore>.from(scores)
      ..sort((a, b) => a.total.compareTo(b.total));
    return Scaffold(
      body: CaboBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.63,
                    child: Image.asset(
                      'assets/logo/cabo_logo.png',
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Game Over!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: _fontLilitaOne,
                  fontSize: 28,
                  color: CaboColors.ink,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                titleText,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: CaboColors.butter,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: CaboColors.orange,
                    width: 2,
                  ),
                ),
                child: Text(
                  winners.join(', '),
                  style: const TextStyle(
                    fontFamily: _fontLilitaOne,
                    fontSize: 24,
                    color: CaboColors.orange,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Final scores',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: sortedScores.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final FinalScore score = sortedScores[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          score.name,
                          style: const TextStyle(
                            fontFamily: _fontBaloo2,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: CaboColors.ink,
                          ),
                        ),
                        trailing: Text(
                          score.total.toString(),
                          style: const TextStyle(
                            fontFamily: _fontLilitaOne,
                            fontSize: 18,
                            color: CaboColors.ink,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to Scoring'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('New Game'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Background with soft shapes to create a paperlike, playful feel.
class CaboBackground extends StatelessWidget {
  const CaboBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: CaboColors.paper,
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.2,
            child: Transform.scale(
              scale: 1.1,
              child: Image.asset(
                'assets/logo/card_back.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}
