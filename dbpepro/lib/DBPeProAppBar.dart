// ignore_for_file: file_names

import 'package:flutter/material.dart';


class DBPeProAppBar extends StatelessWidget {
  const DBPeProAppBar({ 
   Key? key 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(color: Colors.blue[500]),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'DB PePro',
              style: Theme.of(
                context
              ).primaryTextTheme.headline6,
            ),
          ),
        ],
      ),
    );
  }
}