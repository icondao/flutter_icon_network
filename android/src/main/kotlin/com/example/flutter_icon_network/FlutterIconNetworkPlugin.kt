package com.example.flutter_icon_network

import android.os.Build
import android.os.StrictMode
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.math.BigInteger


/** FlutterIconNetworkPlugin */
class FlutterIconNetworkPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_icon_network")
    channel.setMethodCallHandler(this)

    val SDK_INT = Build.VERSION.SDK_INT
    if (SDK_INT > 8) {
      val policy = StrictMode.ThreadPolicy.Builder()
              .permitAll().build()
      StrictMode.setThreadPolicy(policy)
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when(call.method) {
      "createWallet" -> {
        val wallet: Map<String, String> = ICONWalletManager.getInstance().createWallet()
        result.success("{\"private_key\":\"${wallet["private_key"]}\",\"address\":\"${wallet["address"]}\"}")
      }
      "sendIcx" -> {
        val from: String? = call.argument("from")
        val to: String? = call.argument("to")
        val value: String? = call.argument("value")
        Log.v("sendIcx: ","from $from to $to value $value")
        val txHash = ICONTransactionManager.getInstance("https://bicon.net.solidwallet.io/api/v3").sendICX(from, value, to, false)
        result.success("{\"txHash\":\"${txHash}\",\"status\":0}")
      }
      "getBalance" -> {
        val address: String? = call.argument("address")
        val balance: BigInteger? = ICONTransactionManager.getInstance("https://bicon.net.solidwallet.io/api/v3").getICXBalance(address)
        result.success("{\"balance\":\"${balance}\"}")
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
