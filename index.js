import { NativeModules, Platform } from "react-native";

export default (url) => {
  if (Platform.OS === "web") {
    return url;
  }
  if (!global.nativeCallSyncHook) {
    return url;
  }
  return NativeModules.VideoCache.convert(url);
};

export const convertAsync = (url) => {
  if (Platform.OS === "web") {
    return Promise.resolve(url);
  }
  return NativeModules.VideoCache.convertAsync(url);
};

export const convertAndStartDownloadAsync = NativeModules.VideoCache.convertAndStartDownloadAsync;
