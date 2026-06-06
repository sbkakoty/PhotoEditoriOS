//
//  ViewControllerLaunchScreen.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 12/11/22.
//

import UIKit

class ViewControllerLaunchScreen: UIViewController {
    
    var window: UIWindow?
    
    private lazy var splashIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "splash_icon")
        view.alpha = 0
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor(hexaRGB: getBackgroundColor())
        
        let safeArea = view.safeAreaLayoutGuide
        let launchScreen = UINib(nibName: "CustomLaunchScreen", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        launchScreen.translatesAutoresizingMaskIntoConstraints = false
        launchScreen.backgroundColor = UIColor(hexaRGB: getBackgroundColor())!
        
        view.addSubview(launchScreen)
        launchScreen.addSubview(splashIcon)
        
        launchScreen.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        launchScreen.leftAnchor.constraint(equalTo: safeArea.leftAnchor).isActive = true
        launchScreen.rightAnchor.constraint(equalTo: safeArea.rightAnchor).isActive = true
        launchScreen.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        
        splashIcon.widthAnchor.constraint(equalToConstant: 100).isActive = true
        splashIcon.heightAnchor.constraint(equalToConstant: 100).isActive = true
        splashIcon.centerXAnchor.constraint(equalTo: launchScreen.centerXAnchor).isActive = true
        splashIcon.centerYAnchor.constraint(equalTo: launchScreen.centerYAnchor).isActive = true
        
        UIView.animate(withDuration: 2, animations: {
            self.splashIcon.alpha = 1
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 2, animations: {
                    self.splashIcon.alpha = 0
                }, completion: { done in
                    if done {
                        self.view.removeFromSuperview()
                        if let windowScene = UIApplication.shared.connectedScenes.first {
                            let vc = ViewControllerStart()
                            let navController = UINavigationController()
                            navController.pushViewController(vc, animated: false)
                            self.window = UIWindow(windowScene: windowScene as! UIWindowScene)
                            self.window!.rootViewController = navController
                            self.window!.makeKeyAndVisible()
                        }
                    }
                })
            }
        })
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
