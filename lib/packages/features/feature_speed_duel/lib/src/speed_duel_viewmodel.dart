import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smart_duel_disk/packages/core/core_data_manager/core_data_manager_interface/lib/core_data_manager_interface.dart';
import 'package:smart_duel_disk/packages/core/core_general/lib/core_general.dart';
import 'package:smart_duel_disk/packages/core/core_logger/core_logger_interface/lib/core_logger_interface.dart';
import 'package:smart_duel_disk/packages/core/core_messaging/core_messaging_interface/lib/src/snack_bar/snack_bar_service.dart';
import 'package:smart_duel_disk/packages/core/core_navigation/lib/core_navigation.dart';
import 'package:smart_duel_disk/packages/core/core_smart_duel_server/core_smart_duel_server_interface/lib/core_smart_duel_server_interface.dart';
import 'package:smart_duel_disk/packages/features/feature_speed_duel/lib/src/dialogs/speed_duel_dialog_provider.dart';
import 'package:smart_duel_disk/packages/features/feature_speed_duel/lib/src/models/play_card.dart';
import 'package:smart_duel_disk/packages/features/feature_speed_duel/lib/src/models/player_state.dart';
import 'package:smart_duel_disk/packages/features/feature_speed_duel/lib/src/models/speed_duel_screen_event.dart';
import 'package:smart_duel_disk/packages/features/feature_speed_duel/lib/src/models/speed_duel_state.dart';
import 'package:smart_duel_disk/packages/features/feature_speed_duel/lib/src/models/zone.dart';
import 'package:smart_duel_disk/packages/wrappers/wrapper_crashlytics/wrapper_crashlytics_interface/lib/wrapper_crashlytics_interface.dart';
import 'package:smart_duel_disk/packages/wrappers/wrapper_enum_helper/wrapper_enum_helper_interface/lib/wrapper_enum_helper_interface.dart';

import 'models/deck_action.dart';
import 'models/zone_type.dart';
import 'usecases/does_card_fit_in_zone_use_case.dart';
import 'usecases/get_cards_from_deck_use_case.dart';

@Injectable()
class SpeedDuelViewModel extends BaseViewModel {
  static const _tag = 'SpeedDuelViewModel';

  static const _speedDuelStartHandLength = 4;

  final PreBuiltDeck _preBuiltDeck;
  final RouterHelper _router;
  final SmartDuelServer _smartDuelServer;
  final GetCardsFromDeckUseCase _getCardsFromDeckUseCase;
  final DoesCardFitInZoneUseCase _doesCardFitInZoneUseCase;
  final EnumHelper _enumHelper;
  final CrashlyticsProvider _crashlyticsProvider;
  final DialogService _dialogService;
  final SpeedDuelDialogProvider _speedDuelDialogProvider;
  final SnackBarService _snackBarService;

  final _playerState = BehaviorSubject<PlayerState>.seeded(const PlayerState());

  final _speedDuelState = BehaviorSubject<SpeedDuelState>.seeded(const SpeedDuelLoading());
  Stream<SpeedDuelState> get speedDuelState => _speedDuelState.stream;

  final _speedDuelScreenEvent = BehaviorSubject<SpeedDuelScreenEvent>();
  Stream<SpeedDuelScreenEvent> get speedDuelScreenEvent => _speedDuelScreenEvent.stream;

  bool _initialized = false;
  StreamSubscription<PlayerState> _playerStateSubscription;

  bool _surrendered = false;

  SpeedDuelViewModel(
    Logger logger,
    @factoryParam this._preBuiltDeck,
    this._router,
    this._smartDuelServer,
    this._getCardsFromDeckUseCase,
    this._doesCardFitInZoneUseCase,
    this._enumHelper,
    this._dialogService,
    this._crashlyticsProvider,
    this._speedDuelDialogProvider,
    this._snackBarService,
  ) : super(
          logger,
        ) {
    _init();
  }

  //region Lifecycle

  bool onBackPressed() {
    logger.info(_tag, 'onBackPressed()');

    final canPop = _surrendered || _speedDuelState.value is! SpeedDuelData;
    if (!canPop) {
      _snackBarService.showSnackBar('Currently, the back key cannot be used.');
    }

    return canPop;
  }

  //endregion

  //region Initialization

