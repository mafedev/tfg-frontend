package com.example.tfg_frontend

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

// clase que se encarga de programar y cancelar alarmas del sistema
// usa alarmmanager porque permite ejecutar recordatorios incluso si la app está cerrada
class AlarmScheduler(private val context: Context) {

    // obtenemos el servicio del sistema para manejar alarmas
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    companion object {
        private const val TAG = "AlarmScheduler" // para logs
    }

    // programa una alarma en un momento exacto
    fun scheduleExactAlarm(
        id: Int,
        triggerAtMillis: Long,
        title: String,
        body: String
    ) {
        try {
            // intent que se enviará cuando salte la alarma
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                putExtra("notification_id", id)
                putExtra("notification_title", title)
                putExtra("notification_body", body)
                // action única para evitar conflictos entre alarmas
                action = "com.example.tfg_frontend.ALARM_$id"
            }

            // pendingintent porque el sistema lo ejecuta fuera de la app
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // android 12+ requiere permiso para alarmas exactas
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    // alarma exacta si hay permiso
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerAtMillis,
                        pendingIntent
                    )
                    Log.d(TAG, "alarm exacta programada id=$id")
                } else {
                    // fallback si no hay permiso
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerAtMillis,
                        pendingIntent
                    )
                    Log.d(TAG, "alarm inexacta programada id=$id")
                }
            } else {
                // versiones antiguas usan alarma exacta directamente
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
                Log.d(TAG, "alarm programada id=$id")
            }
        } catch (e: Exception) {
            Log.e(TAG, "error programando alarma id=$id: ${e.message}")
        }
    }

    // cancela una alarma ya programada
    fun cancelAlarm(id: Int) {
        try {
            // se recrea el mismo intent para encontrar la alarma
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                action = "com.example.tfg_frontend.ALARM_$id"
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            // se cancela la alarma en el sistema
            alarmManager.cancel(pendingIntent)
            Log.d(TAG, "alarm cancelada id=$id")
        } catch (e: Exception) {
            Log.e(TAG, "error cancelando alarma id=$id: ${e.message}")
        }
    }
}
