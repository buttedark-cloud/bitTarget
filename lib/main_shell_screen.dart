import 'package:bittarget/core/auth/auth_cubit.dart';
import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/locale/locale_cubit.dart';
import 'package:bittarget/core/nav/nav_cubit.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/features/home/presentation/screens/home_screen.dart';
import 'package:bittarget/features/profile/presentation/screens/profile_screen.dart';
import 'package:bittarget/features/trade/presentation/screens/trade_screen.dart';
import 'package:bittarget/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int _profileIndex = 3;

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Листаем PageView к нужной странице (если мы уже там, ничего не делаем)
  void _showPage(int index) {
    if (!_pageController.hasClients) return;
    final current = (_pageController.page ?? 0).round();
    if (current == index) return;

    if ((current - index).abs() > 1) {
      // Не проматываем промежуточные страницы, чтобы не строить их зря
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = context.watch<NavCubit>().state;
    final loggedIn = context.watch<AuthCubit>().state;

    final List<Widget> screens = [
      _KeepAlive(
        child: HomeScreen(
          onLanguageToggle: () => context.read<LocaleCubit>().toggle(),
          onProfileTap: () => context.read<NavCubit>().goTo(_profileIndex),
        ),
      ),
      _KeepAlive(child: TradeScreen(isActive: currentIndex == 1)),
      const _KeepAlive(child: WalletScreen()),
      const _KeepAlive(child: ProfileScreen()),
    ];

    return MultiBlocListener(
      listeners: [
        // Кто-то попросил открыть вкладку (меню, кнопка Trade, аватар)
        BlocListener<NavCubit, int>(
          listener: (context, index) {
            // Пока пользователь вышел, никуда, кроме профиля, пускать нельзя
            if (!context.read<AuthCubit>().state && index != _profileIndex) {
              context.read<NavCubit>().goTo(_profileIndex);
              return;
            }
            _showPage(index);
          },
        ),
        // Вышли из аккаунта: переносим на профиль
        BlocListener<AuthCubit, bool>(
          listener: (context, isLoggedIn) {
            if (!isLoggedIn) context.read<NavCubit>().goTo(_profileIndex);
          },
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF000000), Color(0xFF121214), Color(0xFF1A1A1E)],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: PageView(
                    controller: _pageController,
                    // Пока пользователь вышел, свайп отключён
                    physics: loggedIn ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) => context.read<NavCubit>().goTo(index),
                    children: screens,
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 5, 5, 5),
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(top: BorderSide(color: Color.fromARGB(255, 72, 77, 73), width: 1.0)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(Icons.home_rounded, l10n.home, 0, currentIndex, loggedIn),
                        _buildNavItem(Icons.bar_chart_rounded, l10n.trade, 1, currentIndex, loggedIn),
                        _buildNavItem(Icons.account_balance_wallet_rounded, l10n.wallet, 2, currentIndex, loggedIn),
                        _buildNavItem(Icons.person_rounded, l10n.profile, 3, currentIndex, loggedIn),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int currentIndex, bool loggedIn) {
    final isActive = currentIndex == index;
    // Пока пользователь вышел, доступен только профиль: остальное тускнеет и не нажимается
    final locked = !loggedIn && index != _profileIndex;

    return Opacity(
      opacity: locked ? 0.3 : 1,
      child: IgnorePointer(
        ignoring: locked,
        child: PressEffect(
          scale: 0.9,
          onTap: () => context.read<NavCubit>().goTo(index),
          child: SizedBox(
            width: 65,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isActive ? AppColors.neonGreen : AppColors.textSecondary, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: isActive ? AppColors.neonGreen : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Не даёт PageView уничтожать страницу при свайпе.
/// Благодаря этому экраны не создаются заново при каждом переходе.
class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
