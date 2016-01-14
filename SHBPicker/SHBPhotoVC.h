//
//  SHBPhotoVC.h
//  Refresh
//
//  Created by 沈红榜 on 16/1/5.
//  Copyright © 2016年 沈红榜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef void(^CallBack)(NSArray <PHAsset *>*dataArray);
typedef void(^SelectedImages)(NSArray <NSData *>*dataArray);

@interface SHBPhotoVC : UIViewController

@property (nonatomic, copy) CallBack callback;
@property (nonatomic, copy) SelectedImages  selectedImages;

@end
