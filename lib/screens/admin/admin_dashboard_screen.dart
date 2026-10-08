import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/app_data.dart';
import '../../widgets/data_widgets.dart';
import '../../widgets/session_home.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _decide(String uid, bool approve) async {
    if (!AppData.instance.isAdmin) throw StateError('Administrator access required.');
    final db = AppData.instance.db!;
    await db.runTransaction((tx) async {
      final userRef = db.collection('users').doc(uid);
      final tutorRef = db.collection('tutorProfiles').doc(uid);
      final user = await tx.get(userRef);
      final tutor = await tx.get(tutorRef);
      if (user.data()?['role'] != 'tutor' || !tutor.exists) {
        throw StateError('The tutor must complete their profile before approval.');
      }
      tx.update(userRef, {'verificationStatus': approve ? 'approved' : 'rejected'});
      tx.update(tutorRef, {'verified': approve});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AppData.instance.isAdmin) {
      return const Scaffold(body: Center(child: Text('Administrator access required.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), actions: [
        TextButton(onPressed: () async {
          final ok = await perform(context, () => AppData.instance.signOut());
          if (ok && context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SessionHome()), (_) => false);
          }
        }, child: const Text('Sign out')),
      ]),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: AppData.instance.db!.collection('users').where('role', isEqualTo: 'tutor').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text(dataError(snapshot.error!)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final tutors = snapshot.data!.docs.toList()..sort((a,b) {
            final ap = a.data()['verificationStatus'] == 'pending' ? 0 : 1;
            final bp = b.data()['verificationStatus'] == 'pending' ? 0 : 1;
            return ap.compareTo(bp);
          });
          if (tutors.isEmpty) return const Center(child: Text('No tutor applications yet.'));
          return ListView(padding: const EdgeInsets.all(16), children: [
            const Text('Tutor applications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Pending tutors appear first. Approval makes their profile available for booking.'),
            const SizedBox(height: 16),
            for (final tutor in tutors) Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tutor.data()['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('${tutor.data()['email']}\n${tutor.data()['year']} · ${tutor.data()['program']}'),
                Text('Status: ${tutor.data()['verificationStatus']}'),
                StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
                  stream: AppData.instance.db!.collection('tutorProfiles').doc(tutor.id).snapshots(),
                  builder: (context, profile) {
                    if (profile.hasError) return Text(dataError(profile.error!));
                    if (!profile.hasData) return const LinearProgressIndicator();
                    if (!profile.data!.exists) return const Text('Awaiting completed tutor profile.');
                    final details = profile.data!.data()!;
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Modules: ${(details['subjects'] as List? ?? []).join(', ')}'),
                      Text(details['bio'] ?? ''),
                      const SizedBox(height: 12),
                      Wrap(spacing: 12, runSpacing: 8, children: [
                        AsyncPeerButton('Approve', action: tutor.data()['verificationStatus'] == 'approved' ? null : () => _decide(tutor.id, true)),
                        AsyncPeerButton('Reject / revoke', secondary: true, action: tutor.data()['verificationStatus'] == 'rejected' ? null : () => _decide(tutor.id, false)),
                      ]),
                    ]);
                  },
                ),
              ]),
            )),
          ]);
        },
      ),
    );
  }
}
