import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MemoryCardGame());
}

class MemoryCardGame extends StatelessWidget {
  const MemoryCardGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memory Card Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

// Game states
enum GameState { idle, inProgress, completed }

class _GameScreenState extends State<GameScreen> {
  GameState _gameState = GameState.idle;

  // Game settings
  int _cardCount = 16; // Default: 4x4 grid (8 pairs)

  // Player data
  int _currentPlayer = 1;
  int _player1Score = 0;
  int _player2Score = 0;

  // Game data
  late List<CardItem> _cards;
  List<int> _flippedCardIndices = [];
  String _statusMessage = "Tap 'Start Game' to begin";

  // List of available emoji card values
  final List<String> availableCardValues = [
    '😀',
    '😃',
    '😄',
    '😁',
    '😆',
    '😅',
    '😂',
    '🤣',
    '😊',
    '😇',
    '🙂',
    '🙃',
    '😉',
    '😌',
    '😍',
    '🥰',
    '😘',
    '😗',
    '😙',
    '😚',
    '😋',
    '😛',
    '😝',
    '😜',
    '🤪',
    '🤨',
    '🧐',
    '🤓',
    '😎',
    '🤩',
    '🥳',
    '😏',
    '😒',
    '😞',
    '😔',
    '😟',
    '😕',
    '🙁',
    '☹️',
    '😣',
    '😖',
    '😫',
    '😩',
    '🥺',
    '😢',
    '😭',
    '😤',
    '😠',
    '😡',
    '🤬',
    '🤯',
    '😳',
    '🥵',
    '🥶',
    '😱',
    '😨',
    '😰',
    '😥',
    '😓',
    '🤗',
    '🤔',
    '🤭',
    '🤫',
    '🤥',
    '😶',
    '😐',
    '😑',
    '😬',
    '🙄',
    '😯',
    '😦',
    '😧',
    '😮',
    '😲',
    '🥱',
    '😴',
    '🤤',
    '😪',
    '😵',
    '🤐',
    '🥴',
    '🤢',
    '🤮',
    '🤧',
    '😷',
    '🤒',
    '🤕',
    '🤑',
    '🤠',
    '😈',
    '👿',
    '👹',
    '👺',
    '🤡',
    '💩',
    '👻',
    '💀',
    '☠️',
    '👽',
    '👾',
  ];

  // Initialize the game
  void _initializeGame() {
    // Randomly select emojis for this game based on difficulty
    final random = Random();
    final List<String> selectedEmojis = [];
    final List<int> randomIndices = [];

    // Create a list of random indices
    while (randomIndices.length < _cardCount ~/ 2) {
      int randomIndex = random.nextInt(availableCardValues.length);
      if (!randomIndices.contains(randomIndex)) {
        randomIndices.add(randomIndex);
      }
    }

    // Select emojis based on random indices
    for (int index in randomIndices) {
      selectedEmojis.add(availableCardValues[index]);
    }

    // Create pairs of cards
    final List<CardItem> cardPairs = [];
    for (int i = 0; i < selectedEmojis.length; i++) {
      cardPairs.add(
        CardItem(value: selectedEmojis[i], isFlipped: false, isMatched: false),
      );
      cardPairs.add(
        CardItem(value: selectedEmojis[i], isFlipped: false, isMatched: false),
      );
    }

    // Shuffle the cards
    _cards = List.from(cardPairs);
    _cards.shuffle(random);

    // Reset game state
    _currentPlayer = 1;
    _player1Score = 0;
    _player2Score = 0;
    _flippedCardIndices = [];
    _statusMessage = "Player 1's turn. Pick a card.";

    setState(() {
      _gameState = GameState.inProgress;
    });
  }

  // Handle card tap
  void _handleCardTap(int index) {
    // Ignore if card is already flipped or matched
    if (_cards[index].isFlipped || _cards[index].isMatched) {
      return;
    }

    // Ignore if two cards are already flipped
    if (_flippedCardIndices.length >= 2) {
      return;
    }

    setState(() {
      // Flip the card
      _cards[index].isFlipped = true;
      _flippedCardIndices.add(index);

      // Update status message
      if (_flippedCardIndices.length == 1) {
        _statusMessage = "Player $_currentPlayer, pick one more card.";
      }

      // Check for match if two cards are flipped
      if (_flippedCardIndices.length == 2) {
        _checkForMatch();
      }
    });
  }

