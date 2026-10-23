import 'package:flutter/material.dart';
import '../models/flight_models.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../services/alert_service.dart';
import 'route_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService();
  final AlertNotificationService _alertService = AlertNotificationService();

  List<FlightRoute> _routes = [];
  bool _isLoading = true;
  String? _error;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final routes = await _apiService.getRoutes();
      if (!mounted) return;
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'Не удалось загрузить маршруты. Проверьте доступность сервера.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedRoutes = _selectedTabIndex == 0
        ? _routes
        : _routes.where((r) => _favoritesService.isFavorite(r.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Авиамаршруты Казахстана'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoutes,
            tooltip: 'Обновить данные',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(
                      onPressed: _loadRoutes, child: const Text('Повторить'))
                ]))
              : displayedRoutes.isEmpty
                  ? Center(
                      child: Text(_selectedTabIndex == 0
                          ? 'Нет доступных маршрутов'
                          : 'Нет маршрутов в избранном'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: displayedRoutes.length,
                      itemBuilder: (context, index) {
                        final route = displayedRoutes[index];
                        final isFav = _favoritesService.isFavorite(route.id);
                        final threshold = _alertService.getThreshold(route.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.flight_takeoff),
                            ),
                            title: Text(
                              route.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              threshold != null
                                  ? 'Порог уведомления: ${threshold.toStringAsFixed(0)} KZT'
                                  : 'Нажмите для просмотра графика и аналитики',
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isFav ? Icons.star : Icons.star_border,
                                color: isFav ? Colors.amber : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  _favoritesService.toggleFavorite(route.id);
                                });
                              },
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RouteDetailScreen(
                                    route: route,
                                    apiService: _apiService,
                                    alertService: _alertService,
                                  ),
                                ),
                              );
                              if (!mounted) return;
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (idx) => setState(() => _selectedTabIndex = idx),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.connecting_airports),
            label: 'Все маршруты (${_routes.length})',
          ),
          const NavigationDestination(
            icon: Icon(Icons.star),
            label: 'Избранное',
          ),
        ],
      ),
    );
  }
}
