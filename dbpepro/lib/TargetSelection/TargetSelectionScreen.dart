// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// AppBar
import '../DBPeProAppBar.dart';
// 権限選択画面
import '../AuthoritySelection/AuthoritySelectionScreen.dart';

class TargetUser {
  const TargetUser({required this.name});

  final String name;
}

class TargetUserListResult {
  final int code;
  final List<TargetUser> result;

  const TargetUserListResult({
    required this.code,
    required this.result,
  });

  factory TargetUserListResult.fromJson(Map<String, dynamic> json) {
    List<TargetUser> createList(String result) {
      List<TargetUser> targetUser = [];

      for (String target in result.split(',')) {
        targetUser.add(TargetUser(name: target));
      }

      return targetUser;
    }
    
    return TargetUserListResult(
      code: json['code'],
      result: createList(json['result']),
    );
  }
}

Future<TargetUserListResult> _getTargetUserList(
  BuildContext context,
  String dbType,
  String user,
  String password,
  String host,
  String port,
  String database,
) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:8000/target_user_list'),
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

  if (response.statusCode == 200) {
    TargetUserListResult result = TargetUserListResult.fromJson(
      jsonDecode(response.body)
    );
    return result;
  } else {
    return const TargetUserListResult(code: 2, result: [TargetUser(name: 'API is not responding.')]);
  }
}

class Table {
  const Table({required this.name});

  final String name;
}

class TableListResult {
  final int code;
  final List<Table> result;

  const TableListResult({
    required this.code,
    required this.result,
  });

  factory TableListResult.fromJson(Map<String, dynamic> json) {
    List<Table> createList(String result) {
      List<Table> tableList = [];

      for (String table in result.split(',')) {
        tableList.add(Table(name: table));
      }

      return tableList;
    }
    
    return TableListResult(
      code: json['code'],
      result: createList(json['result']),
    );
  }
}

Future<TableListResult> _getTableList(
  BuildContext context,
  String dbType,
  String user,
  String password,
  String host,
  String port,
  String database,
) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:8000/table_list'),
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

  if (response.statusCode == 200) {
    TableListResult result = TableListResult.fromJson(
      jsonDecode(response.body)
    );
    return result;
  } else {
    return const TableListResult(code: 2, result: [Table(name: 'API is not responding.')]);
  }
}

class TargetSelectionScreen extends StatefulWidget {
  final String dbType;
  final String user;
  final String password;
  final String host;
  final String port;
  final String database;

  const TargetSelectionScreen({ 
    required this.dbType,
    required this.user,
    required this.password,
    required this.host,
    required this.port,
    required this.database,
    Key? key 
  }) : super(key: key);

  @override
  State<TargetSelectionScreen> createState() => _TargetSelectionScreenState();
}

class _TargetSelectionScreenState extends State<TargetSelectionScreen> {
  static const Color errorColor = Colors.red;
  static const Color defaultColor = Colors.black54;
  static const Color iconColor = Colors.blue;

  bool _isVisible = false;
  late Future<TargetUserListResult> _futureTargetUserListResult;
  String? _controllerTargetUser;
  Color _targetUserColor = defaultColor;
  late Future<TableListResult> _futureTableListResult;
  String? _controllerTable;
  Color _tableColor = defaultColor;

  void _handleTargetUserChange(String? newValue) {
    setState(() {
      _controllerTargetUser = newValue;

      if (newValue == null) {
        _targetUserColor = errorColor;
      } else {
        _targetUserColor = defaultColor;
      }
    });
  }

