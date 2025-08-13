/// Modelo de dados para um personagem do Rick and Morty
class CharacterModel {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final OriginModel origin;
  final LocationModel location;
  final String imageUrl;
  final List<String> episodes;
  final String apiUrl;
  final DateTime createdAt;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.imageUrl,
    required this.episodes,
    required this.apiUrl,
    required this.createdAt,
  });

  /// Cria uma instância de CharacterModel a partir de JSON
  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      species: json['species'] ?? '',
      type: json['type'] ?? '',
      gender: json['gender'] ?? '',
      origin: OriginModel.fromJson(json['origin'] ?? {}),
      location: LocationModel.fromJson(json['location'] ?? {}),
      imageUrl: json['image'] ?? '',
      episodes: List<String>.from(json['episode'] ?? []),
      apiUrl: json['url'] ?? '',
      createdAt: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
    );
  }

  /// Converte a instância para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'origin': origin.toJson(),
      'location': location.toJson(),
      'image': imageUrl,
      'episode': episodes,
      'url': apiUrl,
      'created': createdAt.toIso8601String(),
    };
  }

  /// Verifica se o personagem está vivo
  bool get isAlive => status.toLowerCase() == 'alive';

  /// Verifica se o personagem está morto
  bool get isDead => status.toLowerCase() == 'dead';

  /// Verifica se o status é desconhecido
  bool get isStatusUnknown => status.toLowerCase() == 'unknown';

  /// Retorna o número do primeiro episódio
  String get firstEpisodeNumber {
    if (episodes.isEmpty) return 'Unknown';
    return episodes.first.split('/').last;
  }

  /// Retorna o número do último episódio
  String get lastEpisodeNumber {
    if (episodes.isEmpty) return 'Unknown';
    return episodes.last.split('/').last;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CharacterModel(id: $id, name: $name)';
}

/// Modelo de dados para a origem de um personagem
class OriginModel {
  final String name;
  final String url;

  const OriginModel({required this.name, required this.url});

  factory OriginModel.fromJson(Map<String, dynamic> json) {
    return OriginModel(name: json['name'] ?? 'Unknown', url: json['url'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
  }
}

/// Modelo de dados para a localização de um personagem
class LocationModel {
  final String name;
  final String url;

  const LocationModel({required this.name, required this.url});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] ?? 'Unknown',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
  }
}
