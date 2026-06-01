package com.devflow.devflow

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class DevFlowWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        // home_widget 패키지가 저장한 SharedPreferences에서 데이터 읽기
        val widgetData = HomeWidgetPlugin.getData(context)

        val completed = widgetData.getInt("completed", 0)
        val total     = widgetData.getInt("total", 0)
        val streak    = widgetData.getInt("max_streak", 0)

        val progressText = if (total == 0) "오늘 루틴 없음" else "오늘 $completed / $total 완료"
        val progress     = if (total == 0) 0 else (completed * 100 / total)
        val streakText   = if (streak > 0) "🔥 최고 스트릭 ${streak}일" else ""

        val views = RemoteViews(context.packageName, R.layout.devflow_widget_layout)
        views.setTextViewText(R.id.widget_progress_text, progressText)
        views.setProgressBar(R.id.widget_progress_bar, 100, progress, false)
        views.setTextViewText(R.id.widget_streak_text, streakText)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
