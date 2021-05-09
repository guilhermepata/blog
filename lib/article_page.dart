import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
// import 'package:icon_shadow/icon_shadow.dart';
import 'package:provider/provider.dart';
import 'package:the_duckling/home_page.dart';
// import 'package:visibility_detector/visibility_detector.dart';
import 'classes.dart';
import 'widgets.dart';
import 'app_shell.dart';
import 'app_state.dart';

class ImagePositionNotifier extends ValueNotifier {
  ImagePositionNotifier(value) : super(value);
}

class ArticlePage extends StatefulWidget {
  final Article /*!*/ article;

  const ArticlePage({Key? key, required this.article}) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage>
    with SingleTickerProviderStateMixin {
  late double width, height, usefulWidth, usefulHeight, gutters;

  late double appBarMargins;
  final double maxContentWidth = 720;
  late double contentWidth;
  late double webLayoutMinWidth;
  late double cardCornerRadius;
  late double initialSheetHeight;
  late double maxSheetHeight;
  late double totalSheetHeightDelta;

  ValueNotifier pastTitleNotifier = ValueNotifier(false);

  // double imageScrollPosition = 0.0;

  ImagePositionNotifier imagePositionNotifier = ImagePositionNotifier(0.0);

  bool isInitialized = false;
  late bool isMobileLayout;

  ScrollController scrollController = ScrollController();
  // ScrollController imageScrollController = ScrollController();

  bool get displayMobileLayout {
    return isMobileLayout;
  }

  @override
  void initState() {
    // VisibilityDetectorController.instance.updateInterval = Duration.zero;

    MouseState().addListener(() {
      setState(() {});
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels > 0) {
        pastTitleNotifier.value = true;
      } else if (scrollController.position.pixels <= 0) {
        pastTitleNotifier.value = false;
      }
      // if (scrollController.offset < height * 4) {
      //   imageScrollController.jumpTo(scrollController.offset / 4);
      // }
    });

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();

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

      if (width < maxContentWidth) {
        gutters = 24;
        appBarMargins = 0;
      } else {
        gutters = 48;
        appBarMargins = 24;
      }

      webLayoutMinWidth = maxContentWidth + gutters * 2;

      isMobileLayout = width < 1023;

      if (!isMobileLayout && width < webLayoutMinWidth) isMobileLayout = true;

      if (usefulWidth < maxContentWidth)
        cardCornerRadius = 0;
      else
        cardCornerRadius = 0;

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
                elevation: 0,
                leadingWidth: 56 + appBarMargins,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                centerTitle: true,
                title: AppTitle(),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: Center(child: CircularProgressIndicator()));
        else
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: ArticlePageAppBar(
                title: widget.article.title,
                appBarMargins: appBarMargins,
                pastTitleNotifier: pastTitleNotifier,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: NotificationListener(
              onNotification: (dynamic notification) {
                if (notification is ScrollUpdateNotification) {
                  imagePositionNotifier.value +=
                      notification.scrollDelta! / 3 * 2;
                  return true;
                }
                return false;
              },
              child: Scrollbar(
                isAlwaysShown: MouseState.isPresent,
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  // itemCount: 7,
                  physics: MouseState.isPresent
                      ? null //NeverScrollableScrollPhysics()
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < 7; i++) buildContentCard(context, i)
                    ],
                  ),
                ),
              ),
            ),
          );
      },
    );
  }

  Widget buildTitle() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 48),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: gutters),
              child: Padding(
                padding: EdgeInsets.only(top: gutters),
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.article.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 50000,
                      style: Theme.of(context).textTheme.headline1!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(.87),
                            // fontWeight: FontWeight.w100,
                            fontStyle: FontStyle.italic,
                            fontSize: width < maxContentWidth ? 33 : 46,
                          ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    if (widget.article.subtitle != null)
                      Text(
                        widget.article.subtitle!,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        maxLines: 5000,
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: width < maxContentWidth ? 18 : 19,
                              height: 1.3,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(.86),
                            ),
                      ),
                  ],
                ),
              ),
            ),
            Divider(height: 36, indent: gutters, endIndent: gutters),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ButtonBar(
                buttonPadding: EdgeInsets.zero,
                alignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                    message: 'Share',
                    child: TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: Uri.base.toString()));
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
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContentCard(BuildContext context, int index) {
    Widget result;
    if (index == 0)
      result = Stack(
        children: [
          Opacity(
            opacity: 0,
            child: buildTitle(),
          ),
          ChangeNotifierProvider.value(
            value: imagePositionNotifier,
            // builder: (context, child) => Positioned(child: child!),
            child: Consumer<ImagePositionNotifier>(
              builder: (context, position, child) => Positioned(
                top: position.value,
                // height: 300,
                width: width > maxContentWidth ? maxContentWidth : width,
                child: Opacity(
                  opacity: (1.0 - position.value / 200).clamp(0.0, 1.0),
                  child: buildTitle(),
                ),
              ),
            ),
          ),
        ],
      );
    else if (index == 1)
      result = SizedBox(height: 0);
    else if (index == 2)
      result = SizedBox(height: 0);
    else if (index == 4)
      result = Padding(
        padding: EdgeInsets.symmetric(horizontal: gutters),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: widget.article.buildInitialContent(
            context,
            // index - 3,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 17.5,
                  height: 1.5,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(.87),
                ),
            headlineStyle: GoogleFonts.lora(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(.87),
              fontSize: 19,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
            ),
            quoteStyle: GoogleFonts.ibmPlexSerif(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.left,
            overflow: TextOverflow.visible,
          ),
        ),
      );
    else if (index == 3)
      result = Padding(
        padding: EdgeInsets.only(top: 0, bottom: 32),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Material(
            elevation: 2,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Skeleton(
                    height: maxContentWidth * 1.3 * 9 / 16,
                    width: maxContentWidth * 1.3,
                  ),
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: maxContentWidth * 1.3),
                    child: Image.network(
                      widget.article.imageUrl!,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      semanticLabel: widget.article.altText,
                      frameBuilder: (BuildContext context, Widget child,
                          int? frame, bool wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) {
                          return child;
                        }
                        return AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeIn,
                          child: child,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    else if (index == 5)
      result = Padding(
        padding: EdgeInsets.symmetric(horizontal: gutters),
        child: widget.article.buildOtherContent(
          context,
          // index - 3,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 19,
                height: 1.75,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.87),
              ),
          headlineStyle: GoogleFonts.lora(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.87),
            fontSize: 19,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
          quoteStyle: GoogleFonts.ibmPlexSerif(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.left,
          overflow: TextOverflow.visible,
        ),
      );
    else if (index == 6)
      result = SizedBox(height: gutters);
    else
      result = SizedBox(height: 0);
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: index != 3 ? maxContentWidth : maxContentWidth * 1.3,
        ),
        child: result,
      ),
    );
  }
}

