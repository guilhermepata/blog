// import 'dart:html';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'home_page.dart';

class Article {
  String _title, _subtitle, _rawContent, _imageUrl, _altText;
  String _content;
  String _asset;
  bool _isLoaded;

  BodyTextParser parser;

  String get title => _title;
  String get subtitle => _subtitle;
  String get rawContent => _rawContent;
  String get imageUrl => _imageUrl;
  String get altText => _altText;
  String get content => _content;
  bool get isLoaded => _isLoaded;

  Article._(
      {title, subtitle = '', rawContent, imageUrl = '', altText = '', asset}) {
    this._title = title;
    this._subtitle = subtitle;
    this._rawContent = rawContent;
    this._imageUrl = imageUrl;
    this._altText = altText;
    this._asset = asset;
  }

  // factory Article.fromMarkdown(String markdown) {
  //   String title, subtitle, rawContent, imageUrl, altText;

  //   // matches something like:
  //   // Title
  //   // ===
  //   // (the group is the title)
  //   RegExp titleExp = RegExp(r'(.+)\s*\n[=-]{3,}\s*\n*');
  //   // print(markdown);
  //   var matches = titleExp.allMatches(markdown);
  //   assert(matches.length > 0, 'The article must have a title');
  //   title = matches.first.group(1);
  //   if (matches.length > 1) subtitle = matches.elementAt(1).group(1);

  //   // matches something like:
  //   // ![alt text](url)
  //   // (the first group is the alt text and the second is the url)
  //   RegExp imageExp = RegExp(r'!\[(.+)\]\((.+)\)');
  //   matches = imageExp.allMatches(markdown);
  //   if (matches.length > 0) {
  //     altText = matches.first.group(1);
  //     imageUrl = matches.first.group(2);
  //   }

  //   rawContent = markdown;
  //   rawContent = rawContent.replaceFirst(titleExp, '');
  //   rawContent = rawContent.replaceFirst(titleExp, '');
  //   rawContent = rawContent.replaceFirst(imageExp, '');

  //   var result = Article._(
  //       title: title,
  //       subtitle: subtitle,
  //       rawContent: rawContent,
  //       imageUrl: imageUrl,
  //       altText: altText);

  //   result._isLoaded = true;

  //   // result.cleanContent();

  //   return result;
  // }

  static Future<Article> fromAsset(String asset) async {
    var result = Article._(asset: asset);
    result._isLoaded = false;
    var markdown = await rootBundle.loadString(asset);

    // matches something like:
    // Title
    // ===
    // (the group is the title)
    var titleExp = RegExp(r'(.+)\s*\n[=-]{3,}\s*\n*');
    var matches = titleExp.allMatches(markdown);
    assert(matches.length > 0, 'The article must have a title');
    String title = matches.first.group(1);
    result._title = title;

    return result;
  }

  Future load() async {
    if (isLoaded) return;
    if (_asset != null) {
      var markdown = await rootBundle.loadString(_asset);
      String subtitle, rawContent, imageUrl, altText;

      // matches something like:
      // Title
      // ===
      // (the group is the title)
      RegExp titleExp = RegExp(r'(.+)\s*\n[=-]{3,}\s*\n*');
      // print(markdown);
      var matches = titleExp.allMatches(markdown);
      if (matches.length > 1) subtitle = matches.elementAt(1).group(1);

      // matches something like:
      // ![alt text](url)
      // (the first group is the alt text and the second is the url)
      RegExp imageExp = RegExp(r'!\[(.+)\]\((.+)\)');
      matches = imageExp.allMatches(markdown);
      if (matches.length > 0) {
        altText = matches.first.group(1);
        imageUrl = matches.first.group(2);
      }

      rawContent = markdown;
      rawContent = rawContent.replaceFirst(titleExp, '');
      rawContent = rawContent.replaceFirst(titleExp, '');
      rawContent = rawContent.replaceFirst(imageExp, '');

      _subtitle = subtitle;
      _rawContent = rawContent;
      _imageUrl = imageUrl;
      _altText = altText;

      cleanContent();

      parser = BodyTextParser(rawContent);
      // bool parsed = await parser.isParsed;

      _isLoaded = true;
    }
  }

