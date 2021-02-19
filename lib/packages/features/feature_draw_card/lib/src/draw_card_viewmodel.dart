import 'package:flutter/foundation.dart';
import 'package:smart_duel_disk/packages/core/core_general/lib/core_general.dart';
import 'package:smart_duel_disk/packages/core/core_logger/core_logger_interface/lib/core_logger_interface.dart';
import 'package:smart_duel_disk/packages/core/core_navigation/lib/core_navigation.dart';

class DrawCardViewModel extends BaseViewModel {
  final VoidCallback _cardDrawnCallback;
  final RouterHelper _router;

  DrawCardViewModel(
    Logger logger,
    this._cardDrawnCallback,
    this._router,
  ) : super(
          logger,
        );

  Future<void> onCardDrawn() {
    _cardDrawnCallback?.call();
    return _router.closeScreen();
  }
}
