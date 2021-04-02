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
              child: ListView.separated(
                physics: MouseState.isPresent
                    ? NeverScrollableScrollPhysics()
                    : null,
                controller: scrollController,
                padding:
                    EdgeInsets.only(bottom: state.item2 * 4, left: 8, right: 8),
                itemCount: 3,
                separatorBuilder: (context, int i) {
                  if (i == 0)
                    return SizedBox(
                      height: 0,
                    );
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: Material(
                        elevation: 2,
                        color: Theme.of(context).colorScheme.surface,
                        child: Divider(
                          height: 0,
                        ),
                      ),
                    ),
                  );
                },
                itemBuilder: (context, int i) {
                  if (i == 0)
                    return Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: state.item2, vertical: 4),
                          title: Text('Projects'),
                        ),
                      ),
                    );
                  if (i == 1)
                    return ContentTile(
                      placement: TilePlacement.start,
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
                  if (i == 2)
                    return ContentTile(
                      placement: TilePlacement.end,
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
          );
        });
  }
}
