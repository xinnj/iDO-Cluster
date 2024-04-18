package main

import (
	"github.com/rivo/tview"
	"golang.org/x/exp/slices"
	"strconv"
	"strings"
)

var enableBackup = false

var providers = []string{
	"minio",
	"aws",
	"alibabacloud",
}

type BackupInfo struct {
	backupGitea             bool
	backupJenkinsController bool
	backupKeycloak          bool
	backupNexus             bool
	backupFileServer        bool
	backupSonarqube         bool
	backupZentao            bool
	provider                string
	bucket                  string
	locationConfig          string
	cloudSecret             string
	schedule                string
	ttl                     int
	region                  string
}

var backupInfo = BackupInfo{}
var providerSelected = "minio"

// Minio: region, s3ForcePathStyle, s3Url
// S3: region
// OSS: region
var locationConfig map[string]string

// S3 and compatible: aws_access_key_id, aws_secret_access_key
// OSS: ALIBABA_CLOUD_ACCESS_KEY_ID, ALIBABA_CLOUD_ACCESS_KEY_SECRET
var cloudSecretConfig map[string]string

func initFlexBackup() {
	flexBackup.Clear()
	flexBackupTop := tview.NewFlex()
	flexBackupTop.SetTitle("Backup").SetBorder(true)
	flexBackupMiddle := tview.NewFlex()
	flexBackupMiddle.SetBorder(false)
	formBackupLeft := tview.NewForm()
	formBackupLeft.SetBorder(false)
	formBackupRight := tview.NewForm()
	formBackupRight.SetBorder(false)

	checkboxBackup := tview.NewCheckbox().
		SetLabel("Enable backup: ").
		SetChecked(enableBackup).
		SetChangedFunc(func(checked bool) {
			enableBackup = checked
			flexBackup.Clear()
			initFlexBackup()
		})

	if enableBackup {
		formBackupLeft.SetBorder(true).SetTitle("Backup Items")
		formBackupRight.SetBorder(true).SetTitle("Backup Config")

		// left form
		formBackupLeft.AddCheckbox("Backup Gitea: ", backupInfo.backupGitea, func(checked bool) {
			backupInfo.backupGitea = checked
		})
		formBackupLeft.AddCheckbox("Backup Jenkins Controller: ", backupInfo.backupJenkinsController, func(checked bool) {
			backupInfo.backupJenkinsController = checked
		})
		formBackupLeft.AddCheckbox("Backup Zentao: ", backupInfo.backupZentao, func(checked bool) {
			backupInfo.backupZentao = checked
		})
		formBackupLeft.AddCheckbox("Backup Keycloak: ", backupInfo.backupKeycloak, func(checked bool) {
			backupInfo.backupKeycloak = checked
		})
		formBackupLeft.AddCheckbox("Backup Nexus: ", backupInfo.backupNexus, func(checked bool) {
			backupInfo.backupNexus = checked
		})
		formBackupLeft.AddCheckbox("Backup File Server: ", backupInfo.backupFileServer, func(checked bool) {
			backupInfo.backupFileServer = checked
		})
		formBackupLeft.AddCheckbox("Backup Sonarqube: ", backupInfo.backupSonarqube, func(checked bool) {
			backupInfo.backupSonarqube = checked
		})

		// right form
		initialOption := slices.Index(providers, providerSelected)
		formBackupRight.AddDropDown("Select a Provider: ", providers, initialOption, func(option string, optionIndex int) {
			if providerSelected != option {
				providerSelected = option
				locationConfig = make(map[string]string)
				cloudSecretConfig = make(map[string]string)
				flexBackup.Clear()
				initFlexBackup()
			}
		})

		if locationConfig == nil {
			locationConfig = make(map[string]string)
		}
		if cloudSecretConfig == nil {
			cloudSecretConfig = make(map[string]string)
		}

		switch providerSelected {
		case "minio":
			formBackupRight.AddInputField("Minio Server URL: ", locationConfig["s3Url"], 0, nil,
				func(text string) {
					locationConfig["s3Url"] = strings.Trim(text, " ")
					locationConfig["region"] = "minio"
					locationConfig["s3ForcePathStyle"] = "true"
					backupInfo.region = "minio"
				})
			formBackupRight.AddInputField("Access Key ID: ", cloudSecretConfig["aws_access_key_id"], 0, nil,
				func(text string) {
					cloudSecretConfig["aws_access_key_id"] = strings.Trim(text, " ")
				})
			formBackupRight.AddInputField("Secret Access Key: ", cloudSecretConfig["aws_secret_access_key"], 0, nil,
				func(text string) {
					cloudSecretConfig["aws_secret_access_key"] = strings.Trim(text, " ")
				})
		case "aws":
			formBackupRight.AddInputField("AWS Region: ", locationConfig["region"], 0, nil,
				func(text string) {
					locationConfig["region"] = strings.Trim(text, " ")
					backupInfo.region = locationConfig["region"]
				})
			formBackupRight.AddInputField("Access Key ID: ", cloudSecretConfig["aws_access_key_id"], 0, nil,
				func(text string) {
					cloudSecretConfig["aws_access_key_id"] = strings.Trim(text, " ")
				})
			formBackupRight.AddInputField("Secret Access Key: ", cloudSecretConfig["aws_secret_access_key"], 0, nil,
				func(text string) {
					cloudSecretConfig["aws_secret_access_key"] = strings.Trim(text, " ")
				})
		case "alibabacloud":
			formBackupRight.AddInputField("Alibaba Cloud Region: ", locationConfig["region"], 0, nil,
				func(text string) {
					locationConfig["region"] = strings.Trim(text, " ")
					backupInfo.region = locationConfig["region"]
				})
			formBackupRight.AddInputField("Access Key ID: ", cloudSecretConfig["ALIBABA_CLOUD_ACCESS_KEY_ID"], 0, nil,
				func(text string) {
					cloudSecretConfig["ALIBABA_CLOUD_ACCESS_KEY_ID"] = strings.Trim(text, " ")
				})
			formBackupRight.AddInputField("Access Key Secret: ", cloudSecretConfig["ALIBABA_CLOUD_ACCESS_KEY_SECRET"], 0, nil,
				func(text string) {
					cloudSecretConfig["ALIBABA_CLOUD_ACCESS_KEY_SECRET"] = strings.Trim(text, " ")
				})
		}

		formBackupRight.AddInputField("Bucket: ", backupInfo.bucket, 0, nil,
			func(text string) {
				backupInfo.bucket = strings.Trim(text, " ")
			})

		if backupInfo.schedule == "" {
			backupInfo.schedule = "5 1 * * *"
		}
		formBackupRight.AddInputField("Backup Schedule (crontab): ", backupInfo.schedule, 0, nil,
			func(text string) {
				backupInfo.schedule = strings.Trim(text, " ")
			})

		if backupInfo.ttl == 0 {
			backupInfo.ttl = 240
		}
		formBackupRight.AddInputField("Backup TTL (hour): ", strconv.Itoa(backupInfo.ttl), 0, nil,
			func(text string) {
				backupInfo.ttl, _ = strconv.Atoi(text)
			})
	}

	formDown := tview.NewForm()
	formDown.AddButton("Next", func() {
		if enableBackup {
			switch providerSelected {
			case "minio":
				if locationConfig["s3Url"] == "" {
					showErrorModal("Minio Server URL is empty.")
				}
				if cloudSecretConfig["aws_access_key_id"] == "" {
					showErrorModal("Access Key ID is empty.")
				}
				if cloudSecretConfig["aws_secret_access_key"] == "" {
					showErrorModal("Secret Access Key is empty.")
				}
				backupInfo.provider = "aws"
			case "aws":
				if locationConfig["region"] == "" {
					showErrorModal("Region is empty.")
				}
				if cloudSecretConfig["aws_access_key_id"] == "" {
					showErrorModal("Access Key ID is empty.")
				}
				if cloudSecretConfig["aws_secret_access_key"] == "" {
					showErrorModal("Secret Access Key is empty.")
				}
				backupInfo.provider = providerSelected
			case "alibabacloud":
				if locationConfig["region"] == "" {
					showErrorModal("Region is empty.")
				}
				if cloudSecretConfig["ALIBABA_CLOUD_ACCESS_KEY_ID"] == "" {
					showErrorModal("Access Key ID is empty.")
				}
				if cloudSecretConfig["ALIBABA_CLOUD_ACCESS_KEY_SECRET"] == "" {
					showErrorModal("Access Key Secret is empty.")
				}
				backupInfo.provider = providerSelected
			default:
				showErrorModal("Unknown Provider.")
			}

			if backupInfo.bucket == "" {
				showErrorModal("Bucket is empty.")
			}
			if backupInfo.schedule == "" {
				showErrorModal("Schedule is empty.")
			}
			if backupInfo.ttl == 0 {
				showErrorModal("TTL can't be 0.")
			}
			backupInfo.locationConfig = ""
			for k := range locationConfig {
				backupInfo.locationConfig = backupInfo.locationConfig + k + ": " + locationConfig[k] + "\n      "
			}

			backupInfo.cloudSecret = ""
			for k := range cloudSecretConfig {
				backupInfo.cloudSecret = backupInfo.cloudSecret + k + "=" + cloudSecretConfig[k] + "\n      "
			}
		}

		initFlexMirror()
		pages.SwitchToPage("Mirror")
	})

	formDown.AddButton("Back", func() {
		pages.SwitchToPage("Packages")
	})

	formDown.AddButton("Quit", func() {
		showQuitModal()
	})

	flexBackupMiddle.
		AddItem(formBackupLeft, 0, 1, false).
		AddItem(formBackupRight, 0, 3, false)

	flexBackupTop.SetDirection(tview.FlexRow).
		AddItem(checkboxBackup, 3, 0, true).
		AddItem(flexBackupMiddle, 0, 1, false)

	flexBackup.SetDirection(tview.FlexRow).
		AddItem(flexBackupTop, 0, 1, true).
		AddItem(formDown, 3, 1, false)
}
