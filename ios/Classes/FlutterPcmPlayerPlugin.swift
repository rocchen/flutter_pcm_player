import Flutter
import UIKit

public class FlutterPcmPlayerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_pcm_player", binaryMessenger: registrar.messenger())
    let instance = FlutterPcmPlayerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  private var players = [RawSoundPlayer]()

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
   var args = [String: AnyObject]()

       if(call.arguments != nil) {
           args = call.arguments as! [String: AnyObject]
       }

       let playerNo = 0

       // NSLog("call.method: \(call.method)")
       switch call.method {
       case "initialize":
         let sampleRate = args["sampleRate"] as! Int
         let nChannels = args["nChannels"] as! Int
         let pcmType: PCMType = PCMType(rawValue: args["pcmType"] as! Int)!
         initialize(
           sampleRate: sampleRate,
           nChannels: nChannels, pcmType: pcmType, result: result)
       case "release":
         release(playerNo: playerNo, result: result)
       case "play":
         play(playerNo: playerNo, result: result)
       case "stop":
         stop(playerNo: playerNo, result: result)
       case "pause":
         pause(playerNo: playerNo, result: result)
       case "resume":
         resume(playerNo: playerNo, result: result)
       case "feed":
         let _data = args["data"] as! FlutterStandardTypedData
         let data: [UInt8] = [UInt8](_data.data)
         // NSLog("data: \(data[0]) \(data[1]) \(data[2]) \(data[3]) ...")
         // NSLog("data.count: \(data.count)")
         feed(playerNo: playerNo, data: data, result: result)
       case "setVolume":
         let volume = args["volume"] as! Float
         setVolume(playerNo: playerNo, volume: volume, result: result)
       default:
         result(FlutterMethodNotImplemented)
       }
  }

   private func sendResultError(
      _ code: String, message: String?, details: Any?,
      result: @escaping FlutterResult
    ) {
      DispatchQueue.main.async {
        result(FlutterError(code: code, message: message, details: details))
      }
    }

    private func sendResultInt(_ playState: Int, result: @escaping FlutterResult) {
      DispatchQueue.main.async {
        result(playState)
      }
    }

    private func initialize(
      sampleRate: Int, nChannels: Int, pcmType: PCMType,
      result: @escaping FlutterResult
    ) {
      guard
        let player = RawSoundPlayer(
          sampleRate: sampleRate,
          nChannels: nChannels, pcmType: pcmType)
      else {
        sendResultError(
          "Error", message: "Failed to initalize", details: nil, result: result)
        return
      }
      players.append(player)
      sendResultInt(players.count - 1, result: result)
    }

    private func release(playerNo: Int, result: @escaping FlutterResult) {
      let player = players[playerNo]
      if player.release() {
        players.remove(at: playerNo)
        sendResultInt(playerNo, result: result)
      } else {
        sendResultError(
          "Error", message: "Failed to release", details: nil, result: result)
      }
    }

    private func play(playerNo: Int, result: @escaping FlutterResult) {
      let player = players[playerNo]
      if player.play() {
        sendResultInt(player.getPlayState(), result: result)
      } else {
        sendResultError(
          "Error", message: "Failed to play", details: nil, result: result)
      }
    }

    private func stop(playerNo: Int, result: @escaping FlutterResult) {
      let player = players[playerNo]
      if player.stop() {
        sendResultInt(player.getPlayState(), result: result)
      } else {
        sendResultError(
          "Error", message: "Failed to stop", details: nil, result: result)
      }
    }

    private func resume(playerNo: Int, result: @escaping FlutterResult) {
      let player = players[playerNo]
      if player.resume() {
        sendResultInt(player.getPlayState(), result: result)
      } else {
        sendResultError(
          "Error", message: "Failed to resume", details: nil, result: result)
      }
    }

    private func pause(playerNo: Int, result: @escaping FlutterResult) {
      let player = players[playerNo]
      if player.pause() {
        sendResultInt(player.getPlayState(), result: result)
      } else {
        sendResultError(
          "Error", message: "Failed to pause", details: nil, result: result)
      }
    }

    private func feed(playerNo: Int, data: [UInt8], result: @escaping FlutterResult) {
      let player = players[playerNo]
      player.feed(
        data: data,
        onDone: { r in
          if r {
            self.sendResultInt(player.getPlayState(), result: result)
          } else {
            self.sendResultError(
              "Error", message: "Failed to feed", details: nil, result: result)
          }
        }
      )
    }

    private func setVolume(playerNo: Int, volume: Float, result: @escaping FlutterResult) {
      let player = players[playerNo]
      if player.setVolume(volume) {
        sendResultInt(player.getPlayState(), result: result)
      } else {
        sendResultError(
          "Error", message: "Failed to setVolume", details: nil, result: result)
      }
    }
}
