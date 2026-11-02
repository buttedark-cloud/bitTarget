import 'package:bittarget/core/auth/auth_cubit.dart';
import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/widgets/base_screen_layout.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loggedIn = context.watch<AuthCubit>().state;
    final accent = loggedIn ? AppColors.neonGreen : AppColors.textSecondary;
    const fade = Duration(milliseconds: 300);

    return BaseScreenLayout(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Аватар и имя тускнеют, когда пользователь вышел
              AnimatedOpacity(
                opacity: loggedIn ? 1 : 0.4,
                duration: fade,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        AnimatedContainer(
                          duration: fade,
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.cardBackground,
                            border: Border.all(color: accent, width: 2),
                            boxShadow: loggedIn
                                ? [BoxShadow(color: AppColors.neonGreen.withValues(alpha: 0.25), blurRadius: 24)]
                                : const [],
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white70, size: 48),
                        ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: AnimatedContainer(
                            duration: fade,
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Alex Trade', style: AppTypography.titleLarge),
                        const SizedBox(width: 6),
                        Icon(Icons.verified_rounded, color: accent, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Статус
              AnimatedContainer(
                duration: fade,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  loggedIn ? l10n.online : l10n.offline,
                  style: AppTypography.caption.copyWith(color: accent, fontWeight: FontWeight.w700),
                ),
              ),
              // Сообщение появляется только после выхода
              AnimatedSize(
                duration: fade,
                curve: Curves.easeOut,
                child: loggedIn
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          l10n.loggedOutMessage,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(fontSize: 12),
                        ),
                      ),
              ),
              const SizedBox(height: 32),
              // Кнопка плавно меняется между «Выйти» и «Войти»
              AnimatedSwitcher(
                duration: fade,
                child: PressEffect(
                  key: ValueKey(loggedIn),
                  scale: 0.97,
                  onTap: () {
                    final auth = context.read<AuthCubit>();
                    loggedIn ? auth.logout() : auth.login();
                  },
                  child: loggedIn ? _logoutButton(l10n) : _loginButton(l10n),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.neonRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neonRed.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout_rounded, color: AppColors.neonRed, size: 20),
          const SizedBox(width: 8),
          Text(
            l10n.logOut,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.neonRed, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _loginButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.neonGreen,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.neonGreen.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.login_rounded, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          Text(
            l10n.logIn,
            style: AppTypography.bodyLarge.copyWith(color: Colors.black, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