  void cleanContent() {
    _content = _rawContent;

    RegExp asteriskItalic =
        RegExp(r'([^\n\*])[\*]{1}([^\n\*].+?[^\n\*])[\*]{1}([^\n\*])');
    RegExp underscoreItalic =
        RegExp(r'([^\n\_])[\_]{1}([^\n\_].+?[^\n\_])[\_]{1}([^\n\_])');
    RegExp asteriskBold =
        RegExp(r'([^\n\*])[\*]{2}([^\n\*].+?[^\n\*])[\*]{2}([^\n\*])');
    RegExp underscoreBold =
        RegExp(r'([^\n\_])[\_]{2}([^\n\_].+?[^\n\_])[\_]{2}([^\n\_])');

    _content = _content.replaceAllMapped(asteriskItalic,
        (match) => match.group(1) + match.group(2) + match.group(3));
    _content = _content.replaceAllMapped(asteriskBold,
        (match) => match.group(1) + match.group(2) + match.group(3));
    _content = _content.replaceAllMapped(underscoreItalic,
        (match) => match.group(1) + match.group(2) + match.group(3));
    _content = _content.replaceAllMapped(underscoreBold,
        (match) => match.group(1) + match.group(2) + match.group(3));
  }

  bool get isParsing {
    if (parser == null) parser = BodyTextParser(rawContent);
    return parser.isParsing;
  }

  int get numParagraphs {
    if (parser == null) parser = BodyTextParser(rawContent);
    return isParsing ? parser.contentParts.length : parser.paragraphs.length;
  }

  Widget buildParagraph(BuildContext context, int index,
      {double paragraphSpacing = 16,
      TextStyle style,
      TextStyle headlineStyle,
      TextStyle quoteStyle,
      TextAlign textAlign = TextAlign.justify,
      TextOverflow overflow,
      int maxLines}) {
    if (parser == null) parser = BodyTextParser(rawContent);

    final builder = BodyTextBuilder(
        parser: parser,
        paragraphSpacing: paragraphSpacing,
        normalStyle: style,
        headlineStyle: headlineStyle,
        quoteStyle: quoteStyle,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines);

    return builder.buildParagraph(context, index);
  }

  List<Widget> buildContents(BuildContext context,
      {double paragraphSpacing = 16,
      TextStyle style,
      TextStyle headlineStyle,
      TextStyle quoteStyle,
      TextAlign textAlign = TextAlign.justify,
      TextOverflow overflow,
      int maxLines}) {
    if (parser == null) parser = BodyTextParser(rawContent);

    final builder = BodyTextBuilder(
        parser: parser,
        paragraphSpacing: paragraphSpacing,
        normalStyle: style,
        headlineStyle: headlineStyle,
        quoteStyle: quoteStyle,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines);

    return builder.buildWidgets(context);
  }
}

/// An object that contains a string where each character is associated with a
/// [Format].
///
/// A [FormattedString] will change the input string to remove any markdown
/// format indicators (asterisks and underscores) and format the characters
/// appropriately.
///
/// This class can be converted into a list of [SingleFormatString].
class FormattedString {
  String _string;
  final List<Format> _characterFormats = <Format>[];

  /// Final string.
  String get string => _string;

  /// List of [Format] objects where the format at index i corresponds to the
  /// format of the character at index i in the final string.
  List<Format> get characterFormats => _characterFormats;

  /// List of indices of characters whose [Format] is [Format.boldItalic].
  List<int> get boldItalicLCharacters {
    var result = <int>[];
    for (var i = 0; i < _characterFormats.length; i++) {
      if (_characterFormats[i] == Format.boldItalic) {
        result.add(i);
      }
    }
    return result;
  }

