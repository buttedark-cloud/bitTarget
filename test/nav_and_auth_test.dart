import 'package:bittarget/core/auth/auth_cubit.dart';
import 'package:bittarget/core/nav/nav_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthCubit: выход и вход', () async {
    final auth = AuthCubit();
    expect(auth.state, isTrue); // по умолчанию вошли

    auth.logout();
    expect(auth.state, isFalse);

    auth.login();
    expect(auth.state, isTrue);

    await auth.close();
  });

  test('NavCubit: переход на вкладку', () async {
    final nav = NavCubit();
    expect(nav.state, 0); // главная

    nav.goTo(1);
    expect(nav.state, 1); // торговля

    nav.goTo(3);
    expect(nav.state, 3); // профиль

    await nav.close();
  });
}
