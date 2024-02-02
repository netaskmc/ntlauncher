!include "MUI2.nsh"
!include "FileFunc.nsh"

;--------------------------------
;General
!define BASE "..\.."
!define BUILD_DIR "${BASE}\build\windows"
!define RELEASE_DIR "${BUILD_DIR}\runner\Release"
!define INSTALLER_DIR "${BUILD_DIR}"

;Name and file
!define APPNAME "ntlauncher"

!getdllversion "${RELEASE_DIR}\${APPNAME}.exe" Appv
!define VERSION "${Appv1}.${Appv2}.${Appv3}+${Appv4}"
!define LOCALE_APPNAME "NeTask Launcher"
!define PUBLISHER "NeTask Collective"

!define ICON "${BASE}\windows\runner\resources\app_icon.ico"

Name "${LOCALE_APPNAME}"
OutFile "${INSTALLER_DIR}\${APPNAME}-${VERSION}-setup.exe"
BrandingText "${LOCALE_APPNAME} ${VERSION}"

;!define MUI_ICON "$%ICON%"
;!define MUI_UNICON "$%ICON%"
; !define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
!define MUI_ICON "${ICON}"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall.ico"
!define MUI_FINISHPAGE_RUN "$INSTDIR\${APPNAME}.exe"

; !define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\nsis3-metro.bmp"
; !define MUI_UNWELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\nsis3-metro.bmp"

!define MUI_WELCOMEFINISHPAGE_BITMAP "banner.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "banner.bmp"

;Default installation folder
InstallDir "$LOCALAPPDATA\${APPNAME}"

;Get installation folder from registry if available
InstallDirRegKey HKCU "Software\${APPNAME}" ""

;Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------
;Interface Settings

!define MUI_ABORTWARNING

;--------------------------------
;Pages

!insertmacro MUI_PAGE_WELCOME
; !insertmacro MUI_PAGE_LICENSE "License.txt"
; !insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

!insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "Default"

  SetOutPath "$INSTDIR"

  ;ADD YOUR OWN FILES HERE...
  File "${RELEASE_DIR}\${APPNAME}.exe" ; Main executable
  File "${RELEASE_DIR}\flutter_secure_storage_windows_plugin.dll"
  File "${RELEASE_DIR}\flutter_windows.dll"
  File "${RELEASE_DIR}\screen_retriever_plugin.dll"
  File "${RELEASE_DIR}\url_launcher_windows_plugin.dll"
  File "${RELEASE_DIR}\window_manager_plugin.dll"
  File /r "${RELEASE_DIR}\data" ; Assets

  ;Create Uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  call installShortcuts
  Call installRegEntry

SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ;ADD YOUR OWN FILES HERE...
  RMDir /r "$INSTDIR"

  ;Rmove Uninstaller
  ; Delete "$INSTDIR\Uninstall.exe"

  call un.removeShortcuts
  Call un.removeRegEntry

SectionEnd

Function installShortcuts
  ;create shortcuts in the start menu and on the desktop
  CreateDirectory "$SMPROGRAMS\${APPNAME}"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\${LOCALE_APPNAME}.lnk" "$INSTDIR\${APPNAME}.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\Uninstall ${LOCALE_APPNAME}.lnk" "$INSTDIR\Uninstall.exe"
  CreateShortCut "$DESKTOP\${LOCALE_APPNAME}.lnk" "$INSTDIR\${APPNAME}.exe"
FunctionEnd

Function un.removeShortcuts
  ; delete the shortcuts
  delete "$SMPROGRAMS\${APPNAME}\${LOCALE_APPNAME}.lnk"
  delete "$SMPROGRAMS\${APPNAME}\Uninstall ${LOCALE_APPNAME}.lnk"
  rmDir  "$SMPROGRAMS\${APPNAME}"
  delete "$DESKTOP\${LOCALE_APPNAME}.lnk"
FunctionEnd

Function installRegEntry
  ;Store installation folder
  WriteRegStr HKCU "Software\${APPNAME}" "" $INSTDIR

  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
                   "DisplayName" "${LOCALE_APPNAME}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
                   "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
                   "DisplayIcon" "$INSTDIR\${APPNAME}.exe,0"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
                   "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
                   "Publisher" "${PUBLISHER}"

  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
                   "EstimatedSize" "$0"
FunctionEnd

Function un.removeRegEntry
  DeleteRegKey HKCU "Software\${APPNAME}"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
FunctionEnd