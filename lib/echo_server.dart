
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sqflite/sqflite.dart';

import 'message.dart';

class HttpEchoServer {
  static const GET = 'GET';
  static const POST = 'POST';

  static const tableName = 'History';
  static const columnId = 'id';
  static const columnMsg = 'msg';
  static const columnTimestamp = 'timestamp';

  final int port;
  HttpServer httpServer;
  Database database;
  // 在 Dart 里面，函数也是 first class object，我们可以直接把
  // 函数放到 Map 里面
  Map<String, void Function(HttpRequest)> routes;

  final List<Message> messages = [];

  HttpEchoServer(this.port) {
    _initRoutes();
  }

  void _initRoutes() {
    routes = {
      // 我们只支持 path 为 '/history' 和 '/echo' 的请求。
      // history 用于获取历史记录；
      // echo 则提供 echo 服务。
      '/history': _history,
      '/echo': _echo,
    };
  }

  // 返回一个 Future，这样客户端就能够在 start 完成后做一些事
  Future start() async {
    await _initDatabase();
    await _loadMessages();
    // 1. 创建一个 HttpServer
    httpServer = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    // 2. 开始监听客户请求
    return httpServer.listen((request) {
      final path = request.uri.path;
      final handler = routes[path];
      if (handler != null) {
        handler(request);
      } else {
        // 给客户返回一个 404
        request.response.statusCode = HttpStatus.notFound;
        request.response.close();
      }
    });
  }

  Future _initDatabase() async {
    var path = await getDatabasesPath() + '/history.db';
    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        var sql = '''
            CREATE TABLE $tableName (
            $columnId INTEGER PRIMARY KEY,
            $columnMsg TEXT,
            $columnTimestamp INTEGER
            )
            ''';
        await db.execute(sql);
      }
    );
  }

  _unsupportedMethod(HttpRequest request) {
    request.response.statusCode = HttpStatus.methodNotAllowed;
    request.response.close();
  }

  void _history(HttpRequest request) {
    if (request.method != GET) {
      _unsupportedMethod(request);
      return;
    }

    String historyData = json.encode(messages);
    request.response.write(historyData);
    request.response.close();
  }

  void _echo(HttpRequest request) async {
    if (request.method != POST) {
      _unsupportedMethod(request);
      return;
    }

    // 获取从客户端 post 请求的 body，更多的知识，参考
    // https://www.dartlang.org/tutorials/dart-vm/httpserver
    String body = await request.transform(utf8.decoder).join();
    if (body != null) {
      var message = Message.create(body);
      messages.add(message);
      request.response.statusCode = HttpStatus.ok;
      // json 是 convert 包里的对象，encode 方法还有第二个参数 toEncodable。当遇到对象不是
      // Dart 的内置对象时，如果提供这个参数，就会调用它对对象进行序列化；这里我们没有提供，
      // 所以 encode 方法会调用对象的 toJson 方法，这个方法在前面我们已经定义了
      var data = json.encode(message);
      // 把响应写回给客户端
      request.response.write(data);
      _storeMessage(message);
    } else {
      request.response.statusCode = HttpStatus.badRequest;
    }
    request.response.close();
  }

  void _storeMessage(Message msg) {
    database.insert(tableName, msg.toJson());
  }

  Future _loadMessages() async {
    var list = await database.query(
      tableName,
      columns: [columnMsg, columnTimestamp],
      orderBy: columnId,
    );
    for (var item in list) {
      var message = Message.fromJson(item);
      messages.add(message);
    }
  }

  void close() async {
    var server = httpServer;
    httpServer = null;
    await server?.close();
    var db = database;
    database = null;
    db?.close();
  }

}

