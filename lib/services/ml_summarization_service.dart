import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Service to interact with on-device ML summarization using ML Kit GenAI (Gemini Nano)
///
/// This uses platform channels to call Android's ML Kit Summarization API
/// which provides true AI-powered summarization using Google's Gemini Nano model.
///
/// Note: Only available on Android devices with API level 26+
class MLSummarizationService {
  static const MethodChannel _channel =
      MethodChannel('com.example.pin_notes/ml_summarization');

  /// Check if ML Kit summarization is available on this device
  ///
  /// Returns true if:
  /// - Running on Android
  /// - Device has ML Kit Summarization feature
  /// - Gemini Nano model is downloaded or can be downloaded
  static Future<bool> isAvailable() async {
    // Only available on Android
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final bool? available = await _channel.invokeMethod('isAvailable');
      return available ?? false;
    } catch (e) {
      print('Error checking ML summarization availability: $e');
      return false;
    }
  }

  /// Summarize text using ML Kit GenAI (Gemini Nano)
  ///
  /// Takes the full note content and returns a concise AI-generated summary
  /// suitable for use as a title (4-5 words).
  ///
  /// Returns null if:
  /// - Summarization fails
  /// - Text is too short (< 400 characters)
  /// - ML Kit is not available
  /// - Any error occurs
  ///
  /// The caller should fall back to keyword extraction if this returns null.
  static Future<String?> summarizeForTitle(String text) async {
    // Only available on Android
    if (!Platform.isAndroid) {
      return null;
    }

    // ML Kit requires at least 400 characters
    if (text.length < 400) {
      return null;
    }

    try {
      final String? summary = await _channel.invokeMethod(
        'summarizeText',
        {'text': text},
      );
      return summary;
    } on PlatformException catch (e) {
      // Handle specific errors
      if (e.code == 'NOT_AVAILABLE') {
        print('ML Kit summarization not available on this device');
      } else if (e.code == 'SUMMARIZATION_FAILED') {
        print('Summarization failed: ${e.message}');
      } else {
        print('Platform error: ${e.code} - ${e.message}');
      }
      return null;
    } catch (e) {
      print('Error summarizing text: $e');
      return null;
    }
  }
}
