//
//  UserPhotoDetailViewController.m
//  ClickrFlickr
//
//  Created by Artur Olar on 11/23/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

#import "UserPhotoDetailViewController.h"
#import "UserPhotoDetailCell.h"
#import "CoverFlowLayout.h"
#import "ClickrFlickr-Swift.h"

@interface UserPhotoDetailViewController()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation UserPhotoDetailViewController

@synthesize photos;

- (void)viewDidLoad {
    [super viewDidLoad];
    CenterCellCollectionViewFlowLayout *layout = [[CenterCellCollectionViewFlowLayout alloc]init];
    _collectionView.collectionViewLayout = layout;
    UIColor *color = [[UIColor alloc]initWithRed:0.1915385664 green:0.1915385664 blue:0.1915385664 alpha:1.0];
    _collectionView.backgroundColor = color;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [ImageLoader cleanAllCash];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    CGPoint offset = _collectionView.contentOffset;
    CGFloat width = _collectionView.bounds.size.width;
    CGFloat newWidth = size.width;
    CGFloat index = offset.x / width;
    CGPoint newOffset = CGPointMake(index * newWidth, offset.y);
    _collectionView.contentOffset = newOffset;
}

#pragma UICollectionViewDataSource

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return photos.count;
}

- (__kindof UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UserPhotoDetailCell";
    
    UserPhotoDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Photo *photo = [photos objectAtIndex:indexPath.item];
    [ImageLoader loadImageUsingUrlStringWithUrlString:photo.url completion:^(UIImage * _Nullable image) {
        cell.photo.image = image;
    }];
    return cell;
}

#pragma UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (@available(iOS 11.0, *)) {
        return CGSizeMake(_collectionView.bounds.size.width, _collectionView.bounds.size.height - (_collectionView.safeAreaInsets.bottom + _collectionView.safeAreaInsets.top));
    } else {
        return CGSizeMake(_collectionView.bounds.size.width, _collectionView.bounds.size.height - (_collectionView.layoutMargins.bottom + _collectionView.layoutMargins.top));
    }
}

@end
