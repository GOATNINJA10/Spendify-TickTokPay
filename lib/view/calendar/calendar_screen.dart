import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spendify/config/app_color.dart';
import 'package:spendify/controller/home_controller/home_controller.dart';
import 'package:spendify/utils/utils.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Set<DateTime> _billDates = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadBillDates();
  }

  void _loadBillDates() {
    final controller = Get.find<HomeController>();
    final transactions = controller.transactions;
    
    Set<DateTime> dates = {};
    
    for (var transaction in transactions) {
      try {
        if (transaction['category'] == 'Bills & Fees' && 
            transaction['type'] == 'expense') {
          final date = DateTime.parse(transaction['date']);
          if (date.isAfter(DateTime.now())) {
            dates.add(DateTime(date.year, date.month, date.day));
          }
        }
      } catch (e) {
        print('Error parsing date: ${transaction['date']}');
      }
    }
    
    setState(() {
      _billDates = dates;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      body: SafeArea(
        child: Column(
          children: [
            // Calendar Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF1A2533)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Calendar',
                        style: titleText(24, Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Calendar Widget
                  TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2025, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: Colors.red),
                      holidayTextStyle: TextStyle(color: Colors.red),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonShowsNext: false,
                      formatButtonDecoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                      ),
                      formatButtonTextStyle: const TextStyle(color: Colors.white),
                      titleTextStyle: titleText(20, Colors.white),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: Colors.red),
                      weekdayStyle: TextStyle(color: Colors.white70),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final hasBill = _billDates.any((billDate) => 
                          isSameDay(billDate, day));
                          
                        return Container(
                          margin: const EdgeInsets.all(4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSameDay(day, _selectedDay)
                                ? Colors.red.withOpacity(0.3)
                                : hasBill
                                    ? Colors.blue.withOpacity(0.3)
                                    : null,
                            borderRadius: BorderRadius.circular(8),
                            border: hasBill
                                ? Border.all(color: Colors.blue, width: 1)
                                : null,
                          ),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: isSameDay(day, _selectedDay)
                                  ? Colors.white
                                  : hasBill
                                      ? Colors.blue[200]
                                      : Colors.white70,
                              fontWeight: hasBill ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Upcoming Bills List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming Bills',
                      style: titleText(18, Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Obx(() {
                        final upcomingBills = controller.transactions
                            .where((transaction) {
                          try {
                            final transactionDate = DateTime.parse(transaction['date']);
                            final isBillsAndFees = transaction['category'] == 'Bills & Fees';
                            final isExpense = transaction['type'] == 'expense';
                            final isFutureDate = transactionDate.isAfter(DateTime.now());
                            
                            return isFutureDate && isExpense && isBillsAndFees;
                          } catch (e) {
                            print('Error parsing date: ${transaction['date']}');
                            print('Error: $e');
                            return false;
                          }
                        }).toList()
                          ..sort((a, b) => DateTime.parse(a['date'])
                              .compareTo(DateTime.parse(b['date'])));

                        if (upcomingBills.isEmpty) {
                          return Center(
                            child: Text(
                              'No upcoming bills',
                              style: normalText(16, Colors.white70),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: upcomingBills.length,
                          itemBuilder: (context, index) {
                            final bill = upcomingBills[index];
                            final date = DateTime.parse(bill['date']);
                            final daysUntilDue = date.difference(DateTime.now()).inDays;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E2530),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bill['description'] ?? 'Untitled Bill',
                                          style: titleText(16, Colors.white),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Due in $daysUntilDue days',
                                          style: normalText(14, Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${bill['amount']}',
                                        style: titleText(16, Colors.red),
                                      ),
                                      const SizedBox(height: 4),
                                      TextButton(
                                        onPressed: () {
                                          controller.deleteTransaction(bill['id']);
                                          _loadBillDates(); // Refresh bill dates after deletion
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          backgroundColor: Colors.green.withOpacity(0.2),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Mark as Paid',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}