// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:spendly/controllers/setup_controller.dart';
// import 'package:spendly/screens/setup_screen/country.dart';
// import 'package:spendly/screens/setup_screen/currency.dart';
// import 'package:spendly/screens/setup_screen/languages.dart';
// import 'package:spendly/screens/setup_screen/profile.dart';

// class SetupView extends StatelessWidget {
//   final SetupController controller = Get.put(SetupController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Setup Your Profile')),
//       body: Obx(
//         () => AnimatedSwitcher(
//           duration: Duration(milliseconds: 500),
//           child: getStepView(controller.currentStep.value),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: controller.nextStep,
//         child: Icon(Icons.arrow_forward),
//       ),
//     );
//   }

//   Widget getStepView(int step) {
//     switch (step) {
//       case 0:
//         return LanguageSelection();
//       case 1:
//         return CurrencySelection();
//       case 2:
//         return CountrySelection();
//       case 3:
//         return ProfilePictureUpload();
//       default:
//         return Center(child: Text('Unknown Step'));
//     }
//   }
// }
