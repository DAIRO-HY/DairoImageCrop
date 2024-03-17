//
//  DairoImageCropView++.swift
//  DairoImageCrop
//
//  Created by zhoulq on 2024/03/17.
//

import SwiftUI

/**
 * 图片裁剪预览扩展
 */
@available(iOS 15.0, *)
extension DairoImageCropView {
    
    /**
     * 修复裁剪范围
     */
    func fixCropImage() {
        
        //当前图片的尺寸
        let inputImageWidth = self.inputImage.size.width
        let inputImageHeight = self.inputImage.size.height
        
        // 当前图片的宽高比
        let inputImageWHRate: CGFloat = inputImageWidth / inputImageHeight
        
        //当前屏幕的宽高比
        let screenWHRate: CGFloat = self.screenWidth / self.screenHeight
        
        //没有缩放状态下的显示宽与高
        var displayW1: CGFloat
        var displayH1: CGFloat
        if inputImageWHRate > screenWHRate {//图片的宽高比大于屏幕的宽高比,则没有放大缩小的状态下,显示的宽度为屏幕宽度
            displayW1 = self.screenWidth
            displayH1 = displayW1 / inputImageWHRate
        } else {//图片的宽高比小于屏幕的宽高比,则没有放大缩小的状态下,显示的高度为屏幕的高度
            displayH1 = self.screenHeight
            displayW1 = displayH1 * inputImageWHRate
        }
        
        //允许最小的缩小比例
        let minZoomAmount: CGFloat
        if CGFloat(self.cropWHRate) > inputImageWHRate{//裁剪框宽高比大于图片宽高比,说明裁剪框有足够的宽度容纳图片的宽度,用宽度来计算最小缩放比例
            minZoomAmount = self.cropWidth / displayW1
        }else{
            minZoomAmount = self.cropHeight / displayH1
        }
        if self.zoomAmount < minZoomAmount{//手动缩小比例不能小于最小缩小比例
            self.zoomAmount = minZoomAmount
        }
        
        //拖动到边界计算
        let offsetMinHeight = (displayH1 * self.zoomAmount - self.cropHeight)/2
        if self.currentOffsetPosition.height < -offsetMinHeight{
            self.currentOffsetPosition = CGSize(width: self.currentOffsetPosition.width, height: -offsetMinHeight)
        }else if self.currentOffsetPosition.height > offsetMinHeight{
            self.currentOffsetPosition = CGSize(width: self.currentOffsetPosition.width, height: offsetMinHeight)
        }
        
        let offsetMinWidth = (displayW1 * self.zoomAmount - self.cropWidth)/2
        if self.currentOffsetPosition.width < -offsetMinWidth{
            self.currentOffsetPosition = CGSize(width: -offsetMinWidth, height: self.currentOffsetPosition.height)
        }else if self.currentOffsetPosition.width > offsetMinWidth{
            self.currentOffsetPosition = CGSize(width: offsetMinWidth, height: self.currentOffsetPosition.height)
        }
        self.preOffsetPosition = self.currentOffsetPosition
    }
    
    /**
     * 生成选取的图片
     */
    func onCropImage() {
        
        //当前图片的尺寸
        let inputImageWidth = self.inputImage.size.width
        let inputImageHeight = self.inputImage.size.height
        
        // 当前图片的宽高比
        var inputImageWHRate: CGFloat = inputImageWidth / inputImageHeight
        
        //当前屏幕的宽高比
        let screenWHRate: CGFloat = self.screenWidth / self.screenHeight
        
        //与实际尺寸相比,放大比例
        var displayZoomRate:CGFloat
        if inputImageWHRate > screenWHRate{//输入图片的宽高比大于屏幕的宽高比时
            displayZoomRate = inputImageWidth / (self.screenWidth * self.zoomAmount)
        }else{
            displayZoomRate = inputImageHeight / (self.screenHeight * self.zoomAmount)
        }
        
        //计算实际偏移像素
        let offsetWidthPX = self.cropWidth * displayZoomRate / 2 + self.currentOffsetPosition.width * displayZoomRate
        let x = (inputImageWidth/2) - offsetWidthPX//计算记过舍去小数
        
        //计算实际偏移像素
        let offsetHeightPX = self.cropHeight * displayZoomRate / 2 + self.currentOffsetPosition.height * displayZoomRate
        let y = (inputImageHeight/2) - offsetHeightPX//计算记过舍去小数
        
        let width = self.cropWidth * displayZoomRate
        let height = self.cropHeight * displayZoomRate
        
        let cropImage = self.crop(from: self.inputImage, croppedTo: CGRect(x: CGFloat(Int(x)), y: CGFloat(Int(y)), width: CGFloat(Int(width)), height: CGFloat(Int(height))))
        self.callback(cropImage)
    }
    
    /**
     * 裁剪成一张新的图片
     */
    private func crop(from image: UIImage, croppedTo rect: CGRect) -> UIImage {

        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        let drawRect = CGRect(x: -rect.origin.x, y: -rect.origin.y, width: image.size.width, height: image.size.height)

        context?.clip(to: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))

        image.draw(in: drawRect)

        let subImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        return subImage!
    }
}
