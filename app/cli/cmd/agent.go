package cmd

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"plandex-cli/agent_exec"

	"github.com/spf13/cobra"
)

var agentCmd = &cobra.Command{
	Use:   "agent [prompt]",
	Short: "Run Plandex in autonomous agent mode (local mode by default)",
	Long: `Run Plandex in autonomous agent mode similar to Cursor's agent mode.
This mode provides human-readable progress and autonomous execution capabilities.
Perfect for interactive use and automation.

By default, agent mode runs in LOCAL MODE - it works standalone without requiring
a server or database. It automatically detects if full mode (server + database)
is available and uses it if detected, otherwise falls back to local mode.

You can force modes with --local-mode or --full-mode flags.

The agent mode displays clean, readable progress by default. Use --json for
machine-readable output or --output to save JSON to a file.

You can provide the prompt in several ways:
- As a command line argument: plandex agent "Fix the bug"
- From a file: plandex agent --file prompt.txt
- From stdin: echo "Fix the bug" | plandex agent

Examples:
  plandex agent "Fix the bug in the login function"
  plandex agent --file task.txt
  echo "Add a new API endpoint" | plandex agent
  plandex agent "Refactor the database layer" --json
  plandex agent "Implement user auth" --output results.json
  plandex agent "Create a new feature" --full-mode
  plandex agent "Quick fix" --local-mode`,
	Args: cobra.RangeArgs(0, 1),
	Run:  runAgent,
}

var (
	agentOutputFile    string
	agentPromptFile    string
	agentNoPlan        bool
	agentAutoExec      bool
	agentAutoApply     bool
	agentHumanReadable bool
	agentVerbose       bool
	agentJSON          bool
	agentFullMode      bool
	agentLocalMode     bool
)

func init() {
	RootCmd.AddCommand(agentCmd)

	agentCmd.Flags().StringVarP(&agentOutputFile, "output", "o", "", "Output file for JSON responses")
	agentCmd.Flags().StringVarP(&agentPromptFile, "file", "f", "", "File containing the prompt")
	agentCmd.Flags().BoolVar(&agentNoPlan, "no-plan", false, "Work without local plan context")
	agentCmd.Flags().BoolVar(&agentAutoExec, "auto-exec", true, "Automatically execute commands")
	agentCmd.Flags().BoolVar(&agentAutoApply, "auto-apply", true, "Automatically apply changes")
	agentCmd.Flags().BoolVar(&agentHumanReadable, "human-readable", true, "Display human-readable progress (default)")
	agentCmd.Flags().BoolVar(&agentVerbose, "verbose", false, "Enable verbose human-readable output")
	agentCmd.Flags().BoolVar(&agentJSON, "json", false, "Output JSON instead of human-readable format")
	agentCmd.Flags().BoolVar(&agentFullMode, "full-mode", false, "Force full mode (requires server and database)")
	agentCmd.Flags().BoolVar(&agentLocalMode, "local-mode", false, "Force local mode (standalone, no server required)")
}

func runAgent(cmd *cobra.Command, args []string) {
	prompt := getAgentPrompt(args)

	if prompt == "" {
		fmt.Println("🤷‍♂️ No prompt to send")
		return
	}

	// Initialize agent job
	jobID := agent_exec.GenerateAgentJobID()

	// Set up agent configuration
	config := agent_exec.AgentMode{
		JobID:             jobID,
		OutputFile:        agentOutputFile,
		NoPlan:            agentNoPlan,
		AutoExec:          agentAutoExec,
		AutoApply:         agentAutoApply,
		AutoContext:       true,
		SmartContext:      true,
		SkipConfirmations: true,
		HumanReadable:     agentHumanReadable,
		Verbose:           agentVerbose,
		JSON:              agentJSON,
		FullMode:          agentFullMode,
		LocalMode:         agentLocalMode,
	}

	// Run agent mode
	err := agent_exec.RunAgentMode(config, prompt)
	if err != nil {
		agent_exec.SendAgentError(config, fmt.Sprintf("Agent execution failed: %v", err))
	}
}

// getAgentPrompt retrieves the prompt from command line args, file, or stdin
func getAgentPrompt(args []string) string {
	var prompt string
	var pipedData string

	// Get prompt from command line argument
	if len(args) > 0 {
		prompt = args[0]
	} else if agentPromptFile != "" {
		// Get prompt from file
		bytes, err := os.ReadFile(agentPromptFile)
		if err != nil {
			fmt.Printf("Error reading prompt file: %v\n", err)
			return ""
		}
		prompt = string(bytes)
	}

	// Check if there's piped input
	fileInfo, err := os.Stdin.Stat()
	if err != nil {
		fmt.Printf("Failed to stat stdin: %v\n", err)
		return prompt
	}

	if fileInfo.Mode()&os.ModeNamedPipe != 0 {
		reader := bufio.NewReader(os.Stdin)
		pipedDataBytes, err := io.ReadAll(reader)
		if err != nil {
			fmt.Printf("Failed to read piped data: %v\n", err)
			return prompt
		}
		pipedData = string(pipedDataBytes)
	}

	// Combine prompt sources if both exist
	if prompt == "" && pipedData == "" {
		return ""
	} else if pipedData != "" {
		if prompt != "" {
			prompt = fmt.Sprintf("%s\n\n---\n\n%s", prompt, pipedData)
		} else {
			prompt = pipedData
		}
	}

	return prompt
}
