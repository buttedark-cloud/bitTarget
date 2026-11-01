import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/locale/locale_cubit.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/widgets/base_screen_layout.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/features/home/presentation/screens/home_screen.dart';
import 'package:bittarget/features/trade/presentation/screens/trade_screen.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bittarget/features/wallet/presentation/screens/wallet_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
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

  void _goToPage(int index) {
    if (index == _currentIndex) return;
    final distance = (index - _currentIndex).abs();
    setState(() => _currentIndex = index);

    if (distance > 1) {
      // Не проматываем промежуточные страницы, чтобы не строить их зря
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  // Заглушка: BaseScreenLayout нужен только ей, у Home и Trade он уже внутри
  Widget _stub(String text) {
    return BaseScreenLayout(
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<Widget> screens = [
      _KeepAlive(
        child: HomeScreen(onLanguageToggle: () => context.read<LocaleCubit>().toggle(), onProfileTap: () => _goToPage(3)),
      ),
      _KeepAlive(child: TradeScreen(isActive: _currentIndex == 1)),
      const _KeepAlive(child: WalletScreen()),
      _KeepAlive(child: _stub(l10n.yourProfile)),
    ];

    return Scaffold(
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
                  onPageChanged: (index) => setState(() => _currentIndex = index),
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
                      _buildNavItem(Icons.home_rounded, l10n.home, 0),
                      _buildNavItem(Icons.bar_chart_rounded, l10n.trade, 1),
                      _buildNavItem(Icons.account_balance_wallet_rounded, l10n.wallet, 2),
                      _buildNavItem(Icons.person_rounded, l10n.profile, 3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return PressEffect(
      scale: 0.9,
      onTap: () => _goToPage(index),
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
    );
  }
}

/// Не даёт PageView уничтожать страницу при свайпе.
/// Благодаря этому TradeCubit создаётся один раз.
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
