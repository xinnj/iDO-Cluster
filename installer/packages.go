package main

import (
	"errors"
	"github.com/rivo/tview"
	"strconv"
)

type JenkinsConfig struct {
	controllerStorageSizeGi int
	agentStorageSizeGi      int
	pipelineLibVersion      string
}

func (config *JenkinsConfig) validate() error {
	if config.controllerStorageSizeGi == 0 {
		return errors.New("Jenkins controller storage size is 0.")
	}
	if config.agentStorageSizeGi == 0 {
		return errors.New("Jenkins agent storage size is 0.")
	}
	if config.pipelineLibVersion == "" {
		return errors.New("Jenkins pipeline lib version is emtpy.")
	}
	return nil
}

type NexusConfig struct {
	storageSizeGi  int
	dockerNodePort string
}

func (config *NexusConfig) validate() error {
	if config.storageSizeGi == 0 {
		return errors.New("Nexus storage size is 0.")
	}
	if config.dockerNodePort == "" {
		return errors.New("Nexus docker node port is emtpy.")
	}
	return nil
}

type SonarConfig struct {
	storageSizeGi   int
	dbStorageSizeGi int
}

func (config *SonarConfig) validate() error {
	if config.storageSizeGi == 0 {
		return errors.New("Sonarqube storage size is 0.")
	}
	if config.dbStorageSizeGi == 0 {
		return errors.New("Sonarqube DB storage size is 0.")
	}
	return nil
}

type FileServerConfig struct {
	storageSizeGi int
}

func (config *FileServerConfig) validate() error {
	if config.storageSizeGi == 0 {
		return errors.New("File server storage size is 0.")
	}
	return nil
}

type SmbConfig struct {
	nodePort string
}

func (config *SmbConfig) validate() error {
	if config.nodePort == "" {
		return errors.New("Smb node port is empty.")
	}
	return nil
}

type PrometheusConfig struct {
	alertmanagerStorageSizeGi int
	grafanaStorageSizeGi      int
	prometheusStorageSizeGi   int
}

func (config *PrometheusConfig) validate() error {
	if config.alertmanagerStorageSizeGi == 0 {
		return errors.New("Alert manager storage size is 0.")
	}
	if config.grafanaStorageSizeGi == 0 {
		return errors.New("Grafana storage size is 0.")
	}
	if config.prometheusStorageSizeGi == 0 {
		return errors.New(" Prometheus storage size is 0.")
	}
	return nil
}

var installJenkins = false
var installNexus = false
var installSonar = false
var installFileServer = false
var installSmb = false
var installPrometheus = false
var jenkinsConfig = JenkinsConfig{
	controllerStorageSizeGi: 20,
	agentStorageSizeGi:      200,
	pipelineLibVersion:      "latest",
}
var nexusConfig = NexusConfig{
	storageSizeGi:  200,
	dockerNodePort: "30000",
}
var sonarConfig = SonarConfig{
	storageSizeGi:   5,
	dbStorageSizeGi: 20,
}
var fileServerConfig = FileServerConfig{
	storageSizeGi: 200,
}
var smbConfig = SmbConfig{
	nodePort: "30445",
}
var prometheusConfig = PrometheusConfig{
	alertmanagerStorageSizeGi: 10,
	grafanaStorageSizeGi:      5,
	prometheusStorageSizeGi:   10,
}

