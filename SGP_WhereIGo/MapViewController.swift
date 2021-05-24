//
//  MapViewController.swift
//  HospitalMap
//
//  Created by Game on 2021/04/13.
//

import UIKit
import MapKit

class MapViewController: UIViewController ,MKMapViewDelegate{
    
    

    @IBOutlet weak var mapView: MKMapView!
    var posts = NSMutableArray()
    
    let regionRadius: CLLocationDistance = 5000
    
    func centerMapOnLocation(location: CLLocation) {

            let coordinateRegion = MKCoordinateRegion(center: location.coordinate,

                                                      latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)

            mapView.setRegion(coordinateRegion, animated: true)

        }
    
    var hospitals : [Hospital] = []
    
    func loadInitalData() {
        
        for post in posts {
            let yadmNm = (post as AnyObject).value(forKey: "yadmNm") as! NSString as String
            let addr = (post as AnyObject).value(forKey: "addr") as! NSString as String
            let XPos = (post as AnyObject).value(forKey: "XPos") as! NSString as String
            let YPos = (post as AnyObject).value(forKey: "YPos") as! NSString as String
            let lat = (YPos as NSString).doubleValue
            let lon = (XPos as NSString).doubleValue
            let hospital = Hospital(title: yadmNm,locationName: addr, coordinate: CLLocationCoordinate2D(latitude: lat ,longitude: lon))
            hospitals.append(hospital)
        }
    }
//    func  loadIntialData() {
//        for post in posts {
//            let yadmNm = (post as AnyObject).value(forkey:"yadmNm") as! NSString as String
//            let addr = (post as AnyObject).value(forkey:"addr") as! NSString as String
//            let XPos = (post as AnyObject).value(forkey:"XPos") as! NSString as String
//            let YPos = (post as AnyObject).value(forkey:"YPos") as! NSString as String
//            let lat = (YPos as NSString).doubleValue
//            let lon = (XPos as NSString).doubleValue
//            let hospital = Hospital(title: yadmNm,locationName: addr,coordinate: CLLocationCoordinate2D((latitude: lat ,longitude: lon))
//                                    hospitals.append(hospital)
//
//        }
//    }
  

    func mapView(_ mapView: MKMapView,annotationView view: MKAnnotationView,calloutAccessoryControlTapped control:UIControl){
        let location = view.annotation as! Hospital
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
        
    }
    
    func mapView(_ mapView: MKMapView,viewFor annotation: MKAnnotation) -> MKAnnotationView?{

        guard let annotation = annotation as? Hospital else{return nil}

        let identifier = "marker"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView{
            dequeuedView.annotation = annotation
            view = dequeuedView
        }else{
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5 ,y:5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialLocation = CLLocation(latitude: 37.5384514, longitude: 127.0709764)
        
        centerMapOnLocation(location: initialLocation)
        
        mapView.delegate = self
        loadInitalData()
        mapView.addAnnotations(hospitals)

        // Do any additional setup after loading the view.
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
