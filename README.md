
# 🌦️ Flutter Weather App

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/) 
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/) 
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE) 
[![GitHub stars](https://img.shields.io/github/stars/vibhav22022000/Flutter-Weather-App?style=for-the-badge)](https://github.com/vibhav22022000/Flutter-Weather-App/stargazers) 
[![GitHub issues](https://img.shields.io/github/issues/vibhav22022000/Flutter-Weather-App?style=for-the-badge)](https://github.com/vibhav22022000/Flutter-Weather-App/issues)

A **modern weather application** built with Flutter that provides real-time weather updates, forecasts, and air quality information — all in a clean and user-friendly interface.

---

## ✨ Features

- 🌍 **Current Weather**: Real-time temperature, conditions, and location info  
- 📅 **7-Day Forecast**: Extended outlook with detailed data  
- ⏱️ **24-Hour Forecast**: Hourly temperatures displayed with interactive chart  
- 🏙️ **City Comparison**: Compare weather across up to 6 cities  
- 🌅 **Detailed Insights**: Sunrise/sunset, humidity, pressure, visibility  
- 📊 **Weather Trends**: Past 7 days data visualization  
- 🌫️ **Air Quality Index**: Live AQI with health recommendations  
- ⚙️ **Customizable Settings**: Choose units (°C/°F), themes, and notifications  

---

## 📸 Screenshots

### Home Screens
| Home 1 | Home 2 |
|--------|--------|
| ![Home 1](screenshots/homescreen1.png) | ![Home 2](screenshots/homescreen2.png) |

### Forecast
| 7-Day Forecast | 24-Hour Forecast 1 | 24-Hour Forecast 2 |
|----------------|------------------|------------------|
| ![7-Day](screenshots/7daysforecast.png) | ![24h1](screenshots/24hrsforecast.png) | ![24h2](screenshots/24hrsforecast2.png) |

### Air Quality
| Air Quality 1 | Air Quality 2 |
|---------------|---------------|
| ![AQ1](screenshots/airquality1.png) | ![AQ2](screenshots/airquality2.png) |

### City Comparison
| City Comparison |
|----------------|
| ![City](screenshots/citycomparison.png) |

### Detailed Info
| Detailed Info 1 | Detailed Info 2 |
|-----------------|----------------|
| ![Detail1](screenshots/detailedinfo1.png) | ![Detail2](screenshots/detailedinfo2.png) |

### Weather Trends
| Trend 1 | Trend 2 |
|---------|---------|
| ![Trend1](screenshots/weathertrends1.png) | ![Trend2](screenshots/weathertrends2.png) |

---

## 🛠️ Technologies Used

- **[Flutter](https://flutter.dev/)** – Cross-platform UI toolkit  
- **Dart** – Programming language  
- **[Open-Meteo API](https://open-meteo.com/)** – Free weather API  

---

## 🚀 Getting Started

Follow these steps to **run the app locally**:

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/vibhav22022000/Flutter-Weather-App.git
cd Flutter-Weather-App
````

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ API Setup

This app uses **Open-Meteo API** (no key required, free and open). By default, the app fetches weather for the current location.

* To change default city, edit `lib/services/api_service.dart` and set your desired coordinates.
* Optional: For advanced users, you can integrate other APIs like OpenWeatherMap by updating the service class.

### 4️⃣ Run the App

```bash
flutter run
```

> ⚡ Tip: If you are using a physical device, enable USB debugging (Android) or add your device for iOS.

### 5️⃣ Customization

* **Theme**: Switch between Light/Dark mode in settings
* **Units**: Change temperature between °C and °F
* **Notifications**: Enable to get weather alerts

---

## 📂 Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── forecast_screen.dart
│   ├── comparison_screen.dart
├── widgets/
│   ├── weather_card.dart
│   ├── forecast_chart.dart
├── services/
│   └── api_service.dart
```

---

## 🧑‍💻 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a new branch (`feature/your-feature`)
3. Commit your changes
4. Push to your fork
5. Submit a Pull Request

---

## 📜 License

This project is licensed under the **MIT License**.
Feel free to use, modify, and distribute it as per the license.

---

## 🙌 Acknowledgements

* [Open-Meteo API](https://open-meteo.com/) for weather data
* Flutter community for plugins & support


