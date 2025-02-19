import 'package:injectable/injectable.dart';
import 'package:smart_duel_disk/packages/core/core_data_manager/core_data_manager_interface/lib/core_data_manager_interface.dart';

@LazySingleton(as: DataManager)
class DataManagerImpl implements DataManager {
  final NewsDataManager _newsDataManager;
  final YugiohCardsDataManager _yugiohCardsDataManager;
  final DeckDataManager _deckDataManager;
  final DuelDataManager _duelDataManager;

  DataManagerImpl(
    this._newsDataManager,
    this._yugiohCardsDataManager,
    this._deckDataManager,
    this._duelDataManager,
  );

  //region News

  @override
  Future<Iterable<NewsItem>> getNewsItems() {
    return _newsDataManager.getNewsItems();
  }

  //endregion

  //region Yu-Gi-Oh! cards

  @override
  Future<Iterable<YugiohCard>> getSpeedDuelCards({bool includeSkillCards = false}) {
    return _yugiohCardsDataManager.getSpeedDuelCards(includeSkillCards: includeSkillCards);
  }

  //endregion

  //region Decks

  @override
  Future<Iterable<int>> getPreBuiltDeckCardIds(PreBuiltDeck deck) {
    return _deckDataManager.getPreBuiltDeckCardIds(deck);
  }

  //endregion

  //region Duel

  @override
  ConnectionInfo getConnectionInfo() {
    return _duelDataManager.getConnectionInfo();
  }

  @override
  Future<void> saveConnectionInfo(ConnectionInfo connectionInfo) {
    return _duelDataManager.saveConnectionInfo(connectionInfo);
  }

  //endregion
}
