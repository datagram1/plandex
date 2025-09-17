//go:build windows

package lib

import (
	"log"
	"os/exec"
)

func logProcessGroup(execCmd *exec.Cmd) {
	// On Windows, process groups work differently
	log.Printf("Child PID=%d", execCmd.Process.Pid)
}
