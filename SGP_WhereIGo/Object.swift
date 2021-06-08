//
//  Hospital.swift
//  HospitalMap
//
//  Created by Game on 2021/05/02.
//

import Foundation

import MapKit

import Contacts



class Object: NSObject,MKAnnotation {
    let title: String?
    let category: String
    let category_M: String
    let coordinate: CLLocationCoordinate2D
    let addr: String
    let addr_short: String
    
    init(title:String,category:String,coordinate:CLLocationCoordinate2D, addr: String, category_M: String, addr_short: String){
        self.title = title
        self.category = category
        self.category_M = category_M
        self.coordinate = coordinate
        self.addr = addr
        self.addr_short = addr_short
        super.init()
    }
    
    var subtitle: String?{
        return category_M
    }
    
    func mapItem() -> MKMapItem{
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate,addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}
