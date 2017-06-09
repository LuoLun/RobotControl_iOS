//
//  VoiceRecognizerAdapter.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/9.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

protocol VoiceRecognizerAdapterDelegate {
    func initError(_ error: Error)
    
    func error(_ error: Error)
    func onResult(best: String, all: [String: Float])
    
    func onBeginSpeech()
    func onFinishSpeech()
    func onCancel()
}

class VoiceRecognizerAdapter: NSObject {
    
    let delegate: VoiceRecognizerAdapterDelegate
    var _iflySpeechRecognizer: IFlySpeechRecognizer?
    
    init(delegate: VoiceRecognizerAdapterDelegate) throws {
        self.delegate = delegate
        super.init()
                
        _iflySpeechRecognizer = IFlySpeechRecognizer.sharedInstance()
        _iflySpeechRecognizer!.delegate = self
        
        //设置在线识别参数
        //开启候选结果
        _iflySpeechRecognizer!.setParameter("1", forKey: "asr_wbest")
        
        //设置引擎类型，cloud 或者 local
        _iflySpeechRecognizer!.setParameter("cloud", forKey: IFlySpeechConstant.engine_TYPE())
        //设置字符编码为 utf-8
        _iflySpeechRecognizer!.setParameter("utf-8", forKey: IFlySpeechConstant.text_ENCODING())
        //语法类型，本地是 bnf，在线识别是 abnf
        _iflySpeechRecognizer!.setParameter("abnf", forKey: IFlySpeechConstant.grammar_TYPE())
        //设置服务类型为 asr 识别
        _iflySpeechRecognizer!.setParameter("asr", forKey: IFlySpeechConstant.ifly_DOMAIN())
        
//        _iflySpeechRecognizer!.setParameter("json", forKey: IFlySpeechConstant.result_TYPE())
        _iflySpeechRecognizer!.setParameter("30000", forKey: IFlySpeechConstant.speech_TIMEOUT())
        _iflySpeechRecognizer!.setParameter("3000", forKey: IFlySpeechConstant.vad_EOS())
        _iflySpeechRecognizer!.setParameter("3000", forKey: IFlySpeechConstant.vad_BOS())
        _iflySpeechRecognizer!.setParameter("16000", forKey: IFlySpeechConstant.sample_RATE())
        _iflySpeechRecognizer!.setParameter("zh_cn", forKey: IFlySpeechConstant.language())
        _iflySpeechRecognizer!.setParameter("mandarin", forKey: IFlySpeechConstant.accent())



        
        try setCommandPatterns()
    }
    
    var _grammerReady = false
    
    func setCommandPatterns() throws {
        //编译语法文件，注意 grammerType 参数的区别
        //读取本地 abnf 语法文件内容
        let grammarFilePath = Bundle.main.path(forResource: "VoiceCommandDef", ofType: "abnf")
        let grammarContent = try NSString(contentsOfFile: grammarFilePath!, encoding: String.Encoding.utf8.rawValue)
        //调用构建语法接口
        _iflySpeechRecognizer?.buildGrammarCompletionHandler({ (grammarID: String?, error: IFlySpeechError?) in
            if let error = error, error.errorCode != 0 {
                self.delegate.initError(VoiceRecognizerAdapterError(error.errorDesc, code: 1))
                return
            }
            
            self._iflySpeechRecognizer?.setParameter(grammarID, forKey: IFlySpeechConstant.cloud_GRAMMAR())
            self._grammerReady = true
        }, grammarType: "abnf", grammarContent: grammarContent as String!)
    }
    
    func recognizeSpeech() -> Bool {
        return _grammerReady && _iflySpeechRecognizer!.startListening()
    }
    
    func stopSpeech() -> Bool {
        _iflySpeechRecognizer!.stopListening()
        return true
    }
}

extension VoiceRecognizerAdapter: IFlySpeechRecognizerDelegate {
    //识别 IFlySpeechRecognizerDelegate 协议 
    //本地和在线的识别返回代理是一致
    //在切换在线和离线服务时还需要注意参数的重置,具体可以参照 demo 所示 
    
    //结果返回代理
    func onResults(_ results: [Any]!, isLast: Bool) {
        let theResult = results[0] as? NSDictionary
        guard let result = theResult as? Dictionary<String, String> else {
            delegate.error(VoiceRecognizerAdapterError("语法识别回调发生未知错误", code: -1))
            return
        }
        guard let resultString = Array(result.keys).first else {
            delegate.error(VoiceRecognizerAdapterError("语法识别回调发生未知错误", code: -1))
            return
        }
        
        var converted = [String: Float]()
        var components = resultString.components(separatedBy: " ")
        for i in 0..<components.count {
            components[i] = components[i].components(separatedBy: "=").last!
        }
        
        for i in 0..<(components.count / 3)  {
            converted[components[3 * i + 2]] = Float(components[3 * i])
        }
        
        var maxPercentage: Float = 0
        var bestResult: String = ""
        
        for key in converted.keys {
            let percentage = converted[key]
            if percentage! > maxPercentage {
                bestResult = key
                maxPercentage = percentage!
            }
        }
        
        delegate.onResult(best: bestResult, all: converted)
    }
    
    //会话结束回调
    func onError(_ errorCode: IFlySpeechError!) {
        delegate.error(VoiceRecognizerAdapterError(errorCode.errorDesc, code: -1))
    }
    
    //录音音量回调
    func onVolumeChanged(_ volume: Int32) {
        
    }
    
    //录音开始回调
    func onBeginOfSpeech() {
        delegate.onBeginSpeech()
    }
    
    //录音结束回调
    func onEndOfSpeech() {
        delegate.onFinishSpeech()
    }
    
    //会话取消回调
    func onCancel() {
        delegate.onCancel()
    }
}

class VoiceRecognizerAdapterError: RobotControlError {
    
}
