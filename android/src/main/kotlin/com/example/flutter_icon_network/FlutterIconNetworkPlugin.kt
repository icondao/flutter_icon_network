package com.example.flutter_icon_network

import android.os.Build
import android.os.StrictMode
import android.util.Log
import androidx.annotation.NonNull
import foundation.icon.icx.data.TransactionResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.math.BigInteger


class FlutterIconNetworkPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

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
        val networkId: String? = call.argument("network_id")
        val host: String? = call.argument("host")
        when (call.method) {
            "createWallet" -> {
                val wallet: Map<String, String> = ICONWalletManager.getInstance().createWallet()
                result.success("{\"private_key\":\"${wallet["private_key"]}\",\"address\":\"${wallet["address"]}\"}")
            }
            "sendIcx" -> {
                val from: String? = call.argument("from")
                val to: String? = call.argument("to")
                val value: String? = call.argument("value")
                Log.v("sendIcx: ", "from $from to $to value $value")
                val txHash = ICONTransactionManager.getInstance(host, networkId).sendICX(from, value, to)
                result.success("{\"txHash\":\"${txHash}\",\"status\":0}")
            }
            "getIcxBalance" -> {
                val privateKey: String? = call.argument("private_key")
                val balance: BigInteger? = ICONTransactionManager.getInstance(host, networkId).getICXBalance(privateKey)
                result.success("{\"balance\":\"${balance}\"}")
            }
            "sendToken" -> {
                val from: String? = call.argument("from")
                val to: String? = call.argument("to")
                val value: String? = call.argument("value")
                val scoreAddress: String? = call.argument("score_address")
                Log.v("sendIcx: ", "from $from to $to value $value")
                val txHash = ICONSCOREManager.getInstance(host, networkId).sendToken(from, to, scoreAddress, value)
                result.success("{\"txHash\":\"${txHash}\",\"status\":0}")
            }
            "getTokenBalance" -> {
                val privateKey: String? = call.argument("private_key")
                val scoreAddress: String? = call.argument("score_address")
                val balance: BigInteger? = ICONSCOREManager.getInstance(host, networkId).getTokenBalance(privateKey, scoreAddress)
                result.success("{\"balance\":\"${balance}\"}")
            }
            "deployScore" -> {
                val privateKey: String? = call.argument("private_key")
                val initIcxSupply: String? = call.argument("init_icx_supply")
                val tResult: TransactionResult = ICONSCOREManager.getInstance(host, networkId).deployScore(privateKey, initIcxSupply)
                result.success("{\"score_address\":\"${tResult.scoreAddress}\", \"status\":\"${tResult.status}\",\"tx_hash\":\"${tResult.txHash}\", \"step_used\",\"${tResult.stepUsed}\"}")
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
