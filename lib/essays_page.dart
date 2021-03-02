import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:provider/provider.dart';
import 'classes.dart';
import 'home_page.dart';
import 'app_state.dart';
import 'app_shell.dart';
import 'widgets.dart';

class EssaysScreen extends StatefulWidget {
  const EssaysScreen({Key key, this.onArticleTapped}) : super(key: key);

  final void Function(Article) onArticleTapped;

  @override
  _EssaysScreenState createState() => _EssaysScreenState();
}

class _EssaysScreenState extends State<EssaysScreen> {
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
                    return ArticleTile(state.item3[i],
                        onArticleTapped: widget.onArticleTapped);
                  },
                ),
              ),
            ),
          );
        });
  }
}

class ArticleTile extends StatelessWidget {
  const ArticleTile(this.article, {Key key, @required this.onArticleTapped})
      : super(key: key);

  final Article article;
  final void Function(Article) onArticleTapped;
  final double imageSide = 72 + 48.0 + 8;

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
                child: InkWell(
                  onTap: () => onArticleTapped(article),
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
                              article.isLoaded ? article.title : null,
                              showText: article.isLoaded,
                              // style: Theme.of(context).textTheme.headline5,
                              // width: 200,
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: CrossFadeTextWidgetBlock(
                                Text(
                                  article.isLoaded ? article.subtitle : '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                showText: article.isLoaded,
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
                          showFirst: article.isLoaded,
                          firstChild: article.isLoaded
                              ? Ink.image(
                                  width: imageSide,
                                  height: imageSide,
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    article.imageUrl,
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
