
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_icon_network/models/balance.dart';
import 'package:flutter_icon_network/models/send_icx_request.dart';
import 'package:flutter_icon_network/models/send_icx_response.dart';
import 'package:flutter_icon_network/models/wallet.dart';

export  'package:flutter_icon_network/models/balance.dart';
export 'package:flutter_icon_network/models/send_icx_request.dart';
export 'package:flutter_icon_network/models/send_icx_response.dart';
export 'package:flutter_icon_network/models/wallet.dart';

class FlutterIconNetwork {
  static const MethodChannel _channel =
      const MethodChannel('flutter_icon_network');

  static Future<Balance> getBalance({String privateKey}) async {
    final String balance = await _channel.invokeMethod('getBalance', {'private_key': privateKey});
    print("FlutterIconNetwork getBalance $balance");
    return balanceFromJson(balance);
  }

  static Future<Wallet> get createWallet async {
    final String wallet = await _channel.invokeMethod('createWallet');
    print("FlutterIconNetwork createWallet $wallet");
    return walletFromJson(wallet);
  }

  static Future<SendIcxResponse> sendIcx(SendIcxRequest request) async {
    final String response = await _channel.invokeMethod('sendIcx', request.toJson());
    print("FlutterIconNetwork sendIcx $response");
    return sendIcxResponseFromJson(response);
  }
}

