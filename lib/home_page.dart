import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'classes.dart';
import 'app_state.dart';
import 'app_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    //   return Consumer<ShellState>(
    //     builder: (context, state, child) {
    //       // bool displayMobileLayout = state.displayMobileLayout;
    //       // double margins = state.margins;
    //       // double gutters = state.gutters;
    //       // double cardCornerRadius = state.cardCornerRadius;
    //       // List<Article> articles = state.articles;
    //       // ScrollController scrollController = state.scrollController;

    //       },
    //   );
    // }
    return Scaffold(
      body:
          // Container(color: Colors.red),
          Scrollbar(
        // thickness: 4
        isAlwaysShown: !context.read<ShellState>().displayMobileLayout ?? false,
        controller: context.read<ShellState>().scrollController,
        child: ListView.builder(
          controller: context.read<ShellState>().scrollController,
          padding: EdgeInsets.only(
              left: context.read<ShellState>().margins,
              right: context.read<ShellState>().margins,
              top: context.read<ShellState>().gutters,
              bottom: context.read<ShellState>().gutters),
          itemCount: context.read<ShellState>().articles.length,
          itemBuilder: (context, int i) {
            return ArticleCard(context.read<ShellState>().articles[i]);
          },
        ),
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  const ArticleCard(
    this.article, {
    Key key,
  }) : super(key: key);

  // final AsyncSnapshot<String> snapshot;
  final Article article;

  void onArticleTapped(BuildContext context, Article article) {
    context.read<AppState>().selectedArticle = article;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShellState>(
      builder: (context, state, _) {
        // final cardCornerRadius = state.cardCornerRadius;
        // final gutters = state.gutters;

        return FutureBuilder(
            future: article.load(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(state.cardCornerRadius)),
                margin: EdgeInsets.zero,
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    CrossFadeWidgets(
                        showFirst: article.isLoaded,
                        firstChild: article.isLoaded
                            ? Image.network(
                                article.imageUrl,
                                frameBuilder: (BuildContext context,
                                    Widget child,
                                    int frame,
                                    bool wasSynchronouslyLoaded) {
                                  if (wasSynchronouslyLoaded ?? false) {
                                    return child;
                                  }
                                  return Stack(
                                    children: [
                                      Skeleton(
                                        width: 600,
                                        height: 600 / 21 * 9,
                                      ),
                                      AnimatedOpacity(
                                        child: child,
                                        opacity: frame == null ? 0 : 1,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.easeIn,
                                      ),
                                    ],
                                  );
                                },
                                loadingBuilder: (BuildContext context,
                                    Widget child, ImageChunkEvent progress) {
                                  return Stack(
                                    children: [
                                      if (progress != null)
                                        Skeleton(
                                          width: 600,
                                          height: 600 / 21 * 9,
                                        ),
                                      child
                                    ],
                                  );
                                },
                                semanticLabel: article.altText,
                                width: 600,
                                height: 600 / 21 * 9,
                                fit: BoxFit.cover,
                                // width: 300,
                              )
                            : null,
                        secondChild: Skeleton(
                          width: 600,
                          height: 600 / 21 * 9,
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          top: state.gutters,
                          left: state.gutters,
                          right: state.gutters),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CrossFadeText(
                            article.isLoaded ? article.title : null,
                            showText: article.isLoaded,
                            style: Theme.of(context).textTheme.headline5,
                            // width: 200,
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          CrossFadeText(
                            article.isLoaded ? article.subtitle : null,
                            showText: article.isLoaded,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(.60)),
                            // width: 300,
                          ),
                          SizedBox(height: 12),
                          Container(
                            height: 14 * 1.5 * 3.9,
                            child: CrossFadeTextWidgetBlock(
                                article.isLoaded
                                    ? article
                                        .buildParagraphs(context,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(.60)),
                                            overflow: TextOverflow.fade,
                                            textAlign: TextAlign.justify)
                                        .first
                                    : null,
                                showText: article.isLoaded,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(.60)),
                                overflow: TextOverflow.fade,
                                textAlign: TextAlign.justify),
                          ),
                        ],
                      ),
                    ),
                    CrossFadeWidgets(
                      showFirst: article.isLoaded,
                      firstChild: ButtonBar(
                        buttonPadding: EdgeInsets.all(state.gutters),
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                onArticleTapped(context, article);
                              },
                              child: Text('Read more')),
                        ],
                      ),
                      secondChild: ButtonBar(
                        buttonPadding: EdgeInsets.all(state.gutters),
                        children: [
                          ElevatedButton(
                              onPressed: null, child: Text('Read more')),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }
}