  /// List of indices of characters whose [Format] is [Format.bold].
  List<int> get boldCharacters {
    var result = <int>[];
    for (var i = 0; i < _characterFormats.length; i++) {
      if (_characterFormats[i] == Format.bold) {
        result.add(i);
      }
    }
    return result;
  }

  /// List of indices of characters whose [Format] is [Format.italic].
  List<int> get italicCharacters {
    var result = <int>[];
    for (var i = 0; i < _characterFormats.length; i++) {
      if (_characterFormats[i] == Format.italic) {
        result.add(i);
      }
    }
    return result;
  }

  /// List of indices of characters whose [Format] is [Format.normal].
  List<int> get normalCharacters {
    var result = <int>[];
    for (var i = 0; i < _characterFormats.length; i++) {
      if (_characterFormats[i] == Format.normal) {
        result.add(i);
      }
    }
    return result;
  }

  /// Creates a [FormattedString].
  ///
  /// Markdown format indicators (asterisks and underscores) will be removed
  /// from the input string and each character in the final string will be given
  /// the appropriate format.
  FormattedString(String inputString) : this._string = inputString {
    for (var i = 0; i < _string.length; i++) {
      _characterFormats.add(Format.normal);
    }

    RegExp asteriskItalic = RegExp(r'[\*]{1}([^\n\*].+?[^\n\*])[\*]{1}');
    RegExp underscoreItalic = RegExp(r'[\_]{1}([^\n\_].+?[^\n\_])[\_]{1}');

    formatLetters(asteriskItalic, '*', Format.italic);
    formatLetters(underscoreItalic, '_', Format.italic);

    RegExp asteriskBold = RegExp(r'[\*]{2}([^\n\*].+?[^\n\*])[\*]{2}');
    RegExp underscoreBold = RegExp(r'[\_]{2}([^\n\_].+?[^\n\_])[\_]{2}');

    formatLetters(asteriskBold, '*', Format.bold);
    formatLetters(underscoreBold, '_', Format.bold);
  }

  void formatLetters(RegExp exp, String symbol, format) {
    final numSymbols = format == Format.italic ? 1 : 2;
    var matches = exp.allMatches(_string).toList();
    final rejectedMatches = <RegExpMatch>[];

    var i = 0;
    while (i < matches.length) {
      if (numSymbols == 2 ||
          (numSymbols == 1 &&
              (matches[i].start == 0 ||
                  _string.substring(matches[i].start - 1, matches[i].start) !=
                      symbol))) {
        for (var j = matches[i].start + numSymbols;
            j < matches[i].end - numSymbols;
            j++) {
          if (_characterFormats[j] == Format.italic && format == Format.bold ||
              _characterFormats[j] == Format.bold && format == Format.italic) {
            _characterFormats[j] = Format.boldItalic;
          } else {
            _characterFormats[j] = format;
          }
        }
        i++;
      } else {
        rejectedMatches.add(matches[i]);
        matches.removeAt(i);
      }
    }

    final m = 0;
    while (matches.length > 0) {
      var length = matches[m].group(1).length;

      for (var k = 0; k < numSymbols; k++) {
        _characterFormats.removeAt(matches[m].start);
        _string =
            _string.replaceRange(matches[m].start, matches[m].start + 1, '');
      }

      for (var k = 0; k < numSymbols; k++) {
        _characterFormats.removeAt(matches[m].start + length);
        _string = _string.replaceRange(
            matches[m].start + length, matches[m].start + 1 + length, '');
      }
      matches = exp.allMatches(_string).toList();
      for (var rejectedMatch in rejectedMatches) {
        matches.remove(rejectedMatch);
      }
    }
  }

