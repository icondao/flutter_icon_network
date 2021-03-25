import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_icon_network/flutter_icon_network.dart';
import 'package:flutter_icon_network_example/constants.dart';
import 'package:flutter_icon_network_example/widgets/button.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BuildContext scaffoldContext;

  final privateKeyCtrl = TextEditingController();
  final walletAddressCtrl = TextEditingController();
  String currentBalance = "N/A";
  String txHash="";

  //send icx
  final senderCtrl = TextEditingController();
  final receiverCtrl = TextEditingController();
  final sendAmountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    senderCtrl.text = "c958108ccc79513ef9bf7647c29194199e3c5b86a88cbbc236dd5f74dfc37366";
    Future.delayed(Duration(seconds: 1), () {
      _getCache();
    });
  }

  @override
  void dispose() {
    privateKeyCtrl.dispose();
    walletAddressCtrl.dispose();
    senderCtrl.dispose();
    receiverCtrl.dispose();
    sendAmountCtrl.dispose();
    super.dispose();
  }

  void _createWallet() async {
    final wallet = await FlutterIconNetwork.createWallet;
    setState(() {
      privateKeyCtrl.text = wallet.privateKey;
      walletAddressCtrl.text = wallet.address;
      receiverCtrl.text = wallet.address;
    });
    Future.delayed(Duration(seconds: 2), () async {
      await _getBalance();
      _saveCache();
    });
  }

  void _sendIcx() async {
    final response = await FlutterIconNetwork.sendIcx(SendIcxRequest(
        from: senderCtrl.text ?? "",
        to: receiverCtrl.text ?? "",
        value: sendAmountCtrl.text ?? 0));
    _showSnackBar(
        "transaction hash ${response.txHash} copied, pls press check txHash button to check");
    Clipboard.setData(new ClipboardData(text: response.txHash));
    setState(() {
      txHash = "transaction/${response.txHash}";
    });
    Future.delayed(Duration(seconds: 5), () async {
      await _getBalance();
    });
  }

  Future<void> _getBalance() async {
    final balance = await FlutterIconNetwork.getBalance(privateKey: privateKeyCtrl.text);
    setState(() {
      currentBalance = balance.balance;
    });
    _saveCache();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Icon Network Example'),
        ),
        body: Builder(
          builder: (scaffoldContext) {
            this.scaffoldContext = scaffoldContext;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ..._buildWalletSection(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                  ),
                  ..._buildSendIcxSection(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                  ),
                  ..._buildGetBalanceSection(),
                  SizedBox(height: 50,),
                  AppSolidButton(
                    backgroundColor: Colors.red,
                    width: 200,
                    onTap: () {
                       launch("https://bicon.tracker.solidwallet.io/$txHash");
                    },
                    text: "press to check transaction hash",
                  ),
                  SizedBox(height: 10,),
                  AppSolidButton(
                    backgroundColor: Colors.red,
                    width: 200,
                    onTap: () {
                      launch("https://bicon.tracker.solidwallet.io/address/${walletAddressCtrl.text}");
                    },
                    text: "press to check wallet address",
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSnackBar(String text) {
    Scaffold.of(scaffoldContext).showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> _buildWalletSection() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSolidButton(onTap: _createWallet, text: "Create wallet"),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextField(
            controller: privateKeyCtrl,
          )),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextField(
            controller: walletAddressCtrl,
          ))
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(child: Center(child: _buildHint("privateKey"))),
          SizedBox(
            width: 10,
          ),
          Expanded(child: Center(child: _buildHint("walletAddress"))),
        ],
      )
    ];
  }

  List<Widget> _buildGetBalanceSection() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSolidButton(onTap: _getBalance, text: "Get balance"),
          SizedBox(
            width: 10,
          ),
          Expanded(child: Center(child: Text(currentBalance.isNotEmpty ? "$currentBalance" : "N/A"))),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(child: Center(child: _buildHint("current balance"))),
        ],
      )
    ];
  }

  List<Widget> _buildSendIcxSection() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSolidButton(onTap: _sendIcx, text: "Send ICX"),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextField(
            controller: senderCtrl,
          )),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextField(
            controller: receiverCtrl,
          )),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextField(
            controller: sendAmountCtrl,
          ))
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(child: Center(child: _buildHint("privateKey"))),
          SizedBox(
            width: 10,
          ),
          Expanded(child: Center(child: _buildHint("to"))),
          SizedBox(
            width: 10,
          ),
          Expanded(child: Center(child: _buildHint("value"))),
        ],
      )
    ];
  }

  void _saveCache() {
    GetStorage().write(StorageKey.balance, currentBalance);
    GetStorage().write(StorageKey.privateKey, privateKeyCtrl.text);
    GetStorage().write(StorageKey.walletAddress, walletAddressCtrl.text);
    GetStorage().write(StorageKey.sender, senderCtrl.text);
    GetStorage().write(StorageKey.receiver, receiverCtrl.text);
    GetStorage().write(StorageKey.sendAmount, sendAmountCtrl.text);
  }

  void _getCache() {
    setState(() {
      currentBalance = GetStorage().read<String>(StorageKey.balance)??"";
      privateKeyCtrl.text = GetStorage().read<String>(StorageKey.privateKey);
      walletAddressCtrl.text =
          GetStorage().read<String>(StorageKey.walletAddress);
      senderCtrl.text = GetStorage().read<String>(StorageKey.sender);
      receiverCtrl.text = GetStorage().read<String>(StorageKey.receiver);
      sendAmountCtrl.text = GetStorage().read<String>(StorageKey.sendAmount);
    });
  }

  Text _buildHint(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.grey, fontSize: 10),
    );
  }
}
