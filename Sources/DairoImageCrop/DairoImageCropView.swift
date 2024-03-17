//
//  DairoImageCropView.swift
//  DairoImageCrop
//
//  Created by zhoulq on 2024/03/17.
//

import SwiftUI

extension String {
    
    /**
     * 将字符串比例(1:2)转Floa(1/2)
     */
    var rate: Float{
        
        // 使用 components(separatedBy:) 方法将字符串拆分为数组
        let components = self.components(separatedBy: ":")
        
        // 如果数组长度为2，则进行转换
        if components.count == 2 {
            // 将分子和分母转换为整数
            if let numerator = Float(components[0]), let denominator = Float(components[1]), denominator != 0 {
                // 创建一个分数对象
                let fraction = Float(numerator) / denominator
                return fraction // 输出: 0.3333333333333333
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
}

/**
 * 图片裁剪预览
 */
@available(iOS 15.0, *)
public struct DairoImageCropView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    /**
     * 裁剪完成之后的回调
     */
    let callback:(_ cropImage: UIImage?)->Void
    
    /**
     * 当前图片
     */
    var inputImage: UIImage
    
    /**
     * 正在缩放比例
     */
    @State var zoomingAmount: CGFloat = 0
    
    /**
     * 缩放比例
     */
    @State var zoomAmount: CGFloat = 0.0
    
    /**
     * 正在移动中的偏移位置
     */
    @State var currentOffsetPosition: CGSize = .zero
    
    /**
     * 记录上一次移动的位置
     */
    @State var preOffsetPosition: CGSize = .zero
    
    /**
     * 裁剪框距离屏幕的边距
     */
    let cropPadding: CGFloat = 15
    
    /**
     * 裁剪框宽度
     */
    let cropWidth: CGFloat
    
    /**
     * 裁剪框高度
     */
    let cropHeight: CGFloat
    
    /**
     * 裁剪宽高比
     */
    let cropWHRate: Float
    
    //当前视图区域的尺寸
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    /**
     * cropWHRate 裁剪宽高比
     * inputImage 要裁剪的图片
     * callback 裁剪完成之后的回调函数
     */
    public init(cropWHRate: String = "1:1", inputImage: UIImage, callback:@escaping (_ cropImage: UIImage?)->Void) {
        self.cropWHRate = cropWHRate.rate
        self.inputImage = inputImage
        self.callback = callback
        
        //裁剪框支持的最大宽度
        let maxCropWidth = self.screenWidth - self.cropPadding * 2
        
        //裁剪框支持的最大高度
        let maxCropHidth = self.screenHeight - self.cropPadding * 2
        
        //支持的裁剪框最大宽高比
        let maxCropRate = Float(maxCropWidth / maxCropHidth)
        
        if maxCropRate > self.cropWHRate{//有足够的宽度容纳当前比例,则裁剪框高度取最大高度
            self.cropHeight = maxCropHidth
            self.cropWidth = maxCropHidth * CGFloat(self.cropWHRate)
        }else{//有足够的高度容纳当前比例,则裁剪框宽度取最大宽度
            self.cropWidth = maxCropWidth
            self.cropHeight = maxCropWidth / CGFloat(self.cropWHRate)
        }
    }
    
    public var body: some View {
        ZStack {
            Color.black
            Image(uiImage: self.inputImage)
                .resizable()
                .scaleEffect(self.zoomAmount + self.zoomingAmount)
                .scaledToFill()
                .aspectRatio(contentMode: .fit)
                .offset(x: self.currentOffsetPosition.width, y: self.currentOffsetPosition.height)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight:.infinity)
                .clipped()
            
            
            /* ---------------------------------------遮罩层---------------------------------------*/
            VStack{
                Spacer().frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/).background(.black).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                Spacer().frame(width: self.cropWidth, height: self.cropHeight)
                Spacer().frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/).background(.black).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            }
            HStack{
                Spacer().frame(width: self.cropPadding, height: self.cropHeight).background(.black).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                Spacer()
                Spacer().frame(width: self.cropPadding, height: self.cropHeight).background(.black).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            }
            /* ---------------------------------------遮罩层---------------------------------------*/
            
            //白色边框
            Spacer().frame(width: self.cropWidth, height: self.cropHeight)
                .overlay(// 设置边框样式
                    RoundedRectangle(cornerRadius: 0).stroke(.white, lineWidth: 1)
                )
            VStack {
                HStack{
                    ZStack {
                        HStack {
                            Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                            }){
                                Image(systemName: "xmark").foregroundColor(.white)
                            }
                            Spacer()
                            Button(action: {
                                self.onCropImage()
                                self.presentationMode.wrappedValue.dismiss()
                            }){
                                Image(systemName: "checkmark").foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .foregroundColor(.white)
                    }
                }
                .padding(.top, 50)
                Spacer()
            }
        }
        
        //MARK: - Gestures
        .gesture(
            MagnificationGesture()
                .onChanged { amount in
                    self.zoomingAmount = amount - 1
                }
                .onEnded { amount in
                    self.zoomAmount += self.zoomingAmount
                    if self.zoomAmount > 4.0 {
                        withAnimation {
                            self.zoomAmount = 4.0
                        }
                    }
                    self.zoomingAmount = 0
                    withAnimation {
                        self.fixCropImage()
                    }
                }.simultaneously(with: DragGesture()
                    .onChanged { value in
                        
                        //加上self.newPosition的目的是让图片从上次的位置开始移动
                        self.currentOffsetPosition = CGSize(width: value.translation.width + self.preOffsetPosition.width, height: value.translation.height + self.preOffsetPosition.height)
                    }
                    .onEnded { value in
                        
                        //加上self.newPosition的目的是让图片从上次的位置开始移动
                        self.currentOffsetPosition = CGSize(width: value.translation.width + self.preOffsetPosition.width, height: value.translation.height + self.preOffsetPosition.height)
                        self.preOffsetPosition = self.currentOffsetPosition
                        withAnimation {
                            self.fixCropImage()
                        }
                    }
                )
        )
        .onAppear(perform: self.fixCropImage )
        .edgesIgnoringSafeArea(.all)//忽略安全区域
    }
}

@available(iOS 15.0.0, *)
struct ImageMoveAndScaleSheet_Previews: PreviewProvider {
    static var previews: some View {
        let inputImage = UIImage(named: "no_img")!
        DairoImageCropView(cropWHRate:"2:1", inputImage : inputImage){ _ in
        }
    }
}
