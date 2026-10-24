import 'package:flutter/material.dart';
import '../models/flight_models.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';
import '../widgets/common.dart';
import 'route_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api, required this.state});
  final ApiService api;
  final MonitorState state;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FlightRoute> _routes = [];
  String _query = '';
  int _tab = 0;
  bool _loading = true;
  String? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final routes = await widget.api.getRoutes();
      if (!mounted || generation != _generation) return;
      setState(() {
        _routes = routes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = 'Не удалось загрузить направления. '
            'Проверьте подключение к серверу.';
        _loading = false;
      });
    }
  }

  Future<void> _save(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Изменение не сохранено. Проверьте локальное хранилище.')));
      }
    }
  }

  Future<void> _date() async {
    final value =
        await pickDeparture(context, widget.state.departure, widget.api.now());
    if (value != null) await _save(() => widget.state.selectDate(value));
  }

  Future<void> _open(FlightRoute route, {DateTime? date}) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => RouteDetailScreen(
            route: route,
            api: widget.api,
            state: widget.state,
            departure: date ?? widget.state.departure)));
  }

  void _about() => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => SafeArea(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('О прототипе',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                const Text(
                    '12 выбранных внутренних направлений. История показывает '
                    'повторные наблюдения для одной даты вылета, а не цены соседних дат.'),
                const SizedBox(height: 12),
                const Text(
                    'Избранное, дата и правила сохраняются на устройстве. '
                    'Они не синхронизируются с аккаунтом. Очистка данных браузера удалит их.'),
                const SizedBox(height: 12),
                const Text(
                    'Оценка сравнивает последнюю цену с медианой предыдущих '
                    'наблюдений. Это описание истории, а не прогноз или совет покупать.'),
                const SizedBox(height: 12),
                Text(widget.api.demo
                    ? 'На экране истории можно выбрать учебный сценарий: '
                        'ошибка, отсутствие данных, старые данные или одно наблюдение.'
                    : 'Режим API пока предназначен для проверки чтения истории. '
                        'Доставка уведомлений и надёжный сбор требуют доработки сервера.'),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Понятно')),
              ]),
        )),
      );

  Widget _routeCard(FlightRoute route) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.flight_takeoff)),
          title: Text(route.title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
              '${route.codes}\nИстория на ${displayDate(widget.state.departure)}'),
          isThreeLine: true,
          trailing: IconButton(
            tooltip:
                '${widget.state.isFavorite(route) ? 'Убрать из избранного' : 'В избранное'}: ${route.codes}',
            icon: Icon(widget.state.isFavorite(route)
                ? Icons.star
                : Icons.star_border),
            color:
                widget.state.isFavorite(route) ? const Color(0xFFA26600) : null,
            onPressed: () => _save(() => widget.state.toggleFavorite(route)),
          ),
          onTap: () => _open(route),
        ),
      );

  Widget _rules() {
    final rules = [...widget.state.rules]
      ..sort((a, b) => a.departureDate.compareTo(b.departureDate));
    if (rules.isEmpty) {
      return const StateMessage(
          icon: Icons.notifications_none,
          title: 'Пока нет правил',
          message:
              'Откройте направление, выберите дату вылета и сохраните порог цены.');
    }
    return Column(
        children: rules.map((rule) {
      final expired = rule.expired(widget.api.now());
      return Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(rule.route.title,
                              style: Theme.of(context).textTheme.titleMedium)),
                      IconButton(
                          tooltip:
                              'Удалить правило: ${rule.route.codes}, ${rule.departureDate}',
                          onPressed: () async {
                            final remove = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                        title: const Text('Удалить правило?'),
                                        content: Text(
                                            '${rule.route.title}, ${displayDate(DateTime.parse(rule.departureDate))}'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Отмена')),
                                          FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Удалить')),
                                        ]));
                            if (remove == true) {
                              await _save(() => widget.state.removeRule(rule));
                            }
                          },
                          icon: const Icon(Icons.delete_outline)),
                    ]),
                    Text(
                        'Вылет: ${displayDate(DateTime.parse(rule.departureDate))}'),
                    Text('Порог: ${money(rule.thresholdKzt)}'),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(expired
                          ? 'Дата вылета прошла'
                          : rule.isActive
                              ? 'Правило активно'
                              : 'Правило отключено'),
                      subtitle: const Text(
                          'Локальное правило. Push пока не подключён.'),
                      value: rule.isActive && !expired,
                      onChanged: expired
                          ? null
                          : (active) => _save(
                              () => widget.state.setRuleActive(rule, active)),
                    ),
                    if (!expired)
                      TextButton.icon(
                          onPressed: () => _open(rule.route,
                              date: DateTime.parse(rule.departureDate)),
                          icon: const Icon(Icons.show_chart),
                          label: const Text('Открыть историю')),
                  ])));
    }).toList());
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        final query = _query.trim().toLowerCase();
        final displayed = _routes
            .where((r) =>
                (_tab != 1 || widget.state.isFavorite(r)) &&
                '${r.title} ${r.codes}'.toLowerCase().contains(query))
            .toList();
        return Scaffold(
          appBar: AppBar(title: const Text('Airfare KZ'), actions: [
            IconButton(
                onPressed: _about,
                tooltip: 'О прототипе',
                icon: const Icon(Icons.help_outline)),
            IconButton(
                onPressed: _loading ? null : _load,
                tooltip: 'Обновить направления',
                icon: const Icon(Icons.refresh)),
          ]),
          body: RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: PageWidth(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ModeNotice(demo: widget.api.demo),
                              const SizedBox(height: 22),
                              Text(
                                  _tab == 2
                                      ? 'Отслеживание цен'
                                      : 'Выберите направление',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(_tab == 2
                                  ? 'Каждое правило привязано к направлению и дате вылета.'
                                  : 'Сравнивайте наблюдения для одной и той же даты вылета.'),
                              if (widget.state.storageWarning != null)
                                Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(widget.state.storageWarning!,
                                        style: const TextStyle(
                                            color: Colors.deepOrange))),
                              const SizedBox(height: 16),
                              if (_tab != 2) ...[
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: DepartureButton(
                                        date: widget.state.departure,
                                        onPressed: _date)),
                                Wrap(
                                    spacing: 8,
                                    children: [7, 14, 30].map((days) {
                                      final date =
                                          calendarDate(widget.api.now())
                                              .add(Duration(days: days));
                                      return ChoiceChip(
                                          label: Text('Через $days дн.'),
                                          selected:
                                              dateKey(widget.state.departure) ==
                                                  dateKey(date),
                                          onSelected: (_) => _save(() =>
                                              widget.state.selectDate(date)));
                                    }).toList()),
                                const SizedBox(height: 16),
                                TextField(
                                    key: const Key('route-search'),
                                    decoration: const InputDecoration(
                                        labelText: 'Город или код аэропорта',
                                        prefixIcon: Icon(Icons.search),
                                        hintText: 'Например, Астана или NQZ'),
                                    onChanged: (value) =>
                                        setState(() => _query = value)),
                                const SizedBox(height: 16),
                              ],
                              if (_tab == 2)
                                _rules()
                              else if (_loading)
                                const Padding(
                                    padding: EdgeInsets.all(36),
                                    child: Center(
                                        child: CircularProgressIndicator()))
                              else if (_error != null)
                                StateMessage(
                                    icon: Icons.cloud_off,
                                    title: 'Не удалось загрузить',
                                    message: _error!,
                                    action: _load)
                              else if (displayed.isEmpty)
                                StateMessage(
                                    icon: _tab == 1
                                        ? Icons.star_outline
                                        : Icons.search_off,
                                    title: _tab == 1 && query.isEmpty
                                        ? 'Нет избранных направлений'
                                        : 'Ничего не найдено',
                                    message: _tab == 1 && query.isEmpty
                                        ? 'Нажмите звезду рядом с нужным направлением.'
                                        : 'Попробуйте другой город или код аэропорта.')
                              else ...[
                                Text('Направлений: ${displayed.length}',
                                    style:
                                        Theme.of(context).textTheme.labelLarge),
                                const SizedBox(height: 8),
                                ...displayed.map(_routeCard),
                              ],
                              const SizedBox(height: 20),
                            ]))),
              )),
          bottomNavigationBar: NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (value) => setState(() => _tab = value),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.travel_explore), label: 'Направления'),
                NavigationDestination(
                    icon: Icon(Icons.star_outline),
                    selectedIcon: Icon(Icons.star),
                    label: 'Избранное'),
                NavigationDestination(
                    icon: Icon(Icons.notifications_outlined),
                    selectedIcon: Icon(Icons.notifications),
                    label: 'Отслеживание'),
              ]),
        );
      });
}

