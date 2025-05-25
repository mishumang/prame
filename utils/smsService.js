// utils/smsService.js
const twilio = require('twilio');

async function sendSms(phone, message) {
  try {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    const twilioPhoneNumber = process.env.TWILIO_PHONE_NUMBER;

    if (!accountSid || !authToken || !twilioPhoneNumber) {
      throw new Error('Twilio configuration is not set properly in environment variables.');
    }

    const client = twilio(accountSid, authToken);

    const sms = await client.messages.create({
      body: message,
      from: twilioPhoneNumber,
      to: phone
    });

    console.log(`SMS sent to ${phone}: ${sms.sid}`);
    return sms;
  } catch (error) {
    console.error('Error sending SMS:', error);
    throw error;
  }
}

module.exports = sendSms;
