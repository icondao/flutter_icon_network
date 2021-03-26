import Flutter
import UIKit
import ICONKit

public class SwiftFlutterIconNetworkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_icon_network", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterIconNetworkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let argumentsMap = (call.arguments as! Dictionary<String, String>)
        let host = argumentsMap["host"]!
        let networkId = argumentsMap["network_id"]!
        switch call.method {
        case "createWallet":
            let wallet = ICONWalletManager.getInstance(host: host, networkId: networkId).createWallet()
            result("{\"private_key\":\"\(wallet.key.privateKey.hexEncoded)\",\"address\":\"\(wallet.address)\"}")
            break
        case "sendIcx":
            let from = argumentsMap["from"]
            let to = argumentsMap["to"]
            let value = argumentsMap["value"]
            let txHash = ICONTransactionManager.getInstance(host: host, networkId: networkId).sendICX(from: from!, to: to!, value: value!)
            result("{\"txHash\":\"\(txHash)\",\"status\":0}")
            break
        case "getBalance":
            let privateKey = argumentsMap["private_key"]
            let balance = ICONWalletManager.getInstance(host: host, networkId: networkId).getBalance(privateKey: privateKey!)
            result("{\"balance\":\"\(balance)\"}")
            break
        default:
            print("unhandled method call \(call.method)")
        }
    }
}
