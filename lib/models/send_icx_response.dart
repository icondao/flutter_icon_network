import 'dart:convert';

SendIcxResponse sendIcxResponseFromJson(String str) => SendIcxResponse.fromJson(json.decode(str));

String sendIcxResponseToJson(SendIcxResponse data) => json.encode(data.toJson());

class SendIcxResponse {
  SendIcxResponse({
    this.txHash,
    this.status,
  });

  final String txHash;
  final int status;

  SendIcxResponse copyWith({
    String txHash,
    int status,
  }) =>
      SendIcxResponse(
        txHash: txHash ?? this.txHash,
        status: status ?? this.status,
      );

  factory SendIcxResponse.fromJson(Map<String, dynamic> json) => SendIcxResponse(
    txHash: json["txHash"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "txHash": txHash,
    "status": status,
  };
}
