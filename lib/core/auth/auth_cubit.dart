import 'package:flutter_bloc/flutter_bloc.dart';

/// true: пользователь вошёл, false: вышел
class AuthCubit extends Cubit<bool> {
  AuthCubit() : super(true);

  void logout() => emit(false);

  void login() => emit(true);
}
