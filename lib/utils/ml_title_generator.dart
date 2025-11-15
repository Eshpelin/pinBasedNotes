import 'dart:math';

/// ML-powered title generator using statistical analysis and smart algorithms
/// This lightweight approach uses ML principles without requiring large models
class MLTitleGenerator {
  static final Random _random = Random();

  /// Funny titles for gibberish content
  static const List<String> _funnyGibberishTitles = [
    "Random Thoughts from Another Dimension",
    "My Cat Walked on the Keyboard",
    "The Secret Code Only I Understand",
    "Brain.exe Has Stopped Working",
    "Abstract Art in Text Form",
    "Encrypted Message from Future Me",
    "When Auto-Correct Gives Up",
    "Keyboard Smash Masterpiece",
    "The Language of Chaos",
    "Digital Hieroglyphics",
    "Matrix Code Leaked",
    "Password Generator Gone Wild",
    "My Head's Voice Transcribed",
    "WiFi Password Inspiration",
    "Modern Poetry at Its Finest",
    "Alien Transmission Decoded",
    "The Symphony of Random Keys",
    "Creative Chaos Chronicles",
    "Untranslatable Wisdom",
    "Quantum Thoughts Manifest",
  ];

  /// Generate title using ML-enhanced approach
  /// Returns a tuple: (title, isGibberish)
  static (String, bool) generateTitle(String plainText) {
    if (plainText.trim().isEmpty) {
      return ('', false);
    }

    // Step 1: Analyze text using ML features
    final analysis = _analyzeText(plainText);

    // Step 2: Detect gibberish using ML classification
    final isGibberish = _isGibberish(analysis);

    // Step 3: Generate appropriate title
    if (isGibberish) {
      return (_generateFunnyTitle(), true);
    } else {
      return (_generateNormalTitle(plainText, analysis), false);
    }
  }

  /// Analyze text and extract ML features
  static TextAnalysis _analyzeText(String text) {
    final normalized = text.toLowerCase();
    final length = text.length;

    // Feature 1: Character entropy (randomness measure)
    final entropy = _calculateEntropy(normalized);

    // Feature 2: Vowel to consonant ratio
    final vowelRatio = _calculateVowelRatio(normalized);

    // Feature 3: Word coherence score
    final wordScore = _calculateWordCoherenceScore(text);

    // Feature 4: Average word length
    final words = text.split(RegExp(r'\s+'));
    final avgWordLength = words.isEmpty
        ? 0.0
        : words.map((w) => w.length).reduce((a, b) => a + b) / words.length;

    // Feature 5: Special character density
    final specialCharDensity = _calculateSpecialCharDensity(text);

    // Feature 6: Number density
    final numberDensity = _calculateNumberDensity(text);

    // Feature 7: Consecutive consonants (indicates gibberish)
    final consecutiveConsonants = _maxConsecutiveConsonants(normalized);

    // Feature 8: Dictionary-like words ratio
    final dictionaryRatio = _calculateDictionaryRatio(words);

    return TextAnalysis(
      entropy: entropy,
      vowelRatio: vowelRatio,
      wordCoherenceScore: wordScore,
      avgWordLength: avgWordLength,
      specialCharDensity: specialCharDensity,
      numberDensity: numberDensity,
      consecutiveConsonants: consecutiveConsonants,
      dictionaryRatio: dictionaryRatio,
      textLength: length,
    );
  }

  /// ML-based gibberish detection using feature classification
  static bool _isGibberish(TextAnalysis analysis) {
    // Decision tree / Random forest approach
    int gibberishScore = 0;

    // High entropy suggests randomness
    if (analysis.entropy > 4.0) gibberishScore += 2;

    // Abnormal vowel ratio
    if (analysis.vowelRatio < 0.2 || analysis.vowelRatio > 0.6) {
      gibberishScore += 2;
    }

    // Low word coherence
    if (analysis.wordCoherenceScore < 0.3) gibberishScore += 3;

    // Too many special characters
    if (analysis.specialCharDensity > 0.3) gibberishScore += 2;

    // Too many numbers
    if (analysis.numberDensity > 0.5) gibberishScore += 2;

    // Many consecutive consonants
    if (analysis.consecutiveConsonants > 5) gibberishScore += 2;

    // Low dictionary word ratio
    if (analysis.dictionaryRatio < 0.4) gibberishScore += 3;

    // Very short or very long words on average
    if (analysis.avgWordLength < 2 || analysis.avgWordLength > 15) {
      gibberishScore += 1;
    }

    // Threshold-based classification (like a neural network decision boundary)
    return gibberishScore >= 8;
  }

