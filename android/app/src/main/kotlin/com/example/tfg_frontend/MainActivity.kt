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

// actividad principal de android que conecta flutter con codigo nativo
// aqui se manejan permisos, alarmas y llamadas desde flutter
class MainActivity : FlutterActivity() {
    // canal de comunicacion entre flutter y android nativo
    private val CHANNEL = "android_permission_service"

    // codigos para identificar respuestas de permisos
    private val PERMISSION_REQUEST_CODE = 100
    private val CALL_PERMISSION_CODE = 101

    // instancia del gestor de alarmas
    private lateinit var alarmScheduler: AlarmScheduler

    // callback para manejar resultado del permiso de llamada
    private var callPermissionResult: ((Boolean) -> Unit)? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // inicializa el gestor de alarmas con el contexto actual
        alarmScheduler = AlarmScheduler(this)

        // define el canal de comunicacion con flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            when (call.method) {

                // comprueba si se pueden programar alarmas exactas
                "canScheduleExactAlarms" -> {
                    val alarmManager =
                        getSystemService(Context.ALARM_SERVICE) as AlarmManager

                    val canSchedule =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            alarmManager.canScheduleExactAlarms()
                        } else {
                            true
                        }

                    result.success(canSchedule)
                }

                // abre ajustes del sistema para permisos de alarmas exactas
                "openExactAlarmSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val intent =
                            Intent(android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)

                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                    }

                    result.success(null)
                }

                // solicita permiso de notificaciones (android 13+)
                "requestPostNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {

                        val permission = Manifest.permission.POST_NOTIFICATIONS

                        if (ContextCompat.checkSelfPermission(this, permission)
                            != PackageManager.PERMISSION_GRANTED
                        ) {

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

                // solicita permiso de alarmas exactas (android 12+)
                "requestScheduleExactAlarmPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {

                        val permission = Manifest.permission.SCHEDULE_EXACT_ALARM

                        if (ContextCompat.checkSelfPermission(this, permission)
                            != PackageManager.PERMISSION_GRANTED
                        ) {

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

                // programa una alarma desde flutter
                "scheduleAlarm" -> {
                    val id = call.argument<Int>("id") ?: return@setMethodCallHandler
                    val timeMillis = call.argument<Long>("timeMillis")
                        ?: return@setMethodCallHandler
                    val title = call.argument<String>("title") ?: "Recordatorio"
                    val body =
                        call.argument<String>("body") ?: "Es hora de tomar tu medicamento"

                    alarmScheduler.scheduleExactAlarm(id, timeMillis, title, body)

                    result.success(true)
                }

                // cancela una alarma existente
                "cancelAlarm" -> {
                    val id = call.argument<Int>("id") ?: return@setMethodCallHandler
                    alarmScheduler.cancelAlarm(id)
                    result.success(true)
                }

                // inicia una llamada telefonica desde flutter
                "makeCall" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")

                    if (phoneNumber != null) {

                        val callService = CallService(this)

                        // si ya hay permiso, llama directamente
                        if (callService.canMakeCall()) {

                            val success = callService.makeCall(phoneNumber)
                            result.success(success)

                        } else {

                            // si no hay permiso, se solicita al usuario
                            callPermissionResult = { hasPermission ->
                                if (hasPermission) {
                                    val success =
                                        callService.makeCall(phoneNumber)
                                    result.success(success)
                                } else {
                                    result.error(
                                        "PERMISSION_DENIED",
                                        "permiso de llamada denegado",
                                        null
                                    )
                                }
                                callPermissionResult = null
                            }

                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.CALL_PHONE),
                                CALL_PERMISSION_CODE
                            )
                        }

                    } else {
                        result.error(
                            "INVALID_ARGUMENT",
                            "numero de telefono no proporcionado",
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    // resultado de peticiones de permisos del sistema
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        when (requestCode) {

            CALL_PERMISSION_CODE -> {

                if (grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED
                ) {

                    callPermissionResult?.invoke(true)

                } else {

                    callPermissionResult?.invoke(false)
                }
            }
        }
    }
}