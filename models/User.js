const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const UserSchema = new mongoose.Schema({
  userName: { type: String, required: true },
  email: { type: String, unique: true, sparse: true }, // allow users without email if using phone
  phone: { type: String, unique: true, sparse: true }, // new field for phone number
  pwd: { type: String, required: true },
  userID: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now }
});

// Method to compare entered password with hashed password
UserSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.pwd);
};

// Pre-save hook to hash the password if it is modified
UserSchema.pre('save', async function (next) {
  if (!this.isModified('pwd')) return next();
  try {
    const salt = await bcrypt.genSalt(10);
    this.pwd = await bcrypt.hash(this.pwd, salt);
    next();
  } catch (err) {
    next(err);
  }
});

module.exports = mongoose.model('User', UserSchema);
