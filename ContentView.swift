import SwiftUI
import CoreLocation
import Photos

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if horizontalSizeClass == .regular {
                // Landscape Orientation
                HStack(spacing: 20) {
                    // Left: News
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Reuters International")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(viewModel.reutersNews, id: \.id) { article in
                                    NewsArticleView(article: article)
                                }
                            }
                        }
                        
                        Divider()
                            .background(Color.gray)
                        
                        Text("BBC Worldwide")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(viewModel.bbcNews, id: \.id) { article in
                                    NewsArticleView(article: article)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    // Middle: Weather & Time
                    VStack(spacing: 30) {
                        // Current Time
                        VStack(spacing: 10) {
                            Text("Aktuelle Uhrzeit")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(viewModel.currentTime)
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                                .foregroundColor(.cyan)
                        }
                        
                        Divider()
                            .background(Color.gray)
                        
                        // Weather
                        VStack(spacing: 15) {
                            Text("Aktuelles Wetter")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            if let weather = viewModel.currentWeather {
                                VStack(spacing: 10) {
                                    Text(weather.location)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    HStack(spacing: 20) {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("Temperatur")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text("\(String(format: "%.1f", weather.temperature))°C")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("Bedingung")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text(weather.condition)
                                                .font(.body)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    HStack(spacing: 20) {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("Luftfeuchtigkeit")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text("\(weather.humidity)%")
                                                .font(.body)
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("Windgeschwindigkeit")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text("\(String(format: "%.1f", weather.windSpeed)) km/h")
                                                .font(.body)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            } else {
                                Text("Wetter wird geladen...")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(maxWidth: 300)
                    .padding()
                    
                    // Right: Photo Slideshow
                    VStack(spacing: 15) {
                        Text("Fotos")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if !viewModel.photos.isEmpty {
                            ZStack {
                                Image(uiImage: viewModel.currentPhoto)
                                    .resizable()
                                    .scaledToFill()
                                    .cornerRadius(8)
                                
                                VStack {
                                    HStack {
                                        Text("\(viewModel.currentPhotoIndex + 1) / \(viewModel.photos.count)")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(4)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    
                                    Spacer()
                                }
                            }
                            
                            HStack(spacing: 10) {
                                Button(action: { viewModel.previousPhoto() }) {
                                    Image(systemName: "chevron.left.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.cyan)
                                }
                                
                                Spacer()
                                
                                Button(action: { viewModel.nextPhoto() }) {
                                    Image(systemName: "chevron.right.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.cyan)
                                }
                            }
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("Keine Fotos gefunden")
                                    .foregroundColor(.gray)
                                
                                Button("Zugriff anfordern") {
                                    viewModel.requestPhotoLibraryAccess()
                                }
                                .foregroundColor(.cyan)
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .onAppear {
                    viewModel.startUpdates()
                }
            } else {
                // Portrait Orientation
                VStack(spacing: 15) {
                    Text("Bitte drehen Sie Ihr Gerät ins Querformat")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(maxHeight: .infinity)
            }
        }
    }
}

struct NewsArticleView: View {
    let article: NewsArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(article.title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text(article.description)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            Text(article.source)
                .font(.caption2)
                .foregroundColor(.cyan)
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
}

#Preview {
    ContentView()
}
