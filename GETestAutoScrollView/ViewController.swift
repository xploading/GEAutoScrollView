//
//  ViewController.swift
//  GETestAutoScrollView
//
//  Created by QTJT on 2017/8/10.
//  Copyright © 2017年 耿晓鹏. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var autoView : GEAutoScorllView?
    var a = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        autoView = GEAutoScorllView()
        autoView?.frame = CGRect(x: 0, y: 0, width: 414, height: 200)
        autoView?.imageLocs = ["111","222","333","444"]
        autoView?.pagePosition = positionType.Right
        self.view.addSubview(autoView!)
        
        
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 400, width: 200, height: 50)
        btn.center.x = UIScreen.main.bounds.width / 2
        btn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        btn.setTitle("点击切换图片", for: .normal)
        self.view.addSubview(btn)
        
    }
    func clickBtn(){
        a = !a
        autoView?.imageLocs =  a ? ["n1","n2","n3","n4","n5"]:["111","222","333","444"]
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

