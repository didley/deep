import { useState } from "preact/hooks";
import "./app.css";

export function App() {
	const [count, setCount] = useState(0);
	const [msg, setMsg] = useState("");

	return (
		<>
			{msg}
			<button type="button" onClick={() => setCount((count) => count + 1)}>
				count is {count}
			</button>

			<button
				type="button"
				onClick={() =>
					WebKit()
						.postMessage({ method: "capture.start" })
						.then((a) => setMsg(JSON.stringify({ m: "started", a })))
						.catch((e) => setMsg(JSON.stringify({ m: "start error", e })))
				}
			>
				Start capture
			</button>

			<button
				type="button"
				onClick={() =>
					WebKit()
						.postMessage({ method: "capture.stop" })
						.then((a) => setMsg(JSON.stringify({ m: "stopped", a })))
						.catch((e) => setMsg(JSON.stringify({ m: "stop error", e })))
				}
			>
				Stop capture
			</button>

			<button
				type="button"
				onClick={() =>
					WebKit()
						.postMessage({ method: "capture.hasPermission" })
						.then((a) => setMsg(JSON.stringify({ m: "hasPermission", a })))
						.catch((e) =>
							setMsg(JSON.stringify({ m: "hasPermission error", e })),
						)
				}
			>
				hasPermission
			</button>
		</>
	);
}

type WebToNativeRequestFn = {
	(args: { method: "capture.start" | "capture.stop" }): Promise<{ ok: true }>;
	(args: { method: "capture.hasPermission" }): Promise<{ allowed: boolean }>;
};

type NativeObject = {
	postMessage: WebToNativeRequestFn;
};

const WebKit = () => {
	const nativeObj = (window as any)?.webkit?.messageHandlers?.native as
		| NativeObject
		| undefined;

	if (!nativeObj) {
		throw new Error("Native object not found");
	}

	return nativeObj;
};
