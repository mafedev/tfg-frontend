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

// este receiver se ejecuta cuando salta la alarma del recordatorio
class AlarmReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "AlarmReceiver" // para ver logs en depuracion
    }

    // se llama automaticamente cuando se dispara la alarma
    override fun onReceive(context: Context, intent: Intent) {
        // datos que vienen desde el scheduler de alarmas
        val notificationId = intent.getIntExtra("notification_id", 0)
        val title = intent.getStringExtra("notification_title") ?: "Recordatorio"
        val body = intent.getStringExtra("notification_body") ?: "Es hora de tomar tu medicamento"

        // intent para abrir la app cuando el usuario toque la notificación
        val clickIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }

        // pending intent porque la notificación se ejecuta fuera de la app
        val clickPendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            clickIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // sonido personalizado de la notificación
        val notificationSound = Uri.parse("android.resource://${context.packageName}/raw/alarm_sound")

        // construcción de la notificación
        val notification = NotificationCompat.Builder(context, "med_channel")
            .setContentTitle(title) // titulo visible
            .setContentText(body) // texto principal
            .setSmallIcon(R.drawable.notification_logo_blanco) // icono obligatorio
            .setAutoCancel(true) // se quita al tocarla
            .setPriority(NotificationCompat.PRIORITY_MAX) // prioridad alta por ser recordatorio
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC) // visible en pantalla bloqueo
            .setContentIntent(clickPendingIntent) // abre app al tocar
            .setSound(notificationSound) // sonido personalizado
            .setVibrate(longArrayOf(0, 500, 250, 500)) // patrón de vibración
            .setLights(0xFF0000FF.toInt(), 500, 500) // luz led si el móvil lo soporta
            .setCategory(NotificationCompat.CATEGORY_REMINDER) // tipo de notificación
            .build()

        try {
            // mostramos la notificación en el sistema
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            notificationManager.notify(notificationId, notification)
            Log.d(TAG, "notificación mostrada id=$notificationId")
        } catch (e: Exception) {
            Log.e(TAG, "error mostrando notificación: ${e.message}")
        }
    }
}
