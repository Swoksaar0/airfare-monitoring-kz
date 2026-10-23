class FavoritesService {
  final Set<int> _favoriteRouteIds = {1, 3}; // По умолчанию ALA->NQZ и ALA->CIT

  Set<int> get favoriteIds => Set.unmodifiable(_favoriteRouteIds);

  bool isFavorite(int routeId) => _favoriteRouteIds.contains(routeId);

  void toggleFavorite(int routeId) {
    if (_favoriteRouteIds.contains(routeId)) {
      _favoriteRouteIds.remove(routeId);
    } else {
      _favoriteRouteIds.add(routeId);
    }
  }
}
