import UIKit
import MapKit


class Parsing_Radius: UIViewController, XMLParserDelegate, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
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
    
    // 피커뷰로 반경 선택, radius 변경 및 beginParsing() didset?
    var parser = XMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    
    var name = NSMutableString()
    var category = NSMutableString()
    var addr = NSMutableString()
    var lon = NSMutableString()
    var lat = NSMutableString()
    
    func loadInitalData() {
        for post in posts {
            let name = (post as AnyObject).value(forKey: "bizesNm") as! NSString as String
            let category = (post as AnyObject).value(forKey: "indsLclsNm") as! NSString as String
            let lat = (post as AnyObject).value(forKey: "lat") as! NSString as String
            let lon = (post as AnyObject).value(forKey: "lon") as! NSString as String
            let lat2 = (lat as NSString).doubleValue
            let lon2 = (lon as NSString).doubleValue
            let object = Object(title: name, locationName: category, coordinate: CLLocationCoordinate2D(latitude: lat2 ,longitude: lon2))
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
        let location = view.annotation as! Object
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
        
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
        }
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickRadius.delegate = self;
        self.pickRadius.dataSource = self;
        

        let initialLocation = CLLocation(latitude: 37.3402891, longitude: 126.7313136)
        
        centerMapOnLocation(location: initialLocation)
        mapView.delegate = self
        
        beginParsing()
        loadInitalData()
        mapView.addAnnotations(objects)
    }
    
    func beginParsing(){
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
        
        parser =  XMLParser(contentsOf:(URL(string:"http://apis.data.go.kr/B553077/api/open/sdsc/storeListInRadius?radius=\(searchRadius)&cx=126.7313136&cy=37.3402891&ServiceKey=cjmrl6WacYoXAOEViWRZIDktzROvQ8cqkp8O%2BMhRsrR1t9p9sGoBk%2FRbWEzsBePKz6H6xcKsEemQ%2F06QDA8MSA%3D%3D"))!)! // 위도 경도 기준 반경 검색
        
        parser.delegate = self
        parser.parse()
        
        //tbData!.reloadData()
        // 맵킷 갱신
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
            lat = NSMutableString()
            lat = ""
            lon = NSMutableString()
            lon = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String){
        if element.isEqual(to: "bizesNm"){
            name.append(string)
        }
        else if element.isEqual(to: "indsLclsNm"){
            category.append(string)
        }
        else if element.isEqual(to: "lat"){
            lat.append(string)
        }
        else if element.isEqual(to: "lon"){
            lon.append(string)
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
            if !lat.isEqual(nil){
                elements.setObject(lat, forKey: "lat" as NSCopying)
            }
            if !lon.isEqual(nil){
                elements.setObject(lon, forKey: "lon" as NSCopying)
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
