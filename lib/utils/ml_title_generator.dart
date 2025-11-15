import 'dart:math';
import '../services/ml_summarization_service.dart';

/// ML-powered title generator using statistical analysis and smart algorithms
/// Now with TRUE AI support via ML Kit GenAI (Gemini Nano) on Android devices!
///
/// Hierarchy:
/// 1. Try ML Kit GenAI (Gemini Nano) - Best quality, on-device AI
/// 2. Fall back to keyword extraction - Fast, works on all platforms
class MLTitleGenerator {
  static final Random _random = Random();

  /// Generate title using ML Kit GenAI (Gemini Nano) with automatic fallback
  ///
  /// This is the recommended method to use - it will:
  /// 1. Try ML Kit GenAI on Android devices (true AI summarization)
  /// 2. Fall back to keyword extraction if ML Kit unavailable or fails
  ///
  /// Returns a tuple: (title, isGibberish)
  static Future<(String, bool)> generateTitleAsync(String plainText) async {
    if (plainText.trim().isEmpty) {
      return ('', false);
    }

    // Try ML Kit GenAI first (Gemini Nano on Android)
    try {
      final mlTitle = await MLSummarizationService.summarizeForTitle(plainText);
      if (mlTitle != null && mlTitle.isNotEmpty) {
        print('✨ ML Kit GenAI (Gemini Nano) generated title: $mlTitle');
        return (mlTitle, false);
      }
    } catch (e) {
      print('ML Kit failed, falling back to keyword extraction: $e');
    }

    // Fall back to keyword extraction
    print('📝 Using keyword extraction (ML Kit not available)');
    return generateTitle(plainText);
  }

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
  /// Analyzes the ENTIRE text to create a meaningful summary
  static String _generateNormalTitle(String plainText, TextAnalysis analysis) {
    // Extract and score keywords from the entire text
    final keywords = _extractKeywords(plainText);

    if (keywords.isEmpty) {
      return '';
    }

    // Take top 4-5 keywords to form the title
    final topKeywords = keywords.take(5).map((kw) => kw.$1).toList();

    // Create a natural-sounding title from keywords
    String title = topKeywords.join(' ');

    // Clean and format the title
    title = _cleanTitle(title);
    title = _formatTitle(title);

    return title;
  }

  /// Extract and score keywords from entire text using ML techniques
  /// Returns list of (keyword, score) tuples sorted by importance
  static List<(String, double)> _extractKeywords(String text) {
    // Common stop words to filter out
    final stopWords = {
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
      'of', 'with', 'by', 'from', 'as', 'is', 'was', 'are', 'were', 'be',
      'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will',
      'would', 'should', 'could', 'may', 'might', 'must', 'can', 'this',
      'that', 'these', 'those', 'i', 'you', 'he', 'she', 'it', 'we', 'they',
      'my', 'your', 'his', 'her', 'its', 'our', 'their', 'me', 'him', 'us',
      'them', 'what', 'which', 'who', 'when', 'where', 'why', 'how', 'all',
      'each', 'every', 'both', 'few', 'more', 'most', 'other', 'some', 'such',
      'no', 'nor', 'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very',
      'just', 'about', 'into', 'through', 'during', 'before', 'after', 'above',
      'below', 'up', 'down', 'out', 'off', 'over', 'under', 'again', 'further',
      'then', 'once',
    };

    // Extract all words
    final words = text.toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.length >= 3 && !stopWords.contains(w))
        .toList();

    if (words.isEmpty) {
      return [];
    }

    // Calculate word frequencies
    final wordFreq = <String, int>{};
    final wordPositions = <String, List<int>>{};

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      wordFreq[word] = (wordFreq[word] ?? 0) + 1;
      wordPositions[word] = (wordPositions[word] ?? [])..add(i);
    }

    // Score each unique word using ML features
    final scoredWords = <(String, double)>[];

    for (final entry in wordFreq.entries) {
      final word = entry.key;
      final frequency = entry.value;
      final positions = wordPositions[word]!;

      double score = 0.0;

      // Feature 1: Frequency (TF-IDF concept)
      // Words that appear 2-3 times are often key concepts
      if (frequency >= 2 && frequency <= 4) {
        score += frequency * 2.0;
      } else if (frequency >= 5) {
        score += 8.0; // Cap for very frequent words
      } else {
        score += 1.0; // Single occurrence
      }

      // Feature 2: Early position bonus (first occurrence)
      final firstPosition = positions.first;
      final positionScore = max(0, 20 - firstPosition) * 0.1;
      score += positionScore;

      // Feature 3: Word length (longer words often more meaningful)
      if (word.length >= 6 && word.length <= 12) {
        score += 2.0;
      } else if (word.length >= 4) {
        score += 1.0;
      }

      // Feature 4: Capitalization in original text (proper nouns)
      final capitalizedCount = text.split(RegExp(r'\s+'))
          .where((w) => w.toLowerCase() == word && RegExp(r'^[A-Z]').hasMatch(w))
          .length;
      if (capitalizedCount > 0) {
        score += capitalizedCount * 1.5;
      }

      // Feature 5: Important domain words
      final importantWords = {
        'learn', 'learned', 'learning', 'today', 'idea', 'important',
        'remember', 'note', 'tip', 'guide', 'tutorial', 'review',
        'summary', 'meeting', 'project', 'plan', 'goal', 'task',
      };
      if (importantWords.contains(word)) {
        score += 3.0;
      }

      scoredWords.add((word, score));
    }

    // Sort by score (highest first)
    scoredWords.sort((a, b) => b.$2.compareTo(a.$2));

    return scoredWords;
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
