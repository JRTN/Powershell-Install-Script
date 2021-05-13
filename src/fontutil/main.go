package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"test/fontutil/font"
)

func GetFontFileData(fileName string) (data []byte, err error) {
	if data, err = ioutil.ReadFile(fileName); err != nil {
		return nil, err
	}

	return data, nil
}

func InstallFont(fontFile string) (ret int, err error) {
	fmt.Printf("Now installing font %v\n", fontFile)
	data, err := GetFontFileData(fontFile)
	if err != nil {
		return 2, err
	}

	fontData, err := font.NewFontData(fontFile, data)
	if err != nil {
		return 3, err
	}

	err = fontData.Install()
	if err != nil {
		return 4, err
	}

	return 0, nil
}

func main() {
	if len(os.Args) < 2 {
		fmt.Printf("Must provide at least one argument\n")
		os.Exit(1)
	}

	fontFile := os.Args[1]
	fontFile = filepath.ToSlash(fontFile)

	info, err := os.Stat(fontFile)
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(-1)
	}

	if info.IsDir() {
		items, _ := ioutil.ReadDir(fontFile)
		for _, item := range items {
			if !item.IsDir() {
				ret, err := InstallFont(filepath.Join(fontFile, item.Name()))
				if err != nil {
					fmt.Printf("Error [%v] installing font [%v]: %v\n", ret, item.Name(), err.Error())
				}
			}
		}
	} else {
		ret, err := InstallFont(fontFile)
		if err != nil {
			fmt.Printf("Error [%v] installing font [%v]: %v\n", ret, fontFile, err.Error())
		}
	}
}
