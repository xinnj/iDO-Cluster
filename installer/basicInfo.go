package main

import (
	"github.com/rivo/tview"
	"github.com/thlib/go-timezone-local/tzlocal"
	"net/url"
	"regexp"
	"strings"
)

var clusterUrl string
var team = "default"
var timezone string

func initFlexBasicInfo() {
	flexBasicInfo.Clear()
	formBasicInfo := tview.NewForm()
	formBasicInfo.SetTitle("Basic Info").SetBorder(true)

	formBasicInfo.AddInputField("Team: ", team, 0, nil, func(text string) {
		team = strings.Trim(text, " ")
	})

	formBasicInfo.AddInputField("Cluster public access URL: ", clusterUrl, 0, nil,
		func(text string) {
			clusterUrl = strings.Trim(text, " ")
		})

	if timezone == "" {
		var err error
		timezone, err = tzlocal.RuntimeTZ()
		check(err)
	}

	formBasicInfo.AddInputField("Timezone: ", timezone, 0, nil, func(text string) {
		timezone = text
	})

	formDown := tview.NewForm()

	formDown.AddButton("Next", func() {
		reTeam := regexp.MustCompile("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$")
		matches := reTeam.FindStringSubmatch(team)
		if matches == nil {
			showErrorModal("Format of team is wrong:\n" + team +
				"\nName must consist of lower case alphanumeric characters or '-', and must start and end with an alphanumeric character.")
			return
		}

		if clusterUrl == "" {
			showErrorModal("Custer public access URL is empty.")
			return
		}
		u, err := url.Parse(clusterUrl)
		if err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Host == "" {
			showErrorModal("Format of cluster public access URL is wrong: \n" + clusterUrl)
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
