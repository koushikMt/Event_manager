import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Required for launching email client

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventHomeScreen(),
    );
  }
}

class EventHomeScreen extends StatefulWidget {
  @override
  _EventHomeScreenState createState() => _EventHomeScreenState();
}

class _EventHomeScreenState extends State<EventHomeScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  List<Map<String, String>> events = []; // List to store created events
  List<Map<String, dynamic>> popularEvents = []; // List for popular events
  List<Map<String, String>> interestedEvents = []; // List for interested events

  int _selectedIndex = 0; // Track the selected index for bottom navigation

  @override
  void initState() {
    super.initState();
    _fetchPopularEvents(); // Load popular events when the screen is initialized
  }

  void _fetchPopularEvents() {
    // Static list of popular events with images (you can modify these)
    popularEvents = [
      {
        'title': 'Concert in the Park',
        'location': 'City Park',
        'email': 'invite@concert.com',
        'image': 'assets/concert.jpg', // Placeholder image URL
      },
      {
        'title': 'Art Exhibition',
        'location': 'Art Gallery',
        'email': 'invite@artexhibition.com',
        'image': 'assets/art.jpg', // Placeholder image URL
      },
      {
        'title': 'Food Festival',
        'location': 'Downtown',
        'email': 'invite@foodfestival.com',
        'image': 'assets/food.jpg', // Placeholder image URL
      },
    ];
  }

  void _addEvent() {
    setState(() {
      if (_titleController.text.isNotEmpty && _locationController.text.isNotEmpty) {
        events.add({
          'title': _titleController.text,
          'location': _locationController.text,
          'email': _emailController.text,

        });
        _titleController.clear();
        _locationController.clear();
        _emailController.clear();
      }
    });
  }

  // Method to send invitation via email
  void _sendInvitation(String email, String eventTitle) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Invitation to $eventTitle&body=You are invited to join the event $eventTitle.',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not send email to $email';
    }
  }

  void _addToInterested(Map<String, dynamic> event) {
    setState(() {
      interestedEvents.add({
        'title': event['title'],
        'location': event['location'],
      }); // Add the event to the interested list
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index for navigation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Manager'),
      ),
      body: _selectedIndex == 0 ? _buildCreateEventScreen() : _buildPopularEventsScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Create Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Popular Events',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCreateEventScreen() {
    return SingleChildScrollView( // Allows scrolling when content exceeds height
      child: Center( // Centering the Create Event block
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Create Event',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Event Title'),
                  ),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Location'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Invitee Email'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addEvent,
                    child: Text('Create Event'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Created Events:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  // Show created events only if there are any
                  ListView.builder(
                    shrinkWrap: true, // Avoids overflow by taking only needed height
                    physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling
                    itemCount: events.isNotEmpty ? events.length : 0,
                    itemBuilder: (ctx, index) {
                      return ListTile(
                        title: Text('Event Name: ${events[index]['title']}'),
                        subtitle: Text('Location: ${events[index]['location']}\nEmail: ${events[index]['email']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            _sendInvitation(events[index]['email']!, events[index]['title']!);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularEventsScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Popular Events Around You:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Use GridView to display popular events in a grid
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of columns
                crossAxisSpacing: 8, // Space between columns
                mainAxisSpacing: 8, // Space between rows
                childAspectRatio: 0.5, // Adjusted aspect ratio for a more compact height
              ),
              itemCount: popularEvents.length,
              physics: NeverScrollableScrollPhysics(), // Disable scrolling for this GridView
              shrinkWrap: true, // Make the GridView take only the required height
              itemBuilder: (ctx, index) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        popularEvents[index]['image'],
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          popularEvents[index]['title']!,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Location: ${popularEvents[index]['location']}',
                        style: TextStyle(fontSize: 10),
                      ),
                      ElevatedButton(
                        onPressed: () {
_addToInterested(popularEvents[index]);
                        },
                        child: Text('Interested', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'Interested Events:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true, // Avoids overflow by taking only needed height
              physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling
              itemCount: interestedEvents.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  title: Text('Event Name: ${interestedEvents[index]['title']}'),
                  subtitle: Text('Location: ${interestedEvents[index]['location']}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
