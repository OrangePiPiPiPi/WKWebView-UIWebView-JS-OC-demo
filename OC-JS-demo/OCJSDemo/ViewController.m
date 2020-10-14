//
//  ViewController.m
//  OCJSDemo
//
//  Created by fank on 2020/7/2.
//  Copyright © 2018年 Dong. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#define KMainWidth ([UIScreen mainScreen].bounds.size.width)
#define KMainHeight ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,UIWebViewDelegate,JSObjcDelegate>

@property(nonatomic,strong)WKWebView *mainWebView;

@property(nonatomic,strong)UIWebView *webView;

@property (nonatomic, strong) JSContext *jsContext;

@property (nonatomic, assign) BOOL isWKWebView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isWKWebView = YES;
    if (self.isWKWebView) {
         [self.view addSubview:self.mainWebView];
    }else {
         [self.view addSubview:self.webView];
    }
    self.view.backgroundColor = [UIColor whiteColor];
}

- (WKWebView *)mainWebView{
    if (_mainWebView == nil) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userController = [[WKUserContentController alloc] init];
        // [userController addScriptMessageHandler:self name:@"scan"];
        // WeakScriptMessageDelegate 主要是用来解决（[userController addScriptMessageHandler:self name:@"scan"];）方式带了的循环引用问题
        [userController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:@"scan"];
        configuration.userContentController = userController;
        _mainWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, KMainWidth, KMainHeight) configuration:configuration];
        NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"index.html"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
        [_mainWebView loadRequest: request];
        _mainWebView.navigationDelegate = self;
        _mainWebView.UIDelegate = self;
    }
    return _mainWebView;
}


- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, KMainWidth, KMainHeight)];
        _webView.delegate = self;
        NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"index.html"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
        [_webView loadRequest: request];
    }
    return _webView;
}

- (void)scan{
    dispatch_async(dispatch_get_main_queue(), ^{//适配13.6
        NSLog(@"=========scan调用成功");
        if (self.isWKWebView) {
            //WKWebView中OC调用JS方法并传值
             [self.mainWebView evaluateJavaScript:@"alertAction('WKWebView-OC调用JS警告窗方法')" completionHandler:^(id _Nullable item, NSError * _Nullable error) {
                   NSLog(@"self.mainWebView evaluateJavaScript:completionHandler:");
               }];
        }else {
            // UIWebView中OC调用JS方法并传值
            JSValue *Callback = self.jsContext[@"alertAction"];
            [Callback callWithArguments:@[@"UIWebView-OC调用JS警告窗方法"]];
        }
    });
}

#pragma mark *****UIWebViewDelegate*****
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext[@"scope"] = self;
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
   NSLog(@"页面加载失败");
}

#pragma mark WKScriptMessageHandler
//接收到JS调用的OC方法的回调
/*
 js端通过window.webkit.messageHandlers.name.postMessage({});调用OC端方法,此处name要和上面[userController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:@"scan"];设置的name保持一致
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"scan"]) {
        [self scan];
    }
}

#pragma mark *****WKWebViewDelegate*****
//当main frame的导航开始请求时，会调用此方法
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
}

//当main frame导航完成时，会回调
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  
}

//当main frame开始加载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {

}


//接收到警告面板
//调用JS的alert()方法
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //此处的completionHandler()就是调用JS方法时，`evaluateJavaScript`方法中的completionHandler
        completionHandler();
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

//接收到确认面板
//调用JS的confirm()方法
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    
}

//接收到输入框
//调用JS的prompt()方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    
}

- (void)dealloc{
    [self.mainWebView.configuration.userContentController removeScriptMessageHandlerForName:@"scan"];
}


@end



@implementation WeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
       [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end
