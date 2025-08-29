import { render } from "preact";
import "./index.css";
import { App } from "./app.tsx";

render(
	<App />,
	// biome-ignore lint: noNonNullAssertion
	document.getElementById("app")!,
);
