import 'dart:convert';

Wallet walletFromJson(String str) => Wallet.fromJson(json.decode(str));

String walletToJson(Wallet data) => json.encode(data.toJson());

class Wallet {
  Wallet({
    this.privateKey,
    this.address,
  });

  final String privateKey;
  final String address;

  Wallet copyWith({
    String privateKey,
    String address,
  }) =>
      Wallet(
        privateKey: privateKey ?? this.privateKey,
        address: address ?? this.address,
      );

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    privateKey: json["private_key"],
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "private_key": privateKey,
    "address": address,
  };
}
