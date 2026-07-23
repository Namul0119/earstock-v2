import 'package:flutter/material.dart';

enum MarketStatus {
  open,
  afterHours,
  closed,
}

MarketStatus getMarketStatus() {
  final now = DateTime.now();

  final isWeekday =
      now.weekday >= DateTime.monday &&
      now.weekday <= DateTime.friday;

  if (!isWeekday) {
    return MarketStatus.closed;
  }

  final currentMinutes =
      now.hour * 60 + now.minute;

  const openStart = 9 * 60;
  const openEnd = 15 * 60 + 30;

  const afterHoursStart = 15 * 60 + 40;
  const afterHoursEnd = 20 * 60;

  if (currentMinutes >= openStart &&
      currentMinutes < openEnd) {
    return MarketStatus.open;
  }

  if (currentMinutes >= afterHoursStart &&
      currentMinutes < afterHoursEnd) {
    return MarketStatus.afterHours;
  }

  return MarketStatus.closed;
}

String getMarketStatusText() {
  switch (getMarketStatus()) {
    case MarketStatus.open:
      return '장중 · 실시간 감시';

    case MarketStatus.afterHours:
      return '시간외 거래';

    case MarketStatus.closed:
      return '시장 종료';
  }
}

Color getMarketStatusColor() {
  switch (getMarketStatus()) {
    case MarketStatus.open:
      return const Color(0xff00F5A0);

    case MarketStatus.afterHours:
      return Colors.amber;

    case MarketStatus.closed:
      return Colors.grey;
  }
}