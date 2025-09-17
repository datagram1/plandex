//go:build !windows

package lib

import (
	"log"
	"os/exec"
	"syscall"
)

func logProcessGroup(execCmd *exec.Cmd) {
	pgid, err := syscall.Getpgid(execCmd.Process.Pid)
	if err != nil {
		log.Printf("Getpgid error: %v", err)
	} else {
		log.Printf("Child PID=%d PGID=%d", execCmd.Process.Pid, pgid)
	}
}