  /// Calculate Shannon entropy (information theory / ML concept)
  static double _calculateEntropy(String text) {
    if (text.isEmpty) return 0.0;

    final freq = <String, int>{};
    for (final char in text.split('')) {
      freq[char] = (freq[char] ?? 0) + 1;
    }

    double entropy = 0.0;
    final length = text.length;

    for (final count in freq.values) {
      final probability = count / length;
      entropy -= probability * (log(probability) / ln2);
    }

    return entropy;
  }

  /// Calculate vowel to total letter ratio
  static double _calculateVowelRatio(String text) {
    const vowels = 'aeiou';
    int vowelCount = 0;
    int letterCount = 0;

    for (final char in text.split('')) {
      if (RegExp(r'[a-z]').hasMatch(char)) {
        letterCount++;
        if (vowels.contains(char)) vowelCount++;
      }
    }

    return letterCount == 0 ? 0.0 : vowelCount / letterCount;
  }

  /// Calculate word coherence using n-gram analysis
  static double _calculateWordCoherenceScore(String text) {
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    if (words.isEmpty) return 0.0;

    int coherentWords = 0;
    for (final word in words) {
      if (word.length < 2) continue;

      // Check for common English patterns
      if (_hasEnglishPattern(word)) {
        coherentWords++;
      }
    }

    return words.isEmpty ? 0.0 : coherentWords / words.length;
  }

  /// Check if word has common English patterns
  static bool _hasEnglishPattern(String word) {
    // Common English patterns and endings
    final commonPatterns = [
      'ing', 'ed', 'er', 'es', 'ly', 'tion', 'ment', 'ness',
      'ful', 'less', 'ity', 'able', 'ible', 'ous', 'ive',
      'th', 'ch', 'sh', 'ph', 'wh',
    ];

    for (final pattern in commonPatterns) {
      if (word.contains(pattern)) return true;
    }

    // Check for alternating vowel-consonant pattern
    const vowels = 'aeiou';
    int alternations = 0;
    bool wasVowel = vowels.contains(word[0]);

    for (int i = 1; i < word.length; i++) {
      final isVowel = vowels.contains(word[i]);
      if (isVowel != wasVowel) alternations++;
      wasVowel = isVowel;
    }

    return alternations >= word.length * 0.3;
  }

  /// Calculate special character density
  static double _calculateSpecialCharDensity(String text) {
    if (text.isEmpty) return 0.0;
    final specialChars = text.split('').where((c) =>
        !RegExp(r'[a-zA-Z0-9\s]').hasMatch(c)).length;
    return specialChars / text.length;
  }

  /// Calculate number density
  static double _calculateNumberDensity(String text) {
    if (text.isEmpty) return 0.0;
    final numbers = text.split('').where((c) =>
        RegExp(r'[0-9]').hasMatch(c)).length;
    return numbers / text.length;
  }

  /// Find maximum consecutive consonants
  static int _maxConsecutiveConsonants(String text) {
    const vowels = 'aeiou';
    int maxConsec = 0;
    int current = 0;

    for (final char in text.split('')) {
      if (RegExp(r'[a-z]').hasMatch(char) && !vowels.contains(char)) {
        current++;
        maxConsec = max(maxConsec, current);
      } else {
        current = 0;
      }
    }

    return maxConsec;
  }

  /// Calculate ratio of dictionary-like words
  static double _calculateDictionaryRatio(List<String> words) {
    if (words.isEmpty) return 0.0;

    int dictionaryLike = 0;
    for (final word in words) {
      final cleaned = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
      if (cleaned.length < 2) continue;

      // Simple heuristic: words with reasonable length and vowel distribution
      const vowels = 'aeiou';
      final vowelCount = cleaned.split('').where((c) =>
          vowels.contains(c)).length;
      final vowelRatio = vowelCount / cleaned.length;

      if (cleaned.length >= 2 && cleaned.length <= 20 &&
          vowelRatio >= 0.2 && vowelRatio <= 0.6) {
        dictionaryLike++;
      }
    }

    return dictionaryLike / words.length;
  }

  /// Generate a funny title for gibberish content
  static String _generateFunnyTitle() {
    return _funnyGibberishTitles[_random.nextInt(_funnyGibberishTitles.length)];
  }

