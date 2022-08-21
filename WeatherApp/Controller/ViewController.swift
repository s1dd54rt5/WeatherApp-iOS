//
//  ViewController.swift
//  WeatherApp
//
//  Created by Siddharth Singh on 20/08/22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var weatherTypeLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var weatherMainLabel: UILabel!
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    let locationManager = CLLocationManager()
    
    var weatherInfo: Weather?
    
    func startLoading() {
        cityLabel.textColor = UIColor.systemIndigo
        temperatureLabel.textColor = UIColor.systemIndigo
        weatherTypeLabel.textColor = UIColor.systemIndigo
        weatherMainLabel.textColor = UIColor.systemIndigo
        loader.startAnimating()
    }
    
    func stopLoading() {
        cityLabel.textColor = UIColor.white
        temperatureLabel.textColor = UIColor.white
        weatherTypeLabel.textColor = UIColor.white
        weatherMainLabel.textColor = UIColor.white
        loader.stopAnimating()
    }
    
    func requestLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func makeRequest(latitude: String, longitude: String, completed: @escaping (_ data: Weather?) -> Void) {
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=01c3966469b8a7d87352aed9bbf50289&units=metric")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return completed(nil) }
            let weatherData = try? JSONDecoder().decode(Weather.self, from: data)
            return completed(weatherData)
        }
        
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLoading()
        requestLocation()
    }
    
    func initialLoad(myLat: Double, myLon: Double) {
        if cityLabel.text == "City Name" {
            startLoading()
        }
        
        // MAKE REQUEST
        makeRequest(latitude: String(format: "%f", myLat), longitude: String(format: "%f", myLon)) { data in
            if data != nil {
                DispatchQueue.main.async { [self] in
                    updateUI(weather: data!)
                }
            }
        }
    }
    
    func updateUI(weather: Weather) {
        temperatureLabel.text = "\(String(format: "%.1f", weather.main.temp))°"
        cityLabel.text = "Currently in \(weather.name)"
        weatherTypeLabel.text = weather.weather[0].main
        stopLoading()
    }
    
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Location data received.")
            print(location)
            initialLoad(myLat: location.coordinate.latitude, myLon: location.coordinate.longitude)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get users location.")
    }
}

