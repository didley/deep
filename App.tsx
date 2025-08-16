import { View } from "react-native";
import { Button, Text } from "react-native-macos";
import NativeScreenCapture from "./specs/NativeScreenCapture";

const App = () => {
	const startCapture = () => NativeScreenCapture.startCapture();

	const endCapture = () => NativeScreenCapture.endCapture();

	return (
		<View>
			<Text>Press:</Text>
			<Button title="Start" onPress={startCapture} />

			<Button title="End" onPress={endCapture} />
		</View>
	);
};

export default App;
