// Backend base URL (ALB DNS). Use HTTP unless HTTPS is configured.
final url = "http://tasktodo-alb-1054970230.eu-north-1.elb.amazonaws.com/";

// Auth endpoints
final registration = url + "registration";
final login = url + 'login';

// Mood endpoints
final createMoodEntry = url + 'createMoodEntry';
final getMoodEntries = url + 'getMoodEntries';
final getMoodEntriesByRange = url + 'getMoodEntriesByRange';
final getMoodStats = url + 'getMoodStats';
final deleteMoodEntry = url + 'deleteMoodEntry';
final getEntriesByMood = url + 'getEntriesByMood';