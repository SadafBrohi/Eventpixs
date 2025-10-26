import "package:eventpix/providers/user_provider.dart";
import "package:eventpix/screens/about/about_screen.dart";
import "package:eventpix/screens/profile/profile_screen.dart";
import "package:eventpix/services/event_service.dart";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:provider/provider.dart";
import "../../widgets/event_card.dart";
import "../../models/event_model.dart";
import "create_event_screen.dart";
import "join_event_screen.dart";
import "event_gallery_screen.dart";
import "../../services/auth_service.dart";

class HomeScreen extends StatefulWidget {
  static const String routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _auth = AuthService();
  final _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("EventPix"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (r) => false,
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "My Events"),
              Tab(text: "Joined Events"),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user?.name ?? "Unknown User"),
                accountEmail: Text(user?.email ?? ""),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_rounded, color: Colors.blue),
                ),
              ),
              ListTile(
                title: const Text("Profile"),
                onTap: () =>
                    Navigator.pushNamed(context, ProfileScreen.routeName),
              ),
              ListTile(
                title: const Text("About"),
                onTap: () =>
                    Navigator.pushNamed(context, AboutScreen.routeName),
              ),
              ListTile(
                title: const Text("Logout"),
                onTap: () async {
                  await _auth.signOut();
                  Provider.of<UserProvider>(context, listen: false).clearUser();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ),
        body: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: TabBarView(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: _eventService.getUserCreatedEvents(user?.uid  ?? "" ),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No events yet. Create one!",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final d = docs[index];
                        final event = EventModel.fromMap(
                          d.id,
                          d.data() as Map<String, dynamic>,
                        );

                        return EventCard(
                          title: event.title,
                          code: event.code,
                          photoCount: event.photos.length,
                          date: event.date,
                          location: event.location,
                          members: event.participants.length,
                          ownerName: event.ownerName,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EventGalleryScreen(eventId: event.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                StreamBuilder<QuerySnapshot>(
                  stream: _eventService.getUserJoinedEvents(user?.uid  ?? "" ),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No joined events yet.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final d = docs[index];
                        final event = EventModel.fromMap(
                          d.id,
                          d.data() as Map<String, dynamic>,
                        );

                        return EventCard(
                          title: event.title,
                          code: event.code,
                          photoCount: event.photos.length,
                          date: event.date,
                          location: event.location,
                          members: event.participants.length,
                          ownerName: event.ownerName,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EventGalleryScreen(eventId: event.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: "join",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinEventScreen()),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.person_add_alt_1),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: "create",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
