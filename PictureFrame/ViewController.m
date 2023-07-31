//
//  ViewController.m
//  PalmBeiT
//
//  Created by zhangkeqin on 2023/7/26.
//  Copyright © 2023 zhangkeqin. All rights reserved.
//

#import "ViewController.h"
#import <PhotosUI/PhotosUI.h>
// 屏幕宽高
#define Screen_Width self.view.bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height



@interface ViewController ()

@property (nonatomic, strong) UIButton *saveButton;//右侧保存按钮

@property (nonatomic, strong) UIView *backView;//底图

@property (nonatomic, strong) UIImageView *borderImageView;//画框

@property (nonatomic, strong) UIImageView *userImageView;//用户字

@property (nonatomic, strong) UIButton *addButton;//添加按钮

@property (nonatomic, strong) UIImageView *topLeftImageView;//左上角图

@property (nonatomic, strong) UIImageView *bottomRightImageView;//右下角图

@property (nonatomic, strong) UIImage *userImage;

@property (nonatomic, assign) CGFloat imageWidth;//图片宽

@property (nonatomic, assign) CGFloat imageHeight;//图片高

@property (nonatomic, assign) CGFloat finalScale;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.userImage = [UIImage imageNamed:@"IMG_0337.jpg"];
    self.imageWidth = CGImageGetWidth(self.userImage.CGImage);
    self.imageHeight = CGImageGetHeight(self.userImage.CGImage);
    [self configUI];
    
}


-(void)configUI{

    
    CGFloat widthScale = (Screen_Width - 150) / self.imageWidth ;
    CGFloat heightScale = (Screen_Height - 90) / self.imageHeight;
    self.finalScale = 0;
    if(widthScale < heightScale){
        //宽先到边 用宽定位
        self.finalScale = widthScale;
    }else{
        //上下先到边 用高定位
        self.finalScale = heightScale;
    }
    
    self.backView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height - 50);
    [self.view addSubview:self.backView];
    
    
    self.userImageView.frame = CGRectMake(0, 0, self.imageWidth * self.finalScale, self.imageHeight *self.finalScale);
    self.userImageView.center = CGPointMake(self.backView.frame.size.width / 2, self.backView.frame.size.height / 2);
    [self.backView addSubview:self.userImageView];
    

    self.addButton.frame = CGRectMake(0, Screen_Height - 50, Screen_Width / 2, 50);
    [self.view addSubview:self.addButton];
    
    self.saveButton.frame = CGRectMake(Screen_Width / 2, Screen_Height - 50, Screen_Width / 2, 50);
    [self.view addSubview:self.saveButton];
    
    self.userImageView.image = self.userImage;

}


//右侧保存按钮
-(UIButton *)saveButton{
    if(!_saveButton){
        _saveButton = [[UIButton alloc]init];
        _saveButton.backgroundColor = [UIColor lightGrayColor];
        [_saveButton setTitle:@"保存图片" forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

//底图
-(UIView *)backView{
    if(!_backView){
        _backView = [[UIView alloc]init];
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}


//用户字
-(UIImageView *)userImageView{
    if(!_userImageView){
        _userImageView = [[UIImageView alloc]init];
        _userImageView.alpha = 1;
        _userImageView.userInteractionEnabled = NO;
    }
    return _userImageView;
}

//添加按钮
-(UIButton *)addButton{
    if(!_addButton){
        _addButton = [[UIButton alloc]init];
        _addButton.backgroundColor = [UIColor lightGrayColor];
        [_addButton setTitle:@"添加相框" forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

//画框
-(UIImageView *)borderImageView{
    if(!_borderImageView){
        _borderImageView = [[UIImageView alloc]init];
//        _borderImageView.alpha = 0.3;
    }
    return _borderImageView;
}

//左上角图
-(UIImageView *)topLeftImageView{
    if(!_topLeftImageView){
        _topLeftImageView = [[UIImageView alloc]init];
        _topLeftImageView.alpha = 0.9;
    }
    return _topLeftImageView;
}

//右下角图
-(UIImageView *)bottomRightImageView{
    if(!_bottomRightImageView){
        _bottomRightImageView = [[UIImageView alloc]init];
        _bottomRightImageView.alpha = 0.9;
    }
    return _bottomRightImageView;
}




#pragma mark - 返回
-(void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 保存图片
-(void)saveButtonAction{
    //将底图带着上边所有的子view全部转成一张图片
    UIImage *saveImage = [self ViewToImage:self.backView];
    //获取这张图片非透明像素的最上下左右的point
    CGPoint top = [self getTopNonTransparentPixel:saveImage];
    CGPoint left = [self getLeftNonTransparentPixel:saveImage];
    CGPoint bottom = [self getBottomNonTransparentPixel:saveImage];
    CGPoint right = [self getRightmostNonTransparentPixel:saveImage];
    //根据上下左右四个点裁剪图片
    UIImage *finale =  [self cropImageWithPoints:saveImage top:top left:left bottom:bottom right:right];
    //保存裁剪后的图片
    [self saveImageToPhotoAlbumWithTransparency:finale];
    
}

//保存图片完成之后的回调 该方法保存图片可保留透明通道
- (void)saveImageToPhotoAlbumWithTransparency:(UIImage *)image {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 创建一个 PHAssetCreationRequest 对象
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        
        // 将 UIImage 转换为 NSData，并指定保留 PNG 格式的透明通道
        NSData *imageData = UIImagePNGRepresentation(image);
        
        // 添加图片数据到请求中
        [request addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];
    } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"图片保存成功");
            });
            
        } else {
            NSLog(@"保存图片失败: %@", error);
        }
    }];
}


#pragma mark - 添加画框
-(void)addButtonAction{
    //画框图
    UIImage *orinalImage = [UIImage imageNamed:@"pictureFrame"];
    
    CGFloat top = orinalImage.size.height/2.0f - 0.5f; // 顶端盖高度
    CGFloat bottom = orinalImage.size.height/2.0f - 0.5f ; // 底端盖高度
    CGFloat left = orinalImage.size.width/2.0f - 0.5f; // 左端盖宽度
    CGFloat right = orinalImage.size.width/2.0f - 0.5f; // 右端盖宽度
    
    UIImage *image = [self stretchImage:orinalImage withCapInsets:UIEdgeInsetsMake(top, left, bottom, right) toSize:CGSizeMake(self.userImageView.frame.size.width + 10, self.userImageView.frame.size.height + 10)];
    
    self.borderImageView.image = image;
    self.borderImageView.frame = CGRectMake(0, 0, self.userImageView.frame.size.width + 10, self.userImageView.frame.size.height + 10);
    self.borderImageView.center = CGPointMake(self.backView.frame.size.width / 2, self.backView.frame.size.height / 2);
    [self.backView addSubview:self.borderImageView];
    
}


#pragma mark - 获取最顶点
-(CGPoint)getTopNonTransparentPixel:(UIImage *)image{
    CGImageRef cgImage = image.CGImage;
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    CGContextRef context = [self createBitmapContextWithCGImage:cgImage];
    
    unsigned char *data = CGBitmapContextGetData(context);
    if (data == NULL) {
        CGContextRelease(context);
        return CGPointZero;
    }
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int byteIndex = (int)(4 * (width * y + x));
            if (data[byteIndex + 3] > 0) { // Check alpha channel value
                CGContextRelease(context);
                return CGPointMake(x, y);
            }
        }
    }
    
    CGContextRelease(context);
    return CGPointZero;
}
#pragma mark - 获取最低点
-(CGPoint)getBottomNonTransparentPixel:(UIImage *)image{
    CGImageRef cgImage = image.CGImage;
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    CGContextRef context = [self createBitmapContextWithCGImage:cgImage];
    
    unsigned char *data = CGBitmapContextGetData(context);
    if (data == NULL) {
        CGContextRelease(context);
        return CGPointZero;
    }
    
    for (int y = (int)height - 1; y >= 0; y--) {
        for (int x = 0; x < width; x++) {
            int byteIndex = (int)(4 * (width * y + x));
            if (data[byteIndex + 3] > 0) { // Check alpha channel value
                CGContextRelease(context);
                return CGPointMake(x, y);
            }
        }
    }
    
    CGContextRelease(context);
    return CGPointZero;
}

