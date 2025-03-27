package main

import (
	"encoding/json"
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
	// Run the inspector-sbomgen command with the provided args.
	runCommand("inspector-sbomgen", args)
	// If the --scan-sbom flag is provided, parse the output file for vulnerability counts.
	parseAndCompareSBOM(isCircleCI, args)
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

func parseAndCompareSBOM(isCircleCI bool, args []string) {
	// Look for the "--scan-sbom" flag and capture the output file from the "--output" flag.
	scanSBOM := false
	outputFile := ""
	for i, arg := range args {
		if arg == "--scan-sbom" {
			scanSBOM = true
		}
		if arg == "-o" && i < len(args)-1 {
			outputFile = args[i+1]
		}
	}

	if !scanSBOM {
		// If not a scan-sbom run, no further action is needed.
		return
	}

	if outputFile == "" {
		fmt.Println("No output file specified for SBOM scan results.")
		return
	}

	// Read the SBOM output file.
	data, err := os.ReadFile(outputFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading SBOM output file %s: %v\n", outputFile, err)
		return
	}

	// Define a structure to capture the vulnerability counts.
	type SbomResult struct {
		VulnerabilityCount struct {
			Critical int `json:"critical"`
			High     int `json:"high"`
			Medium   int `json:"medium"`
			Low      int `json:"low"`
			Other    int `json:"other"`
		} `json:"vulnerability_count"`
	}

	var result SbomResult
	err = json.Unmarshal(data, &result)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error parsing JSON from file %s: %v\n", outputFile, err)
		return
	}

	// Print the vulnerability counts and the file location.
	fmt.Println("SBOM Scan Results:")
	fmt.Printf("Critical: %d, High: %d, Medium: %d, Low: %d, Other: %d\n",
		result.VulnerabilityCount.Critical,
		result.VulnerabilityCount.High,
		result.VulnerabilityCount.Medium,
		result.VulnerabilityCount.Low,
		result.VulnerabilityCount.Other)
	fmt.Printf("Results file location: %s\n", outputFile)
}
