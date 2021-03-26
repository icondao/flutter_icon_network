import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_icon_network/models/balance.dart';
import 'package:flutter_icon_network/models/send_icx_response.dart';
import 'package:flutter_icon_network/models/wallet.dart';
export 'package:flutter_icon_network/models/balance.dart';
export 'package:flutter_icon_network/models/send_icx_response.dart';
export 'package:flutter_icon_network/models/wallet.dart';

class FlutterIconNetwork {
  static const MethodChannel _channel =
      const MethodChannel('flutter_icon_network');
  String host;
  bool isTestNet;

  void init({String host, bool isTestNet}) {
    this.isTestNet = isTestNet;
    this.host = host;
  }

  Future<Balance> getBalance({String privateKey}) async {
    final String balance = await _channel.invokeMethod('getBalance',
        {'private_key': privateKey, "host": host, "network_id": _networkId});
    print("FlutterIconNetwork getBalance $balance");
    return balanceFromJson(balance);
  }

  Future<Wallet> get createWallet async {
    final String wallet = await _channel
        .invokeMethod('createWallet', {"host": host, "network_id": _networkId});
    print("FlutterIconNetwork createWallet $wallet");
    return walletFromJson(wallet);
  }

  Future<SendIcxResponse> sendIcx(
      {String from, String to, String value}) async {
    final String response = await _channel.invokeMethod('sendIcx', {
      "from": from,
      "to": to,
      "value": value,
      "host": host,
      "network_id": _networkId
    });
    print("FlutterIconNetwork sendIcx $response");
    return sendIcxResponseFromJson(response);
  }

  static FlutterIconNetwork get instance {
    _instance ??= FlutterIconNetwork._();
    return _instance;
  }

  static FlutterIconNetwork _instance;

  FlutterIconNetwork._();

  String get _networkId {
    if(Platform.isAndroid) {
      if(isTestNet) {
        return '3';
      } else {
        return '1';
      }
    } else {
      if(isTestNet) {
        return '0x3';
      } else {
        return '0x1';
      }
    }
  }
}
