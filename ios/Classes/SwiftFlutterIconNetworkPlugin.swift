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
        switch call.method {
        case "createWallet":
            let wallet = ICONWalletManager.instance.createWallet()
            result("{\"private_key\":\"\(wallet.key.privateKey.hexEncoded)\",\"address\":\"\(wallet.address)\"}")
            break
        case "sendIcx":
            let argumentsMap = (call.arguments as! Dictionary<String, String>)
            let from = argumentsMap["from"]
            let to = argumentsMap["to"]
            let value = argumentsMap["value"]
            let txHash = ICONTransactionManager.instance.sendICX(from: from!, to: to!, value: value!)
            result("{\"txHash\":\"\(txHash)\",\"status\":0}")
            break
        case "getBalance":
            let argumentsMap = (call.arguments as! Dictionary<String, String>)
            let address = argumentsMap["address"]
            let balance = ICONWalletManager.instance.getBalance(address: address!)
            result("{\"balance\":\"\(balance)\"}")
            break
        default:
            print("unhandled method call \(call.method)")
        }
    }
}
