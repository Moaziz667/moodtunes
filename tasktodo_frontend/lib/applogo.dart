import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1DB954).withOpacity(0.4),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.music_note_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        Text(
          "MoodTunes",
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Track your mood through music",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[400],
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}