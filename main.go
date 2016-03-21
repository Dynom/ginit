package main

import (
	"fmt"
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

	cmd := createCommand(os.Args)
	err := cmd.Start()
	if err != nil {
		printf("Couldn't start command: %s", err)
		os.Exit(-2)
	}

	go func() {
		sig := <-sigs

		debugf("Sending signal '%s' to our child process", sig)
		err := cmd.Process.Signal(sig)
		if err != nil {
			printf("Unable to send signal '%s' to our child process: %s", sig, err)
		}

		debugf("Signal sent", cmd.ProcessState.Exited())
	}()

	debugf("Command started with pid %d.", cmd.Process.Pid)
	err = cmd.Wait()
	debugf("Command finished: %s", err)

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

func createCommand(argv []string) *exec.Cmd {
	var cmd *exec.Cmd
	if len(os.Args) == 2 {
		cmd = exec.Command(os.Args[1])
	} else {
		cmd = exec.Command(os.Args[1], os.Args[2:]...)
	}

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
