import 'package:flutter/material.dart';

class EarStockMessageOverlay extends StatelessWidget {
  final bool isAlertMessage;

  final String titleText;
  final String badgeText;

  final Color badgeColor;
  final Color badgeBackground;
  final Color accentColor;

  final VoidCallback onConfirm;

  const EarStockMessageOverlay({
    super.key,
    required this.isAlertMessage,
    required this.titleText,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBackground,
    required this.accentColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.28),
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(
              milliseconds: 220,
            ),
            tween: Tween(
              begin: 0.88,
              end: 1.0,
            ),
            curve: Curves.easeOutBack,
            builder: (
              context,
              scale,
              child,
            ) {
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: scale
                      .clamp(0.0, 1.0)
                      .toDouble(),
                  child: child,
                ),
              );
            },
            child: Container(
              width: 290,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color:
                        accentColor.withOpacity(0.16),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'EarStock Alert',
                    style: TextStyle(
                      color: Color(0xff151329),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (isAlertMessage)
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            titleText,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color:
                                  Color(0xff55506A),
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBackground,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        const Text(
                          '알림 발생',
                          style: TextStyle(
                            color: Color(0xff55506A),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      titleText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xff55506A),
                        fontSize: 14,
                      ),
                    ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: 110,
                    height: 38,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(22),
                          side: BorderSide(
                            color: accentColor,
                            width: 1.2,
                          ),
                        ),
                      ),
                      onPressed: onConfirm,
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          color: Color(0xff151329),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}