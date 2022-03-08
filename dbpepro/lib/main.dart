import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// AppBar
import './DBPeProAppBar.dart';


void main() {
  runApp(
    const MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'DB PePro',
      home: SafeArea(
        child: ConnectionScreen(),
      ),
    );
  }
}


// 接続確認
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


// 対象選択画面

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
  bool _isVisible = false;
  late Future<TargetUserListResult> _futureTargetUserListResult;
  String? _controllerTargetUser;
  Color _targetUserColor = Colors.black54;
  late Future<TableListResult> _futureTableListResult;
  String? _controllerTable;
  Color _tableColor = Colors.black54;

  void _handleTargetUserChange(String? newValue) {
    setState(() {
      _controllerTargetUser = newValue;

      if (newValue == null) {
        _targetUserColor = Colors.red;
      } else {
        _targetUserColor = Colors.black54;
      }
    });
  }

  void _handleTableChange(String? newValue) {
    setState(() {
      _controllerTable = newValue;

      if (newValue == null) {
        _tableColor = Colors.red;
      } else {
        _tableColor = Colors.black54;
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
                  color: Colors.blue,
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
                                            color:Colors.red
                                          ),
                                        );
                                      }
                                      _isVisible = true;
                                      return const Text('');
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
                          if (snapshot.data!.code == 2) {
                            return Text(
                              snapshot.data!.result.first.name,
                              style: const TextStyle(
                                color: Colors.red
                              ),
                            );
                          }
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
              Visibility(
                visible: _isVisible,
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: const Icon(Icons.navigate_next),
                    color: Colors.blue,
                    iconSize: 50,
                    tooltip: 'Next Authority Select',
                    onPressed: () {
                      setState(() {
                        if (_controllerTargetUser == null) {
                          _targetUserColor = Colors.red;
                        }
                        if (_controllerTable == null) {
                          _tableColor = Colors.red;
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


// 権限選択画面

class Authority {
  const Authority({required this.authority});

  final String authority;
}

class AuthorityListResult {
  final int code;
  final List<Authority> result;

  const AuthorityListResult({
    required this.code,
    required this.result,
  });

  factory AuthorityListResult.fromJson(Map<String, dynamic> json) {
    List<Authority> createList(String result) {
      List<Authority> authorityList = [];

      for (String authority in result.split(',')) {
        authorityList.add(Authority(authority: authority));
      }

      return authorityList;
    }
    
    return AuthorityListResult(
      code: json['code'],
      result: createList(json['result']),
    );
  }
}

Future<AuthorityListResult> _getAuthorityList(
  BuildContext context,
  String dbType,
  String user,
  String password,
  String host,
  String port,
  String database,
) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:8000/authority_list'),
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
    AuthorityListResult result = AuthorityListResult.fromJson(
      jsonDecode(response.body)
    );
    return result;
  } else {
    return const AuthorityListResult(code: 2, result: [Authority(authority: 'API is not responding.')]);
  }
}

typedef AuthoritySelectionChangedCallback = Function(Authority authority, bool selection);

class AuthorityListItem extends StatelessWidget {
  AuthorityListItem({
    required this.authority,
    required this.selection,
    required this.onSelectionChanged,
  }) : super(key: ObjectKey(authority));

  final Authority authority;
  final bool selection;
  final AuthoritySelectionChangedCallback onSelectionChanged;

  Color _getBorderColor(BuildContext context) {
    return selection
      ? Colors.black54
      : Theme.of(context).primaryColor;
  }

  TextStyle? _getTextStyle(BuildContext context) {
    if (!selection) return null;

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _getBorderColor(context)
        ),
      ),
      child: ListTile(
        onTap: () {
          onSelectionChanged(authority, selection);
        },
        title: Text(
          authority.authority,
          style: _getTextStyle(context),
        ),
      )
    );
  }
}

class AddAuthorityResult {
  final int code;
  final String result;

  const AddAuthorityResult({
    required this.code,
    required this.result,
  });

  factory AddAuthorityResult.fromJson(Map<String, dynamic> json) {
    return AddAuthorityResult(
      code: json['code'],
      result: json['result'],
    );
  }
}

Future<AddAuthorityResult> _addAuthority(
  BuildContext context,
  String dbType,
  String user,
  String password,
  String host,
  String port,
  String database,
  String targetUser,
  String table,
  List<Authority> authorityList,
) async {
  if (authorityList.isNotEmpty) {
    String _createAuthority(List<Authority> authorityList) {
      String authority = '';

      for (Authority auth in authorityList) {
        if (authority == '') {
          authority = auth.authority;
        } else {
          authority += ',';
          authority += auth.authority;
        }
      }

      return authority;
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/add_authority'),
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
        'target_user': targetUser,
        'table': table,
        'authority': _createAuthority(authorityList),
      }),
    );

    if (response.statusCode == 200) {
      AddAuthorityResult result = AddAuthorityResult.fromJson(
        jsonDecode(response.body)
      );
      return result;
    } else {
      return const AddAuthorityResult(code: 2, result: 'API is not responding.');
    }
  } else {
    return const AddAuthorityResult(code: 2, result: 'Please select one or more authorizations to be granted');
  }
}

class RemoveAuthorityResult {
  final int code;
  final String result;

  const RemoveAuthorityResult({
    required this.code,
    required this.result,
  });

  factory RemoveAuthorityResult.fromJson(Map<String, dynamic> json) {
    return RemoveAuthorityResult(
      code: json['code'],
      result: json['result'],
    );
  }
}

