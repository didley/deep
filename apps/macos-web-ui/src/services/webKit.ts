type WebToNativeRequestFn = {
	(args: { method: "capture.start" | "capture.stop" }): Promise<{ ok: true }>;
	(args: { method: "capture.hasPermission" }): Promise<{ allowed: boolean }>;
	(args: { method: "capture.isActive" }): Promise<{ active: boolean }>;
};

export type WebKitObject = {
	postMessage: WebToNativeRequestFn;
};

export const WebKit = () => {
	const nativeObj = (window as any)?.webkit?.messageHandlers?.native as
		| WebKitObject
		| undefined;

	if (!nativeObj) {
		throw new Error("Native object not found");
	}

	return nativeObj;
};
