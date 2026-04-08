package com.example.tfg_frontend

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

// Maneja la programación de alarmas exactas con AlarmManager
//es más confiable que flutter_local_notifications para horarios específicos
class AlarmScheduler(private val context: Context) {
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    companion object {
        private const val TAG = "AlarmScheduler"
    }

    // Programa una alarma para que se dispare en un horario específico
    // si es Android 12+, intenta usar alarma exacta, sino usa inexacta como fallback
    fun scheduleExactAlarm(
        id: Int,
        triggerAtMillis: Long,
        title: String,
        body: String
    ) {
        try {
            // se crea el Intent que se envía al BroadcastReceiver cuando se dispara la alarma
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                putExtra("notification_id", id)
                putExtra("notification_title", title)
                putExtra("notification_body", body)
                // Acción única para cada alarma, así no se confunden los PendingIntents
                action = "com.example.tfg_frontend.ALARM_$id"
            }

            //Empaca el Intent en un PendingIntent para que el AlarmManager lo dispare
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Verifica la versión de android y programa dependiendo
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                // Android 12+: solo usa alarma exacta si tiene permisos
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerAtMillis,
                        pendingIntent
                    )
                    Log.d(TAG, "Alarm scheduled exact: ID=$id")
                } else {
                    // Si no tiene permiso de alarma exacta, usar inexacta como fallback
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerAtMillis,
                        pendingIntent
                    )
                    Log.d(TAG, "Alarm scheduled (inexact): ID=$id")
                }
            } else {
                // si android es menor a 12: usa la alarma exacta
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
                Log.d(TAG, "Alarm scheduled: ID=$id")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error scheduling alarm: ID=$id, ${e.message}")
            e.printStackTrace()
        }
    }

    // Cancela una alarma que ya estaba programada
    fun cancelAlarm(id: Int) {
        try {
            // Recrear el Intent con la misma action para encontrar la alarma correcta
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                action = "com.example.tfg_frontend.ALARM_$id"
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            // le dice al alarmManager que cancele esta alarma
            alarmManager.cancel(pendingIntent)
            Log.d(TAG, "Alarm cancelled: ID=$id")
        } catch (e: Exception) {
            Log.e(TAG, "Error cancelling alarm: ID=$id, ${e.message}")
        }
    }
}

