import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RestaurantMenuPreview extends StatelessWidget {
  const RestaurantMenuPreview({super.key, required this.restaurantId});

  final String restaurantId;

  static const Color _orange = Color(0xFFFF6A00);
  static const Color _border = Color(0xFFFFE0B2);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? <String, dynamic>{};
        final rows = _readMenuRows(data);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly Menu Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                )
              else if (rows.isEmpty)
                const _EmptyMenuState()
              else
                ...rows.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 82,
                          child: Text(
                            item.day,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _orange,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.menu,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<_MenuRow> _readMenuRows(Map<String, dynamic> data) {
    final raw = data['weeklyMenu'] ??
        data['menu'] ??
        data['menuPreview'] ??
        data['weeklyMenuPreview'];

    final rows = <_MenuRow>[];

    if (raw is Map) {
      final preferredDays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];

      for (final day in preferredDays) {
        final value = raw[day] ?? raw[day.toLowerCase()];
        final menu = _menuText(value);
        if (menu.isNotEmpty) rows.add(_MenuRow(day: day, menu: menu));
      }

      if (rows.isEmpty) {
        raw.forEach((key, value) {
          final menu = _menuText(value);
          if (menu.isNotEmpty) {
            rows.add(_MenuRow(day: key.toString(), menu: menu));
          }
        });
      }
    }

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final day = (item['day'] ?? item['title'] ?? '').toString().trim();
          final menu = _menuText(item['items'] ?? item['menu'] ?? item['value']);
          if (day.isNotEmpty && menu.isNotEmpty) {
            rows.add(_MenuRow(day: day, menu: menu));
          }
        } else {
          final menu = _menuText(item);
          if (menu.isNotEmpty) {
            rows.add(_MenuRow(day: 'Menu', menu: menu));
          }
        }
      }
    }

    return rows;
  }

  String _menuText(dynamic value) {
    if (value == null) return '';

    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .join(' • ');
    }

    if (value is Map) {
      return value.values
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .join(' • ');
    }

    return value.toString().trim();
  }
}

class _MenuRow {
  const _MenuRow({required this.day, required this.menu});
  final String day;
  final String menu;
}

class _EmptyMenuState extends StatelessWidget {
  const _EmptyMenuState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Weekly menu has not been published yet.',
        style: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: Color(0xFF7C2D12),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
