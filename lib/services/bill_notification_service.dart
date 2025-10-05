import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendify/main.dart';
import 'package:spendify/services/email_service.dart';
import 'dart:async';

class BillNotificationService {
  final supabase = Supabase.instance.client;
  Timer? _timer;
  final EmailService _emailService = EmailService();

  // Initialize the service with automatic checks
  void initialize() {
    print('\n🔄 Initializing Bill Notification Service');
    
    // Check if user is authenticated
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('❌ User not authenticated. Bill notification service will not start.');
      return;
    }
    
    print('✅ User authenticated: ${user.email}. Starting bill notification service.');
    
    // Check immediately
    checkDueBillsAndSendNotifications();
    
    // Set up periodic checks every hour
    _timer = Timer.periodic(const Duration(hours: 1), (timer) {
      // Check authentication again before each check
      if (supabase.auth.currentUser == null) {
        print('❌ User logged out. Stopping bill notification service.');
        dispose();
        return;
      }
      print('\n⏰ Running scheduled bill check');
      checkDueBillsAndSendNotifications();
    });
  }

  // Manual trigger method
  Future<void> triggerBillCheck() async {
    print('\n🔔 Manually triggering bill check');
    await checkDueBillsAndSendNotifications();
  }

  // Stop the service
  void dispose() {
    print('\n🛑 Stopping Bill Notification Service');
    _timer?.cancel();
    _timer = null;
  }

  // Check for due bills and send notifications
  Future<void> checkDueBillsAndSendNotifications() async {
    print('\n=== Starting Bill Notification Check ===');
    final currentTime = DateTime.now();
    print('Current time: ${currentTime.toIso8601String()}');

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print('❌ No authenticated user found');
        return;
      }
      print('✅ User authenticated: ${user.email}');

      // First, show ALL transactions for this user
      print('\nChecking ALL transactions for user...');
      final allTransactions = await supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id);

      print('Total transactions found: ${allTransactions.length}');
      if (allTransactions.isNotEmpty) {
        print('\nAll transaction details:');
        for (var transaction in allTransactions) {
          print('  - Description: ${transaction['description']}');
          print('  - Amount: ₹${transaction['amount']}');
          print('  - Date: ${transaction['date']}');
          print('  - Type: ${transaction['type']}');
          print('  - Category: ${transaction['category']}\n');
        }
      }

      // Then check transactions with "Bills & Fees" category
      print('\nChecking transactions with "Bills & Fees" category...');
      final billTransactions = await supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .eq('category', 'Bills & Fees');

      print('Total bill transactions found: ${billTransactions.length}');
      if (billTransactions.isNotEmpty) {
        print('\nBill transaction details:');
        for (var transaction in billTransactions) {
          print('  - Description: ${transaction['description']}');
          print('  - Amount: ₹${transaction['amount']}');
          print('  - Date: ${transaction['date']}');
          print('  - Type: ${transaction['type']}');
          print('  - Category: ${transaction['category']}\n');
        }
      }

      // Get bills due in next 1-2 days
      print('\nFetching bills due in next 1-2 days...');
      final dueDate = currentTime.add(const Duration(days: 2));
      print('Searching for bills between:');
      print('  - From: ${currentTime.toIso8601String()}');
      print('  - To: ${dueDate.toIso8601String()}');

      // Check transactions table with more lenient conditions
      final dueTransactions = await supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .lte('date', dueDate.toIso8601String())
          .gte('date', currentTime.toIso8601String());

      print('\nTransactions due in next 2 days:');
      if (dueTransactions.isNotEmpty) {
        for (var transaction in dueTransactions) {
          final transactionDate = DateTime.parse(transaction['date']);
          final daysUntilDue = transactionDate.difference(currentTime).inDays;
          print('  - Description: ${transaction['description']}');
          print('  - Amount: ₹${transaction['amount']}');
          print('  - Date: ${transactionDate.toIso8601String()}');
          print('  - Days Until Due: $daysUntilDue');
          print('  - Type: ${transaction['type']}');
          print('  - Category: ${transaction['category']}\n');
        }
      } else {
        print('  No transactions due in next 2 days');
      }

      // Filter for bills from the due transactions
      final dueBills = dueTransactions.where((transaction) => 
        transaction['category'] == 'Bills & Fees' && 
        transaction['type'] == 'expense'
      ).toList();

      if (dueBills.isEmpty) {
        print('ℹ️ No bills due in the next 2 days');
        return;
      }
      print('✅ Found ${dueBills.length} bills due soon');

      // Get user's email
      print('\nFetching user email...');
      final userResponse = await supabase
          .from('users')
          .select('email')
          .eq('id', user.id)
          .single();

      if (userResponse == null || userResponse['email'] == null) {
        print('❌ Could not find user email');
        return;
      }
      final userEmail = userResponse['email'];
      print('✅ User email: $userEmail');

      // Send email notification for each due bill
      print('\nSending notifications for each bill...');
      for (final bill in dueBills) {
        final dueDate = DateTime.parse(bill['date']);
        final daysUntilDue = dueDate.difference(currentTime).inDays;
        
        print('\n📧 Processing bill:');
        print('  - Name: ${bill['description']}');
        print('  - Amount: ₹${bill['amount']}');
        print('  - Due Date: ${dueDate.toString().split(' ')[0]}');
        print('  - Days Until Due: $daysUntilDue');
        
        await _emailService.sendBillNotification(
          recipientEmail: userEmail,
          billName: bill['description'],
          amount: bill['amount'].toDouble(),
          dueDate: dueDate,
          daysUntilDue: daysUntilDue,
          userId: user.id,
        );
      }
      
      print('\n=== Bill Notification Check Completed ===\n');
    } catch (e) {
      print('\n❌ Error in checkDueBillsAndSendNotifications:');
      print('Error details: $e');
      print('Stack trace: ${StackTrace.current}\n');
    }
  }
} 