import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'classes.dart';
import 'home_page.dart';
import 'app_state.dart';
import 'app_shell.dart';
import 'widgets.dart';
import 'essays_page.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({Key? key, this.onArticleTapped}) : super(key: key);

  final void Function(Article)? onArticleTapped;

  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset > 0) {
        context.read<ShellState>().pastTitleNotifier.value = true;
      } else {
        context.read<ShellState>().pastTitleNotifier.value = false;
      }
    });
    MouseState().addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    MouseState().removeListener(() {
      setState(() {});
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ShellState, Tuple2<bool, double>>(
        selector: (_, state) =>
            Tuple2(state.displayMobileLayout, state.gutters),
        builder: (context, state, _) {
          return Scaffold(
            body: Scrollbar(
              thickness: MouseState.isPresent ? null : 0,
              isAlwaysShown: MouseState.isPresent,
              controller: scrollController,
              child: SmoothScroller(
                controller: scrollController,
                child: ListView.separated(
                  physics: MouseState.isPresent
                      ? NeverScrollableScrollPhysics()
                      : null,
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(vertical: state.item2),
                  itemCount: 2,
                  separatorBuilder: (context, int i) {
                    if (MediaQuery.of(context).size.width > 600)
                      return SizedBox(
                        height: state.item2,
                      );
                    else
                      return Material(
                        // color: Colors.white,
                        child: Divider(
                          height: 0.5,
                        ),
                      );
                  },
                  itemBuilder: (context, int i) {
                    if (i == 0)
                      return ContentTile(
                        title: 'Rhythm App',
                        subtitle:
                            'A timer and metronome to use at the gym. WIP, and built for small screen sizes oriented in portrait mode.',
                        onTap: () {
                          launch(
                              'https://guilhermepata.github.io/rhythm_app_web/#/');
                        },
                        imageUrl:
                            'https://cdn.dribbble.com/users/1622791/screenshots/11174104/flutter_intro.png',
                      );
                    if (i == 1)
                      return ContentTile(
                        title: 'Song ranker',
                        subtitle:
                            'A responsive web app to rank songs in an album. Built for both web and mobile, adjusting comfortably to any screen size.',
                        onTap: () {
                          launch(
                              'https://guilhermepata.github.io/song_ranker_web/#/');
                        },
                        imageUrl:
                            'https://cdn.dribbble.com/users/1622791/screenshots/11174104/flutter_intro.png',
                      );
                    else
                      return SizedBox(
                        height: 0,
                      );
                  },
                ),
              ),
            ),
          );
        });
  }
}
