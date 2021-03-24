// To parse this JSON data, do
//
//     final sendIcxRequest = sendIcxRequestFromJson(jsonString);

import 'dart:convert';

SendIcxRequest sendIcxRequestFromJson(String str) => SendIcxRequest.fromJson(json.decode(str));

String sendIcxRequestToJson(SendIcxRequest data) => json.encode(data.toJson());

class SendIcxRequest {
  SendIcxRequest({
    this.from,
    this.to,
    this.value,
  });

  final String from;
  final String to;
  final String value;

  SendIcxRequest copyWith({
    String from,
    String to,
    String value,
  }) =>
      SendIcxRequest(
        from: from ?? this.from,
        to: to ?? this.to,
        value: value ?? this.value,
      );

  factory SendIcxRequest.fromJson(Map<String, dynamic> json) => SendIcxRequest(
    from: json["from"],
    to: json["to"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "from": from,
    "to": to,
    "value": value,
  };
}
