/// Modelo de resposta da API do Rick and Morty
class ApiResponseModel<T> {
  final ApiInfoModel info;
  final List<T> results;

  const ApiResponseModel({required this.info, required this.results});

  /// Cria uma instância de ApiResponseModel a partir de JSON
  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponseModel(
      info: ApiInfoModel.fromJson(json['info'] ?? {}),
      results: (json['results'] as List<dynamic>? ?? [])
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converte a instância para JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'info': info.toJson(),
      'results': results.map((item) => toJsonT(item)).toList(),
    };
  }

  /// Verifica se tem mais páginas disponíveis
  bool get hasNextPage => info.nextPageUrl != null;

  /// Verifica se tem página anterior disponível
  bool get hasPreviousPage => info.previousPageUrl != null;

  /// Retorna o número total de itens
  int get totalCount => info.count;

  /// Retorna o número total de páginas
  int get totalPages => info.pages;
}

/// Modelo de informações de paginação da API
class ApiInfoModel {
  final int count;
  final int pages;
  final String? nextPageUrl;
  final String? previousPageUrl;

  const ApiInfoModel({
    required this.count,
    required this.pages,
    this.nextPageUrl,
    this.previousPageUrl,
  });

  factory ApiInfoModel.fromJson(Map<String, dynamic> json) {
    return ApiInfoModel(
      count: json['count'] ?? 0,
      pages: json['pages'] ?? 0,
      nextPageUrl: json['next'],
      previousPageUrl: json['prev'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'pages': pages,
      'next': nextPageUrl,
      'prev': previousPageUrl,
    };
  }

  /// Extrai o número da página da URL
  int? getPageNumberFromUrl(String? url) {
    if (url == null) return null;

    final uri = Uri.parse(url);
    final pageParam = uri.queryParameters['page'];
    return pageParam != null ? int.tryParse(pageParam) : null;
  }

  /// Retorna o número da próxima página
  int? get nextPageNumber => getPageNumberFromUrl(nextPageUrl);

  /// Retorna o número da página anterior
  int? get previousPageNumber => getPageNumberFromUrl(previousPageUrl);
}
