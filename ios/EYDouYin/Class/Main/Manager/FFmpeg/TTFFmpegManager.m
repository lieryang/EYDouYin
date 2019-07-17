//
//  TTFFmpegManager.m
//  CLVideo
//
//  Created by 李二洋 on 2019/7/6.
//  Copyright © 2019 TaoTie. All rights reserved.
//  该文件为 FFmpeg 执行指令的单例类, 调用对应的方法就行

#import "TTFFmpegManager.h"
#import "ffmpeg.h"

@interface TTFFmpegManager()

@property (nonatomic, assign) BOOL isRuning;
@property (nonatomic, assign) long long fileDuration;
@property (strong, nonatomic) NSMutableDictionary *coverDictionary;

@end

@implementation TTFFmpegManager
+ (instancetype)manager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.coverDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

/**
 选择手机相册中的视频
 
 @param parameters
 限制的参数
 min_time最小时间
 max_time最大时间
 task_id任务id
 task_form 任务类型id()
 limit_task_id任务id(以前普通任务不传但是现在要传了)
 */
- (void)selectVideoWithParameters:(NSDictionary *)parameters {
    CGFloat min_time = [parameters[@"min_time"] floatValue];//最小时间
    CGFloat max_time = [parameters[@"max_time"] floatValue];//最大时间
    
    if (max_time == 0.0 || min_time >= max_time) {
        EYLog(@"时间限制有问题");
        return;
    }
    
    //清除数据
    self.isRuning = NO;
    self.fileDuration = 0;
    [self.coverDictionary removeAllObjects];
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:3 delegate:nil pushPhotoPickerVc:YES];
    //展示相册中的视频
    imagePickerVc.allowPickingVideo = YES;
    //不展示图片
    imagePickerVc.allowPickingImage = NO;
    //不显示原图选项
    imagePickerVc.allowPickingOriginalPhoto = NO;
    //按时间排序
    imagePickerVc.sortAscendingByModificationDate = YES;
    //用户不能拍摄视频
    imagePickerVc.allowTakeVideo = NO;
    //选择完视频之后的回调
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
        CGFloat audioDurationSeconds = asset.duration;
        if (audioDurationSeconds <= min_time) {
            [TTProgressHUD showInfoWithStatus:[NSString stringWithFormat:TTLocalized(@"tt_0056_0"),(int)ceil(min_time)]];
        } else if (audioDurationSeconds >= max_time) {
            [TTProgressHUD showInfoWithStatus:[NSString stringWithFormat:TTLocalized(@"tt_0056_1"),(int)floor(max_time)]];
        } else {
            [self.coverDictionary addEntriesFromDictionary:parameters];
            self.coverDictionary[@"video_location_id"] = asset.localIdentifier;
            
            [self tt_getVideoOutputPathWithPHAsset:asset];
        }
    }];
    [TTKeyWindow.rootViewController presentViewController:imagePickerVc animated:YES completion:nil];
}

/**
 转换&压缩视频
 
 @param inputPath 输入视频路径
 @param ratio 宽高比 720x1280
 */
