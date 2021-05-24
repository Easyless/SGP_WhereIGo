//
//  Hospital.swift
//  HospitalMap
//
//  Created by Game on 2021/05/02.
//

import Foundation

import MapKit

import Contacts



class Hospital: NSObject,MKAnnotation {
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    init(title:String,locationName:String,coordinate:CLLocationCoordinate2D){
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String?{
        return locationName
    }
    
    func mapItem() -> MKMapItem{
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate,addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}
