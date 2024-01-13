import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:seniormatchpro_v1/view/index.dart';

class BottomNavbarCaregivers extends StatefulWidget {
  const BottomNavbarCaregivers({super.key, required this.id});

  final String id;

  @override
  State<BottomNavbarCaregivers> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbarCaregivers> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
            log('${widget.id}');
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Menu',
            icon: Icon(Icons.menu),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return JobRequestsPage(
            id: widget.id); // Replace HomeScreen with your actual widget
      case 1:
        return AcceptedRequestsPage(
            userId: widget.id); // Replace MenuScreen with your actual widget
      case 2:
        return UserProfile(
          name: 'Names',
          email: 'hehe',
        );
      // return ProfileScreen(id: widget.id); // Replace ProfileScreen with your actual widget
      default:
        return Container();
    }
  }
}
