package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
)

type FileEntry struct {
	Number   string
	Status   string
	Filename string
}

type Cache struct {
	CWD          string
	StatusFormat string
	Entries      []FileEntry
}

func getGitDir() (string, error) {
	out, err := exec.Command("git", "rev-parse", "--git-dir").Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(out)), nil
}

func readCache() (*Cache, error) {
	gitDir, err := getGitDir()
	if err != nil {
		return nil, err
	}

	cachePath := filepath.Join(gitDir, gitIDFile)
	file, err := os.Open(cachePath)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, fmt.Errorf("Please run git-number first")
		}
		return nil, err
	}
	defer file.Close()

	cache := &Cache{}
	scanner := bufio.NewScanner(file)

	// Read headers
	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			break
		}
		parts := strings.SplitN(line, ": ", 2)
		if len(parts) == 2 {
			switch parts[0] {
			case "cwd":
				cache.CWD = parts[1]
			case "status-format":
				cache.StatusFormat = parts[1]
			}
		}
	}

	currentCWD, _ := os.Getwd()
	needFixDir := cache.CWD != currentCWD

	// Read entries
	for scanner.Scan() {
		line := scanner.Text()
		var entry FileEntry
		if cache.StatusFormat == "" {
			matches := reNormal.FindStringSubmatch(line)
			if matches != nil {
				entry.Number = matches[1]
				entry.Status = matches[2]
				entry.Filename = matches[3]
			} else {
				continue
			}
		} else if cache.StatusFormat == "--short" {
			matches := reShort.FindStringSubmatch(line)
			if matches != nil {
				entry.Number = matches[1]
				entry.Status = matches[2]
				entry.Filename = matches[3]
			} else {
				continue
			}
		}

		if entry.Filename != "" {
			// Submodule check (like git-list.pl)
			if strings.Contains(entry.Filename, " (") {
				idx := strings.LastIndex(entry.Filename, " (")
				dir := entry.Filename[:idx]
				// Check if dir exists and is a directory
				if info, err := os.Stat(dir); err == nil && info.IsDir() {
					// Check if it's a git repo (has .git)
					if _, err := os.Stat(filepath.Join(dir, ".git")); err == nil {
						entry.Filename = dir
					}
				}
			}

			if needFixDir {
				absPath := filepath.Join(cache.CWD, entry.Filename)
				relPath, err := filepath.Rel(currentCWD, absPath)
				if err == nil {
					entry.Filename = relPath
				}
			}
			cache.Entries = append(cache.Entries, entry)
		}
	}

	return cache, scanner.Err()
}

func explodeArgs(args []string) []string {
	var wanted []string

	for _, arg := range args {
		if matches := reRange.FindStringSubmatch(arg); matches != nil {
			a, _ := strconv.Atoi(matches[1])
			b, _ := strconv.Atoi(matches[2])
			if a > b {
				a, b = b, a
			}
			for i := a; i <= b; i++ {
				wanted = append(wanted, strconv.Itoa(i))
			}
		} else {
			wanted = append(wanted, arg)
		}
	}
	return wanted
}

func escapeFilename(filename string, forDisplay bool) string {
	if !forDisplay {
		return filename
	}
	if strings.ContainsAny(filename, "`$\"") {
		filename = reNeedEscape.ReplaceAllString(filename, "\\$1")
	}
	if strings.ContainsAny(filename, " '[]()&") {
		filename = "\"" + filename + "\""
	}
	return filename
}

