import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_shell.dart';
import 'classes.dart';
import 'app_shell.dart';
import 'app_state.dart';
import 'widgets.dart';

class AboutPage extends StatefulWidget {
  final void Function(AppMenu) onMenuTapped;

  const AboutPage({Key key, this.onMenuTapped}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset > 0) {
        context.read<ShellState>().appBarFlinger = Fling.forward;
      } else {
        context.read<ShellState>().appBarFlinger = Fling.backward;
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
    return Consumer<ShellState>(
      builder: (context, state, child) {
        return Scaffold(
          body: Scrollbar(
            controller: scrollController,
            isAlwaysShown: MouseState.isPresent,
            thickness: MouseState.isPresent ? null : 0,
            child: SmoothScroller(
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                physics: MouseState.isPresent
                    ? NeverScrollableScrollPhysics()
                    : null,
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
            ),
          ),
        );
      },
      child: AboutCard(
        onMenuTapped: widget.onMenuTapped,
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
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 456,
                ),
                child: Divider(
                  height: 56,
                  indent: 24,
                  endIndent: 24,
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: 456,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'pata  ',
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(.6)),
                        ),
                        TextSpan(
                          text: '/ˈpa.tɐ/\n',
                          style: GoogleFonts.notoSans(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.6),
                            letterSpacing: 1,
                          ),
                        ),
                        TextSpan(
                          text: 'noun. f.s. noun: ',
                          style: Theme.of(context).textTheme.caption.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                              ),
                        ),
                        TextSpan(
                          text: 'pata',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(fontWeight: FontWeight.bold)
                              .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                              ),
                        ),
                        TextSpan(
                          text: '; m.s. noun: ',
                          style: Theme.of(context).textTheme.caption.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                              ),
                        ),
                        TextSpan(
                          text: 'pato',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(fontWeight: FontWeight.bold)
                              .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                              ),
                        ),
                        // TextSpan(
                        //   text: '; n.s. noun: ',
                        //   style: Theme.of(context).textTheme.caption,
                        // ),
                        // TextSpan(
                        //   text: 'pate',
                        //   style: Theme.of(context)
                        //       .textTheme
                        //       .caption
                        //       .copyWith(fontWeight: FontWeight.bold),
                        // ),
                        TextSpan(
                          text: '; f.p. noun: ',
                          style: Theme.of(context).textTheme.caption.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                              ),
                        ),
                        TextSpan(
                          text: 'patas',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(fontWeight: FontWeight.bold)
                              .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                              ),
                        ),
                        TextSpan(
                          text: '; m.p. noun: ',
                          style: Theme.of(context).textTheme.caption.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                              ),
                        ),
                        TextSpan(
                          text: 'patos',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(fontWeight: FontWeight.bold)
                              .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                              ),
                        ),
                        // TextSpan(
                        //   text: '; n.p. noun: ',
                        //   style: Theme.of(context).textTheme.caption,
                        // ),
                        // TextSpan(
                        //   text: 'pates',
                        //   style: Theme.of(context)
                        //       .textTheme
                        //       .caption
                        //       .copyWith(fontWeight: FontWeight.bold),
                        // ),
                        TextSpan(
                          text: '.',
                          style: Theme.of(context).textTheme.caption.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Text.rich(
                      TextSpan(
                        text:
                            '1.  a waterbird with a broad blunt bill, short legs, webbed feet, and a waddling gait.',
                      ),
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.6),
                          ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Etymology: ',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextSpan(
                          text: 'from Old Portuguese ',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                                fontSize: 12,
                              ),
                        ),
                        TextSpan(
                          text: 'pato',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                        TextSpan(
                          text:
                              ' (“duck”), from Andalusian Arabic  بَطّ‎  (paṭṭ), from Arabic  بَطّ‎  (baṭṭ, “duck”), from Persian  بت‎  (bat, “duck”).\n',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.38),
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 56,
              indent: 72,
              endIndent: 72,
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: 456,
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Welcome to my place on the web, which ',
                    ),
                    TextSpan(
                      text: 'I built using ',
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
                      text:
                          '! I am a biomedical engineering student and aspiring neuroscientist. Here you can find my ',
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(.6),
                    ),
                strutStyle: StrutStyle(
                  height: Theme.of(context).textTheme.bodyText2.height,
                  forceStrutHeight: true,
                ),
              ),
            ),
            SizedBox(
              height: 48 - 16.0,
            ),
          ],
        ),
      ),
    );
  }
}
