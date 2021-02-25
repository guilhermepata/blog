import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_shell.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: EdgeInsets.only(
              left: context.read<ShellState>().margins,
              right: context.read<ShellState>().margins,
              top: context.read<ShellState>().gutters,
              bottom: context.read<ShellState>().gutters),
          child: Text('My name is Guilherme Pata')),
    );
  }
}