  // Check if the flipped cards match
  void _checkForMatch() {
    final int firstCardIndex = _flippedCardIndices[0];
    final int secondCardIndex = _flippedCardIndices[1];

    if (_cards[firstCardIndex].value == _cards[secondCardIndex].value) {
      // Cards match
      _statusMessage = "Match found! Player $_currentPlayer gets another turn.";

      // Update score
      if (_currentPlayer == 1) {
        _player1Score++;
      } else {
        _player2Score++;
      }

      // Mark cards as matched
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _cards[firstCardIndex].isMatched = true;
          _cards[secondCardIndex].isMatched = true;
          _flippedCardIndices.clear();

          // Check if game is over
          if (_cards.every((card) => card.isMatched)) {
            _gameState = GameState.completed;
            if (_player1Score > _player2Score) {
              _statusMessage = "Game Over! Player 1 wins!";
            } else if (_player2Score > _player1Score) {
              _statusMessage = "Game Over! Player 2 wins!";
            } else {
              _statusMessage = "Game Over! It's a tie!";
            }
          }
        });
      });
    } else {
      // Cards don't match
      _statusMessage =
          "No match. Switching to Player ${_currentPlayer == 1 ? 2 : 1}.";

      // Flip cards back after a delay
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _cards[firstCardIndex].isFlipped = false;
          _cards[secondCardIndex].isFlipped = false;
          _flippedCardIndices.clear();

          // Switch player
          _currentPlayer = _currentPlayer == 1 ? 2 : 1;
          _statusMessage = "Player $_currentPlayer's turn. Pick a card.";
        });
      });
    }

    // if isAiPlayer
    // if _currentPlayer == 2
    // pick random card from _cards.where((e)=>e.isFlipped == false && e.isMatched == false).toList()
  }

  // Build the game board
  Widget _buildGameBoard() {
    // Calculate grid dimensions
    int crossAxisCount;

    // Special case for medium difficulty (24 cards) - use 6x4 grid
    if (_cardCount == 24) {
      crossAxisCount = 6; // 6 columns, 4 rows
    } else {
      // For other difficulties, use square root as before
      crossAxisCount = sqrt(_cardCount).floor();
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        return _buildCard(index);
      },
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  // Build a card widget
  Widget _buildCard(int index) {
    return GestureDetector(
      onTap:
          _gameState == GameState.inProgress
              ? () => _handleCardTap(index)
              : null,
      child: FlipCard(card: _cards[index]),
    );
  }

  // Build the idle screen
  Widget _buildIdleScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Memory Card Game',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          const Text('Select difficulty:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          // secenek -> 2 kisilik - 1 kisilik -> isAiPlayer = true
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDifficultyButton('Easy', 16),
              const SizedBox(width: 10),
              _buildDifficultyButton('Medium', 24),
              const SizedBox(width: 10),
              _buildDifficultyButton('Hard', 36),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _initializeGame,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Start Game', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  // Build a difficulty selection button
  Widget _buildDifficultyButton(String label, int count) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _cardCount = count;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _cardCount == count ? Colors.blue : Colors.grey,
      ),
      child: Text(label),
    );
  }

  // Build the completed screen
  Widget _buildCompletedScreen() {
    String resultText;
    if (_player1Score > _player2Score) {
      resultText = 'Player 1 wins!';
    } else if (_player2Score > _player1Score) {
      resultText = 'Player 2 wins!';
    } else {
      resultText = "It's a tie!";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Game Over',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            resultText,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            'Player 1: $_player1Score points',
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            'Player 2: $_player2Score points',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _gameState = GameState.idle;
              });
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Play Again', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  // Build the in-progress screen
  Widget _buildInProgressScreen() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Player 1: $_player1Score',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    _currentPlayer == 1 ? FontWeight.bold : FontWeight.normal,
                color: _currentPlayer == 1 ? Colors.blue : Colors.black,
              ),
            ),
            Text(
              'Player 2: $_player2Score',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    _currentPlayer == 2 ? FontWeight.bold : FontWeight.normal,
                color: _currentPlayer == 2 ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _statusMessage,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: _buildGameBoard(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _gameState = GameState.idle;
              });
            },
            child: const Text('Restart Game'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Card Game')),
      body: SafeArea(
        child:
            _gameState == GameState.idle
                ? _buildIdleScreen()
                : _gameState == GameState.completed
                ? _buildCompletedScreen()
                : _buildInProgressScreen(),
      ),
    );
  }
}

// Card model
class CardItem {
  final String value;
  bool isFlipped;
  bool isMatched;

  CardItem({
    required this.value,
    required this.isFlipped,
    required this.isMatched,
  });
}

// Flip card widget
class FlipCard extends StatelessWidget {
  final CardItem card;

  const FlipCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color:
            card.isMatched
                ? const Color.fromRGBO(255, 255, 255, 0.3)
                : card.isFlipped
                ? Colors.white
                : Colors.blue,
        border: Border.all(color: Colors.black26, width: 1.0),
      ),
      child: Center(
        child:
            card.isFlipped || card.isMatched
                ? Text(
                  card.value,
                  style: TextStyle(
                    fontSize: 36.0,
                    color: card.isMatched ? Colors.grey : Colors.black,
                  ),
                )
                : const Icon(
                  Icons.question_mark,
                  color: Colors.white,
                  size: 30.0,
                ),
      ),
    );
  }
}
