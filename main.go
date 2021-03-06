package main

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/signal"
	"syscall"
)

var (
	debug bool
)

func init() {
	if os.Getenv("GINIT_DEBUG") != "" {
		debug = true
	}
}

func main() {
	sigs := make(chan os.Signal, 1)
	registerSignals(sigs)

	if len(os.Args) <= 1 {
		printf("Nothing to do.")
		os.Exit(-1)
	}

	cmd := createCommand(os.Args, os.Stdin, os.Stdout, os.Stderr)

	if err := cmd.Start(); err != nil {
		printf("Couldn't start command: %s", err)
		os.Exit(-2)
	}

	go func() {
		sig := <-sigs

		debugf("Sending signal '%s' to our child process", sig)
		if err := cmd.Process.Signal(sig); err != nil {
			printf("Unable to send signal '%s' to our child process: %s", sig, err)
		}
	}()

	debugf("Command started with pid %d.", cmd.Process.Pid)
	debugf("Command finished: %s", cmd.Wait())

	debugf("Exiting ginit")
	os.Exit(0)
}

func registerSignals(sigs chan<- os.Signal) {
	signal.Notify(
		sigs,
		syscall.SIGINT,
		syscall.SIGTERM,
	)
}

func createCommand(argv []string, stdin io.Reader, stdout, stderr io.Writer) *exec.Cmd {
	var cmd *exec.Cmd
	if len(argv) == 2 {
		cmd = exec.Command(argv[1])
	} else {
		cmd = exec.Command(argv[1], argv[2:]...)
	}

	cmd.Stdout = stdout
	cmd.Stderr = stderr
	cmd.Stdin = stdin

	return cmd
}

func debugf(format string, arguments ...interface{}) {
	if debug {
		printf(format, arguments...)
	}
}

func printf(format string, arguments ...interface{}) {
	fmt.Printf(format+"\n", arguments...)
}
