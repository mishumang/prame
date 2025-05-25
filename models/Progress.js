const mongoose = require('mongoose');

const ProgressSchema = new mongoose.Schema({
  uid: { type: String, required: true, unique: true },
  // progressData is stored as an object with date keys (e.g., "YYYY-MM-DD")
  // and values such as { hours: Number, activity: String }.
  progressData: { type: Object, default: {} },
}, { timestamps: true });

module.exports = mongoose.model('Progress', ProgressSchema);