func initFlexPackages() {
	flexPackages.Clear()
	formPackages := tview.NewForm()
	formPackages.SetTitle("Packages").SetBorder(true)

	// Jenkins
	formPackages.AddCheckbox("Install Jenkins: ", installJenkins, func(checked bool) {
		installJenkins = checked
		flexPackages.Clear()
		initFlexPackages()
	})
	if installJenkins {
		formPackages.AddInputField("Jenkins controller storage size (Gi): ", strconv.Itoa(jenkinsConfig.controllerStorageSizeGi),
			0, nil, func(text string) {
				jenkinsConfig.controllerStorageSizeGi, _ = strconv.Atoi(text)
			})
		formPackages.AddInputField("Jenkins agent storage size (Gi): ", strconv.Itoa(jenkinsConfig.agentStorageSizeGi),
			0, nil, func(text string) {
				jenkinsConfig.agentStorageSizeGi, _ = strconv.Atoi(text)
			})
		formPackages.AddInputField("Jenkins pipeline lib version: ", jenkinsConfig.pipelineLibVersion,
			0, nil, func(text string) {
				jenkinsConfig.pipelineLibVersion = text
			})
	}

	// Nexus
	formPackages.AddCheckbox("Install Nexus: ", installNexus, func(checked bool) {
		installNexus = checked
		flexPackages.Clear()
		initFlexPackages()
	})
	if installNexus {
		formPackages.AddInputField("Nexus storage size (Gi): ", strconv.Itoa(nexusConfig.storageSizeGi),
			0, nil, func(text string) {
				nexusConfig.storageSizeGi, _ = strconv.Atoi(text)
			})
		formPackages.AddInputField("Nexus docker node port: ", nexusConfig.dockerNodePort,
			0, nil, func(text string) {
				nexusConfig.dockerNodePort = text
			})
	}

	// Sonar
	formPackages.AddCheckbox("Install Sonarqube: ", installSonar, func(checked bool) {
		installSonar = checked
		flexPackages.Clear()
		initFlexPackages()
	})
	if installSonar {
		formPackages.AddInputField("Sonarqube storage size (Gi): ", strconv.Itoa(sonarConfig.storageSizeGi),
			0, nil, func(text string) {
				sonarConfig.storageSizeGi, _ = strconv.Atoi(text)
			})
		formPackages.AddInputField("Sonarqube DB storage size (Gi): ", strconv.Itoa(sonarConfig.dbStorageSizeGi),
			0, nil, func(text string) {
				sonarConfig.dbStorageSizeGi, _ = strconv.Atoi(text)
			})
	}

	// File server
	formPackages.AddCheckbox("Install file server: ", installFileServer, func(checked bool) {
		installFileServer = checked
		flexPackages.Clear()
		initFlexPackages()
	})
	if installFileServer {
		formPackages.AddInputField("File server storage size (Gi): ", strconv.Itoa(fileServerConfig.storageSizeGi),
			0, nil, func(text string) {
				fileServerConfig.storageSizeGi, _ = strconv.Atoi(text)
			})
	}

	// Smb
	formPackages.AddCheckbox("Install Samba server: ", installSmb, func(checked bool) {
		installSmb = checked
		flexPackages.Clear()
		initFlexPackages()
	})
	if installSmb {
		formPackages.AddInputField("Smb node port: ", smbConfig.nodePort,
			0, nil, func(text string) {
				smbConfig.nodePort = text
			})
	}

	// Prometheus
	formPackages.AddCheckbox("Install Prometheus: ", installPrometheus, func(checked bool) {
		installPrometheus = checked
		flexPackages.Clear()
		initFlexPackages()
	})
	if installPrometheus {
		formPackages.AddInputField("Alert manager storage size (Gi): ", strconv.Itoa(prometheusConfig.alertmanagerStorageSizeGi),
			0, nil, func(text string) {
				prometheusConfig.alertmanagerStorageSizeGi, _ = strconv.Atoi(text)
			})
		formPackages.AddInputField("Grafana storage size (Gi): ", strconv.Itoa(prometheusConfig.grafanaStorageSizeGi),
			0, nil, func(text string) {
				prometheusConfig.grafanaStorageSizeGi, _ = strconv.Atoi(text)
			})
		formPackages.AddInputField("Prometheus storage size (Gi): ", strconv.Itoa(prometheusConfig.prometheusStorageSizeGi),
			0, nil, func(text string) {
				prometheusConfig.prometheusStorageSizeGi, _ = strconv.Atoi(text)
			})
	}

	formDown := tview.NewForm()

	formDown.AddButton("Next", func() {
		if installJenkins {
			err := jenkinsConfig.validate()
			if err != nil {
				showErrorModal(err.Error())
			}
		}

		if installNexus {
			err := nexusConfig.validate()
			if err != nil {
				showErrorModal(err.Error())
			}
		}

		if installSonar {
			err := sonarConfig.validate()
			if err != nil {
				showErrorModal(err.Error())
			}
		}

		if installFileServer {
			err := fileServerConfig.validate()
			if err != nil {
				showErrorModal(err.Error())
			}
		}

		if installSmb {
			err := smbConfig.validate()
			if err != nil {
				showErrorModal(err.Error())
			}
		}

		if installPrometheus {
			err := prometheusConfig.validate()
			if err != nil {
				showErrorModal(err.Error())
			}
		}

		initFlexMirror()
		pages.SwitchToPage("Mirror")
	})

	formDown.AddButton("Back", func() {
		pages.SwitchToPage("Storage")
	})

	formDown.AddButton("Quit", func() {
		showQuitModal()
	})

	flexPackages.SetDirection(tview.FlexRow).
		AddItem(formPackages, 0, 1, true).
		AddItem(formDown, 3, 1, false)
}
