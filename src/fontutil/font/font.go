package font

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"path"
	"path/filepath"
	"strings"

	"github.com/ConradIrwin/font/sfnt"
	"golang.org/x/sys/windows/registry"
)

const (
	FONTS_DIR = `C:\Windows\Fonts`
	FONTS_REG = `SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts`
)

// FontData describes a font file and the various metadata associated with it.
type FontData struct {
	Name     string
	Family   string
	FileName string
	Metadata map[sfnt.NameID]string
	Data     []byte
}

var fontExtensions = map[string]bool{
	".otf": true,
	".ttf": true,
}

func NewFontData(fileName string, data []byte) (*FontData, error) {
	if _, ok := fontExtensions[strings.ToLower(path.Ext(fileName))]; !ok {
		return nil, fmt.Errorf("file %v is not a supported font file", fileName)
	}

	fontData := &FontData{
		FileName: fileName,
		Metadata: make(map[sfnt.NameID]string),
		Data:     data,
	}

	font, err := sfnt.Parse(bytes.NewReader(fontData.Data))
	if err != nil {
		return nil, err
	}

	if !font.HasTable(sfnt.TagName) {
		return nil, fmt.Errorf("font %v does not contain a name table", fileName)
	}

	nameTable, err := font.NameTable()
	if err != nil {
		return nil, err
	}

	for _, nameEntry := range nameTable.List() {
		fontData.Metadata[nameEntry.NameID] = nameEntry.String()
	}

	fontData.Name = fontData.Metadata[sfnt.NameFull]
	fontData.Family = fontData.Metadata[sfnt.NamePreferredFamily]

	if fontData.Family == "" {
		if v, ok := fontData.Metadata[sfnt.NameFontFamily]; ok {
			fontData.Family = v
		}
	}

	if fontData.Name == "" {
		fontData.Name = fileName
	}

	return fontData, nil
}

func (fontData *FontData) Install() error {
	fileName := filepath.Base(fontData.FileName)
	fullPath := filepath.Join(FONTS_DIR, fileName)

	err := ioutil.WriteFile(fullPath, fontData.Data, 0644)
	if err != nil {
		return err
	}

	k, err := registry.OpenKey(registry.LOCAL_MACHINE, FONTS_REG, registry.WRITE)
	if err != nil {
		return fmt.Errorf("failed to open registry key [HKLM:%v]: %v", FONTS_REG, err.Error())
	}
	defer k.Close()

	keyName := fmt.Sprintf("%v (TrueType)", fontData.Name)
	keyName = strings.ReplaceAll(keyName, "\x00", "") //Replace any null characters that may be left from parsing the file

	if err = k.SetStringValue(keyName, fileName); err != nil {
		return fmt.Errorf("failed to set registry value [%v, %v]: %v", keyName, fileName, err.Error())
	}

	return nil
}
