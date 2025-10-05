import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendify/main.dart';
import 'package:spendify/widgets/bottom_navigation.dart';
import 'package:spendify/widgets/toast/custom_toast.dart';
import 'package:spendify/controller/home_controller/home_controller.dart';
import 'package:spendify/controller/wallet_controller/wallet_controller.dart';
import 'package:spendify/services/bill_notification_service.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isHidden = true.obs;
  var emailC = TextEditingController();
  var passwordC = TextEditingController();

  @override
  void dispose() {
    emailC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  Future<bool?> login() async {
    if (emailC.text.isNotEmpty && passwordC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        // Clear any existing controllers
        if (Get.isRegistered<HomeController>()) {
          Get.delete<HomeController>(force: true);
        }
        if (Get.isRegistered<TransactionController>()) {
          Get.delete<TransactionController>(force: true);
        }

        // Sign in
        final response = await supabaseClient.auth
            .signInWithPassword(email: emailC.text.trim(), password: passwordC.text);

        if (response.user == null) {
          throw Exception('Login failed: Invalid credentials');
        }

        // Initialize controllers
        final homeController = Get.put(HomeController(), permanent: true);
        final transactionController = Get.put(TransactionController(), permanent: true);

        // Load user data
        await homeController.getProfile();
        await homeController.fetchTotalBalanceData();
        await homeController.getTransactions();

        // Initialize bill notification service
        final billNotificationService = BillNotificationService();
        billNotificationService.initialize();

        isLoading.value = false;

        // Navigate to home
        Get.offAll(() => const BottomNav(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 300));

        return true;
      } catch (e) {
        isLoading.value = false;
        debugPrint('Login error: $e');
        emailC.clear();
        passwordC.clear();
        CustomToast.errorToast('Error', 'Invalid email or password');
      }
    } else {
      CustomToast.errorToast("Error", "Email and password are required");
    }
    return null;
  }
}
