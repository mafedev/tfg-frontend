package com.example.tfg_frontend

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import android.Manifest

class CallService(private val context: Context) {
    
    fun canMakeCall(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.CALL_PHONE
        ) == PackageManager.PERMISSION_GRANTED
    }
    
    fun makeCall(phoneNumber: String): Boolean {
        return try {
            // Verificar que el permiso esté disponible
            if (!canMakeCall()) {
                android.util.Log.e("CallService", "Permiso CALL_PHONE no concedido")
                return false
            }
            
            val uri = Uri.fromParts("tel", phoneNumber, null)
            val intent = Intent(Intent.ACTION_CALL, uri)
            
            // Agregar flags necesarios
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            
            context.startActivity(intent)
            android.util.Log.d("CallService", "Llamada iniciada a: $phoneNumber")
            true
        } catch (e: SecurityException) {
            android.util.Log.e("CallService", "SecurityException: Sin permisos para hacer llamadas", e)
            false
        } catch (e: Exception) {
            android.util.Log.e("CallService", "Error iniciando llamada: ${e.message}", e)
            false
        }
    }
}

