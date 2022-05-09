#import <React/RCTBridgeModule.h>

typedef (HandleResponseBlock)(NSString *);

@interface VideoCache : NSObject <RCTBridgeModule>
- (NSData *) getDataFrom:(NSString *)url;
- (void) downloadFile:(NSURL *) url callback:(HandleResponseBlock) callback;
- (NSString*) applicationDocumentsDirectory;
@end
