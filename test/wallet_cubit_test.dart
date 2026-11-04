import 'package:bittarget/features/wallet/cubit/wallet_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletCubit', () {
    late WalletCubit wallet;

    setUp(() => wallet = WalletCubit());
    tearDown(() => wallet.close());

    test('стартовый баланс', () {
      expect(wallet.state.usdBalance, 84920.50);
      expect(wallet.state.getAssetBalance('BTC'), closeTo(1.284502, 1e-9));
      expect(wallet.state.getAssetBalance('ADA'), 0);
      expect(wallet.state.transactions.length, 2);
    });

    group('пополнение', () {
      test('долларами', () {
        expect(wallet.deposit('USD', 1000, usdPrice: 1), isTrue);
        expect(wallet.state.usdBalance, closeTo(85920.50, 1e-9));

        final tx = wallet.state.transactions.first;
        expect(tx.type, TxType.depositUsd);
        expect(tx.amount, 1000);
        expect(wallet.state.transactions.length, 3);
      });

      test('монетой', () {
        expect(wallet.deposit('ETH', 2, usdPrice: 2000), isTrue);
        expect(wallet.state.getAssetBalance('ETH'), closeTo(7.2, 1e-9));

        final tx = wallet.state.transactions.first;
        expect(tx.type, TxType.depositCrypto);
        expect(tx.usd, closeTo(4000, 1e-6));
      });

      test('нулевая и отрицательная сумма отклоняются', () {
        expect(wallet.deposit('USD', 0, usdPrice: 1), isFalse);
        expect(wallet.deposit('USD', -50, usdPrice: 1), isFalse);
        expect(wallet.deposit('BTC', 0, usdPrice: 60000), isFalse);
        expect(wallet.state.usdBalance, 84920.50);
        expect(wallet.state.transactions.length, 2);
      });
    });

    group('вывод долларов', () {
      test('успешно', () {
        expect(wallet.withdraw(100), isTrue);
        expect(wallet.state.usdBalance, closeTo(84820.50, 1e-9));
        expect(wallet.state.transactions.first.type, TxType.withdrawUsd);
      });

      test('больше, чем на счёте, нельзя', () {
        expect(wallet.withdraw(1000000), isFalse);
        expect(wallet.state.usdBalance, 84920.50);
        expect(wallet.state.transactions.length, 2);
      });
    });

    group('покупка', () {
      test('списывает доллары и добавляет монеты', () {
        expect(wallet.buyAsset('BTC', 0.1, 66120), isTrue);
        expect(wallet.state.usdBalance, closeTo(78308.50, 1e-9)); // 84920.50 - 6612.00
        expect(wallet.state.getAssetBalance('BTC'), closeTo(1.384502, 1e-9));

        final tx = wallet.state.transactions.first;
        expect(tx.type, TxType.buy);
        expect(tx.symbol, 'BTC');
        expect(tx.usd, closeTo(6612.00, 1e-9));
      });

      test('без денег не покупает и ничего не меняет', () {
        expect(wallet.buyAsset('BTC', 10, 66000), isFalse); // нужно $660 000
        expect(wallet.state.usdBalance, 84920.50);
        expect(wallet.state.getAssetBalance('BTC'), closeTo(1.284502, 1e-9));
        expect(wallet.state.transactions.length, 2);
      });

      test('крохотная покупка стоит минимум 1 цент (нельзя получить монеты бесплатно)', () {
        expect(wallet.buyAsset('POL', 0.000001, 0.09), isTrue);
        expect(wallet.state.usdBalance, closeTo(84920.49, 1e-9));
        expect(wallet.state.getAssetBalance('POL'), closeTo(0.000001, 1e-12));
      });
    });

    group('продажа', () {
      test('списывает монеты и добавляет доллары', () {
        expect(wallet.sellAsset('BTC', 0.5, 70000), isTrue);
        expect(wallet.state.usdBalance, closeTo(119920.50, 1e-9)); // 84920.50 + 35000
        expect(wallet.state.getAssetBalance('BTC'), closeTo(0.784502, 1e-9));
        expect(wallet.state.transactions.first.type, TxType.sell);
      });

      test('больше, чем есть, и чужую монету продать нельзя', () {
        expect(wallet.sellAsset('BTC', 5, 70000), isFalse);
        expect(wallet.sellAsset('ADA', 1, 0.5), isFalse);
        expect(wallet.state.usdBalance, 84920.50);
        expect(wallet.state.transactions.length, 2);
      });

      test('продавец получает не больше цены (округление вниз)', () {
        // 0.000001 BTC по $66 000 стоит 6,6 цента: получаем 6 центов
        expect(wallet.sellAsset('BTC', 0.000001, 66000), isTrue);
        expect(wallet.state.usdBalance, closeTo(84920.56, 1e-9));
      });
    });

    group('перевод монеты наружу', () {
      test('списывает монеты и комиссию 1 доллар', () {
        expect(wallet.transfer('BTC', 0.1, usdPrice: 66000), isTrue);
        expect(wallet.state.getAssetBalance('BTC'), closeTo(1.184502, 1e-9));
        expect(wallet.state.usdBalance, closeTo(84919.50, 1e-9));

        final tx = wallet.state.transactions.first;
        expect(tx.type, TxType.transfer);
        expect(tx.fee, closeTo(1.0, 1e-9));
      });

      test('нельзя перевести больше, чем есть', () {
        expect(wallet.transfer('BTC', 5, usdPrice: 66000), isFalse);
        expect(wallet.state.getAssetBalance('BTC'), closeTo(1.284502, 1e-9));
      });

      test('без денег на комиссию перевод невозможен', () {
        wallet.withdraw(84920.50); // на счёте $0
        final before = wallet.state.transactions.length;

        expect(wallet.transfer('BTC', 0.1, usdPrice: 66000), isFalse);
        expect(wallet.state.getAssetBalance('BTC'), closeTo(1.284502, 1e-9));
        expect(wallet.state.transactions.length, before);
      });
    });

    group('история и точность', () {
      test('новые операции встают наверх', () {
        wallet.deposit('USD', 10, usdPrice: 1);
        wallet.withdraw(5);
        expect(wallet.state.transactions[0].type, TxType.withdrawUsd);
        expect(wallet.state.transactions[1].type, TxType.depositUsd);
      });

      test('история хранит не больше 100 записей', () {
        for (var i = 0; i < 150; i++) {
          wallet.deposit('USD', 1, usdPrice: 1);
        }
        expect(wallet.state.transactions.length, 100);
        expect(wallet.state.transactions.first.type, TxType.depositUsd);
      });

      test('десять раз по 0,1 доллара ровно один доллар (дробные числа не копят ошибку)', () {
        for (var i = 0; i < 10; i++) {
          wallet.deposit('USD', 0.1, usdPrice: 1);
        }
        expect(wallet.state.usdBalance, 84921.50);
      });
    });
  });
}
