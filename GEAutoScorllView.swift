//
//  GEAutoScorllView.swift
//  ChinaJXLM
//
//  Created by QTJT on 2017/6/19.
//  Copyright © 2017年 耿晓鹏. All rights reserved.
//

///------------------
///GEAutoScrollView>>
///------------------
///需要SDWebImage支持>>
///------------------
/**
    实现原理: ScrollView添加三个ImageView L(左) M(中) R(右)
            当前显示的为M(中)ImageView
            给三个ImageView加载图片,M加载第0张图片,L加载第n张,R加载第1张
            
            滑动结束时,调用scrollView协议方法,scrollViewDidEndDecelerating
            ImageView重新加载图片
            重设ScrollView的contentOffset,一直显示M(中)ImageView
 
            向左滚动:
            🌰-------------🌰
            |     L   M   R |
            | 1>  n   0   1 |
            | 2>  0   1   2 |
            | 3>  1   2   3 |
            | ...           |
            | ...           |
            | n>  n-1 n   0 |
            🌰-------------🌰
    支持:
        1.加载网络图片 ImageNets
        2.加载本地图片 ImageLocs
        3.显示pageControl,支持底部左,中,右显示
        4.更换图片只需重新给图片数组赋值,无需其他操作
    //MARK: GE.🗣----------!
 */


import UIKit
import SDWebImage

enum positionType{
    case Left
    case Right
    case Mid
}

@objc protocol GEAutoScorllViewDelegate {
    @objc optional func clickImageView(number:Int)
}



class GEAutoScorllView: UIView {
    
    fileprivate var scrollView : UIScrollView?
    

//MARK: GE.🗣-----公开属性-----!
/**  GE.🗣 代理*/
    var delegte:GEAutoScorllViewDelegate?
/**  GE.🗣 加载网络图片*/
    var imageNets    =  [String](){
        didSet{
            self.layoutSubviews()
        }
    }
/**  GE.🗣 加载本地图片*/
    var imageLocs    =   [String](){
        didSet{
            self.layoutSubviews()
        }
    }
/**  GE.🗣 显示pageControl,默认true*/
    var isShowPage   = true
    var pagePosition = positionType.Mid //pageControl位置,默认中间
    var holderImage : UIImage?          //占位图片
    
    
    
    
    
    fileprivate var images = [String]()
    fileprivate var timer : Timer?
    fileprivate var pageControl : UIPageControl?
    //三个ImageView用来展示图片
    fileprivate var L_ImageView = UIImageView()
    fileprivate var M_ImageView = UIImageView()
    fileprivate var R_imageView = UIImageView()
    
    
    fileprivate var LIndex = -1
    fileprivate var MIndex = 0
    fileprivate var RIndex = 1
    
    
    
