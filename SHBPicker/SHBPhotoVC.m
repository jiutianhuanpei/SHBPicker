//
//  SHBPhotoVC.m
//  Refresh
//
//  Created by 沈红榜 on 16/1/5.
//  Copyright © 2016年 沈红榜. All rights reserved.
//

#import "SHBPhotoVC.h"
#import "UIView+SendAction.h"
#import "SHBBrowserController.h"

static CGFloat space = 2;
static NSInteger columNum = 4;

static CGFloat btnWidth = 20;

@protocol SHBItemDelegate <NSObject>

- (void)clickedRightBtn:(id)sender;
- (void)lookBigImage:(id)sender;

@end


@interface SHBItemCell : UICollectionViewCell

- (void)configImage:(UIImage *)image;

@property (nonatomic, assign) id<SHBItemDelegate> delegate;

@end
@implementation SHBItemCell {
    UIImageView         *_imageView;
    UIButton            *_btn;
    UITapGestureRecognizer  *_tap;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = true;
        [self addSubview:_imageView];
        
        _imageView.userInteractionEnabled = true;
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [_imageView addGestureRecognizer:_tap];
        
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.frame = CGRectMake(CGRectGetWidth(frame) - btnWidth - 5, 5, btnWidth, btnWidth);
        [_btn setImage:[UIImage imageNamed:@"weixuan"] forState:UIControlStateNormal];
        [_btn setImage:[UIImage imageNamed:@"xuanze"] forState:UIControlStateSelected];
        [self addSubview:_btn];
        [_btn addTarget:self action:@selector(clickedBtn) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)clickedBtn {
    if ([_delegate respondsToSelector:@selector(clickedRightBtn:)]) {
        [_delegate clickedRightBtn:self];
    }
//    [self shbSendAction:@selector(kkkBtn:) from:self];
}

- (void)tap {
    if ([_delegate respondsToSelector:@selector(lookBigImage:)]) {
        [_delegate lookBigImage:self];
    }
//    [self shbSendAction:@selector(lookBigImage:) from:self];
}

- (void)configImage:(UIImage *)image {
    _imageView.image = image;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _btn.selected = selected;
}

@end


@interface SHBPhotoVC ()<UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver, SHBItemDelegate>

@end

@implementation SHBPhotoVC {
    PHCachingImageManager   *_manager;
    PHFetchResult           *_fetchResult;
    CGSize                  _itemSize;
    
    UICollectionView        *_view;
}

- (void)disMiss {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)makeSure {
    NSArray *indexPaths = [_view indexPathsForSelectedItems];
    __block NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    __block NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:0];
    
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = [_fetchResult objectAtIndex:indexPath.row];
        [_manager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            [images addObject:imageData];
            if (images.count == indexPaths.count) {
                if (_selectedImages) {
                    _selectedImages(images);
                }
            }
        }];
    }];
    
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = [_fetchResult objectAtIndex:indexPath.row];
        [array addObject:asset];
        if (array.count == indexPaths.count) {
            if (_callback) {
                _callback(array);
            }
        }
    }];
    
    [self disMiss];
}

- (void)goToBrowser {
    NSArray *indexPaths = [_view indexPathsForSelectedItems];
    __block NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    __weak typeof(self) SHB = self;
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = [_fetchResult objectAtIndex:indexPath.row];
        [array addObject:asset];
        if (array.count == indexPaths.count) {
            
            SHBBrowserController *browser = [[SHBBrowserController alloc] initWithImage:array];
            [SHB presentViewController:browser animated:true completion:nil];
            
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:false];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setToolbarHidden:true];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"所有照片";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(disMiss)];
    
    self.toolbarItems = @[[[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(goToBrowser)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(makeSure)]];
    
    _manager = [[PHCachingImageManager alloc] init];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat width = (CGRectGetWidth(self.view.frame) - (columNum - 1) * space) / columNum;
    _itemSize = CGSizeMake(width, width);
    layout.itemSize = CGSizeMake(width, width);
    
    _view = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _view.backgroundColor = [UIColor whiteColor];
    _view.dataSource = self;
    _view.delegate = self;
    _view.allowsMultipleSelection = true;
    _view.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    [self.view addSubview:_view];
    
    [_view registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    [_view registerClass:[SHBItemCell class] forCellWithReuseIdentifier:NSStringFromClass([SHBItemCell class])];
    // 权限
    __weak typeof(self) SHB = self;
    
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [SHB fetchData];
            
        }
    }];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)fetchData {
    _fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_view reloadData];
    });
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:_fetchResult];
    if (!details) {
        return ;
    }
    
    PHFetchResult *before = [details fetchResultBeforeChanges];
    PHFetchResult *after = [details fetchResultAfterChanges];
    _fetchResult = after;
    
    NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] initWithCapacity:0];
    [details.insertedObjects enumerateObjectsUsingBlock:^(__kindof PHObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger num = [after indexOfObject:obj];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:num inSection:0];
        [insertIndexPaths addObject:indexPath];
    }];
    
    NSMutableArray  *removeIndexPaths = [[NSMutableArray alloc] initWithCapacity:0];
    [details.removedObjects enumerateObjectsUsingBlock:^(__kindof PHObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger num = [before indexOfObject:obj];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:num inSection:0];
        [removeIndexPaths addObject:indexPath];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_view performBatchUpdates:^{
            [_view deleteItemsAtIndexPaths:removeIndexPaths];
            [_view insertItemsAtIndexPaths:insertIndexPaths];
        } completion:^(BOOL finished) {
            
        }];
    });
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SHBItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SHBItemCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    PHAsset *asset = [_fetchResult objectAtIndex:indexPath.row];
    [_manager requestImageForAsset:asset targetSize:_itemSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [cell configImage:result];        
    }];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _fetchResult.count;
}

#pragma mark - 引出

- (void)clickedRightBtn:(SHBItemCell *)sender {
    NSIndexPath *indexPath = [_view indexPathForCell:sender];
    if (sender.isSelected) {
        [_view deselectItemAtIndexPath:indexPath animated:true];
    } else {
        [_view selectItemAtIndexPath:indexPath animated:true scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)lookBigImage:(SHBItemCell *)cell {
    NSIndexPath *indexPath = [_view indexPathForCell:cell];
    if (cell.selected) {
        [_view deselectItemAtIndexPath:indexPath animated:true];
    } else {
        [_view selectItemAtIndexPath:indexPath animated:true scrollPosition:UICollectionViewScrollPositionNone];
    }
}

//- (void)kkkBtn:(SHBItemCell *)sender {
//    NSIndexPath *indexPath = [_view indexPathForCell:sender];
//    if (sender.isSelected) {
//        [_view deselectItemAtIndexPath:indexPath animated:true];
//    } else {
//        [_view selectItemAtIndexPath:indexPath animated:true scrollPosition:UICollectionViewScrollPositionNone];
//    }
//}
//
//- (void)lookBigImage:(SHBItemCell *)cell {
//    NSIndexPath *indexPath = [_view indexPathForCell:cell];
//    if (cell.selected) {
//        [_view deselectItemAtIndexPath:indexPath animated:true];
//    } else {
//        [_view selectItemAtIndexPath:indexPath animated:true scrollPosition:UICollectionViewScrollPositionNone];
//    }
//}

#pragma mark - UICollectionViewDelegateFlowLayout
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//
//    return _itemSize;
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return space;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return space;
}


@end
