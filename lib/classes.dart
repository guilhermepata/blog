import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Article {
  String _title, _subtitle, _rawContent, _imageUrl, _altText;
  String _content;
  String _asset;
  bool _isLoaded;

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

  factory Article.fromMarkdown(String markdown) {
    String title, subtitle, rawContent, imageUrl, altText;

    // matches something like:
    // Title
    // ===
    // (the group is the title)
    RegExp titleExp = RegExp(r'(.+)\s*\n[=-]{3,}\s*\n*');
    // print(markdown);
    var matches = titleExp.allMatches(markdown);
    assert(matches.length > 0, 'The article must have a title');
    title = matches.first.group(1);
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

    var result = Article._(
        title: title,
        subtitle: subtitle,
        rawContent: rawContent,
        imageUrl: imageUrl,
        altText: altText);

    result._isLoaded = true;

    result.cleanContent();

    return result;
  }

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

      _isLoaded = true;
    }
  }

  // Future<bool> get isLoaded async {
  //   await load();
  //   return true;
  // }

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

  List<Widget> buildParagraphs(BuildContext context,
      {paragraphSpacing = 16, style, textAlign = TextAlign.justify, overflow}) {
    var builder = ArticleBuilder(
        content: rawContent,
        paragraphSpacing: paragraphSpacing,
        style: style,
        textAlign: textAlign,
        overflow: overflow);
    return builder.buildWidgets(context);
  }
}

class FormatedString {
  String string;
  final List<Format> letterFormats = <Format>[];

  List<int> get boldItalicLetters {
    var result = <int>[];
    for (var i = 0; i < letterFormats.length; i++) {
      if (letterFormats[i] == Format.boldItalic) {
        result.add(i);
      }
    }
    return result;
  }

  List<int> get boldLetters {
    var result = <int>[];
    for (var i = 0; i < letterFormats.length; i++) {
      if (letterFormats[i] == Format.bold) {
        result.add(i);
      }
    }
    return result;
  }

  List<int> get italicLetters {
    var result = <int>[];
    for (var i = 0; i < letterFormats.length; i++) {
      if (letterFormats[i] == Format.italic) {
        result.add(i);
      }
    }
    return result;
  }

  List<int> get normalLetters {
    var result = <int>[];
    for (var i = 0; i < letterFormats.length; i++) {
      if (letterFormats[i] == Format.normal) {
        result.add(i);
      }
    }
    return result;
  }

  FormatedString(this.string) {
    for (var i = 0; i < string.length; i++) {
      letterFormats.add(Format.normal);
    }

    RegExp asteriskItalic =
        RegExp(r'([^\n\*])[\*]{1}([^\n\*].+?[^\n\*])[\*]{1}([^\n\*])');
    RegExp underscoreItalic =
        RegExp(r'([^\n\_])[\_]{1}([^\n\_].+?[^\n\_])[\_]{1}([^\n\_])');

    formatLetters(asteriskItalic, Format.italic);
    formatLetters(underscoreItalic, Format.italic);

    RegExp asteriskBold =
        RegExp(r'([^\n\*])[\*]{2}([^\n\*].+?[^\n\*])[\*]{2}([^\n\*])');
    RegExp underscoreBold =
        RegExp(r'([^\n\_])[\_]{2}([^\n\_].+?[^\n\_])[\_]{2}([^\n\_])');

    formatLetters(asteriskBold, Format.bold);
    formatLetters(underscoreBold, Format.bold);
  }

  void formatLetters(RegExp exp, format) {
    var numSymbols = format == Format.italic ? 1 : 2;
    var matches = exp.allMatches(string).toList();

    for (var i = 0; i < matches.length; i++) {
      for (var j = matches[i].start + 1 + numSymbols;
          j < matches[i].end - 1 - numSymbols;
          j++) {
        if (letterFormats[j] == Format.italic && format == Format.bold ||
            letterFormats[j] == Format.bold && format == Format.italic) {
          letterFormats[j] = Format.boldItalic;
        } else {
          letterFormats[j] = format;
        }
      }

      var length = matches[i].group(2).length;

      // var j = matches[i].start + 1;
      // letterFormats.removeAt(j);
      // string = string.replaceRange(j, j + 1, '');

      for (var k = 0; k < numSymbols; k++) {
        letterFormats.removeAt(matches[i].start + 1);
        string =
            string.replaceRange(matches[i].start + 1, matches[i].start + 2, '');
      }

      for (var k = 0; k < numSymbols; k++) {
        letterFormats.removeAt(matches[i].start + 1 + length);
        string = string.replaceRange(
            matches[i].start + 1 + length, matches[i].start + 2 + length, '');
      }
    }
  }

