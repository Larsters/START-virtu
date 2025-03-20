import 'package:flutter/material.dart';
import 'package:frontend/map/map_view.dart';
import 'package:frontend/view/farm_list/farm_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _showMap = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showMap = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_showMap ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow:
                              !_showMap
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(50),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Text(
                          'My Farms',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_showMap ? Colors.black : Colors.grey[600],
                            fontWeight:
                                !_showMap ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showMap = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _showMap ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow:
                              _showMap
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(50),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Text(
                          'Map View',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _showMap ? Colors.black : Colors.grey[600],
                            fontWeight:
                                _showMap ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showMap ? const MapView() : const FarmListView(),
            ),
          ),
        ],
      ),
    );
  }
}
