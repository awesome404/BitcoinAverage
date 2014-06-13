//
//  BARateAppAlertHandler.h
//  ฿ Average
//
//  Created by Adam Dann on 2014-06-12.
//  Copyright (c) 2014 Nullriver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BARateAppAlertHandler : NSObject <UIAlertViewDelegate>

- (BOOL)shouldShow;
- (void)showAlert;

@end
