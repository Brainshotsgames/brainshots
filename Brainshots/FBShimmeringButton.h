//
//  FBShimmeringButton.h
//  Brainshots
//
//  Created by Amrit on 18/05/17.
//  Copyright © 2017 Anuradha Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBShimmering.h"

@interface FBShimmeringButton : UIButton <FBShimmering>

//! @abstract The content view to be shimmered.
@property (strong, nonatomic) UIView *contentView;

@end
