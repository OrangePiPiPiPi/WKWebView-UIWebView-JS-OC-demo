function buttonDivAction() {
    //此处是为了兼容UIWebView和WKWebView两种调用OC方法
    if (typeof window.scope != 'undefined'){
        window.scope.scan();
    }else {
        window.webkit.messageHandlers.scan.postMessage({});
        /*
         1.不带参数：
         window.webkit.messageHandlers.scan.postMessage({});
         window.webkit.messageHandlers.scan.postMessage([]);
         但是不能使用window.webkit.messageHandlers.scan.postMessage()方式
         2.带参数
         window.webkit.messageHandlers.senderModel.postMessage({body: 'sender message'});
         window.webkit.messageHandlers.senderModel.postMessage([body: 'sender message']);
         */
    }
}

function alertAction(message) {
	alert(message);
}
