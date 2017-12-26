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
    CoverFlowLayout *layout = [[CoverFlowLayout alloc]init];
    _collectionView.collectionViewLayout = layout;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [ImageLoader cleanAllCash];
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
    NSLog(@"W:%f",_collectionView.bounds.size.width);
    NSLog(@"H:%f",_collectionView.bounds.size.height);
    return CGSizeMake(_collectionView.bounds.size.width, _collectionView.bounds.size.height);
}

@end
