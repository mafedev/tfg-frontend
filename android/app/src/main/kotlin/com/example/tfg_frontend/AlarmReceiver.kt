package com.example.tfg_frontend

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import androidx.core.app.NotificationCompat
import android.util.Log

// Este BroadcastReceiver se dispara cuando llega la hora de la alarma
// Su trabajo es mostrar la notificación con sonido y vibración
class AlarmReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "AlarmReceiver"
    }

    // Se llama cuando la alarma se dispara
    // aquí extraemos los datos y mostramos la notificación
    override fun onReceive(context: Context, intent: Intent) {
        // Se extraen los datos que enviamos desde AlarmScheduler
        val notificationId = intent.getIntExtra("notification_id", 0)
        val title = intent.getStringExtra("notification_title") ?: "Recordatorio"
        val body = intent.getStringExtra("notification_body") ?: "Es hora de tomar tu medicamento"

        // Crear un Intent para abrir la app cuando el usuario toca la notificación
        val clickIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }

        // se empaca el Intent en un PendingIntent
        val clickPendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            clickIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // sonido personalizado
        val notificationSound = Uri.parse("android.resource://${context.packageName}/raw/alarm_sound")

        // construye la notificación con todos los efectos
        val notification = NotificationCompat.Builder(context, "med_channel")
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.drawable.notification_logo_blanco)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_MAX)  // prioridad alta para que se vea rápido
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(clickPendingIntent)  // que ocurre cuando se toca
            .setSound(notificationSound)  // Sonido personalizado
            .setVibrate(longArrayOf(0, 500, 250, 500))  //vibra 500ms, para, vibra 500ms
            .setLights(0xFF0000FF.toInt(), 500, 500)  // luz led
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .build()

        try {
            // muestra la notificación al usuario
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            notificationManager.notify(notificationId, notification)
            Log.d(TAG, "Notification displayed: ID=$notificationId")
        } catch (e: Exception) {
            Log.e(TAG, "Error displaying notification: ${e.message}")
        }
    }
}

