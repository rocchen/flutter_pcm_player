package com.example.flutter_pcm_player;


import androidx.annotation.NonNull;
import android.util.Log;
import java.util.Map;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterPcmPlayerPlugin */
public class FlutterPcmPlayerPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private PcmPlayer player = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_pcm_player");
    channel.setMethodCallHandler(this);
    player = new PcmPlayer();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("initialize")) {
      Map args = (Map)call.arguments;
      int nChannels = (int)args.get("nChannels");
      int sampleRate = (int)args.get("sampleRate");
      int pcmType = (int)args.get("pcmType");
      player.init(nChannels, sampleRate, pcmType);
      result.success(null);
    } else if (call.method.equals("release")) {
      player.release();
      result.success(null);
    } else if (call.method.equals("play")) {
      player.play();
      result.success(player.getPlayState());
    } else if (call.method.equals("stop")) {
      player.stop();
      result.success(player.getPlayState());
    } else if (call.method.equals("pause")) {
      player.pause();
      result.success(player.getPlayState());
    } else if (call.method.equals("resume")) {
      player.play();
      result.success(player.getPlayState());
    } else if (call.method.equals("feed")) {
      Map args = (Map)call.arguments;
      Log.d("PcmPlayer", "feed() args:" + args);
      player.write((byte[])args.get("data"));
      result.success(player.getPlayState());
    } else if (call.method.equals("setVolume")) {
      Map args = (Map)call.arguments;
      Log.d("PcmPlayer", "setVolume() args:" + args);
      player.setVolume((double)args.get("volume"));
      result.success(player.getPlayState());
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
