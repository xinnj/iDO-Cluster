package main

import (
	"github.com/rivo/tview"
	"github.com/thlib/go-timezone-local/tzlocal"
	"net/url"
	"regexp"
	"strings"
)

type BasicInfo struct {
	clusterUrl string
	team       string
	timezone   string
}

var basicInfo = BasicInfo{clusterUrl: "", team: "default", timezone: ""}

func initFlexBasicInfo() {
	flexBasicInfo.Clear()
	formBasicInfo := tview.NewForm()
	formBasicInfo.SetTitle("Basic Info").SetBorder(true)

	formBasicInfo.AddInputField("Team: ", basicInfo.team, 0, nil, func(text string) {
		basicInfo.team = strings.Trim(text, " ")
	})

	formBasicInfo.AddInputField("Cluster public access URL: ", basicInfo.clusterUrl, 0, nil,
		func(text string) {
			basicInfo.clusterUrl = strings.Trim(text, " ")
		})

	if basicInfo.timezone == "" {
		var err error
		basicInfo.timezone, err = tzlocal.RuntimeTZ()
		check(err)
	}

	formBasicInfo.AddInputField("Timezone: ", basicInfo.timezone, 0, nil, func(text string) {
		basicInfo.timezone = text
	})

	formDown := tview.NewForm()

	formDown.AddButton("Next", func() {
		reTeam := regexp.MustCompile("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$")
		matches := reTeam.FindStringSubmatch(basicInfo.team)
		if matches == nil {
			showErrorModal("Format of team is wrong:\n" + basicInfo.team +
				"\nName must consist of lower case alphanumeric characters or '-', and must start and end with an alphanumeric character.")
			return
		}

		if basicInfo.clusterUrl == "" {
			showErrorModal("Custer public access URL is empty.")
			return
		}

		basicInfo.clusterUrl = strings.TrimSuffix(basicInfo.clusterUrl, "/")
		u, err := url.Parse(basicInfo.clusterUrl)
		if err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Host == "" {
			showErrorModal("Format of cluster public access URL is wrong: \n" + basicInfo.clusterUrl)
			return
		}

		initFlexStorage()
		pages.SwitchToPage("Storage")
	})

	formDown.AddButton("Quit", func() {
		showQuitModal()
	})

	flexBasicInfo.SetDirection(tview.FlexRow).
		AddItem(formBasicInfo, 0, 1, true).
		AddItem(formDown, 3, 1, false)
}
