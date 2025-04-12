import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A3A), // Dark blue background
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with resort image
            Stack(
              children: [
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kuriftu Resort',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Luxury beachfront experience',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Welcome section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready for your next luxury escape? Explore our special offers and amenities.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                children: [
                  _buildActionCard(
                    icon: Icons.king_bed,
                    label: 'Book Now',
                    color: const Color(0xFF1E88E5),
                  ),
                  _buildActionCard(
                    icon: Icons.restaurant,
                    label: 'Dining',
                    color: const Color(0xFF42A5F5),
                  ),
                  _buildActionCard(
                    icon: Icons.spa,
                    label: 'Spa',
                    color: const Color(0xFF64B5F6),
                  ),
                  _buildActionCard(
                    icon: Icons.local_activity,
                    label: 'Activities',
                    color: const Color(0xFF90CAF9),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Current booking status (if any)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Next Stay',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ocean View Suite • Dec 15-20, 2023',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Special offers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Special Offers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                children: [
                  _buildOfferItem(
                    'Summer Getaway',
                    '20% off all bookings',
                    'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                  ),
                  const SizedBox(width: 15),
                  _buildOfferItem(
                    'Spa Package',
                    '3 treatments + lunch',
                    'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                  ),
                  const SizedBox(width: 15),
                  _buildOfferItem(
                    'Romantic Escape',
                    'Champagne included',
                    'https://images.unsplash.com/photo-1564501049412-61c2a3083791?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Resort features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Resort Features',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildFeatureItem(Icons.beach_access, 'Private Beach'),
                  _buildFeatureItem(Icons.pool, 'Infinity Pool'),
                  _buildFeatureItem(Icons.restaurant, '5 Restaurants'),
                  _buildFeatureItem(Icons.fitness_center, 'Fitness Center'),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 80,
      height: 90,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferItem(String title, String subtitle, String imageUrl) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1E88E5).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
