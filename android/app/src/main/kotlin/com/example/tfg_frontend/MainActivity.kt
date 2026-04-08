package com.example.tfg_frontend

import io.flutter.embedding.android.FlutterActivity

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.Manifest
import android.content.pm.PackageManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    // Canal para comunicar Flutter con el código nativo de Android
    private val CHANNEL = "android_permission_service"
    private val PERMISSION_REQUEST_CODE = 100 // código que se usará para identificar la solicitud de permisos
    private lateinit var alarmScheduler: AlarmScheduler // instancia de la clase que maneja las alarmas

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        alarmScheduler = AlarmScheduler(this) // se inicializa el AlarmScheduler con el contexto de la actividad

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->

            // Maneja las llamadas que vienen desde Flutter a través del canal
            // dependiendo del método que se llame, se ejecuta una acción diferente
            when (call.method) {
                // Verifica si la app tiene permiso para programar alarmas exactas
                "canScheduleExactAlarms" -> {
                    val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager 
                    val canSchedule = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        alarmManager.canScheduleExactAlarms()
                    } else {
                        true
                    }
                    result.success(canSchedule) // devuelve el resultado a Flutter
                }
                //abre la configuración del sistema para que el usuario pueda otorgar el permiso de alarmas exactas
                "openExactAlarmSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val intent = Intent(android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                    }
                    result.success(null)
                }
                // solicita el permiso de notificaciones para Android 13+ y se devuelve el resultado a Flutter
                "requestPostNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        val permission = Manifest.permission.POST_NOTIFICATIONS
                        if (ContextCompat.checkSelfPermission(this, permission)
                            != PackageManager.PERMISSION_GRANTED) {
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(permission),
                                PERMISSION_REQUEST_CODE
                            )
                        }
                        result.success(true)
                    } else {
                        result.success(true)
                    }
                }
                // Solicita el permiso de programar alarmas exactas para Android 12+ y se devuelve el resultado a Flutter
                "requestScheduleExactAlarmPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val permission = Manifest.permission.SCHEDULE_EXACT_ALARM
                        if (ContextCompat.checkSelfPermission(this, permission)
                            != PackageManager.PERMISSION_GRANTED) {
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(permission),
                                PERMISSION_REQUEST_CODE
                            )
                        }
                        result.success(true)
                    } else {
                        result.success(true)
                    }
                }
                // Programa una alarma con los datos que se reciben desde Flutter
                "scheduleAlarm" -> {
                    val id = call.argument<Int>("id") ?: return@setMethodCallHandler
                    val timeMillis = call.argument<Long>("timeMillis") ?: return@setMethodCallHandler
                    val title = call.argument<String>("title") ?: "Recordatorio"
                    val body = call.argument<String>("body") ?: "Es hora de tomar tu medicamento"

                    alarmScheduler.scheduleExactAlarm(id, timeMillis, title, body)
                    result.success(true)
                }
                // Cancela la alarma
                "cancelAlarm" -> {
                    val id = call.argument<Int>("id") ?: return@setMethodCallHandler
                    alarmScheduler.cancelAlarm(id)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}