- (void)converVideoWithInputPath:(NSString *)inputPath widthHeightRatio:(NSString *)ratio {
    //    String[] commands = new String[]{"-threads","2","-i", videoPath, "-c:v", "libx264","-b:v","1250K","-s","1280x720","-crf","30","-preset", "superfast","-y",
    //        "-acodec","libmp3lame","-vol","500", outPath};
    
    //    String[] command = new String[]{"-i", path};
    
    // ffmpeg语法，可根据需求自行更改
    // !#$ 为分割标记符，也可以使用空格代替
    //    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -threads 2 -i %@ -c:v libx264 -b:v 1250K -s 1280x720 crf 30 -preset superfast -acodec libmp3lame -vol 500 -y %@", inputPath, outpath];
    // -h 输出 log
    // -threads 2
    // -i 输入文件路径
    // -c:v 编码格式
    // -b:v 视频码率
    // -s 视频frame大小
    // -aspect 宽高比
    // -b:a 音频码率
    // -ac 音频通道数 channels
    // -vol 音频的声音大小
    /*
     
     Getting help:
     -h      -- print basic options
     -h long -- print more options
     -h full -- print all options (including all format and codec specific options, very long)
     -h type=name -- print all options for the named decoder/encoder/demuxer/muxer/filter/bsf
     See man ffmpeg for detailed description of the options.
     
     Print help / information / capabilities:
     -L                  show license
     -h topic            show help
     -? topic            show help
     -help topic         show help
     --help topic        show help
     -version            show version
     -buildconf          show build configuration
     -formats            show available formats
     -muxers             show available muxers
     -demuxers           show available demuxers
     -devices            show available devices
     -codecs             show available codecs
     -decoders           show available decoders
     -encoders           show available encoders
     -bsfs               show available bit stream filters
     -protocols          show available protocols
     -filters            show available filters
     -pix_fmts           show available pixel formats
     -layouts            show standard channel layouts
     -sample_fmts        show available audio sample formats
     -colors             show available color names
     -sources device     list sources of the input device
     -sinks device       list sinks of the output device
     -hwaccels           show available HW acceleration methods
     
     Global options (affect whole program instead of just one file:
     -loglevel loglevel  set logging level
     -v loglevel         set logging level
     -report             generate a report
     -max_alloc bytes    set maximum size of a single allocated block
     -y                  overwrite output files
     -n                  never overwrite output files
     -ignore_unknown     Ignore unknown stream types
     -filter_threads     number of non-complex filter threads
     -filter_complex_threads  number of threads for -filter_complex
     -stats              print progress report during encoding
     -max_error_rate maximum error rate  ratio of errors (0.0: no errors, 1.0: 100% errors) above which ffmpeg returns an error instead of success.
     -bits_per_raw_sample number  set the number of bits per raw sample
     -vol volume         change audio volume (256=normal)
     
     Per-file main options:
     -f fmt              force format
     -c codec            codec name
     -codec codec        codec name
     -pre preset         preset name
     -map_metadata outfile[,metadata]:infile[,metadata]  set metadata information of outfile from infile
     -t duration         record or transcode "duration" seconds of audio/video
     -to time_stop       record or transcode stop time
     -fs limit_size      set the limit file size in bytes
     -ss time_off        set the start time offset
     -sseof time_off     set the start time offset relative to EOF
     -seek_timestamp     enable/disable seeking by timestamp with -ss
     -timestamp time     set the recording timestamp ('now' to set the current time)
     -metadata string=string  add metadata
     -program title=string:st=number...  add program with specified streams
     -target type        specify target file type ("vcd", "svcd", "dvd", "dv" or "dv50" with optional prefixes "pal-", "ntsc-" or "film-")
     -apad               audio pad
     -frames number      set the number of frames to output
     -filter filter_graph  set stream filtergraph
     -filter_script filename  read stream filtergraph description from a file
     -reinit_filter      reinit filtergraph on input parameter changes
     -discard            discard
     -disposition        disposition
     
     Video options:
     -vframes number     set the number of video frames to output
     -r rate             set frame rate (Hz value, fraction or abbreviation)
     -s size             set frame size (WxH or abbreviation)
     -aspect aspect      set aspect ratio (4:3, 16:9 or 1.3333, 1.7777)
     -bits_per_raw_sample number  set the number of bits per raw sample
     -vn                 disable video
     -vcodec codec       force video codec ('copy' to copy stream)
     -timecode hh:mm:ss[:;.]ff  set initial TimeCode value.
     -pass n             select the pass number (1 to 3)
     -vf filter_graph    set video filters
     -ab bitrate         audio bitrate (please use -b:a)
     -b bitrate          video bitrate (please use -b:v)
     -dn                 disable data
     
     Audio options:
     -aframes number     set the number of audio frames to output
     -aq quality         set audio quality (codec-specific)
     -ar rate            set audio sampling rate (in Hz)
     -ac channels        set number of audio channels
     -an                 disable audio
     -acodec codec       force audio codec ('copy' to copy stream)
     -vol volume         change audio volume (256=normal)
     -af filter_graph    set audio filters
     
     Subtitle options:
     -s size             set frame size (WxH or abbreviation)
     -sn                 disable subtitle
     -scodec codec       force subtitle codec ('copy' to copy stream)
     -stag fourcc/tag    force subtitle tag/fourcc
     -fix_sub_duration   fix subtitles duration
     -canvas_size size   set canvas size (WxH or abbreviation)
     -spre preset        set the subtitle options to the indicated preset
     
     usage: ffmpeg [options] [[infile options] -i infile]... {[outfile options] outfile}...
     */
    //    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -i %@ -y %@", inputPath, outpath];
    //    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -ignore_unknown -i %@ -c:v h264 -b:v 1250 -r 25 -vol 500 -y %@", inputPath, outpath];
    //    String[] commands = new String[]{"-threads", "2", "-i", videoPath, "-c:v", "libx264", "-b:v", "1250K", "-crf", "30", "-preset", "superfast", "-y",
    //        "-acodec", "aac", "-vol", "500", outPath};
    
    NSString *commandString = [NSString stringWithFormat:@"ffmpeg -threads 2 -i %@ -c:v h264 -b:v 1250K -s %@ -r 30 -vol 500 -y %@", inputPath, ratio, TTSendVideoFilePath];
    
    // 放在子线程运行
    [[[NSThread alloc] initWithTarget:self selector:@selector(runCommand:) object:commandString] start];
}

