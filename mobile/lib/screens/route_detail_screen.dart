import 'package:flutter/material.dart';
import '../models/flight_models.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';
import '../widgets/common.dart';
import '../widgets/price_chart.dart';

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen(
      {super.key,
      required this.route,
      required this.api,
      required this.state,
      required this.departure});
  final FlightRoute route;
  final ApiService api;
  final MonitorState state;
  final DateTime departure;
  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late DateTime _departure = widget.departure;
  DemoScenario _scenario = DemoScenario.normal;
  List<PriceSnapshot> _history = [];
  bool _loading = true, _saving = false;
  String? _error, _inputError;
  int _generation = 0, _selected = 0;
  final _threshold = TextEditingController();

  @override
  void initState() {
    super.initState();
    _restoreRule();
    _load();
  }

  void _restoreRule() {
    final rule = widget.state.ruleFor(widget.route, _departure);
    _threshold.text = rule == null
        ? ''
        : (rule.thresholdMinor / 100).toStringAsFixed(2).replaceAll('.', ',');
    _inputError = null;
  }

  @override
  void dispose() {
    _generation++;
    _threshold.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    final date = _departure;
    setState(() {
      _loading = true;
      _error = null;
      _history = [];
    });
    try {
      final data = await widget.api
          .getRouteHistory(widget.route, date, scenario: _scenario);
      if (!mounted || generation != _generation) return;
      setState(() {
        _history = data;
        _selected = data.isEmpty ? 0 : data.length - 1;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _error = 'Не удалось получить историю. Предыдущая история другой даты '
            'не подставляется вместо результата.';
      });
    }
  }

  Future<void> _changeDate() async {
    final next = await pickDeparture(context, _departure, widget.api.now());
    if (next == null || !mounted) return;
    try {
      await widget.state.selectDate(next);
      if (!mounted) return;
      setState(() {
        _departure = next;
        _restoreRule();
      });
      await _load();
    } catch (_) {
      _notice('Не удалось сохранить выбранную дату.');
    }
  }

  void _notice(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _saveRule() async {
    final minor = parseThreshold(_threshold.text);
    if (minor == null) {
      setState(() => _inputError =
          'Введите положительную сумму, не более 2 знаков после запятой.');
      return;
    }
    setState(() {
      _saving = true;
      _inputError = null;
    });
    try {
      await widget.state.saveRule(widget.route, _departure, minor);
      _notice('Сохранено на устройстве. Push-уведомления не отправляются.');
    } catch (_) {
      _notice('Правило не сохранено. Проверьте локальное хранилище.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _instant(DateTime date) {
    final local = date.toLocal();
    return '${displayDate(local)} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')} '
        '(время устройства)';
  }

  Widget _metric(String label, String value) => SizedBox(
        width: 240,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700))
        ]),
      );

  Widget _historyContent() {
    if (_loading) {
      return const Padding(
          padding: EdgeInsets.all(40),
          child: Column(children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загружаем историю выбранной даты…')
          ]));
    }
    if (_error != null) {
      return StateMessage(
          icon: Icons.cloud_off,
          title: 'История недоступна',
          message: _error!,
          action: _load);
    }
    if (_history.isEmpty) {
      return const StateMessage(
          icon: Icons.query_stats,
          title: 'Для этой даты пока нет наблюдений',
          message:
              'Выберите другую дату или сохраните порог для будущего отслеживания. '
              'Отсутствие наблюдений не означает отсутствие рейсов.');
    }

    final summary = PriceSummary(_history);
    final latest = summary.latest!;
    final age = widget.api.now().toUtc().difference(latest.collectedAt);
    final aged = age > const Duration(hours: 48);
    final change = summary.changePercent;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (aged || age.isNegative || latest.invalidSourceTime)
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFE8D1),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(aged
                    ? 'Данные устарели: последний замер старше 48 часов. '
                        'Это не текущая цена.'
                    : 'Временная метка источника или замера некорректна. Свежесть не подтверждена.'))),
      Card(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        widget.api.demo
                            ? 'Последняя цена в демоистории'
                            : 'Последняя цена в ответе сервера',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(money(latest.priceKzt),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('Замер: ${_instant(latest.collectedAt)}'),
                    Text('Источник: ${latest.source ?? 'не указан сервером'}'),
                    Text(
                        'Время исходной цены: ${latest.trustedSourceTime == null ? 'неизвестно' : _instant(latest.trustedSourceTime!)}'),
                    Text(
                        'Кэш источника: ${latest.isCached == null ? 'неизвестно' : latest.isCached! ? 'да' : 'нет'}'),
                    const SizedBox(height: 10),
                    Text(widget.api.demo
                        ? 'Учебный пример минимальной цены. Не является предложением к покупке.'
                        : 'Данные API не верифицированы. Тариф, багаж и полное наличие рейсов не подтверждены.'),
                  ]))),
      Card(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Что показывает история',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    Wrap(spacing: 20, runSpacing: 20, children: [
                      _metric(
                          'Прошлая медиана',
                          summary.priorMedian == null
                              ? 'Недостаточно данных'
                              : money(summary.priorMedian!)),
                      _metric('Минимум за период', money(summary.minimum!)),
                      _metric(
                          'Изменение за период',
                          change == null
                              ? 'Недостаточно данных'
                              : '${change > 0 ? '+' : ''}${change.toStringAsFixed(1).replaceAll('.', ',')}%'),
                      _metric('Наблюдений', '${_history.length}'),
                    ]),
                    const SizedBox(height: 16),
                    Text(summary.assessment,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text('Последний замер исключён из прошлой медианы. '
                        'Оценка «ниже/выше» означает отклонение от неё не менее 8%. '
                        'Это описание истории, а не прогноз или совет покупать.'),
                  ]))),
      Card(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Динамика цены',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('Одна дата вылета: ${displayDate(_departure)}'),
                    const SizedBox(height: 18),
                    PriceChart(
                        history: summary.history, selectedIndex: _selected),
                    const SizedBox(height: 10),
                    const Text(
                        'По горизонтали — время замера; по вертикали — цена в KZT. '
                        'Линии соединяют известные точки и не восстанавливают пропущенные цены.'),
                    const SizedBox(height: 12),
                    Text(
                        'Выбранный замер: ${money(summary.history[_selected].priceKzt)}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(_instant(summary.history[_selected].collectedAt)),
                    const Divider(height: 28),
                    ...List.generate(summary.history.length, (i) {
                      final item = summary.history[i];
                      return ListTile(
                        key: Key('observation-$i'),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 6),
                        selected: i == _selected,
                        leading: Icon(i == _selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off),
                        title: Text(money(item.priceKzt)),
                        subtitle: Text(_instant(item.collectedAt)),
                        onTap: () => setState(() => _selected = i),
                      );
                    }),
                  ]))),
    ]);
  }

  Widget _tracking() {
    final rule = widget.state.ruleFor(widget.route, _departure);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Отслеживание цены',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                      '${widget.route.codes} • Вылет ${displayDate(_departure)}'),
                  const SizedBox(height: 12),
                  TextField(
                      key: const Key('threshold-input'),
                      controller: _threshold,
                      enabled: !_saving,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText: 'Пороговая цена, KZT',
                          hintText: 'Например, 25 000',
                          errorText: _inputError)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                      key: const Key('save-rule'),
                      onPressed: _saving ? null : _saveRule,
                      icon: const Icon(Icons.notifications_outlined),
                      label: Text(_saving
                          ? 'Сохраняем…'
                          : rule == null
                              ? 'Сохранить правило на устройстве'
                              : 'Обновить правило')),
                  if (rule != null)
                    SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(rule.isActive
                            ? 'Правило активно'
                            : 'Правило отключено'),
                        value: rule.isActive,
                        onChanged: _saving
                            ? null
                            : (active) async {
                                try {
                                  await widget.state
                                      .setRuleActive(rule, active);
                                } catch (_) {
                                  _notice('Не удалось изменить правило.');
                                }
                              }),
                  const SizedBox(height: 8),
                  const Text(
                      'Правило хранится на этом устройстве и доступно во вкладке '
                      '«Отслеживание». Реальная доставка push пока не подключена.'),
                ])));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) => Scaffold(
            appBar: AppBar(title: Text(widget.route.codes), actions: [
              IconButton(
                  tooltip: widget.state.isFavorite(widget.route)
                      ? 'Убрать из избранного'
                      : 'Добавить в избранное',
                  onPressed: () async {
                    try {
                      await widget.state.toggleFavorite(widget.route);
                    } catch (_) {
                      _notice('Не удалось сохранить избранное.');
                    }
                  },
                  icon: Icon(widget.state.isFavorite(widget.route)
                      ? Icons.star
                      : Icons.star_border)),
              IconButton(
                  tooltip: 'Обновить историю',
                  onPressed: _loading ? null : _load,
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
                                const SizedBox(height: 20),
                                Text(widget.route.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                const SizedBox(height: 12),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: DepartureButton(
                                        date: _departure,
                                        onPressed:
                                            _saving ? () {} : _changeDate)),
                                if (widget.api.demo) ...[
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<DemoScenario>(
                                      key: const Key('demo-scenario'),
                                      initialValue: _scenario,
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                          labelText: 'Учебный сценарий'),
                                      items: DemoScenario.values
                                          .map((value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(value.label)))
                                          .toList(),
                                      onChanged: _saving
                                          ? null
                                          : (value) {
                                              if (value == null) return;
                                              setState(() => _scenario = value);
                                              _load();
                                            }),
                                ],
                                const SizedBox(height: 16),
                                _historyContent(),
                                const SizedBox(height: 12),
                                _tracking(),
                                const SizedBox(height: 24),
                              ]))),
                )),
          ));
}

