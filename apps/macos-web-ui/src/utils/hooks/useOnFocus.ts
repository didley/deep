import { useEffect } from "react";

export function useOnFocus(callback: () => void) {
	useEffect(() => {
		const handleFocus = () => callback();

		window.addEventListener("focus", handleFocus);
		return () => window.removeEventListener("focus", handleFocus);
	}, [callback]);
}
