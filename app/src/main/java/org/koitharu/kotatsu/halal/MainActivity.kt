package org.koitharu.kotatsu.halal

import android.app.Activity
import android.os.Bundle
import android.widget.ScrollView
import android.widget.TextView
import org.koitharu.kotatsu.parsers.model.MangaParserSource

class MainActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val parserList = MangaParserSource.entries
            .sortedBy { it.name }
            .joinToString(separator = "\n") { source ->
                val locale = source.locale.ifBlank { "global" }
                "- ${source.name} [$locale]"
            }

        val body = buildString {
            appendLine(getString(R.string.app_name))
            appendLine("Version: ${BuildConfig.VERSION_NAME}")
            appendLine("Repo: ${getString(R.string.repo_url)}")
            appendLine("Upstream: ${getString(R.string.upstream_url)}")
            appendLine()
            appendLine("Enabled parser sources (${MangaParserSource.entries.size}):")
            appendLine(parserList)
        }

        val padding = (24 * resources.displayMetrics.density).toInt()
        val textView = TextView(this).apply {
            setPadding(padding, padding, padding, padding)
            textSize = 16f
            text = body
        }

        setContentView(ScrollView(this).apply { addView(textView) })
    }
}
