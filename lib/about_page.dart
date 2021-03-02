import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_shell.dart';
import 'classes.dart';
import 'app_shell.dart';
import 'app_state.dart';

class AboutPage extends StatelessWidget {
  final void Function(AppMenu) onMenuTapped;

  const AboutPage({Key key, this.onMenuTapped}) : super(key: key);

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
      child: AboutCard(
        onMenuTapped: onMenuTapped,
      ),
    );
  }
}

class AboutCard extends StatelessWidget {
  final void Function(AppMenu) onMenuTapped;

  const AboutCard({
    Key key,
    @required this.onMenuTapped,
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
                      AssetImage('assets/images/photo_cropped_small.jpeg')),
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
              TextSpan(
                children: [
                  TextSpan(
                    text:
                        'Welcome to my place on the web! I am a Biomedical Engineering student and aspiring neuroscientist, ',
                  ),
                  TextSpan(
                    text: 'and I built this website using ',
                  ),
                  LinkSpan(
                    child: LinkTextWidget(
                      'Flutter',
                      fraction: 1,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.6),
                          ),
                      onTap: () {
                        launch('https://flutter.dev');
                      },
                    ),
                  ),
                  TextSpan(
                    text: '. Here you can find my ',
                  ),
                  LinkSpan(
                    child: LinkTextWidget(
                      'essays',
                      fraction: 1,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.6),
                          ),
                      onTap: () {
                        onMenuTapped(AppMenu.essays);
                      },
                    ),
                  ),
                  TextSpan(
                    text: ' and my other little ',
                  ),
                  LinkSpan(
                    child: LinkTextWidget(
                      'projects',
                      fraction: 1,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.6),
                          ),
                      onTap: () {
                        onMenuTapped(AppMenu.projects);
                      },
                    ),
                  ),
                  TextSpan(
                    text: '. You can check out my ',
                  ),
                  LinkSpan(
                    child: LinkTextWidget(
                      'Medium',
                      fraction: 1,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.6),
                          ),
                      onTap: () {
                        launch('https://guilhermepata.medium.com');
                      },
                    ),
                  ),
                  TextSpan(
                    text: ' page too, where I also publish my essays.',
                  ),
                  TextSpan(
                    text: ' The code for all of this is freely available on ',
                  ),
                  LinkSpan(
                    child: LinkTextWidget(
                      'GitHub',
                      fraction: 1,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.6),
                          ),
                      onTap: () {
                        launch('https://github.com/guilhermepata/blog');
                      },
                    ),
                  ),
                  TextSpan(
                    text: '. Enjoy!',
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withOpacity(.6),
                  ),
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
