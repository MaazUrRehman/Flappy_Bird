import 'dart:math';
import 'package:flutter/material.dart';
import '../../game/flappy_bird_game.dart';

/// Word guessing game modal that appears when player wants to continue
class WordGameModal extends StatefulWidget {
  final FlappyBirdGame game;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const WordGameModal({
    super.key,
    required this.game,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<WordGameModal> createState() => _WordGameModalState();
}

class _WordGameModalState extends State<WordGameModal> {
  late WordGuessingGame _wordGame;
  final TextEditingController _guessController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _message = '';
  bool _isMessageError = false;
  int _attemptsLeft = 3;
  Set<String> _wrongGuesses = {};

  // Countdown state
  bool _showCountdown = false;
  int _countdown = 3;

  // Keyboard letter buttons
  final List<String> _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

  @override
  void initState() {
    super.initState();
    _initializeNewGame();
  }

  @override
  void dispose() {
    _guessController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeNewGame() {
    _wordGame = WordGuessingGame();
    _wordGame.pickRandomWord();
    _wordGame.generateMaskedWord();
    _wrongGuesses.clear();
    _attemptsLeft = 3;
    _message = '';
    _isMessageError = false;
    _showCountdown = false;
    _countdown = 3;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_focusNode.hasFocus == false) {
        _focusNode.requestFocus();
      }
    });
  }

