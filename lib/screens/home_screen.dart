import 'package:flutter/material.dart';
import 'package:interview/models/leisure.dart';
import 'package:interview/screens/experience_detail_screen.dart';
import 'widgets/leisure_card.dart';
import 'widgets/section_header.dart';
import 'widgets/membership_banner.dart';
import 'widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final List<Leisure> leasures = [
    Leisure(
      title: "Boat Cruise",
      price: "₦100,000/hr",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
    Leisure(
      title: "Transportation",
      price: "₦200,000/trip",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
    Leisure(
      title: "Kayak",
      price: "₦25,000/hr",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
    Leisure(
      title: "Jet Ski",
      price: "₦50,000/hr",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
    Leisure(
      title: "Jet Ski",
      price: "₦50,000/hr",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
    Leisure(
      title: "Jet Ski",
      price: "₦50,000/hr",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
    Leisure(
      title: "Jet Ski",
      price: "₦50,000/hr",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
    Leisure(
      title: "Jet Ski",
      price: "₦50,000/hr",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
    Leisure(
      title: "Jet Ski",
      price: "₦50,000/hr",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
    Leisure(
      title: "Jet Ski",
      price: "₦50,000 / hr",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
    Leisure(
      title: "Jet Ski",
      price: "₦50,000/hr",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
    Leisure(
      title: "Jet Ski",
      price: "₦50,000/hr",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Profile + Icons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
                    ),
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 30,
                          ),
                          Positioned(
                            right: 0,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.orange,
                              child: const Text(
                                "2",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Stack(
                        children: [
                          const Icon(
                            Icons.shopping_bag,
                            color: Colors.white,
                            size: 30,
                          ),
                          Positioned(
                            right: 0,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.orange,
                              child: const Text(
                                "9",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const MembershipBanner(),

            const SectionHeader(title: "Leisures"),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: leasures.length,
                  itemBuilder:
                      (_, i) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ExperienceDetailScreen(
                                    title: leasures[i].title,
                                    image: leasures[i].image,
                                    price:
                                        10000, // or leisure.price if it's an int
                                  ),
                            ),
                          );
                        },
                        child: LeisureCard(leisure: leasures[i]),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
