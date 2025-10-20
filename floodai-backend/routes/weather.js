const express = require('express');
const router = express.Router();
const axios = require('axios');

// Mock weather data (replace with real API integration later)
router.get('/current', async (req, res) => {
  try {
    const { latitude, longitude } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude and longitude required' });
    }

    // Mock weather response
    const mockWeather = {
      latitude: parseFloat(latitude),
      longitude: parseFloat(longitude),
      temperature: Math.round(Math.random() * 15 + 25),
      humidity: Math.round(Math.random() * 40 + 50),
      rainfall: Math.round(Math.random() * 100),
      windSpeed: Math.round(Math.random() * 20),
      condition: ['Clear', 'Cloudy', 'Rainy', 'Stormy'][Math.floor(Math.random() * 4)],
      timestamp: new Date().toISOString(),
    };

    res.json(mockWeather);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Forecast (mock for now)
router.get('/forecast', async (req, res) => {
  try {
    const { latitude, longitude, days = 5 } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude and longitude required' });
    }

    const forecast = [];
    for (let i = 0; i < parseInt(days); i++) {
      const date = new Date();
      date.setDate(date.getDate() + i);

      forecast.push({
        date: date.toISOString().split('T')[0],
        maxTemp: Math.round(Math.random() * 15 + 28),
        minTemp: Math.round(Math.random() * 10 + 20),
        rainfall: Math.round(Math.random() * 150),
        condition: ['Clear', 'Cloudy', 'Rainy', 'Stormy'][Math.floor(Math.random() * 4)],
      });
    }

    res.json({
      latitude: parseFloat(latitude),
      longitude: parseFloat(longitude),
      forecast,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;