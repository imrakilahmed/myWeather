//
//  ChangeCityViewController.swift
//  myWeather
//
//  Created by Rakil Ahmed on 6/29/19.
//  Copyright © 2019 Rakil Ahmed. All rights reserved.
//

import UIKit

//protocol declaration here:
protocol ChangeCityDelegate {
    func userEnteredANewCityName (city: String)
}

class ChangeCityVC: UIViewController {
    
    override func viewDidLoad() {
        // On this view, only left-right swipe works
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    //Declaring the delegate variable here:
    var delagate : ChangeCityDelegate?
    
    //linked IBOutlets to the text field:
    @IBOutlet weak var changeCityTextField: UITextField!
    
    
    //This is the IBAction that gets called when the user taps on the "Get Weather" button:
    @IBAction func getWeatherPressed(_ sender: UIButton) {
        
        //Getting the city name the user entered in the text field
        let cityName = changeCityTextField.text!
        
        //If we have a delegate set, calling the method userEnteredANewCityName
        delagate?.userEnteredANewCityName(city: cityName)
        view.endEditing(true)
        
        //Dismissing the Change City View Controller to go back to the WeatherViewController
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
