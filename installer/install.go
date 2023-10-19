package main

import (
	"github.com/gdamore/tcell/v2"
	"github.com/rivo/tview"
	"io"
	"net"
	"net/url"
	"os"
	"os/exec"
	"strconv"
	"syscall"
	"time"
)

type task struct {
	name    string
	command string
}

var flexTop = tview.NewFlex()
var listTask *tview.List
var process *os.Process
var processState *os.ProcessState
var abortButton *tview.Button
var backButton *tview.Button
var quitButton *tview.Button
var logContent *tview.TextView
var stopTimer = make(chan bool)

func initFlexInstall() {
	flexInstall.Clear()
	flexTop.Clear()
	flexTop.SetTitle("Install").SetBorder(true)

	tasks, envs := buildTasks()

	listTask = tview.NewList()
	for index, task := range tasks {
		listTask.AddItem(task.name, "pending", rune(49+index), nil)
	}
	// Disable mouse
	listTask.SetMouseCapture(func(action tview.MouseAction, event *tcell.EventMouse) (tview.MouseAction, *tcell.EventMouse) {
		return action, nil
	})

	process = nil
	processState = nil

	logContent = tview.NewTextView()
	logContent.SetBackgroundColor(tcell.ColorDarkBlue)
	logContent.SetMaxLines(0).
		SetWrap(true).
		SetWordWrap(true).
		SetChangedFunc(func() {
			logContent.ScrollToEnd()
			app.Draw()
		})

	flexTop.
		AddItem(listTask, 0, 1, false).
		AddItem(logContent, 0, 3, false)

	formDown := tview.NewForm()
	formDown.AddButton("Abort", func() {
		if process != nil && processState == nil {
			confirmAbort := tview.NewModal().
				SetText("Do you want to abort the execution?").
				AddButtons([]string{"Abort", "Cancel"}).
				SetDoneFunc(func(buttonIndex int, buttonLabel string) {
					if buttonLabel == "Cancel" {
						pages.SwitchToPage("Install")
					}
					if buttonLabel == "Abort" {
						pgid, err := syscall.Getpgid(process.Pid)
						check(err)
						syscall.Kill(-pgid, 15)

						abortButton.SetDisabled(true)
						backButton.SetDisabled(false)
						quitButton.SetDisabled(false)

						pages.SwitchToPage("Install")
					}
				})
			pages.AddPage("Confirm Abort", confirmAbort, true, true)
		}
	})
	abortButton = formDown.GetButton(formDown.GetButtonIndex("Abort"))
	abortButton.SetDisabled(true)

	formDown.AddButton("Back", func() {
		pages.SwitchToPage("Mirror")
	})
	backButton = formDown.GetButton(formDown.GetButtonIndex("Back"))
	backButton.SetDisabled(false)

	formDown.AddButton("Quit", func() {
		showQuitModal()
	})
	quitButton = formDown.GetButton(formDown.GetButtonIndex("Quit"))
	quitButton.SetDisabled(false)

	flexInstall.SetDirection(tview.FlexRow).
		AddItem(flexTop, 0, 1, true).
		AddItem(formDown, 3, 1, false)

	go startTimer(stopTimer)
	go execCmd(tasks, envs, logContent)
}

