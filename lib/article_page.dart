import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'classes.dart';

class ArticlePage extends StatefulWidget {
  final Article article;

  const ArticlePage({Key key, this.article}) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage>
    with SingleTickerProviderStateMixin {
  double width, height, usefulWidth, usefulHeight, margins, gutters;
  double appBarMargins;
  double maxContentWidth = 600;
  double contentWidth;
  double webLayoutMinWidth;
  double cardCornerRadius;
  double initialSheetHeight;
  double maxSheetHeight;
  double totalSheetHeightDelta;

  double imageScrollPosition = 0.0;

  bool isInitialized = false;
  bool isMobileLayout;
  bool isAppBarElevated = false;

  ScrollController scrollController = ScrollController();
  AnimationController appBarStateController;
  Animation<Color> appBarColor;

  Color dominantColor;
  Color lightVibrantColor;
  Color darkVibrantColor;

  bool get displayMobileLayout {
    return isMobileLayout;
  }

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.offset > totalSheetHeightDelta) {
        appBarStateController.fling();
      } else if (isAppBarElevated) {
        appBarStateController.fling(velocity: -1);
      }
    });

    appBarStateController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    appBarStateController.addStatusListener((status) {
      if (status == AnimationStatus.completed)
        setState(() {
          isAppBarElevated = true;
        });
      else if (status == AnimationStatus.dismissed)
        setState(() {
          isAppBarElevated = false;
        });
    });
    appBarStateController.addListener(() {
      setState(() {});
    });

    generatePalette();

    super.initState();
  }

  void generatePalette() async {
    PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.article.imageUrl),
        size: Size(200, 100));
    dominantColor =
        generator.dominantColor != null ? generator.dominantColor.color : null;
    lightVibrantColor = generator.lightVibrantColor != null
        ? generator.lightVibrantColor.color
        : null;
    darkVibrantColor = generator.darkVibrantColor != null
        ? generator.darkVibrantColor.color
        : null;
  }

  void buildState(BuildContext context) {
    setState(() {
      Size size = MediaQuery.of(context).size;
      width = size.width;
      usefulWidth = size.width;
      height = size.height;

      usefulHeight = size.height - 56;

      maxSheetHeight = usefulHeight;
      initialSheetHeight = usefulHeight / 3;
      totalSheetHeightDelta = maxSheetHeight - initialSheetHeight;

      if (width < 720) {
        gutters = 24;
        appBarMargins = 0;
      } else {
        gutters = 24;
        appBarMargins = 24;
      }

      webLayoutMinWidth = maxContentWidth + gutters * 2;

      isMobileLayout = width < webLayoutMinWidth;

      if (usefulWidth < maxContentWidth + gutters * 2) {
        if (usefulWidth < maxContentWidth)
          margins = 0;
        else
          margins = gutters;
      } else {
        margins = (usefulWidth - maxContentWidth) / 2;
      }

      contentWidth = usefulWidth - margins * 2;

      if (margins == 0)
        cardCornerRadius = 0;
      else
        cardCornerRadius = gutters / 4;

      if (!isInitialized) {
        appBarColor = ColorTween(
                begin: Colors.transparent,
                end: Color.alphaBlend(Colors.white.withOpacity(.09),
                    Theme.of(context).colorScheme.background))
            .animate(appBarStateController);
        appBarColor.addListener(() {
          setState(() {});
        });
      }

      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    buildState(context);
    final originalThemeData = Theme.of(context);

    var children2 =
        widget.article.buildParagraphs(context, textAlign: TextAlign.left);
    children2.add(ButtonBar(
      children: [ElevatedButton(onPressed: () {}, child: Text('Button'))],
    ));

    return Theme(
      data: originalThemeData.copyWith(
          accentColor: darkVibrantColor, primaryColor: lightVibrantColor),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          // elevation: appBarStateController.value * 4,
          shadowColor: Colors.black.withOpacity(appBarStateController.value),
          backgroundColor: appBarColor.value,
          leadingWidth: 56 + appBarMargins,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            widget.article.title,
            overflow: TextOverflow.fade,
            style: Theme.of(context).textTheme.headline6.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(appBarStateController.value * .87)),
          ),
        ),
        body: NotificationListener(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification)
              setState(
                  () => imageScrollPosition -= notification.scrollDelta / 4);
          },
          child: Stack(
            children: [
              Positioned(
                top: imageScrollPosition,
                child: Padding(
                  padding: EdgeInsets
                      .zero, //EdgeInsets.only(left: margins, right: margins),
                  child: Image.network(
                    widget.article.imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    width: usefulWidth,
                    // height: height,
                    semanticLabel: widget.article.altText,
                  ),
                ),
              ),
              Scrollbar(
                // thickness: 4,
                isAlwaysShown: !displayMobileLayout,
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.only(left: margins, right: margins),
                    child: Column(
                      children: [
                        Stack(
                          alignment: AlignmentDirectional.bottomStart,
                          children: [
                            SizedBox(
                              height: totalSheetHeightDelta,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                      center: Alignment.bottomCenter,
                                      radius: 1,
                                      colors: <Color>[
                                    Colors.black,
                                    Colors.transparent
                                  ])),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: gutters,
                                    right: gutters,
                                    bottom: gutters,
                                    top: gutters * 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.article.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3
                                          .copyWith(
                                        color: Colors.white.withOpacity(.87),
                                        shadows: <Shadow>[
                                          Shadow(
                                            blurRadius: 3.0,
                                            color: Colors.black38,
                                          ),
                                          Shadow(
                                            blurRadius: 8.0,
                                            color: Colors.black38,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    if (widget.article.subtitle != null)
                                      Text(
                                        widget.article.subtitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(
                                          color: Colors.white.withOpacity(.54),
                                          shadows: <Shadow>[
                                            Shadow(
                                              blurRadius: 3.0,
                                              color: Colors.black38,
                                            ),
                                            Shadow(
                                              blurRadius: 8.0,
                                              color: Colors.black38,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(cardCornerRadius)),
                          child: Padding(
                            padding: EdgeInsets.all(gutters),
                            child: Column(children: children2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
