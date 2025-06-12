require('dotenv').config();  // load .env in dev
const express = require('express');
const axios = require('axios');
const app = express();
const PORT = process.env.PORT || 3000;
const API_KEY = process.env.OPENWEATHER_API_KEY;

app.get('/weather', async (req, res) => {
  const city = req.query.city ? req.query.city.trim() : 'Vancouver';

  if (!city) {
    return res.status(400).json({ error: 'City parameter is required' });
  }

  const url = `https://api.openweathermap.org/data/2.5/forecast/daily?q=${encodeURIComponent(city)}&cnt=7&units=metric&appid=${API_KEY}`;

  try {
    const response = await axios.get(url);
    const { city: cityInfo, list } = response.data;

    res.json({
      city: cityInfo.name,
      forecast: list.map(day => ({
        date: new Date(day.dt * 1000).toDateString(),
        temp: day.temp.day,
        weather: day.weather[0].description
      })),
    });
  } catch (error) {
    console.error('Weather API fetch error:', error.message);
    res.status(500).json({ error: 'Failed to fetch weather data' });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
