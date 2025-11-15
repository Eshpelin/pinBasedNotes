package com.example.pin_notes

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.mlkit.nl.genai.summarization.Summarization
import com.google.mlkit.nl.genai.summarization.SummarizationConfig
import com.google.mlkit.nl.genai.summarization.SummarizationFormat
import com.google.mlkit.nl.genai.summarization.Summarizer
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.pin_notes/ml_summarization"
    private var summarizer: Summarizer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // FLAG_SECURE: Prevent screenshots and screen recording
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )

        // Initialize ML Kit Summarizer
        initializeSummarizer()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "summarizeText" -> {
                    val text = call.argument<String>("text")
                    if (text != null) {
                        summarizeText(text, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Text cannot be null", null)
                    }
                }
                "isAvailable" -> {
                    checkAvailability(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun initializeSummarizer() {
        try {
            val config = SummarizationConfig.builder()
                .setFormat(SummarizationFormat.BULLET_POINTS)
                .setLength(1) // 1 bullet point for concise title
                .build()

            summarizer = Summarization.getClient(config)
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Failed to initialize summarizer: ${e.message}")
        }
    }

    private fun checkAvailability(result: MethodChannel.Result) {
        summarizer?.let { sum ->
            sum.checkAvailability()
                .addOnSuccessListener { available ->
                    result.success(available)
                }
                .addOnFailureListener { e ->
                    result.error("CHECK_FAILED", e.message, null)
                }
        } ?: result.success(false)
    }

    private fun summarizeText(text: String, result: MethodChannel.Result) {
        summarizer?.let { sum ->
            // First check if feature is available
            sum.checkAvailability()
                .addOnSuccessListener { available ->
                    if (!available) {
                        result.error("NOT_AVAILABLE", "ML Kit Summarization not available on this device", null)
                        return@addOnSuccessListener
                    }

                    // Feature is available, proceed with summarization
                    sum.summarize(text)
                        .addOnSuccessListener { summary ->
                            // Extract first line from bullet point summary
                            val title = extractTitleFromSummary(summary)
                            result.success(title)
                        }
                        .addOnFailureListener { e ->
                            result.error("SUMMARIZATION_FAILED", e.message, null)
                        }
                }
                .addOnFailureListener { e ->
                    result.error("CHECK_FAILED", e.message, null)
                }
        } ?: result.error("NOT_INITIALIZED", "Summarizer not initialized", null)
    }

    private fun extractTitleFromSummary(summary: String): String {
        // ML Kit returns bullet points like "• Summary text"
        // Extract and clean to create a concise title
        val cleaned = summary
            .trim()
            .removePrefix("•")
            .removePrefix("-")
            .removePrefix("*")
            .trim()

        // Limit to 4-5 words for title
        val words = cleaned.split("\\s+".toRegex())
        val title = words.take(5).joinToString(" ")

        return if (words.size > 5) "$title..." else title
    }

    override fun onDestroy() {
        super.onDestroy()
        summarizer?.close()
    }
}
