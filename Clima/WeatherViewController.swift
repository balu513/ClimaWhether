//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit

import CoreLocation

import Alamofire

import SwiftyJSON

import SwiftyJSON
class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityNameDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let weatherDataModel=WeatherDataModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //TODO:Set up the location manager here.
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWhetherData(params : [String:String], url:String) {
        
        Alamofire.request(url, method: .get, parameters:params).responseJSON { response in
            if response.result.isSuccess {
                let whetherJson:JSON = JSON(response.result.value!)
                
                print(whetherJson)
                
                self.updayeWhetherData(whetherJson: whetherJson)
                
            }else{
               // print(String(response.result.error))
                self.cityLabel.text = "network issue"
            }
        }
        
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updayeWhetherData(whetherJson : JSON){
        
        if let temp = whetherJson["main"]["temp"].double {
        weatherDataModel.temp = Int(temp - 273.15)
        weatherDataModel.city = whetherJson["name"].stringValue
        weatherDataModel.condition = whetherJson["waether"][0]["id"].intValue
        weatherDataModel.weatherIcon=weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        }else{
            cityLabel.text = "Weather Unavailable"
        }
        
        updateUIWithWeatherData()
        
    }
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/

    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        temperatureLabel.text = String(weatherDataModel.temp)
        cityLabel.text = weatherDataModel.city
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIcon)
    }
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        
        if(location.horizontalAccuracy > 0)
        {
            locationManager.stopUpdatingLocation()
            locationManager.delegate=nil
            
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            
            print("lat : \(lat)  lan:  \(lon)")
            
            let params : [String:String] = ["lat":lat, "lon":lon, "apikey":APP_ID]
            
            getWhetherData(params: params, url: WEATHER_URL)
            
            
        }
        
    }
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error.localizedDescription)
        cityLabel.text="location unavialable"
        
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
   
    
  
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    
    func userEnteredCity(cityName : String){
        
        print("City Name from 2nd screen to 1st screen is: \(cityName)")
        
        let params : [String:String] = ["q":cityName , "appid":APP_ID]
        
        getWhetherData(params: params, url: WEATHER_URL)
        
    }
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"
        {
            let destination = segue.destination as! ChangeCityViewController
            
            destination.delgate = self
        }
    }
    
    
    
}


