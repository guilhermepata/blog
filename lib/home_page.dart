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
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = context.read<ShellState>().scrollController;
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
    return Selector<ShellState, Tuple4<bool, double, List<Article>, bool>>(
        selector: (_, state) => Tuple4(state.displayMobileLayout, state.gutters,
            state.articles, state.areArticlesLoaded),
        builder: (context, state, _) {
          final articles = state.item3;
          // final articleCards = <Widget>[];

          // for (var article in articles) {
          //   articleCards.add(
          //       ArticleCard(article, onArticleTapped: widget.onArticleTapped));
          // }

          return Scaffold(
            body: Scrollbar(
              thickness: MouseState().isPresent ? null : 0,
              isAlwaysShown: MouseState().isPresent,
              controller: scrollController,
              child: SmoothScroller(
                controller: scrollController,
                child: ListView.separated(
                  physics: MouseState().isPresent
                      ? NeverScrollableScrollPhysics()
                      : null,
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(vertical: state.item2),
                  itemCount: state.item3.length,
                  separatorBuilder: (context, int i) =>
                      SizedBox(height: state.item2),
                  itemBuilder: (context, int i) {
                    return ArticleCard(state.item3[i],
                        onArticleTapped: widget.onArticleTapped);
                  },
                ),
              ),
            ),
          );
        });
  }
}

class ArticleCard extends StatefulWidget {
  const ArticleCard(
    this.article, {
    Key key,
    @required this.onArticleTapped,
  }) : super(key: key);

  // final AsyncSnapshot<String> snapshot;
  final Article article;
  final void Function(Article) onArticleTapped;

  @override
  _ArticleCardState createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  @override
  Widget build(BuildContext context) {
    // return Consumer<ShellState>(
    //   builder: (context, state, _) {
    //     // final cardCornerRadius = state.cardCornerRadius;
    //     // final gutters = state.gutters;

    //   },
    // );

    return FutureBuilder(
        future: widget.article.load(),
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
                        showFirst: widget.article.isLoaded,
                        firstChild: widget.article.isLoaded
                            ? Image.network(
                                widget.article.imageUrl,
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
                                semanticLabel: widget.article.altText,
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
                            widget.article.isLoaded
                                ? widget.article.title
                                : null,
                            showText: widget.article.isLoaded,
                            style: Theme.of(context).textTheme.headline5,
                            // width: 200,
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          CrossFadeText(
                            widget.article.isLoaded
                                ? widget.article.subtitle
                                : null,
                            showText: widget.article.isLoaded,
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
                          CrossFadeTextWidgetBlock(
                              widget.article.isLoaded
                                  ? widget.article.buildParagraph(context, 0,
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
                              showText: widget.article.isLoaded,
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
                      showFirst: widget.article.isLoaded,
                      firstChild: ButtonBar(
                        buttonPadding:
                            EdgeInsets.all(context.read<ShellState>().gutters),
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                widget.onArticleTapped(widget.article);
                              },
                              child: Text('Read more')),
                        ],
                      ),
                      secondChild: ButtonBar(
                        buttonPadding:
                            EdgeInsets.all(context.read<ShellState>().gutters),
                        children: [
                          ElevatedButton(
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
        children: article.buildContents(context),
      ),
    ));
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
