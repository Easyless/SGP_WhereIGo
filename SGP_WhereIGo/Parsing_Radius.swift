import UIKit
import MapKit
import SwiftUI
import CoreLocation

class Parsing_Radius: UIViewController, XMLParserDelegate, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pickRadius: UIPickerView!
    
    var pickerDataSource = ["50", "100", "300", "500", "1000", "3000"]
    
    var currentRadius = 50
    var searchRadius : String = "50" {
        didSet{
            if(currentRadius < Int(searchRadius)!) {
                beginParsing()
                loadInitalData()
                mapView.addAnnotations(objects)
                currentRadius = Int(searchRadius)!
            }
        }
    }
    
    var viewRadius : CLLocationDistance = 500
    var objects : [Object] = []
    
    func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                      latitudinalMeters: viewRadius, longitudinalMeters: viewRadius)
            mapView.setRegion(coordinateRegion, animated: true)

    }
    
    // 파싱 후 카테고리로 거르기
    var pascategory = ""
    var userlat : Double = 0.0
    var userlon : Double = 0.0
    
    // 피커뷰로 반경 선택, radius 변경 및 beginParsing() didset?
    var parser = XMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    
    var name = NSMutableString()
    var category = NSMutableString()
    var category_M = NSMutableString()
    var addr = NSMutableString()
    var addr_short = NSMutableString()
    var lon = NSMutableString()
    var lat = NSMutableString()
    var id = NSMutableString()
    // bizesId
    
    var nums : [Int] = [0, 0, 0, 0, 0, 0]
    
    var locationManager: CLLocationManager!
    
    func loadInitalData() {
        for post in posts {
            let addr = (post as AnyObject).value(forKey: "lnoAdr") as! NSString as String
            let addr_short = (post as AnyObject).value(forKey: "adongNm") as! NSString as String
            let name = (post as AnyObject).value(forKey: "bizesNm") as! NSString as String
            let category = (post as AnyObject).value(forKey: "indsLclsNm") as! NSString as String
            let category_M = (post as AnyObject).value(forKey: "indsMclsNm") as! NSString as String
            let lat = (post as AnyObject).value(forKey: "lat") as! NSString as String
            let lon = (post as AnyObject).value(forKey: "lon") as! NSString as String
            let lat2 = (lat as NSString).doubleValue
            let lon2 = (lon as NSString).doubleValue
            
            let object = Object(title: name, category: category, coordinate: CLLocationCoordinate2D(latitude: lat2 ,longitude: lon2), addr: addr, category_M: category_M, addr_short: addr_short)
            
            let temp = String(category.filter { !" \n\t".contains($0) })
            
            if temp == "음식" {
                nums[0] += 1
            }
            else if temp  == "숙박"{
                nums[1] += 1
            }
            else if temp  == "학문/교육"{
                nums[2] += 1
            }
            else if temp  == "부동산"{
                nums[3] += 1
            }
            else if temp  == "소매"{
                nums[4] += 1
            }
            else if temp  == "생활서비스"{
                nums[5] += 1
            }
            if(pascategory != ""){
                if(String(category.filter { !" \n\t".contains($0) }) == pascategory){
                    objects.append(object)
                }
            }
            else{
                objects.append(object)
            }
        }
    }
  

    func mapView(_ mapView: MKMapView,annotationView view: MKAnnotationView,calloutAccessoryControlTapped control:UIControl){
        //let location = view.annotation as! Object
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
//
//        location.mapItem().openInMaps(launchOptions: launchOptions)
//         여기서 상세정보로 이동
//         해당 상가 번호를 상세정보 페이지에 전달 -> 파싱
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailView_web") as! Detail_View_Web
        //vc.storeNumber = (view.annotation as! Object).id
        vc.addr = (view.annotation as! Object).addr
        vc.name = (view.annotation as! Object).title!
        vc.category = (view.annotation as! Object).category
        vc.category_M = (view.annotation as! Object).category_M
        vc.addr_short = (view.annotation as! Object).addr_short
        present(vc,animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView,viewFor annotation: MKAnnotation) -> MKAnnotationView?{

        guard let annotation = annotation as? Object else{return nil}

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
            view.rightCalloutAccessoryView?.addSubview(UIView())
        
        }
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickRadius.delegate = self;
        self.pickRadius.dataSource = self;
        

        locationManager = CLLocationManager()
        locationManager.delegate = self


        locationManager.requestAlwaysAuthorization()

                //배터리에 맞게 권장되는 최적의 정확도
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

          
        var initialLocation = CLLocation(latitude: 37.3402891, longitude: 126.731313)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
          let coor = locationManager.location?.coordinate
            if coor != nil{
                userlat = coor!.latitude
                userlon = coor!.longitude
                initialLocation = CLLocation(latitude: userlat, longitude: userlon)
            }
        }
        
        centerMapOnLocation(location: initialLocation)
        mapView.delegate = self
        
        beginParsing()
        loadInitalData()
        mapView.addAnnotations(objects)
        
    }
    
    func beginParsing(){
        nums = [0, 0, 0, 0, 0, 0]
        posts = []
        
        // storeListInRadius 위도경도기준 상가조회 -> 현 위치 받아와서
        // storeListInArea 상권 내 상가조회
        // storeZoneInRadius 위,경도 기준 상권 조회  정왕ex1588 -> storeListInArea
        // storeOne, 단일 상가 조회 -> 상세 정보
        
        // 상가 번호 - bizesId
        // 상호명 - bizesNm
        // 위, 경도 - lon, lat
        // 분류 - indsLclsNm 음식 소매 생활서비스 학문/교육 부동산 숙박
        // 세분 - indsMclsNm 커피점/카페, 일식, 한식
        // 세세세분 - indsSclsNm
        // 주소 - rdnmAdr, lnoAdr
        if(userlat != 0.0){
            parser =  XMLParser(contentsOf:(URL(string:"http://apis.data.go.kr/B553077/api/open/sdsc/storeListInRadius?radius=\(searchRadius)&cx=\(userlon)&cy=\(userlat)&ServiceKey=cjmrl6WacYoXAOEViWRZIDktzROvQ8cqkp8O%2BMhRsrR1t9p9sGoBk%2FRbWEzsBePKz6H6xcKsEemQ%2F06QDA8MSA%3D%3D"))!)! // 위도 경도 기준 반경 검색
        }
        else{
            parser =  XMLParser(contentsOf:(URL(string:"http://apis.data.go.kr/B553077/api/open/sdsc/storeListInRadius?radius=\(searchRadius)&cx=126.731313&cy=37.3402891&ServiceKey=cjmrl6WacYoXAOEViWRZIDktzROvQ8cqkp8O%2BMhRsrR1t9p9sGoBk%2FRbWEzsBePKz6H6xcKsEemQ%2F06QDA8MSA%3D%3D"))!)!
        } // 위도 경도 기준 반경 검색

        
        parser.delegate = self
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI:String?, qualifiedName qName:String?, attributes attributeDict: [String : String]){
        element = elementName as NSString
        if(elementName as NSString).isEqual(to:"item"){
            elements = NSMutableDictionary()
            elements = [:]
            name = NSMutableString()
            name = ""
            category = NSMutableString()
            category = ""
            category_M = NSMutableString()
            category_M = ""
            lat = NSMutableString()
            lat = ""
            lon = NSMutableString()
            lon = ""
            addr = NSMutableString()
            addr = ""
            addr_short = NSMutableString()
            addr_short = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String){
        if element.isEqual(to: "bizesNm"){
            name.append(string)
        }
        else if element.isEqual(to: "indsLclsNm"){
            category.append(string)
        }
        else if element.isEqual(to: "indsMclsNm"){
            category_M.append(string)
        }
        else if element.isEqual(to: "lat"){
            lat.append(string)
        }
        else if element.isEqual(to: "lon"){
            lon.append(string)
        }
        else if element.isEqual(to: "lnoAdr"){
            addr.append(string)
        }
        else if element.isEqual(to: "adongNm"){
            addr_short.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
        if(elementName as NSString).isEqual(to: "item"){
            if !name.isEqual(nil){
                elements.setObject(name, forKey: "bizesNm" as NSCopying)
            }
            if !category.isEqual(nil){
                elements.setObject(category, forKey: "indsLclsNm" as NSCopying)
            }
            if !category_M.isEqual(nil){
                elements.setObject(category_M, forKey: "indsMclsNm" as NSCopying)
            }
            if !lat.isEqual(nil){
                elements.setObject(lat, forKey: "lat" as NSCopying)
            }
            if !lon.isEqual(nil){
                elements.setObject(lon, forKey: "lon" as NSCopying)
            }
            if !addr.isEqual(nil){
                elements.setObject(addr, forKey: "lnoAdr" as NSCopying)
            }
            if !addr_short.isEqual(nil){
                elements.setObject(addr_short, forKey: "adongNm" as NSCopying)
            }
            posts.add(elements);
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0{
            searchRadius  = "50"
        }
        else if row == 1{
            searchRadius  = "100"
        }
        else if row == 2{
            searchRadius  = "300"
        }
        else if row == 3{
            searchRadius  = "500"
        }
        else if row == 4{
            searchRadius  = "1000"
        }
        else if row == 5{
            searchRadius  = "3000"
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
}
