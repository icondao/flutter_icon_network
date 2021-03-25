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
        break
    case "sendIcx":
        break
    case "getBalance":
        break
    default:
        print("unhandled method call \(call.method)")
    }
//    result("iOS " + UIDevice.current.systemVersion)
  }
}
