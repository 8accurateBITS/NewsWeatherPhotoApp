import SwiftUI
import CoreLocation
import Photos
import Combine

class MainViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var reutersNews: [NewsArticle] = []
    @Published var bbcNews: [NewsArticle] = []
    @Published var currentWeather: Weather?
    @Published var currentTime: String = ""
    @Published var photos: [UIImage] = []
    @Published var currentPhoto: UIImage = UIImage()
    @Published var currentPhotoIndex: Int = 0
    
    private let locationManager = CLLocationManager()
    private var timer: Timer?
    private var newsUpdateTimer: Timer?
    private var photoUpdateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    func startUpdates() {
        updateTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
        
        updateNews()
        newsUpdateTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.updateNews()
        }
        
        locationManager.startUpdatingLocation()
        
        loadPhotos()
        autoAdvancePhotos()
    }
    
    // MARK: - Time Update
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        DispatchQueue.main.async {
            self.currentTime = formatter.string(from: Date())
        }
    }
    
    // MARK: - Location Manager Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        fetchWeather(for: location)
    }
    
    // MARK: - Weather Fetching
    private func fetchWeather(for location: CLLocation) {
        let urlString = "https://api.weatherapi.com/v1/current.json?key=YOUR_WEATHER_API_KEY&q=\(location.coordinate.latitude),\(location.coordinate.longitude)&aqi=no"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.currentWeather = Weather(
                        location: response.location.name,
                        temperature: response.current.temp_c,
                        condition: response.current.condition.text,
                        humidity: response.current.humidity,
                        windSpeed: response.current.wind_kph
                    )
                }
            } catch {
                print("Fehler beim Dekodieren des Wetters: \(error)")
            }
        }.resume()
    }
    
    // MARK: - News Fetching
    private func updateNews() {
        fetchReutersNews()
        fetchBBCNews()
    }
    
    private func fetchReutersNews() {
        let urlString = "https://newsapi.org/v2/everything?sources=reuters&sortBy=publishedAt&language=de&apiKey=YOUR_NEWS_API_KEY"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode(NewsResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.reutersNews = response.articles.prefix(5).map { article in
                        NewsArticle(
                            id: UUID(),
                            title: article.title,
                            description: article.description ?? "Keine Beschreibung",
                            source: "Reuters",
                            url: article.url
                        )
                    }
                }
            } catch {
                print("Fehler beim Fetchen von Reuters News: \(error)")
            }
        }.resume()
    }
    
    private func fetchBBCNews() {
        let urlString = "https://newsapi.org/v2/everything?sources=bbc-news&sortBy=publishedAt&language=de&apiKey=YOUR_NEWS_API_KEY"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode(NewsResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.bbcNews = response.articles.prefix(5).map { article in
                        NewsArticle(
                            id: UUID(),
                            title: article.title,
                            description: article.description ?? "Keine Beschreibung",
                            source: "BBC Worldwide",
                            url: article.url
                        )
                    }
                }
            } catch {
                print("Fehler beim Fetchen von BBC News: \(error)")
            }
        }.resume()
    }
    
    // MARK: - Photo Management
    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.loadPhotos()
            }
        }
    }
    
    private func loadPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var loadedPhotos: [UIImage] = []
        
        fetchResult.enumerateObjects { asset, _, _ in
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.resizeMode = .exact
            
            manager.requestImage(for: asset, targetSize: CGSize(width: 1920, height: 1080), contentMode: .aspectFill, options: options) { image, _ in
                if let image = image {
                    loadedPhotos.append(image)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.photos = loadedPhotos
            if !loadedPhotos.isEmpty {
                self.currentPhoto = loadedPhotos[0]
            }
        }
    }
    
    func nextPhoto() {
        guard !photos.isEmpty else { return }
        currentPhotoIndex = (currentPhotoIndex + 1) % photos.count
        currentPhoto = photos[currentPhotoIndex]
    }
    
    func previousPhoto() {
        guard !photos.isEmpty else { return }
        currentPhotoIndex = (currentPhotoIndex - 1 + photos.count) % photos.count
        currentPhoto = photos[currentPhotoIndex]
    }
    
    private func autoAdvancePhotos() {
        photoUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.nextPhoto()
        }
    }
    
    deinit {
        timer?.invalidate()
        newsUpdateTimer?.invalidate()
        photoUpdateTimer?.invalidate()
    }
}

// MARK: - Data Models
struct NewsArticle {
    let id: UUID
    let title: String
    let description: String
    let source: String
    let url: String
}

struct Weather {
    let location: String
    let temperature: Double
    let condition: String
    let humidity: Int
    let windSpeed: Double
}

struct NewsResponse: Codable {
    let articles: [NewsArticleResponse]
}

struct NewsArticleResponse: Codable {
    let title: String
    let description: String?
    let url: String
}

struct WeatherResponse: Codable {
    let location: LocationData
    let current: CurrentWeather
}

struct LocationData: Codable {
    let name: String
}

struct CurrentWeather: Codable {
    let temp_c: Double
    let condition: WeatherCondition
    let humidity: Int
    let wind_kph: Double
}

struct WeatherCondition: Codable {
    let text: String
}
