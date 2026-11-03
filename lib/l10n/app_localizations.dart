import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance (USD)'**
  String get totalBalance;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @trade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get trade;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @massiveGrowth.
  ///
  /// In en, this message translates to:
  /// **'MASSIVE GROWTH TODAY'**
  String get massiveGrowth;

  /// No description provided for @liveUpdates.
  ///
  /// In en, this message translates to:
  /// **'Live Updates'**
  String get liveUpdates;

  /// No description provided for @marketOverview.
  ///
  /// In en, this message translates to:
  /// **'Market Overview'**
  String get marketOverview;

  /// No description provided for @vol24h.
  ///
  /// In en, this message translates to:
  /// **'Vol 24h'**
  String get vol24h;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @limitOrder.
  ///
  /// In en, this message translates to:
  /// **'Limit Order'**
  String get limitOrder;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price (USD)'**
  String get price;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @selectAsset.
  ///
  /// In en, this message translates to:
  /// **'Select Asset'**
  String get selectAsset;

  /// No description provided for @realtimeBinance.
  ///
  /// In en, this message translates to:
  /// **'Real-time Binance data'**
  String get realtimeBinance;

  /// No description provided for @marketLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load market'**
  String get marketLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @tradeScreen.
  ///
  /// In en, this message translates to:
  /// **'Trade Screen'**
  String get tradeScreen;

  /// No description provided for @walletScreen.
  ///
  /// In en, this message translates to:
  /// **'Wallet Screen'**
  String get walletScreen;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get todayLabel;

  /// No description provided for @high24h.
  ///
  /// In en, this message translates to:
  /// **'24h High'**
  String get high24h;

  /// No description provided for @low24h.
  ///
  /// In en, this message translates to:
  /// **'24h Low'**
  String get low24h;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @priceUsdt.
  ///
  /// In en, this message translates to:
  /// **'Price (USDT)'**
  String get priceUsdt;

  /// No description provided for @orderBookPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get orderBookPrice;

  /// No description provided for @orderBookSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get orderBookSize;

  /// No description provided for @orderInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price and amount'**
  String get orderInvalid;

  /// No description provided for @orderPriceFar.
  ///
  /// In en, this message translates to:
  /// **'Price is more than 5% away from the market'**
  String get orderPriceFar;

  /// No description provided for @orderNoFunds.
  ///
  /// In en, this message translates to:
  /// **'Not enough funds'**
  String get orderNoFunds;

  /// No description provided for @orderFilled.
  ///
  /// In en, this message translates to:
  /// **'Order filled'**
  String get orderFilled;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Asset Wallet'**
  String get walletTitle;

  /// No description provided for @estimatedNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Estimated Net Worth'**
  String get estimatedNetWorth;

  /// No description provided for @profit24h.
  ///
  /// In en, this message translates to:
  /// **'24h Profit'**
  String get profit24h;

  /// No description provided for @assetAllocation.
  ///
  /// In en, this message translates to:
  /// **'Asset Allocation'**
  String get assetAllocation;

  /// No description provided for @assetsWord.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assetsWord;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @networkFee.
  ///
  /// In en, this message translates to:
  /// **'Network Fee'**
  String get networkFee;

  /// No description provided for @txStaking.
  ///
  /// In en, this message translates to:
  /// **'Staking Rewards'**
  String get txStaking;

  /// No description provided for @convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @walletAddress.
  ///
  /// In en, this message translates to:
  /// **'Wallet address'**
  String get walletAddress;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @invalidAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid wallet address'**
  String get invalidAddress;

  /// No description provided for @operationDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get operationDone;

  /// No description provided for @searchCoin.
  ///
  /// In en, this message translates to:
  /// **'Search coin'**
  String get searchCoin;

  /// No description provided for @chartSettings.
  ///
  /// In en, this message translates to:
  /// **'Chart settings'**
  String get chartSettings;

  /// No description provided for @showPoints.
  ///
  /// In en, this message translates to:
  /// **'Show points'**
  String get showPoints;

  /// No description provided for @showMa.
  ///
  /// In en, this message translates to:
  /// **'Moving average (MA)'**
  String get showMa;

  /// No description provided for @orderType.
  ///
  /// In en, this message translates to:
  /// **'Order type'**
  String get orderType;

  /// No description provided for @marketOrder.
  ///
  /// In en, this message translates to:
  /// **'Market Order'**
  String get marketOrder;

  /// No description provided for @marketPrice.
  ///
  /// In en, this message translates to:
  /// **'Market price'**
  String get marketPrice;

  /// No description provided for @limitHint.
  ///
  /// In en, this message translates to:
  /// **'You set the price'**
  String get limitHint;

  /// No description provided for @marketHint.
  ///
  /// In en, this message translates to:
  /// **'Instantly at the market price'**
  String get marketHint;

  /// No description provided for @limitDesc.
  ///
  /// In en, this message translates to:
  /// **'You set the price yourself. In this demo it fills instantly if the price is within 5% of the market.'**
  String get limitDesc;

  /// No description provided for @marketDesc.
  ///
  /// In en, this message translates to:
  /// **'Fills instantly at the current market price.'**
  String get marketDesc;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @loggedOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You are signed out. Log in to get back to the app.'**
  String get loggedOutMessage;

  /// No description provided for @chartLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the chart. Showing the previous data.'**
  String get chartLoadError;

  /// No description provided for @reconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get reconnecting;

  /// No description provided for @bookUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Order book is unavailable'**
  String get bookUnavailable;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errNetwork;

  /// No description provided for @errTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond'**
  String get errTimeout;

  /// No description provided for @errServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Try again later'**
  String get errServer;

  /// No description provided for @errRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a moment'**
  String get errRateLimited;

  /// No description provided for @errUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errUnknown;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No connection. Showing the latest prices.'**
  String get offlineBanner;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