#pragma mark - 获取最左点
-(CGPoint)getLeftNonTransparentPixel:(UIImage *)image{
    CGImageRef cgImage = image.CGImage;
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    CGContextRef context = [self createBitmapContextWithCGImage:cgImage];
    
    unsigned char *data = CGBitmapContextGetData(context);
    if (data == NULL) {
        CGContextRelease(context);
        return CGPointZero;
    }
    
    for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
            int byteIndex = (int)(4 * (width * y + x));
            if (data[byteIndex + 3] > 0) { // Check alpha channel value
                CGContextRelease(context);
                return CGPointMake(x, y);
            }
        }
    }
    
    CGContextRelease(context);
    return CGPointZero;
}
#pragma mark - 获取最右点
-(CGPoint)getRightmostNonTransparentPixel:(UIImage *)image{
    CGImageRef cgImage = image.CGImage;
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    CGContextRef context = [self createBitmapContextWithCGImage:cgImage];
    
    unsigned char *data = CGBitmapContextGetData(context);
    if (data == NULL) {
        CGContextRelease(context);
        return CGPointZero;
    }
    
    for (int x = (int)width - 1; x >= 0; x--) { // 从右边开始遍历
        for (int y = 0; y < height; y++) {
            int byteIndex = (int)(4 * (width * y + x));
            if (data[byteIndex + 3] > 0) { // 检查 alpha 通道值
                CGContextRelease(context);
                return CGPointMake(x, y);
            }
        }
    }
    
    CGContextRelease(context);
    return CGPointZero;
}

#pragma mark - 创建位图上下文
- (CGContextRef)createBitmapContextWithCGImage:(CGImageRef)cgImage {
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    
    // 每个组件的位数
    size_t bitsPerComponent = 8;
    
    // 每一行的字节数
    size_t bytesPerRow = width * 4; // 假设图片格式为RGBA
    
    // 创建颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 创建位图上下文
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // 设置绘制参数
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // 绘制图片到位图上下文
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    
    // 释放颜色空间
    CGColorSpaceRelease(colorSpace);
    
    return context;
}


#pragma mark - 裁剪图片
-(UIImage *)cropImageWithPoints:(UIImage *)image top:(CGPoint)top left:(CGPoint)left bottom:(CGPoint)bottom right:(CGPoint)right {
    // 计算裁剪区域的边界矩形
    CGRect cropRect = CGRectMake(left.x, top.y, right.x - left.x, bottom.y - top.y);
    
    // 将裁剪区域应用到原始图片上
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

// 拉伸图片并保持四个角的形状不变
- (UIImage *)stretchImage:(UIImage *)image withCapInsets:(UIEdgeInsets)capInsets toSize:(CGSize)size {
    UIImage *resizableImage = [image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeTile];
    
    return resizableImage;
}

#pragma mark - view转为image
-(UIImage*)ViewToImage:(UIView *)View{
    CGSize s = View.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [View.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end



