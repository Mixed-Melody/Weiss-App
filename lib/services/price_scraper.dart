import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/ws_card.dart';
import '../models/trial_deck.dart';
import 'database_service.dart';

/// A service responsible for scraping card and deck prices and images from
/// third‑party web sites.  Scraping is triggered manually by the user.  The
/// implementation uses simple heuristics to locate prices and images.  See
/// TODOs within the class for further enhancements.
///
/// **Important:** Web scraping can be fragile and may violate the terms of
/// service of target sites.  Use responsibly and respect websites' robots
/// policies.  Always check the legality and ethicality of scraping before
/// enabling this functionality in a production setting.
class PriceScraper {
  PriceScraper._internal();
  static final PriceScraper instance = PriceScraper._internal();

  /// Runs the scraper for all cards and trial decks in the database.  This
  /// method iterates over every record, attempts to fetch the latest price
  /// and image, and writes back any updated values.  It catches and logs
  /// exceptions so that one failing scrape does not halt the entire run.
  Future<void> updateAll() async {
    final db = DatabaseService.instance;
    await db.init();
    final cards = db.getCards();
    for (final card in cards) {
      try {
        final double? price = await scrapeCardPrice(card);
        final String? imageUrl = await scrapeCardImageUrl(card);
        if (price != null) {
          card.price = price;
        }
        if (imageUrl != null) {
          final String localPath = await _downloadImage(imageUrl, 'card_${card.id}.jpg');
          card.imageUrl = localPath;
        }
        await db.updateCard(card);
      } catch (e) {
        debugPrint('Error scraping card ${card.name}: $e');
      }
    }
    final decks = db.getDecks();
    for (final deck in decks) {
      try {
        final double? price = await scrapeDeckPrice(deck);
        final String? imageUrl = await scrapeDeckImageUrl(deck);
        if (price != null) {
          deck.price = price;
        }
        if (imageUrl != null) {
          final String localPath = await _downloadImage(imageUrl, 'deck_${deck.id}.jpg');
          deck.imageUrl = localPath;
        }
        await db.updateDeck(deck);
      } catch (e) {
        debugPrint('Error scraping deck ${deck.name}: $e');
      }
    }
  }

  /// Attempts to determine the current price of a card by searching for it
  /// online and extracting the first price match.  This implementation uses
  /// a very naïve approach: it performs a search query and scans the
  /// resulting HTML for a dollar amount.  It is not robust and will need to
  /// be refined to target specific marketplaces.
  ///
  /// TODO: Research popular Weiß Schwarz marketplaces (e.g. TCGplayer,
  /// eBay, Amazon, other card retailers) and implement site‑specific
  /// scrapers with proper CSS selectors.  Consider caching results to
  /// reduce duplicate network requests.
  Future<double?> scrapeCardPrice(WSCard card) async {
    final query = Uri.encodeComponent('${card.name} ${card.cardNumber} price');
    final url = Uri.parse('https://duckduckgo.com/html/?q=$query');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      return null;
    }
    final document = parse(response.body);
    final text = document.body?.text ?? '';
    final priceRegex = RegExp(r'\$\s*([0-9]+(?:\.[0-9]{1,2})?)');
    final match = priceRegex.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Attempts to find an image URL for a card.  Similar to [scrapeCardPrice],
  /// this uses a search engine result page and extracts the first image src.
  /// In practice you should integrate an official API or parse a known
  /// database of card images.
  Future<String?> scrapeCardImageUrl(WSCard card) async {
    final query = Uri.encodeComponent('${card.name} ${card.cardNumber} Weiß Schwarz card image');
    final url = Uri.parse('https://duckduckgo.com/html/?q=$query');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      return null;
    }
    final document = parse(response.body);
    // This simple scraper looks for the first <img> tag with a src ending in jpg or png.
    final images = document.getElementsByTagName('img');
    for (final img in images) {
      final src = img.attributes['src'];
      if (src != null && (src.endsWith('.jpg') || src.endsWith('.png'))) {
        return src;
      }
    }
    return null;
  }

  /// Naïve price scraper for trial decks.  See [scrapeCardPrice] for details.
  Future<double?> scrapeDeckPrice(TrialDeck deck) async {
    final query = Uri.encodeComponent('${deck.name} Weiß Schwarz trial deck price');
    final url = Uri.parse('https://duckduckgo.com/html/?q=$query');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      return null;
    }
    final document = parse(response.body);
    final text = document.body?.text ?? '';
    final priceRegex = RegExp(r'\$\s*([0-9]+(?:\.[0-9]{1,2})?)');
    final match = priceRegex.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Naïve image scraper for trial decks.  See [scrapeCardImageUrl] for details.
  Future<String?> scrapeDeckImageUrl(TrialDeck deck) async {
    final query = Uri.encodeComponent('${deck.name} Weiß Schwarz trial deck image');
    final url = Uri.parse('https://duckduckgo.com/html/?q=$query');
    final response = await http.get(url);
    if (response.statusCode != 200) {
      return null;
    }
    final document = parse(response.body);
    final images = document.getElementsByTagName('img');
    for (final img in images) {
      final src = img.attributes['src'];
      if (src != null && (src.endsWith('.jpg') || src.endsWith('.png'))) {
        return src;
      }
    }
    return null;
  }

  /// Downloads an image from [url] and stores it in the application's
  /// documents directory.  Returns the local file path.  Existing images
  /// with the same filename will be overwritten.
  Future<String> _downloadImage(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to download image from $url');
    }
    final Directory dir = await getApplicationSupportDirectory();
    final File imageFile = File(p.join(dir.path, fileName));
    await imageFile.writeAsBytes(response.bodyBytes);
    return imageFile.path;
  }
}