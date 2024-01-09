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
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (int newIndex) {
        setState(() {
          _currentIndex = newIndex;
          log('${widget.id}');
        });
        if (_currentIndex == 0) {
          log(widget.id);
        }
        if (_currentIndex == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AcceptedRequestsPage(userId: widget.id),
            ),
          );
        }
        if (_currentIndex == 2) {}
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
    );
  }
}