func runList(args []string) {
	if len(args) > 0 && (args[0] == "-h" || args[0] == "--help") {
		fmt.Print(`NAME
    git-list

SYNOPSIS
    git-list [-h] [number pattern]

DESCRIPTION
    git-list lists the corresponding filenames given their numbers that was
    previously assigned by git-id. It lists one filename per line of output. Any
    other argument or numbers that has no filenames associated with it will be
    printed as is.

    [number pattern] can either be a single number or a range:

        git-list 1 5-6

OPTIONS
    -h           Show this help message.

SEE ALSO
    git number -h, git number id -h
`)
		return
	}
	cache, err := readCache()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	wantedIDs := explodeArgs(args)
	if len(wantedIDs) == 0 {
		for _, entry := range cache.Entries {
			fmt.Println(entry.Filename)
		}
		return
	}

	fileFor := make(map[string]string)
	for _, entry := range cache.Entries {
		fileFor[entry.Number] = escapeFilename(entry.Filename, true)
	}

	for _, id := range wantedIDs {
		if filename, ok := fileFor[id]; ok {
			fmt.Println(filename)
		} else {
			fmt.Println(id)
		}
	}
}
func showHelp() {
	fmt.Print(`NAME
    git-number

SYNOPSIS
    git-number [-h|--color=<when>|-s] [<git-cmd|-c <cmd>> [git-or-cmd-options] [files or numbers]] [[--|---] ...]

DESCRIPTION
    When run without arguments, runs git-status and assign numeric ids to
    filenames shown by git-status.

    When run with arguments, runs <git-cmd> or <cmd>, and replaces any number in
    the arguments with the corresponding filename from the previous run of
    git-number.

    Any arguments given after '--' are passed to the underlying command verbatim,
    including the '--'. Numbers following '--' are left intact. To replace numbers
    with their equivalent filenames after '--', use triple-dash '---' inplace of
    '--'. For example:

        $ git number log -- 1   # runs git log -- 1
        $ git number log --- 1  # runs git log -- <filename associated with 1>

    To use 'git id' and 'git list' as shortcuts, run 'git number --set-git-alias'.

SUBCOMMANDS
    id           Runs git-status and prepends numeric ids to filenames.
                 (This is what runs when git-number is called without arguments)
    list         Lists filenames associated with the given IDs.

OPTIONS
    -c <cmd>     Runs <cmd> instead of git on the given arguments.
                 All arguments that follows <cmd> will be passed on to <cmd>.

    -v           Show version information.

    -h           Show this help message.

    -s           Show short status.

    --column     Show untracked files in columns.

    -u(no|normal|all)
    --color=(always|auto|never)
                 These options are similar to git-status'.

    --set-git-alias
                 Set git aliases "id" and "list" to "number id" and "number list".

SEE ALSO
    git number id -h, git number list -h
`)
}

func setGitAlias() {
	commands := [][]string{
		{"config", "--global", "alias.id", "number id"},
		{"config", "--global", "alias.list", "number list"},
	}

	for _, cmdArgs := range commands {
		fmt.Printf("Running: git %s\n", strings.Join(cmdArgs, " "))
		cmd := exec.Command("git", cmdArgs...)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			fmt.Fprintf(os.Stderr, "Error setting alias: %v\n", err)
			os.Exit(1)
		}
	}
	fmt.Println("Git aliases 'id' and 'list' have been set.")
}

// colors
var (
	colorRed   = "\033[31m"
	colorReset = "\033[0m"
)

// regexes
var (
	reIDAndFilename = regexp.MustCompile(`\s*{(\d+)}\s+`)

	reBracedID  = regexp.MustCompile(`{([0-9]+)}`)
	reFileEntry = regexp.MustCompile(`([\t ])(\S)`)

	// Handle optional ANSI escapes before the tab
	reANSI = `(?:\x1b\[[0-9;]*m)*`
	reHashTab   = regexp.MustCompile(`^(` + reANSI + `)#\t`)
	reTab       = regexp.MustCompile(`^(` + reANSI + `)\t`)

	reNumber = regexp.MustCompile(`^[0-9]+$`)
	reRange = regexp.MustCompile(`^([1-9]+)-([0-9]+)$`)

	reNormal = regexp.MustCompile(`^#?([0-9]+)\t([^:]+:\s+)?(.*)`)
	reShort = regexp.MustCompile(`^([0-9]+)\s+([^ ]+)\s+(.*)`)

	reNeedEscape = regexp.MustCompile("([`$\"])")
)

func main() {
	if len(os.Args) < 1 {
		os.Exit(0)
	}

	args := os.Args[1:]

	if len(args) > 0 {
		switch args[0] {
		case "id":
			runID(args[1:])
			return
		case "list":
			runList(args[1:])
			return
		case "-h", "--help":
			showHelp()
			return
		case "-v", "--version":
			fmt.Println("git-number version 1.0.1 (golang)")
			return
		case "--set-git-alias":
			setGitAlias()
			return
		}
	}

	// Default git-number behavior
	runNumber(args)
}