  Future<void> _init() async {
    logger.verbose(_tag, '_init()');

    try {
      _smartDuelServer.connect();

      _initPlayerStateSubscription();

      await _setDeck();
      _shuffleDeck();
      _drawStartHand();

      _speedDuelState.add(SpeedDuelState(_playerState.value));
      _initialized = true;
    } catch (e, stackTrace) {
      _crashlyticsProvider.logException(e, stackTrace);
      _speedDuelState.add(const SpeedDuelError());
    }
  }

  void _initPlayerStateSubscription() {
    logger.verbose(_tag, '_initPlayerStateSubscription()');

    _playerStateSubscription = _playerState.listen((playerState) {
      if (_initialized && _speedDuelState.value is SpeedDuelData) {
        _speedDuelState.add(SpeedDuelState(playerState));
      }
    });
  }

  Future<void> _setDeck() async {
    logger.verbose(_tag, '_setDeck()');

    final playCards = await _getCardsFromDeckUseCase(_preBuiltDeck);

    final mainDeck = playCards.where((card) => card.yugiohCard.type != CardType.fusionMonster);
    final extraDeck = playCards
        .where((card) => card.yugiohCard.type == CardType.fusionMonster)
        .map((card) => card.copyWith(zoneType: ZoneType.extraDeck));

    final currentState = _playerState.value;
    final updatedState = currentState.copyWith(
      deckZone: currentState.deckZone.copyWith(cards: mainDeck),
      extraDeckZone: currentState.extraDeckZone.copyWith(cards: extraDeck),
    );

    _playerState.add(updatedState);
  }

  void _drawStartHand() {
    logger.verbose(_tag, '_drawStartHand()');

    for (var i = 0; i < _speedDuelStartHandLength; i++) {
      _drawCard();
    }
  }

  //endregion

  //region Drag & drop

  bool doesCardFitInZone(PlayCard card, Zone zone) {
    logger.info(_tag, 'doesCardFitInZone($card, $zone)');

    _speedDuelScreenEvent.add(const SpeedDuelHideOverlaysEvent());

    final currentState = _playerState.value;

    return _doesCardFitInZoneUseCase(card, zone, currentState);
  }

  void moveCardToNewZone(PlayCard card, Zone newZone) {
    logger.info(_tag, 'moveCardToNewZone($card, $newZone)');

    _speedDuelScreenEvent.add(const SpeedDuelHideOverlaysEvent());

    final currentState = _playerState.value;
    final currentZones = currentState.zones;

    final cardOldZone = currentZones.singleWhere((zone) => zone.zoneType == card.zoneType);
    if (cardOldZone.zoneType == newZone.zoneType) {
      return;
    }

    _sendSummonEvent(card.yugiohCard, newZone);
    _sendRemoveCardEvent(cardOldZone);

    _updatePlayerState(card, newZone, cardOldZone);
  }

  void _updatePlayerState(PlayCard card, Zone newZone, Zone oldZone) {
    logger.verbose(_tag, '_updatePlayerState($card, $newZone, $oldZone)');

    final currentState = _playerState.value;
    final currentZones = currentState.zones;

    final updatedOldZone = oldZone.copyWith(cards: [...oldZone.cards]..remove(card));

    final updatedCard = card.copyWith(zoneType: newZone.zoneType);
    final updatedNewZone = newZone.copyWith(cards: [...newZone.cards, updatedCard]);

    final updatedZones = currentZones.toList()
      ..removeWhere((zone) => zone.zoneType == updatedOldZone.zoneType)
      ..removeWhere((zone) => zone.zoneType == updatedNewZone.zoneType)
      ..add(updatedOldZone)
      ..add(updatedNewZone);

    final updatedState = currentState.copyWith(
      hand: updatedZones.singleWhere((zone) => zone.zoneType == ZoneType.hand),
      fieldZone: updatedZones.singleWhere((zone) => zone.zoneType == ZoneType.field),
      mainMonsterZone1: updatedZones.singleWhere((zone) => zone.zoneType == ZoneType.mainMonster1),
      mainMonsterZone2: updatedZones.singleWhere((zone) => zone.zoneType == ZoneType.mainMonster2),
      mainMonsterZone3: updatedZones.singleWhere((zone) => zone.zoneType == ZoneType.mainMonster3),
      graveyardZone: updatedZones.singleWhere((zone) => zone.zoneType == ZoneType.graveyard),
      banishedZone: updatedZones.singleWhere((zone) => zone.zoneType == ZoneType.banished),
      extraDeckZone: updatedZones.singleWhere((zone) => zone.zoneType == ZoneType.extraDeck),
      spellTrapZone1: updatedZones.singleWhere((zone) => zone.zoneType == ZoneType.spellTrap1),
      spellTrapZone2: updatedZones.singleWhere((zone) => zone.zoneType == ZoneType.spellTrap2),
      spellTrapZone3: updatedZones.singleWhere((zone) => zone.zoneType == ZoneType.spellTrap3),
      deckZone: updatedZones.singleWhere((zone) => zone.zoneType == ZoneType.deck),
    );

    _playerState.add(updatedState);
  }

