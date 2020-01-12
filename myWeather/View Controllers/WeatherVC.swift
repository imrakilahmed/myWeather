//
//  WeatherViewController.swift
//  myWeather
//
//  Created by Rakil Ahmed on 6/29/19.
//  Copyright © 2019 Rakil Ahmed. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SVProgressHUD

class WeatherVC: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    // Constants (Confidential)
    let WEATHER_URL = "https://api.darksky.net/forecast/"
    let APP_ID = "ca710bf4f6992e5acf8cd6fdfb79bdbc"
    
    // Declaring instance variables
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDM()
    var isToggle : Bool = false

    // Linked IBOutlets
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsTempLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func toggle(_ sender: Any) {
        
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            temperatureLabel.text = "\(weatherDataModel.temperatureInFar)°"
            feelsTempLabel.text = "Feels like: \(weatherDataModel.feelsTempInFer)°"
            lowTempLabel.text = "\(weatherDataModel.lowTempInFer)º"
            highTempLabel.text = "\(weatherDataModel.highTempInFer)º"
            isToggle = false
        case 1:
            temperatureLabel.text = "\(weatherDataModel.temperatureInCel)°"
            feelsTempLabel.text = "Feels like: \(weatherDataModel.feelsTempInCel)°"
            lowTempLabel.text = "\(weatherDataModel.lowTempInCel)º"
            highTempLabel.text = "\(weatherDataModel.highTempInCel)º"
            isToggle = true
        default:
            break
        }
    }
    
    func recognizeSwipe() {
        
        // Swipe left to search the weather for any city
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Swipe down to refresh the content on the page
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    func initializeLocationManager() {
        
        SVProgressHUD.setBackgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.show()
        DispatchQueue.global(qos: .default).async(execute: {
            
            // Setting up the location manager here.
            self.locationManager.requestWhenInUseAuthorization()
            if(CLLocationManager.locationServicesEnabled()){
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
            }
            
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss(withDelay: 1.5)
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recognizeSwipe()
        initializeLocationManager()
    }

    // MARK: - Networking
    // getWeatherData method here:
    func getWeatherData(url : String) {
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                self.cityLabel.text = "Connection Issues!"
                self.conditionLabel.text = "-"
                self.weatherIcon.image = UIImage(named: "none")
                self.temperatureLabel.text = "-"
                self.feelsTempLabel.text = "-"
            }
        }
    }
    
    // MARK: - JSON Parsing
    // updateWeatherData method here:
    // var iconName : String = ""
    func updateWeatherData(json : JSON) {
        // updating the UI by getting information from the JSON response
        if let origTemp = json["currently"]["temperature"].double, let feelsTemp = json["currently"]["apparentTemperature"].double, let lowTemp = json["daily"]["data"][0]["temperatureLow"].double, let highTemp = json["daily"]["data"][0]["temperatureHigh"].double {
            
            weatherDataModel.temperatureInCel = Int((origTemp - 32) / 1.8)
            weatherDataModel.temperatureInFar = Int(origTemp)
            
            weatherDataModel.feelsTempInCel = Int((feelsTemp - 32) / 1.8)
            weatherDataModel.feelsTempInFer = Int(feelsTemp)
            
            weatherDataModel.lowTempInCel = Int((lowTemp - 32) / 1.8)
            weatherDataModel.lowTempInFer = Int(lowTemp)
            weatherDataModel.highTempInCel = Int((highTemp - 32) / 1.8)
            weatherDataModel.highTempInFer = Int(highTemp)
            
            weatherDataModel.condition = json["minutely"]["summary"].stringValue            // for user's current location
            weatherDataModel.cityCondition = json["currently"]["summary"].stringValue       // for user entered cities
            weatherDataModel.currentWeatherIcon = json["currently"]["icon"].stringValue     // for both current and user entered cities
            
            updateUIWithWeatherData()
        }
        else {
            
            SVProgressHUD.setBackgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
            SVProgressHUD.setDefaultMaskType(.gradient)
            SVProgressHUD.showError(withStatus: "Error!")
            SVProgressHUD.dismiss(withDelay: 1.5)
            
            dayLabel.text = "Sorry :("
            cityLabel.text = "No Data Available!"
            conditionLabel.text = ""
            feelsTempLabel.text = ""
            weatherIcon.image = UIImage(named: "none")
            temperatureLabel.text = ""
            lowTempLabel.text = ""
            highTempLabel.text = ""
            feelsTempLabel.text = "-"
        }
    }
    
    func updateBGImage(name : String)
    {
        switch name {
        case "clear-day":
            backgroundView.loadGif(name: "day")
        case "clear-night":
            backgroundView.loadGif(name: "night")
        case "rain":
            backgroundView.loadGif(name: "rainy")
        case "thunderstorm":
            backgroundView.loadGif(name: "thunderstorm")
        case "snow":
            backgroundView.loadGif(name: "snowy")
        case "partly-cloudy-night":
            backgroundView.loadGif(name: "cloudy")
        case "partly-cloudy-day":
            backgroundView.loadGif(name: "cloudy")
        case "cloudy":
            backgroundView.loadGif(name: "cloudy")
        case "fog":
            backgroundView.loadGif(name: "foggy")
        case "wind":
            backgroundView.loadGif(name: "windy")
        default:
            backgroundView.image = UIImage(named: "nightBg")
        }
    }
    
    // MARK: - UI Updates
    // updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        // updating the toggle stage (on/off)
        if isToggle == false {
            temperatureLabel.text = "\(weatherDataModel.temperatureInFar)°"
            feelsTempLabel.text = "Feels like: \(weatherDataModel.feelsTempInFer)°"
            lowTempLabel.text = "\(weatherDataModel.lowTempInFer)º"
            highTempLabel.text = "\(weatherDataModel.highTempInFer)º"
        }
        else {
            temperatureLabel.text = "\(weatherDataModel.temperatureInCel)°"
            feelsTempLabel.text = "Feels like: \(weatherDataModel.feelsTempInCel)°"
            lowTempLabel.text = "\(weatherDataModel.lowTempInCel)º"
            highTempLabel.text = "\(weatherDataModel.highTempInCel)º"
        }
        
        weatherIcon.image = UIImage(named: weatherDataModel.currentWeatherIcon)
        updateBGImage(name: weatherDataModel.currentWeatherIcon)
        
        if (weatherDataModel.condition == "")
        {
            conditionLabel.text = String(weatherDataModel.cityCondition)
            conditionLabel.adjustsFontSizeToFitWidth = true
        }
        else
        {
            conditionLabel.text = String(weatherDataModel.condition.dropLast())
            conditionLabel.adjustsFontSizeToFitWidth = true
        }
        
        // checking and updating if it's day or night as well as the week day
        let day = Date()
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE | MMMM dd"
        dayLabel.text = dayFormatter.string(from: day)
    }
    
    // MARK: - Location Manager Delegate Methods
    // didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]   // for the most accurate result
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()  // stop updating location once accurate result found
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            getWeatherData(url: "\(WEATHER_URL)\(APP_ID)/\(latitude),\(longitude)")
            
            let loco = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(loco) { (placemarks, err) in
                if let placemark = placemarks?[0] {
                    self.weatherDataModel.city = placemark.subLocality!
                    self.cityLabel.text = ("\(self.weatherDataModel.city) | \(placemark.isoCountryCode!)")
                    self.cityLabel.adjustsFontSizeToFitWidth = true
                }
            }
        }
    }
    
    // didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // MARK: - Change City Delegate methods
    // userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
    
        CLGeocoder().geocodeAddressString(city) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    
                    SVProgressHUD.setBackgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
                    SVProgressHUD.setDefaultMaskType(.gradient)
                    SVProgressHUD.show()
                    DispatchQueue.global(qos: .default).async(execute: {
                        
                        self.getWeatherData(url: "\(self.WEATHER_URL)\(self.APP_ID)/\(latitude),\(longitude)")
                        
                        DispatchQueue.main.async(execute: {
                            SVProgressHUD.dismiss(withDelay: 1.5)
                        })
                    })
                    
                    let loco = CLLocation(latitude: latitude, longitude: longitude)
                    let geoCoder = CLGeocoder()
                    geoCoder.reverseGeocodeLocation(loco) { (placemarks, err) in
                        if let placemark = placemarks?[0] {
                            if(placemark.locality == nil)
                            {
                                if (placemark.subLocality == nil)
                                {
                                    self.weatherDataModel.city = city
                                }
                                else
                                {
                                    self.weatherDataModel.city = placemark.subLocality!
                                }
                            }
                            else
                            {
                                self.weatherDataModel.city = placemark.locality!
                            }
                            self.cityLabel.text = ("\(self.weatherDataModel.city) | \(placemark.isoCountryCode!)")
                            self.cityLabel.adjustsFontSizeToFitWidth = true
                        }
                    }
                }
            }
        }
    }
    
    // prepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goRight" {
            let destinationVC = segue.destination as! ChangeCityVC
            destinationVC.delagate = self
        }
    }
}

extension UIViewController {
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                performSegue(withIdentifier: "goLeft", sender: self)
            case UISwipeGestureRecognizer.Direction.left:
                performSegue(withIdentifier: "goRight", sender: self)
            case UISwipeGestureRecognizer.Direction.down:
                viewDidLoad()
            default:
                break
            }
        }
    }
}