  void _handleTableChange(String? newValue) {
    setState(() {
      _controllerTable = newValue;

      if (newValue == null) {
        _tableColor = errorColor;
      } else {
        _tableColor = defaultColor;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _futureTargetUserListResult = _getTargetUserList(
      context,
      widget.dbType,
      widget.user,
      widget.password,
      widget.host,
      widget.port,
      widget.database,
    );
    _futureTableListResult = _getTableList(
      context,
      widget.dbType,
      widget.user,
      widget.password,
      widget.host,
      widget.port,
      widget.database,
    );
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
                  FutureBuilder<TargetUserListResult>(
                    future: _futureTargetUserListResult,
                    builder: (context, snapshot) {
                      if (snapshot.data != null && snapshot.data!.code == 1) {
                        return Container(
                          margin: const EdgeInsets.all(16.0),
                          child: DropdownButton<String>(
                            hint: const Text('Select user'),
                            underline: Container(
                              height: 1,
                              color: _targetUserColor,
                            ),
                            value: _controllerTargetUser,
                            onChanged: _handleTargetUserChange,
                            isExpanded: true,
                            items: snapshot.data!.result.map<DropdownMenuItem<String>>(
                              (TargetUser targetUser) {
                                return DropdownMenuItem<String>(
                                  value: targetUser.name,
                                  child: Text(targetUser.name),
                                );
                              }
                            ).toList(),
                          ),
                        );
                      }
                      return Container(
                        margin: const EdgeInsets.all(16.0),
                        child: DropdownButton<String>(
                          value: '',
                          onChanged: _handleTargetUserChange,
                          isExpanded: true,
                          items: const [],
                        ),
                      );
                    },
                  ),
                  FutureBuilder<TableListResult>(
                    future: _futureTableListResult,
                    builder: (context, snapshot) {
                      if (snapshot.data != null && snapshot.data!.code == 1) {
                        return Container(
                          margin: const EdgeInsets.all(16.0),
                          child: DropdownButton<String>(
                            hint: const Text('Select Table'),
                            underline: Container(
                              height: 1,
                              color: _tableColor,
                            ),
                            value: _controllerTable,
                            onChanged: _handleTableChange,
                            isExpanded: true,
                            items: snapshot.data!.result.map<DropdownMenuItem<String>>(
                              (Table table) {
                                return DropdownMenuItem<String>(
                                  value: table.name,
                                  child: Text(table.name),
                                );
                              }
                            ).toList(),
                          ),
                        );
                      }
                      return Container(
                        margin: const EdgeInsets.all(16.0),
                        child: DropdownButton<String>(
                          value: '',
                          onChanged: _handleTableChange,
                          isExpanded: true,
                          items: const [],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.navigate_before),
                  color: iconColor,
                  iconSize: 50,
                  tooltip: 'Back',
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  }, 
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16.0),
                child: FutureBuilder<TargetUserListResult>(
                  future: _futureTargetUserListResult,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return const CircularProgressIndicator();
                      case ConnectionState.waiting:
                        return const CircularProgressIndicator();
                      case ConnectionState.active:
                        return const CircularProgressIndicator();
                      case ConnectionState.done:
                        if (snapshot.data != null) {
                          if (snapshot.data!.code == 1){
                            return FutureBuilder<TableListResult>(
                              future: _futureTableListResult,
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.none:
                                    return const CircularProgressIndicator();
                                  case ConnectionState.waiting:
                                    return const CircularProgressIndicator();
                                  case ConnectionState.active:
                                    return const CircularProgressIndicator();
                                  case ConnectionState.done:
                                    if (snapshot.data != null) {
                                      if (snapshot.data!.code == 2) {
                                        return Text(
                                          snapshot.data!.result.first.name,
                                          style: const TextStyle(
                                            color: errorColor,
                                          ),
                                        );
                                      }
                                      _isVisible = true;
                                      return const Text('');
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
                          if (snapshot.data!.code == 2) {
                            return Text(
                              snapshot.data!.result.first.name,
                              style: const TextStyle(
                                color: errorColor,
                              ),
                            );
                          }
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
              Visibility(
                visible: _isVisible,
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: const Icon(Icons.navigate_next),
                    color: iconColor,
                    iconSize: 50,
                    tooltip: 'Next Authority Select',
                    onPressed: () {
                      setState(() {
                        if (_controllerTargetUser == null) {
                          _targetUserColor = errorColor;
                        }
                        if (_controllerTable == null) {
                          _tableColor = errorColor;
                        }

                        if (_controllerTargetUser != null && _controllerTable != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return AuthoritySelectionScreen(
                                  dbType: widget.dbType,
                                  user: widget.user,
                                  password: widget.password,
                                  host: widget.host,
                                  port: widget.port,
                                  database: widget.database,
                                  targetUser: _controllerTargetUser!,
                                  table: _controllerTable!,
                                );
                              }
                            ),
                          );
                        }
                      });
                    }, 
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}