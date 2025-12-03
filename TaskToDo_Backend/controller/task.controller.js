const MoodService = require('../services/task.services');

// Create a new mood entry
exports.createMoodEntry = async (req, res, next) => {
    try {
        const { userId, mood, moodScore, song, note } = req.body;
        let moodData = await MoodService.createMoodEntry(userId, mood, moodScore, song, note);
        res.json({ status: true, success: moodData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
};

// Get all mood entries for a user
exports.getMoodEntries = async (req, res, next) => {
    try {
        const { userId } = req.body;
        let moodData = await MoodService.getUserMoodEntries(userId);
        res.json({ status: true, success: moodData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
};

// Get mood entries by date range
exports.getMoodEntriesByRange = async (req, res, next) => {
    try {
        const { userId, startDate, endDate } = req.body;
        let moodData = await MoodService.getMoodEntriesByDateRange(userId, startDate, endDate);
        res.json({ status: true, success: moodData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
};

// Get mood statistics
exports.getMoodStats = async (req, res, next) => {
    try {
        const { userId } = req.body;
        let statsData = await MoodService.getMoodStats(userId);
        res.json({ status: true, success: statsData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
};

// Delete a mood entry
exports.deleteMoodEntry = async (req, res, next) => {
    try {
        const { id } = req.body;
        let deletedData = await MoodService.deleteMoodEntry(id);
        res.json({ status: true, success: deletedData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
};

// Get entries by mood type
exports.getEntriesByMood = async (req, res, next) => {
    try {
        const { userId, mood } = req.body;
        let moodData = await MoodService.getEntriesByMood(userId, mood);
        res.json({ status: true, success: moodData });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
};