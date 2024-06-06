class SpStorage {
    static callbackBuffer = new Map();

    static set(key, value) {
        let json = {
            'key': key,
            'value': value
        };
        let jsonString = JSON.stringify(json);
        ChannelSave.postMessage(jsonString);
    }

    static get(key) {
        let json = {
            'id': generateRandomId(6),
            'key': key,
            'callbackFun': 'SpStorage.onGetValue'
        };
        let sp = new SpStorage();
        let promise = new Promise((resolve, reject) => {
            sp.resolve = resolve;
            sp.reject = reject;
        });
        SpStorage.callbackBuffer.set(json['id'], sp);

        let jsonString = JSON.stringify(json);
        ChannelRead.postMessage(jsonString);

        setTimeout(() => {
            if (HttpSender.senderBuffer.has(json['id'])) {
                HttpSender.senderBuffer.delete(json['id']);
                sender.reject('');
            }
        }, 1000);

        return promise;
    }

    static onGetValue(jsonString) {
        try {
            let jsonObj = JSON.parse(jsonString);
            let sp = SpStorage.callbackBuffer.get(jsonObj.id);
            if (sp !== undefined) {
                sp.resolve(Base64.decode(jsonObj.value));
                SpStorage.callbackBuffer.delete(jsonObj.id);
            } else {
                console.log('sp undefined');
            }
        } catch(e) {
            console.log('onGetValue error:', e);
        }
    }
}