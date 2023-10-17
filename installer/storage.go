package main

import (
	"github.com/rivo/tview"
	"strings"
)

type StorageClassType struct {
	ceph string
	nfs  string
}
type NfsConfig struct {
	server string
	path   string
}

var storageClassType = StorageClassType{
	ceph: "ceph-filesystem",
	nfs:  "nfs-client",
}
var storageClass = storageClassType.ceph
var nfsConfig NfsConfig

func initFlexStorage() {
	// todo: auto detect sc
	flexStorage.Clear()
	formStorage := tview.NewForm()
	formStorage.SetTitle("Storage").SetBorder(true)

	formStorage.AddCheckbox("Use CEPH: ", storageClass == storageClassType.ceph, func(checked bool) {
		storageClass = storageClassType.ceph
		flexStorage.Clear()
		initFlexStorage()
	})

	formStorage.AddCheckbox("Use NFS: ", storageClass == storageClassType.nfs, func(checked bool) {
		storageClass = storageClassType.nfs
		flexStorage.Clear()
		initFlexStorage()
	})
	if storageClass == storageClassType.nfs {
		formStorage.AddInputField("NFS server: ", nfsConfig.server, 0, nil, func(text string) {
			nfsConfig.server = strings.Trim(text, " ")
		})
		formStorage.AddInputField("NFS path: ", nfsConfig.path, 0, nil, func(text string) {
			nfsConfig.path = strings.Trim(text, " ")
		})
	}

	formDown := tview.NewForm()

	formDown.AddButton("Next", func() {
		if storageClass == storageClassType.nfs {
			if nfsConfig.server == "" {
				showErrorModal("NFS server is empty.")
				return
			}
			if nfsConfig.path == "" {
				showErrorModal("NFS path is empty.")
				return
			}
		}

		initFlexPackages()
		pages.SwitchToPage("Packages")
	})

	formDown.AddButton("Back", func() {
		pages.SwitchToPage("Basic Info")
	})

	formDown.AddButton("Quit", func() {
		showQuitModal()
	})

	flexStorage.SetDirection(tview.FlexRow).
		AddItem(formStorage, 0, 1, true).
		AddItem(formDown, 3, 1, false)
}
