import 'package:flutter/material.dart';
import '../../widgets/peer_ui.dart';

class PeerFilters {
  final Set<String> modules, modes;
  final bool immediate;
  final String day;
  final double rating;
  const PeerFilters(
      {this.modules = const {},
      this.modes = const {},
      this.immediate = false,
      this.day = 'Any Time',
      this.rating = 0});
}

class FilterBottomSheet extends StatefulWidget {
  final PeerFilters initial;
  const FilterBottomSheet({super.key, this.initial = const PeerFilters()});
  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Set<String> modules, modes;
  late bool immediate;
  late String day;
  late double rating;
  @override
  void initState() {
    super.initState();
    modules = {...widget.initial.modules};
    modes = {...widget.initial.modes};
    immediate = widget.initial.immediate;
    day = widget.initial.day;
    rating = widget.initial.rating;
  }

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
          child: SizedBox(
              height: MediaQuery.sizeOf(context).height * .92,
              child: Column(children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, color: Colors.black12),
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      const Icon(Icons.tune, color: peerBlue),
                      const SizedBox(width: 10),
                      const Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('Filter Peer Tutors',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: peerBlue)),
                            Text('Free campus academic mentoring',
                                style: TextStyle(fontSize: 11))
                          ])),
                      TextButton(
                          onPressed: () => setState(() {
                                modules.clear();
                                modes.clear();
                                immediate = false;
                                day = 'Any Time';
                                rating = 0;
                              }),
                          child: const Text('Reset All')),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close))
                    ])),
                const Divider(height: 1),
                Expanded(
                    child:
                        ListView(padding: const EdgeInsets.all(16), children: [
                  Row(children: [
                    const Expanded(child: PeerTitle('SLIIT MODULE')),
                    PeerBadge('${modules.length} selected')
                  ]),
                  for (final m in const [
                    [
                      'IT1010',
                      'Programming Fundamentals',
                      'Year 1 • Semester 1'
                    ],
                    [
                      'IT2050',
                      'Data Structures & Algorithms',
                      'Year 2 • Semester 2'
                    ],
                    [
                      'IT3060',
                      'Human Computer Interaction',
                      'Year 3 • Semester 1'
                    ]
                  ])
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                            color: peerTint,
                            borderRadius: BorderRadius.circular(14),
                            child: CheckboxListTile(
                                value: modules.contains(m[0]),
                                activeColor: peerBlue,
                                title: Text('${m[0]} ${m[1]}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                subtitle: Text(m[2]),
                                onChanged: (v) => setState(() {
                                      v!
                                          ? modules.add(m[0])
                                          : modules.remove(m[0]);
                                    })))),
                  const SizedBox(height: 16),
                  const PeerTitle('AVAILABILITY'),
                  Material(
                      color: peerTint,
                      borderRadius: BorderRadius.circular(14),
                      child: SwitchListTile(
                          title: const Text('Available within 24 hours',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          subtitle:
                              const Text('For immediate exam or lab prep'),
                          value: immediate,
                          onChanged: (v) => setState(() => immediate = v))),
                  Wrap(
                      spacing: 8,
                      children: ['Today', 'This Week', 'Weekend']
                          .map((d) => ChoiceChip(
                              label: Text(d),
                              selected: day == d,
                              onSelected: (_) => setState(() => day = d)))
                          .toList()),
                  const SizedBox(height: 20),
                  const PeerTitle('LOCATION & STUDY MODE'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    ChoiceChip(
                        label: const Text('All Modes'),
                        selected: modes.isEmpty,
                        onSelected: (_) => setState(() => modes.clear())),
                    for (final m in [
                      'Campus Library / Discussion Rooms',
                      'Online MS Teams'
                    ])
                      FilterChip(
                          label: Text(m),
                          selected: modes.contains(m),
                          onSelected: (v) => setState(() {
                                v ? modes.add(m) : modes.remove(m);
                              }))
                  ]),
                  const SizedBox(height: 20),
                  const PeerTitle('TUTOR RATING'),
                  Wrap(spacing: 8, children: [
                    for (final r in [4.8, 4.5, 4.0, 0.0])
                      ChoiceChip(
                          label: Text(r == 0
                              ? 'Any'
                              : '★ $r+${r == 4.8 ? ' Top' : ''}'),
                          selected: rating == r,
                          onSelected: (_) => setState(() => rating = r))
                  ]),
                ])),
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      PeerButton('Apply Filters',
                          icon: Icons.filter_alt_outlined,
                          onPressed: () => Navigator.pop(
                              context,
                              PeerFilters(
                                  modules: modules,
                                  modes: modes,
                                  immediate: immediate,
                                  day: day,
                                  rating: rating))),
                      const SizedBox(height: 10),
                      const Text(
                          'SLIIT Peer Learning Network • 100% Free Peer Support',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11))
                    ])),
              ]))));
}
