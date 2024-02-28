package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
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

	oldFilename := files[0]
	newFilename := files[1]

	dirname := filepath.Dir(oldFilename)
	newFilename = filepath.Join(dirname, filepath.Base(newFilename))

	// Check if original file exists
	os.Stat(oldFilename)

	// Check if the destination file already exists
	_, err := os.Stat(newFilename)
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

	// Perform the renaming operation
	os.Rename(oldFilename, newFilename)
	fmt.Printf("'%s' -> '%s'", oldFilename, newFilename)
}