Future<RemoveAuthorityResult> _removeAuthority(
  BuildContext context,
  String dbType,
  String user,
  String password,
  String host,
  String port,
  String database,
  String targetUser,
  String table,
  List<Authority> authorityList,
) async {
  if (authorityList.isNotEmpty) {
    String _createAuthority(List<Authority> authorityList) {
      String authority = '';

      for (Authority auth in authorityList) {
        if (authority == '') {
          authority = auth.authority;
        } else {
          authority += ',';
          authority += auth.authority;
        }
      }

      return authority;
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/remove_authority'),
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
        'target_user': targetUser,
        'table': table,
        'authority': _createAuthority(authorityList),
      }),
    );

    if (response.statusCode == 200) {
      RemoveAuthorityResult result = RemoveAuthorityResult.fromJson(
        jsonDecode(response.body)
      );
      return result;
    } else {
      return const RemoveAuthorityResult(code: 2, result: 'API is not responding.');
    }
  } else {
    return const RemoveAuthorityResult(code: 2, result: 'Please select one or more authorizations to be granted');
  }
}

class AuthoritySelectionScreen extends StatefulWidget {
  final String dbType;
  final String user;
  final String password;
  final String host;
  final String port;
  final String database;
  final String targetUser;
  final String table;
  
  const AuthoritySelectionScreen({
    required this.dbType,
    required this.user,
    required this.password,
    required this.host,
    required this.port,
    required this.database,
    required this.targetUser,
    required this.table,
    Key? key 
  }) : super(key: key);

  @override
  _AuthoritySelectionScreenState createState() => _AuthoritySelectionScreenState();
}

class _AuthoritySelectionScreenState extends State<AuthoritySelectionScreen> {
  bool _isVisibleAuthority = false;
  bool _isVisibleAddAuthorityResult = false;
  bool _isVisibleRemoveAuthorityResult = false;
  late Future<AuthorityListResult> _futureAuthorityListResult;
  final _authoritySelection = <Authority>{};
  Future<AddAuthorityResult>? _futureAddAuthorityResult;
  Future<RemoveAuthorityResult>? _futureRemoveAuthorityResult;

  void _handleSelectionChanged(Authority authority, bool selection) {
    setState(() {
      if (selection) {
        _authoritySelection.add(authority);
      } else {
        _authoritySelection.remove(authority);
      }
      if (_authoritySelection.isNotEmpty) {
        _isVisibleAuthority = true;
      } else {
        _isVisibleAuthority = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _futureAuthorityListResult = _getAuthorityList(
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
              child: FutureBuilder<AuthorityListResult>(
                future: _futureAuthorityListResult,
                builder: (context, snapshot) {
                  return ListView(
                    children: [
                      if (snapshot.data != null && snapshot.data!.code == 1)
                        for (Authority authority in snapshot.data!.result)
                          AuthorityListItem(
                            authority: authority,
                            selection: !_authoritySelection.contains(authority),
                            onSelectionChanged: _handleSelectionChanged,
                          ),
                    ],
                  );
                },
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
                  color: Colors.blue,
                  iconSize: 50,
                  tooltip: 'Back',
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  }, 
                ),
              ),
              if (_isVisibleAddAuthorityResult)
                Visibility(
                  visible: _isVisibleAddAuthorityResult,
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: FutureBuilder<AddAuthorityResult>(
                      future: _futureAddAuthorityResult,
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
                              if (snapshot.data != null && snapshot.data!.code == 2) {
                                return Text(
                                  snapshot.data!.result,
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                );
                              }
                              return Text(
                                snapshot.data!.result,
                                style: const TextStyle(
                                  color: Colors.lightGreen,
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
              if (_isVisibleRemoveAuthorityResult)
                Visibility(
                  visible: _isVisibleRemoveAuthorityResult,
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: FutureBuilder<RemoveAuthorityResult>(
                      future: _futureRemoveAuthorityResult,
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
                              if (snapshot.data != null && snapshot.data!.code == 2) {
                                return Text(
                                  snapshot.data!.result,
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                );
                              }
                              return Text(
                                snapshot.data!.result,
                                style: const TextStyle(
                                  color: Colors.lightGreen,
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
              Visibility(
                visible: _isVisibleAuthority,
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      child: IconButton(
                        icon: const Icon(Icons.remove),
                        color: Colors.blue,
                        iconSize: 50,
                        tooltip: 'REVOKE',
                        onPressed: () {
                          setState(() {
                            _futureRemoveAuthorityResult = _removeAuthority(
                              context, 
                              widget.dbType, 
                              widget.user, 
                              widget.password, 
                              widget.host, 
                              widget.port, 
                              widget.database, 
                              widget.targetUser, 
                              widget.table, 
                              _authoritySelection.toList(),
                            );
                            _isVisibleAddAuthorityResult = false;
                            _isVisibleRemoveAuthorityResult = true;
                          });
                        }, 
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        color: Colors.blue,
                        iconSize: 50,
                        tooltip: 'GRANT',
                        onPressed: () {
                          setState(() {
                            _futureAddAuthorityResult = _addAuthority(
                              context, 
                              widget.dbType, 
                              widget.user, 
                              widget.password, 
                              widget.host, 
                              widget.port, 
                              widget.database, 
                              widget.targetUser, 
                              widget.table, 
                              _authoritySelection.toList(),
                            );
                            _isVisibleAddAuthorityResult = true;
                            _isVisibleRemoveAuthorityResult = false;
                          });
                        }, 
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