// 执行指令
- (void)runCommand:(NSString *)commandString {
    // 判断转换状态
    if (self.isRuning) {
        EYLog(@"FFmpeg正在转换,稍后重试");
        return;
    }
    self.isRuning = YES;
    
    // 指令分割为指令数组
    NSArray *argv_array = [commandString componentsSeparatedByString:(@" ")];
    
    // 将OC对象转换为对应的C对象
    int argc = (int)argv_array.count;
    char** argv = (char**)malloc(sizeof(char*)*argc);
    
    for(int i = 0; i < argc; i++) {
        argv[i] = (char*)malloc(sizeof(char)*1024);
        strcpy(argv[i],[[argv_array objectAtIndex:i] UTF8String]);
    }
    
    // 打印日志
    EYLog(@"FFmpeg 运行参数%@",commandString);
    
    // 传入指令数及指令数组
    ffmpeg_main(argc, argv);
    
    // 线程已杀死,下方的代码不会执行
}

#pragma mark - FfFmpeg的回调
// 设置总时长
+ (void)setDuration:(long long)time {
    EYLog(@"FFmpeg视频转码设置总时长 秒数==%lld", time);
    TTFFmpegManager *mgr = [TTFFmpegManager manager];
    mgr.fileDuration = time;
    mgr.coverDictionary[@"audio_duration"] = [NSString stringWithFormat:@"%ld",(long)(time * 1000)];
}

// 设置当前时间
+ (void)setCurrentTime:(long long)time {
    TTFFmpegManager *mgr = [TTFFmpegManager manager];
    if (mgr.fileDuration) {
        float process = 0.5 + ( time / (mgr.fileDuration * 1.00)) * 0.5;
        
        EYLog(@"FFmpeg视频转码==进度:%f==当前时间 %lld", process, time);
        
        //2.进度
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"state"] = @"1";
        userInfo[@"progress"] = @(process);
        [TTNotificationTool tt_postTTCompressNotificationUserInfo:userInfo];
    }
}

// 转换停止 ret:0 成功, 其他:失败
+ (void)stopRuning:(int)ret {
    TTFFmpegManager *mgr = [TTFFmpegManager manager];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:mgr.coverDictionary];
    if (ret) {//失败
        userInfo[@"state"] = @"3";
        userInfo[@"progress"] = @(1.0);
    } else {//成功
        userInfo[@"state"] = @"2";
        userInfo[@"progress"] = @(1.0);
    }
    EYLog(@"FFmpeg132456转换停止==");
    [EYNotificationTool tt_postTTCompressNotificationUserInfo:userInfo];
}

