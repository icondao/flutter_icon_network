import 'package:flutter_icon_network/flutter_icon_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  FlutterIconNetwork.instance.init(host: "https://bicon.net.solidwallet.io/api/v3", isTestNet: true);
  final privateKey = "592eb276d534e2c41a2d9356c0ab262dc233d87e4dd71ce705ec130a8d27ff0c";
  final receiverAddress = "hx116e14d86771b97d50aec933685e85ad7c1d5f30";
  final value = "1";
  final scoreAddress = "cx9e7f89f7f7fa8bd5d56e67282328a3ca87a082b1";


  testWidgets('Create wallet success', (WidgetTester tester) async {
    final wallet = await FlutterIconNetwork.instance.createWallet;
    expect(wallet.privateKey, isA<String>());
    expect(wallet.address, isA<String>());
  });

  testWidgets('Send Icx success', (WidgetTester tester) async {
    final txHash = await FlutterIconNetwork.instance.sendIcx(
        yourPrivateKey: privateKey,
        destinationAddress: receiverAddress,
        value: value
    );
    expect(txHash.txHash, isA<String>());
  });

  testWidgets('check icx balance success', (WidgetTester tester) async {
    final balance = await FlutterIconNetwork.instance.getIcxBalance(privateKey: privateKey);
    expect(balance.balance, isA<String>());
  });

  testWidgets('send token success', (WidgetTester tester) async {
    final response = await FlutterIconNetwork.instance.sendToken(
        yourPrivateKey: privateKey,
        toAddress: receiverAddress,
        value: value, scoreAddress: scoreAddress);
    expect(response.txHash, isA<String>());
  });

  testWidgets('check token balance success', (WidgetTester tester) async {
    final balance = await FlutterIconNetwork.instance.getTokenBalance(
        privateKey: privateKey,
        scoreAddress: scoreAddress);
    expect(balance.balance, isA<String>());
  });
}