func buildTasks() (tasks []task, envs []string) {
	envs = append(envs, "CLUSTER_URL="+basicInfo.clusterUrl)
	envs = append(envs, "TEAM="+basicInfo.team)
	envs = append(envs, "TIMEZONE="+basicInfo.timezone)

	u, _ := url.Parse(basicInfo.clusterUrl)
	if net.ParseIP(u.Host) == nil {
		envs = append(envs, "CLUSTER_HOSTNAME="+u.Host)
	} else {
		envs = append(envs, "CLUSTER_HOSTNAME=")
	}

	var finalMirrors map[string]string
	if enableMirror {
		finalMirrors = mirrors
	} else {
		finalMirrors = map[string]string{
			"DOCKER_CONTAINER_MIRROR": "docker.io",
			"QUAY_CONTAINER_MIRROR":   "quay.io",
			"K8S_CONTAINER_MIRROR":    "k8s.io",
			"GCR_CONTAINER_MIRROR":    "k8s-gcr.io",
		}
	}
	for k, v := range finalMirrors {
		envs = append(envs, k+"="+v)
	}

	envs = append(envs, "ENABLE_PROMETHEUS="+strconv.FormatBool(installPrometheus))
	if installPrometheus {
		tasks = append(tasks, task{name: "Install Prometheus",
			command: "chmod +x packages/prometheus/install.sh; packages/prometheus/install.sh"})
		envs = append(envs, "ALTERMANAGER_STORAGE_SIZE="+strconv.Itoa(prometheusConfig.alertmanagerStorageSizeGi)+"Gi")
		envs = append(envs, "GRAFANA_STORAGE_SIZE="+strconv.Itoa(prometheusConfig.grafanaStorageSizeGi)+"Gi")
		envs = append(envs, "PROMETHEUS_STORAGE_SIZE="+strconv.Itoa(prometheusConfig.prometheusStorageSizeGi)+"Gi")
	}

	switch storageClass {
	case storageClassType.ceph:
		tasks = append(tasks, task{name: "Install Ceph",
			command: "chmod +x packages/storage/ceph/install.sh; packages/storage/ceph/install.sh"})
		envs = append(envs, "STORAGE_CLASS=ceph-filesystem")
	case storageClassType.nfs:
		tasks = append(tasks, task{name: "Install nfs",
			command: "chmod +x packages/storage/nfs/install.sh; packages/storage/nfs/install.sh"})
		envs = append(envs, "STORAGE_CLASS=nfs-client")
		envs = append(envs, "NFS_SERVER="+nfsConfig.server)
		envs = append(envs, "NFS_PATH="+nfsConfig.path)
	}

	if installJenkins {
		tasks = append(tasks, task{name: "Install Jenkins",
			command: "chmod +x packages/jenkins/install.sh; packages/jenkins/install.sh"})
		envs = append(envs, "CONTROLLER_STORAGE_SIZE="+strconv.Itoa(jenkinsConfig.controllerStorageSizeGi)+"Gi")
		envs = append(envs, "AGENT_STORAGE_SIZE="+strconv.Itoa(jenkinsConfig.agentStorageSizeGi)+"Gi")
		envs = append(envs, "JENKINS_LIB_VERSION="+jenkinsConfig.pipelineLibVersion)
	}

	if installNexus {
		tasks = append(tasks, task{name: "Install Nexus",
			command: "chmod +x packages/nexus/install.sh; packages/nexus/install.sh"})
		envs = append(envs, "NEXUS_STORAGE_SIZE="+strconv.Itoa(nexusConfig.storageSizeGi)+"Gi")
		envs = append(envs, "DOCKER_NODE_PORT="+nexusConfig.dockerNodePort)
	}

	if installSonar {
		tasks = append(tasks, task{name: "Install Sonarqube",
			command: "chmod +x packages/sonar/install.sh; packages/sonar/install.sh"})
		envs = append(envs, "SONAR_STORAGE_SIZE="+strconv.Itoa(sonarConfig.storageSizeGi)+"Gi")
		envs = append(envs, "SONAR_PG_STORAGE_SIZE="+strconv.Itoa(sonarConfig.dbStorageSizeGi)+"Gi")
	}

	if installFileServer {
		tasks = append(tasks, task{name: "Install File Server",
			command: "chmod +x packages/file-server/install.sh; packages/file-server/install.sh"})
		envs = append(envs, "FILE_STORAGE_SIZE="+strconv.Itoa(fileServerConfig.storageSizeGi)+"Gi")
	}

	if installSmb {
		tasks = append(tasks, task{name: "Install Samba Server",
			command: "chmod +x packages/samba-server/install.sh; packages/samba-server/install.sh"})
		envs = append(envs, "SMB_NODE_PORT="+smbConfig.nodePort)
	}

	return
}

func execCmd(tasks []task, envs []string, view *tview.TextView) {
	var logBgColor tcell.Color

	for index, task := range tasks {
		listTask.SetCurrentItem(index)
		mainText, _ := listTask.GetItemText(index)
		listTask.SetItemText(index, mainText, "installing...")

		processState = nil

		//cmd := exec.Command("/bin/bash", "-c", "echo '"+command+"'")
		//cmd := exec.Command("/bin/bash", "-c", "export")
		cmd := exec.Command("/bin/bash", "-c", task.command)

		cmd.Dir = appPath

		cmd.Env = os.Environ()
		for _, env := range envs {
			cmd.Env = append(cmd.Env, env)
		}

		cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}

		stdout, err := cmd.StdoutPipe()
		check(err)
		stderr, err := cmd.StderrPipe()
		check(err)

		err = cmd.Start()
		check(err)
		process = cmd.Process

		abortButton.SetDisabled(false)
		backButton.SetDisabled(true)
		quitButton.SetDisabled(true)

		_, err = io.Copy(view, stdout)
		check(err)

		errBytes, err := io.ReadAll(stderr)
		check(err)

		err = cmd.Wait()
		processState = cmd.ProcessState
		process = nil

		if err != nil {
			view.SetText(view.GetText(false) + "\n" + string(errBytes))
			listTask.SetItemText(index, mainText, "failed!")
			logBgColor = tcell.ColorDarkRed
			break
		} else {
			listTask.SetItemText(index, mainText, "done")
			logBgColor = tcell.ColorDarkGreen
		}
	}

	stopTimer <- true

	app.QueueUpdateDraw(func() {
		logContent.SetBackgroundColor(logBgColor)
		abortButton.SetDisabled(true)
		backButton.SetDisabled(false)
		quitButton.SetDisabled(false)
	})
}

func startTimer(stop chan bool) {
	startTime := time.Now()
	for {
		select {
		case <-stop:
			return
		default:
			app.QueueUpdateDraw(func() {
				flexTop.SetTitle("Install - Time Elapsed: " + time.Since(startTime).Round(time.Second).String())
			})
			time.Sleep(time.Second)
		}
	}
}
