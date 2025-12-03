const MoodEntryModel = require("../model/task.model");

class MoodService {
    // Create a new mood entry
    static async createMoodEntry(userId, mood, moodScore, song, note) {
        const moodEntry = new MoodEntryModel({
            userId,
            mood,
            moodScore,
            song,
            note
        });
        return await moodEntry.save();
    }

    // Get all mood entries for a user
    static async getUserMoodEntries(userId) {
        const entries = await MoodEntryModel.find({ userId })
            .sort({ date: -1 });
        return entries;
    }

    // Get mood entries by date range
    static async getMoodEntriesByDateRange(userId, startDate, endDate) {
        const entries = await MoodEntryModel.find({
            userId,
            date: { $gte: new Date(startDate), $lte: new Date(endDate) }
        }).sort({ date: -1 });
        return entries;
    }

    // Get mood statistics for a user
    static async getMoodStats(userId) {
        const entries = await MoodEntryModel.find({ userId });
        
        if (entries.length === 0) {
            return {
                totalEntries: 0,
                averageMoodScore: 0,
                moodDistribution: {},
                topSongs: [],
                streakDays: 0
            };
        }

        // Calculate mood distribution
        const moodDistribution = {};
        entries.forEach(entry => {
            moodDistribution[entry.mood] = (moodDistribution[entry.mood] || 0) + 1;
        });

        // Calculate average mood score
        const totalScore = entries.reduce((sum, entry) => sum + entry.moodScore, 0);
        const averageMoodScore = (totalScore / entries.length).toFixed(1);

        // Get top songs by frequency
        const songCounts = {};
        entries.forEach(entry => {
            const songKey = `${entry.song.title} - ${entry.song.artist}`;
            songCounts[songKey] = (songCounts[songKey] || 0) + 1;
        });
        const topSongs = Object.entries(songCounts)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 5)
            .map(([song, count]) => ({ song, count }));

        // Calculate streak (consecutive days with entries)
        const uniqueDates = [...new Set(entries.map(e => 
            new Date(e.date).toISOString().split('T')[0]
        ))].sort().reverse();
        
        let streakDays = 0;
        const today = new Date().toISOString().split('T')[0];
        for (let i = 0; i < uniqueDates.length; i++) {
            const expectedDate = new Date();
            expectedDate.setDate(expectedDate.getDate() - i);
            if (uniqueDates[i] === expectedDate.toISOString().split('T')[0]) {
                streakDays++;
            } else {
                break;
            }
        }

        return {
            totalEntries: entries.length,
            averageMoodScore: parseFloat(averageMoodScore),
            moodDistribution,
            topSongs,
            streakDays
        };
    }

    // Delete a mood entry
    static async deleteMoodEntry(id) {
        const deleted = await MoodEntryModel.findByIdAndDelete({ _id: id });
        return deleted;
    }

    // Get entries by mood type
    static async getEntriesByMood(userId, mood) {
        const entries = await MoodEntryModel.find({ userId, mood })
            .sort({ date: -1 });
        return entries;
    }
}

module.exports = MoodService;