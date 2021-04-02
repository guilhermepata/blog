import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tuple/tuple.dart';
import 'package:provider/provider.dart';
import 'classes.dart';
import 'home_page.dart';
import 'app_state.dart';
import 'app_shell.dart';
import 'widgets.dart';

class EssaysScreen extends StatefulWidget {
  const EssaysScreen({Key? key, this.onArticleTapped}) : super(key: key);

  final void Function(Article)? onArticleTapped;

  @override
  _EssaysScreenState createState() => _EssaysScreenState();
}

class _EssaysScreenState extends State<EssaysScreen> {
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
    return Selector<ShellState,
            Tuple5<bool, double, List<Article>, bool, bool>>(
        selector: (_, state) => Tuple5(
              state.displayMobileLayout,
              state.gutters,
              state.articles,
              state.areArticlesLoaded,
              state.refresher,
            ),
        builder: (context, state, _) {
          return Scaffold(
            body: Scrollbar(
              thickness: MouseState.isPresent ? null : 0,
              isAlwaysShown: MouseState.isPresent,
              controller: scrollController,
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<AppState>().loadArticles();
                  await context.read<ShellState>().refreshArticles();
                },
                child: ListView.separated(
                  clipBehavior: Clip.none,
                  physics: MouseState.isPresent
                      ? NeverScrollableScrollPhysics()
                      : AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  padding: EdgeInsets.only(
                      bottom: state.item2 * 4, left: 8, right: 8),
                  itemCount: state.item3.length + 1,
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
                            title: Text('Essays'),
                          ),
                        ),
                      );
                    return ArticleTile(
                      state.item3[i - 1],
                      onArticleTapped: widget.onArticleTapped,
                      placement:
                          ItemPlacement.placement(i - 1, state.item3.length),
                    );
                  },
                ),
              ),
            ),
          );
        });
  }
}

class ContentTile extends StatefulWidget {
  const ContentTile({
    Key? key,
    this.title,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.future,
    this.condition = true,
    this.placement = TilePlacement.lone,
  }) : super(key: key);

  final Future<dynamic>? future;
  final bool condition;
  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final void Function()? onTap;
  final TilePlacement placement;

  @override
  _ContentTileState createState() => _ContentTileState();
}

class _ContentTileState extends State<ContentTile> {
  final double imageSide = 72 + 16;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.future ?? Future(() {}),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Selector<ShellState, double>(
                selector: (_, state) => state.cardCornerRadius,
                builder: (contex, cardCornerRadius, child) {
                  return Card(
                    elevation: isHovered ? 8 : 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: widget.placement == TilePlacement.lone
                            ? BorderRadius.circular(cardCornerRadius)
                            : widget.placement == TilePlacement.start
                                ? BorderRadius.vertical(
                                    top: Radius.circular(cardCornerRadius))
                                : widget.placement == TilePlacement.end
                                    ? BorderRadius.vertical(
                                        bottom:
                                            Radius.circular(cardCornerRadius))
                                    : BorderRadius.zero),
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.hardEdge,
                    child: child,
                  );
                },
                child: InkWell(
                  onTap: widget.onTap,
                  onHover: (_) => setState(() {
                    isHovered = _;
                  }),
                  child: Row(
                    children: [
                      Expanded(
                        child: Selector<ShellState, double>(
                          selector: (_, state) => state.gutters,
                          builder: (context, gutters, child) {
                            return Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: gutters),
                              child: child,
                            );
                          },
                          child: ListTile(
                            // isThreeLine: true,
                            contentPadding: EdgeInsets.zero,
                            title: CrossFadeText(
                              widget.condition ? widget.title : null,
                              showText: widget.condition,
                              maxLines: 1,
                              // style: Theme.of(context).textTheme.headline5,
                              // width: 200,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: CrossFadeTextWidgetBlock(
                                Text(
                                  widget.condition ? widget.subtitle! : '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                showText: widget.condition,
                                numLines: 2,
                                // style: Theme.of(context)
                                //     .textTheme
                                //     .subtitle1
                                //     .copyWith(
                                //         color: Theme.of(context)
                                //             .colorScheme
                                //             .onSurface
                                //             .withOpacity(.60)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          height: imageSide,
                          width: imageSide,
                          child: CrossFadeWidgets(
                            showFirst: widget.condition,
                            firstChild: widget.condition
                                ? Ink(
                                    width: imageSide,
                                    height: imageSide,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          widget.imageUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : null,
                            secondChild: Skeleton(
                              width: imageSide,
                              height: imageSide,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class ArticleTile extends StatefulWidget {
  const ArticleTile(this.article,
      {Key? key,
      required this.onArticleTapped,
      this.placement = TilePlacement.lone})
      : super(key: key);

  final Article article;
  final void Function(Article)? onArticleTapped;
  final TilePlacement placement;

  @override
  _ArticleTileState createState() => _ArticleTileState();
}

class _ArticleTileState extends State<ArticleTile> {
  final double imageSide = 72 + 16;

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
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
                    elevation: isHovered ? 8 : 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: widget.placement == TilePlacement.lone
                            ? BorderRadius.circular(cardCornerRadius)
                            : widget.placement == TilePlacement.start
                                ? BorderRadius.vertical(
                                    top: Radius.circular(cardCornerRadius))
                                : widget.placement == TilePlacement.end
                                    ? BorderRadius.vertical(
                                        bottom:
                                            Radius.circular(cardCornerRadius))
                                    : BorderRadius.zero),
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.hardEdge,
                    child: child,
                  );
                },
                child: InkWell(
                  onTap: () => widget.onArticleTapped!(widget.article),
                  onHover: (_) => setState(() {
                    isHovered = _;
                  }),
                  // hoverColor: Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: Selector<ShellState, double>(
                          selector: (_, state) => state.gutters,
                          builder: (context, gutters, child) {
                            return Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: gutters),
                              child: child,
                            );
                          },
                          child: ListTile(
                            // isThreeLine: true,
                            contentPadding: EdgeInsets.zero,
                            title: CrossFadeText(
                              widget.article.isLoaded
                                  ? widget.article.title
                                  : null,
                              showText: widget.article.isLoaded,
                              // style: Theme.of(context).textTheme.headline5,
                              // width: 200,
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: CrossFadeTextWidgetBlock(
                                Text(
                                  widget.article.isLoaded
                                      ? widget.article.subtitle!
                                      : '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                                showText: widget.article.isLoaded,
                                numLines: 2,
                                // style: Theme.of(context)
                                //     .textTheme
                                //     .subtitle1
                                //     .copyWith(
                                //         color: Theme.of(context)
                                //             .colorScheme
                                //             .onSurface
                                //             .withOpacity(.60)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CrossFadeWidgets(
                          showFirst: widget.article.isLoaded,
                          firstChild: widget.article.isLoaded
                              ? Ink(
                                  width: imageSide,
                                  height: imageSide,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        widget.article.imageUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // child:
                                  // fit: BoxFit.cover,
                                  // image: NetworkImage(
                                  //   article.imageUrl!,
                                  // ),
                                )
                              : null,
                          secondChild: Skeleton(
                            width: imageSide,
                            height: imageSide,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

enum TilePlacement { start, middle, end, lone }

extension ItemPlacement on TilePlacement {
  static TilePlacement placement(int index, int length) {
    if (length == 1) return TilePlacement.lone;
    if (index == 0) return TilePlacement.start;
    if (index == length - 1) return TilePlacement.end;
    return TilePlacement.middle;
  }
}
