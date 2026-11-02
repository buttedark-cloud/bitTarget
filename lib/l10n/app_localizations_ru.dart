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

  @override
  String get high24h => 'Макс. за 24ч';

  @override
  String get low24h => 'Минимум 24ч';

  @override
  String get total => 'Итого';

  @override
  String get priceUsdt => 'Цена (USDT)';

  @override
  String get orderBookPrice => 'Цена';

  @override
  String get orderBookSize => 'Объём';

  @override
  String get orderInvalid => 'Введите корректную цену и количество';

  @override
  String get orderPriceFar => 'Цена отличается от рыночной больше чем на 5%';

  @override
  String get orderNoFunds => 'Недостаточно средств';

  @override
  String get orderFilled => 'Ордер исполнен';

  @override
  String get walletTitle => 'Мой кошелёк';

  @override
  String get estimatedNetWorth => 'Оценка капитала';

  @override
  String get profit24h => 'Прибыль за 24ч';

  @override
  String get assetAllocation => 'Структура портфеля';

  @override
  String get assetsWord => 'активов';

  @override
  String get other => 'Прочее';

  @override
  String get recentTransactions => 'Последние операции';

  @override
  String get allTransactions => 'Все операции';

  @override
  String get viewAll => 'Все';

  @override
  String get noTransactions => 'Операций пока нет';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get completed => 'Выполнено';

  @override
  String get networkFee => 'Комиссия сети';

  @override
  String get txStaking => 'Награды за стейкинг';

  @override
  String get convert => 'Обмен';

  @override
  String get available => 'Доступно';

  @override
  String get walletAddress => 'Адрес кошелька';

  @override
  String get invalidAmount => 'Введите корректную сумму';

  @override
  String get invalidAddress => 'Введите корректный адрес кошелька';

  @override
  String get operationDone => 'Готово';

  @override
  String get searchCoin => 'Поиск монеты';

  @override
  String get chartSettings => 'Настройки графика';

  @override
  String get showPoints => 'Показывать точки';

  @override
  String get showMa => 'Скользящая средняя (MA)';

  @override
  String get orderType => 'Тип ордера';

  @override
  String get marketOrder => 'Рыночный ордер';

  @override
  String get marketPrice => 'Рыночная цена';

  @override
  String get limitHint => 'Цену задаёте вы';

  @override
  String get marketHint => 'Сразу по рыночной цене';

  @override
  String get limitDesc =>
      'Вы сами задаёте цену. В этой демо-версии ордер исполняется сразу, если цена не дальше 5% от рыночной.';

  @override
  String get marketDesc => 'Исполняется сразу по текущей рыночной цене.';

  @override
  String get logOut => 'Выйти из аккаунта';

  @override
  String get logIn => 'Войти в аккаунт';

  @override
  String get online => 'В сети';

  @override
  String get offline => 'Не в сети';

  @override
  String get loggedOutMessage =>
      'Вы вышли из аккаунта. Войдите, чтобы вернуться в приложение.';

  @override
  String get chartLoadError =>
      'Не удалось загрузить график. Показаны прежние данные.';

  @override
  String get reconnecting => 'Переподключение…';

  @override
  String get bookUnavailable => 'Стакан недоступен';
}
