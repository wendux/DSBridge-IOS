//
//  WebEventDelegate.h
//  dspider
//
//  Created by 杜文 on 16/12/28.
//  Copyright © 2016年 杜文. All rights reserved.
//

#import <Foundation/Foundation.h>

CF_ASSUME_NONNULL_BEGIN
@protocol JSBWebEventDelegateProtocol <NSObject>
@optional
- (void) onPageStart:(NSString *)url;
- (void) onpageFinished:(NSString *)url;
- (void) onpageError:(NSString *)url :(NSString *) msg;
- (BOOL) shouldStartLoadWithRequest:(NSURLRequest *)request :(UIWebViewNavigationType)navigationType;
@end
CF_ASSUME_NONNULL_END
