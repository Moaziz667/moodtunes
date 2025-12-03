import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'loginPage.dart';

class Dashboard extends StatefulWidget {
  final token;
  const Dashboard({@required this.token, Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String userId;
  List<dynamic>? moodEntries;
  Map<String, dynamic>? stats;
  int _currentIndex = 0;
  bool _isLoading = true;

  final List<Map<String, dynamic>> moods = [
    {'name': 'happy', 'emoji': '😊', 'color': Color(0xFFFFD700)},
    {'name': 'sad', 'emoji': '😢', 'color': Color(0xFF6495ED)},
    {'name': 'energetic', 'emoji': '⚡', 'color': Color(0xFFFF6B6B)},
    {'name': 'calm', 'emoji': '😌', 'color': Color(0xFF98D8C8)},
    {'name': 'angry', 'emoji': '😠', 'color': Color(0xFFFF4444)},
    {'name': 'anxious', 'emoji': '😰', 'color': Color(0xFFDDA0DD)},
    {'name': 'romantic', 'emoji': '💕', 'color': Color(0xFFFF69B4)},
    {'name': 'nostalgic', 'emoji': '🥺', 'color': Color(0xFFDEB887)},
  ];

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchMoodEntries(),
      _fetchMoodStats(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchMoodEntries() async {
    try {
      var response = await http.post(
        Uri.parse(getMoodEntries),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        setState(() {
          moodEntries = jsonResponse['success'];
        });
      }
    } catch (e) {
      print('Error loading entries: $e');
    }
  }

  Future<void> _fetchMoodStats() async {
    try {
      var response = await http.post(
        Uri.parse(getMoodStats),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        setState(() {
          stats = jsonResponse['success'];
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> _addMoodEntry(String mood, int score, Map<String, String> song, String note) async {
    try {
      var response = await http.post(
        Uri.parse(createMoodEntry),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "mood": mood,
          "moodScore": score,
          "song": song,
          "note": note,
        }),
      );
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        _loadData();
      }
    } catch (e) {
      print('Error adding entry: $e');
    }
  }

  Future<void> _deleteEntry(String id) async {
    try {
      var response = await http.post(
        Uri.parse(deleteMoodEntry),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        _loadData();
      }
    } catch (e) {
      print('Error deleting entry: $e');
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeTab(),
                _buildStatsTab(),
                _buildProfileTab(),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
          border: Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: Color(0xFF1DB954),
          unselectedItemColor: Colors.grey[600],
          elevation: 0,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddMoodDialog(),
              backgroundColor: Color(0xFF1DB954),
              icon: Icon(Icons.add),
              label: Text("Log Mood"),
            )
          : null,
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: Color(0xFF121212),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'MoodTunes',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1DB954), Color(0xFF121212)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Text(
                      '🔥 ${stats?['streakDays'] ?? 0} day streak',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Average mood: ${stats?['averageMoodScore']?.toStringAsFixed(1) ?? '0'}/10',
                      style: TextStyle(fontSize: 14, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Recent Moods',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        moodEntries == null || moodEntries!.isEmpty
            ? SliverToBoxAdapter(child: _buildEmptyState())
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildMoodCard(moodEntries![index]),
                  childCount: moodEntries!.length,
                ),
              ),
      ],
    );
  }

  Widget _buildMoodCard(Map<String, dynamic> entry) {
    final moodData = moods.firstWhere(
      (m) => m['name'] == entry['mood'],
      orElse: () => moods[0],
    );
    final date = DateTime.parse(entry['date'] ?? entry['createdAt']);

    return Dismissible(
      key: Key(entry['_id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteEntry(entry['_id']),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (moodData['color'] as Color).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: (moodData['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        moodData['emoji'],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry['mood']?.toString().toUpperCase() ?? 'MOOD'}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: moodData['color'] as Color,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy • h:mm a').format(date),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (moodData['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${entry['moodScore']}/10',
                      style: TextStyle(
                        color: moodData['color'] as Color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (entry['song'] != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.music_note, color: Color(0xFF1DB954), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry['song']['title'] ?? 'Unknown Song',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              entry['song']['artist'] ?? 'Unknown Artist',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (entry['note'] != null && entry['note'].isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  entry['note'],
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    if (stats == null) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)));
    }

    final moodDist = stats!['moodDistribution'] as Map<String, dynamic>? ?? {};
    final topSongs = stats!['topSongs'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Text(
            'Your Stats',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),

          // Stats cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Entries', '${stats!['totalEntries']}', Icons.library_music)),
              SizedBox(width: 12),
              Expanded(child: _buildStatCard('Avg Mood', '${stats!['averageMoodScore']}/10', Icons.trending_up)),
              SizedBox(width: 12),
              Expanded(child: _buildStatCard('Streak', '${stats!['streakDays']} days', Icons.local_fire_department)),
            ],
          ),
          SizedBox(height: 24),

          // Mood distribution
          Text(
            'Mood Distribution',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 16),
          if (moodDist.isNotEmpty)
            Container(
              height: 200,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: PieChart(
                PieChartData(
                  sections: moodDist.entries.map((e) {
                    final moodData = moods.firstWhere(
                      (m) => m['name'] == e.key,
                      orElse: () => moods[0],
                    );
                    return PieChartSectionData(
                      value: (e.value as num).toDouble(),
                      title: moodData['emoji'],
                      color: moodData['color'] as Color,
                      radius: 60,
                      titleStyle: TextStyle(fontSize: 20),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            )
          else
            _buildEmptyStatsCard(),

          SizedBox(height: 24),

          // Top songs
          Text(
            'Top Songs',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 16),
          if (topSongs.isNotEmpty)
            ...topSongs.asMap().entries.map((e) => _buildTopSongCard(e.key + 1, e.value))
          else
            _buildEmptyStatsCard(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF1DB954), size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopSongCard(int rank, Map<String, dynamic> songData) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: rank == 1 ? Color(0xFFFFD700) : (rank == 2 ? Color(0xFFC0C0C0) : Color(0xFFCD7F32)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              songData['song'] ?? 'Unknown',
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${songData['count']}x',
            style: TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 24),
            Text(
              'MoodTunes User',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${stats?['totalEntries'] ?? 0} mood entries',
              style: TextStyle(color: Colors.grey[500]),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout, color: Colors.red),
                label: Text('Log Out', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎵', style: TextStyle(fontSize: 60)),
            SizedBox(height: 16),
            Text(
              'No moods logged yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the button below to log your first mood with a song!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStatsCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Log some moods to see your stats!',
          style: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }

  void _showAddMoodDialog() {
    String? selectedMood;
    int moodScore = 5;
    final songTitleController = TextEditingController();
    final songArtistController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'How are you feeling?',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),

                // Mood selector
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: moods.map((mood) {
                    final isSelected = selectedMood == mood['name'];
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedMood = mood['name']),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (mood['color'] as Color).withOpacity(0.3)
                              : Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? mood['color'] as Color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(mood['emoji'], style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Text(
                              mood['name'],
                              style: TextStyle(
                                color: isSelected ? mood['color'] as Color : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24),

                // Mood score slider
                Text('Intensity: $moodScore/10', style: TextStyle(color: Colors.white)),
                Slider(
                  value: moodScore.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: Color(0xFF1DB954),
                  onChanged: (value) => setModalState(() => moodScore = value.round()),
                ),
                SizedBox(height: 16),

                // Song input
                Text('What song matches this mood?', style: TextStyle(color: Colors.white)),
                SizedBox(height: 12),
                TextField(
                  controller: songTitleController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                    hintText: "Song title",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.music_note, color: Color(0xFF1DB954)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: songArtistController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                    hintText: "Artist",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.person, color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Note input
                TextField(
                  controller: noteController,
                  style: TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                    hintText: "Add a note (optional)",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                Spacer(),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedMood != null && songTitleController.text.isNotEmpty) {
                        _addMoodEntry(
                          selectedMood!,
                          moodScore,
                          {
                            'title': songTitleController.text,
                            'artist': songArtistController.text,
                          },
                          noteController.text,
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1DB954),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'SAVE MOOD',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}