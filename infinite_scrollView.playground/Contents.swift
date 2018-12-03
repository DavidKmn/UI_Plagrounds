import UIKit

class InfiniteScrollView: UIView {
    
    var dataSource: [String]? {
        didSet {
            modifyDataSource()
        }
    }
    
    struct Events {
        var onOptionChanged: ((String) -> Void)? = nil
    }
    
    public var events = Events()
    
    private var _dataSource: [String]? {
        didSet {
            setupContentView()
        }
    }
    
    lazy var scrollView: UIScrollView = { [unowned self] in
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy var tapView: UIView = { [unowned self] in
        let view = UIView()
        view.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didRecieveTap(sender:)))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .gray
        
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc fileprivate func didRecieveTap(sender: UITapGestureRecognizer) {
        
        guard let data = dataSource else { return }
        
        var index = Int(scrollView.contentOffset.x / scrollView.frame.width)
        print(scrollView.contentOffset.x / scrollView.frame.width)
        index = index < data.count ? index : 0
        self.events.onOptionChanged?(data[index])
        
        
        
        let x = scrollView.contentOffset.x
        let nextRect = CGRect(x: x + scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        print("Next Rect: \(nextRect)")
        scrollView.scrollRectToVisible(nextRect, animated: true)
    }

    private func modifyDataSource() {
        guard var tempInput = dataSource, tempInput.count >= 2 else { return }
        
        let firstTwoElementsTuple = (firstElement: tempInput.first!, secondElement: tempInput.last!)
        tempInput.append(firstTwoElementsTuple.firstElement)
        tempInput.insert(firstTwoElementsTuple.secondElement, at: 0)
        
        print("_datasource set to: \(tempInput)")
        
        self._dataSource = tempInput
    }
    
    private func setupContentView() {
        let subviews = scrollView.subviews
        subviews.forEach {
            $0.removeFromSuperview()
        }
        
        guard let data = _dataSource else { return }
        
        self.scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(data.count), height: scrollView.frame.size.height)
        
        for i in 0..<data.count {
            var frame = CGRect()
            frame.origin.x = scrollView.frame.size.width * CGFloat(i)
            frame.origin.y = 0
            frame.size = scrollView.frame.size
            
            let label = UILabel(frame: frame)
            label.backgroundColor = [UIColor.red, UIColor.green, UIColor.blue].randomElement()
            label.text = data[i]
            self.scrollView.addSubview(label)
        }
        let index = 1
        scrollView.contentOffset = CGPoint(x: scrollView.frame.width * CGFloat(index), y: 0)
    }
    
    func setupSubviews() {
        scrollView.frame = CGRect(x: (self.bounds.width / 2), y: 0, width: (self.bounds.width / 2), height: self.bounds.height)
        self.addSubview(scrollView)
        
        tapView.frame = self.bounds
        self.addSubview(tapView)
    }

}

extension InfiniteScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard _dataSource != nil else { return }
        
        let x = scrollView.contentOffset.x

        if x >= scrollView.frame.size.width * CGFloat(_dataSource!.count - 1) {
            self.scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
        } else if x < scrollView.frame.width {
            self.scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width * CGFloat(_dataSource!.count - 2), y: 0)
        }
    }
}

class ScrollViewContainerViewController: UIViewController {
    
    lazy var scrollOptionsView: InfiniteScrollView = { [unowned self] in
        let sov = InfiniteScrollView(frame: CGRect(x: 0, y: 300, width: self.view.bounds.width, height: 40))
        sov.dataSource = ["option one", "option two", "option three", "option four", "option five", "option six"]
        return sov
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .white
        view.addSubview(scrollOptionsView)
        scrollOptionsView.events = InfiniteScrollView.Events.init(onOptionChanged: { (optionName) in
            print(optionName)
        })
        
    }
}

import PlaygroundSupport

let vc = ScrollViewContainerViewController()
vc.preferredContentSize = vc.view.frame.size
PlaygroundPage.current.liveView = vc