    override func layoutSubviews() {
        self.additionalSetup()
    }

 
    fileprivate func additionalSetup(){
        self.initConfig()
        self.addTapForImageView()
        self.setupUI()
        self.setImages()
        self.createPageControl()
        self.start()
        
    }
    fileprivate func initConfig(){
        
        self.images = (imageNets.count != 0) ? imageNets : imageLocs
        
        LIndex = self.images.count-1
        MIndex = 0
        RIndex = 1

    }
    
    
/**  GE.🗣 布局UI*/
    fileprivate func setupUI(){
        if scrollView != nil{
            return
        }
        let w = self.frame.width
        let h = self.frame.height
        scrollView = UIScrollView(frame: CGRect.init(x: 0, y: 0, width: w, height: h))
        scrollView?.contentSize = CGSize(width: w*3,height: 0)
        scrollView?.isPagingEnabled = true
        //隐藏水平滚动条
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.delegate = self
        scrollView?.contentOffset = CGPoint(x: w, y: 0)
        
        L_ImageView.frame = CGRect(x: 0, y: 0, width: w, height: h)
    
        M_ImageView.frame = CGRect(x: w, y: 0, width: w, height: h)
        R_imageView.frame = CGRect(x: w*2, y: 0, width: w, height: h)

        
        scrollView?.addSubview(L_ImageView)
        scrollView?.addSubview(M_ImageView)
        scrollView?.addSubview(R_imageView)
        self.addSubview(scrollView!)
    }
/**  GE.🗣 滚动视图显示的图片*/
    fileprivate func setImages(){
//轮播图无图片时,跳出,防止程序崩溃.
        if imageLocs.count == 0 && imageNets.count == 0{
            print("未添加轮播图片")
            self.stop()
            return
        }
//加载网络图片和本地图片判断
        if imageNets.count != 0
        {
            L_ImageView.sd_setImage(
                with:URL.init(string: imageNets[LIndex]) ,
                placeholderImage: holderImage)
            M_ImageView.sd_setImage(
                with: URL.init(string: imageNets[MIndex]),
                placeholderImage: holderImage)
            R_imageView.sd_setImage(
                with: URL.init(string: imageNets[RIndex]),
                placeholderImage: holderImage)
            
            
        }else
        {
            L_ImageView.image = UIImage(named: imageLocs[LIndex])
            M_ImageView.image = UIImage(named: imageLocs[MIndex])
            R_imageView.image = UIImage(named: imageLocs[RIndex])
            
        }

    }
/**  GE.🗣 添加计时器*/
    func start(){
        if timer == nil{
            self.timer = Timer(timeInterval: 2, target: self, selector: #selector(roll), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer!, forMode:.defaultRunLoopMode)

        }

    }
    //界面消失时需调用方法,释放
    func stop(){
        if timer == nil{
            return
        }
        timer?.invalidate()
        timer = nil
    }
/**  GE.🗣 定时器执行方法*/
    func roll()  {
        if timer == nil{
            return
        }
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.scrollView?.contentOffset.x+=(self?.frame.width)!
        }
        self.scrollViewDidEndDecelerating(scrollView!)
        
    }

    

//MARK: GE.🗣-----设置PageControl-----!
    func createPageControl(){
        if pageControl != nil{
            pageControl?.removeFromSuperview()
            pageControl = nil
        }
        if isShowPage{
            pageControl = UIPageControl(frame:CGRect(x: 15, y: self.frame.maxY - 10, width: 100, height: 10))
            let w = (pageControl?.frame.width)!
//页面指示器的位置,左\中\右
            switch pagePosition
            {
            case .Left:
                pageControl?.center.x = w/2 + 15
            case .Mid:
                pageControl?.center.x = self.center.x
            case .Right:
                pageControl?.center.x = self.frame.width - w/2 - 15
            }
            pageControl?.numberOfPages = self.images.count
            pageControl?.currentPage = 0

            self.addSubview(pageControl!)
        }
    }
/**  GE.🗣 ImageView添加点击手势,点击轮播图时进行页面跳转*/
    func addTapForImageView(){
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(tapImageView))
        self.M_ImageView.isUserInteractionEnabled = true
        self.M_ImageView.addGestureRecognizer(tap)
    }
    
    func tapImageView(tap:UITapGestureRecognizer){
        print("点击手势执行:",self.MIndex)
        //代理执行协议方法
        delegte?.clickImageView?(number: MIndex)
        
    }
    
    
    
    deinit {
        print("界面销毁")
    }
    

    
}

//MARK: GE.🗣-----scrollView协议方法-----!
extension GEAutoScorllView:UIScrollViewDelegate{
     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x<self.frame.width{
            var temp = 0
            temp = MIndex
            MIndex = LIndex
            RIndex = temp
            if LIndex<=0{
                LIndex = self.images.count
            }
            LIndex -= 1
        }else
        {
            var temp = 0
            temp = MIndex
            MIndex = RIndex
            LIndex = temp
            if RIndex>=self.images.count-1
            {
                RIndex = -1
            }

            RIndex += 1
        }
        self.setImages()
        scrollView.contentOffset = CGPoint(x: self.frame.width, y: 0)
        pageControl?.currentPage = MIndex //显示pageControl的下标
        
    }
//MARK: GE.🗣-----开始拖拽时停止轮播-----!
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stop()
    }
//MARK: GE.🗣-----停止拖拽时启动轮播-----!
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.start()
    }
    
    
}











