const Progress = require('../models/Progress');

exports.updateProgress = async (req, res) => {
    try {
      console.log("Received updateProgress request:", req.body);
      const { uid, progressData } = req.body;
  
      if (!uid || !progressData) {
        console.log("Missing uid or progressData");
        return res.status(400).json({ message: "Missing uid or progressData." });
      }
  
      let progress = await Progress.findOne({ uid });
      console.log("Existing progress:", progress);
  
      if (progress) {
        Object.keys(progressData).forEach(date => {
          progress.progressData[date] = progressData[date];
        });
        await progress.save();
        console.log("Progress updated");
      } else {
        progress = new Progress({ uid, progressData });
        await progress.save();
        console.log("New progress created");
      }
  
      return res.status(200).json({ message: "Progress updated successfully." });
    } catch (error) {
      console.error("Progress update error:", error);
      return res.status(500).json({ message: "Server error during progress update.", error: error.message });
    }
  };
  
  exports.getProgress = async (req, res) => {
    try {
      const { uid } = req.params;
      if (!uid) {
        return res.status(400).json({ message: "Missing uid parameter." });
      }
  
      const progress = await Progress.findOne({ uid });
      if (!progress) {
        // Return an empty object if no data is found.
        return res.status(200).json({});
      }
      console.log("Progress retrieved:", progress);
      return res.status(200).json(progress.progressData);
    } catch (error) {
      console.error("Progress fetch error:", error);
      return res.status(500).json({ message: "Server error during progress fetch.", error: error.message });
    }
  };