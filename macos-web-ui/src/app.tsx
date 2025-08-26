import { useEffect, useState } from "preact/hooks";
import "./app.css";
import { WebKit, type WebKitObject } from "./services/webKit";
import { useOnFocus } from "./utils/hooks/useOnFocus";

type SessionStatus =
	| { kind: "idle" }
	| { kind: "loading" }
	| { kind: "success"; active: boolean }
	| { kind: "error"; msg: string };

const INACTIVE_TEXT = "Go deep";
const STOP_TEXT = "Cancel session";

type ScreenPermsStatus =
	| { kind: "idle" }
	| { kind: "loading" }
	| { kind: "success"; allowed: boolean }
	| { kind: "error"; msg: string };

const refreshSessionStatus = async ({
	setSessionStatus,
	wk,
}: {
	setSessionStatus: (args: SessionStatus) => void;
	wk: WebKitObject;
}) => {
	try {
		const { active } = await wk.postMessage({
			method: "capture.isActive",
		});

		setSessionStatus({ kind: "success", active });
	} catch (e) {
		console.error(e);
		setSessionStatus({
			kind: "error",
			msg: "Failed to fetch session status.",
		});
	}
};

export const App = () => {
	const [sessionStatus, setSessionStatus] = useState<SessionStatus>({
		kind: "idle",
	});

	const [hasScreenPerms, setHasScreenPerms] = useState<ScreenPermsStatus>({
		kind: "idle",
	});

	const isActiveSession =
		sessionStatus.kind === "success" && sessionStatus.active;

	const isLoading =
		sessionStatus.kind === "loading" || hasScreenPerms.kind === "loading";

	const wk = WebKit();

	useEffect(() => {
		const initSessionStats = async () => {
			setSessionStatus({ kind: "loading" });
			refreshSessionStatus({ setSessionStatus, wk });
		};

		initSessionStats();
	}, []);

	useEffect(() => {
		const initFetchScreenPermsStatus = async () => {
			setHasScreenPerms({ kind: "loading" });

			try {
				const { allowed } = await wk.postMessage({
					method: "capture.hasPermission",
				});

				setHasScreenPerms({ kind: "success", allowed });
			} catch (e) {
				console.error(e);
				setHasScreenPerms({
					kind: "error",
					msg: "Failed to load screen permissions.",
				});
			}
		};

		initFetchScreenPermsStatus();
	}, []);

	useOnFocus(() => refreshSessionStatus({ setSessionStatus, wk }));

	const handleStartSession = async () => {
		setSessionStatus({ kind: "loading" });
		try {
			await wk.postMessage({ method: "capture.start" });
			setSessionStatus({ kind: "success", active: true });
		} catch (e) {
			console.error(e);
			setSessionStatus({ kind: "error", msg: "Failed to start session." });
		}
	};

	const handleEndSession = async () => {
		setSessionStatus({ kind: "loading" });
		try {
			await wk.postMessage({ method: "capture.stop" });
			setSessionStatus({ kind: "success", active: false });
		} catch (e) {
			console.error(e);
			setSessionStatus({ kind: "error", msg: "Failed to start session." });
		}
	};

	const noScreenPerms =
		!isLoading && hasScreenPerms.kind === "success" && !hasScreenPerms.allowed;

	const sessionButtonDisabled = isLoading || noScreenPerms;

	return (
		<div>
			<p>Deep status: {JSON.stringify({ sessionStatus, hasScreenPerms })}</p>
			<button
				type="button"
				onClick={isActiveSession ? handleEndSession : handleStartSession}
				disabled={sessionButtonDisabled}
			>
				{isActiveSession ? STOP_TEXT : INACTIVE_TEXT}
			</button>

			{noScreenPerms && (
				<div>
					<p>⚠️ You don't have screen permissions enabled.</p>
					<button
						type="button"
						onClick={() => wk.postMessage({ method: "capture.start" })}
					>
						Request access
					</button>
				</div>
			)}
		</div>
	);
};
