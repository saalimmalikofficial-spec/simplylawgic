// // lib/screens/dashboard/dashboard_screen.dart
//
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import 'package:simplylawgic/screens/dashboard/profile/edit_profile_screen.dart';
// import 'package:simplylawgic/screens/auth/sign_in_screen.dart';
// import 'package:simplylawgic/services/api_service.dart';
// import 'package:simplylawgic/services/storage_service.dart';
// import 'package:simplylawgic/services/student_notifier.dart';
// import 'package:simplylawgic/models/student_model.dart';
// import 'package:simplylawgic/utils/app_colors.dart';
// import 'package:simplylawgic/widgets/app_drawer.dart';
//
// import '../user_progress_screen.dart';
// import 'tabs/home_tab.dart';
// import 'tabs/batches_tab.dart';
// import 'tabs/tests_tab.dart';
//
// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});
//
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen>
//     with WidgetsBindingObserver {
//   // ============================================================
//   // CURRENT TAB
//   // ============================================================
//
//   int _currentIndex = 0;
//
//   Student? _student;
//
//   final StorageService _storage = StorageService();
//   final ApiService _apiService = ApiService();
//
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   // ============================================================
//   // TAB NAVIGATORS
//   // ============================================================
//
//   late final List<GlobalKey<NavigatorState>> _navigatorKeys;
//
//   // ============================================================
//   // TAB HISTORY
//   // ============================================================
//
//   // Example:
//   // Home → Batches → Tests → Profile
//   //
//   // history:
//   // [0, 1, 3, 4]
//   //
//   // Back:
//   // [0, 1, 3]
//   // current = 3
//   //
//   final List<int> _tabHistory = [0];
//
//   // ============================================================
//   // BACK BUTTON
//   // ============================================================
//
//   DateTime? _lastBackPress;
//
//   // ============================================================
//   // NAVIGATION ITEMS
//   // ============================================================
//
//   static const List<_NavItemData> _navItems = [
//     _NavItemData(
//       icon: Icons.home_outlined,
//       activeIcon: Icons.home_rounded,
//       label: 'Home',
//     ),
//     _NavItemData(
//       icon: Icons.play_lesson_outlined,
//       activeIcon: Icons.play_lesson_rounded,
//       label: 'Batches',
//     ),
//     _NavItemData(
//       icon: Icons.dashboard_outlined,
//       activeIcon: Icons.dashboard_rounded,
//       label: 'Dashboard',
//     ),
//     _NavItemData(
//       icon: Icons.assignment_outlined,
//       activeIcon: Icons.assignment_rounded,
//       label: 'Tests',
//     ),
//     _NavItemData(
//       icon: Icons.person_outline_rounded,
//       activeIcon: Icons.person_rounded,
//       label: 'Profile',
//     ),
//   ];
//
//   // ============================================================
//   // INIT
//   // ============================================================
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addObserver(this);
//
//     StudentNotifier.instance.student.addListener(_onStudentChanged);
//
//     // Create one navigator for every tab.
//     //
//     // 0 = Home
//     // 1 = Batches
//     // 2 = Dashboard
//     // 3 = Tests
//     // 4 = Profile
//     //
//     _navigatorKeys = List.generate(
//       _navItems.length,
//           (_) => GlobalKey<NavigatorState>(),
//     );
//
//     _loadUserData();
//   }
//
//   // ============================================================
//   // STUDENT UPDATE
//   // ============================================================
//
//   void _onStudentChanged() {
//     if (!mounted) return;
//
//     final updated = StudentNotifier.instance.student.value;
//
//     if (updated != null) {
//       setState(() {
//         _student = updated;
//       });
//     }
//   }
//
//   // ============================================================
//   // DISPOSE
//   // ============================================================
//
//   @override
//   void dispose() {
//     StudentNotifier.instance.student.removeListener(_onStudentChanged);
//
//     WidgetsBinding.instance.removeObserver(this);
//
//     super.dispose();
//   }
//
//   // ============================================================
//   // PLATFORM BRIGHTNESS
//   // ============================================================
//
//   @override
//   void didChangePlatformBrightness() {
//     super.didChangePlatformBrightness();
//
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   // ============================================================
//   // TAB SWITCH
//   // ============================================================
//
//   void _switchTab(int index) {
//     if (index < 0 || index >= _navItems.length) {
//       return;
//     }
//
//     // Same tab clicked.
//     //
//     // We don't add duplicate history.
//     //
//     // Example:
//     // Home → Batches → Batches
//     //
//     // History stays:
//     // [0, 1]
//     //
//     if (_currentIndex == index) {
//       return;
//     }
//
//     setState(() {
//       _currentIndex = index;
//
//       // Remove previous occurrence.
//       _tabHistory.remove(index);
//
//       // Add selected tab at the end.
//       _tabHistory.add(index);
//     });
//   }
//
//   // ============================================================
//   // TAB NAVIGATOR
//   // ============================================================
//
//   Widget _buildTabNavigator(int index) {
//     return Navigator(
//       key: _navigatorKeys[index],
//
//       // ----------------------------------------------------------
//       // IMPORTANT
//       // ----------------------------------------------------------
//       //
//       // Every tab gets its own Navigator.
//       //
//       // Therefore:
//       //
//       // Home:
//       // Home → Detail → Detail2
//       //
//       // Batches:
//       // Batches → BatchDetail
//       //
//       // Tests:
//       // Tests → TestDetail
//       //
//       // All stacks remain alive because they are inside
//       // IndexedStack.
//       //
//       onGenerateRoute: (settings) {
//         Widget page;
//
//         switch (index) {
//         // ------------------------------------------------------
//         // HOME
//         // ------------------------------------------------------
//
//           case 0:
//             page = HomeTab(
//               scaffoldKey: _scaffoldKey,
//             );
//             break;
//
//         // ------------------------------------------------------
//         // BATCHES
//         // ------------------------------------------------------
//
//           case 1:
//             page = const BatchesTab();
//             break;
//
//         // ------------------------------------------------------
//         // DASHBOARD
//         // ------------------------------------------------------
//
//           case 2:
//             page = const UserProgressScreen();
//             break;
//
//         // ------------------------------------------------------
//         // TESTS
//         // ------------------------------------------------------
//
//           case 3:
//             page = const TestsTab();
//             break;
//
//         // ------------------------------------------------------
//         // PROFILE
//         // ------------------------------------------------------
//
//           case 4:
//             page = const EditProfileScreen();
//             break;
//
//         // ------------------------------------------------------
//         // FALLBACK
//         // ------------------------------------------------------
//
//           default:
//             page = HomeTab(
//               scaffoldKey: _scaffoldKey,
//             );
//         }
//
//         return MaterialPageRoute(
//           builder: (_) => page,
//           settings: settings,
//         );
//       },
//     );
//   }
//
//   // ============================================================
//   // BACK BUTTON HANDLER
//   // ============================================================
//
//   Future<bool> _handleBackPress() async {
//     // ============================================================
//     // CASE 1
//     // Current tab has internal navigation stack.
//     //
//     // Example:
//     //
//     // Home
//     //   ↓
//     // Details
//     //   ↓
//     // Documents
//     //
//     // Back:
//     //
//     // Documents → Details
//     // ============================================================
//
//     final currentNavigator = _navigatorKeys[_currentIndex].currentState;
//
//     if (currentNavigator != null && currentNavigator.canPop()) {
//       currentNavigator.pop();
//
//       return false;
//     }
//
//     // ============================================================
//     // CASE 2
//     // Current tab is at root.
//     //
//     // Go to previous selected tab.
//     //
//     // Example:
//     //
//     // Home → Batches → Tests → Profile
//     //
//     // Back:
//     //
//     // Profile → Tests
//     // ============================================================
//
//     if (_tabHistory.length > 1) {
//       setState(() {
//         // Remove current tab.
//         _tabHistory.removeLast();
//
//         // Previous tab becomes current.
//         _currentIndex = _tabHistory.last;
//       });
//
//       return false;
//     }
//
//     // ============================================================
//     // CASE 3
//     // Home root.
//     //
//     // First back:
//     // Show message.
//     //
//     // Second back within 2 seconds:
//     // Minimize app.
//     // ============================================================
//
//     final now = DateTime.now();
//
//     if (_lastBackPress == null ||
//         now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
//       _lastBackPress = now;
//
//       _showExitSnackBar();
//
//       return false;
//     }
//
//     // ============================================================
//     // CASE 4
//     // DOUBLE BACK
//     // ============================================================
//
//     await _minimizeApp();
//
//     return false;
//   }
//
//   // ============================================================
//   // EXIT SNACKBAR
//   // ============================================================
//
//   void _showExitSnackBar() {
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context).clearSnackBars();
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text(
//           'Press back again to exit',
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
//
//   // ============================================================
//   // MINIMIZE APP
//   // ============================================================
//
//   Future<void> _minimizeApp() async {
//     try {
//       if (Platform.isAndroid) {
//         await SystemNavigator.pop();
//       } else if (Platform.isIOS) {
//         await SystemChannels.platform.invokeMethod(
//           'SystemNavigator.pop',
//         );
//       }
//     } catch (e) {
//       debugPrint(
//         'Minimize error: $e',
//       );
//     }
//   }
//
//   // ============================================================
//   // LOAD USER DATA
//   // ============================================================
//
//   Future<void> _loadUserData() async {
//     try {
//       // ----------------------------------------------------------
//       // LOCAL STUDENT
//       // ----------------------------------------------------------
//
//       final local = await _storage.getStudent();
//
//       if (mounted && local != null) {
//         setState(() {
//           _student = local;
//         });
//
//         StudentNotifier.instance.update(local);
//       }
//
//       // ----------------------------------------------------------
//       // API STUDENT
//       // ----------------------------------------------------------
//
//       final data = await _apiService.getStudentAnalytics(
//         limit: 20,
//       );
//
//       final profileJson = data['profile'];
//
//       if (profileJson is Map<String, dynamic>) {
//         final student = Student.fromJson(profileJson);
//
//         await _storage.saveStudent(student);
//
//         if (mounted) {
//           setState(() {
//             _student = student;
//           });
//
//           StudentNotifier.instance.update(student);
//         }
//       }
//     } catch (e) {
//       debugPrint(
//         'Error loading user data: $e',
//       );
//     }
//   }
//
//   // ============================================================
//   // LOGOUT
//   // ============================================================
//
//   Future<void> _handleLogout() async {
//     try {
//       // ----------------------------------------------------------
//       // Clear local data
//       // ----------------------------------------------------------
//
//       await _storage.clearAll();
//
//       if (!mounted) return;
//
//       // ----------------------------------------------------------
//       // Clear all tab navigation stacks
//       // ----------------------------------------------------------
//
//       for (final key in _navigatorKeys) {
//         final navigator = key.currentState;
//
//         if (navigator != null) {
//           navigator.popUntil(
//                 (route) => route.isFirst,
//           );
//         }
//       }
//
//       // ----------------------------------------------------------
//       // Clear tab history
//       // ----------------------------------------------------------
//
//       _tabHistory
//         ..clear()
//         ..add(0);
//
//       _currentIndex = 0;
//
//       // ----------------------------------------------------------
//       // Clear complete application navigation stack
//       // ----------------------------------------------------------
//
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder: (_) => const SignInScreen(),
//         ),
//             (route) => false,
//       );
//     } catch (e) {
//       if (!mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Logout failed: $e',
//           ),
//           backgroundColor: AppColors.danger,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
//
//   // ============================================================
//   // BUILD
//   // ============================================================
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     final backgroundColor = isDark
//         ? const Color(0xFF0A0A0F)
//         : AppColors.background;
//
//     return PopScope(
//       // ----------------------------------------------------------
//       // We handle back manually.
//       // ----------------------------------------------------------
//
//       canPop: false,
//
//       onPopInvokedWithResult: (
//           didPop,
//           result,
//           ) async {
//         if (didPop) return;
//
//         await _handleBackPress();
//       },
//
//       child: Scaffold(
//         key: _scaffoldKey,
//
//         backgroundColor: backgroundColor,
//
//         // ========================================================
//         // DRAWER
//         // ========================================================
//
//         drawer: ValueListenableBuilder<Student?>(
//           valueListenable: StudentNotifier.instance.student,
//
//           builder: (
//               context,
//               student,
//               _,
//               ) {
//             return AppDrawer(
//               student: student,
//
//               onNavigate: (index) {
//                 // Close drawer first.
//                 if (_scaffoldKey.currentState?.isDrawerOpen == true) {
//                   Navigator.of(context).pop();
//                 }
//
//                 _switchTab(index);
//               },
//
//               onProfileUpdated: () {
//                 _loadUserData();
//               },
//
//               onLogout: _handleLogout,
//             );
//           },
//         ),
//
//         // ========================================================
//         // BODY
//         // ========================================================
//
//         body: AnnotatedRegion<SystemUiOverlayStyle>(
//           value: isDark
//               ? const SystemUiOverlayStyle(
//             statusBarColor: Colors.transparent,
//             statusBarIconBrightness: Brightness.light,
//             statusBarBrightness: Brightness.dark,
//           )
//               : const SystemUiOverlayStyle(
//             statusBarColor: Colors.transparent,
//             statusBarIconBrightness: Brightness.dark,
//             statusBarBrightness: Brightness.light,
//           ),
//
//           child: SafeArea(
//             bottom: false,
//
//             // ====================================================
//             // IMPORTANT
//             //
//             // IndexedStack keeps all tab Navigators alive.
//             // ====================================================
//
//             child: IndexedStack(
//               index: _currentIndex,
//
//               children: List.generate(
//                 _navItems.length,
//                     (index) {
//                   return _buildTabNavigator(index);
//                 },
//               ),
//             ),
//           ),
//         ),
//
//         // ========================================================
//         // BOTTOM NAVIGATION
//         // ========================================================
//
//         bottomNavigationBar: _buildPremiumBottomNav(isDark),
//       ),
//     );
//   }
//
//   // ============================================================
//   // PREMIUM BOTTOM NAV BAR
//   // ============================================================
//
//   Widget _buildPremiumBottomNav(
//       bool isDark,
//       ) {
//     final navBarColor = isDark ? const Color(0xFF12121A) : Colors.white;
//
//     final borderColor = isDark
//         ? Colors.white.withValues(alpha: 0.06)
//         : AppColors.border;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: navBarColor,
//
//         boxShadow: [
//           BoxShadow(
//             color: (isDark ? Colors.black : AppColors.textPrimary).withValues(
//               alpha: isDark ? 0.4 : 0.08,
//             ),
//             blurRadius: 24,
//             offset: const Offset(0, -8),
//           ),
//
//           BoxShadow(
//             color: AppColors.primary.withValues(
//               alpha: 0.06,
//             ),
//             blurRadius: 30,
//             offset: const Offset(0, -4),
//           ),
//         ],
//
//         border: Border(
//           top: BorderSide(
//             color: borderColor,
//             width: 0.6,
//           ),
//         ),
//       ),
//
//       child: SafeArea(
//         top: false,
//
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 8,
//             vertical: 8,
//           ),
//
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//
//             children: List.generate(
//               _navItems.length,
//                   (index) {
//                 final item = _navItems[index];
//
//                 final isSelected = _currentIndex == index;
//
//                 // --------------------------------------------------
//                 // DASHBOARD TAB (index 2) -> LOGO instead of
//                 // icon + label.
//                 // --------------------------------------------------
//
//                 if (index == 2) {
//                   return _buildLogoNavItem(
//                     isSelected: isSelected,
//                     isDark: isDark,
//                     onTap: () {
//                       _switchTab(index);
//                     },
//                   );
//                 }
//
//                 return _buildPremiumNavItem(
//                   item: item,
//                   isSelected: isSelected,
//                   isDark: isDark,
//                   onTap: () {
//                     _switchTab(index);
//                   },
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ============================================================
//   // LOGO NAV ITEM (Dashboard tab)
//   // ============================================================
//
//   // ============================================================
// // LOGO NAV ITEM — bilkul icons jaisa, no effect, no gradient
// // ============================================================
//   Widget _buildLogoNavItem({
//     required bool isSelected,
//     required bool isDark,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         behavior: HitTestBehavior.opaque,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // 🔥 YAHI CHANGE — logo ko upar shift karo
//               Transform.translate(
//                 offset: const Offset(0, -4),   // 👈 UPAR shift (negative = upar)
//                 child: SizedBox(
//                   height: 36,
//                   child: Center(
//                     child: Image.asset(
//                       'assets/images/logo_transparent.png',
//                       height: 24,
//                       width: 24,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Dashboard',
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: 10.5,
//                   fontWeight: FontWeight.w500,
//                   color: isDark
//                       ? Colors.white.withValues(alpha: 0.5)
//                       : AppColors.textSecondary,
//                   letterSpacing: 0.2,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ============================================================
//   // NAV ITEM
//   // ============================================================
//
//   Widget _buildPremiumNavItem({
//     required _NavItemData item,
//     required bool isSelected,
//     required bool isDark,
//     required VoidCallback onTap,
//   })
//   {
//     final activeColor = AppColors.primary;
//
//     final inactiveColor = isDark
//         ? Colors.white.withValues(alpha: 0.5)
//         : AppColors.textSecondary;
//
//     return Expanded(
//       child: Material(
//         color: Colors.transparent,
//
//         child: InkWell(
//           onTap: onTap,
//
//           borderRadius: BorderRadius.circular(16),
//
//           splashColor: activeColor.withValues(
//             alpha: 0.08,
//           ),
//
//           highlightColor: activeColor.withValues(
//             alpha: 0.04,
//           ),
//
//           child: AnimatedContainer(
//             duration: const Duration(
//               milliseconds: 280,
//             ),
//
//             curve: Curves.easeOutCubic,
//
//             padding: const EdgeInsets.symmetric(
//               vertical: 8,
//             ),
//
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//
//               children: [
//                 // ==================================================
//                 // ICON
//                 // ==================================================
//
//                 AnimatedContainer(
//                   duration: const Duration(
//                     milliseconds: 280,
//                   ),
//
//                   curve: Curves.easeOutCubic,
//
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 14,
//                     vertical: 6,
//                   ),
//
//                   decoration: BoxDecoration(
//                     gradient: isSelected
//                         ? LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         activeColor.withValues(
//                           alpha: 0.18,
//                         ),
//                         activeColor.withValues(
//                           alpha: 0.08,
//                         ),
//                       ],
//                     )
//                         : null,
//
//                     borderRadius: BorderRadius.circular(
//                       20,
//                     ),
//
//                     boxShadow: isSelected
//                         ? [
//                       BoxShadow(
//                         color: activeColor.withValues(
//                           alpha: 0.15,
//                         ),
//                         blurRadius: 12,
//                         offset: const Offset(
//                           0,
//                           4,
//                         ),
//                       ),
//                     ]
//                         : null,
//                   ),
//
//                   child: AnimatedSwitcher(
//                     duration: const Duration(
//                       milliseconds: 220,
//                     ),
//
//                     transitionBuilder: (
//                         child,
//                         animation,
//                         ) {
//                       return ScaleTransition(
//                         scale: animation,
//
//                         child: FadeTransition(
//                           opacity: animation,
//                           child: child,
//                         ),
//                       );
//                     },
//
//                     child: Icon(
//                       isSelected ? item.activeIcon : item.icon,
//
//                       key: ValueKey(
//                         isSelected,
//                       ),
//
//                       color: isSelected ? activeColor : inactiveColor,
//
//                       size: isSelected ? 24 : 22,
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(
//                   height: 4,
//                 ),
//
//                 // ==================================================
//                 // LABEL
//                 // ==================================================
//
//                 AnimatedDefaultTextStyle(
//                   duration: const Duration(
//                     milliseconds: 220,
//                   ),
//
//                   style: TextStyle(
//                     fontSize: 10.5,
//
//                     fontWeight: isSelected
//                         ? FontWeight.w700
//                         : FontWeight.w500,
//
//                     color: isSelected ? activeColor : inactiveColor,
//
//                     letterSpacing: 0.2,
//                   ),
//
//                   child: Text(
//                     item.label,
//
//                     maxLines: 1,
//
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ================================================================
// // NAV ITEM DATA
// // ================================================================
//
// class _NavItemData {
//   final IconData icon;
//   final IconData activeIcon;
//   final String label;
//
//   const _NavItemData({
//     required this.icon,
//     required this.activeIcon,
//     required this.label,
//   });
// }