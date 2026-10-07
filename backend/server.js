const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// In-Memory Database for Weather Reports & Observations
let weatherReports = [
  {
    id: 'rep_1728300100',
    city: 'Mumbai',
    temperature: 30.5,
    condition: 'Sunny',
    notes: 'Clear sunny sky around Bandra Worli Sea Link with moderate humidity.',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    author: 'Aarav Sharma',
    createdAt: new Date().toISOString()
  },
  {
    id: 'rep_1728300200',
    city: 'London',
    temperature: 15.0,
    condition: 'Rainy',
    notes: 'Overcast skies and light showers across central London.',
    imageUrl: 'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?w=800',
    author: 'Elena Vance',
    createdAt: new Date(Date.now() - 3600000).toISOString()
  },
  {
    id: 'rep_1728300300',
    city: 'New York',
    temperature: 19.8,
    condition: 'Cloudy',
    notes: 'Brisk autumn wind with scattered high stratocumulus clouds.',
    imageUrl: 'https://images.unsplash.com/photo-1534088568595-a066f410bcda?w=800',
    author: 'Marcus Reed',
    createdAt: new Date(Date.now() - 7200000).toISOString()
  }
];

// Health Check Endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'ONLINE',
    service: 'AeroCast Weather REST API',
    practical: 'Practical 12 Final Demo',
    timestamp: new Date().toISOString()
  });
});

// ==========================================
// REST ENDPOINTS: GET, POST, PUT, DELETE
// ==========================================

// 1. GET /api/reports - Retrieve all weather observations
app.get('/api/reports', (req, res) => {
  console.log(`[GET] /api/reports - Fetching ${weatherReports.length} records`);
  res.status(200).json(weatherReports);
});

// 2. GET /api/reports/:id - Retrieve single observation by ID
app.get('/api/reports/:id', (req, res) => {
  const { id } = req.params;
  const report = weatherReports.find(r => r.id === id);
  if (!report) {
    return res.status(404).json({ error: `Observation with id ${id} not found.` });
  }
  res.status(200).json(report);
});

// 3. POST /api/reports - Create new weather observation (includes Firebase image URL)
app.post('/api/reports', (req, res) => {
  const { city, temperature, condition, notes, imageUrl, author } = req.body;

  if (!city || temperature === undefined) {
    return res.status(400).json({ error: 'City and temperature are required fields.' });
  }

  const newReport = {
    id: req.body.id || `rep_${Date.now()}`,
    city: city.trim(),
    temperature: Number(temperature),
    condition: condition || 'Clear',
    notes: notes || '',
    imageUrl: imageUrl || '',
    author: author || 'Anonymous Observer',
    createdAt: new Date().toISOString()
  };

  weatherReports.unshift(newReport);
  console.log(`[POST] /api/reports - Created observation for ${newReport.city}`);
  res.status(201).json(newReport);
});

// 4. PUT /api/reports/:id - Update existing weather observation
app.put('/api/reports/:id', (req, res) => {
  const { id } = req.params;
  const index = weatherReports.findIndex(r => r.id === id);

  if (index === -1) {
    return res.status(404).json({ error: `Observation with id ${id} not found.` });
  }

  const existing = weatherReports[index];
  const updated = {
    ...existing,
    ...req.body,
    id: existing.id, // Immutable ID
    updatedAt: new Date().toISOString()
  };

  weatherReports[index] = updated;
  console.log(`[PUT] /api/reports/${id} - Updated observation`);
  res.status(200).json(updated);
});

// 5. DELETE /api/reports/:id - Remove an observation
app.delete('/api/reports/:id', (req, res) => {
  const { id } = req.params;
  const initialLength = weatherReports.length;
  weatherReports = weatherReports.filter(r => r.id !== id);

  if (weatherReports.length === initialLength) {
    return res.status(404).json({ error: `Observation with id ${id} not found.` });
  }

  console.log(`[DELETE] /api/reports/${id} - Removed observation`);
  res.status(200).json({ success: true, message: `Observation ${id} deleted successfully.` });
});

// Start Server
app.listen(PORT, () => {
  console.log(`===============================================`);
  console.log(` AeroCast Weather Backend REST API`);
  console.log(` Server active on: http://localhost:${PORT}`);
  console.log(` API Endpoints:`);
  console.log(`   GET    /api/health`);
  console.log(`   GET    /api/reports`);
  console.log(`   POST   /api/reports`);
  console.log(`   PUT    /api/reports/:id`);
  console.log(`   DELETE /api/reports/:id`);
  console.log(`===============================================`);
});
