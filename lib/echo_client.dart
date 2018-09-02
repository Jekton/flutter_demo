
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'message.dart';


class HttpEchoClient {
  final int port;
  final String host;

  HttpEchoClient(this.port): host = 'http://localhost:$port';

  Future<Message> send(String msg) async {
    // http.post 用来执行一个 HTTP post 请求。
    // 它的 body 参数是一个 dynamic，可以支持不同类型的 body，这里我们
    // 只是直接把客户输入的消息发给服务端就可以了。由于 msg 是一个 String，
    // post 方法会自动设置 HTTP 的 Content-Type 为 text/plain
    final response = await http.post(host + '/echo', body: msg);
    if (response.statusCode == 200) {
      Map<String, dynamic> msgJson = json.decode(response.body);
      var message = Message.fromJson(msgJson);
      return message;
    } else {
      return null;
    }
  }

  Future<List<Message>> getHistory() async {
    try {
      final response = await http.get(host + '/history');
      if (response.statusCode == 200) {
        return _decodeHistory(response.body);
      }
    } catch (e) {
      print('getHistory: $e');
    }
    return null;
  }

  List<Message> _decodeHistory(String response) {
    // JSON 数组 decode 出来是一个 <Map<String, dynamic>>[]
    var messages = json.decode(response);
    var list = <Message>[];
    for (var msgJson in messages) {
      list.add(Message.fromJson(msgJson));
    }
    return list;
  }
}