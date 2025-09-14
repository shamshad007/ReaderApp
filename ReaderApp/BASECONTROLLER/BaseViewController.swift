//
//  BaseViewController.swift
//  ReaderApp
//
//  Created by Md Shamshad Akhtar on 12/09/25.
//

import UIKit
import MBProgressHUD

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: Show Alert And Hide
    func showAlertWithTextAtController(vc : UIViewController, title : String, message : String) {
        
        // the alert view
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK:- Shadow On Uiview
    func shadowOnUIView(name : UIView) {
        name.layer.shadowRadius = 8
        name.layer.shadowOffset = .zero
        name.layer.shadowOpacity = 0.2
        name.layer.shouldRasterize = true
        name.layer.rasterizationScale = UIScreen.main.scale
        name.layer.cornerRadius = 10.0
    }
    
    //MARK:- Loader
    func showLoader(text: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = text
    }
    
    func hideLoader() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}