class ArticlePageAppBar extends StatefulWidget {
  const ArticlePageAppBar({
    Key? key,
    required this.title,
    required this.appBarMargins,
    required this.pastTitleNotifier,
  }) : super(key: key);

  final String title;
  final double appBarMargins;
  final ValueNotifier pastTitleNotifier;

  @override
  _ArticlePageAppBarState createState() => _ArticlePageAppBarState();
}

class _ArticlePageAppBarState extends State<ArticlePageAppBar>
    with SingleTickerProviderStateMixin {
  bool isAppBarElevated = false;
  late AnimationController appBarStateController;
  late Animation<Color?> appBarColor;
  late Animation<Color?> appBarForegroundColor;
  AppBarState appBarState = AppBarState.lowered;

  @override
  void initState() {
    widget.pastTitleNotifier.addListener(() {
      if (widget.pastTitleNotifier.value == true &&
          appBarState != AppBarState.raised &&
          appBarState != AppBarState.raising) {
        appBarStateController.fling(velocity: 10);
      } else if (widget.pastTitleNotifier.value == false &&
          appBarState != AppBarState.lowered &&
          appBarState != AppBarState.lowering) {
        appBarStateController.fling(velocity: -10);
      }
    });

    appBarStateController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    appBarStateController.addStatusListener((status) {
      if (status == AnimationStatus.completed)
        setState(() {
          appBarState = AppBarState.raised;
          isAppBarElevated = true;
        });
      else if (status == AnimationStatus.dismissed)
        setState(() {
          appBarState = AppBarState.lowered;
          isAppBarElevated = false;
        });
      else if (status == AnimationStatus.forward)
        setState(() {
          appBarState = AppBarState.raising;
        });
      else if (status == AnimationStatus.reverse)
        setState(() {
          appBarState = AppBarState.lowering;
        });
    });
    appBarStateController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appBarColor = ColorTween(
            begin: Theme.of(context).colorScheme.surface,
            end: Color.alphaBlend(Colors.white.withOpacity(.09),
                Theme.of(context).colorScheme.surface))
        .animate(appBarStateController);
    appBarColor.addListener(() {
      setState(() {});
    });
    appBarForegroundColor = ColorTween(
            begin: Theme.of(context).appBarTheme.foregroundColor,
            end: Theme.of(context).appBarTheme.foregroundColor)
        .animate(appBarStateController);
    appBarForegroundColor.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    appBarStateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: Colors.black.withOpacity(appBarStateController.value),
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        color: appBarColor.value,
      ),
      backwardsCompatibility: false,
      systemOverlayStyle: isAppBarElevated
          ? Theme.of(context).brightness == Brightness.light
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.light,
      foregroundColor: appBarForegroundColor.value,
      leadingWidth: 56 + widget.appBarMargins,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: appBarForegroundColor.value,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      centerTitle: true,
      title: AppTitle(),
      // Text(
      //   'Essay: ' + widget.title,
      //   overflow: TextOverflow.ellipsis,
      //   style: Theme.of(context).textTheme.headline6!.copyWith(
      //         color: Theme.of(context)
      //             .colorScheme
      //             .onSurface
      //             .withOpacity(appBarStateController.value * .87),
      //       ),
      // ),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
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
          ),
        )
      ],
    );
  }
}
