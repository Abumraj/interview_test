import 'package:flutter/material.dart';
import 'widgets/rounded_selector.dart';
import 'widgets/rounded_input_field.dart';
import 'widgets/primary_button.dart';
import 'widgets/secondary_button.dart';
import 'widgets/bottom_booking_summary.dart';

class JetSkiDetailScreen extends StatefulWidget {
  final String title;
  final String image;
  final int price;

  const JetSkiDetailScreen({
    super.key,
    required this.title,
    required this.image,
    required this.price,
  });

  @override
  State<JetSkiDetailScreen> createState() => _JetSkiDetailScreenState();
}

class _JetSkiDetailScreenState extends State<JetSkiDetailScreen> {
  final List<String> types = ["Instructor", "Solo"];
  final List<String> durationOptions = ["1hr", "2hrs", "3hrs", "4hrs"];

  String selectedType = "Instructor";
  String selectedDuration = "1hr";

  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF053C5E),
      body: Stack(
        children: [
          // Header Image
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
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            ),
          ),

          // Scrollable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.62,
            maxChildSize: 0.95,
            minChildSize: 0.62,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF053C5E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),

                    const SizedBox(height: 22),

                    // Type Selector
                    const Text(
                      "Type?",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          types.map((t) {
                            return RoundedSelector(
                              label: t,
                              selected: selectedType == t,
                              onTap: () => setState(() => selectedType = t),
                            );
                          }).toList(),
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
                    const SizedBox(height: 10),

                    RoundedInputField(
                      hint:
                          selectedTime == null
                              ? "Enter time"
                              : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')} ",
                      suffix: const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => selectedTime = time);
                        }
                      },
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      "Description",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
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
