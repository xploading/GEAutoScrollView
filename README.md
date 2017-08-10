# GEAutoScrollView
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
