const db = require('../config/db');
const UserModel = require("./user.model");
const mongoose = require('mongoose');
const { Schema } = mongoose;

// Mood Entry Schema - Track daily moods with songs
const MoodEntrySchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: UserModel.modelName,
        required: true
    },
    mood: {
        type: String,
        enum: ['happy', 'sad', 'energetic', 'calm', 'angry', 'anxious', 'romantic', 'nostalgic'],
        required: true
    },
    moodScore: {
        type: Number,
        min: 1,
        max: 10,
        required: true
    },
    song: {
        title: { type: String, required: true },
        artist: { type: String, required: true },
        albumArt: { type: String, default: '' },
        spotifyUrl: { type: String, default: '' }
    },
    note: {
        type: String,
        default: ''
    },
    date: {
        type: Date,
        default: Date.now
    }
}, { timestamps: true });

const MoodEntryModel = db.model('MoodEntry', MoodEntrySchema);
module.exports = MoodEntryModel;