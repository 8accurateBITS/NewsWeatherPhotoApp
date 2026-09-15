# News Weather Photo App

Eine iOS App im Querformat, die Nachrichten von Reuters International und BBC Worldwide, das aktuelle Wetter am Standort des Nutzers, die aktuelle Uhrzeit und eine automatische Foto-Slideshow anzeigt.

## Features

### 📰 Nachrichten
- **Reuters International**: Live-Nachrichten von Reuters
- **BBC Worldwide**: Live-Nachrichten von BBC
- Automatische Aktualisierung alle 5 Minuten
- Scrollbarer News-Feed mit Titel und Beschreibung

### 🌤️ Wetter
- **Standortbasiertes Wetter**: Automatische Erkennung des Nutzerstandorts
- **Anzeigeinformationen**:
  - Aktuelle Temperatur in Celsius
  - Wetterbedingung (z.B. sonnig, bewölkt, regnerisch)
  - Luftfeuchtigkeit in Prozent
  - Windgeschwindigkeit in km/h
- **Live-Aktualisierung** bei Standortwechsel

### ⏰ Uhrzeit
- Große digitale Anzeige der aktuellen Uhrzeit
- Echtzeit-Aktualisierung jede Sekunde
- Format: HH:MM:SS

### 📸 Foto-Slideshow
- **Automatische Slideshow**: Fotos wechseln alle 5 Sekunden
- **Manuelle Navigation**: Vor- und Zurück-Tasten
- **Fotobibliotheks-Integration**: Lädt Fotos aus der iOS-Fotobibliothek
- **Querformat-optimiert**: Vollbildanzeige im Landscape-Modus
- **Fotocounter**: Zeigt aktuelle Position in der Slideshow an

## Layout (Querformat)

```
┌─────────────────────────────────────────────────────────────┐
│  NACHRICHTEN  │          WETTER & UHRZEIT          │  FOTOS  │
│               │                                     │         │
│ Reuters       │  Aktuelle Uhrzeit: 14:30:45       │  [Foto] │
│ ─────────────┼─────────────────────────────────────┤    1/42 │
│ • Artikel 1   │                                     │         │
│ • Artikel 2   │  Aktuelles Wetter                  │  ◀ ▶    │
│ • Artikel 3   │  ─────────────────                 │         │
│               │  Temperatur: 22.5°C                 │         │
│ BBC           │  Bedingung: Teilweise bewölkt      │         │
│ ────────────┼─────────────────��────────────────────         │
│ • Artikel 1   │  Luftfeuchtigkeit: 65%             │         │
│ • Artikel 2   │  Windgeschwindigkeit: 12.3 km/h    │         │
│ • Artikel 3   │                                     │         │
└─────────────────────────────────────────────────────────────┘
```

## Installation

### Anforderungen
- Xcode 14.0 oder höher
- iOS 15.0 oder höher
- Swift 5.7+

### Schritt-für-Schritt-Anleitung

1. **Repository klonen**
   ```bash
   git clone https://github.com/8accurateBITS/NewsWeatherPhotoApp.git
   cd NewsWeatherPhotoApp
   ```

2. **API-Schlüssel konfigurieren**
   - NewsAPI Schlüssel: https://newsapi.org
   - WeatherAPI Schlüssel: https://www.weatherapi.com
   
   Öffne `MainViewModel.swift` und ersetze:
   ```swift
   // Zeile ~103
   let urlString = "https://newsapi.org/v2/everything?sources=reuters&sortBy=publishedAt&language=de&apiKey=YOUR_NEWS_API_KEY"
   
   // Zeile ~82
   let urlString = "https://api.weatherapi.com/v1/current.json?key=YOUR_WEATHER_API_KEY&q=..."
   ```

3. **In Xcode öffnen**
   ```bash
   open NewsWeatherPhotoApp.xcodeproj
   ```

4. **Build und Run**
   - Wähle ein iPhone-Gerät oder Simulator
   - Drücke `Cmd + R` zum Ausführen

## Berechtigungen

Die App benötigt folgende Berechtigungen:

- **Standort**: Zur Anzeige des lokalen Wetters
- **Fotobibliothek**: Zum Laden von Fotos für die Slideshow
- **Querformat-Orientierung**: App läuft nur im Landscape-Modus

## Architektur

### Hauptkomponenten

| Komponente | Funktion |
|-----------|----------|
| `ContentView.swift` | Hauptbenutzeroberfläche (SwiftUI) |
| `MainViewModel.swift` | Business Logic, Datenmanagement |
| `NewsWeatherPhotoApp.swift` | App Entry Point |

### Datenfluss

```
MainViewModel
├── News Fetching (NewsAPI)
│   ├── Reuters International
│   └── BBC Worldwide
├── Weather Fetching (WeatherAPI)
│   ├── Location Manager
│   └── Current Weather
├── Time Updates
│   └── Timer (1 Sekunde)
└── Photo Management
    ├── PHPhotoLibrary
    └── Auto-Advance (5 Sekunden)
```

## Konfiguration

### News-Update-Intervall
Standard: 5 Minuten (300 Sekunden)

```swift
newsUpdateTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true)
```

### Foto-Slideshow-Intervall
Standard: 5 Sekunden

```swift
photoUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true)
```

### Wetter-Update
Wird automatisch bei Standortwechsel aktualisiert

## Fehlerbehebung

### Problem: "Wetter wird geladen..." bleibt stehen
**Lösung**: 
- Stelle sicher, dass du den WeatherAPI-Schlüssel korrekt eingegeben hast
- Prüfe die Internetverbindung
- Aktiviere Standortzugriff in den Einstellungen

### Problem: Keine Fotos werden angezeigt
**Lösung**:
- Erlaube der App den Zugriff auf die Fotobibliothek
- Stelle sicher, dass Fotos auf dem Gerät vorhanden sind
- Tippe auf "Zugriff anfordern" im App

### Problem: News werden nicht angezeigt
**Lösung**:
- Verifiziere den NewsAPI-Schlüssel
- Prüfe die Internetverbindung
- Stelle sicher, dass du das richtige API-Quota nicht erreicht hast

## API-Dokumentation

### NewsAPI
- **Website**: https://newsapi.org
- **Sources**: 
  - Reuters: `reuters`
  - BBC: `bbc-news`
- **Kostenlos**: 100 Requests pro Tag

### WeatherAPI
- **Website**: https://www.weatherapi.com
- **Features**: Aktuelle Wettervorhersagen, Standortdaten
- **Kostenlos**: 1,000,000 Requests pro Monat

## Lizenz

MIT License - siehe LICENSE Datei

## Support

Bei Fragen oder Problemen öffne bitte ein GitHub Issue.

---

**Version**: 1.0.0  
**Letzte Aktualisierung**: September 2026  
**Autor**: 8accurateBITS
