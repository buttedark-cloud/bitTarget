import 'package:flutter_bloc/flutter_bloc.dart';

/// Номер открытой вкладки: 0 Главная, 1 Торговля, 2 Кошелёк, 3 Профиль.

class NavCubit extends Cubit<int> {
  NavCubit() : super(0);

  void goTo(int index) => emit(index);
}
