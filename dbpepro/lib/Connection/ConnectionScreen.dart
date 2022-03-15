// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// AppBar
import '../DBPeProAppBar.dart';
// 対象選択画面
import '../TargetSelection/TargetSelectionScreen.dart';

String apiUri = 'http://127.0.0.1:8000';

class CheckConnectionResult {
  final int code;
  final String result;

  const CheckConnectionResult({
    required this.code,
    required this.result,
  });

  factory CheckConnectionResult.fromJson(Map<String, dynamic> json) {
    return CheckConnectionResult(
      code: json['code'],
      result: json['result'],
    );
  }
}

Future<CheckConnectionResult> _checkConnection(
  BuildContext context,
  String? dbType,
  String user,
  String password,
  String host,
  String port,
  String database,
) async {
  http.Response? response;

  if (dbType != null && [user, password, host, port, database].every((e) => e != '')){
    response = await http.post(
      Uri.parse(apiUri+'/connection_check'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String>{
        'db_type': dbType,
        'user': user,
        'password': password,
        'host': host,
        'port': port,
        'database': database,
      }),
    );
  }

  if (response == null) {
    return const CheckConnectionResult(code: 3, result: 'There are fields that have not been filled in.');
  } else {
    if (response.statusCode == 200) {
      CheckConnectionResult result = CheckConnectionResult.fromJson(
        jsonDecode(response.body)
      );
      return result;
    } else {
      return const CheckConnectionResult(code: 2, result: 'API is not responding.');
    }
  }
}

class CheckAuthorityResult {
  final int code;
  final String result;

  const CheckAuthorityResult({
    required this.code,
    required this.result,
  });

  factory CheckAuthorityResult.fromJson(Map<String, dynamic> json) {
    return CheckAuthorityResult(
      code: json['code'],
      result: json['result'],
    );
  }
}

