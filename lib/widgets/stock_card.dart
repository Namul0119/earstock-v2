import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {
  final Map<String, dynamic> stock;
  final int refreshRemainingSeconds;
  final String Function(dynamic value) formatPrice;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;

  const StockCard({
    super.key,
    required this.stock,
    required this.refreshRemainingSeconds,
    required this.formatPrice,
    required this.onEdit,
    required this.onDelete,
  });

  static const cardColor = Color(0xff252245);
  static const accentColor = Color(0xff00F5C8);
  static const dangerColor = Color(0xffFF5C7A);
  static const successColor = Color(0xff00F5A0);

  @override
  Widget build(BuildContext context) {
    final double changeRate =
        double.tryParse(stock['changeRate'].toString()) ?? 0.0;

    final int changePrice =
        int.tryParse(stock['changePrice'].toString()) ?? 0;

    final int volume =
        int.tryParse(stock['volume'].toString()) ?? 0;

    final String status =
        stock['status']?.toString() ?? '감시중';

    final String currentPriceText =
        stock['currentPrice']?.toString() ?? '';

    final bool isPriceLoading =
        currentPriceText == '시세 확인중';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: status == '🚨 위험'
              ? [
                  cardColor,
                  const Color(0xff292342),
                  const Color(0xff35233A),
                ]
              : status == '🎯 목표 도달'
                  ? [
                      cardColor,
                      const Color(0xff202F3B),
                      const Color(0xff173F39),
                    ]
                  : [
                      cardColor,
                      cardColor,
                    ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stock['name']?.toString() ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: '감시 기준 수정',
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Colors.white70,
                      ),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: '감시 종목 삭제',
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: dangerColor,
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  isPriceLoading
                      ? currentPriceText
                      : '${formatPrice(currentPriceText)}원',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${changePrice >= 0 ? '▲' : '▼'}'
                  '${formatPrice(changePrice.abs())}원 '
                  '(${changeRate >= 0 ? '+' : '-'}'
                  '${changeRate.abs().toStringAsFixed(2)}%)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: changeRate >= 0
                        ? successColor
                        : dangerColor,
                  ),
                ),

                const SizedBox(height: 14),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: status == '🚨 위험'
                            ? dangerColor.withOpacity(0.20)
                            : status == '🎯 목표 도달'
                                ? successColor.withOpacity(0.20)
                                : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: status == '🚨 위험'
                              ? dangerColor
                              : status == '🎯 목표 도달'
                                  ? successColor
                                  : Colors.white70,
                        ),
                      ),
                    ),
                    Text(
                      '▼ ${formatPrice(stock['low'])}원',
                      style: const TextStyle(
                        color: dangerColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '▲ ${formatPrice(stock['high'])}원',
                      style: const TextStyle(
                        color: successColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Divider(
                  height: 1,
                  color: Colors.white12,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '거래량 ${formatPrice(volume)}주',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      refreshRemainingSeconds == 0
                          ? '갱신 중...'
                          : '다음 갱신 ${refreshRemainingSeconds}초',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}