  /// Returns a list of [SingleFormatString] objects, where each object
  /// corresponds to intervals of characters with the same [Format] in the
  /// [FormattedString].
  List<SingleFormatString> toSingleFormatStrings() {
    var normalIntervals = makeIntervals(normalCharacters);
    var italicIntervals = makeIntervals(italicCharacters);
    var boldIntervals = makeIntervals(boldCharacters);
    var boldItalicIntervals = makeIntervals(boldItalicLCharacters);

    var result = <SingleFormatString>[];

    var currentIndex = 0;

    while (normalIntervals.length +
            italicIntervals.length +
            boldIntervals.length +
            boldItalicIntervals.length >
        0) {
      if (normalIntervals.isNotEmpty &&
          normalIntervals.first.first == currentIndex) {
        result.add(SingleFormatString(
            _string.substring(currentIndex, normalIntervals.first.last),
            format: Format.normal));
        currentIndex = normalIntervals.first.last;
        normalIntervals.removeAt(0);
      } else if (italicIntervals.isNotEmpty &&
          italicIntervals.first.first == currentIndex) {
        result.add(SingleFormatString(
            _string.substring(currentIndex, italicIntervals.first.last),
            format: Format.italic));
        currentIndex = italicIntervals.first.last;
        italicIntervals.removeAt(0);
      } else if (boldIntervals.isNotEmpty &&
          boldIntervals.first.first == currentIndex) {
        result.add(SingleFormatString(
            _string.substring(currentIndex, boldIntervals.first.last),
            format: Format.bold));
        currentIndex = boldIntervals.first.last;
        boldIntervals.removeAt(0);
      } else if (boldItalicIntervals.isNotEmpty &&
          boldItalicIntervals.first.first == currentIndex) {
        result.add(SingleFormatString(
            _string.substring(currentIndex, boldItalicIntervals.first.last),
            format: Format.boldItalic));
        currentIndex = boldItalicIntervals.first.last;
        boldItalicIntervals.removeAt(0);
      }
    }
    return result;
  }

  /// Returns a list of intervals from a list of indices
  ///
  /// First element is start of interval (i.e., inclusive)
  /// Second element is end of interval + 1 (i.e., exclusive)
  static List<List<int>> makeIntervals(List<int> indices) {
    var pairs = <List<int>>[];
    var prevIndex = -2;
    var currIndex;
    for (var i = 0; i < indices.length; i++) {
      currIndex = indices[i];
      if (currIndex - prevIndex == 1) {
        pairs.last.last++;
      } else {
        pairs.add([currIndex, currIndex + 1]);
      }
      prevIndex = currIndex;
    }
    return pairs;
  }
}

/// An object that contains a [String] associated with a [Format] and a
/// [TypeStyle]. If [TypeStyle] is [TypeStyle.link], it will also include the
/// link's URL.
class SingleFormatString {
  final String string;
  Format format;
  TypeStyle style;
  String _url;

  /// Creates a [SingleFormatString]
  SingleFormatString(this.string,
      {this.format = Format.normal, this.style = TypeStyle.body, String url})
      : this._url = url {
    if (url != null) style = TypeStyle.link;
  }

  String get url => _url;

  set url(String value) {
    this._url = value;
    if (value != null) style = TypeStyle.link;
  }
}

enum Format { normal, italic, bold, boldItalic }

enum TypeStyle { body, headline, quote, link, reference }

class BodyTextParser {
  final String content;
  final List<List<SingleFormatString>> paragraphs = [];
  List<String> contentParts = [];

  bool isParsing = true;
  Future<bool> isParsed;

  BodyTextParser(this.content) {
    contentParts = content.split(RegExp(r'\n\s{1,}'));
    isParsed = parse();
  }

  Future<bool> parse() async {
    isParsing = true;
    for (var paragraph in contentParts) {
      var parsedParagraph = await compute(parseParagraph, paragraph);
      paragraphs.add(parsedParagraph);
    }
    isParsing = false;
    return true;
  }

  static List<String> splitString(Tuple2<String, Pattern> tuple) {
    return tuple.item1.split(tuple.item2);
  }

