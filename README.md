# RLParallaxView


### 简介

网易云歌单头部实现了高斯、视差、导航内容遮挡的效果。<del>记得早期网易云的高斯还有 blur 度跟随滚动变化，类似 QQ 音药那个样子...</del>

### 原理

- 分析了网易云的图层，看出头部背景图是单独的一个 `imageview`，同时并没有做导航与头部设置相同图片做跟随处理的操作，同时，如果这样处理也是很麻烦的。
- 所以，想到可以在头图的基础上设置一个 `contentView`，所有的布局内容都放在这个 `contentView` 上，然后设置一个作为 `mask` 的 `layer`，用于裁减掉延伸到导航位置的内容，造成一种穿透的效果。同时，监听滚动视图的 `offset` 变化，来改变 `mask` 的大小，让遮罩始终裁切掉多余的内容，只显示导航下面的内容。

### 使用

```swift
let headerView = RLParallaxView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
// 配置视差变化的最低高度
headerView.backgroundMinumHeight = headerView.frame.height
// 设置背景图
headerView.backgroundImage = UIImage(named: "header.jpeg")
// 引用 scrollview 监听滚动变化
headerView.scrollView = scrollView
// 开启背景高斯模糊效果
headerView.blurBackgroundImageEnabled = true
// 顶部穿透的间隙高度，此处设置导航的高度
headerView.translucentHeight = 64
// 开启顶部穿透效果
headerView.backgroundTranslucent = true

scrollView.addSubview(headerView)
```
