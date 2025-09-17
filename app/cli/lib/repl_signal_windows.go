//go:build windows

package lib

import (
	"os/exec"
)

func setupSignalHandling(cmd *exec.Cmd) {
	// On Windows, signal handling is different
	// We'll just let the process run normally
	// The process will be killed when the parent exits
}
