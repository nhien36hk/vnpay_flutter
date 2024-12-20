import 'package:http/http.dart' as http;
import 'package:zalo_pay/models/create_order_response.dart';
import 'dart:async';
import 'dart:convert';

import 'package:zalo_pay/utils/config.dart' as config;
import 'package:zalo_pay/utils/endpoints.dart';
import 'package:zalo_pay/utils/util.dart' as utils;
import 'package:sprintf/sprintf.dart';

class ZaloPayConfig {
  static const String appId = "2553";
  static const String key1 = "PcY4iZIKFCIdgZvA6ueMcMHHUbRLYjPL";
  static const String key2 = "kLtgPl8HHhfvMuDHPwKfgfsY4Ydm9eIz";

  static const String appUser = "zalopaydemo";
  static int transIdDefault = 1;
}

Future<CreateOrderResponse?> createOrder(int price) async {
  var header = new Map<String, String>();
  header["Content-Type"] = "application/x-www-form-urlencoded";

  var body = new Map<String, String>();
  body["app_id"] = ZaloPayConfig.appId;
  body["app_user"] = ZaloPayConfig.appUser;
  body["app_time"] = DateTime.now().millisecondsSinceEpoch.toString();
  body["amount"] = price.toStringAsFixed(0);
  body["app_trans_id"] = utils.getAppTransId();
  body["embed_data"] = "{}";
  body["item"] = "[]";
  body["bank_code"] = utils.getBankCode();
  body["description"] = utils.getDescription(body["app_trans_id"]!);

  var dataGetMac = sprintf("%s|%s|%s|%s|%s|%s|%s", [
    body["app_id"],
    body["app_trans_id"],
    body["app_user"],
    body["amount"],
    body["app_time"],
    body["embed_data"],
    body["item"]
  ]);
  body["mac"] = utils.getMacCreateOrder(dataGetMac);
  print("mac: ${body["mac"]}");

  // Gửi request
  var response = await http.post(
    Uri.parse(Endpoints.createOrderUrl), // Sửa lại URL đúng
    headers: header,
    body: body,
  );

  print("body_request: $body");
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print("Parsed response data: $data");
    return CreateOrderResponse.fromJson(data);
  } else {
    print("Error: ${response.body}");
    return null;
  }
}
