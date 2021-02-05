//
//  WeatherViewController.swift
//  OpenWeatherApp
//
//  Created by Arkadijs Makarenko on 04/02/2021.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate{
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    let weatherDataModel = WeatherDataModel()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    //MARK: - CLLOcationManager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            print("longitude:  \(location.coordinate.longitude),lat: \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String:String] = ["lat": latitude , "lon": longitude , "appid": weatherDataModel.apiId]
            
            getWeatherData(url: weatherDataModel.apiUrl, params: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:", error)
    }
    
    func getWeatherData(url: String, params: [String: String]){
        
        AF.request(url, method: .get, parameters: params).responseJSON { (response) in
            if response.value != nil {
                let weatherJSON: JSON = JSON(response.value!)
                print("weatherJSON: ", weatherJSON)
                //update
                self.updateWeatherData(json: weatherJSON)
            }else{
                print("error, \(String(describing: response.error))")
                self.cityLabel.text = "Weather unavailable!"
            }
        }
    }
    
    func updateWeatherData(json: JSON){
        
        if let tempResult = json["main"]["temp"].double{
            weatherDataModel.temp = Int(tempResult - 273.15)
            
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUI()
            
        }else{
            self.cityLabel.text = "Weather unavailable!"
        }
    }
    
    //MARK: - UpdateUI
    
    func updateUI(){
        cityLabel.text = weatherDataModel.city
        tempLabel.text = "\(weatherDataModel.temp) º"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "city"{
            let vc = segue.destination as! ChangeCityViewController
            vc.delegate = self
        }
    }
    func userEnterCityName(city: String) {
        print(city)
        let params: [String:String] = ["q": city , "appid": weatherDataModel.apiId]
        
        getWeatherData(url: weatherDataModel.apiUrl, params: params)
    }
}
