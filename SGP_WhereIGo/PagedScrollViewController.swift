

import UIKit

class PagedScrollViewController: UIViewController, UIScrollViewDelegate {
    var page : Int = 0
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet weak var text: UITextView!
    
    @IBAction func webViewBut(_ sender: Any) {
        
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailView_web") as! Detail_View_Web
            if page == 0{
                vc.addr = "경기도 시흥시 정왕동 2304-10"
                vc.name = "한마음식자재클럽"
                vc.category = "소매"
                vc.category_M = "종합소매점"
                vc.addr_short = "정왕동"
            }
            else if page == 1{
                vc.addr = "경기 시흥시 정왕동 2321-9"
                vc.name = "술촌"
                vc.category = "음식"
                vc.category_M = "요리주점"
                vc.addr_short = "정왕동"
            }
            else if page == 2{
                vc.addr = "경기 시흥시 정왕동 2300-7"
                vc.name = "귀한족"
                vc.category = "음식"
                vc.category_M = "한식"
                vc.addr_short = "정왕동"
            }
           
            present(vc,animated: true, completion: nil)
    }
   
    
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        pageImages = [UIImage(named: "photo1.jpeg")!,
                      UIImage(named: "photo2.jpeg")!,
                      UIImage(named: "photo3.jpeg")!
                    ]
        
        let pageCount = pageImages.count
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
        
        for _ in 0...pageCount{
            pageViews.append(nil)
        }
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageImages.count), height: pagesScrollViewSize.height)
        
        loadVisiblePages()
    }
    
    func loadPage(_ page:Int){
        if page < 0 || page >= pageImages.count{
            return
        }
        
        if pageViews[page] != nil{}
        else{
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .scaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            
            pageViews[page] = newPageView
        }
    }
    
    func purgePage(_ page: Int){
        if page < 0 || page >= pageImages.count{
            return
        }
        
        if let pageView = pageViews[page]{
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    
    func loadVisiblePages(){
        let pageWidth = scrollView.frame.width
        page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        if page == 0 {
            text.text = "한마음식자재마트 \n정왕역 부근에 위치한 자취생들의 성지. \n매우 저렴한 물가를 자랑하며 웬만한 물건은 다 있다"
        }
        if page == 1 {
            text.text = "술촌 \n정왕역 바로 뒤에 위치한 아는 사람만 아는 가성비 최고의 전집.\n안주의 맛이 뛰어나며 양 또한 어마무시하다 "
        }
        if page == 2 {
            text.text = "귀한족 \n혼자 사는 자취생을 위한 1인족발 메뉴가 정말 마음에 드는 집. \n1인 메뉴지만 양이 적은것도 아니며 물론 맛 또한 훌륭하다"
        }
        pageControl.currentPage = page
        
        let firstPage = page - 1
        let lastPage = page + 1
        
        for index in 0 ..< firstPage+1 {
            purgePage(index)
        }
    
        for index in firstPage ... lastPage {
            loadPage(index)
        }
        
        for index in lastPage+1 ..< pageImages.count+1 {
            purgePage(index)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        loadVisiblePages()
    }
}