  /// Generate normal title using ML-enhanced extraction
  static String _generateNormalTitle(String plainText, TextAnalysis analysis) {
    // Split into sentences
    final sentences = plainText.split(RegExp(r'[.!?\n]+'));

    // Score each sentence using ML features
    final scoredSentences = <(String, double)>[];

    for (final sentence in sentences) {
      final trimmed = sentence.trim();
      if (trimmed.isEmpty) continue;

      // ML scoring: position, length, word quality
      double score = 0.0;

      // Feature: Position (slight preference for earlier sentences)
      // Reduced bias to allow later, more substantive sentences to win
      final position = sentences.indexOf(sentence);
      score += max(0, 3 - position) * 0.2;

      // Feature: Length (ideal length is 30-80 chars)
      final length = trimmed.length;
      if (length >= 30 && length <= 80) {
        score += 3.0;
      } else if (length >= 15 && length <= 100) {
        score += 1.5;
      }

      // Feature: Word count (ideal is 4-8 words)
      final wordCount = trimmed.split(RegExp(r'\s+')).length;
      if (wordCount >= 4 && wordCount <= 8) {
        score += 2.0;
      } else if (wordCount >= 3 && wordCount <= 12) {
        score += 1.0;
      }

      // Feature: Starts with capital
      if (RegExp(r'^[A-Z]').hasMatch(trimmed)) {
        score += 1.0;
      }

      // Feature: Has important words (ML keyword extraction)
      final importantWords = ['how', 'why', 'what', 'today', 'learned',
          'idea', 'note', 'remember', 'important', 'tip'];
      for (final word in importantWords) {
        if (trimmed.toLowerCase().contains(word)) {
          score += 0.5;
        }
      }

      scoredSentences.add((trimmed, score));
    }

    if (scoredSentences.isEmpty) {
      return '';
    }

    // Select sentence with highest ML score
    scoredSentences.sort((a, b) => b.$2.compareTo(a.$2));
    String bestSentence = scoredSentences.first.$1;

    // Clean and format the title
    bestSentence = _cleanTitle(bestSentence);
    bestSentence = _formatTitle(bestSentence);

    return bestSentence;
  }

  /// Clean title by removing formatting
  static String _cleanTitle(String title) {
    // Remove markdown formatting
    title = title.replaceAll(RegExp(r'[*_`~#]'), '');

    // Remove multiple spaces
    title = title.replaceAll(RegExp(r'\s+'), ' ');

    // Remove leading/trailing punctuation
    title = title.replaceAll(RegExp(r'^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$'), '');

    return title.trim();
  }

  /// Format title with proper capitalization and length
  static String _formatTitle(String title) {
    if (title.isEmpty) return title;

    // Split into words
    final words = title.split(RegExp(r'\s+'));

    // Limit to maximum 4 words for concise titles
    const maxWords = 4;
    if (words.length > maxWords) {
      // Take first 4 words and remove common filler words if present
      final selectedWords = <String>[];
      final fillerWords = {'the', 'a', 'an', 'of', 'in', 'on', 'at', 'to', 'for'};

      for (final word in words) {
        if (selectedWords.length >= maxWords) break;

        // Skip filler words unless it's the first word or we need it
        if (selectedWords.isNotEmpty &&
            fillerWords.contains(word.toLowerCase()) &&
            selectedWords.length < words.length - 1) {
          continue;
        }

        selectedWords.add(word);
      }

      title = selectedWords.take(maxWords).join(' ');
    }

    // Capitalize first letter
    title = title[0].toUpperCase() + title.substring(1);

    // Add ellipsis if we truncated words
    if (words.length > maxWords) {
      title = '$title...';
    }

    return title;
  }
}

/// Text analysis result containing ML features
class TextAnalysis {
  final double entropy;
  final double vowelRatio;
  final double wordCoherenceScore;
  final double avgWordLength;
  final double specialCharDensity;
  final double numberDensity;
  final int consecutiveConsonants;
  final double dictionaryRatio;
  final int textLength;

  TextAnalysis({
    required this.entropy,
    required this.vowelRatio,
    required this.wordCoherenceScore,
    required this.avgWordLength,
    required this.specialCharDensity,
    required this.numberDensity,
    required this.consecutiveConsonants,
    required this.dictionaryRatio,
    required this.textLength,
  });

  @override
  String toString() {
    return 'TextAnalysis('
        'entropy: ${entropy.toStringAsFixed(2)}, '
        'vowelRatio: ${vowelRatio.toStringAsFixed(2)}, '
        'wordScore: ${wordCoherenceScore.toStringAsFixed(2)}, '
        'avgWordLen: ${avgWordLength.toStringAsFixed(2)}, '
        'gibberish: ${specialCharDensity > 0.3 || numberDensity > 0.5}'
        ')';
  }
}
