//
//  SearchCityControllerViewController.swift
//  WeatherApp
//
//  Created by Xuanwei Zhang on 10/28/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import RealmSwift

class SearchCityControllerViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    let arr = ["Seattle WA, USA", "Seaside CA, USA"]
    var arrCityInfo : [CityInfo] = [CityInfo]()
    
    @IBOutlet weak var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.arrCityInfo.removeAll()
        self.tblView.reloadData()
        if searchText.count < 3 {
            return
        }
        getCitiesFromSearch(searchText)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCityInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let content = arrCityInfo[indexPath.row].localizedName + ", " + arrCityInfo[indexPath.row].administrativeID + ", " + arrCityInfo[indexPath.row].countryLocalizedName
        cell.textLabel?.text = content
        return cell
    }
    
    func getSearchURL(_ searchText : String) -> String{
        return locationSearchUrl + "apikey=" + apiKey + "&q=" + searchText
    }
        
    func getCitiesFromSearch(_ searchText : String) {
        // Network call from there
        let url = getSearchURL(searchText)
        AF.request(url).responseJSON { response in
            
            if response.error != nil {
                print(response.error?.localizedDescription)
            }
            // You will receive JSON array
            // Parse the JSON array
            // Add values in arrCityInfo
            // Reload table with the values
            let cities = JSON( response.data!).array
            for city in cities!{
                let cityInfo = CityInfo()
                cityInfo.key = city["Key"].stringValue
                cityInfo.type = city["Type"].stringValue
                cityInfo.localizedName = city["LocalizedName"].stringValue
                cityInfo.countryLocalizedName = city["Country"]["LocalizedName"].stringValue
                cityInfo.administrativeID = city["AdministrativeArea"]["ID"].stringValue
                self.arrCityInfo.append(cityInfo)
            }
            self.tblView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // You will get the Index of the city info from here and then add it into the realm Database
        // Once the city is added in the realm DB pop the navigation view controller
        let cityInfo = arrCityInfo[indexPath.row]
        self.addCityInfoDB(cityInfo)
        print("click on \(indexPath.row) and save")
    }

    func addCityInfoDB(_ cityInfo : CityInfo){
        do{
            let realm = try Realm()
            try realm.write {
                realm.add(cityInfo, update: .modified)
            }
            print("save into db")
        }catch{
            print("Error in getting values from DB \(error)")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
