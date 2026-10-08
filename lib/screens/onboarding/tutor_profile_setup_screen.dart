import 'package:flutter/material.dart';
import '../../services/app_data.dart';
import '../../models/peer_records.dart';
import '../../widgets/peer_ui.dart';
import '../../widgets/data_widgets.dart';
import '../discovery/home_dashboard_screen.dart';

class TutorProfileSetupScreen extends StatefulWidget {
  const TutorProfileSetupScreen({super.key});
  @override
  State<TutorProfileSetupScreen> createState() =>
      _TutorProfileSetupScreenState();
}

class _TutorProfileSetupScreenState extends State<TutorProfileSetupScreen> {
  final bio = TextEditingController();
  Set<String> modules = {};
  String year = 'Year 1', program = 'Information Technology';
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = AppData.instance;
    year = data.profile?['year'] ?? year;
    program = data.profile?['program'] ?? program;
    if (data.db != null && data.uid.isNotEmpty) {
      await perform(context, () async {
        final profile = await data.db!.collection('users').doc(data.uid).get();
        final doc =
            await data.db!.collection('tutorProfiles').doc(data.uid).get();
        if (!mounted) return;
        year = profile.data()?['year'] ?? year;
        program = profile.data()?['program'] ?? program;
        bio.text = doc.data()?['bio'] ?? '';
        modules = Set<String>.from(doc.data()?['subjects'] ?? []);
      });
    }
    if (mounted) setState(() => loaded = true);
  }

  @override
  void dispose() {
    bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DataView(
      builder: (context, data) => PeerPage(title: 'Academic Setup', children: [
            const PeerTitle('Set Up Your Peer Tutor Profile'),
            const Text(
                'Select the modules you can explain and introduce yourself. Your profile becomes visible after enrollment approval.'),
            const SizedBox(height: 18),
            PeerCard(children: [
              const PeerTitle('Live Tutee View Preview',
                  icon: Icons.visibility_outlined),
              PeerPerson(name: data.name, subtitle: '$year • $program'),
              PeerBadge(data.verified
                  ? 'Enrollment verified'
                  : 'Enrollment verification pending'),
              const SizedBox(height: 12),
              Text(bio.text.isEmpty
                  ? 'Your introduction will appear here.'
                  : bio.text),
              Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: modules.map((m) => PeerBadge(m)).toList())
            ]),
            PeerCard(children: [
              DropdownButtonFormField<String>(
                  initialValue: year,
                  decoration: const InputDecoration(labelText: 'Year of study'),
                  items: ['Year 1', 'Year 2', 'Year 3', 'Year 4']
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => year = v!)),
              DropdownButtonFormField<String>(
                  initialValue: program,
                  decoration: const InputDecoration(labelText: 'Program'),
                  items: [
                    'Information Technology',
                    'Software Engineering',
                    'Computer Science',
                    'Cyber Security'
                  ]
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => program = v!)),
              const SizedBox(height: 18),
              const PeerTitle('Modules You Can Teach'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final entry in peerModules.entries)
                  FilterChip(
                      label: Text(moduleLabel(entry.key)),
                      selected: modules.contains(entry.key),
                      onSelected: (v) => setState(() {
                            v
                                ? modules.add(entry.key)
                                : modules.remove(entry.key);
                          }))
              ]),
              const SizedBox(height: 18),
              TextField(
                  controller: bio,
                  maxLength: 250,
                  maxLines: 5,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                      labelText: 'About your peer mentoring',
                      filled: true,
                      fillColor: peerTint)),
            ]),
            AsyncPeerButton('Save Tutor Profile',
                icon: Icons.save_outlined,
                action: !loaded
                    ? null
                    : () async {
                        await data.saveTutor(
                            modules: modules.toList(),
                            bio: bio.text,
                            year: year,
                            program: program);
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (_) => const HomeDashboardScreen()),
                              (_) => false);
                        }
                      }),
            const PeerFreeNote(),
            if (data.ownTutor != null)
              PeerButton('Remove Tutor Profile', secondary: true,
                  onPressed: () async {
                final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: const Text('Remove tutor profile?'),
                          content: const Text(
                              'Your public tutor profile will be removed and your account will return to student mode. Existing bookings and messages remain available.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Keep Profile')),
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Remove')),
                          ],
                        ));
                if (confirmed != true || !context.mounted) return;
                final ok = await perform(context, data.deleteTutorProfile);
                if (ok && context.mounted) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<void>(
                          builder: (_) => const HomeDashboardScreen()),
                      (_) => false);
                }
              }),
          ]));
}
