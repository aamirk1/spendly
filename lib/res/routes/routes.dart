import 'package:get/get.dart';
import 'package:spendly/res/routes/routes_name.dart';
import 'package:spendly/screens/add_income_and_expense/add_expense.dart';
import 'package:spendly/screens/add_income_and_expense/add_income.dart';
import 'package:spendly/screens/add_income_and_expense/view_all_expense_and_income/view_all_expense.dart';
import 'package:spendly/screens/add_income_and_expense/view_all_expense_and_income/view_all_income.dart';
import 'package:spendly/screens/auth/sign_in_screen.dart';
import 'package:spendly/screens/auth/sign_up_screen.dart';
import 'package:spendly/screens/auth/welcome_screen.dart';
import 'package:spendly/screens/home/views/home_screen.dart';

class AppRoutes {
  static appRoutes() => [
        // GetPage(
        //     name: RoutesName.splashScreen,
        //     page: () => const SplashScreen(),
        //     transitionDuration: const Duration(milliseconds: 250),
        //     transition: Transition.leftToRight),
        GetPage(
            name: RoutesName.welcomeView,
            page: () => const WelcomeScreen(),
            transitionDuration: const Duration(milliseconds: 250),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RoutesName.loginView,
            page: () => SignInScreen(),
            transitionDuration: const Duration(milliseconds: 250),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RoutesName.signupView,
            page: () => SignUpScreen(),
            transitionDuration: const Duration(milliseconds: 250),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RoutesName.homeView,
            page: () => HomeScreen(),
            transitionDuration: const Duration(milliseconds: 250),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RoutesName.expenseView,
            page: () => AddExpense(),
            transitionDuration: const Duration(milliseconds: 250),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RoutesName.incomeView,
            page: () => AddIncome(),
            transitionDuration: const Duration(milliseconds: 250),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RoutesName.viewAllExpenses,
            page: () => ViewAllExpense(),
            transitionDuration: const Duration(milliseconds: 250),
            transition: Transition.leftToRightWithFade),
        GetPage(
            name: RoutesName.viewAllIncome,
            page: () => ViewAllIncome(),
            transitionDuration: const Duration(milliseconds: 250),
            transition: Transition.leftToRightWithFade),
      ];
}
