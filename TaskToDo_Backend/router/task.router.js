const router = require("express").Router();
const MoodController = require('../controller/task.controller');

// Mood Entry Routes
router.post("/createMoodEntry", MoodController.createMoodEntry);
router.post('/getMoodEntries', MoodController.getMoodEntries);
router.post('/getMoodEntriesByRange', MoodController.getMoodEntriesByRange);
router.post('/getMoodStats', MoodController.getMoodStats);
router.post("/deleteMoodEntry", MoodController.deleteMoodEntry);
router.post('/getEntriesByMood', MoodController.getEntriesByMood);

module.exports = router;