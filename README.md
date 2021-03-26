# flutter_icon_network

**environment:**
  - sdk: ">=2.7.0 <3.0.0"
  - flutter: ">=1.20.0"

A Flutter plugin to work with native Android/Ios sdk of Icon network

**To track:** https://bicon.tracker.solidwallet.io/ \
**Native SDK:** https://www.icondev.io/docs/sdk-overview

**Features:** create wallet, send icx to testnet, check balance

Supported `Android`, `Ios`

![demo](./demo.png)

# Install:
```
  flutter_icon_network:
    git: https://git.baikal.io/mobile/boilerplate/flutter_icon_network
```

# Init:
```
FlutterIconNetwork.instance.init(host: "https://bicon.net.solidwallet.io/api/v3", isTestNet: true);
```
# Functions:
##### getBalance:
return current balance
```
final balance = await FlutterIconNetwork.instance.getIcxBalance(privateKey: yourPrivateKey;
```
##### sendIcx:
send Icx to an `address`
return the `transaction hash`
```
final txHash = await FlutterIconNetwork.instance.sendIcx(
                        from: yourPrivateKey,
                        to: adress,
                        value: 1
                     )
```
##### createWallet:
create a new wallet
return the `Wallet` object that contain the `privateKey` and `address`
```
final wallet = await FlutterIconNetwork.instance.createWallet;
```