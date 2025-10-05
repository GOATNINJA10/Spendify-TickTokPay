import 'package:flutter/material.dart';
import 'package:emailjs/emailjs.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _serviceId = 'service_7up9zso';
  static const String _templateId = 'template_7vpi446';
  static const String _userId = '6B5sQO0ir4Y7uOxmO';
  static const String _emailJsApiUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  Future<void> sendBillNotification({
    required String recipientEmail,
    required String billName,
    required double amount,
    required DateTime dueDate,
    required int daysUntilDue,
    required String userId,
  }) async {
    try {
      print('\n📧 Preparing email notification with EmailJS...');
      
      // Prepare template parameters
      final Map<String, dynamic> templateParams = {
        'subject': 'Bill Payment Reminder',
        'to_name': recipientEmail.split('@')[0],
        'message': 'Your ${billName} payment of ₹${amount.toStringAsFixed(0)} is due on ${dueDate.toString().split(' ')[0]} (${daysUntilDue} days remaining).',
        'bill_name': billName,
        'amount': amount.toStringAsFixed(0),
        'due_date': dueDate.toString().split(' ')[0],
        'days_remaining': daysUntilDue.toString(),
        'to_email': recipientEmail,
      };
      
      // Prepare the complete request body
      final Map<String, dynamic> requestBody = {
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _userId,
        'template_params': templateParams,
      };
      
      // Send the request directly using http package
      final response = await http.post(
        Uri.parse(_emailJsApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Origin': 'https://www.example.com',  // Fake origin to mimic browser
        },
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('\n✅ Email sent successfully!');
      } else {
        throw Exception('Failed to send email: ${response.statusCode} ${response.body}');
      }
      
    } catch (e, stackTrace) {
      print('\n❌ Error sending email:');
      print('Error type: ${e.runtimeType}');
      print('Error details: $e');
      
      print('\nStack trace:');
      print(stackTrace);
      rethrow;
    }
  }

  // Helper method to validate parameters
  void _validateParameter(String name, dynamic value) {
    if (value == null) {
      print('❌ $name is null');
      return;
    }
    
    if (value is String && value.isEmpty) {
      print('❌ $name is empty');
      return;
    }
    
    if (value is Map && value.isEmpty) {
      print('❌ $name is empty map');
      return;
    }
    
    print('✅ $name is present');
    
    // Additional validation for specific parameters
    switch (name) {
      case 'service_id':
        if (!value.toString().startsWith('service_')) {
          print('⚠️ $name should start with "service_"');
        }
        break;
      case 'template_id':
        if (!value.toString().startsWith('template_')) {
          print('⚠️ $name should start with "template_"');
        }
        break;
      case 'template_params':
        if (value is Map) {
          print('  Template parameters validation:');
          value.forEach((k, v) {
            print('  - $k: ${v ?? 'null'} (${v?.runtimeType ?? 'null'})');
          });
        }
        break;
    }
  }
}