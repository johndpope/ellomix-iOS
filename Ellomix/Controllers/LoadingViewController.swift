//
//  LoadingViewController.swift
//  National Driver Training
//
//  Created by Abelardo Torres on 7/16/18.
//  Copyright © 2018 National Driver Training. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    var message: String = "Loading..."
    var isIconEnabled: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadingIndicator.startAnimating()
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        containerView.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Setter method
    
    func setMessage(forLabel msg: String) {
        message = msg
    }
    
    func setIconEnabled(enabled: Bool) {
        isIconEnabled = enabled
    }
    
    //MARK: - UI Controls
    
    func showLoadingIndicator(parent: UIViewController) {
        parent.addChildViewController(self)
        
        self.view.frame = parent.view.frame
        parent.view.addSubview(self.view)
        self.didMove(toParentViewController: parent)
        
        if messageLabel != nil {
            messageLabel.text = message
        }
    }
    
    func dismissLoadingIndicator() {
        self.view.removeFromSuperview()
    }
    
    //TODO: Implement show and hide method

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIStoryboard {
    static func instateLoadingViewController() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loadingViewController")
    }
}
