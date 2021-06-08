//
//  AudioController.swift
//  Anagrams
//
//  Created by KIMYOUNG SIK on 2018. 2. 13..
//  Copyright © 2018년 Caroline. All rights reserved.
//

import AVFoundation

class AudioController {
    //딕셔너리 key/value = 오디오파일이름/오디오객체
    private var audio = [String: AVAudioPlayer]()
    
    var player: AVAudioPlayer?
    
    //모든 오디오파일을 preload하기 위한 메소드
    func preloadAudioEffects(audioFileNames: [String]) {
        for effect in AudioEffectFiles {
            // 1. 오디오 파일 path 얻어옴
            let soundPath = Bundle.main.path(forResource: effect, ofType: nil)
            let soundURL = NSURL.fileURL(withPath: soundPath!)
            
            // 2. 오디오 파일 로딩
            do {
                player = try AVAudioPlayer(contentsOf: soundURL)
                guard let player = player else {
                    return
                }
                //3. 1번만 플레이하도록 설정
                player.numberOfLoops = 0
                player.prepareToPlay()
                //4. 딕셔너리에 추가
                audio[effect] = player
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    //오디오 파일 플레이 메소드
    func playerEffect(name: String) {
        if let player = audio[name] {
            if player.isPlaying {
                //오디오가 이미 플레이 중이라면 rewind 처음으로
                player.currentTime = 0
            } else {
                player.play()
            }
        }
    }

}
