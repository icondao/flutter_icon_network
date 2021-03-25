import Flutter
import UIKit

public class SwiftFlutterIconNetworkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_icon_network", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterIconNetworkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "createWallet":
        var wallet: Dictionary<String, String> = [:]
        wallet["private_key"] = "test pr key"
        wallet["address"] = "address"
        result("{\"private_key\":\"\(wallet["private_key"]!)\",\"address\":\"\(wallet["address"]!)\"}")
        break
    case "sendIcx":
        let argumentsMap = (call.arguments as! Dictionary<String, String>)
        let from = argumentsMap["from"]
        let to = argumentsMap["to"]
        let value = argumentsMap["value"]
        let txHash = "testHash"
        result("{\"txHash\":\"\(txHash)\",\"status\":0}")
        break
    case "getBalance":
        let argumentsMap = (call.arguments as! Dictionary<String, String>)
        let privateKey = argumentsMap["private_key"]
        let balance = "100000000000000"
        result("{\"balance\":\"\(balance)\"}")
        break
    default:
        print("unhandled method call \(call.method)")
    }
//    result("iOS " + UIDevice.current.systemVersion)
  }
}
