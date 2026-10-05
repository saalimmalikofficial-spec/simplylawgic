package com.bettlebyte.simplylawgic

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class SmsReceiver : BroadcastReceiver() {
    companion object {
        var methodChannel: MethodChannel? = null
        const val TAG = "SmsReceiver"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            try {
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                val messageBody = StringBuilder()
                for (msg in messages) {
                    messageBody.append(msg.messageBody)
                }
                val fullMessage = messageBody.toString()
                Log.d(TAG, "SMS Received: $fullMessage")
                Log.d(TAG, "methodChannel is null? ${methodChannel == null}")
                Log.d(TAG, "MainActivity.methodChannel is null? ${MainActivity.methodChannel == null}")

                // Try both channels
                val channel = methodChannel ?: MainActivity.methodChannel
                if (channel != null) {
                    channel.invokeMethod("onSmsReceived", fullMessage)
                    Log.d(TAG, "MethodChannel invoked successfully")
                } else {
                    Log.e(TAG, "MethodChannel is NULL — cannot send to Flutter")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error parsing SMS: ${e.message}")
            }
        }
    }
}