var (
	gitIDFile = "gitids.go.txt"
)

func runID(args []string) {
	if len(args) > 0 && (args[0] == "-h" || args[0] == "--help") {
		fmt.Print(`NAME
    git-id

SYNOPSIS
    git-id

DESCRIPTION
    Runs git-status and prepends numeric ids to filenames.

OPTIONS
    -h           Show this help message.

    -s           Show short status.

    --column     Show untracked files in columns.

    -u(no|normal|all)
    --color=(always|auto|never)
                 These options are similar to git-status'.

SEE ALSO
    git number -h, git number list -h
`)
		return
	}
	color := "always"
	statusStyle := "default"
	statusOpt := ""
	untrackedInColumns := false

	var passthru []string
	for i := 0; i < len(args); i++ {
		arg := args[i]
		if arg == "" {
			continue
		}
		if arg == "--" {
			passthru = args[i+1:]
			break
		}
		if strings.HasPrefix(arg, "--color=") {
			color = strings.TrimPrefix(arg, "--color=")
			if color == "never" {
				colorRed = ""
				colorReset = ""
			}
		} else if arg == "--short" || arg == "-s" {
			statusStyle = "--short"
		} else if strings.HasPrefix(arg, "-u") {
			statusOpt += " " + arg
		} else if strings.HasPrefix(arg, "--column") {
			if arg == "--column=never" {
				untrackedInColumns = false
			} else {
				// Simplified: if it's not never, we assume it might be columns if stdout is a terminal
				untrackedInColumns = true // Should ideally check isatty
			}
			statusOpt += " " + arg
		} else {
			passthru = append(passthru, arg)
		}
	}

	gitCmdArgs := []string{"-c", "color.status=" + color, "status"}
	if statusOpt != "" {
		gitCmdArgs = append(gitCmdArgs, strings.Fields(statusOpt)...)
	}
	if statusStyle == "--short" {
		gitCmdArgs = append(gitCmdArgs, "--short")
	}
	gitCmdArgs = append(gitCmdArgs, passthru...)

	cmd := exec.Command("git", gitCmdArgs...)
	cmd.Stderr = os.Stderr
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	if err := cmd.Start(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	var gitDir string
	gitDir, err = getGitDir()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	cachePath := filepath.Join(gitDir, gitIDFile)
	var cacheFile *os.File
	cacheFile, err = os.Create(cachePath)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	defer cacheFile.Close()

	currentCWD, _ := os.Getwd()
	fmt.Fprintf(cacheFile, "cwd: %s\n", currentCWD)
	fmt.Fprintf(cacheFile, "status-format: %s\n\n", strings.Replace(statusStyle, "default", "", 1))

	var lines []string
	scanner := bufio.NewScanner(stdout)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	cmd.Wait()

	id := 1
	seenUntracked := false
	var untrackedLines []string
	var otherLines []string

	for i := 0; i < len(lines); i++ {
		line := lines[i]
		if strings.Contains(line, "Untracked files:") {
			seenUntracked = true
		}

		if statusStyle == "default" {
			// git-id.pl:
			// if ($seen_untracked && $line =~ /\t/ && $untracked_in_columns) {
			//     push @untracked, $line;
			//     last;
			// }
			if seenUntracked && untrackedInColumns && strings.Contains(line, "\t") {
				// Buffer all CONSECUTIVE lines that have tabs
				j := i
				for ; j < len(lines); j++ {
					if strings.Contains(lines[j], "\t") {
						untrackedLines = append(untrackedLines, lines[j])
					} else {
						break
					}
				}
				// All remaining lines go to otherLines
				otherLines = lines[j:]

				// Process buffered untracked lines
				rows := len(untrackedLines)
				maxID := id
				for r, uLine := range untrackedLines {
					out, lastIDInLine := processColumnarLine(uLine, id, r, rows, cacheFile)
					fmt.Println(out)
					if lastIDInLine >= maxID {
						maxID = lastIDInLine + 1
					}
				}
				id = maxID

				// Process remaining other lines
				for _, oLine := range otherLines {
					fmt.Println(oLine)
					cacheLine(oLine, cacheFile)
				}
				return
			}
		}

		fmt.Println(processAndCacheLine(line, &id, statusStyle, false, 0, cacheFile))
	}

	// Final check if untracked lines were at the very end
	if len(untrackedLines) > 0 {
		rows := len(untrackedLines)
		for r, uLine := range untrackedLines {
			out, _ := processColumnarLine(uLine, id, r, rows, cacheFile)
			fmt.Println(out)
		}
	}
}

func cacheLine(line string, cacheFile *os.File) {
	tocache := line

	// 1. remove ANSI colors
	tocache = decolorize(tocache)

	// 2. replace {id}[\t ]{1,2} with \n$1\t globally
	//
	//    {1}	file.txt {2} foo.txt
	//
	//    1<tab>file.txt
	//    2<tab>foo.txt
	//
	// 3. Remove temporary braces {id} becomes id
	tocache = reIDAndFilename.ReplaceAllString(tocache, "\n$1\t")

	fmt.Fprintln(cacheFile, tocache)
}

func decolorize(s string) string {
	var b strings.Builder
	b.Grow(len(s))

	const esc = '\x1b'

	for i := 0; i < len(s); {
		// Look for ESC [
		if s[i] == esc && i+1 < len(s) && s[i+1] == '[' {
			j := i + 2

			// Consume parameter bytes: digits + ';'
			for j < len(s) && ((s[j] >= '0' && s[j] <= '9') || s[j] == ';') {
				j++
			}

			// If this is an SGR sequence (ends with 'm'), skip it
			if j < len(s) && s[j] == 'm' {
				i = j + 1
				continue
			}

			// Not an SGR sequence → treat as normal text
			// fall through and copy one byte
		}

		b.WriteByte(s[i])
		i++
	}

	return b.String()
}

func processAndCacheLine(line string, id *int, statusStyle string, isColumnar bool, rowOffset int, cacheFile *os.File) string {
	processedLine := line
	if statusStyle == "default" {
		// git-id.pl:
		// if ($line =~ /#\t/) { $line =~ s/#\t/#$c\t/; $c += 1; }
		// elsif ($line =~ /\t/) { $line =~ s/\t/$c\t/; $c += 1; }


		if matches := reHashTab.FindStringSubmatch(line); matches != nil {
			ansiPrefix := matches[1]
			processedLine = reHashTab.ReplaceAllString(line, fmt.Sprintf("%s#{%d}\t", ansiPrefix, *id))
			*id++
		} else if matches := reTab.FindStringSubmatch(line); matches != nil {
			ansiPrefix := matches[1]
			processedLine = reTab.ReplaceAllString(line, fmt.Sprintf("%s{%d}\t", ansiPrefix, *id))
			*id++
		}
	} else if statusStyle == "--short" {
		if !strings.HasPrefix(line, "#") && line != "" {
			processedLine = fmt.Sprintf("{%d} %s", *id, line)
			*id++
		}
	}

	cacheLine(processedLine, cacheFile)
	processedLine = reBracedID.ReplaceAllString(processedLine, "$1")
	return processedLine
}

func processColumnarLine(line string, startID int, row int, totalRows int, cacheFile *os.File) (string, int) {
	currentID := startID + row
	lastID := currentID

	processedLine := reFileEntry.ReplaceAllStringFunc(line, func(match string) string {
		sub := reFileEntry.FindStringSubmatch(match)
		space := sub[1]
		firstChar := sub[2]

		numStr := fmt.Sprintf("{%d}", currentID)
		if currentID < 10 && space == " " {
			numStr = fmt.Sprintf("{%d} ", currentID)
		}
		res := fmt.Sprintf("%s%s%s%s%s",
			colorReset, numStr, colorRed,
			space, firstChar) // TODO color reset and red

		lastID = currentID
		currentID += totalRows
		return res
	})

	// Remove leading spaces if any
	processedLine = strings.TrimLeft(processedLine, " ")

	cacheLine(processedLine, cacheFile)

	processedLine = reBracedID.ReplaceAllString(processedLine, "$1")

	return processedLine, lastID
}

func resolveIDs(ids []string, fileFor map[string]string) []string {
	var resolved []string
	for _, id := range ids {
		if filename, ok := fileFor[id]; ok {
			resolved = append(resolved, filename)
		} else {
			resolved = append(resolved, id)
		}
	}
	return resolved
}

func isTerminal() bool {
	fi, err := os.Stdout.Stat()
	if err != nil {
		return false
	}
	return (fi.Mode() & os.ModeCharDevice) != 0
}

func runNumber(args []string) {
	run := "git"
	color := "always"
	var statusOpts []string

	if len(args) == 0 {
		runID(nil)
		return
	}

	i := 0
	for ; i < len(args); i++ {
		arg := args[i]
		if !strings.HasPrefix(arg, "-") {
			break
		}
		if arg == "-h" {
			// Show usage
			fmt.Println("Usage: git number [options] [git-cmd] [args]")
			return
		}
		if arg == "-v" {
			fmt.Println("git-number version 1.0.1 (golang)")
			return
		}
		if arg == "-c" {
			if i+1 < len(args) {
				run = args[i+1]
				i++
				i++ // Move to next arg after -c <cmd>
				break
			} else {
				fmt.Fprintf(os.Stderr, "-c requires command\n")
				os.Exit(1)
			}
		}
		if strings.HasPrefix(arg, "--color=") {
			color = strings.TrimPrefix(arg, "--color=")
		} else if arg == "-s" {
			statusOpts = append(statusOpts, "--short")
		} else if strings.HasPrefix(arg, "-u") {
			statusOpts = append(statusOpts, arg)
		} else if strings.HasPrefix(arg, "--column") {
			statusOpts = append(statusOpts, arg)
		} else if arg == "--" {
			break
		}
	}

	remainingArgs := args[i:]
	if run == "git" && (len(remainingArgs) == 0 || remainingArgs[0] == "--") {
		idArgs := []string{"--color=" + color}
		idArgs = append(idArgs, statusOpts...)
		idArgs = append(idArgs, remainingArgs...)
		runID(idArgs)
		return
	}

	if run == "git" {
		// Check if the first remaining arg is a known git command
		// If not, we might want to run ID with these as pathspecs
		// but git-number.pl does this:
		// if ($run eq 'git' && scalar @ARGV == 0) { ... exit run_cmd(git-id ...) }
		// Wait, my i loop already consumed options.
	}

	cache, _ := readCache()
	fileFor := make(map[string]string)
	if cache != nil {
		for _, entry := range cache.Entries {
			fileFor[entry.Number] = entry.Filename
		}
	}

	var finalArgs []string
	var displayArgs []string
	converted := false

	for j := 0; j < len(remainingArgs); j++ {
		arg := remainingArgs[j]
		if arg == "--" {
			finalArgs = append(finalArgs, "--")
			finalArgs = append(finalArgs, remainingArgs[j+1:]...)
			displayArgs = append(displayArgs, "--")
			for _, a := range remainingArgs[j+1:] {
				displayArgs = append(displayArgs, escapeFilename(a, true))
			}
			break
		}
		if arg == "---" {
			finalArgs = append(finalArgs, "--")
			displayArgs = append(displayArgs, "--")
			continue
		}

		// Check if it's a number or range
		isNumber := reNumber.MatchString(arg)
		isRange := reRange.MatchString(arg)

		if isNumber || isRange {
			exploded := explodeArgs([]string{arg})
			resolved := resolveIDs(exploded, fileFor)
			finalArgs = append(finalArgs, resolved...)
			for _, r := range resolved {
				displayArgs = append(displayArgs, escapeFilename(r, true))
			}
			converted = true
		} else {
			finalArgs = append(finalArgs, arg)
			displayArgs = append(displayArgs, escapeFilename(arg, true))
		}
	}

	fullCmdArgs := append([]string{}, finalArgs...)
	cmd := exec.Command(run, fullCmdArgs...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	if converted && isTerminal() {
		fmt.Printf("%s %s\n", run, strings.Join(displayArgs, " "))
	}

	if err := cmd.Run(); err != nil {
		if exitError, ok := err.(*exec.ExitError); ok {
			os.Exit(exitError.ExitCode())
		}
		os.Exit(1)
	}
}
