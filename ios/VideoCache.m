#import "VideoCache.h"
#import <KTVHTTPCache/KTVHTTPCache.h>

@implementation VideoCache

RCT_EXPORT_MODULE()

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(convert:(NSString *)url)
{
//    [KTVHTTPCache logSetConsoleLogEnable:YES];
    if (!KTVHTTPCache.proxyIsRunning) {
      NSError *error;
      [KTVHTTPCache proxyStart:&error];
      if (error) {
        return url;
      }
    }
    return [KTVHTTPCache proxyURLWithOriginalURL:[NSURL URLWithString:url]].absoluteString;
}

RCT_EXPORT_METHOD(convertAsync:(NSString *)url
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [KTVHTTPCache logSetConsoleLogEnable:YES];
  if (!KTVHTTPCache.proxyIsRunning) {
    NSError *error;
    [KTVHTTPCache proxyStart:&error];
    if (error) {
      reject(@"init.error", @"failed to start proxy server", error);
      return;
    }
  }
  resolve([KTVHTTPCache proxyURLWithOriginalURL:[NSURL URLWithString:url]].absoluteString);
}

RCT_EXPORT_METHOD(convertAndStartDownloadAsync:(NSString *)url
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  if (!KTVHTTPCache.proxyIsRunning) {
    NSError *error;
    [KTVHTTPCache proxyStart:&error];
    if (error) {
      reject(@"init.error", @"failed to start proxy server", error);
      return;
    }
  }

    NSURL *fileUrl = [[NSURL alloc] initWithString:url];
    @try {
        NSURL *completedCacheFileURL = [KTVHTTPCache cacheCompleteFileURLWithURL:fileUrl];
        if (completedCacheFileURL != nil) {
            resolve(completedCacheFileURL.absoluteString);
            return;
        }
    }
    @catch (NSException *exception) {
    }
    NSLog(@"Downloading Started");
    NSURL *proxyUrl = [KTVHTTPCache proxyURLWithOriginalURL:fileUrl];
    NSData *urlData = [NSData dataWithContentsOfURL:proxyUrl];
    if ( urlData )
    {
        NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
        NSString *outFilePath =  [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"video-editor/Download_cache_%.0f.mp4", timeInSeconds]];

        [urlData writeToFile:outFilePath atomically:YES];
        NSLog(@"File Saved !");
        NSURL *completedCacheFileURL = [KTVHTTPCache cacheCompleteFileURLWithURL:fileUrl];
        if (completedCacheFileURL != nil) {
            NSError *error = nil;
            NSFileManager *manager = [NSFileManager defaultManager];
            [manager removeItemAtPath:outFilePath error:&error];
            
            resolve(completedCacheFileURL.absoluteString);
        } else resolve(outFilePath);
    } else resolve(proxyUrl.absoluteString);
}

- (NSString*) applicationDocumentsDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
