# AeroCast Backend REST API (Practical 12)

This Node.js + Express backend fulfills the **Section B: Backend API Development** requirement for Practical 12.

## Quick Start

1. Open a terminal in this directory:
   ```bash
   cd c:\Users\janas\OneDrive\Documents\weather_app\backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the REST API server:
   ```bash
   npm start
   ```
   Server will run on `http://localhost:5000`.

---

## REST Endpoints Specification

### 1. Health Check
- **Method:** `GET`
- **URL:** `http://localhost:5000/api/health`
- **Response:**
  ```json
  {
    "status": "ONLINE",
    "service": "AeroCast Weather REST API"
  }
  ```

### 2. Get All Observations
- **Method:** `GET`
- **URL:** `http://localhost:5000/api/reports`
- **Response (200 OK):**
  ```json
  [
    {
      "id": "rep_1728300100",
      "city": "Mumbai",
      "temperature": 30.5,
      "condition": "Sunny",
      "notes": "Clear sunny sky around Bandra Worli Sea Link.",
      "imageUrl": "https://images.unsplash.com/...",
      "author": "Aarav Sharma",
      "createdAt": "2026-10-07T12:00:00.000Z"
    }
  ]
  ```

### 3. Post New Observation (with Firebase Storage Image)
- **Method:** `POST`
- **URL:** `http://localhost:5000/api/reports`
- **Headers:** `Content-Type: application/json`
- **Request Body:**
  ```json
  {
    "city": "Bengaluru",
    "temperature": 24.2,
    "condition": "Rainy",
    "notes": "Evening monsoon showers in Indiranagar.",
    "imageUrl": "https://firebasestorage.googleapis.com/v0/b/...",
    "author": "Student Observer"
  }
  ```
- **Response (201 Created):** Returns created JSON record with assigned `id`.

### 4. Update Observation
- **Method:** `PUT`
- **URL:** `http://localhost:5000/api/reports/rep_1728300100`
- **Headers:** `Content-Type: application/json`
- **Request Body:**
  ```json
  {
    "temperature": 31.0,
    "notes": "Sky cleared up completely by afternoon."
  }
  ```
- **Response (200 OK):** Returns updated JSON record.

### 5. Delete Observation
- **Method:** `DELETE`
- **URL:** `http://localhost:5000/api/reports/rep_1728300100`
- **Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Observation rep_1728300100 deleted successfully."
  }
  ```
