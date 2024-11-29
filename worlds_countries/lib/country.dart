class Country {
  final String name;
  final String capital;
  final String region;
  final int population;
  final String flag;
  final List<String> languages;
  final Map<String, String> currencies;

  Country({
    required this.name,
    required this.capital,
    required this.region,
    required this.population,
    required this.flag,
    required this.languages,
    required this.currencies,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']['common'] ?? 'Unknown',
      capital: (json['capital'] as List<dynamic>?)?.first ?? 'Unknown',
      region: json['region'] ?? 'Unknown',
      population: json['population'] ?? 0,
      flag: json['flags']['png'] ?? '',
      languages: json['languages'] != null 
        ? (json['languages'] as Map<String, dynamic>).values.toList().cast<String>()
        : [],
      currencies: json['currencies'] != null 
        ? Map.from(json['currencies']).map((key, value) => 
            MapEntry(key, value['name'] as String))
        : {},
    );
  }
}
