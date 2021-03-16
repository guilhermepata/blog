import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'classes.dart';
import 'app_state.dart';
import 'app_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key key,
    @required this.onArticleTapped,
  }) : super(key: key);

  final void Function(Article) onArticleTapped;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    // context.read<AppState>().addListener(scrollControllerListener);
    MouseState().addListener(() {
      setState(() {});
    });
  }

  // void scrollControllerListener() {
  //   if (context.read<AppState>().selectedMenu != AppMenu.home && mounted)
  //     setState(() {
  //       scrollController = null;
  //     });
  // }

  @override
  void dispose() {
    MouseState().removeListener(() {
      setState(() {});
    });
    // context.read<AppState>().removeListener(scrollControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ShellState, Tuple4<bool, double, List<Article>, bool>>(
        selector: (_, state) => Tuple4(state.displayMobileLayout, state.gutters,
            state.articles, state.areArticlesLoaded),
        builder: (context, state, _) {
          // final articleCards = <Widget>[];

          // for (var article in articles) {
          //   articleCards.add(
          //       ArticleCard(article, onArticleTapped: widget.onArticleTapped));
          // }

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
                  itemCount: state.item3.length,
                  separatorBuilder: (context, int i) =>
                      SizedBox(height: state.item2),
                  itemBuilder: (context, int i) {
                    return ArticleCard2(state.item3[i],
                        onArticleTapped: widget.onArticleTapped);
                  },
                ),
              ),
            ),
          );
        });
  }
}

class ArticleCard extends StatelessWidget {
  const ArticleCard(
    this.article, {
    Key key,
    @required this.onArticleTapped,
  }) : super(key: key);

  // final AsyncSnapshot<String> snapshot;
  final Article article;
  final void Function(Article) onArticleTapped;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: article.load(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Selector<ShellState, double>(
                selector: (_, state) => state.cardCornerRadius,
                builder: (contex, cardCornerRadius, child) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(cardCornerRadius)),
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.hardEdge,
                    child: child,
                  );
                },
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
                    Selector<ShellState, double>(
                      selector: (_, state) => state.gutters,
                      builder: (context, gutters, child) {
                        return Padding(
                          padding: EdgeInsets.only(
                              top: gutters, left: gutters, right: gutters),
                          child: child,
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CrossFadeText(
                            article.isLoaded ? article.title : null,
                            showText: article.isLoaded,
                            style: Theme.of(context).textTheme.headline5,
                            maxLines: 200,
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
                            maxLines: 1000,
                            // width: 300,
                          ),
                          SizedBox(height: 12),
                          CrossFadeTextWidgetBlock(
                              article.isLoaded
                                  ? article.buildParagraph(context, 0,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(.60)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                      textAlign: TextAlign.justify)
                                  : null,
                              showText: article.isLoaded,
                              numLines: 4,
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
                        ],
                      ),
                    ),
                    CrossFadeWidgets(
                      showFirst: article.isLoaded,
                      firstChild: ButtonBar(
                        buttonPadding:
                            EdgeInsets.all(context.read<ShellState>().gutters),
                        children: [
                          OutlinedButton(
                              onPressed: () {
                                onArticleTapped(article);
                              },
                              child: Text('Read more')),
                        ],
                      ),
                      secondChild: ButtonBar(
                        buttonPadding:
                            EdgeInsets.all(context.read<ShellState>().gutters),
                        children: [
                          OutlinedButton(
                              onPressed: null, child: Text('Read more')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class ArticleCard2 extends StatelessWidget {
  const ArticleCard2(
    this.article, {
    Key key,
    @required this.onArticleTapped,
  }) : super(key: key);

  // final AsyncSnapshot<String> snapshot;
  final Article article;
  final void Function(Article) onArticleTapped;

  final double imageAspectRatio = 16 / 9;
  final double maxContentWidth = 600;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: article.load(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Selector<ShellState, double>(
                selector: (_, state) => state.cardCornerRadius,
                builder: (contex, cardCornerRadius, child) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(cardCornerRadius)),
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.hardEdge,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: imageAspectRatio,
                      child: Stack(
                        alignment: AlignmentDirectional.bottomStart,
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
                                              width: maxContentWidth,
                                              height: maxContentWidth /
                                                  imageAspectRatio,
                                            ),
                                            AnimatedOpacity(
                                              child: child,
                                              opacity: frame == null ? 0 : 1,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.easeIn,
                                            ),
                                          ],
                                        );
                                      },
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent progress) {
                                        return Stack(
                                          children: [
                                            if (progress != null)
                                              Skeleton(
                                                width: maxContentWidth,
                                                height: maxContentWidth /
                                                    imageAspectRatio,
                                              ),
                                            child
                                          ],
                                        );
                                      },
                                      semanticLabel: article.altText,
                                      width: maxContentWidth,
                                      height:
                                          maxContentWidth / imageAspectRatio,
                                      fit: BoxFit.cover,
                                      // width: 300,
                                    )
                                  : null,
                              secondChild: Skeleton(
                                width: maxContentWidth,
                                height: maxContentWidth / imageAspectRatio,
                              )),
                          Container(
                            height: maxContentWidth / imageAspectRatio,
                            alignment: Alignment.bottomLeft,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Selector<ShellState, double>(
                              selector: (_, state) => state.gutters,
                              builder: (context, gutters, child) {
                                return Padding(
                                  padding: EdgeInsets.all(gutters),
                                  child: child,
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CrossFadeText(
                                    article.isLoaded ? article.title : null,
                                    showText: article.isLoaded,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        .copyWith(
                                            color:
                                                Colors.white.withOpacity(.87)),
                                    maxLines: 200,
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
                                            color:
                                                Colors.white.withOpacity(.60)),
                                    maxLines: 1000,
                                    // width: 300,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Selector<ShellState, double>(
                      selector: (_, state) => state.gutters,
                      builder: (context, gutters, child) {
                        return Padding(
                          padding: EdgeInsets.only(
                              top: gutters, left: gutters, right: gutters),
                          child: child,
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CrossFadeTextWidgetBlock(
                              article.isLoaded
                                  ? article.buildParagraph(context, 0,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(.60)),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                      paragraphSpacing: 0,
                                      textAlign: TextAlign.justify)
                                  : null,
                              showText: article.isLoaded,
                              numLines: 4,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(.60)),
                              textAlign: TextAlign.justify),
                        ],
                      ),
                    ),
                    CrossFadeWidgets(
                      showFirst: article.isLoaded,
                      firstChild: ButtonBar(
                        buttonPadding:
                            EdgeInsets.all(context.read<ShellState>().gutters),
                        children: [
                          OutlinedButton(
                              onPressed: () {
                                onArticleTapped(article);
                              },
                              child: Text('Read more')),
                        ],
                      ),
                      secondChild: ButtonBar(
                        buttonPadding:
                            EdgeInsets.all(context.read<ShellState>().gutters),
                        children: [
                          OutlinedButton(
                              onPressed: null, child: Text('Read more')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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
              '',
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
  final int maxLines;

  const CrossFadeText(
    this.text, {
    Key key,
    @required this.showText,
    this.style,
    this.width,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CrossFadeWidgets(
        showFirst: showText,
        firstChild: Text(
          text ?? ' ',
          style: style,
          textAlign: TextAlign.left,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: maxLines,
        ),
        secondChild: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Text(
              ' ',
              style: style,
              textAlign: TextAlign.left,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
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
