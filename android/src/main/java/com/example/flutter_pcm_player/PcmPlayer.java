package com.example.flutter_pcm_player;

import androidx.annotation.NonNull;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.util.Log;

enum PlayState {
    stopped,
    playing,
    paused,
}

enum PCMType {
    pcm8,
    pcm16,
    pcm32,
}

public class PcmPlayer {
    private static final String TAG = "PcmPlayer";

    private static final int CMD_WRITE = 1;
    private static final int CMD_WRITE32 = 2;

    private AudioTrack mAudioTrack;
    private int mBufferSize = 0;

    private HandlerThread mThread;
    private MyHandler mHandler;

    PcmPlayer() {
        mThread = new HandlerThread("pcmplayer");
        mThread.start();
        mHandler = new MyHandler(mThread.getLooper());
    }

    void init(final int nChannels, final int sampleRate, final int pcmType) {
        PCMType type = PCMType.values()[(int)pcmType];
        int format = type == PCMType.pcm8 ? AudioFormat.ENCODING_PCM_8BIT :
                type == PCMType.pcm16 ? AudioFormat.ENCODING_PCM_16BIT : AudioFormat.ENCODING_PCM_FLOAT;
        int channelConfig = nChannels == 1 ? AudioFormat.CHANNEL_OUT_MONO : AudioFormat.CHANNEL_OUT_STEREO;
        mBufferSize = AudioTrack.getMinBufferSize(sampleRate, channelConfig, format);

        mAudioTrack = new AudioTrack(AudioManager.STREAM_MUSIC, sampleRate,
                channelConfig, format, mBufferSize, AudioTrack.MODE_STREAM);
        Log.d(TAG, "init() channel:" + nChannels + ", sampleRate:" + sampleRate + ", type:" + type);

        /*Message msg = Message.obtain();
        msg.what = CMD_INIT;
        msg.obj = nChannels;
        msg.arg1 = sampleRate;
        msg.arg2 = pcmType;
        mHandler.sendMessage(msg);*/
    }

    void release() {
        if(mAudioTrack != null) {
            mAudioTrack.release();
            mAudioTrack = null;
        }
        //mHandler.sendEmptyMessage(CMD_RELEASE);
    }

    void play() {
        if(mAudioTrack != null)
            mAudioTrack.play();
        //mHandler.sendEmptyMessage(CMD_PLAY);
    }

    void stop() {
        if(mAudioTrack != null)
            mAudioTrack.stop();
        //mHandler.sendEmptyMessage(CMD_STOP);
    }

    void pause() {
        if(mAudioTrack != null)
            mAudioTrack.pause();
        //mHandler.sendEmptyMessage(CMD_PAUSE);
    }

    // for pcm8 && pcm16
    void write(byte[] data) {
        Message msg = Message.obtain();
        msg.what = CMD_WRITE;
        msg.obj = data;
        mHandler.sendMessage(msg);
    }

    // for pcm32
    void write(float[] data) {
        Message msg = Message.obtain();
        msg.what = CMD_WRITE32;
        msg.obj = data;
        mHandler.sendMessage(msg);
    }

    int getBufferSize() {
        return mBufferSize;
    }
    int getFormat() {
        if(mAudioTrack != null)
            return mAudioTrack.getAudioFormat();
        else
            return 0;
    }

    int getPlayState() {
        if(mAudioTrack == null)
            return PlayState.stopped.ordinal();
        int state = mAudioTrack.getPlayState();
        switch(state) {
            case AudioTrack.PLAYSTATE_PAUSED:
                return PlayState.paused.ordinal();
            case AudioTrack.PLAYSTATE_PLAYING:
                return PlayState.playing.ordinal();
            default:
            case AudioTrack.PLAYSTATE_STOPPED:
                return PlayState.stopped.ordinal();
        }
    }

    void setVolume(double gain) {
        /*Message msg = Message.obtain();
        msg.what = CMD_SET_VOLUME;
        msg.obj = gain;
        mHandler.sendMessage(msg);*/
    }

    private class MyHandler extends Handler {
        MyHandler(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(@NonNull Message msg) {
            switch(msg.what) {
                case CMD_WRITE: {
                    byte[] data = (byte[])msg.obj;
                    if (mAudioTrack != null && mAudioTrack.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
                        int pos = 0;
                        while (pos < data.length) {
                            int len = pos + mBufferSize > data.length ? data.length - pos : mBufferSize;
                            mAudioTrack.write(data, pos, len);
                            pos += len;
                        }
                    }
                    break;
                }
                case CMD_WRITE32: {
                    float[] data = (float[])msg.obj;
                    if(mAudioTrack != null && mAudioTrack.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
                        int pos = 0;
                        while (pos < data.length) {
                            int len = pos + mBufferSize/4 > data.length ? data.length - pos : mBufferSize/4;
                            mAudioTrack.write(data, 0, len, AudioTrack.WRITE_BLOCKING);
                            pos += len;
                        }
                        mAudioTrack.write(data, pos, data.length, AudioTrack.WRITE_BLOCKING);
                    }
                    break;
                }
                default:
                    Log.e(TAG, "command not support! " + msg.what);
                    break;
            }
        }
    }
}
