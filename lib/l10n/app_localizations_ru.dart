// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get welcomeBack => 'С возвращением,';

  @override
  String get totalBalance => 'Общий баланс (USD)';

  @override
  String get deposit => 'Депозит';

  @override
  String get withdraw => 'Вывод';

  @override
  String get trade => 'Торговля';

  @override
  String get transfer => 'Перевод';

  @override
  String get massiveGrowth => 'ЛИДЕРЫ РОСТА СЕГОДНЯ';

  @override
  String get liveUpdates => 'Обновления';

  @override
  String get marketOverview => 'Обзор рынка';

  @override
  String get vol24h => 'Объем 24ч';

  @override
  String get home => 'Главная';

  @override
  String get wallet => 'Кошелек';

  @override
  String get profile => 'Профиль';

  @override
  String get buy => 'Купить';

  @override
  String get sell => 'Продать';

  @override
  String get limitOrder => 'Лимитный ордер';

  @override
  String get price => 'Цена (USD)';

  @override
  String get amount => 'Количество';

  @override
  String get selectAsset => 'Выберите актив';

  @override
  String get realtimeBinance => 'Данные Binance в реальном времени';

  @override
  String get marketLoadError => 'Не удалось загрузить рынок';

  @override
  String get retry => 'Повторить';

  @override
  String get tradeScreen => 'Экран торговли';

  @override
  String get walletScreen => 'Экран кошелька';

  @override
  String get yourProfile => 'Ваш профиль';

  @override
  String get todayLabel => 'за 24 часа';
}
