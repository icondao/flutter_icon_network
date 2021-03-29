import 'dart:io';

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
  FlutterIconNetwork.instance.init(host: "https://bicon.net.solidwallet.io/api/v3", isTestNet: true);
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
  double currentIcxBalance;
  double currentTokenBalance;
  String txHash="";

  //send icx
  final icxSenderCtrl = TextEditingController();
  final icxReceiverCtrl = TextEditingController();
  final icxSendAmountCtrl = TextEditingController();
  
  //score
  final scoreAddressCtrl = TextEditingController();
  final tokenReceiverAddressCtrl = TextEditingController();
  final tokenSendAmountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    icxSenderCtrl.text = IconConstant.samplePrivateKey;
    Future.delayed(Duration(seconds: 1), () {
      _getCache();
    });
  }

  @override
  void dispose() {
    privateKeyCtrl.dispose();
    walletAddressCtrl.dispose();
    icxSenderCtrl.dispose();
    icxReceiverCtrl.dispose();
    icxSendAmountCtrl.dispose();
    scoreAddressCtrl.dispose();
    tokenReceiverAddressCtrl.dispose();
    tokenSendAmountCtrl.dispose();
    super.dispose();
  }

  void _createWallet() async {
    final wallet = await FlutterIconNetwork.instance.createWallet;
    setState(() {
      privateKeyCtrl.text = wallet.privateKey;
      walletAddressCtrl.text = wallet.address;
      icxReceiverCtrl.text = wallet.address;
    });
    _saveCache();
  }

  void _sendIcx() async {
    final response = await FlutterIconNetwork.instance.sendIcx(yourPrivateKey: icxSenderCtrl.text ?? "",
        destinationAddress: icxReceiverCtrl.text ?? "",
        value: icxSendAmountCtrl.text ?? 0);
    _showSnackBar(
        "transaction hash ${response.txHash} copied, pls press check txHash button to check");
    Clipboard.setData(new ClipboardData(text: response.txHash));
    setState(() {
      txHash = "transaction/${response.txHash}";
    });
    Future.delayed(Duration(seconds: 5), () async {
      _getIcxBalance();
    });
  }

  void _getIcxBalance() async {
    final balance = await FlutterIconNetwork.instance.getIcxBalance(privateKey: privateKeyCtrl.text);
    setState(() {
      currentIcxBalance = balance.icxBalance;
    });
    _saveCache();
  }

  void _sendToken() async {
    final response = await FlutterIconNetwork.instance.sendToken(yourPrivateKey: privateKeyCtrl.text ?? "",
        toAddress: tokenReceiverAddressCtrl.text ?? "",
        value: tokenSendAmountCtrl.text, scoreAddress: scoreAddressCtrl.text);
    _showSnackBar(
        "transaction hash ${response.txHash} copied, pls press check txHash button to check");
    Clipboard.setData(new ClipboardData(text: response.txHash));
    setState(() {
      txHash = "transaction/${response.txHash}";
    });
    Future.delayed(Duration(seconds: 5), () async {
      _getTokenBalance();
    });
  }

  void _getTokenBalance() async {
    final balance = await FlutterIconNetwork.instance.getTokenBalance(privateKey: privateKeyCtrl.text, scoreAddress: scoreAddressCtrl.text);
    setState(() {
      currentTokenBalance = balance.icxBalance;
    });
    _saveCache();
  }

  void _deployScore() async {
    final transactionResult = await FlutterIconNetwork.instance.deployScore(privateKey: privateKeyCtrl.text, initIcxSupply: "10");
    setState(() {
      scoreAddressCtrl.text = transactionResult.scoreAddress;
      txHash = "transaction/${transactionResult.txHash}";
    });
    _showSnackBar(
        "deployed, scoreAddress ${transactionResult.scoreAddress} copied, pls press check txHash button to check");
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
              child: SingleChildScrollView(
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
                    ..._buildGetIcxBalanceSection(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Divider(),
                    ),
                    ..._buildScoreSection(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                    ),
                    ..._buildSendTokenSection(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                    ),
                    ..._buildGetTokenBalanceSection(),
                    SizedBox(height: 50,),
                    AppSolidButton(
                      backgroundColor: Colors.red,
                      width: 200,
                      onTap: () {
                         launch("https://bicon.tracker.solidwallet.io/$txHash");
                      },
                      text: "Check transaction hash",
                    ),
                    SizedBox(height: 10,),
                    AppSolidButton(
                      backgroundColor: Colors.red,
                      width: 200,
                      onTap: () {
                        launch("https://bicon.tracker.solidwallet.io/address/${walletAddressCtrl.text}");
                      },
                      text: "Check wallet address",
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  //icx
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
            controller: icxSenderCtrl,
          )),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextField(
            controller: icxReceiverCtrl,
          )),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextField(
            controller: icxSendAmountCtrl,
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

  List<Widget> _buildGetIcxBalanceSection() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSolidButton(onTap: _getIcxBalance, text: "Get Icx balance"),
          SizedBox(
            width: 10,
          ),
          Expanded(child: Center(child: Text(currentIcxBalance != null ? "$currentIcxBalance ICX" : "N/A"))),
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

  List<Widget> _buildGetTokenBalanceSection() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSolidButton(onTap: _getTokenBalance, text: "Get Token balance"),
          SizedBox(
            width: 10,
          ),
          Expanded(child: Center(child: Text(currentTokenBalance != null ? "$currentTokenBalance Token" : "N/A"))),
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

  //score
  List<Widget> _buildScoreSection() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSolidButton(onTap: _deployScore, text: "Create SCORE", isEnable: Platform.isAndroid,),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextField(
                controller: scoreAddressCtrl,
              )),
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
          Expanded(child: Center(child: _buildHint("SCORE Address"))),
        ],
      )
    ];
  }

  List<Widget> _buildSendTokenSection() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSolidButton(onTap: _sendToken, text: "Send Token"),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextField(
                controller: tokenReceiverAddressCtrl,
              )),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: TextField(
                controller: tokenSendAmountCtrl,
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
          Expanded(child: Center(child: _buildHint("Token Receiver Address"))),
          SizedBox(
            width: 10,
          ),
          Expanded(child: Center(child: _buildHint("amount of token"))),
        ],
      )
    ];
  }

  void _saveCache() {
    GetStorage().write(StorageKey.icxBalance, currentIcxBalance);
    GetStorage().write(StorageKey.privateKey, privateKeyCtrl.text);
    GetStorage().write(StorageKey.walletAddress, walletAddressCtrl.text);
    GetStorage().write(StorageKey.icxSender, icxSenderCtrl.text);
    GetStorage().write(StorageKey.icxReceiver, icxReceiverCtrl.text);
    GetStorage().write(StorageKey.icxSendAmount, icxSendAmountCtrl.text);

    //score
    GetStorage().write(StorageKey.tokenBalance, currentTokenBalance);
    GetStorage().write(StorageKey.scoreAddress, scoreAddressCtrl.text);
    GetStorage().write(StorageKey.tokenReceiver, tokenReceiverAddressCtrl.text);
    GetStorage().write(StorageKey.tokenSendAmount, tokenSendAmountCtrl.text);
  }

  void _getCache() {
    setState(() {
      currentIcxBalance = GetStorage().read<double>(StorageKey.icxBalance);
      privateKeyCtrl.text = GetStorage().read<String>(StorageKey.privateKey);
      walletAddressCtrl.text =
          GetStorage().read<String>(StorageKey.walletAddress);
      icxSenderCtrl.text = GetStorage().read<String>(StorageKey.icxSender);
      icxReceiverCtrl.text = GetStorage().read<String>(StorageKey.icxReceiver);
      icxSendAmountCtrl.text = GetStorage().read<String>(StorageKey.icxSendAmount);

      //score
      currentTokenBalance = GetStorage().read(StorageKey.tokenBalance);
      scoreAddressCtrl.text = GetStorage().read(StorageKey.scoreAddress);
      tokenReceiverAddressCtrl.text = GetStorage().read(StorageKey.tokenReceiver);
      tokenSendAmountCtrl.text = GetStorage().read(StorageKey.tokenSendAmount);
    });
  }

  void _showSnackBar(String text) {
    Scaffold.of(scaffoldContext).showSnackBar(SnackBar(content: Text(text)));
  }

  Text _buildHint(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.grey, fontSize: 10),
    );
  }
}
