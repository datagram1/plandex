//go:build !windows

package lib

import (
	"os"
	"os/exec"
	"os/signal"
	"syscall"
)

func setupSignalHandling(cmd *exec.Cmd) {
	signal.Ignore(syscall.SIGINT)
	defer signal.Reset(syscall.SIGINT)

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)

	go func() {
		sig := <-sigChan
		syscall.Kill(-cmd.Process.Pid, sig.(syscall.Signal))
	}()
}
