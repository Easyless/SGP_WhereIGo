
import UIKit
import WebKit

class Detail_View_Web: UIViewController, WKNavigationDelegate,
                       WKUIDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addrLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var addr : String = ""
    var addr_short : String = ""
    var name : String = ""
    var category : String = ""
    var category_M : String = ""
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        name = name.filter { !"\n\t".contains($0) }
        addr = addr.filter { !"\n\t".contains($0) }
        category = category.filter { !"\n\t".contains($0) }
        category_M = category_M.filter { !"\n\t".contains($0) }
        addr_short = addr_short.filter { !"\n\t".contains($0) }
        nameLabel.text = "상호명: " + name
        addrLabel.text = "주소: " + addr
        categoryLabel.text = "분류: " + category + " - " +  category_M
        
        let sURL = "https://m.map.naver.com/search2/search.naver?query=\(name) \(addr_short)"
        let temp = sURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let uURL = URL(string: temp)
        var request = URLRequest(url: uURL!)
        webView.load(request)
    }
}
