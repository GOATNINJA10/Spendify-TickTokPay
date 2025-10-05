import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendify/config/app_color.dart';
import 'package:spendify/controller/wallet_controller/wallet_controller.dart';
import 'package:spendify/model/categories_model.dart';

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final List<CategoriesModel> categoryList;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.categoryList,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late final TransactionController controller;
  final amountController = TextEditingController();
  final titleController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = Get.find<TransactionController>();
    amountController.text = widget.transaction['amount'].toString();
    titleController.text = widget.transaction['description'];
    controller.selectedCategory.value = widget.transaction['category'];
    controller.selectedType.value = widget.transaction['type'];
    controller.selectedDate.value = widget.transaction['date'];
  }

  @override
  void dispose() {
    amountController.dispose();
    titleController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        controller.amountController.text = amountController.text;
        controller.titleController.text = titleController.text;
        await controller.updateTransaction(widget.transaction['id']);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        debugPrint('Error updating transaction: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColor.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Edit Transaction",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Add other fields like category, type, and date picker
                // ...

                // Save Button
                ElevatedButton(
                  onPressed: _handleUpdate,
                  child: const Text("Save Changes"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}