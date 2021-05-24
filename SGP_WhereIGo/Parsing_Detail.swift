import UIKit

class Parsing_Detail: UIViewController, XMLParserDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tbData: UITableView!
    
    var parser = XMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    
    var name = NSMutableString()
    var category = NSMutableString()
    var addr = NSMutableString()
    var lon = NSMutableString()
    var lat = NSMutableString()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beginParsing()
        // Do any additional setup after loading the view.
    }
    func beginParsing(){
        posts = []
        // storeListInRadius 위도경도기준 상가조회 -> 현 위치 받아와ㅁ서
        // storeListInArea 상권 내 상가조회
        // storeZoneInRadius 위,경도 기준 상권 조회  정왕ex1588 -> storeListInArea
        // storeOne, 단일 상가 조회 -> 상세 정보
        
        // 상가 번호 - bizesId
        // 상호명 - bizesNm
        // 위, 경도 - lon, lat
        // 분류 - indsLclsNm
        // 세분 - indsMclsNm
        // 세세세분 - indsSclsNm
        // 주소 - rdnmAdr, lnoAdr
        
        parser = XMLParser(contentsOf:(URL(string:"http://apis.data.go.kr/B553077/api/open/sdsc/storeOne?key=16684648&ServiceKey=cjmrl6WacYoXAOEViWRZIDktzROvQ8cqkp8O%2BMhRsrR1t9p9sGoBk%2FRbWEzsBePKz6H6xcKsEemQ%2F06QDA8MSA%3D%3D"))!)! // 상세정보 key = 상가 번호
    
        parser.delegate = self
        parser.parse()
        
        tbData!.reloadData()
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
        else if element.isEqual(to: "indsMclsNm"){
            category.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
        if(elementName as NSString).isEqual(to: "item"){
            if !name.isEqual(nil){
                elements.setObject(name, forKey: "bizesNm" as NSCopying)
            }
            if !category.isEqual(nil){
                elements.setObject(category, forKey: "indsMclsNm" as NSCopying)
            }
            posts.add(elements)
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = (posts.object(at: indexPath.row) as AnyObject).value(forKey: "bizesNm") as! NSString as String
        cell.detailTextLabel?.text = (posts.object(at: indexPath.row) as AnyObject).value(forKey: "indsMclsNm") as! NSString as String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
}