  //endregion

  //region Deck actions

  Future<void> onDeckActionSelected(DeckAction deckAction) {
    logger.info(_tag, 'onDeckActionSelected($deckAction)');

    switch (deckAction) {
      case DeckAction.drawCard:
        return _router.showDrawCard(_drawCard);
      case DeckAction.showDeckList:
        return Future.sync(_showDeckList);
      case DeckAction.shuffleDeck:
        return Future.sync(_shuffleDeck);
      case DeckAction.surrender:
        return _surrender();
      default:
        return Future.value();
    }
  }

  void _showDeckList() {
    logger.verbose(_tag, '_showDeckList()');

    final currentState = _playerState.value;
    onMultiCardZonePressed(currentState.deckZone);
  }

  void _drawCard() {
    logger.verbose(_tag, '_drawCard()');

    final currentState = _playerState.value;
    final deck = currentState.deckZone.cards.toList();
    if (deck.isEmpty) {
      _snackBarService.showSnackBar('Deck is empty');
      return;
    }

    final drawnCard = deck.removeLast().copyWith(zoneType: ZoneType.hand);

    final updatedState = currentState.copyWith(
      deckZone: currentState.deckZone.copyWith(cards: deck),
      hand: currentState.hand.copyWith(cards: [...currentState.hand.cards, drawnCard]),
    );

    _playerState.add(updatedState);
  }

  void _shuffleDeck() {
    logger.verbose(_tag, '_shuffleDeck()');

    final currentState = _playerState.value;
    final shuffledDeck = currentState.deckZone.cards.toList()..shuffle();
    final updatedState = currentState.copyWith(
      deckZone: currentState.deckZone.copyWith(cards: shuffledDeck),
    );

    _playerState.add(updatedState);
  }

  Future<void> _surrender() async {
    logger.verbose(_tag, '_surrender()');

    final surrender = await _router.showDialog(const DialogConfig(
      title: 'Surrender',
      description: 'Are you sure you want to surrender?',
      positiveButton: 'Yes',
      negativeButton: 'Cancel',
    ));

    if (surrender ?? false) {
      _surrendered = true;
      _router.closeScreen();
    }
  }

  //endregion

  //region Card pressed events

  void onCardPressed(PlayCard playCard) {
    final dialog = _speedDuelDialogProvider.getCardDetailDialog(playCard);
    _dialogService.showCustomDialog<void>(dialog);
  }

  void onMultiCardZonePressed(Zone zone) {
    logger.info(_tag, 'onMultiCardZonePressed()');

    if (zone.cards.isEmpty) {
      return;
    }

    _speedDuelScreenEvent.add(SpeedDuelInspectCardPileEvent(zone));
  }

  //endregion

  //region Server events

  void _sendSummonEvent(YugiohCard yugiohCard, Zone newZone) {
    logger.verbose(_tag, '_sendSummonEvent($yugiohCard, $newZone)');

    _smartDuelServer.emitSpeedDuelEvent(
      SummonDuelEvent(
        SummonEvent(
          yugiohCardId: yugiohCard.id.toString(),
          zoneName: _enumHelper.convertToString(newZone.zoneType),
        ),
      ),
    );
  }

  void _sendRemoveCardEvent(Zone oldZone) {
    logger.verbose(_tag, '_sendRemoveCardEvent($oldZone)');

    _smartDuelServer.emitSpeedDuelEvent(
      RemoveCardDuelEvent(
        RemoveCardEvent(
          zoneName: _enumHelper.convertToString(oldZone.zoneType),
        ),
      ),
    );
  }

  //endregion

  //region Clean-up

  void _cancelPlayerStateSubscription() {
    logger.verbose(_tag, '_cancelPlayerStateSubscription()');

    _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
  }

  @override
  void dispose() {
    logger.info(_tag, 'dispose()');

    _smartDuelServer?.dispose();

    _cancelPlayerStateSubscription();

    _playerState?.close();
    _speedDuelState?.close();
    _speedDuelScreenEvent?.close();

    super.dispose();
  }

  //endregion
}
