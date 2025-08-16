import type { TurboModule } from "react-native";
import { TurboModuleRegistry } from "react-native";

export interface Spec extends TurboModule {
	startCapture(): void;
	endCapture(): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>("NativeScreenCapture");