#pragma mark - 选取视频
//1.设置转移参数
- (void)tt_getVideoOutputPathWithPHAsset:(PHAsset *)asset {
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
        AVURLAsset *videoAsset = (AVURLAsset*)avasset;
        [self tt_startExportVideoWithVideoAsset:videoAsset phAsset:asset];
    }];
}

// 2.开始转移
- (void)tt_startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset phAsset:(PHAsset *)asset {
    
    // 宽高比例
    NSArray *results = [self getOriginVideoPresetNameWithPHAsset:asset];
    NSString *ratio = results.firstObject;
    NSString *presetName = results.lastObject;
    
    //0.开始进行
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"state"] = @"0";
    userInfo[@"progress"] = @(0);
    [TTNotificationTool tt_postTTCompressNotificationUserInfo:userInfo];
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    if ([presets containsObject:presetName]) {
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:presetName];
        session.shouldOptimizeForNetworkUse = YES;
        //        session.canPerformMultiplePassesOverSourceMediaData = YES;
        //        session.directoryForTemporaryFiles = [NSURL fileURLWithPath:CLPathTemp];
        
        NSString *outputPath = TTSendVideoH264FilePath;
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
        }
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        } else if (supportedTypeArray.count == 0) {
            //3.失败
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[@"state"] = @"3";
            userInfo[@"progress"] = @(1.0);
            [TTNotificationTool tt_postTTCompressNotificationUserInfo:userInfo];
            return;
        } else {
            session.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
        
        //创建定时器
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.02 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            //0 - 0.5是视频提取出来的进度
            CGFloat compress_progress = (session.progress * 0.5);
            //2.开始进行压缩
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[@"state"] = @"1";
            userInfo[@"progress"] = @(compress_progress);
            [TTNotificationTool tt_postTTCompressNotificationUserInfo:userInfo];
            if (session.progress >= 1) {
                dispatch_source_cancel(timer);
            }
        });
        dispatch_resume(timer);
        [session exportAsynchronouslyWithCompletionHandler:^(void) {
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (session.status == AVAssetExportSessionStatusCompleted) {
                    //使用 FFmpeg 指令 转码视频
                    [self converVideoWithInputPath:outputPath widthHeightRatio:ratio];
                } else {
                    //3.失败
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    userInfo[@"state"] = @"3";
                    userInfo[@"progress"] = @(1.0);
                    [TTNotificationTool tt_postTTCompressNotificationUserInfo:userInfo];
                }
            });
        }];
    } else {
        //3.失败
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"state"] = @"3";
        userInfo[@"progress"] = @(1.0);
        [TTNotificationTool tt_postTTCompressNotificationUserInfo:userInfo];
    }
}

/**
 返回视频的信息
 ratio: 宽高比例(默认720x1280)
 presetName: (默认:AVAssetExportPresetHighestQuality)
 
 @param phAsset 视频信息
 @return 数组 [ratio, presetName]
 */
- (NSArray *)getOriginVideoPresetNameWithPHAsset:(PHAsset *)phAsset {
    NSMutableArray *arrayM = [NSMutableArray array];
    
    //1.宽高比例
    NSString *ratio = @"720x1280";
    
    //原始数据
    NSUInteger pixelWidth = phAsset.pixelWidth;
    NSUInteger pixelHeight = phAsset.pixelHeight;
    double scale = pixelWidth*1.0 / 720.0;
    
    //转化后的数据
    int converPixelHeight = (int)(pixelHeight * 1.0 / scale);
    
    if (converPixelHeight > 0) {//大于 0
        ratio = [NSString stringWithFormat:@"720x%d", converPixelHeight];
    }
    [arrayM addObject:ratio];
    
    //2.视频的 presetName
    [arrayM addObject:AVAssetExportPreset3840x2160];
    
    return [NSArray arrayWithArray:arrayM];
}

@end
