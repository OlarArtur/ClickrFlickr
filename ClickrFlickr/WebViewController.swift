//
//  WebViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/7/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {


    @IBOutlet weak var userAuthWebView: UIWebView!
    
    var url = "https://www.google.by/search?client=safari&rls=en&q=ghjcnj+cfqn&ie=UTF-8&oe=UTF-8&gfe_rd=cr&dcr=0&ei=EQKxWazIN9Ov8we34LaQBA"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        userAuthWebView.loadRequest(URLRequest(url: URL(string: url)!))
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
