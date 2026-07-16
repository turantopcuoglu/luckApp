package com.turan.kader

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Ana ekran widget'ı sağlayıcısı.
 *
 * Veri, Flutter tarafından `home_widget` ile SharedPreferences'a yazılır
 * (bkz. HomeWidgetService); burada okunup [RemoteViews]'e basılır. Anahtar
 * adları Dart'taki WidgetConfig ile birebir eşleşmelidir. Widget'a
 * dokununca uygulama açılır.
 */
class KaderWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.kader_widget)

            // Anahtarlar Dart WidgetConfig ile aynı olmalı: skor/tarih/teaser.
            val skor = widgetData.getString("skor", null) ?: "--"
            val tarih = widgetData.getString("tarih", null) ?: ""
            val teaser = widgetData.getString("teaser", null) ?: ""

            views.setTextViewText(R.id.kader_widget_skor, skor)
            views.setTextViewText(R.id.kader_widget_tarih, tarih)
            views.setTextViewText(R.id.kader_widget_teaser, teaser)

            // Widget'a dokununca uygulamayı aç.
            val acilisIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.kader_widget_root, acilisIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
