import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:super_generic_api_client/api_services/decoder.dart';

import 'api_services/api_client.dart';
import 'api_services/api_response.dart';
import 'api_services/api_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late APIClient apiClient;

  String? _text;

  @override
  initState() {
    super.initState();
    apiClient = APIClient();
    apiClient.instance.interceptors
        .add(LogInterceptor(requestBody: true, responseBody: true));
  }

  _buildButton(String title, Function callback) {
    return TextButton(
      style: TextButton.styleFrom(backgroundColor: Colors.amber),
      child: Text(title),
      onPressed: () {
        callback();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generic API Client"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildButton("Basic types", () {
                        apiClient
                            .request<Map<String, dynamic>?>(
                          route: APIRoute(apiType: APIType.testGet),
                          create: (_) => {},
                        )
                            .then((response) {
                          setState(() {
                            _text = response.toString();
                          });
                        });
                      }),
                      _buildButton("Api wrapper wih basic types: Get", () {
                        apiClient
                            .request(
                          route: APIRoute(apiType: APIType.testGet),
                          params: {"data": "get"},
                          create: (response) =>
                              APIResponse<Map<String, dynamic>>(
                                  response: response),
                        )
                            .then((response) {
                          setState(() {
                            _text = response.decodedData?.toString();
                          });
                        });
                      }),
                      _buildButton("Api wrapper wih basic types: Put", () {
                        apiClient
                            .request(
                          route: APIRoute(apiType: APIType.testPut),
                          params: {"data": "put"},
                          create: (response) =>
                              APIResponse<Map<String, dynamic>>(
                                  response: response),
                        )
                            .then((response) {
                          setState(() {
                            _text = response.decodedData?.toString();
                          });
                        });
                      }),
                      _buildButton("Api wrapper wih basic types: Post", () {
                        apiClient
                            .request(
                          route: APIRoute(apiType: APIType.testPost),
                          params: {"data": "post"},
                          create: (response) =>
                              APIResponse<Map<String,dynamic>>(
                                  response: response),
                        )
                            .then((response) {
                          setState(() {
                            _text = response.decodedData?.toString();
                          });
                        });
                      }),
                      _buildButton("Api wrapper wih basic types: Delete", () {
                        apiClient
                            .request(
                          route: APIRoute(apiType: APIType.testDelete),
                          params: {"data": "post"},
                          create: (response) =>
                              APIResponse<Map<String, dynamic>>(
                                  response: response),
                        )
                            .then((response) {
                          setState(() {
                            _text = response.decodedData?.toString();
                          });
                        });
                      }),
                      _buildButton("Api wrapper wih basic types: Delete", () {
                        apiClient
                            .request(
                          route: APIRoute(apiType: APIType.testDelete),
                          params: {"data": "post"},
                          create: (response) =>
                              APIResponse<Map<String, dynamic>>(
                                  response: response),
                        )
                            .then((response) {
                          setState(() {
                            _text = response.decodedData?.toString();
                          });
                        });
                      }),
                      _buildButton("Api wrapper wih custom types: Student", () {
                        apiClient
                            .request(
                          route: APIRoute(apiType: APIType.testGet),
                          params: {"name": "maxaka", "id": 1},
                          create: (response) => APIResponse(
                              response: response, decodedData: Student()),
                        )
                            .then((response) {
                          setState(() {
                            _text = response.decodedData?.toString();
                          });
                        });
                      }),
                      _buildButton("Api wrapper wih list: Student", () {
                        apiClient
                            .request(
                          route: APIRoute(apiType: APIType.testPost),
                          body: [
                            {"name": "maxaka", "id": 1},
                            {"name": "maxaka1", "id": 2},
                            {"name": "maxaka3", "id": 3},
                          ],
                          create: (response) => APIListResponse(
                              response: response, decodedData: Student()),
                        )
                            .then((response) {
                          setState(() {
                            _text = response.decodedList?.toString();
                          });
                        });
                      }),
                      _buildButton("Api wrapper wih list: Student", () {
                        apiClient
                            .request(
                          route: APIRoute(apiType: APIType.testPost),
                          body: [
                            {"name": "maxaka", "id": 1},
                            {"name": "maxaka1", "id": 2},
                            {"name": "maxaka3", "id": 3},
                          ],
                          create: (response) => APIListResponse(
                              response: response, decodedData: Student()),
                        )
                            .then((response) {
                          setState(() {
                            _text = response.decodedList?.toString();
                          });
                        });
                      }),
                      _buildButton("API Error", () async{
                        try {
                          await apiClient.request(
                            route: APIRoute(apiType: APIType.testError),
                            extraPath: "/500",
                            create: (response) =>
                                APIResponse<String>(response: response),
                          );
                        } on ErrorResponse catch (e) {
                          setState(() {
                            _text = e.statusMessage;
                          });
                        }
                      }),
                    ]),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_text ?? "Unknown"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Student extends Decoder<Student> {
  String? name, id;

  Student({this.name, this.id});

  Student.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    id = json["id"]?.toString();
  }

  @override
  Student decode(Map<String, dynamic> json) => Student.fromJson(json);

  @override
  String toString() {
    return 'Student{name: $name, id: $id}';
  }
}
