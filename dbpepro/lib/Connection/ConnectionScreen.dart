// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// AppBar
import '../DBPeProAppBar.dart';
// 対象選択画面
import '../TargetSelection/TargetSelectionScreen.dart';


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
      Uri.parse('http://127.0.0.1:8000/connection_check'),
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
      Uri.parse('http://127.0.0.1:8000/check_authority'),
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
  bool _isVisible = false;
  final List<String> _list = <String>[
    'PostgreSQL',
    'MySQL',
    // 'Oracle',
    // 'Microsoft SQL Server',
  ];

  String? _controllerDBType;
  final TextEditingController _controllerUser = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerHost = TextEditingController();
  final TextEditingController _controllerPort = TextEditingController();
  final TextEditingController _controllerDatabase = TextEditingController();

  Color _dbTypeColor = Colors.black54;
  Color _usernameColor = Colors.black54;
  Color _passwordColor = Colors.black54;
  Color _hostColor = Colors.black54;
  Color _portColor = Colors.black54;
  Color _databaseColor = Colors.black54;

  Future<CheckConnectionResult>? _futureCheckConnectionResult;
  Future<CheckAuthorityResult>? _futureCheckAuthorityResult;

  void _handleChange(String? newValue) {
    setState(() {
      _controllerDBType = newValue;

      if (newValue == null) {
        _dbTypeColor = Colors.red;
      } else {
        _dbTypeColor = Colors.black54;
      }
    });
  }

  void _checkUser(String? newValue) {
    setState(() {
      if (newValue == '') {
        _usernameColor = Colors.red;
      } else {
        _usernameColor = Colors.black54;
      }
    });
  }

  void _checkPassword(String? newValue) {
    setState(() {
      if (newValue == '') {
        _passwordColor = Colors.red;
      } else {
        _passwordColor = Colors.black54;
      }
    });
  }

  void _checkHost(String? newValue) {
    setState(() {
      if (newValue == '') {
        _hostColor = Colors.red;
      } else {
        _hostColor = Colors.black54;
      }
    });
  }

  void _checkPort(String? newValue) {
    setState(() {
      if (newValue == '') {
        _portColor = Colors.red;
      } else {
        _portColor = Colors.black54;
      }
    });
  }

  void _checkDatabase(String? newValue) {
    setState(() {
      if (newValue == '') {
        _databaseColor = Colors.red;
      } else {
        _databaseColor = Colors.black54;
      }
    });
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
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: TextField(
                      enabled: true,
                      controller: _controllerUser,
                      onChanged: _checkUser,
                      maxLength: 64,
                      cursorHeight: 20,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _usernameColor,
                          ),
                        ),
                        labelText: 'Username',
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: TextField(
                      enabled: true,
                      controller: _controllerPassword,
                      onChanged: _checkPassword,
                      maxLength: 64,
                      cursorHeight: 20,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _passwordColor,
                          ),
                        ),
                        labelText: 'Password',
                      ),
                      maxLines: 1,
                      obscureText: true,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: TextField(
                      enabled: true,
                      controller: _controllerHost,
                      onChanged: _checkHost,
                      maxLength: 64,
                      cursorHeight: 20,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _hostColor,
                          ),
                        ),
                        labelText: 'Host',
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: TextField(
                      enabled: true,
                      controller: _controllerPort,
                      onChanged: _checkPort,
                      maxLength: 5,
                      cursorHeight: 20,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _portColor,
                          ),
                        ),
                        labelText: 'Port',
                      ),
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: TextField(
                      enabled: true,
                      controller: _controllerDatabase,
                      onChanged: _checkDatabase,
                      maxLength: 64,
                      cursorHeight: 20,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _databaseColor,
                          ),
                        ),
                        labelText: 'Database',
                      ),
                      maxLines: 1,
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
                                              ? Colors.lightGreen
                                              : Colors.red
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Text(
                                          '${snapshot.error}',
                                          style: const TextStyle(
                                            color: Colors.red,
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
                                color: Colors.red
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              '${snapshot.error}',
                              style: const TextStyle(
                                color: Colors.red,
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
                  color: Colors.blue,
                  iconSize: 50,
                  tooltip: 'Connection',
                  onPressed: () {
                    setState(() {
                      if (_controllerDBType == null) {
                        _dbTypeColor = Colors.red;
                      }
                      if (_controllerUser.text == '') {
                        _usernameColor = Colors.red;
                      }
                      if (_controllerPassword.text == '') {
                        _passwordColor = Colors.red;
                      }
                      if (_controllerHost.text == '') {
                        _hostColor = Colors.red;
                      }
                      if (_controllerPort.text == '') {
                        _portColor = Colors.red;
                      }
                      if (_controllerDatabase.text == '') {
                        _databaseColor = Colors.red;
                      }

                      _futureCheckConnectionResult = _checkConnection(
                        context,
                        _controllerDBType,
                        _controllerUser.text,
                        _controllerPassword.text,
                        _controllerHost.text,
                        _controllerPort.text,
                        _controllerDatabase.text,
                      );
                      _futureCheckAuthorityResult = _checkAuthority(
                        context,
                        _controllerDBType,
                        _controllerUser.text,
                        _controllerPassword.text,
                        _controllerHost.text,
                        _controllerPort.text,
                        _controllerDatabase.text,
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