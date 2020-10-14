//
//  ViewController.h
//  OCJSDemo
//
//  Created by fank on 2020/7/2.
//  Copyright © 2018年 Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>

@protocol JSObjcDelegate <JSExport>
-(void)scan;
@end

@interface ViewController : UIViewController


@end


@interface WeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end

