import { defineConfig } from "tsup";

export default defineConfig({
	entry: ["src/index.ts"],
	splitting: false,
	sourcemap: true,
	clean: true,
	// noExternal enables all node_modules to be included in build output
	noExternal: [/.*/],
	format: ["esm"],
	outExtension: () => ({ js: ".mjs" }),
	outDir: "dist/js"
});