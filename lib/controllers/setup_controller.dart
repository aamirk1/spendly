import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendly/res/routes/routes_name.dart';

class SetupController extends GetxController {
  var currentStep = 0.obs;
  var selectedLanguage = ''.obs;
  var selectedCurrency = ''.obs;
  var selectedCountry = ''.obs;
  var profileImage = Rxn<XFile>();
  var isFaceDetected = false.obs;

  Future<void> completeSetup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSetupComplete', true);
    Get.offAllNamed(RoutesName.homeView);
  }

  void nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++;
    } else {
      completeSetup();
    }  
  }

  void pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = image;
      detectFace(image);
    }
  }

  void detectFace(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final faceDetector = GoogleMlKit.vision.faceDetector();
    final faces = await faceDetector.processImage(inputImage);
    isFaceDetected.value = faces.isNotEmpty;
    await faceDetector.close();
  }
}