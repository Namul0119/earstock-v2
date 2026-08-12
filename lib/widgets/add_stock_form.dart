import 'package:flutter/material.dart';
import '../formatters/price_input_formatter.dart';

class AddStockForm extends StatelessWidget {

    final TextEditingController stockController;
    final TextEditingController baseController;
    final TextEditingController lowController;
    final TextEditingController highController;
    final VoidCallback onClearSearch;
    final ValueChanged<String> onStockSearchChanged;
    final ValueChanged<Map<String, dynamic>> onSelectStock;
    final bool isStockSearchOpen;
    final bool isStockSearching;
    final List<Map<String, dynamic>> stockSearchResults;
    final Future<void> Function() onAddStock;

    final Color panelColor;
    final Color accentColor;

    const AddStockForm({
        super.key,
        required this.stockController,
        required this.baseController,
        required this.lowController,
        required this.highController,
        required this.panelColor,
        required this.accentColor,
        required this.onClearSearch,
        required this.onStockSearchChanged,
        required this.onSelectStock,
        required this.isStockSearchOpen,
        required this.isStockSearching,
        required this.stockSearchResults,
        required this.onAddStock,
    });

    @override
    Widget build(BuildContext context) {

    return Column(
        children: [
            TextField(
                controller: stockController,
                style: const TextStyle(
                    color: Colors.white,
                ),
                onChanged: onStockSearchChanged,
                decoration: InputDecoration(
                    labelText: '종목명 또는 종목 코드 검색',
                    hintText: '예: 삼성전자, 삼성, 005930',
                    labelStyle: const TextStyle(
                        color: Colors.white70,
                    ),
                    hintStyle: const TextStyle(
                        color: Colors.white38,
                    ),
                    prefixIcon: Icon(
                        Icons.search,
                        color: accentColor,
                    ),
                    suffixIcon: stockController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                                Icons.close,
                                color: Colors.white54,
                            ),
                            onPressed: onClearSearch,
                        )
                        : null,
                    filled: true,
                    fillColor: panelColor,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: accentColor.withOpacity(0.35),
                        ),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: accentColor,
                            width: 1.5,
                        ),
                    ),
                ),
            ),

            if (isStockSearchOpen)
            Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                    maxHeight: 230,
                ),
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                    color: panelColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: accentColor.withOpacity(0.25),
                    ),
                    boxShadow: [
                        BoxShadow(
                        color: Colors.black.withOpacity(0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                        ),
                    ],
                ),
                child: isStockSearching
                    ? Padding(
                        padding: EdgeInsets.all(18),
                        child: Center(
                            child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: accentColor,
                                ),
                            ),
                        ),
                    )
                    : stockSearchResults.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(18),
                            child: Text(
                                '검색 결과가 없습니다.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white54,
                                ),
                            ),
                        )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6,
                            ),
                            shrinkWrap: true,
                            itemCount: stockSearchResults.length,
                            separatorBuilder: (context, index) {
                                return const Divider(
                                    color: Colors.white10,
                                    height: 1,
                                );
                            },
                            itemBuilder: (context, index) {
                                final stock = stockSearchResults[index];

                                final stockName =
                                    stock['stockName']?.toString() ?? '';

                                final stockCode =
                                    stock['stockCode']?.toString() ?? '';

                                final marketType =
                                    stock['marketType']?.toString() ?? '';

                                return ListTile(
                                    leading: Container(
                                        width: 42,
                                        height: 42,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: accentColor.withOpacity(0.12),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: accentColor.withOpacity(0.35),
                                            ),
                                        ),
                                        child: Text(
                                            stockName.isNotEmpty
                                                ? stockName.substring(0, 1)
                                                : '?',
                                            style: TextStyle(
                                                color: accentColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                            ),
                                        ),
                                    ),
                                    title: Text(
                                        stockName,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                        ),
                                    ),
                                    subtitle: Text(
                                        '$stockCode · $marketType',
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                        ),
                                    ),
                                    trailing: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.white38,
                                    ),
                                    onTap: () {
                                        onSelectStock(stock);
                                    },
                                );
                            },
                        ),
            ),

            TextField(
                controller: baseController,
                keyboardType: TextInputType.number,
                inputFormatters: const [
                    PriceInputFormatter(),
                ],
                style: const TextStyle(
                    color: Colors.white,
                ),
                decoration: InputDecoration(
                    labelText: '내 매수가',
                    hintText: '예: 400,000',
                    labelStyle: const TextStyle(
                    color: Colors.white70,
                    ),
                    hintStyle: const TextStyle(
                    color: Colors.white38,
                    ),
                    filled: true,
                    fillColor: panelColor,
                    enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: accentColor.withOpacity(0.35),
                    ),
                    ),
                    focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: accentColor,
                        width: 1.5,
                    ),
                    ),
                ),
            ),

            const SizedBox(height: 12),

            TextField(
                controller: lowController,
                keyboardType: TextInputType.number,

                inputFormatters: const [
                    PriceInputFormatter(),
                ],

                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    labelText: '하락 기준 가격',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: panelColor,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: accentColor.withOpacity(0.35),
                        ),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: accentColor,
                            width: 1.5,
                        ),
                    ),
                ),
            ),

            const SizedBox(height: 12),

            TextField(
                controller: highController,
                keyboardType: TextInputType.number,

                inputFormatters: const [
                    PriceInputFormatter(),
                ],

                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    labelText: '상승 기준 가격',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: panelColor,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: accentColor.withOpacity(0.35),
                        ),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: accentColor,
                            width: 1.5,
                        ),
                    ),
                ),
            ),

            const SizedBox(height: 16),

            SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: panelColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                        ),
                    ),
                    onPressed: onAddStock,
                    child: const Text(
                        '감시 시작',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                        ),
                    ),
                ),
            ),

            const SizedBox(height: 12),
        ],
    );
    }
}