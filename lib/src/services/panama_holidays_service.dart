import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model for a public holiday from Nager.Date API
class PublicHoliday {
  final DateTime date;
  final String localName;
  final String name;
  final String countryCode;
  final bool isFixed;
  final bool isGlobal;

  PublicHoliday({
    required this.date,
    required this.localName,
    required this.name,
    required this.countryCode,
    required this.isFixed,
    required this.isGlobal,
  });

  factory PublicHoliday.fromJson(Map<String, dynamic> json) {
    return PublicHoliday(
      date: DateTime.parse(json['date'] as String),
      localName: json['localName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? 'PA',
      isFixed: json['fixed'] as bool? ?? false,
      isGlobal: json['global'] as bool? ?? true,
    );
  }
}

/// Service for fetching Panama public holidays using Nager.Date API
/// API is free, no rate limit, no API key required
class PanamaHolidaysService {
  static const String _baseUrl = 'https://date.nager.at/api/v3';
  static const String _countryCode = 'PA';

  /// Cache of loaded holidays by year
  final Map<int, List<PublicHoliday>> _cache = {};

  /// Get holidays for a specific year
  Future<List<PublicHoliday>> getHolidays(int year) async {
    // Check cache first
    if (_cache.containsKey(year)) {
      return _cache[year]!;
    }

    try {
      final url = Uri.parse('$_baseUrl/PublicHolidays/$year/$_countryCode');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final holidays = data.map((json) => PublicHoliday.fromJson(json)).toList();
        _cache[year] = holidays;
        return holidays;
      } else {
        // Return empty list on error
        return [];
      }
    } catch (e) {
      // Return empty list on network error
      return [];
    }
  }

  /// Check if a specific date is a holiday
  Future<PublicHoliday?> isHoliday(DateTime date) async {
    final holidays = await getHolidays(date.year);
    try {
      return holidays.firstWhere(
        (h) => h.date.year == date.year && h.date.month == date.month && h.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get holidays for a date range
  Future<List<PublicHoliday>> getHolidaysInRange(DateTime start, DateTime end) async {
    final Set<int> years = {start.year, end.year};
    final List<PublicHoliday> result = [];

    for (final year in years) {
      final holidays = await getHolidays(year);
      result.addAll(holidays.where((h) => 
        !h.date.isBefore(start) && !h.date.isAfter(end)
      ));
    }

    return result;
  }

  /// Get known Panama holidays (fallback if API is unavailable)
  static List<PublicHoliday> getFallbackHolidays(int year) {
    return [
      PublicHoliday(date: DateTime(year, 1, 1), localName: 'Año Nuevo', name: "New Year's Day", countryCode: 'PA', isFixed: true, isGlobal: true),
      PublicHoliday(date: DateTime(year, 1, 9), localName: 'Día de los Mártires', name: 'Martyrs Day', countryCode: 'PA', isFixed: true, isGlobal: true),
      PublicHoliday(date: DateTime(year, 5, 1), localName: 'Día del Trabajo', name: 'Labour Day', countryCode: 'PA', isFixed: true, isGlobal: true),
      PublicHoliday(date: DateTime(year, 11, 3), localName: 'Separación de Panamá de Colombia', name: 'Separation Day', countryCode: 'PA', isFixed: true, isGlobal: true),
      PublicHoliday(date: DateTime(year, 11, 4), localName: 'Día de la Bandera', name: 'Flag Day', countryCode: 'PA', isFixed: true, isGlobal: true),
      PublicHoliday(date: DateTime(year, 11, 5), localName: 'Día de Colón', name: 'Colon Day', countryCode: 'PA', isFixed: true, isGlobal: true),
      PublicHoliday(date: DateTime(year, 11, 10), localName: 'Primer Grito de Independencia', name: 'Los Santos Uprising Day', countryCode: 'PA', isFixed: true, isGlobal: true),
      PublicHoliday(date: DateTime(year, 11, 28), localName: 'Independencia de Panamá de España', name: 'Independence Day', countryCode: 'PA', isFixed: true, isGlobal: true),
      PublicHoliday(date: DateTime(year, 12, 8), localName: "Día de la Madre", name: "Mother's Day", countryCode: 'PA', isFixed: true, isGlobal: true),
      PublicHoliday(date: DateTime(year, 12, 25), localName: 'Navidad', name: 'Christmas Day', countryCode: 'PA', isFixed: true, isGlobal: true),
    ];
  }
}
