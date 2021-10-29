//
//  CityInfo.swift
//  WeatherApp
//
//  Created by Xuanwei Zhang on 10/28/21.
//

import Foundation
import RealmSwift

class CityInfo : Object {
    @objc dynamic var key: String  = ""
    @objc dynamic var type : String = ""
    @objc dynamic var localizedName : String = ""
    @objc dynamic var countryLocalizedName : String = ""
    @objc dynamic var administrativeID : String = ""
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
}
