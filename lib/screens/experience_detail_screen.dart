import 'package:flutter/material.dart';
import 'package:interview/const.dart';
import 'package:interview/screens/widgets/bottom_booking_summary.dart';
import 'package:interview/screens/widgets/primary_button.dart';
import 'package:interview/screens/widgets/rounded_input_field.dart';
import 'package:interview/screens/widgets/rounded_selector.dart';
import 'package:interview/screens/widgets/secondary_button.dart';

class ExperienceDetailScreen extends StatefulWidget {
  final String title;
  final String image;
  final int price;

  const ExperienceDetailScreen({
    super.key,
    required this.title,
    required this.image,
    required this.price,
  });

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  final List<int> peopleOptions = [10, 15, 20, 25, 30];
  final List<String> durationOptions = ["1hr", "2hrs", "3hrs", "4hrs"];

  int selectedPeople = 10;
  int selectedValue = 10;
  String selectedDuration = "1hr";
  DateTime selectedDateTime = DateTime(2025, 10, 28, 12, 0);

  Future<void> _selectDateTime(BuildContext context) async {
    // First, pick the date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  AppColors
                      .bottomNavBarHighlightColor, // Customize your primary color
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    // Then, pick the time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime:
          selectedDateTime != null
              ? TimeOfDay.fromDateTime(selectedDateTime!)
              : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.bottomNavBarHighlightColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    setState(() {
      selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF053C5E),
      body: Stack(
        children: [
          // Top Image
          SizedBox(
            height: 360,
            width: double.infinity,
            child: Image.network(widget.image, fit: BoxFit.cover),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            ),
          ),

          // Main Content
          DraggableScrollableSheet(
            initialChildSize: 0.62,
            maxChildSize: 0.95,
            minChildSize: 0.62,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF053C5E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    const SizedBox(height: 20),

                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Enjoy an amazing boat cruising experience at lagos water craft.",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),

                    const SizedBox(height: 22),

                    // People selector
                    const Text(
                      "How many people?",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),

                    const SizedBox(height: 12),
                    SegmentedProgressIndicator(
                      currentValue: selectedValue,
                      maxValue: 30,
                      segments: 5,
                      activeColor: AppColors.bottomNavBarHighlightColor,
                      backgroundColor: AppColors.subcolor,
                      onSegmentTap: (value) {
                        setState(() {
                          selectedValue = value;
                        });
                        print("Selected value: $value");
                      },
                    ),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children:
                    //       peopleOptions.map((e) {
                    //         return RoundedSelector(
                    //           label: e.toString(),
                    //           selected: selectedPeople == e,
                    //           onTap: () => setState(() => selectedPeople = e),
                    //         );
                    //       }).toList(),
                    // ),
                    const SizedBox(height: 16),

                    RoundedInputField(
                      hint: "Enter amount of people",
                      initialValue: selectedPeople.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        final value = int.tryParse(text);
                        if (value != null) {
                          setState(() => selectedPeople = value);
                        }
                      },
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      "Duration?",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          durationOptions.map((e) {
                            return RoundedSelector(
                              label: e,
                              backgroundColor: AppColors.subcolor,
                              selected: selectedDuration == e,
                              onTap: () => setState(() => selectedDuration = e),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 16),

                    RoundedInputField(
                      hint: "Select Duration",
                      suffix: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                      ),
                      onTap: () {},
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      "Time",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),

                    const SizedBox(height: 12),

                    RoundedInputField(
                      hint:
                          "${selectedDateTime.hour} : ${selectedDateTime.minute.toString().padLeft(2, '0')} PM   |   ${selectedDateTime.day} / October",
                      suffix: const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                      ),
                      onTap: () async {
                        await _selectDateTime(context);
                      },
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      "Description",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),

                    const SizedBox(height: 26),

                    BottomBookingSummary(
                      duration: selectedDuration,
                      total: widget.price,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            label: "Add to Bag",
                            icon: Icons.shopping_bag,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PrimaryButton(
                            label: "Book Now",
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