  static List<SingleFormatString> parseParagraph(String paragraph) {
    final segments = <SingleFormatString>[];
    RegExp imageExp = RegExp(r'!\[(.+)\]\((.+)\)');
    paragraph = paragraph.replaceAll(imageExp, '');
    if (paragraph.isEmpty) return segments;

    // replace all empty spaces
    final spaceMatches = RegExp(r'([\s]+)\n').allMatches(paragraph);
    for (var match in spaceMatches) {
      paragraph = paragraph.replaceRange(match.start, match.end, '\n');
    }

    var isQuote = false;

    if (paragraph.substring(0, 2) == '> ') {
      isQuote = true;
      paragraph = paragraph.replaceFirst('> ', '');
    }

    if (!isQuote) {
      final headlineExp = RegExp(r'#+ +(.+?\n)');
      final matches = headlineExp.allMatches(paragraph).toList();

      if (matches.length > 0 && matches.first.start == 0) {
        paragraph = paragraph.replaceFirst(matches.first.group(0), '');
        final headline = matches.first.group(1);
        final headlineSegments =
            FormattedString(headline).toSingleFormatStrings();
        for (var segment in headlineSegments)
          segment.style = TypeStyle.headline;
        segments.addAll(headlineSegments);
      }
    }

    segments.addAll(FormattedString(paragraph).toSingleFormatStrings());

    if (isQuote) {
      for (var segment in segments) segment.style = TypeStyle.quote;
    }

    var i = 0;
    while (i < segments.length) {
      var segment = segments[i];
      final linkExp = RegExp(r'\[(.+?)\]\((.+?)\)');
      var string = segment.string;
      var match = linkExp.firstMatch(string);

      if (match != null) {
        final firstText = string.substring(0, match.start);
        final lastText = string.substring(match.end);
        final linkLabel = match.group(1);
        final url = match.group(2);

        final firstSegment = SingleFormatString(firstText,
            style: segment.style, format: segment.format);
        final linkSegment =
            SingleFormatString(linkLabel, url: url, format: segment.format);
        final lastSegment = SingleFormatString(lastText,
            style: segment.style, format: segment.format);

        segments[i] = firstSegment;
        segments.insertAll(i + 1, [linkSegment, lastSegment]);
        i++;
      }
      i++;
    }

    return segments;

    // final segments = headlineSegments + FormattedString(paragraph).toSingleFormatStrings();
  }
}

class BodyTextBuilder {
  // final String content;
  final double paragraphSpacing;
  final TextStyle normalStyle;
  final TextStyle headlineStyle;
  final TextStyle quoteStyle;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int maxLines;

  // final List<List<SingleFormatString>> paragraphs = [];
  // List<String> contentParts;

  final BodyTextParser parser;

  BodyTextBuilder(
      {@required this.parser,
      this.paragraphSpacing = 16,
      this.normalStyle,
      this.headlineStyle,
      this.quoteStyle,
      this.textAlign = TextAlign.justify,
      this.overflow,
      this.maxLines});

  int get numParagraphs => parser.paragraphs.length;

  List<List<SingleFormatString>> get paragraphs => parser.paragraphs;

