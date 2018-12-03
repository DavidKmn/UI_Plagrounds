import UIKit
import PlaygroundSupport

final class TargetAction: NSObject {
    
    let callback: () -> Void
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    @objc func action(sender: Any) {
        self.callback()
    }
}

final class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    struct Events {
        var didEndEditing: ((String?) -> Void)?  = nil
        var didBeginEditing: ((String?) -> Void)? = nil
        var shouldReturn: ((String?) -> Void)?  = nil
    }
    
    var events: Events
    
    init(events: Events) {
        self.events = events
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let handler = events.didEndEditing {
            handler(textField.text)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let handler = events.didBeginEditing {
            handler(textField.text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let handler = events.shouldReturn {
            handler(textField.text)
        }
        return true
    }
    
}


enum ContentElement {
    case label(String)
    case button(String, () -> Void)
    case image(UIImage)
    case textField(placeholder: String?, didEnd: (String?) -> Void, onShouldReturn: (String?) -> Void)
}

extension ContentElement {
    func render() -> (UIView, Any?) {
        switch self {
        case .label(let text):
            let label = UILabel()
            label.text = text
            return (label, nil)
        case .button(let title, let callback):
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            let target = TargetAction(callback: callback)
            button.addTarget(target, action: #selector(TargetAction.action(sender:)), for: .touchUpInside)
            return (button, target)
        case .image(let image):
            return (UIImageView(image: image), nil)
        case .textField(let placeholder, let onDidEnd, let onShouldReturn):
            let textField = UITextField()
            textField.placeholder = placeholder
            textField.borderStyle = .roundedRect
            var events = TextFieldDelegate.Events()
            events.didEndEditing = onDidEnd
            events.shouldReturn = onShouldReturn
            let delegate = TextFieldDelegate(events: events)
            textField.delegate = delegate
            return (textField, delegate)
        }
    }
}


final class StackViewController: UIViewController {

    let elements: [ContentElement]
    var strongReferences: [Any] = []
    
    init(elements: [ContentElement]) {
        self.elements = elements
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var stackView: UIStackView = { [unowned self] in
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 10
        self.elements.map({ $0.render() }).forEach({ (view, strongRef) in
            sv.addArrangedSubview(view)
            if let s = strongRef { self.strongReferences.append(s) }
        })
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.center(in: view)
        contentView.constrain(dimension: .width, toConstant: view.frame.width - view.safeAreaInsets.left - view.safeAreaInsets.right)
        contentView.constrain(dimension: .width, toConstant: 320)
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        view.addSubview(stackView)
        
        stackView.constrainEqual(dimension: .width, to: view)
        stackView.center(in: view)
    }
}


extension UIView {
    
    enum Dimension {
        case width
        case height
    }
    func constrainEqual(dimension: Dimension, to viewToConstraintTo: UIView) {
        guard let _ = self.superview else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        switch dimension {
        case .height:
            self.heightAnchor.constraint(equalTo: viewToConstraintTo.heightAnchor).isActive = true
        case .width:
            self.widthAnchor.constraint(equalTo: viewToConstraintTo.widthAnchor).isActive = true
        }
    }
    
    func center(in viewToConstraintTo: UIView) {
        guard let _ = self.superview else { return }

        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.centerXAnchor.constraint(equalTo: viewToConstraintTo.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: viewToConstraintTo.centerYAnchor).isActive = true
    }
    
    func constrain(dimension: Dimension, toConstant constant: CGFloat) {
        guard let _ = self.superview else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        switch dimension {
        case .height:
            self.heightAnchor.constraint(equalToConstant: constant).isActive = true
        case .width:
            self.widthAnchor.constraint(equalToConstant: constant).isActive = true
        }
    }
}

let elements: [ContentElement] = [
    .label("Please Login"),
    .textField(placeholder: "Name", didEnd: { text in
        print("name: \(text ?? "")")
    }, onShouldReturn: {
        print("Did Return on Email Field with: \($0 ?? "")")
    }),
    .textField(placeholder: "Password", didEnd: {
        print("password: \($0 ?? "")")
    }, onShouldReturn: {
        print("Did Return on Password Field with: \($0 ?? "")")
    }),
    .button("Login", {
        print("Login Button Tapped")
    })
]

let vc = StackViewController(elements: elements)
vc.preferredContentSize = vc.view.frame.size
PlaygroundPage.current.liveView = vc
