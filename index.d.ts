export default function convert(url: string): string;
export function convertAsync(url: string): Promise<string>;
export function convertAndStartDownloadAsync(url: string, buffCount: number): Promise<string>;