  Widget buildParagraph(BuildContext context, int index) {
    return FutureBuilder(
        future: parser.isParsed,
        builder: (context, snapshot) {
          Widget result;
          EdgeInsets padding;
          if (!parser.isParsing) {
            final effectiveNormalStyle = normalStyle ??
                Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(.6));
            final effectiveHeadlineStyle =
                headlineStyle ?? Theme.of(context).textTheme.headline6;
            final effectiveQuoteStyle = quoteStyle ??
                GoogleFonts.ibmPlexSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.onSurface);

            final colorLinkDecorationColor =
                Theme.of(context).colorScheme.secondary;

            final textSpan = toSpan(
              paragraphs[index],
              effectiveNormalStyle,
              effectiveHeadlineStyle,
              effectiveQuoteStyle,
              colorLinkDecorationColor,
              context,
            );

            final isQuote = paragraphs[index]
                .any((element) => element.style == TypeStyle.quote);
            final containsHeadline =
                paragraphs[index].first.style == TypeStyle.headline;

            padding = EdgeInsets.only(
                bottom: isQuote ? paragraphSpacing * 1.5 : paragraphSpacing,
                top: (containsHeadline || isQuote) && index != 0
                    ? paragraphSpacing * 0.5
                    : 0,
                left: isQuote ? 48 : 0,
                right: isQuote ? 48 : 0);

            result = Text.rich(
              textSpan,
              strutStyle: StrutStyle(
                height: effectiveNormalStyle.height,
                forceStrutHeight: true,
              ),
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow,
            );
          } else {
            padding = EdgeInsets.only(bottom: paragraphSpacing);
            result = Container();
          }
          return Padding(
            padding: padding,
            child:
                CrossFadeTextWidgetBlock(result, showText: !parser.isParsing),
          );
        });
  }

  List<Widget> buildWidgets(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < numParagraphs; i++)
      children.add(buildParagraph(context, i));
    return children;
  }

  static TextSpan toSpan(
    List<SingleFormatString> segments,
    TextStyle normalStyle,
    TextStyle headlineStyle,
    TextStyle quoteStyle,
    Color linkDecorationColor,
    BuildContext context,
  ) {
    TextStyle spanStyle = normalStyle;
    final isQuote = segments.any((element) => element.style == TypeStyle.quote);
    if (isQuote) spanStyle = quoteStyle;
    final containsHeadline = segments.first.style == TypeStyle.headline;

    final spans = <InlineSpan>[];
    for (var i = 0; i < segments.length; i++) {
      var segmentStyle = TextStyle();
      switch (segments[i].format) {
        case Format.italic:
          segmentStyle = TextStyle(fontStyle: FontStyle.italic);
          break;
        case Format.bold:
          segmentStyle = TextStyle(fontWeight: FontWeight.bold);
          break;
        case Format.boldItalic:
          segmentStyle = TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic);
          break;
        default:
          break;
      }
      switch (segments[i].style) {
        case TypeStyle.link:
          spans.add(LinkSpan(
              child: LinkTextWidget(segments[i].string,
                  style: normalStyle.merge(segmentStyle), onTap: () {
            return onLinkTapped(url: segments[i].url, context: context);
          })));
          break;
        case TypeStyle.headline:
          spans.add(TextSpan(
              text: segments[i].string,
              style: headlineStyle.merge(segmentStyle)));
          break;
        default:
          spans.add(TextSpan(text: segments[i].string, style: segmentStyle));
          break;
      }
    }
    return (TextSpan(children: spans, style: spanStyle));
  }

  static Future<bool> onLinkTapped(
      {@required BuildContext context, @required String url, String label}) {
    return showModalBottomSheet(
        context: context,
        isDismissible: true,
        barrierColor: Colors.black26,
        elevation: 0,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  boxShadow: kElevationToShadow[24],
                ),
                child: Card(
                  elevation: 24,
                  shadowColor: Colors.transparent,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('This link will take you to an external website.',
                            style: Theme.of(context).textTheme.subtitle1),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            url,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(.6),
                                    ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text('Cancel'),
                              ),
                            ),
                            SizedBox(width: 24),
                            Expanded(
                              child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                    if (UniversalPlatform.isAndroid)
                                      launchWebPage(context, url);
                                    else
                                      launch(url);
                                  },
                                  label: Text('Open website'),
                                  icon: Icon(Icons.launch, size: 18)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  static void launchWebPage(BuildContext context, String url) {
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        enableDrag: false,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 7 / 8,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Browser'),
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: PopupMenuButton(
                        onSelected: (MenuOptions result) {
                          if (result == MenuOptions.externalBroswer) {
                            launch(url);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<MenuOptions>>[
                          PopupMenuItem<MenuOptions>(
                            value: MenuOptions.externalBroswer,
                            child: Text('Open in external browser',
                                style: Theme.of(context).textTheme.bodyText2),
                          ),
                        ],
                      ))
                ],
              ),
              body: WebView(
                initialUrl: url,
              ),
            ),
          );
        });
  }

  Widget parseImage(String url, {String altText = ''}) {
    return Image.network(
      url,
    );
  }
}