  List<TextSegment> toTextSegments() {
    var normalIntervals = makeIntervals(normalLetters);
    var italicIntervals = makeIntervals(italicLetters);
    var boldIntervals = makeIntervals(boldLetters);
    var boldItalicIntervals = makeIntervals(boldItalicLetters);

    var result = <TextSegment>[];

    var currentIndex = 0;

    while (normalIntervals.length +
            italicIntervals.length +
            boldIntervals.length +
            boldItalicIntervals.length >
        0) {
      if (normalIntervals.isNotEmpty &&
          normalIntervals.first.first == currentIndex) {
        result.add(TextSegment(
            string.substring(currentIndex, normalIntervals.first.last),
            format: Format.normal));
        currentIndex = normalIntervals.first.last;
        normalIntervals.removeAt(0);
      } else if (italicIntervals.isNotEmpty &&
          italicIntervals.first.first == currentIndex) {
        result.add(TextSegment(
            string.substring(currentIndex, italicIntervals.first.last),
            format: Format.italic));
        currentIndex = italicIntervals.first.last;
        italicIntervals.removeAt(0);
      } else if (boldIntervals.isNotEmpty &&
          boldIntervals.first.first == currentIndex) {
        result.add(TextSegment(
            string.substring(currentIndex, boldIntervals.first.last),
            format: Format.bold));
        currentIndex = boldIntervals.first.last;
        boldIntervals.removeAt(0);
      } else if (boldItalicIntervals.isNotEmpty &&
          boldItalicIntervals.first.first == currentIndex) {
        result.add(TextSegment(
            string.substring(currentIndex, boldItalicIntervals.first.last),
            format: Format.boldItalic));
        currentIndex = boldItalicIntervals.first.last;
        boldItalicIntervals.removeAt(0);
      }
    }
    return result;
  }

  /// Returns a list of intervals from a list of indices
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

class TextSegment {
  final String text;
  final Format format;

  TextSegment(this.text, {this.format = Format.normal});
}

enum Format { normal, italic, bold, boldItalic }

class ArticleBuilder {
  String content;
  double paragraphSpacing;
  TextStyle style;
  TextAlign textAlign;
  TextOverflow overflow;
  List<Widget> children = <Widget>[];

  ArticleBuilder(
      {@required this.content,
      this.paragraphSpacing = 16,
      this.style,
      this.textAlign = TextAlign.justify,
      this.overflow});

  List<Widget> buildWidgets(BuildContext context) {
    var parts = content.split(RegExp(r'\n\s{2,}'));

    // print('The number of paragraphs is:');
    // print(parts.length);

    for (var i = 0; i < parts.length; i++) {
      String paragraph = parts[i];
      Widget parsedParagaph = parseParagraph(paragraph, context);
      if (parsedParagaph != null) {
        children.add(parsedParagaph);
        children.add(SizedBox(
          height: 16,
        ));
      }

      RegExp imageExp = RegExp(r'!\[(.+)\]\((.+)\)');
      var matches = imageExp.allMatches(content).toList();
      for (var j = 0; j < matches.length; j++) {
        children
            .add(parseImage(matches[i].group(2), altText: matches[i].group(1)));
      }
    }
    return children;
  }

  Widget parseParagraph(String paragraph, BuildContext context) {
    RegExp imageExp = RegExp(r'!\[(.+)\]\((.+)\)');
    paragraph = paragraph.replaceAll(imageExp, '');
    if (paragraph.isEmpty) return null;
    var segments = FormatedString(paragraph).toTextSegments();
    // print('The number of segments is:');
    // print(segments.length);
    var spans = <TextSpan>[];
    for (var i = 0; i < segments.length; i++) {
      var style = TextStyle();
      switch (segments[i].format) {
        case Format.normal:
          // do nothing
          break;
        case Format.italic:
          style = TextStyle(fontStyle: FontStyle.italic);
          print('Found italics');
          break;
        case Format.bold:
          style = TextStyle(fontWeight: FontWeight.bold);
          break;
        case Format.boldItalic:
          style = TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic);
          break;
      }
      spans.add(TextSpan(text: segments[i].text, style: style));
    }
    return Text.rich(
      TextSpan(
        children: spans,
      ),
      style: style ?? Theme.of(context).textTheme.bodyText1,
      textAlign: textAlign,
      overflow: overflow,
    );
  }

  Widget parseImage(String url, {String altText = ''}) {
    return Image.network(
      url,
    );
  }
}