Future<CheckAuthorityResult> _checkAuthority(
  BuildContext context,
  String? dbType,
  String user,
  String password,
  String host,
  String port,
  String database,
) async {
  http.Response? response;

  if (dbType != null && [user, password, host, port, database].every((e) => e != '')){
    response = await http.post(
      Uri.parse(apiUri+'/check_authority'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String>{
        'db_type': dbType,
        'user': user,
        'password': password,
        'host': host,
        'port': port,
        'database': database,
      }),
    );
  }

  if (response == null) {
    return const CheckAuthorityResult(code: 3, result: 'There are fields that have not been filled in.');
  } else {
    if (response.statusCode == 200) {
      CheckAuthorityResult result = CheckAuthorityResult.fromJson(
        jsonDecode(response.body)
      );
      if (result.code == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return TargetSelectionScreen(
                dbType: dbType!,
                user: user,
                password: password,
                host: host,
                port: port,
                database: database,
              );
            }
          ),
        );
      }
      return result;
    } else {
      return const CheckAuthorityResult(code: 2, result: 'API is not responding.');
    }
  }
}

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({ 
    Key? key 
  }) : super(key: key);

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  static const Color defaultColor = Colors.black54;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.lightGreen;
  static const Color defaultTextColor = Colors.black;
  static const Color iconColor = Colors.blue;

  final List<String> _textFieldLabel = [
    'Username',
    'Password',
    'Host',
    'Port',
    'Database',
  ];
  final Map<String, TextEditingController> _textFieldController = {
    'Username': TextEditingController(),
    'Password': TextEditingController(),
    'Host': TextEditingController(),
    'Port': TextEditingController(),
    'Database': TextEditingController(),
  };
  late final Map<String, Color> _textFieldColor = {
    'Username': defaultColor,
    'Password': defaultColor,
    'Host': defaultColor,
    'Port': defaultColor,
    'Database': defaultColor,
  };

  bool _isVisible = false;
  final List<String> _list = <String>[
    'PostgreSQL',
    'MySQL',
    'Oracle',
    'Microsoft SQL Server',
  ];

  String? _controllerDBType;
  late Color _dbTypeColor;

  Future<CheckConnectionResult>? _futureCheckConnectionResult;
  Future<CheckAuthorityResult>? _futureCheckAuthorityResult;

  void _handleChange(String? newValue) {
    setState(() {
      _controllerDBType = newValue;

      if (newValue == null) {
        _dbTypeColor = errorColor;
      } else {
        _dbTypeColor = defaultColor;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _dbTypeColor = defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          const DBPeProAppBar(),
          Expanded(
            child: SizedBox(
              child: ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: DropdownButton<String>(
                      hint: const Text('Select DB'),
                      underline: Container(
                        height: 1,
                        color: _dbTypeColor,
                      ),
                      value: _controllerDBType,
                      onChanged: _handleChange,
                      isExpanded: true,
                      items: _list.map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }
                      ).toList(),
                    ),
                  ),
                  for (String label in _textFieldLabel)
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      child: TextField(
                        enabled: true,
                        controller: _textFieldController[label],
                        onChanged: (String newValue) {
                          setState(() {
                            if (newValue == '') {
                              _textFieldColor[label] = errorColor;
                            } else {
                              _textFieldColor[label] = defaultColor;
                            }
                          });
                        },
                        maxLength: 64,
                        cursorHeight: 20,
                        style: const TextStyle(
                          color: defaultTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _textFieldColor[label]!,
                            ),
                          ),
                          labelText: label,
                        ),
                        maxLines: 1,
                        obscureText: (label == 'Password') ? true : false,
                        keyboardType: (label == 'Port') ? TextInputType.number : TextInputType.text,
                        inputFormatters: (label == 'Port') ? [FilteringTextInputFormatter.digitsOnly] : [],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Visibility(
                visible: _isVisible,
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  child: FutureBuilder<CheckConnectionResult>(
                    future: _futureCheckConnectionResult,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return const CircularProgressIndicator();
                        case ConnectionState.waiting:
                          return const CircularProgressIndicator();
                        case ConnectionState.active:
                          return const CircularProgressIndicator();
                        case ConnectionState.done:
                          if (snapshot.hasData) {
                            if (snapshot.data!.code == 1){
                              return FutureBuilder<CheckAuthorityResult>(
                                future: _futureCheckAuthorityResult,
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                      return const CircularProgressIndicator();
                                    case ConnectionState.waiting:
                                      return const CircularProgressIndicator();
                                    case ConnectionState.active:
                                      return const CircularProgressIndicator();
                                    case ConnectionState.done:
                                      if (snapshot.hasData) {
                                        return Text(
                                          snapshot.data!.result,
                                          style: TextStyle(
                                            color: (snapshot.data!.code == 1) 
                                              ? successColor
                                              : errorColor
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Text(
                                          '${snapshot.error}',
                                          style: const TextStyle(
                                            color: errorColor,
                                          ),
                                        );
                                      }
                                  }
                                  return const CircularProgressIndicator();
                                },
                              );
                            }
                            return Text(
                              snapshot.data!.result,
                              style: const TextStyle(
                                color: errorColor,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              '${snapshot.error}',
                              style: const TextStyle(
                                color: errorColor,
                              ),
                            );
                          }
                        }
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.navigate_next),
                  color: iconColor,
                  iconSize: 50,
                  tooltip: 'Connection',
                  onPressed: () {
                    setState(() {
                      if (_controllerDBType == null) {
                        _dbTypeColor = errorColor;
                      }
                      for (String label in _textFieldLabel) {
                        if (_textFieldController[label]!.text == '') {
                          _textFieldColor[label] = errorColor;
                        }
                      }
                      _futureCheckConnectionResult = _checkConnection(
                        context,
                        _controllerDBType,
                        _textFieldController['Username']!.text,
                        _textFieldController['Password']!.text,
                        _textFieldController['Host']!.text,
                        _textFieldController['Port']!.text,
                        _textFieldController['Database']!.text,
                      );
                      _futureCheckAuthorityResult = _checkAuthority(
                        context,
                        _controllerDBType,
                        _textFieldController['Username']!.text,
                        _textFieldController['Password']!.text,
                        _textFieldController['Host']!.text,
                        _textFieldController['Port']!.text,
                        _textFieldController['Database']!.text,
                      );
                      _isVisible = true;
                    });
                  }, 
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
