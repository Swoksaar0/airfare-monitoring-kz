import 'package:flutter/material.dart';
import '../models/flight_models.dart';

class PageWidth extends StatelessWidget {
  const PageWidth({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920), child: child),
      );
}

class ModeNotice extends StatelessWidget {
  const ModeNotice({super.key, required this.demo});
  final bool demo;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: demo ? const Color(0xFFFFF3D8) : const Color(0xFFFFE4DE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(demo
                  ? 'ДЕМО • Искусственные цены для демонстрации. '
                      'Запросов к авиакомпаниям и push-уведомлений нет.'
                  : 'API-режим • Происхождение и свежесть данных сервера пока '
                      'не подтверждены. Правила сохраняются только на этом устройстве.')),
        ]),
      );
}

class StateMessage extends StatelessWidget {
  const StateMessage(
      {super.key,
      required this.icon,
      required this.title,
      required this.message,
      this.action,
      this.actionLabel = 'Повторить'});
  final IconData icon;
  final String title, message, actionLabel;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(children: [
          Icon(icon, size: 46, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: action, child: Text(actionLabel)),
          ],
        ]),
      );
}

Future<DateTime?> pickDeparture(
    BuildContext context, DateTime selected, DateTime now) {
  final first = calendarDate(now).add(const Duration(days: 1));
  final last = calendarDate(now).add(const Duration(days: 365));
  final initial = selected.isBefore(first)
      ? first
      : selected.isAfter(last)
          ? last
          : selected;
  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: first,
    lastDate: last,
    currentDate: now,
    helpText: 'Дата вылета',
    cancelText: 'Отмена',
    confirmText: 'Выбрать',
    fieldLabelText: 'Дата вылета',
    fieldHintText: 'ДД.ММ.ГГГГ',
    errorInvalidText: 'Выберите будущую дату в пределах года.',
    errorFormatText: 'Введите дату в формате ДД.ММ.ГГГГ.',
  );
}

class DepartureButton extends StatelessWidget {
  const DepartureButton(
      {super.key, required this.date, required this.onPressed});
  final DateTime date;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        key: const Key('departure-picker'),
        onPressed: onPressed,
        icon: const Icon(Icons.calendar_month_outlined),
        label: Text('Вылет: ${displayDate(date)}'),
      );
}

