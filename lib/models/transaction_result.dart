// To parse this JSON data, do
//
//     final transactionResult = transactionResultFromJson(jsonString);

import 'dart:convert';

TransactionResult transactionResultFromJson(String str) => TransactionResult.fromJson(json.decode(str));

String transactionResultToJson(TransactionResult data) => json.encode(data.toJson());

class TransactionResult {
  TransactionResult({
    this.scoreAddress,
    this.status,
    this.txHash,
    this.stepUsed,
  });

  final String scoreAddress;
  final String status;
  final String txHash;
  final String stepUsed;

  factory TransactionResult.fromJson(Map<String, dynamic> json) => TransactionResult(
    scoreAddress: json["score_address"],
    status: json["status"],
    txHash: json["tx_hash"],
    stepUsed: json["step_used"],
  );

  Map<String, dynamic> toJson() => {
    "score_address": scoreAddress,
    "status": status,
    "tx_hash": txHash,
    "step_used": stepUsed,
  };
}