enum MenuOptions { externalBroswer }

/// Creates a [Text] widget which can be tapped.
///
/// If you want to integrate it in a [Text.rich], remeber to set the
/// [StrutStyle] so that the line height stays fixed, since the underline
/// takes up some space.
class LinkTextWidget extends StatefulWidget {
  /// Defaults to the theme accent color.
  final Color decorationColor;

  /// Function to run when the text is tapped.
  /// Can trigger a navigator or hyperlink
  final Function() onTap;

  /// The string to display.
  final String text;

  /// The text style. This widget does not properly inherit the [TextStyle] of
  /// the parent [Text.rich] if placed inside a [WidgetSpan].
  final TextStyle style;

  /// The distance, in fraction of line height, at which the underline should be
  /// from the top of the text widget. If left null or unset, it will default to
  /// `0.95`. If its greater than `1` and `forceStrutHeight` is set to true in a
  /// parent [Text.rich]'s [StrutStyle], the underline will be clipped on the
  /// last line of a body of text.
  final double fraction;

  /// Thickness of the underline.
  final double thickness;

  const LinkTextWidget(this.text,
      {Key key,
      this.decorationColor,
      this.onTap,
      this.style,
      this.fraction = .95,
      this.thickness = 1})
      : super(key: key);

  @override
  _LinkTextWidgetState createState() => _LinkTextWidgetState();
}

class _LinkTextWidgetState extends State<LinkTextWidget> {
  bool wasHovering = false;
  Color decorationColor;
  double textOpacity;

  @override
  void initState() {
    super.initState();
    decorationColor =
        widget.style.color.withOpacity(widget.style.color.opacity * 0.8);
    textOpacity = widget.style.color.opacity;
  }

  void changeHighlight(bool isHighlighted) {
    setState(() {
      decorationColor = isHighlighted
          ? widget.decorationColor ?? Theme.of(context).colorScheme.secondary
          : widget.style.color.withOpacity(widget.style.color.opacity * 0.8);
      textOpacity = isHighlighted ? 1 : widget.style.color.opacity;
    });
  }

  void onFocusChange(bool isFocused) {
    changeHighlight(isFocused);
  }

  void onTap() {
    changeHighlight(true);

    if (widget.onTap is Future)
      widget.onTap().then((_) => changeHighlight(false));
    else {
      widget.onTap();
      changeHighlight(false);
    }
  }

  void onTapCancel() {
    changeHighlight(false);
  }

  void onTapDown(TapDownDetails details) {
    changeHighlight(true);
  }

  void onLongPress() {
    changeHighlight(true);
  }

  void onHover(bool isHovering) {
    if (wasHovering != isHovering) {
      {
        if (isHovering) {
          changeHighlight(true);
        } else {
          changeHighlight(false);
        }
      }
      wasHovering = isHovering;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          onTapCancel: onTapCancel,
          onTapDown: onTapDown,
          onFocusChange: onFocusChange,
          onHover: onHover,
          child: AnimatedOpacity(
            opacity: textOpacity,
            duration: Duration(milliseconds: 100),
            child: Text(
              widget.text,
              style: widget.style.copyWith(
                color: widget.style.color.withOpacity(1),
              ),
              maxLines: 1,
            ),
          ),
        ),
        Positioned(
            top: widget.style.height * widget.style.fontSize * widget.fraction,
            child: AnimatedContainer(
              height: 0,
              clipBehavior: Clip.hardEdge,
              duration: Duration(milliseconds: 50),
              padding: EdgeInsets.only(bottom: 0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: decorationColor, // Text color here
                    width: widget.thickness, // Underline width
                  ),
                ),
              ),
              child: Text(
                widget.text,
                style: widget.style,
                maxLines: 1,
              ),
            )),
      ],
    );
  }
}

class LinkSpan extends WidgetSpan {
  final Widget child;
  LinkSpan({this.child})
      : super(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: child);
}
