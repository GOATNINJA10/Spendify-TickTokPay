import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendify/controller/home_controller/home_controller.dart';
import 'package:spendify/main.dart';
import 'package:spendify/widgets/toast/custom_toast.dart';
import 'package:spendify/model/transaction_model.dart';

class TransactionController extends GetxController {
  final amountController = TextEditingController();
  var selectedCategory = ''.obs;
  final titleController = TextEditingController();
  final selectedType = 'expense'.obs;
  var isLoading = false.obs;
  var isSubmitted = false.obs;
  var selectedDate = DateTime.now().obs;
  final homeC = Get.find<HomeController>();
  var transactions = <TransactionModel>[].obs;
  var amount = ''.obs;
  var note = ''.obs;
  var balance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    getTransactions();
  }

  @override
  void dispose() {
    super.dispose();
    amountController.dispose();
    titleController.dispose();
  }

  Future<void> getTransactions() async {
    try {
      isLoading.value = true;
      var currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final response = await supabaseClient
          .from('transactions')
          .select()
          .eq('user_id', currentUser.id)
          .order('date', ascending: false);

      transactions.value = response
          .map((transaction) => TransactionModel.fromJson(transaction))
          .toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      CustomToast.errorToast('Error', 'Failed to fetch transactions');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addResource() async {
    try {
      // Validate inputs first
      if (amountController.text.isEmpty) {
        CustomToast.errorToast('Error', 'Amount cannot be empty');
        return;
      }

      if (titleController.text.isEmpty) {
        CustomToast.errorToast('Error', 'Title cannot be empty');
        return;
      }

      if (selectedCategory.value.isEmpty) {
        CustomToast.errorToast('Error', 'Please select a category');
        return;
      }

      isSubmitted.value = true;
      isLoading.value = true;
      var currentUser = supabaseClient.auth.currentUser;

      // Parse amount from String to double
      double amount;
      try {
        amount = double.parse(amountController.text);
      } catch (e) {
        CustomToast.errorToast('Error', 'Please enter a valid amount');
        return;
      }

      // Add resource
      await supabaseClient.from('transactions').insert({
        'user_id': currentUser!.id,
        'amount': amount,
        'description': titleController.text,
        'type': selectedType.value,
        'category': selectedCategory.value,
        'date': selectedDate.value.toIso8601String(),
      });

      // Update balance based on transaction type
      await updateBalance(amount, selectedType.value);

      // Fetch complete balance data first (to fix the main issue)
      await homeC.fetchTotalBalanceData();

      // Then get paginated transactions for display
      await homeC.getTransactions();

      // Clear form
      resetForm();
      selectedType.value = 'expense'; // Reset to default

      // Close the current screen
      Get.back();

      // Show success message
      CustomToast.successToast('Success', 'Transaction submitted successfully');
    } catch (e) {
      // Log the error for debugging
      debugPrint("Error in addResource: $e");

      // Show error message if transaction submission fails
      CustomToast.errorToast('Failure', "Failed to submit transaction");
    } finally {
      isLoading.value = false;
      isSubmitted.value = false;
    }
  }

  void resetForm() {
    amountController.clear();
    titleController.clear();
    selectedCategory.value = '';
    selectedDate.value = DateTime.now();
  }

  Future<void> updateBalance(double amount, String type) async {
    try {
      final response =
          await supabaseClient.from("users").select('balance').eq('id', supabaseClient.auth.currentUser!.id).single();

      final currentBalance = (response['balance'] as num).toDouble();
      final newBalance = type == 'income' ? currentBalance + amount : currentBalance - amount;

      await supabaseClient.from("users").update({'balance': newBalance}).eq('id', supabaseClient.auth.currentUser!.id);

      // Update local value
      homeC.totalBalance.value = newBalance;

      debugPrint("User's balance updated successfully to: $newBalance");
    } catch (error) {
      debugPrint("Error updating user's balance: $error");
      CustomToast.errorToast('Error', 'Failed to update balance');
    }
  }

  Future<void> addTransaction() async {
    try {
      if (amountController.text.isEmpty || selectedCategory.isEmpty) {
        CustomToast.errorToast('Error', 'Please fill all required fields');
        return;
      }

      var currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      await supabaseClient.from('transactions').insert({
        'user_id': currentUser.id,
        'amount': double.parse(amountController.text),
        'type': selectedType.value,
        'category': selectedCategory.value,
        'note': titleController.text,
        'date': selectedDate.value.toIso8601String(),
      });

      // Update user balance
      final userResponse = await supabaseClient
          .from("users")
          .select('balance')
          .eq('id', supabaseClient.auth.currentUser!.id)
          .single();

      double currentBalance = userResponse['balance'] ?? 0.0;
      double transactionAmount = double.parse(amountController.text);
      double newBalance = selectedType.value == 'income'
          ? currentBalance + transactionAmount
          : currentBalance - transactionAmount;

      await supabaseClient
          .from("users")
          .update({'balance': newBalance})
          .eq('id', supabaseClient.auth.currentUser!.id);

      // Reset form
      amountController.clear();
      titleController.clear();
      selectedCategory.value = '';
      selectedDate.value = DateTime.now();

      // Refresh transactions
      await getTransactions();

      CustomToast.successToast('Success', 'Transaction added successfully');
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      CustomToast.errorToast('Error', 'Failed to add transaction');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await supabaseClient.from('transactions').delete().eq('id', transactionId);
      await getTransactions();
      CustomToast.successToast('Success', 'Transaction deleted successfully');
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      CustomToast.errorToast('Error', 'Failed to delete transaction');
    }
  }

  Future<void> updateTransaction(String transactionId) async {
    try {
      if (amountController.text.isEmpty || selectedCategory.isEmpty) {
        CustomToast.errorToast('Error', 'Please fill all required fields');
        return;
      }

      // Get the old transaction to calculate balance difference
      final oldTransaction = await supabaseClient
          .from('transactions')
          .select()
          .eq('id', transactionId)
          .single();

      // Update the transaction
      await supabaseClient.from('transactions').update({
        'amount': double.parse(amountController.text),
        'type': selectedType.value,
        'category': selectedCategory.value,
        'note': titleController.text,
        'date': selectedDate.value.toIso8601String(),
      }).eq('id', transactionId);

      // Update user balance
      final userResponse = await supabaseClient
          .from("users")
          .select('balance')
          .eq('id', supabaseClient.auth.currentUser!.id)
          .single();

      double currentBalance = userResponse['balance'] ?? 0.0;
      double oldAmount = oldTransaction['amount'];
      double newAmount = double.parse(amountController.text);
      double balanceDifference = 0.0;

      if (oldTransaction['type'] == 'income' && selectedType.value == 'expense') {
        balanceDifference = -(oldAmount + newAmount);
      } else if (oldTransaction['type'] == 'expense' && selectedType.value == 'income') {
        balanceDifference = oldAmount + newAmount;
      } else if (oldTransaction['type'] == 'income' && selectedType.value == 'income') {
        balanceDifference = newAmount - oldAmount;
      } else if (oldTransaction['type'] == 'expense' && selectedType.value == 'expense') {
        balanceDifference = oldAmount - newAmount;
      }

      double newBalance = currentBalance + balanceDifference;

      await supabaseClient
          .from("users")
          .update({'balance': newBalance})
          .eq('id', supabaseClient.auth.currentUser!.id);

      // Reset form
      amountController.clear();
      titleController.clear();
      selectedCategory.value = '';
      selectedDate.value = DateTime.now();

      // Refresh transactions
      await getTransactions();

      CustomToast.successToast('Success', 'Transaction updated successfully');
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      CustomToast.errorToast('Error', 'Failed to update transaction');
    }
  }
}