  void _startCountdown() {
    setState(() {
      _showCountdown = true;
      _countdown = 3;
    });

    // Start countdown timer
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _showCountdown) {
        setState(() {
          _countdown = 2;
        });
        if (_countdown > 0) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted && _showCountdown) {
              setState(() {
                _countdown = 1;
              });
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted && _showCountdown) {
                  widget.onSuccess();
                }
              });
            }
          });
        }
      }
    });
  }

  void _handleLetterGuess(String letter) {
    if (_wordGame.isWordFullyGuessed()) return;
    if (_wrongGuesses.contains(letter)) return;

    setState(() {
      bool isCorrect = _wordGame.guessLetter(letter);

      if (isCorrect) {
        _message = '✓ Correct!';
        _isMessageError = false;

        if (_wordGame.isWordFullyGuessed()) {
          // Word completed - show success and start countdown
          _message = '🎉 Perfect! Get ready... 🎉';
          _isMessageError = false;
          _startCountdown();
        }
      } else {
        _wrongGuesses.add(letter);
        _attemptsLeft--;
        _message = '✗ Wrong guess! $_attemptsLeft attempts remaining';
        _isMessageError = true;

        if (_attemptsLeft <= 0) {
          _message = 'Game over! The word was "${_wordGame.originalWord.toUpperCase()}"';
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              widget.onCancel();
            }
          });
        }
      }

      _guessController.clear();
    });
  }

  void _handleTextGuess(String guess) {
    if (guess.isEmpty) return;
    if (_wordGame.isWordFullyGuessed()) return;

    setState(() {
      String upperGuess = guess.toUpperCase().trim();

      if (upperGuess.length == 1) {
        _handleLetterGuess(upperGuess);
      } else if (upperGuess.length > 1) {
        if (upperGuess == _wordGame.originalWord.toUpperCase()) {
          for (var char in _wordGame.originalWord.toUpperCase().split('')) {
            _wordGame.guessLetter(char);
          }
          _message = '🎉 Perfect! Get ready... 🎉';
          _isMessageError = false;
          _startCountdown();
        } else {
          _attemptsLeft--;
          _message = '✗ Wrong word! $_attemptsLeft attempts remaining';
          _isMessageError = true;

          if (_attemptsLeft <= 0) {
            _message = 'Game over! The word was "${_wordGame.originalWord.toUpperCase()}"';
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                widget.onCancel();
              }
            });
          }
        }
      }

      _guessController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: min(350, screenWidth * 0.9), // Responsive width
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF0F3460),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.amber.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: _showCountdown
            ? _buildCountdownWidget()
            : SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildWordDisplay(),
              const SizedBox(height: 12),
              _buildHintText(),
              const SizedBox(height: 15),
              _buildInputField(),
              const SizedBox(height: 12),
              _buildMessage(),
              const SizedBox(height: 12),
              _buildAttemptsRemaining(),
              const SizedBox(height: 15),
              _buildVirtualKeyboard(),
              const SizedBox(height: 12),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "🎉 WORD SOLVED! 🎉",
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withOpacity(0.2),
                  border: Border.all(color: Colors.amber, width: 3),
                ),
              ),
              Text(
                "$_countdown",
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Get ready to fly!",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: (3 - _countdown) / 3,
            backgroundColor: Colors.grey[800],
            color: Colors.green,
            minHeight: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.amber.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.games, color: Colors.amber, size: 24),
              Flexible(
                child: Text(
                  "WORD CHALLENGE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: constraints.maxWidth < 250 ? 14 : 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const Icon(Icons.help, color: Colors.amber, size: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWordDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Text(
        _getFormattedDisplayWord(),
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          fontFamily: 'monospace',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHintText() {
    if (_wordGame.originalWord.isEmpty || _wordGame.isWordFullyGuessed()) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "💡 Length: ${_wordGame.originalWord.length} letters | Remaining: ${_wordGame.getRemainingLettersCount()} unique letters",
        style: const TextStyle(
          color: Colors.blueAccent,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: TextField(
        controller: _guessController,
        focusNode: _focusNode,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        textCapitalization: TextCapitalization.characters,
        onSubmitted: (value) => _handleTextGuess(value),
        decoration: InputDecoration(
          hintText: 'Enter a letter or word...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
          prefixIcon: const Icon(Icons.edit, color: Colors.amber, size: 18),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send, color: Colors.amber, size: 18),
            onPressed: () => _handleTextGuess(_guessController.text),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    if (_message.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (_isMessageError ? Colors.red : Colors.green).withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _message,
        style: TextStyle(
          color: _isMessageError ? Colors.redAccent : Colors.greenAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAttemptsRemaining() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(3, (index) {
          return Icon(
            Icons.favorite,
            color: index < _attemptsLeft ? Colors.red : Colors.grey,
            size: 16,
          );
        }),
        const SizedBox(width: 6),
        Text(
          "${_wordGame.guessedLetters.length} / ${_wordGame.originalWord.split('').toSet().length} letters",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualKeyboard() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 180, // Limit keyboard height
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: _letters.map((letter) {
            bool isGuessed = _wordGame.guessedLetters.contains(letter.toLowerCase());
            bool isWrong = _wrongGuesses.contains(letter);
            bool isDisabled = isGuessed || isWrong || _wordGame.isWordFullyGuessed();

            return SizedBox(
              width: 32,
              height: 32,
              child: ElevatedButton(
                onPressed: isDisabled ? null : () => _handleLetterGuess(letter.toLowerCase()),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: isGuessed
                      ? Colors.green
                      : (isWrong
                      ? Colors.red.withOpacity(0.5)
                      : Colors.white.withOpacity(0.2)),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: isGuessed
                        ? BorderSide.none
                        : BorderSide(color: Colors.amber.withOpacity(0.5)),
                  ),
                ),
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => widget.onCancel(),
            icon: const Icon(Icons.close, size: 14),
            label: const Text("CANCEL", style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (_wordGame.isWordFullyGuessed())
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _startCountdown,
              icon: const Icon(Icons.play_arrow, size: 14),
              label: const Text("RESUME", style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getFormattedDisplayWord() {
    if (_wordGame.displayedWord.isEmpty) return '';
    return _wordGame.displayedWord
        .toUpperCase()
        .split('')
        .join(' ');
  }
}

// WordGuessingGame class remains the same as before...
class WordGuessingGame {
  static final Random _random = Random();

  static const List<String> _wordBank = [
    'bird', 'flame', 'apple', 'house', 'happy', 'flower', 'garden', 'rocket',
    'puzzle', 'guitar', 'planet', 'jungle', 'animal', 'forest', 'winter',
    'summer', 'spring', 'autumn', 'clouds', 'bridge', 'castle', 'dragon',
    'eagle', 'falcon', 'tiger', 'lion', 'panda', 'koala', 'zebra', 'camel',
    'ocean', 'river', 'mountain', 'valley', 'desert', 'island', 'sunset',
    'rainbow', 'butterfly', 'diamond', 'silver', 'golden', 'copper', 'bronze',
    'magic', 'sugar', 'honey', 'sweet', 'light', 'sound', 'music', 'dance'
  ];

  String originalWord = '';
  String displayedWord = '';
  Set<String> guessedLetters = {};

  String pickRandomWord() {
    List<String> validWords = _wordBank
        .where((word) => word.length >= 4 && word.length <= 8)
        .toList();

    if (validWords.isEmpty) {
      validWords = ['bird', 'fish', 'frog', 'bear', 'lion'];
    }

    originalWord = validWords[_random.nextInt(validWords.length)];
    guessedLetters.clear();
    displayedWord = '';
    return originalWord;
  }

  String generateMaskedWord() {
    if (originalWord.isEmpty) {
      pickRandomWord();
    }

    int wordLength = originalWord.length;
    int lettersToReveal = (wordLength / 2).ceil();

    List<int> indices = List.generate(wordLength, (i) => i);
    indices.shuffle(_random);

    Set<int> revealIndices = indices.take(lettersToReveal).toSet();

    List<String> maskedChars = List.generate(wordLength, (index) {
      if (revealIndices.contains(index)) {
        String letter = originalWord[index];
        guessedLetters.add(letter);
        return letter;
      } else {
        return '_';
      }
    });

    displayedWord = maskedChars.join('');
    return displayedWord;
  }

  bool guessLetter(String letter) {
    if (letter.isEmpty || letter.length > 1) {
      return false;
    }

    letter = letter.toLowerCase();

    if (guessedLetters.contains(letter)) {
      return false;
    }

    if (originalWord.contains(letter)) {
      guessedLetters.add(letter);
      _updateDisplayedWord();
      return true;
    }

    return false;
  }

  void _updateDisplayedWord() {
    List<String> newDisplay = List.generate(originalWord.length, (index) {
      String currentChar = originalWord[index];
      if (guessedLetters.contains(currentChar)) {
        return currentChar;
      }
      return '_';
    });

    displayedWord = newDisplay.join('');
  }

  bool isWordFullyGuessed() {
    return !displayedWord.contains('_');
  }

  void resetGame() {
    pickRandomWord();
    generateMaskedWord();
  }

  int getRemainingLettersCount() {
    Set<String> uniqueLetters = originalWord.split('').toSet();
    return uniqueLetters.difference(guessedLetters).length;
  }

  String getHint() {
    if (displayedWord.isEmpty) return '';

    for (int i = 0; i < displayedWord.length; i++) {
      if (displayedWord[i] == '_') {
        return originalWord[i];
      }
    }
    return '';
  }

  Map<String, dynamic> getGameStats() {
    return {
      'wordLength': originalWord.length,
      'revealedLetters': guessedLetters.length,
      'totalUniqueLetters': originalWord.split('').toSet().length,
      'progress': (displayedWord.replaceAll('_', '').length / originalWord.length * 100).round(),
      'isComplete': isWordFullyGuessed(),
    };
  }
}