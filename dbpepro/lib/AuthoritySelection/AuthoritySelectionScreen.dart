// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// AppBar
import '../DBPeProAppBar.dart';

String apiUri = 'http://127.0.0.1:8000';

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
  String targetUser,
  String table,
) async {
  final response = await http.post(
    Uri.parse(apiUri+'/authority_list'),
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
      Uri.parse(apiUri+'/add_authority'),
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
      Uri.parse(apiUri+'/remove_authority'),
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
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.lightGreen;
  static const Color iconColor = Colors.blue;

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
      widget.targetUser,
      widget.table,
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
                                    color: errorColor,
                                  ),
                                );
                              }
                              return Text(
                                snapshot.data!.result,
                                style: const TextStyle(
                                  color: successColor,
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
                                    color: errorColor,
                                  ),
                                );
                              }
                              return Text(
                                snapshot.data!.result,
                                style: const TextStyle(
                                  color: successColor,
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
              Visibility(
                visible: _isVisibleAuthority,
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      child: IconButton(
                        icon: const Icon(Icons.remove),
                        color: iconColor,
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
                        color: iconColor,
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
