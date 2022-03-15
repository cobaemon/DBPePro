// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// AppBar
import '../DBPeProAppBar.dart';
// 権限選択画面
import '../AuthoritySelection/AuthoritySelectionScreen.dart';

String apiUri = 'http://127.0.0.1:8000';
String targetUserUri = '/target_user_list';
String tableUri = '/table_list';

class APIResult {
  final int code;
  final List<String> result;

  const APIResult({
    required this.code,
    required this.result,
  });

  factory APIResult.fromJson(Map<String, dynamic> json) {
    List<String> createList(String result) {
      List<String> targetUser = [];

      for (String target in result.split(',')) {
        targetUser.add(target);
      }

      return targetUser;
    }
    
    return APIResult(
      code: json['code'],
      result: createList(json['result']),
    );
  }
}

Future<APIResult> _getList(
  BuildContext context,
  String uri,
  String dbType,
  String user,
  String password,
  String host,
  String port,
  String database,
) async {
  final response = await http.post(
    Uri.parse(apiUri+uri),
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
    APIResult result = APIResult.fromJson(
      jsonDecode(response.body)
    );
    return result;
  } else {
    return const APIResult(code: 2, result: ['API is not responding.']);
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
  static const Color _errorColor = Colors.red;
  static const Color _defaultColor = Colors.black54;
  static const Color _iconColor = Colors.blue;

  final List<String> _uriList = [
    targetUserUri,
    tableUri,
  ];
  final Map<String, String> _futureBuilderText = {
    targetUserUri: 'Select user',
    tableUri: 'Select Table',
  };
  final Map<String, Color> _futureBuilderColor = {
    targetUserUri: _defaultColor,
    tableUri: _defaultColor,
  };
  final Map<String, String?> _selectList = {
    targetUserUri: null,
    tableUri: null,
  };

  late final Map<String, Future<APIResult>> _futureAPIResult = {};
  
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    for (String uri in _uriList) {
      _futureAPIResult[uri] = 
        _getList(
          context, 
          uri, 
          widget.dbType, 
          widget.user, 
          widget.password, 
          widget.host, 
          widget.port, 
          widget.database,
        );
    }
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
                  for (String uri in _uriList)
                    FutureBuilder<APIResult>(
                      future: _futureAPIResult[uri],
                      builder: (context, snapshot) {
                        if (snapshot.data != null && snapshot.data!.code == 1) {
                          return Container(
                            margin: const EdgeInsets.all(16.0),
                            child: 
                            DropdownButton<String>(
                              hint: Text(_futureBuilderText[uri]!),
                              underline: Container(
                                height: 1,
                                color: _futureBuilderColor[uri],
                              ),
                              value: _selectList[uri],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectList[uri] = newValue;
                                  if (newValue == null) {
                                    _futureBuilderColor[uri] = _errorColor;
                                  } else {
                                    _futureBuilderColor[uri] = _defaultColor;
                                  }
                                });
                              },
                              isExpanded: true,
                              items: snapshot.data!.result.map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }
                              ).toList(),
                            ),
                          );
                        }
                        return Container(
                          margin: const EdgeInsets.all(16.0),
                          child: DropdownButton<String>(
                            underline: Container(
                              height: 1,
                              color: _errorColor,
                            ),
                            value: '',
                            onChanged: (String? newValue) {
                              setState(() {
                                if (newValue == null) {
                                  _futureBuilderColor[uri] = _errorColor;
                                } else {
                                  _futureBuilderColor[uri] = _defaultColor;
                                }
                              });
                            },
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
                  color: _iconColor,
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
                child: FutureBuilder<APIResult>(
                  future: _futureAPIResult[targetUserUri],
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
                            return FutureBuilder<APIResult>(
                              future: _futureAPIResult[tableUri],
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
                                          snapshot.data!.result.first,
                                          style: const TextStyle(
                                            color: _errorColor,
                                          ),
                                        );
                                      }
                                      _isVisible = true;
                                      return const Text('');
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        '${snapshot.error}',
                                        style: const TextStyle(
                                          color: _errorColor,
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
                              snapshot.data!.result.first,
                              style: const TextStyle(
                                color: _errorColor,
                              ),
                            );
                          }
                        } else if (snapshot.hasError) {
                          return Text(
                            '${snapshot.error}',
                            style: const TextStyle(
                              color: _errorColor,
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
                    color: _iconColor,
                    iconSize: 50,
                    tooltip: 'Next Authority Select',
                    onPressed: () {
                      setState(() {
                        for (String uri in _uriList) {
                          if (_selectList[uri] == null) {
                            _futureBuilderColor[uri] = _errorColor;
                          }
                        }
                        if (_selectList[targetUserUri] != null && _selectList[tableUri] != null) {
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
                                  targetUser: _selectList[targetUserUri]!,
                                  table: _selectList[tableUri]!,
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