class CrossFadeTextWidgetBlock extends StatelessWidget {
  final bool showText;
  final Widget textWidget;
  final TextStyle style;
  final double width;
  final int numLines;
  final TextOverflow overflow;
  final TextAlign textAlign;

  const CrossFadeTextWidgetBlock(
    this.textWidget, {
    Key key,
    @required this.showText,
    this.style,
    this.width,
    this.numLines = 5,
    this.overflow,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    for (var i = 0; i < numLines; i++) {
      children.add(
        Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Text(
              ' ',
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            ),
            Skeleton(
              width: width,
              height: style != null ? style.fontSize * 0.8 : 16 * 0.8,
            ),
          ],
        ),
      );
    }

    return CrossFadeWidgets(
        showFirst: showText,
        firstChild: textWidget ??
            Text(
              '',
              style: style,
              textAlign: textAlign,
              overflow: overflow,
            ),
        secondChild: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: children,
          ),
        ));
  }
}

class CrossFadeText extends StatelessWidget {
  final bool showText;
  final String text;
  final TextStyle style;
  final double width;

  const CrossFadeText(
    this.text, {
    Key key,
    @required this.showText,
    this.style,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CrossFadeWidgets(
        showFirst: showText,
        firstChild: Text(
          text ?? '',
          style: style,
          textAlign: TextAlign.left,
          overflow: TextOverflow.fade,
        ),
        secondChild: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Text(
              ' ',
              style: style,
              textAlign: TextAlign.left,
            ),
            Skeleton(
              width: width,
              height: style != null ? style.fontSize * 0.8 : 16 * 0.8,
            ),
          ],
        ));
  }
}

class CrossFadeWidgets extends StatelessWidget {
  const CrossFadeWidgets({
    Key key,
    @required this.firstChild,
    @required this.secondChild,
    @required this.showFirst,
  }) : super(key: key);

  final Widget firstChild;
  final Widget secondChild;
  final bool showFirst;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      alignment: Alignment.topLeft,
      sizeCurve: Curves.fastOutSlowIn,
      firstCurve: Curves.fastOutSlowIn,
      secondCurve: Curves.fastOutSlowIn,
      firstChild: showFirst ? firstChild : secondChild,
      secondChild: secondChild,
      crossFadeState:
          showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 300),
    );
  }
}

class BodyCard extends StatelessWidget {
  const BodyCard({
    Key key,
    @required this.gutters,
    @required this.article,
  }) : super(key: key);

  final double gutters;
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: EdgeInsets.all(gutters),
      child: Column(
        children: article.buildParagraphs(context),
      ),
    ));
  }
}

enum DrawerState { closed, closing, open, opening }

class Skeleton extends StatefulWidget {
  final double height;
  final double width;

  Skeleton({Key key, this.height = 20, this.width}) : super(key: key);

  createState() => SkeletonState();
}

class SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Animation opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);

    opacity = Tween<double>(
      begin: .12,
      end: .26,
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceIn,
        reverseCurve: Curves.bounceOut))
      ..addListener(() {
        setState(() {});
      });

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.width,
        height: widget.height,
        decoration:
            BoxDecoration(color: Colors.black12.withOpacity(opacity.value)));
  }
}
