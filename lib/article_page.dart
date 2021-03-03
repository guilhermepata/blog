import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:provider/provider.dart';
// import 'package:visibility_detector/visibility_detector.dart';
import 'classes.dart';
import 'widgets.dart';
import 'app_shell.dart';
import 'app_state.dart';

class ImagePositionNotifier extends ValueNotifier {
  ImagePositionNotifier(value) : super(value);
}

class ArticlePage extends StatefulWidget {
  final Article article;

  const ArticlePage({Key key, this.article}) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage>
    with SingleTickerProviderStateMixin {
  double width, height, usefulWidth, usefulHeight, gutters;

  double appBarMargins;
  double maxContentWidth = 600;
  double contentWidth;
  double webLayoutMinWidth;
  double cardCornerRadius;
  double initialSheetHeight;
  double maxSheetHeight;
  double totalSheetHeightDelta;

  // double imageScrollPosition = 0.0;

  ImagePositionNotifier imagePositionNotifier = ImagePositionNotifier(0.0);

  bool isInitialized = false;
  bool isMobileLayout;
  bool isAppBarElevated = false;

  ScrollController scrollController = ScrollController();
  AnimationController appBarStateController;
  Animation<Color> appBarColor;
  Animation<Color> appBarForegroundColor;

  bool get displayMobileLayout {
    return isMobileLayout;
  }

  @override
  void initState() {
    // VisibilityDetectorController.instance.updateInterval = Duration.zero;

    scrollController.addListener(() {
      if (scrollController.position.pixels > height / 3) {
        appBarStateController.fling();
      } else {
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

    MouseState().addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appBarColor = ColorTween(
            begin: Colors.transparent,
            end: Color.alphaBlend(Colors.white.withOpacity(.09),
                Theme.of(context).colorScheme.surface))
        .animate(appBarStateController);
    appBarColor.addListener(() {
      setState(() {});
    });
    appBarForegroundColor = ColorTween(
            begin: Colors.white,
            end: Theme.of(context).appBarTheme.foregroundColor)
        .animate(appBarStateController);
    appBarForegroundColor.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    appBarStateController.dispose();
    MouseState().removeListener(() {
      setState(() {});
    });
    super.dispose();
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

      isMobileLayout = width < 1023;

      if (!isMobileLayout && width < webLayoutMinWidth) isMobileLayout = true;

      if (usefulWidth < maxContentWidth)
        cardCornerRadius = 0;
      else
        cardCornerRadius = gutters / 4;

      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    buildState(context);

    return FutureBuilder(
        future: widget.article.load(),
        builder: (context, snapshot) {
          if (!widget.article.isLoaded)
            return Scaffold(
                appBar: AppBar(
                  // THIS IS THE LOADING ONE
                  brightness: isAppBarElevated
                      ? Theme.of(context).brightness == Brightness.light
                          ? Brightness.light
                          : Brightness.dark
                      : Brightness.dark,
                  systemOverlayStyle: isAppBarElevated
                      ? Theme.of(context).brightness == Brightness.light
                          ? SystemUiOverlayStyle.dark
                          : SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.light,
                  shadowColor: Colors.black.withOpacity(
                      appBarStateController.value *
                          appBarStateController.value),
                  backgroundColor: appBarColor.value,
                  backwardsCompatibility: false,
                  leadingWidth: 56 + appBarMargins,
                  leading: IconButton(
                    icon: IconShadowWidget(
                      Icon(Icons.arrow_back),
                      showShadow: false,
                      shadowColor: Colors.black,
                    ),
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
                body: Center(child: CircularProgressIndicator()));
          else
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                shadowColor: Colors.black.withOpacity(
                    appBarStateController.value * appBarStateController.value),
                backgroundColor: appBarColor.value,
                backwardsCompatibility: false,
                systemOverlayStyle: isAppBarElevated
                    ? Theme.of(context).brightness == Brightness.light
                        ? SystemUiOverlayStyle.dark
                        : SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.light,
                foregroundColor: appBarForegroundColor.value,
                leadingWidth: 56 + appBarMargins,
                leading: IconButton(
                  icon: IconShadowWidget(
                    Icon(Icons.arrow_back, color: appBarForegroundColor.value),
                    showShadow: appBarStateController.isDismissed,
                    shadowColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  'Essay: ' + widget.article.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(appBarStateController.value * .87),
                      ),
                ),
                actions: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: PopupMenuButton<AppBarMenuOptions>(
                        onSelected: (AppBarMenuOptions result) {
                          if (result == AppBarMenuOptions.changeTheme) {
                            context.read<AppState>().flipTheme();
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<AppBarMenuOptions>>[
                          PopupMenuItem<AppBarMenuOptions>(
                            value: AppBarMenuOptions.changeTheme,
                            child: ListTile(
                              dense: true,
                              // visualDensity:
                              //     VisualDensity(horizontal: -4, vertical: -4),
                              minLeadingWidth: 18,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 0),
                              horizontalTitleGap: 8,
                              leading: Icon(
                                Theme.of(context).brightness == Brightness.dark
                                    ? Icons.brightness_7
                                    : Icons.brightness_4,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.87),
                              ),
                              title: Text(
                                'Change theme',
                                // style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ),
                          ),
                        ],
                      ))
                ],
              ),
              body: NotificationListener(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification)
                    imagePositionNotifier.value -= notification.scrollDelta / 4;
                },
                child: Stack(
                  children: [
                    ChangeNotifierProvider.value(
                      value: imagePositionNotifier,
                      child: Consumer<ImagePositionNotifier>(
                        builder: (context, imageScrollPosition, child) =>
                            Positioned(
                          top: imageScrollPosition.value,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: usefulWidth,
                                minWidth: usefulWidth,
                                minHeight: height * 1 / 3,
                                maxHeight: height),
                            child: child,
                          ),
                        ),
                        child: Material(
                          elevation: 4,
                          child: Image.network(
                            widget.article.imageUrl,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            semanticLabel: widget.article.altText,
                            frameBuilder: (BuildContext context, Widget child,
                                int frame, bool wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded ?? false) {
                                return child;
                              }
                              return AnimatedOpacity(
                                child: child,
                                opacity: frame == null ? 0 : 1,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeIn,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Scrollbar(
                      isAlwaysShown: MouseState.isPresent,
                      controller: scrollController,
                      child: SmoothScroller(
                        controller: scrollController,
                        child: ListView(
                          controller: scrollController,
                          physics: MouseState.isPresent
                              ? NeverScrollableScrollPhysics()
                              : null,
                          children: [
                            SizedBox(
                              height: height / 3 - 56,
                            ),
                            Center(
                              child: Container(
                                constraints:
                                    BoxConstraints(maxWidth: maxContentWidth),
                                child: Card(
                                  margin: EdgeInsets.only(bottom: gutters),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          cardCornerRadius)),
                                  child: CustomScrollView(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    // controller: scrollController,
                                    slivers: [
                                      SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          buildContentCard,
                                          childCount:
                                              3 + widget.article.numParagraphs,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
        });
  }

  Widget buildContentCard(BuildContext context, int index) {
    Widget result;
    if (index == 0)
      result = Padding(
        padding: EdgeInsets.symmetric(horizontal: gutters),
        child: Padding(
          padding: EdgeInsets.only(top: gutters),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AutoSizeText(
                  widget.article.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines:
                      (widget.article.title.split(RegExp(r'[ ]')).length / 4)
                          .ceil(),
                  presetFontSizes: [93, 58, 46, 33],
                  style: Theme.of(context).textTheme.headline1.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(.87),
                      ),
                ),
                SizedBox(
                  height: 8,
                ),
                if (widget.article.subtitle != null)
                  AutoSizeText(
                    widget.article.subtitle,
                    overflow: TextOverflow.ellipsis,
                    presetFontSizes: [19, 18, 14],
                    minFontSize: 18,
                    maxLines:
                        (widget.article.subtitle.split(RegExp(r'[ ]')).length /
                                9)
                            .ceil(),
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(.6),
                        ),
                  ),
              ]),
        ),
      );
    else if (index == 1)
      return Divider(height: 36, indent: 24, endIndent: 24);
    else if (index == 2)
      result = Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ButtonBar(
          buttonPadding: EdgeInsets.zero,
          alignment: MainAxisAlignment.center,
          children: [
            Tooltip(
              message: 'Share',
              child: TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: Uri.base.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        width: width < maxContentWidth
                            ? width - 32
                            : maxContentWidth - 32,
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'URL copied to clipboard. Share it an app!',
                        ),
                      ),
                    );
                  },
                  label: Text('Share'),
                  icon: Icon(
                    Icons.share,
                    size: 18,
                  )),
            )
          ],
        ),
      );
    else if (index > 2)
      result = Padding(
        padding: EdgeInsets.symmetric(horizontal: gutters),
        child: widget.article.buildParagraph(
          context,
          index - 3,
          style: Theme.of(context).textTheme.bodyText1.copyWith(
              fontSize: 16,
              height: 2,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(.7)),
          textAlign: TextAlign.left,
          overflow: TextOverflow.visible,
        ),
      );
    else
      result = SizedBox(height: 0);
    return result;
  }
}
