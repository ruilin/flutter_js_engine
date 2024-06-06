class HttpSender {
    static senderBuffer = new Map();

    constructor() {
        this.callback = null;
    }

    sendRequest(json) {
        let jsonString = JSON.stringify(json);
        // console.log(jsonString);
        ChannelHttp.postMessage(jsonString);
    }

    static onHttpResponse(jsonString) {
        try {
            let jsonObj = JSON.parse(jsonString);
            let sender = HttpSender.senderBuffer.get(jsonObj.id);
            if (sender !== undefined) {
                jsonObj.response.data = Base64.decode(jsonObj.response.data);
                jsonObj.response.headers = Base64.decode(jsonObj.response.headers);
                sender.resolve(jsonObj);
                HttpSender.senderBuffer.delete(jsonObj.id);
            } else {
                console.log('sender undefined');
            }
        } catch(e) {
            console.log('onHttpResponse error:', e);
        }
    }

    static sendRequest(url, header, data, urlParams, method) {
        let json = {
            'id': generateRandomId(6),
            'url' : url,
            'header': header,
            'data': data,
            'urlParams': urlParams,
            'method': method,
            'callbackFun': 'HttpSender.onHttpResponse'
        };
        let sender = new HttpSender();
        let promise = new Promise((resolve, reject) => {
            sender.resolve = resolve;
            sender.reject = reject;
        });
        HttpSender.senderBuffer.set(json['id'], sender);
        sender.sendRequest(json);

        setTimeout(() => {
            if (HttpSender.senderBuffer.has(json['id'])) {
                HttpSender.senderBuffer.delete(json['id']);
                sender.reject('');
            }
        }, 20000);

        return promise;
    }
}