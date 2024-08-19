# DairoImageCrop

`SwiftUI` 图片裁剪

<p align="center">
<img src='Resource/demo.gif' width='200'>
</p>

## 内容列表

- [要求](#要求)
- [安装](#安装)
- [使用说明](#使用说明)
- [示例DEMO](#示例)


## 要求

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+
- Xcode 11.0+
- Swift 5.1+


## 安装

### Swift Package Manager

打开 `Xcode`， 选择 `File -> Swift Packages -> Add Package Dependency`，输入 `https://github.com/DAIRO-HY/DairoImageCrop`

也可以将 `DairoImageCrop` 作为依赖添加项到你的 `Package.swift` 中:
```swift
dependencies: [
  .package(url: "https://github.com/DAIRO-HY/DairoImageCrop", from: "0.2.0")
]
```


## 使用说明

- 基础使用：`DairoImageCropView` 的参数有默认值，你只需要简单的传入数据源即可使用~
```swift
DairoImageCropView(cropWHRate:"2:1", inputImage: self.vm.inputImage!){
    self.cropImage = $0
}
```

### 参数说明

- cropWHRate 裁剪比例(可选，默认值1:1)
- inputImage 需要裁剪的图片(必须)
- callback 裁剪完成之后的回调(必须)，回调函数中的第一个参数为裁剪后的图片


## 示例DEMO

DEMO连接：[https://github.com/DAIRO-HY/DairoImageCropDemo](https://github.com/DAIRO-HY/DairoImageCropDemo)，下载或者克隆之后，打开 `DairoImageCropDemo -> DairoImageCropDemo.xcodeproj` 运行并查看

