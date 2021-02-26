import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_shell.dart';
import 'classes.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ShellState>(
      builder: (context, state, child) {
        return Scaffold(
          body: SingleChildScrollView(
            controller: state.scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                  // left: state.margins,
                  // right: state.margins,
                  top: state.gutters,
                  bottom: state.gutters),
              child: Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 600,
                    ),
                    child: child),
              ),
            ),
          ),
        );
      },
      child: AboutCard(),
    );
  }
}

class AboutCard extends StatelessWidget {
  const AboutCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              context.watch<ShellState>().cardCornerRadius)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: EdgeInsets.all(context.watch<ShellState>().gutters),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 72,
                  foregroundImage:
                      AssetImage('images/photo_cropped_small.jpg')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Guilherme Pata',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Text(
              'MSc Biomedical Engineering',
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: 12,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(.6)),
            ),
            Divider(
              height: 56,
              indent: 72,
              endIndent: 72,
            ),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                    text:
                        'Welcome to place on the web! I built this website myself using Flutter. Here you can find my essays and my')
              ]),
              strutStyle: StrutStyle(
                height: Theme.of(context).textTheme.bodyText2.height,
                forceStrutHeight: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
