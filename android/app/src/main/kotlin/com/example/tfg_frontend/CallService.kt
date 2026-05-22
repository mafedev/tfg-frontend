package com.example.tfg_frontend

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import android.Manifest

// clase que se encarga de realizar llamadas desde la app
// centraliza la lógica para comprobar permisos y lanzar la llamada
class CallService(private val context: Context) {
    // comprueba si el usuario ha dado permiso para hacer llamadas
    fun canMakeCall(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.CALL_PHONE
        ) == PackageManager.PERMISSION_GRANTED
    }

        // realiza la llamada si hay permisos
    fun makeCall(phoneNumber: String): Boolean {
        return try {
            // se comprueba antes el permiso porque android lo exige por seguridad
            if (!canMakeCall()) {
                android.util.Log.e("CallService", "permiso CALL_PHONE no concedido")
                return false
            }
            // se crea la uri del numero de telefono
            val uri = Uri.fromParts("tel", phoneNumber, null)

            // intent de llamada directa
            val intent = Intent(Intent.ACTION_CALL, uri)

            // necesario para lanzar la actividad desde contexto no activity
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK

            // se inicia la llamada
            context.startActivity(intent)

            android.util.Log.d("CallService", "llamada iniciada a: $phoneNumber")
            true
        } catch (e: SecurityException) {
            // error típico si faltan permisos aunque se haya intentado llamar
            android.util.Log.e("CallService", "error de permisos para llamar", e)
            false
        } catch (e: Exception) {
            // cualquier otro error
            android.util.Log.e("CallService", "error iniciando llamada: ${e.message}", e)
            false
        }
    }
}
