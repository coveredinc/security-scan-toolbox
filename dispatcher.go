package main

import (
	"fmt"
	"os"
	"os/exec"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: dispatcher <command> [args...]")
		os.Exit(1)
	}

	cmdName := os.Args[1]
	cmdArgs := os.Args[2:]

	// Detect if running in CircleCI
	isCircleCI := os.Getenv("CIRCLECI") == "true"

	switch cmdName {
	case "trivy":
		runTrivy(cmdArgs, isCircleCI)
	case "inspector-sbomgen":
		runInspectorSBOM(cmdArgs, isCircleCI)
	default:
		runCommand(cmdName, cmdArgs)
	}
}

func runTrivy(args []string, isCircleCI bool) {
	if isCircleCI {
		args = append(args, "--format", "junit", "--output", "/tmp/trivy-report.xml")
	} else {
		args = append(args, "--format", "table")
	}
	runCommand("trivy", args)
}

func runInspectorSBOM(args []string, isCircleCI bool) {
	runCommand("inspector-sbomgen", args)
	// Parse and compare results
	parseAndCompareSBOM(isCircleCI)
}

func runCommand(cmdName string, cmdArgs []string) {
	cmd := exec.Command(cmdName, cmdArgs...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	err := cmd.Run()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to run %s: %v\n", cmdName, err)
		os.Exit(1)
	}
}

func parseAndCompareSBOM(isCircleCI bool) {
	// Placeholder for parsing and comparing SBOM results
	// Implement the logic to parse the SBOM results and compare with the latest ECR image
	// Notify the developer locally or fail the test in CircleCI
}
