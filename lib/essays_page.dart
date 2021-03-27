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
    return Selector<ShellState, Tuple4<bool, double, List<Article>, bool>>(
        selector: (_, state) => Tuple4(state.displayMobileLayout, state.gutters,
            state.articles, state.areArticlesLoaded),
        builder: (context, state, _) {
          return Scaffold(
            body: Scrollbar(
              thickness: MouseState.isPresent ? null : 0,
              isAlwaysShown: MouseState.isPresent,
              controller: scrollController,
              child: ListView.separated(
                clipBehavior: Clip.none,
                physics: MouseState.isPresent
                    ? NeverScrollableScrollPhysics()
                    : null,
                controller: scrollController,
                padding: EdgeInsets.only(bottom: state.item2 * 4),
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
                  return ArticleTile(state.item3[i - 1],
                      onArticleTapped: widget.onArticleTapped);
                },
              ),
            ),
          );
        });
  }
}

class ContentTile extends StatelessWidget {
  const ContentTile({
    Key? key,
    this.title,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.future,
    this.condition = true,
  }) : super(key: key);

  final Future<dynamic>? future;
  final bool condition;
  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final void Function()? onTap;

  final double imageSide = 72 + 48.0 + 8;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future ?? Future(() {}),
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
                child: InkWell(
                  onTap: onTap,
                  child: Row(
                    children: [
                      Expanded(
                        child: Selector<ShellState, double>(
                          selector: (_, state) => state.gutters,
                          builder: (context, gutters, child) {
                            return Padding(
                              padding: EdgeInsets.all(gutters),
                              child: child,
                            );
                          },
                          child: ListTile(
                            // isThreeLine: true,
                            contentPadding: EdgeInsets.zero,
                            title: CrossFadeText(
                              condition ? title : null,
                              showText: condition,
                              maxLines: 1,
                              // style: Theme.of(context).textTheme.headline5,
                              // width: 200,
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: CrossFadeTextWidgetBlock(
                                Text(
                                  condition ? subtitle! : '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                showText: condition,
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
                      SizedBox(
                        height: imageSide,
                        width: imageSide,
                        child: CrossFadeWidgets(
                          showFirst: condition,
                          firstChild: condition
                              ? Ink.image(
                                  width: imageSide,
                                  height: imageSide,
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    imageUrl!,
                                  ),
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

class ArticleTile extends StatefulWidget {
  const ArticleTile(this.article, {Key? key, required this.onArticleTapped})
      : super(key: key);

  final Article article;
  final void Function(Article)? onArticleTapped;

  @override
  _ArticleTileState createState() => _ArticleTileState();
}

class _ArticleTileState extends State<ArticleTile> {
  final double imageSide = 72 + 24;

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
                        borderRadius: BorderRadius.circular(cardCornerRadius)),
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
                  hoverColor: Colors.transparent,
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
                        padding: const EdgeInsets.all(8.0),
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
