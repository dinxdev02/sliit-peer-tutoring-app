import 'package:flutter/material.dart';
import '../../services/app_data.dart';
import '../../models/peer_records.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/peer_navigation.dart';
import '../../widgets/data_widgets.dart';
import '../../widgets/booking_workflow.dart';
import '../messaging/notifications_screen.dart';
import 'filter_bottom_sheet.dart';
import 'tutor_profile_detail_screen.dart';

class SearchDiscoveryScreen extends StatefulWidget {
  final String initialQuery;
  final bool savedOnly;
  const SearchDiscoveryScreen(
      {super.key, this.initialQuery = '', this.savedOnly = false});
  @override
  State<SearchDiscoveryScreen> createState() => _SearchDiscoveryScreenState();
}

class _SearchDiscoveryScreenState extends State<SearchDiscoveryScreen> {
  late final TextEditingController search =
      TextEditingController(text: widget.initialQuery);
  PeerFilters filters = const PeerFilters(
      modules: {}, modes: {}, immediate: false, day: 'Any Time', rating: 0);
  late bool savedOnly = widget.savedOnly;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> openFilters() async {
    final result = await showModalBottomSheet<PeerFilters>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => FilterBottomSheet(initial: filters));
    if (result != null && mounted) setState(() => filters = result);
  }

  bool matches(PeerTutor tutor, AppData data) {
    final query = search.text.trim().toLowerCase();
    if (tutor.id == data.uid ||
        savedOnly && !data.favorites.contains(tutor.id)) {
      return false;
    }
    if (query.isNotEmpty &&
        !('${tutor.name} ${tutor.program} ${tutor.modules.map(moduleLabel).join(' ')}')
            .toLowerCase()
            .contains(query)) {
      return false;
    }
    if (filters.modules.isNotEmpty &&
        !tutor.modules.any(filters.modules.contains)) {
      return false;
    }
    if (data.rating(tutor.id) < filters.rating) return false;
    final now = DateTime.now();
    final restrict = filters.immediate ||
        filters.day == 'This Week' ||
        filters.day == 'Today' ||
        filters.day == 'Weekend' ||
        filters.modes.isNotEmpty;
    if (!restrict) return true;
    return data.openSlots(tutor.id).any((s) =>
        (filters.day != 'This Week' ||
            s.start.isBefore(DateTime(now.year, now.month, now.day)
                .add(Duration(days: 8 - now.weekday)))) &&
        (!filters.immediate || s.start.difference(now).inMinutes <= 1440) &&
        (filters.day != 'Today' ||
            s.start.year == now.year &&
                s.start.month == now.month &&
                s.start.day == now.day) &&
        (filters.day != 'Weekend' ||
            s.start.weekday >= 6 &&
                s.start.isBefore(now.add(const Duration(days: 7)))) &&
        (filters.modes.isEmpty ||
            filters.modes.length == 2 ||
            filters.modes.contains(s.mode == 'Online'
                ? 'Online MS Teams'
                : 'Campus Library / Discussion Rooms')));
  }

  @override
  Widget build(BuildContext context) => DataView(builder: (context, data) {
        final tutors = data.tutors.where((t) => matches(t, data)).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        return PeerPage(
            title: 'Search',
            bottom: const PeerNavigation(index: 1),
            actions: [
              IconButton(
                  tooltip: 'Notifications',
                  onPressed: () =>
                      openPeerScreen(context, const NotificationsScreen()),
                  icon: const Icon(Icons.notifications_none))
            ],
            children: [
              TextField(
                  controller: search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                      hintText: 'Search module, topic or tutor',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                          tooltip: 'Clear search',
                          onPressed: () => setState(() => search.clear()),
                          icon: const Icon(Icons.close)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none))),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                ActionChip(
                    avatar: const Icon(Icons.tune, size: 18),
                    label: const Text('Filters'),
                    onPressed: openFilters),
                FilterChip(
                    label: const Text('Saved Tutors'),
                    selected: savedOnly,
                    onSelected: (v) => setState(() => savedOnly = v)),
                for (final module in filters.modules)
                  InputChip(
                      label: Text(module),
                      onDeleted: () => setState(() => filters = PeerFilters(
                          modules: {...filters.modules}..remove(module),
                          modes: filters.modes,
                          immediate: filters.immediate,
                          day: filters.day,
                          rating: filters.rating))),
                ActionChip(
                    label: const Text('Reset All'),
                    onPressed: () => setState(() {
                          search.clear();
                          savedOnly = false;
                          filters = const PeerFilters(
                              modules: {},
                              modes: {},
                              immediate: false,
                              day: 'Any Time',
                              rating: 0);
                        })),
              ]),
              const SizedBox(height: 18),
              Text(
                  'Showing ${tutors.length} campus mentors • 100% Free Peer Study',
                  style: const TextStyle(color: peerBlue)),
              const SizedBox(height: 12),
              if (tutors.isEmpty)
                const PeerCard(children: [
                  PeerTitle('No tutors match your search'),
                  Text('Try another module or reset your filters.')
                ]),
              for (final tutor in tutors)
                PeerCard(children: [
                  PeerPerson(
                      name: tutor.name,
                      subtitle: '${tutor.year} • ${tutor.program}'),
                  Text(data.rating(tutor.id) == 0
                      ? 'New Peer Mentor • No reviews yet'
                      : '★ ${data.rating(tutor.id).toStringAsFixed(1)} • ${data.reviews.where((r) => r.tutorId == tutor.id).length} peer reviews'),
                  const SizedBox(height: 10),
                  Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          tutor.modules.map((m) => PeerBadge(m)).toList()),
                  const SizedBox(height: 12),
                  Text(data.openSlots(tutor.id).isEmpty
                      ? 'No future slots published'
                      : '${data.openSlots(tutor.id).length} available slots'),
                  AsyncPeerButton(
                      data.favorites.contains(tutor.id)
                          ? 'Remove Saved Tutor'
                          : 'Save Tutor',
                      icon: Icons.bookmark_outline,
                      secondary: true,
                      action: () => data.toggleFavorite(tutor.id)),
                  if (savedOnly && data.favorites.contains(tutor.id)) ...[
                    if ((data.favoriteNotes[tutor.id] ?? '').isNotEmpty)
                      Text(data.favoriteNotes[tutor.id]!),
                    PeerButton('Edit Private Note', secondary: true,
                        onPressed: () async {
                      final note = TextEditingController(
                          text: data.favoriteNotes[tutor.id] ?? '');
                      await showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                                title: const Text('Saved tutor note'),
                                content: TextField(
                                    controller: note,
                                    maxLength: 300,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                        hintText:
                                            'What would you like to study with this tutor?')),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () async {
                                        final ok = await perform(
                                            ctx,
                                            () => data.updateFavoriteNote(
                                                tutor.id, note.text));
                                        if (ok && ctx.mounted) {
                                          Navigator.pop(ctx);
                                        }
                                      },
                                      child: const Text('Save')),
                                ],
                              ));
                      note.dispose();
                    }),
                  ],
                  Row(children: [
                    Expanded(
                        child: PeerButton('View Profile',
                            secondary: true,
                            onPressed: () => openPeerScreen(context,
                                TutorProfileDetailScreen(tutorId: tutor.id)))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: AsyncPeerButton('Request Session',
                            orange: true,
                            action: data.openSlots(tutor.id).isEmpty
                                ? null
                                : () => requestStudySession(context, tutor)))
                  ]),
                ]),
              const PeerFreeNote(),
            ]);
      });
}
