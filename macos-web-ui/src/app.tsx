import { useState } from "preact/hooks";
import preactLogo from "./assets/preact.svg";
import viteLogo from "/vite.svg";
import "./app.css";

export function App() {
	const [count, setCount] = useState(0);

	return (
		<>

				<button type="button" onClick={() => setCount((count) => count + 1)}>
					count is {count}
				</button>

<button type="button" onClick={() => WebKit().postMessage({type: 'startCapture'})}>
  Start capture
</button>

<button type="button" onClick={() => WebKit().postMessage({type: 'stopCapture'})}>
  Stop capture
</button>


		</>
	);
}


type WebKitAction = {type: "startCapture"}

type NativeObject = {
 postMessage:(action: WebKitAction) => void
}

const WebKit = () => {
  const nativeObj = (window as any)?.webkit?.messageHandlers?.native as NativeObject | undefined

  if(!nativeObj) {
    throw new Error("Native object not found")
  }

  return nativeObj
}