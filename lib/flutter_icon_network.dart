import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_network/models/balance.dart';
import 'package:flutter_icon_network/models/send_icx_response.dart';
import 'package:flutter_icon_network/models/transaction_result.dart';
import 'package:flutter_icon_network/models/wallet.dart';
export 'package:flutter_icon_network/models/balance.dart';
export 'package:flutter_icon_network/models/send_icx_response.dart';
export 'package:flutter_icon_network/models/wallet.dart';
export 'package:flutter_icon_network/constant.dart';

/// A Flutter plugin to work with native Android/Ios sdk of Icon network
/// Native sdk: https://www.icondev.io/docs/sdk-overview
class FlutterIconNetwork {
  static const MethodChannel _channel =
      const MethodChannel('flutter_icon_network');
  String host;

  /// is test network or main network
  bool isTestNet;

  /// run once in your main.dart file
  ///
  /// FlutterIconNetwork.instance.init(host: "https://bicon.net.solidwallet.io/api/v3", isTestNet: true);
  void init({String host, bool isTestNet}) {
    this.isTestNet = isTestNet;
    this.host = host;
  }

  /// create a new wallet
  /// return the `Wallet` object that contain the `privateKey` and `address`
  ///
  /// ```final wallet = await FlutterIconNetwork.instance.createWallet;```
  Future<Wallet> get createWallet async {
    final String wallet = await _channel
        .invokeMethod('createWallet', {"host": host, "network_id": _networkId});
    print("FlutterIconNetwork createWallet $wallet");
    return walletFromJson(wallet);
  }

  /// return current icx balance
  ///
  /// ```final balance = await FlutterIconNetwork.instance.getIcxBalance(privateKey: yourPrivateKey);```
  Future<Balance> getIcxBalance({String privateKey}) async {
    final String balance = await _channel.invokeMethod('getIcxBalance',
        {'private_key': privateKey, "host": host, "network_id": _networkId});
    print("FlutterIconNetwork getIcxBalance $balance");
    return balanceFromJson(balance);
  }

  /// value is decimal, ex: '1'
  /// send Icx to an `address`
  /// return the `transaction hash`
  /// ```
  /// final txHash = await FlutterIconNetwork.instance.sendIcx(
  ///                         yourPrivateKey: yourPrivateKey,
  ///                         destinationAddress: address,
  ///                         value: 1
  ///                      )
  /// ```
  Future<SendIcxResponse> sendIcx(
      {String yourPrivateKey, String destinationAddress, String value}) async {
    final String response = await _channel.invokeMethod('sendIcx', {
      "from": yourPrivateKey,
      "to": destinationAddress,
      "value": value,
      "host": host,
      "network_id": _networkId
    });
    print("FlutterIconNetwork sendIcx $response");
    return sendIcxResponseFromJson(response);
  }

  /// to check the token balance in SCORE
  /// ```
  /// final balance = await FlutterIconNetwork.instance.getTokenBalance(
  ///                                     privateKey: privateKey,
  ///                                     scoreAddress: scoreAddress);
  /// ```
  Future<Balance> getTokenBalance({String privateKey, String scoreAddress}) async {
    final String balance = await _channel.invokeMethod('getTokenBalance',
        {'private_key': privateKey, 'score_address': scoreAddress, "host": host, "network_id": _networkId});
    print("FlutterIconNetwork getTokenBalance $balance");
    return balanceFromJson(balance);
  }

  ///deployContract: only available in android, on ios the sdk not support yet
  /// to deploy a SCORE by choose the zip file contain the source code
  /// the sample token zip file contain in source code, pls download it to your phone
  /// ```
  /// final transactionResult = await FlutterIconNetwork.instance.deployScore(
  ///                             privateKey: privateKey, initIcxSupply: "10");
  /// ```
  Future<TransactionResult> deployScore({String privateKey, String initIcxSupply}) async {
    if(Platform.isIOS) {
      return null;
    }
    Uint8List fileBytes = await readFile();

    final String result = await _channel.invokeMethod('deployScore',
        {'private_key': privateKey, 'init_icx_supply': initIcxSupply, "host": host, "network_id": _networkId, 'content': fileBytes});
    print("FlutterIconNetwork deployScore $result");
    return transactionResultFromJson(result);
  }

  Future<Uint8List> readFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if(result != null) {
      File file = File(result.files.single.path);
      return await file.readAsBytes();
    } else {
      return null;
    }
  }

  /// value is num of icx, ex: 1
  /// to send token to a address through SCORE
  /// ```
  /// final response = await FlutterIconNetwork.instance.sendToken(
  ///         yourPrivateKey: privateKey,
  ///         toAddress: receiverAddress,
  ///         value: numOfToken,
  ///         scoreAddress: scoreAddress
  ///        );
  /// ```
  Future<SendIcxResponse> sendToken(
      {String yourPrivateKey, String toAddress, String scoreAddress, String value}) async {
    final String response = await _channel.invokeMethod('sendToken', {
      "from": yourPrivateKey,
      "to": toAddress,
      "score_address": scoreAddress,
      "value": value,
      "host": host,
      "network_id": _networkId
    });
    print("FlutterIconNetwork sendToken $response");
    return sendIcxResponseFromJson(response);
  }

  /// singleton
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
