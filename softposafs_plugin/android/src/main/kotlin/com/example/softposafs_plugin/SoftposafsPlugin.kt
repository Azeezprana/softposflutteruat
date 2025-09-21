package com.example.softposafs_plugin

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import com.cardtek.softpos.utils.SoftPosInfo
import com.cardtek.softpos.interfaces.*
import com.cardtek.softpos.SoftPosService
import com.cardtek.softpos.results.SoftPosError
import com.cardtek.softpos.constants.TransactionType
import com.cardtek.softpos.kernel.BeepType
import com.cardtek.softpos.constants.CardType
import com.cardtek.softpos.results.TransactionResult
import java.io.InputStream

class SoftposafsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var softPosService: SoftPosService
    private var activity: Activity? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "softposafs_plugin")
        channel.setMethodCallHandler(this)

        // Setup EventChannel to send real-time messages to Flutter UI
        val eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "softposafs_plugin_events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                Log.d("SoftposPlugin", "Flutter subscribed to event stream.")
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                Log.d("SoftposPlugin", "Flutter unsubscribed from event stream.")
            }
        })

        // ❌ DO NOT send events here — Flutter hasn't subscribed yet.
        // sendEventToFlutter("Please switch off developer opt.") ← REMOVED
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "initializeSDK" -> {
                initializeSoftPos()
                result.success("SDK Initialization started")
            }
            "checkPOSService" -> {
                checkPOSService()
                result.success("POS Service check started")
            }
            "registerDevice" -> {
                registerDevice()
                result.success("Device registration started")
            }
            "unregisterDevice" -> {
                unregisterDevice()
                result.success("Device unregistration started")
            }
            "startTransaction" -> {
                startTransaction()
                result.success("Please tap your card")
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventSink = null
    }

    // ————— ActivityAware Overrides —————

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d("SoftposPlugin", "Activity attached: ${activity?.javaClass?.simpleName}")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        Log.d("SoftposPlugin", "Activity detached (config change)")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.d("SoftposPlugin", "Activity reattached (config change)")
    }

    override fun onDetachedFromActivity() {
        activity = null
        Log.d("SoftposPlugin", "Activity fully detached")
    }

    // ————— SDK Initialization —————

    private fun initializeSoftPos() {
        Log.d("SoftposPlugin", "Starting SDK initialization...")

        try {
            val assetManager = context.assets
            val certificateInputStream: InputStream = assetManager.open("star.uat.afs.com.bh.crt")
            SoftPosInfo.setHostCertificate(certificateInputStream)
            Log.d("SoftposPlugin", "✅ SSL certificate loaded successfully.")
        } catch (e: Exception) {
            val errorMsg = "❌ Failed to load SSL certificate: ${e.message}"
            Log.e("SoftposPlugin", errorMsg, e)
            sendEventToFlutter(errorMsg)
            return
        }

        // ✅ Trim URL to avoid hidden whitespace issues
        SoftPosInfo.setUrl("https://soharpay.uat.afs.com.bh/core".trim())
        SoftPosInfo.setAcquirerId(300001)
        SoftPosInfo.setPinAppPackageName("context.aar")
        SoftPosInfo.setPinAppVersion(com.softpos.pin.BuildConfig.VERSION_NAME)
        SoftPosInfo.setConnectionTimeoutSec(60)
        SoftPosInfo.setHostName("*.afs.com")
        SoftPosInfo.enableForegroundDispatch()
        SoftPosInfo.setL2HostResponseTimeoutMs(180000)
        SoftPosInfo.setIsoDepTimeoutMs(15000)
        SoftPosInfo.enableFileLogging()
        SoftPosInfo.enableGeoCoordinates()

        SoftPosInfo.setDetectionListener(object : DetectionListener {
            override fun onRiskDetected() {
                Handler(Looper.getMainLooper()).post {
                    Log.e("SoftPosService", "⚠️ Risk detected in POS service")
                    sendEventToFlutter("⚠️ Risk detected in POS service. Please contact support.")
                }
            }
        })

        try {
            softPosService = SoftPosService(context)
            Log.d("SoftposPlugin", "SoftPosService instance created.")
        } catch (e: Exception) {
            val errorMsg = "❌ Failed to create SoftPosService: ${e.message}"
            Log.e("SoftposPlugin", errorMsg, e)
            sendEventToFlutter(errorMsg)
            return
        }

        sendEventToFlutter("⏳ Initializing SoftPOS SDK...")

        softPosService.initialize(object : InitializeListener {
            override fun onPOSReady() {
                Log.d("SoftPosInit", "✅ POS Ready. Proceed to checkPOSService.")
                sendEventToFlutter("✅ POS is ready. Please proceed to check POS service.")
            }

            override fun onRegisterNeed() {
                Log.d("SoftPosInit", "📱 Registration required.")
                sendEventToFlutter("📱 Device registration required. Please register your device.")
            }

            override fun onPermissionNeed(missingPermissions: ArrayList<String>) {
                val perms = missingPermissions.joinToString()
                Log.d("SoftPosInit", "🔐 Permissions required: $perms")
                sendEventToFlutter("🔐 Permissions needed: $perms. Grant them and retry SDK init.")
            }

            override fun onInitializeError(error: SoftPosError) {
                val userMessage = "❌ SDK Initialization failed. Code: ${error.getErrorCode()} - ${error.getErrorMessage()}"
                Log.e("SoftPosInit", userMessage)
                sendEventToFlutter(userMessage)
            }
        })
    }

    private fun checkPOSService() {
        Log.d("SoftPosCheck", "🔍 Checking POS Service...")
        sendEventToFlutter("🔍 Checking POS service... Please wait.")

        softPosService.checkPOSService(object : CheckPOSServiceListener {
            override fun onCheckPOSSuccess() {
                Log.d("SoftPosService", "✅ POS Service check successful.")
                sendEventToFlutter("✅ POS service check passed. You may now register or start transactions.")
            }

            override fun onCheckPOSError(error: SoftPosError) {
                val userMessage = "❌ POS service check failed. Code: ${error.getErrorCode()} - ${error.getErrorMessage()}"
                Log.e("SoftPosService", userMessage)
                sendEventToFlutter(userMessage)
            }
        })
    }

    private fun registerDevice() {
        val merchantId = "220000000209890"
        val terminalId = "22949347"
        val activationCode = "1"

        Log.d("SoftPosRegister", "📲 Registering device with merchantId: $merchantId...")
        sendEventToFlutter("📲 Registering device with merchant ID: $merchantId...")

        softPosService.register(merchantId, terminalId, activationCode, object : RegisterListener {
            override fun onRegisterSuccess() {
                Log.d("SoftPosRegister", "✅ Registration successful")
                sendEventToFlutter("✅ Device registered successfully. You may now start transactions.")
            }

            override fun onRegisterError(error: SoftPosError) {
                val userMessage = "❌ Device registration failed. Code: ${error.getErrorCode()} - ${error.getErrorMessage()}"
                Log.e("SoftPosRegister", userMessage)
                sendEventToFlutter(userMessage)
            }
        })
    }

    private fun unregisterDevice() {
        Log.d("SoftPosUnRegister", "🔄 Unregistering device...")
        sendEventToFlutter("🔄 Unregistering device...")

        softPosService.unregister(object : UnregisterListener {
            override fun onUnregisterSuccess() {
                Log.d("SoftPosUnRegister", "✅ Unregistration successful")
                sendEventToFlutter("✅ Device unregistered successfully.")
            }

            override fun onUnregisterError(error: SoftPosError) {
                val userMessage = "❌ Device unregistration failed. Code: ${error.getErrorCode()} - ${error.getErrorMessage()}"
                Log.e("SoftPosUnRegister", userMessage)
                sendEventToFlutter(userMessage)
            }
        })
    }

    private fun startTransaction() {
        val customMessage = "SampleMessage"
        val currentActivity = activity ?: run {
            val errorMsg = "❌ Cannot start transaction: No active screen. Please restart the app."
            Log.e("SoftposPlugin", errorMsg)
            sendEventToFlutter(errorMsg)
            return
        }

        sendEventToFlutter("💳 Please tap or insert your card to start payment...")
        Log.d("Transaction", "Starting transaction...")

        softPosService.startTransaction(
            1300L,
            TransactionType.SALE,
            10000,
            customMessage,
            currentActivity,
            object : TransactionListener {
                override fun onCardDetected() {
                    Log.d("Transaction", "📇 Card Detected")
                    sendEventToFlutter("📇 Card detected. Reading card data...")
                }

                override fun onCardReadSuccess() {
                    Log.d("Transaction", "✅ Card Read Successfully")
                    sendEventToFlutter("✅ Card read successfully. Processing transaction...")
                }

                override fun onCardReadFail() {
                    Log.e("Transaction", "❌ Card Read Failed")
                    sendEventToFlutter("❌ Failed to read card. Please try again.")
                }

                override fun onGoOnline(cardType: CardType) {
                    Log.d("Transaction", "🌐 Go Online: $cardType")
                    sendEventToFlutter("🌐 Communicating with bank for $cardType card...")
                }

                override fun onPlaySound(beepType: BeepType) {
                    Log.d("Transaction", "🔊 Play Sound: $beepType")
                    // Optional: sendEventToFlutter("🔊 Beep: $beepType")
                }

                override fun onCompleted(transactionResult: TransactionResult) {
                   // val refusalCode = transactionResult.refusalCode ?: "N/A"
                  //  val approved = transactionResult.approved // ← if available
                  //  val status = if (approved) "✅ Approved" else "❌ Declined"
                  //  val msg = "$status | Refusal Code: $refusalCode"
                  //  Log.d("Transaction", "Completed: $msg") 
                    Log.d("Transaction", "Transaction Completed: $transactionResult")
                    sendEventToFlutter("TransactionResult :  ${transactionResult}") 
                   
                }

                override fun onTimeout() {
                    Log.e("Transaction", "⏳ Transaction Timeout")
                    sendEventToFlutter("⏳ Transaction timed out. Please retry.")
                }

                override fun onStartTransactionError(error: SoftPosError) {
                    val userMessage = "❌ Transaction error: ${error.getErrorMessage()} (Code: ${error.getErrorCode()})"
                    Log.e("Transaction", userMessage)
                    sendEventToFlutter(userMessage)
                }
            }
        )
    }

    // ————— Helper: Send user-friendly message to Flutter UI —————
    // Uses EventChannel if subscribed, otherwise falls back to MethodChannel

    private fun sendEventToFlutter(message: String) {
        Handler(Looper.getMainLooper()).post {
            try {
                if (eventSink != null) {
                    eventSink?.success(message)
                    Log.d("SoftposPlugin", "Event sent via EventChannel: $message")
                } else {
                    // Fallback: send via MethodChannel if no stream listener yet
                    if (::channel.isInitialized) {
                        channel.invokeMethod("logEvent", message)
                        Log.d("SoftposPlugin", "Event sent via MethodChannel (fallback): $message")
                    } else {
                        Log.w("SoftposPlugin", "Dropping event (no channel or sink): $message")
                    }
                }
            } catch (e: Exception) {
                Log.w("SoftposPlugin", "Failed to send event to Flutter: $message", e)
            }
        }
    }
}