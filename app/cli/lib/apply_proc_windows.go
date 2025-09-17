//go:build windows

package lib

import (
	"os/exec"
	"syscall"
)

func SetPlatformSpecificAttrs(cmd *exec.Cmd) {
	cmd.SysProcAttr = &syscall.SysProcAttr{
		CreationFlags: syscall.CREATE_NEW_PROCESS_GROUP,
	}
}

func KillProcessGroup(cmd *exec.Cmd, signal syscall.Signal) error {
	// On Windows, we can't easily kill process groups like on Unix
	// Just kill the main process
	return cmd.Process.Kill()
}
