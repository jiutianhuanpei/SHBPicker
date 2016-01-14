


//
//  SHBBrowserController.m
//  Refresh
//
//  Created by 沈红榜 on 16/1/12.
//  Copyright © 2016年 沈红榜. All rights reserved.
//

#import "SHBBrowserController.h"
#import <Photos/Photos.h>
#import "UIView+SendAction.h"

@protocol SHBPhotoItemDelegate <NSObject>

- (void)saveImage:(UIImageView *)imgView;

@end

@interface SHBPhotoItem : UICollectionViewCell<UIScrollViewDelegate>

//@property (nonatomic) SEL   singleTap;
//@property (nonatomic) SEL   doubleTap;

@property (nonatomic, assign) id<SHBPhotoItemDelegate> delegate;

- (void)configImage:(UIImage *)image;
- (void)nomalScale;

@end
@implementation SHBPhotoItem {
    UIScrollView        *_scroll;
    UIView              *_contentView;
    UIImageView         *_imgView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        _scroll = [[UIScrollView alloc] initWithFrame:rect];
        _scroll.delegate = self;
        _scroll.minimumZoomScale = 1;
        _scroll.maximumZoomScale = 4;
        _scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_scroll];
        
        _contentView = [[UIView alloc] init];
        _contentView.clipsToBounds = true;
        [_scroll addSubview:_contentView];
        
        _imgView = [[UIImageView alloc] initWithFrame:rect];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        [_contentView addSubview:_imgView];
        _imgView.userInteractionEnabled = true;
        
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [_imgView addGestureRecognizer:press];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        singleTap.numberOfTapsRequired = 1;
        [_imgView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [_imgView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
    }
    return self;
}

- (void)longPress:(UILongPressGestureRecognizer *)press {
    if (press.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(saveImage:)]) {
            [_delegate saveImage:_imgView];
        }
//        [self shbSendAction:@selector(saveImage:) from:_imgView];
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    _scroll.backgroundColor = [UIColor whiteColor];
//    [self shbSendAction:_singleTap from:_imgView];
}

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    _scroll.backgroundColor = [UIColor blackColor];
//    [self shbSendAction:_doubleTap from:self];
}

- (void)configImage:(UIImage *)image {
    _imgView.image = image;
    _scroll.backgroundColor = [UIColor blackColor];
    
    _contentView.origin = CGPointZero;
    _contentView.width = self.width;
    
    if (image.size.height / image.size.width > self.height / self.width) {  // 图片是竖图，高度比屏长
        _contentView.height = floor(image.size.height / (image.size.width / self.width));
        
    } else {
        CGFloat height = image.size.height / image.size.width * self.width; // 图片为屏宽是，高度
        if (height < 1 || isnan(height)) {
            height = self.height;
        }
        height = floor(height);
        
        _contentView.height = height;
        _contentView.centerY = self.height / 2.;
    }
    
    if (_contentView.height > self.height && _contentView.height - self.height <= 1) {
        _contentView.height = self.height;
    }
    
    _scroll.contentSize = CGSizeMake(self.width, MAX(_contentView.height, self.height));
    [_scroll scrollRectToVisible:self.bounds animated:false];
    _imgView.frame = _contentView.bounds;
}

- (void)nomalScale {
    _scroll.zoomScale = 1;
}

#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _contentView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.width > scrollView.contentSize.width) ? (scrollView.width - scrollView.contentSize.width) * 0.5 : 0;
    CGFloat offsetY = (scrollView.height > scrollView.contentSize.height) ? (scrollView.height - scrollView.contentSize.height) * 0.5 : 0;
    _contentView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}
@end

@interface SHBBrowserController ()<UICollectionViewDelegate, UICollectionViewDataSource, SHBPhotoItemDelegate>

@property (nonatomic, strong) PHCachingImageManager *manager;

@end

@implementation SHBBrowserController {
    id              _model;
    
    UICollectionView    *_view;
    
}

- (id)initWithImage:(id)image {
    self = [super init];
    if (self) {
        _model = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    _manager = [[PHCachingImageManager alloc] init];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    layout.itemSize = self.view.bounds.size;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _view = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _view.dataSource = self;
    _view.delegate = self;
    _view.backgroundColor = [UIColor blackColor];
    _view.pagingEnabled = true;
    [self.view addSubview:_view];
    [_view registerClass:[SHBPhotoItem class] forCellWithReuseIdentifier:NSStringFromClass([SHBPhotoItem class])];
    
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(disMiss:)];
    swip.direction = UISwipeGestureRecognizerDirectionDown;
    [_view addGestureRecognizer:swip];
    
}

- (void)disMiss:(UISwipeGestureRecognizer *)swipe {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SHBPhotoItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SHBPhotoItem class]) forIndexPath:indexPath];
    item.delegate = self;
    PHAsset *asset = _model[indexPath.row];
    [_manager requestImageForAsset:asset targetSize:item.bounds.size contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [item configImage:result];
    }];
    
    return item;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *array = _model;
    return array.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    SHBPhotoItem *item = (SHBPhotoItem *)cell;
    [item nomalScale];
}

//- (void)longPress:(UILongPressGestureRecognizer *)press {
//    if (press.state == UIGestureRecognizerStateBegan) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"你是否要保存本图片" preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            
//        }]];
//        [alert addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            UIImageWriteToSavedPhotosAlbum(_imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//        }]];
//        [self presentViewController:alert animated:true completion:nil];
//    }
//}

- (void)saveImage:(UIImageView *)imageView {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"你是否要保存本图片" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }]];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"Error");
    } else {
        NSLog(@"Success");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
