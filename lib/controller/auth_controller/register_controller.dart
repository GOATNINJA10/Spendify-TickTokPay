import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendify/main.dart';
import 'package:spendify/widgets/bottom_navigation.dart';
import 'package:spendify/widgets/toast/custom_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendify/controller/home_controller/home_controller.dart';
import 'package:spendify/services/bill_notification_service.dart';

class RegisterController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isHidden = true.obs;
  var balanceKeypad = TextEditingController();

  var emailC = TextEditingController();
  var passwordC = TextEditingController();
  var nameC = TextEditingController();
  var imageUrl = ''.obs;
  RxString selectedAvatarUrl = ''.obs;
  List<String> avatarList = [
    'https://api.dicebear.com/7.x/avataaars/svg?seed=1', // Default avatar
    'https://api.dicebear.com/7.x/avataaars/svg?seed=2',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=3',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=4',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=5',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=6',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=7',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=8',
  ];

  @override
  void dispose() {
    emailC.dispose();
    passwordC.dispose();
    nameC.dispose();
    balanceKeypad.dispose();
    super.dispose();
  }

  Future<String?> uploadImage(File imageFile) async {
    final response = await supabaseClient.storage
        .from('avatars/pics')
        .upload('${DateTime.now().millisecondsSinceEpoch}', imageFile);
    if (response.isEmpty) {
      return response.toString();
    }
    return null;
  }

  Future<void> register() async {
    if (emailC.text.isNotEmpty &&
        passwordC.text.isNotEmpty &&
        nameC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        debugPrint('Starting registration process...');
        
        // First, sign up the user
        debugPrint('Attempting to sign up user with email: ${emailC.text}');
        AuthResponse res = await supabaseClient.auth
            .signUp(password: passwordC.text, email: emailC.text);

        if (res.user != null) {
          debugPrint('User signed up successfully with ID: ${res.user!.id}');
          try {
            // Then insert the user data using service role client
            debugPrint('Attempting to insert user data into users table...');
            final userData = {
              "id": res.user!.id,
              "name": nameC.text.trim(),
              "email": emailC.text.trim().toLowerCase(),
              "balance": 0.0,
              "url": selectedAvatarUrl.value.isEmpty ? avatarList[0] : selectedAvatarUrl.value
            };
            debugPrint('User data to insert: $userData');
            
            final response = await supabaseServiceClient
                .from("users")
                .insert(userData)
                .select()
                .single();
                
            debugPrint('User data inserted successfully: $response');

            // Explicitly sign in the user after successful registration
            debugPrint('Signing in user after registration...');
            final signInResponse = await supabaseClient.auth.signInWithPassword(
              email: emailC.text.trim().toLowerCase(),
              password: passwordC.text,
            );

            if (signInResponse.user == null) {
              throw Exception("Failed to sign in after registration");
            }

            debugPrint('User signed in successfully after registration');

            // Wait for a moment to ensure data is properly initialized
            await Future.delayed(const Duration(milliseconds: 500));

            // Clean up any existing controllers
            if (Get.isRegistered<HomeController>()) {
              Get.delete<HomeController>(force: true);
            }

            // Initialize new controllers
            final homeController = Get.put(HomeController(), permanent: true);
            await homeController.getProfile();
            await homeController.fetchTotalBalanceData();
            await homeController.getTransactions();

            // Initialize bill notification service
            final billNotificationService = BillNotificationService();
            billNotificationService.initialize();

            debugPrint('Registration process completed successfully');
            
            // Navigate to BottomNav and remove all previous routes
            await Get.offAll(
              () => const BottomNav(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 300),
            );
            
          } catch (e) {
            debugPrint("Error during registration process: $e");
            // If user data insertion fails, we should clean up the auth user
            try {
              debugPrint('Attempting to clean up auth user after failed profile creation...');
              await supabaseClient.auth.signOut();
              debugPrint('Auth user cleaned up successfully');
            } catch (cleanupError) {
              debugPrint('Error during auth user cleanup: $cleanupError');
            }
            
            if (e.toString().contains('duplicate key')) {
              throw Exception("An account with this email already exists");
            } else if (e.toString().contains('HomeController')) {
              // Handle HomeController initialization error separately
              debugPrint('Retrying with HomeController initialization...');
              if (Get.isRegistered<HomeController>()) {
                Get.delete<HomeController>(force: true);
              }
              Get.put(HomeController(), permanent: true);
              throw Exception("Please try registering again");
            } else {
              throw Exception("Failed to create user profile: ${e.toString()}");
            }
          }
        } else {
          throw Exception("Failed to create user account");
        }
        isLoading.value = false;
      } catch (e) {
        isLoading.value = false;
        debugPrint('Registration error: $e');
        CustomToast.errorToast('Error', e.toString());
      }
    } else {
      CustomToast.errorToast("Error", "All fields are required");
    }
  }
}
