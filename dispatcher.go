package main

import (
	"fmt"
	"os"
	"os/exec"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: entrypoint <command> [args...]")
		os.Exit(1)
	}

	cmdName := os.Args[1]
	cmdArgs := os.Args[2:]

	// Map supported commands to their binary paths
	commandMap := map[string]string{
		"trivy":             "/usr/local/bin/trivy",
		"inspector-sbomgen": "/usr/local/bin/inspector-sbomgen",
	}

	binaryPath, exists := commandMap[cmdName]
	if !exists {
		fmt.Printf("Unknown command: %s\n", cmdName)
		os.Exit(1)
	}

	cmd := exec.Command(binaryPath, cmdArgs...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	err := cmd.Run()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to run %s: %v\n", binaryPath, err)
		os.Exit(1)
	}
}
