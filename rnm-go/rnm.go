package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	git "github.com/go-git/go-git/v5"
)

func displayUsage() {
	fmt.Println("Usage: rnm [options] <file> <new-filename>")
	fmt.Println("\nOPTIONS:")
	flag.PrintDefaults()
}

func main() {
	// `flag.Bool` returns a pointer
	help := flag.Bool("help", false, "Display this help message")
	force := flag.Bool(
		"force",
		false,
		"Force overwrite if new filename already exists",
	)

	flag.Parse()

	if *help {
		displayUsage()
		return
	}

	files := flag.Args()

	if len(files) != 2 {
		fmt.Println("Please provide a file to rename and its new name.")
		fmt.Println()
		displayUsage()
		os.Exit(1)
	}

	oldFilename, err := filepath.Abs(files[0])
	dirname := filepath.Dir(oldFilename)
	newFilename, err := filepath.Abs(filepath.Join(dirname, files[1]))

	// Check if original file exists
	os.Stat(oldFilename)

	// Check if the destination file already exists
	_, err = os.Stat(newFilename)
	if err == nil && !*force {
		// File exists, ask for permission to overwrite (good boy)
		fmt.Printf("File '%s' already exists. Overwrite? (y/n): ", newFilename)
		var response string
		fmt.Scanln(&response)
		if strings.ToLower(response) != "y" {
			fmt.Println("Operation aborted.")
			os.Exit(1)
		}
	}

	var gitRepo *git.Repository
	var gitWorktree *git.Worktree
	var gitStatus git.Status
	var gitFileStatus *git.FileStatus
	var oldFilenameRelGit string
	var newFilenameRelGit string
	var isGitTracked bool

	isGitTracked = false
	// Check if file is tracked by Git
	gitRepo, err = git.PlainOpenWithOptions(
		dirname,
		&git.PlainOpenOptions{DetectDotGit: true}, // Look in parent directories for `.git`
	)
	if err == nil {
		gitWorktree, err = gitRepo.Worktree()
		if err == nil {
			gitStatus, err = gitWorktree.Status()
			if err == nil {
				oldFilenameRelGit, err = filepath.Rel(gitWorktree.Filesystem.Root(), oldFilename)
				if err != nil {
					fmt.Printf("Error: Unable to determine relative path of old file: %v\n", err)
					os.Exit(1)
				}
				gitFileStatus = gitStatus[oldFilenameRelGit]
				if gitFileStatus.Worktree != git.Untracked {
					isGitTracked = true
				}
			}
		}
	}

	// Perform the renaming operation
	if isGitTracked {
		tmpPath, err := filepath.Rel(gitWorktree.Filesystem.Root(), dirname)
		if err != nil {
			fmt.Printf("Error: Unable to determine relative path of target: %v\n", err)
			os.Exit(1)
		}
		newFilenameRelGit = filepath.Join(tmpPath, filepath.Base(newFilename))

		_, err = gitWorktree.Move(oldFilenameRelGit, newFilenameRelGit)
		if err != nil {
			fmt.Printf("Error: Unable to move file using Git: %v\n", err)
			os.Exit(1)
		}
	} else {
		os.Rename(oldFilename, newFilename)
	}

	fmt.Printf("'%s' -> '%s'", oldFilename, newFilename)
}
