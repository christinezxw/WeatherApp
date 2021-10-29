//
//  ViewController.swift
//  WeatherApp
//
//  Created by Xuanwei Zhang on 10/28/21.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var arr : [String] = [String]()
    var arrCurrentWeather : [CurrentWeather] = [CurrentWeather]()
    
    @IBOutlet weak var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadCurrentConditions()
    }
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = arr[indexPath.row] // replace this with values from arrCurrentWeather array
                return cell
    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            arr.remove(at: indexPath.row)
//            arrCurrentWeather.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//
//        }
//    }
//
    func loadCurrentConditions(){
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        do{
            let realm = try Realm()
            let cityInfos = realm.objects(CityInfo.self)
            getAllCurrentWeather(Array(cityInfos)).done { currentWeathers in
                self.arr.removeAll()
                            
                for currentWeather in currentWeathers{
                    self.arr.append( "\(currentWeather.cityInfoName), \(currentWeather.weatherText), \(currentWeather.temp)℉" )
                }
               self.tblView.reloadData()
            }
        }catch{
            print("Error in reading Database \(error)")
        }
    }
    
    func getAllCurrentWeather(_ cities: [CityInfo] ) -> Promise<[CurrentWeather]> {
            
        var promises: [Promise< CurrentWeather>] = []
        
        for i in 0 ..< cities.count {
            promises.append( getCurrentWeather(cities[i].key) )
        }
        
        return when(fulfilled: promises)
    }
    
    
    func getCurrentWeather(_ cityKey : String) -> Promise<CurrentWeather>{
        return Promise<CurrentWeather> { seal -> Void in
            let url = getCurrentWeatherURL(cityKey) // build URL for current weather here
            
            AF.request(url).responseJSON { response in
                
                if response.error != nil {
                    seal.reject(response.error!)
                }
                let currentWeather = CurrentWeather()
                let weathers = JSON( response.data!).array
                guard let weather = weathers!.first else {
                    return
                }
                currentWeather.cityKey = cityKey
                do{
                    let realm = try Realm()
                    currentWeather.cityInfoName = realm.object(ofType: CityInfo.self, forPrimaryKey: cityKey)!.localizedName
                }catch{
                    print("Error in getting values from DB \(error)")
                }
                currentWeather.weatherText = weather["WeatherText"].stringValue
                currentWeather.epochTime = weather["EpochTime"].intValue
                currentWeather.isDayTime = weather["IsDayTime"].boolValue
                currentWeather.temp = weather["Temperature"]["Imperial"]["Value"].intValue
                seal.fulfill(currentWeather)
            }
        }
    }
    
    func getCurrentWeatherURL(_ cityKey : String) -> String{
        return currentConditionUrl + cityKey + "?apikey=" + apiKey
    }

}

