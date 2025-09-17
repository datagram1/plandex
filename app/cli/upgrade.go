package main

import (
	"archive/tar"
	"compress/gzip"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"log"
	"net/http"
	"net/url"
	"os"
	"os/exec"
	"plandex-cli/term"
	"plandex-cli/version"
	"runtime"
	"strings"
	"time"

	"github.com/Masterminds/semver"
	"github.com/fatih/color"
	"github.com/inconshreveable/go-update"
)

func checkForUpgrade() {
	if os.Getenv("PLANDEX_SKIP_UPGRADE") != "" {
		return
	}

	if version.Version == "development" {
		return
	}

	term.StartSpinner("")
	defer term.StopSpinner()
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	latestVersionURL := "https://api.github.com/repos/datagram1/plandex/releases/latest"
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, latestVersionURL, nil)
	if err != nil {
		log.Println("Error creating request:", err)
		return
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Println("Error checking latest version:", err)
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Println("Error reading response body:", err)
		return
	}

	// Parse GitHub API response to extract tag_name
	var releaseData struct {
		TagName string `json:"tag_name"`
	}
	
	if err := json.Unmarshal(body, &releaseData); err != nil {
		log.Println("Error parsing GitHub API response:", err)
		return
	}

	// Extract version from tag (remove "cli/v" prefix)
	versionStr := strings.TrimPrefix(releaseData.TagName, "cli/v")
	versionStr = strings.TrimSpace(versionStr)

	latestVersion, err := semver.NewVersion(versionStr)
	if err != nil {
		log.Println("Error parsing latest version:", err)
		return
	}

	currentVersion, err := semver.NewVersion(version.Version)
	if err != nil {
		log.Println("Error parsing current version:", err)
		return
	}

	if latestVersion.GreaterThan(currentVersion) {
		term.StopSpinner()
		fmt.Println("A new version of Plandex is available:", color.New(color.Bold, term.ColorHiGreen).Sprint(versionStr))
		fmt.Printf("Current version: %s\n", color.New(color.Bold, term.ColorHiCyan).Sprint(version.Version))
		confirmed, err := term.ConfirmYesNo("Upgrade to the latest version?")
		if err != nil {
			log.Println("Error reading input:", err)
			return
		}

		if confirmed {
			term.ResumeSpinner()
			err := doUpgrade(latestVersion.String())
			if err != nil {
				term.OutputErrorAndExit("Failed to upgrade: %v", err)
				return
			}
			term.StopSpinner()
			restartPlandex()
		} else {
			fmt.Println("Note: set PLANDEX_SKIP_UPGRADE=1 to stop upgrade prompts")
		}
	}
}

func doUpgrade(version string) error {
	tag := fmt.Sprintf("cli/v%s", version)
	escapedTag := url.QueryEscape(tag)

	// Use .zip for Windows, .tar.gz for other platforms
	var fileExt string
	if runtime.GOOS == "windows" {
		fileExt = "zip"
	} else {
		fileExt = "tar.gz"
	}
	
	downloadURL := fmt.Sprintf("https://github.com/datagram1/plandex/releases/download/%s/plandex_%s_%s_%s.%s", escapedTag, version, runtime.GOOS, runtime.GOARCH, fileExt)
	resp, err := http.Get(downloadURL)
	if err != nil {
		return fmt.Errorf("failed to download the update: %w", err)
	}
	defer resp.Body.Close()

	// Create a temporary file to save the downloaded archive
	var tempFilePattern string
	if runtime.GOOS == "windows" {
		tempFilePattern = "*.zip"
	} else {
		tempFilePattern = "*.tar.gz"
	}
	
	tempFile, err := os.CreateTemp("", tempFilePattern)
	if err != nil {
		return fmt.Errorf("failed to create temporary file: %w", err)
	}
	defer os.Remove(tempFile.Name()) // Clean up file afterwards

	// Copy the response body to the temporary file
	_, err = io.Copy(tempFile, resp.Body)
	if err != nil {
		return fmt.Errorf("failed to save the downloaded archive: %w", err)
	}

	_, err = tempFile.Seek(0, 0)
	if err != nil {
		return fmt.Errorf("failed to seek in temporary file: %w", err)
	}

	// Extract the binary based on platform
	if runtime.GOOS == "windows" {
		// Handle ZIP file for Windows
		return extractFromZip(tempFile)
	} else {
		// Handle TAR.GZ file for Unix-like systems
		return extractFromTarGz(tempFile)
	}

	return nil
}

func extractFromTarGz(tempFile *os.File) error {
	// Now, extract the binary from the tempFile
	gzr, err := gzip.NewReader(tempFile)
	if err != nil {
		return fmt.Errorf("failed to create gzip reader: %w", err)
	}
	defer gzr.Close()

	tarReader := tar.NewReader(gzr)
	for {
		header, err := tarReader.Next()
		if err == io.EOF {
			break // End of archive
		}
		if err != nil {
			return fmt.Errorf("failed to read tar header: %w", err)
		}

		// Check if the current file is the binary
		if header.Typeflag == tar.TypeReg && (header.Name == "plandex" || header.Name == "plandex.exe") {
			err = update.Apply(tarReader, update.Options{})
			if err != nil {
				if errors.Is(err, fs.ErrPermission) {
					return fmt.Errorf("failed to apply update due to permission error; please try running your command again with 'sudo': %w", err)
				}
				return fmt.Errorf("failed to apply update: %w", err)
			}
			break
		}
	}
	return nil
}

func extractFromZip(tempFile *os.File) error {
	// For Windows ZIP files, we'll need to use archive/zip
	// This is a simplified version - in practice, you might want to use a ZIP library
	return fmt.Errorf("ZIP extraction not yet implemented for Windows upgrades")
}

func restartPlandex() {
	exe, err := os.Executable()
	if err != nil {
		term.OutputErrorAndExit("Failed to determine executable path: %v", err)
	}

	cmd := exec.Command(exe, os.Args[1:]...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err = cmd.Start()
	if err != nil {
		term.OutputErrorAndExit("Failed to restart: %v", err)
	}

	err = cmd.Wait()

	// If the process exited with an error, exit with the same error code
	if exitErr, ok := err.(*exec.ExitError); ok {
		os.Exit(exitErr.ExitCode())
	} else if err != nil {
		term.OutputErrorAndExit("Failed to restart: %v", err)
	}

	os.Exit(0)
}
