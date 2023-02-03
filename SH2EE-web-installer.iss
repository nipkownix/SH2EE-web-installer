; -- SH2EE Web Installer --

#define INSTALLER_VER  "1.1.1"
#define DEBUG          "true"
#define SH2EE_CSV_URL  "https://raw.githubusercontent.com/elishacloud/Silent-Hill-2-Enhancements/master/Resources/webcsv.url"

//#define LOCAL_CSV      "E:\Porgrams\git_repos\SH2EE-web-installer\test\_sh2ee.csv"

#define PROJECT_URL      "https://enhanced.townofsilenthill.com/SH2/"
#define TROUBLESHOOT_URL "https://enhanced.townofsilenthill.com/SH2/troubleshoot.htm"
#define HELP_URL         "https://github.com/elishacloud/Silent-Hill-2-Enhancements/issues"

#define eeModuleName      "SH2 Enhancements Module"
#define ee_exeName        "Enhanced Executable"
#define ee_essentialsName "Enhanced Edition Essential Files"
#define img_packName      "Image Enhancement Pack"
#define fmv_packName      "FMV Enhancement Pack"
#define audio_pack        "Audio Enhancement Pack"
#define dsoalName         "DSOAL"
#define xidiName          "Xidi"
#define CreditsName       "Credits"

#include "languages/English.iss"
#include "languages/BrazilianPortuguese.iss"
#include "languages/Spanish.iss"
#include "languages/Italian.iss"
#include "languages/Japanese.iss"

[Setup]
AppName=Silent Hill 2: Enhanced Edition
AppVersion={#INSTALLER_VER}
WizardStyle=modern
DefaultDirName={code:GetDefaultDirName}
OutputDir=build
OutputBaseFilename=SH2EEsetup
DirExistsWarning=no
DisableWelcomePage=no
RestartIfNeededByRun=no
AppendDefaultDirName=no
DisableProgramGroupPage=yes
UsePreviousTasks=no
UsePreviousSetupType=no
UsePreviousAppDir=no
RestartApplications=no
Uninstallable=no
DisableDirPage=no
ShowLanguageDialog=no
WizardResizable=yes
SetupIconFile=resources\icon.ico
WizardImageFile=resources\side.bmp
WizardSmallImageFile=resources\top.bmp
WizardImageAlphaFormat=premultiplied
VersionInfoVersion={#INSTALLER_VER}
VersionInfoCompany=nipkow
VersionInfoDescription=Silent Hill 2: Enhanced Edition Web Installer
VersionInfoTextVersion={#INSTALLER_VER}

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"; LicenseFile: "languages\English-license.rtf"
Name: "pt_br"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"; LicenseFile: "languages\BrazilianPortuguese-license.rtf"
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl"; LicenseFile: "languages\Spanish-license.rtf"
Name: "it"; MessagesFile: "compiler:Languages\Italian.isl"; LicenseFile: "languages\Italian-license.rtf"
Name: "jp"; MessagesFile: "compiler:Languages\Japanese.isl"; LicenseFile: "languages\Japanese-license.rtf"

[Types]
Name: full; Description: {cm:installTypeFull}
Name: custom; Description: {cm:installTypeCustom}; Flags: iscustom

[Components]
; *** component name MUST match the component "id" in _sh2ee.csv! ***
Name: sh2emodule;    Description: {#eeModuleName};      Types: full custom
Name: ee_exe;        Description: {#ee_exeName};        Types: full custom
Name: ee_essentials; Description: {#ee_essentialsName}; Types: full
Name: img_pack;      Description: {#img_packName};      Types: full
Name: fmv_pack;      Description: {#fmv_packName};      Types: full
Name: audio_pack;    Description: {#audio_pack};        Types: full
Name: dsoal;         Description: {#dsoalName};         Types: full
Name: xidi;          Description: {#xidiName};          Types: full
Name: credits;       Description: {#creditsName};       Types: full custom

[Files]
; Tools below
Source: "includes\7zip\7za_x86.exe"; Flags: dontcopy
Source: "includes\7zip\7za_x64.exe"; Flags: dontcopy
Source: "includes\cmdlinerunner\cmdlinerunner.dll"; Flags: dontcopy
Source: "includes\BytesToString\BytesToString.dll"; Flags: dontcopy
Source: "includes\deletefile_util\deletefile_util.exe"; Flags: dontcopy
Source: "includes\renamefile_util\renamefile_util.exe"; Flags: dontcopy
Source: "{srcexe}"; DestDir: "{tmp}"; DestName: "SH2EEsetup.exe"; Flags: external
Source: "resources\top.bmp"; Flags: dontcopy
Source: "resources\maintenance\icon_install.bmp"; Flags: dontcopy
Source: "resources\maintenance\icon_update.bmp"; Flags: dontcopy
Source: "resources\maintenance\icon_adjust.bmp"; Flags: dontcopy
Source: "resources\maintenance\icon_uninstall.bmp"; Flags: dontcopy

[Run]
Filename: "{app}\sh2pc.exe"; Description: {cm:StartGameAfterExiting}; Flags: nowait postinstall skipifsilent unchecked
Filename: "{app}\SH2EEconfig.exe"; Description: {cm:OpenCfgToolAfterExiting}; Flags: nowait postinstall skipifsilent unchecked

[Messages]
SetupAppTitle    =Silent Hill 2: Enhanced Edition Setup Tool
SetupWindowTitle =Silent Hill 2: Enhanced Edition Setup Tool
WelcomeLabel1    =Silent Hill 2: Enhanced Edition Setup Tool

// Seems IDP must be included before [Code]
#include "includes/innosetup-download-plugin/idp.iss"

// IDP langs must be included after idp.iss
#include "includes/innosetup-download-plugin/source/unicode/idplang/BrazilianPortuguese.iss"
#include "includes/innosetup-download-plugin/source/unicode/idplang/Spanish.iss"
#include "includes/innosetup-download-plugin/source/unicode/idplang/Italian.iss"

[Code]
type
  TIniArray = record
    Section : String;
    Key     : String;
    Value   : String;
  end;

  TSizeArray = record
    Bytes   : Int64;
    String  : String;
  end;

var
  webcsv_url            : String;
  LanguageButton        : TButton;
  userPackageDataDir    : String;
  maintenanceMode       : Boolean;
  updateMode            : Boolean;
  selfUpdateMode        : Boolean;
  localInstallMode      : Boolean;
  Uninstalling          : Boolean;
  CurIniArray           : array of TIniArray;
  FileSizeArray         : array of TSizeArray;
  sh2pcFilesWerePresent : Boolean;

#include "includes/Util.iss"
#include "CustomUninstall.iss"
#include "includes/Extractore.iss"
#include "wpMaintenance.iss"
#include "LanguageDialog.iss"
#include "wpInstallMode.iss"
#include "CSVparser.iss"
#include "wpSelectComponents.iss"
#include "wpExtract.iss"
#include "SelfUpdate.iss"
#include "CustomLabels.iss"

// Runs before anything else
function InitializeSetup(): Boolean;
var
  i: integer;
  Language: string;
  csvDownloadSuccess: Boolean;
  urlDownloadSuccess: Boolean;
  localFilesMissing :Boolean;
  Lines: TStringList;
begin
  Result := True;

  // Determine whether or not we should be in "maintenance mode"
  if DirExists(ExpandConstant('{src}\') + 'data') and FileExists(ExpandConstant('{src}\') + 'SH2EEsetup.dat') then
    maintenanceMode := True;

  // Set language
  Language := ExpandConstant('{param:LANG}');
  if Language = '' then
  begin
    Log('No language specified, calling language func');
    SelectLanguage(false);
    Result := False;
    Exit;
  end else
    Log('Language specified, proceeding with installation');

  // Determine weather or not we should be in local installation mode
  if FileExists(ExpandConstant('{src}\') + 'local_sh2ee.dat') then
  begin

    // Create an array of TWebComponentsInfo records from sh2ee.csv and store them in a global variable
    LocalCompsArray := LocalCSVToInfoArray(ExpandConstant('{src}\') + 'local_sh2ee.dat');
    // Check if above didn't work
    if GetArrayLength(LocalCompsArray) = 0 then
    begin
      if MsgBox(CustomMessage('LocalCSVParseFailed'), mbConfirmation, MB_YESNO) = IDYES then
      begin
        // Remove local files
        for i := 0 to GetArrayLength(LocalCompsArray) - 1 do
          DeleteFile(ExpandConstant('{src}\') + LocalCompsArray[i].fileName);

        DeleteFile(ExpandConstant('{src}\') + 'local_sh2ee.dat')

        SetArrayLength(LocalCompsArray, 0);
      end else
      begin
        // User pressed No, so we exit
        Result := False;
        exit;
      end;
    end;

    // Check if the local files from the local .csv actually exist
    for i := 0 to GetArrayLength(LocalCompsArray) - 1 do begin
      if not (LocalCompsArray[i].fileName = 'notDownloaded') and not FileExists(ExpandConstant('{src}\') + LocalCompsArray[i].fileName) then
        localFilesMissing := true;
    end;

    // Decide what to do if files are missing
    if localFilesMissing then
    begin
      if MsgBox(CustomMessage('LocalCSVMissingFiles'), mbConfirmation, MB_YESNO) = IDYES then
      begin
        // Remove local files
        for i := 0 to GetArrayLength(LocalCompsArray) - 1 do
          DeleteFile(ExpandConstant('{src}\') + LocalCompsArray[i].fileName);

        DeleteFile(ExpandConstant('{src}\') + 'local_sh2ee.dat')

        SetArrayLength(LocalCompsArray, 0);
        maintenanceMode := false; // Make sure this is false
      end else
      begin
        // User pressed No, so we exit
        Result := False;
        exit;
      end;
    end else
    begin
      // Check if this version of the installer should work with the local .csv
      for i := 0 to GetArrayLength(LocalCompsArray) - 1 do begin
        if LocalCompsArray[i].id = 'setup_tool' then
        begin
          if not SameText(LocalCompsArray[i].version, ExpandConstant('{#INSTALLER_VER}')) then
          begin
            MsgBox(FmtMessage(CustomMessage('LocalCSVIncompatibleVersion'), [ExpandConstant('{#INSTALLER_VER}'), LocalCompsArray[i].version]), mbCriticalError, MB_OK);
            Result := False;
            exit;
          end;
        end;
      end;

      // Guess everything should be fine then
      localInstallMode := true;
    end;
  end;

  // localInstallMode doesn't need any of this
  if not localInstallMode then
  begin
    // Get web .csv URL from git repo's .url file
    #ifndef LOCAL_CSV
    begin
      repeat
        urlDownloadSuccess := idpDownloadFile('{#SH2EE_CSV_URL}', ExpandConstant('{tmp}\webcsv.url'));
        if not urlDownloadSuccess then
        begin
          if MsgBox(CustomMessage('WebURLDownloadError'), mbConfirmation, MB_YESNO) = IDNO then
          begin
            Result := False;
            exit;
          end;
        end;
      until urlDownloadSuccess;
    end;

    Lines := TStringList.Create;
    Lines.LoadFromFile(ExpandConstant('{tmp}\webcsv.url'));
  
    webcsv_url := Lines[0];

    // Store the path to web sh2ee.csv in a global variable
    CSVFilePath := tmp(GetURLFilePart(webcsv_url))
    #endif

    #ifdef LOCAL_CSV
      CSVFilePath := '{#LOCAL_CSV}';
    #endif

    // Download sh2ee.csv; show an error message and exit the installer if downloading fails
    #ifndef LOCAL_CSV
    begin
      repeat
        csvDownloadSuccess := idpDownloadFile(webcsv_url, CSVFilePath);
        if not csvDownloadSuccess then
        begin
          if MsgBox(CustomMessage('WebCSVDownloadError'), mbConfirmation, MB_YESNO) = IDNO then
          begin
            Result := False;
            exit;
          end;
        end;
      until csvDownloadSuccess;
    end;
    #endif

    // Create an array of TWebComponentsInfo records from sh2ee.csv and store them in a global variable
    WebCompsArray := WebCSVToInfoArray(CSVFilePath);
    // Check if above didn't work
    if GetArrayLength(WebCompsArray) = 0 then
    begin
      MsgBox(CustomMessage('WebCSVParseFailed'), mbCriticalError, MB_OK);
      Result := False;
      exit;
    end;

    // If we are in "maintenance mode"
    if maintenanceMode then
    begin
      // Create an array of TMaintenanceComponentsInfo records from the existing SH2EEsetup.dat and store it in a global variable
      MaintenanceCompsArray := MaintenanceCSVToInfoArray(ExpandConstant('{src}\SH2EEsetup.dat'));

      // Check if above didn't work
      if GetArrayLength(WebCompsArray) = 0 then
      begin
        MsgBox(CustomMessage('MaintenanceCSVParseFailed'), mbCriticalError, MB_OK);
        Result := False;
        exit;
      end;

      // Update and reload local CSV if array sizes are different
      if not SamePackedVersion(GetArrayLength(MaintenanceCompsArray), GetArrayLength(WebCompsArray)) then // [2] Using SamePackedVersion() to compare lengths isn't the fanciest approach, but it works
      begin
        UpdateMaintenanceCSV(true);
        MaintenanceCompsArray := MaintenanceCSVToInfoArray(ExpandConstant('{src}\SH2EEsetup.dat'));
      end;

      // Update and reload local CSV if the order of ids don't match
      for i := 0 to GetArrayLength(WebCompsArray) - 1 do
      begin
        if not SameText(MaintenanceCompsArray[i].id, WebCompsArray[i].id) then
          UpdateMaintenanceCSV(true);
          MaintenanceCompsArray := MaintenanceCSVToInfoArray(ExpandConstant('{src}\SH2EEsetup.dat'));
      end;
    end;

    // Enable Update if started with argument
    if CmdLineParamExists('-update') and maintenanceMode then
    begin
      updateMode := True;
    end;

    // Enable selfUpdate if started with argument
    if CmdLineParamExists('-selfUpdate') then
    begin
      selfUpdateMode := True;
      maintenanceMode := True;
    end;

    // Check if the installer should work correctly with with the current server-side files
    if not selfUpdateMode then
    begin
      for i := 0 to GetArrayLength(WebCompsArray) - 1 do begin
        if WebCompsArray[i].id = 'setup_tool' then
        begin
          if not SameText(WebCompsArray[i].version, ExpandConstant('{#INSTALLER_VER}')) then
          begin
            if MsgBox(CustomMessage('OutdatedSetupTool'), mbConfirmation, MB_YESNO) = IDYES then
            begin
              selfUpdateMode := True;
              maintenanceMode := True;
            end else
            begin
              Result := False;
              exit;
            end;
          end else
          begin
            // Make sure the local .csv has the current Setup Tool's version, as there is
            // a chance the user might have manually updated the setup tool.
            UpdateMaintenanceCSV_SetupToolOnly();
          end;
        end;
      end;
    end;
  end;
end;

// What to do if the user presses the help button
procedure HelpButtonClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('open', '{#HELP_URL}', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

// What to do if the user presses the language button
procedure LanguageButtonClick(Sender: TObject);
begin
  // Show language dialog
  if SelectLanguage(true) then
    ExitProcess(1);
end;

procedure InitializeWizard();
var
  HelpButton     : TButton;
  DebugLabel     : TNewStaticText;
  i: integer;
begin
  if not localInstallMode then
  begin
    // Compare the lenght of the web CSV array with the installer's component list
    if not SamePackedVersion(WizardForm.ComponentsList.Items.Count, GetArrayLength(WebCompsArray) - 1) then // Using SamePackedVersion() to compare lengths isn't the fanciest approach, but it works
    begin
      MsgBox(CustomMessage('InvalidWebComponentsListSize'), mbCriticalError, MB_OK);
      Abort;
    end;
  end else
  begin
    // Compare the lenght of the local CSV array with the installer's component list
    if not SamePackedVersion(WizardForm.ComponentsList.Items.Count, GetArrayLength(LocalCompsArray) -1) then
    begin
      if MsgBox(CustomMessage('InvalidLocalComponentsListSize'), mbConfirmation, MB_YESNO) = IDYES then
      begin
        // Remove local files
        for i := 0 to GetArrayLength(LocalCompsArray) - 1 do
          DeleteFile(ExpandConstant('{src}\') + LocalCompsArray[i].fileName);

        DeleteFile(ExpandConstant('{src}\') + 'local_sh2ee.dat')

        // Run new instance
        ShellExecute(0, '', ExpandConstant('{srcexe}'), '', '', SW_SHOW);

        // Close this instance
        Abort;
      end else
      begin
        // User pressed No, so we just exit
        Abort;
      end;
    end;
  end;

  // Replace some default labels with customized ones if not in maintenance mode
  if not maintenanceMode then
    Replace_Labels();

  if not maintenanceMode and not localInstallMode then
    PrepareInstallModePage();

  // IDP settings
  if not localInstallMode then
  begin
    idpSetOption('AllowContinue',  '1');
    idpSetOption('DetailsVisible', '1');
    idpSetOption('DetailsButton',  '1');
    idpSetOption('RetryButton',    '1');
    idpSetOption('UserAgent',      'SH2EE web installer');
    idpSetOption('InvalidCert',    'ignore');
  end;

  if not localInstallMode then
  begin
    // Get file sizes from host, exit if we fail for some reason
    SetArrayLength(FileSizeArray, GetArrayLength(WebCompsArray) - 1);
    for i := 0 to GetArrayLength(WebCompsArray) - 1 do
    begin
      if not (WebCompsArray[i].id = 'setup_tool') then
      begin
        if not idpGetFileSize(WebCompsArray[i].URL, FileSizeArray[i - 1].Bytes) then
          begin
            MsgBox(CustomMessage('FailedToQueryComponents'), mbCriticalError, MB_OK);
            ExitProcess(1);
          end;
        FileSizeArray[i - 1].String := BytesToString(FileSizeArray[i - 1].Bytes);
        if {#DEBUG} then Log('# ' + WebCompsArray[i].ID + ' size = ' + FileSizeArray[i - 1].String);
      end;
    end;
  end else
  begin
    // Get sizes from local files, exit if we fail for some reason
    SetArrayLength(FileSizeArray, GetArrayLength(LocalCompsArray));
    for i := 0 to GetArrayLength(LocalCompsArray) - 1 do
    begin
      if not (LocalCompsArray[i].id = 'setup_tool') then
      begin
        if not (LocalCompsArray[i].fileName = 'notDownloaded') and not FileSize64(ExpandConstant('{src}\') + LocalCompsArray[i].fileName, FileSizeArray[i - 1].Bytes) then
          begin
            MsgBox(CustomMessage('FailedToQueryComponents2'), mbCriticalError, MB_OK);
            ExitProcess(1);
          end;
        FileSizeArray[i - 1].String := BytesToString(FileSizeArray[i - 1].Bytes);
        if {#DEBUG} then Log('# ' + LocalCompsArray[i].ID + ' size = ' + FileSizeArray[i - 1].String);
      end;
    end;
  end;

  // Register new RunList OnClick event
  WizardForm.RunList.OnClickCheck := @RunListClickCheck;
  RunListLastChecked := -1;

  // Customize the default SelectComponents
  customize_wpSelectComponents();

  // Start the download after wpReady
  if not localInstallMode then
    idpDownloadAfter(wpReady);

  // "Install/Update/Uninstall", etc
  if maintenanceMode and (not selfUpdateMode) then
    PrepareMaintenance();

  // Updates the setup tool itself
  if selfUpdateMode then
    PrepareSelfUpdate();

  // Create the file extraction page
  if not selfUpdateMode then
    create_wpExtract();

  // Force installation of the SH2E module, EE exe and credits if not in maintenance mode
  if not maintenanceMode then
  begin
    WizardForm.ComponentsList.Checked[0] := true;
    WizardForm.ComponentsList.Checked[1] := true;
    WizardForm.ComponentsList.Checked[8] := true;
    WizardForm.ComponentsList.ItemEnabled[0] := false;
    WizardForm.ComponentsList.ItemEnabled[1] := false;
    WizardForm.ComponentsList.ItemEnabled[8] := false;
  end;

  // Items names and descriptions on wpSelectComponents
  create_CompNameDesc();
  SetTimer(0, 0, 50, CreateCallback(@HoverTimerProc));  // Create onhover process

  // Show help button on bottom left
  HelpButton := TButton.Create(WizardForm);
  with HelpButton do
  begin
      Top        := WizardForm.CancelButton.Top;
      Left       := WizardForm.ClientWidth - WizardForm.CancelButton.Left - WizardForm.CancelButton.Width;
      Height     := WizardForm.CancelButton.Height;
      Anchors    := [akLeft, akBottom];
      Caption    := CustomMessage('HelpButton');
      Cursor     := crHelp;
      Font.Color := clHighlight;
      OnClick    := @HelpButtonClick;
      Parent     := WizardForm;
  end;

  // Show language button in maintenanceMode
  if maintenanceMode then
  begin
    LanguageButton := TButton.Create(WizardForm);
    with LanguageButton do
    begin
        Top        := WizardForm.CancelButton.Top;
        Left       := HelpButton.Left + HelpButton.Width + ScaleX(10);
        Height     := WizardForm.CancelButton.Height;
        Width      := WizardForm.CancelButton.Width + ScaleX(25);
        Anchors    := [akLeft, akBottom];
        Caption    := CustomMessage('LanguageButton');
        Font.Color := clHighlight;
        OnClick    := @LanguageButtonClick;
        Parent     := WizardForm;
    end;
  end;

  // Show "DEBUG ON" text
  if {#DEBUG} then
  begin
    DebugLabel := TNewStaticText.Create(WizardForm);
    with DebugLabel do
    begin
        Top        := HelpButton.Top + 4;
        Anchors    := [akRight, akBottom];
        Left       := WizardForm.BackButton.Left - WizardForm.BackButton.Width;
        Caption    := ExpandConstant('DEBUG ON');
        Font.Style := [fsBold];
        Parent     := WizardForm;
    end;
  end;

  // Show "OFFLINE INSTALLATION" text
  if localInstallMode then
  begin
    DebugLabel := TNewStaticText.Create(WizardForm);
    with DebugLabel do
    begin
        Top        := HelpButton.Top + 4;
        Anchors    := [akLeft, akBottom];
        Left       := HelpButton.Left + HelpButton.Width + 10;
        Caption    := ExpandConstant('OFFLINE INSTALLATION');
        Font.Style := [fsBold];
        Parent     := WizardForm;
    end;
  end;

end;

function ShouldSkipPage(CurPage: Integer): Boolean;
begin
  Result := False;

  // Skip pages if in selfUpdateMode
  if selfUpdateMode then
  begin
    if (CurPage = wpSelectComponents) or
       (CurPage = wpFinished) then
    begin
      Result := True;
    end;
  end;

  // Skip wpSelectComponents and wpExtract if uninstalling
  if maintenanceMode and not selfUpdateMode then
  begin
    if (CurPage = wpSelectComponents) or
       (CurPage = wpExtract.ID) then
          if uninstallRadioBtn.Checked then
            Result := True;
  end;

  // Skip pages if running launcher
  if maintenanceMode and not selfUpdateMode and not updateMode then
  begin
    if (CurPage = wpSelectComponents) or
       (CurPage = wpExtract.ID) or
       (CurPage = wpPreparing) or
       (CurPage = wpInstalling) or
       (CurPage = wpFinished) then
          if adjustRadioBtn.Checked then
            Result := True;
  end;

  // Skip to updater page if started with argument
  if CmdLineParamExists('-update') and maintenanceMode then
  begin
    if (CurPage = wpMaintenance.ID) then
    begin
      Result := True;
    end;
  end;

  // Skip normal setup pages if in maintenanceMode
  if maintenanceMode then
  begin
    if (CurPage = wpWelcome) or
       (CurPage = wpLicense) or
       (CurPage = wpSelectDir) or
       (CurPage = wpReady) then
    begin
      Result := True;
    end;
  end;
end;

function NextButtonClick(CurPage: Integer): Boolean;
var
  i : Integer;
  iRequiredSize : Int64;
begin
  Result := True;

  if CurPage = wpSelectComponents then
  begin
    // Check if componentes are selected
    if iTotalCompCount = 0 then
    begin
      MsgBox(CustomMessage('NoComponentsSelected'), mbInformation, MB_OK);
      Result := False;
      exit;
    end;

    // Check if we have enough free space
    iRequiredSize := iTotalCompSize * 2;
    Log(WizardDirValue);
    if not IsEnoughFreeSpace(WizardDirValue, iRequiredSize) then
    begin
      MsgBox(FmtMessage(CustomMessage('NoFreeSpace'), [BytesToString(iRequiredSize)]), mbCriticalError, MB_OK);
      ExitProcess(666);
    end;

    // Add files to IDP
    if not localInstallMode then
    begin
      iTotalCompCount := 0; // Clear list
      idpClearFiles(); // Make sure idp file list is clean
      for i := 0 to WizardForm.ComponentsList.Items.Count - 1 do
      begin
        if WizardForm.ComponentsList.Checked[i] then
        begin
          iTotalCompCount := iTotalCompCount + 1;
          idpAddFile(WebCompsArray[i + 1].URL, localDataDir(GetURLFilePart(WebCompsArray[i + 1].URL)));
        end;
      end;
    end;

    selectedComponents := WizardSelectedComponents(false);
    Log('# The following [' + IntToStr(iTotalCompCount) + '] components are selected: ' + selectedComponents);
  end;

  // Check for file presence in WizardDirValue
  if CurPage = wpSelectDir then
  begin
    if not FileExists(AddBackslash(WizardDirValue) + 'data\pic\etc\konami.tex') then
    begin
      if MsgBox(CustomMessage('GameFilesNotFound'), mbConfirmation, MB_YESNO) = IDYES then
      begin
        Result := True;
        sh2pcFilesWerePresent := False;
      end else
        Result := False;
    end else
      sh2pcFilesWerePresent := True;

    // Check for the presence of a semicolon in the installation path
    if Pos(';', WizardDirValue) > 0 then
    begin
      MsgBox(CustomMessage('SemicolonInPath'), mbInformation, MB_OK);
      Result := False;
    end;
  end;
end;

procedure postInstall();
begin
  if selfUpdateMode then
    SelfUpdate_postInstall();

  // User chose to back up installation files
  if (Length(userPackageDataDir) > 0) then
  begin
    CreateLocalCSV();
    FileCopy(ExpandConstant('{tmp}\SH2EEsetup.exe'), localDataDir('SH2EEsetup.exe'), false);
  end;

  // Copy SH2EEsetup.exe to the game's directory if we're not currently running from it
  if not (DirExists(ExpandConstant('{src}\') + 'data') and FileExists(ExpandConstant('{src}\') + 'SH2EEsetup.dat')) then
    FileCopy(ExpandConstant('{tmp}\SH2EEsetup.exe'), ExpandConstant('{app}\SH2EEsetup.exe'), false);

  // Display Wine message when not uninstalling
  if maintenanceMode and not selfUpdateMode then
    if uninstallRadioBtn.Checked then
    Uninstalling := True;

  if (IsWine) and not (Uninstalling) and not (RegValueExists(HKEY_CURRENT_USER, 'Software\Wine\DllOverrides', 'd3d8')) then
  begin
    RegWriteStringValue(HKEY_CURRENT_USER, 'Software\Wine\DllOverrides', 'd3d8', 'native,builtin');
    RegWriteStringValue(HKEY_CURRENT_USER, 'Software\Wine\DllOverrides', 'Dinput', 'native,builtin');
    RegWriteStringValue(HKEY_CURRENT_USER, 'Software\Wine\DllOverrides', 'Dinput8', 'native,builtin');
    RegWriteStringValue(HKEY_CURRENT_USER, 'Software\Wine\DllOverrides', 'dsound', 'native,builtin');
    RegWriteStringValue(HKEY_CURRENT_USER, 'Software\Wine\DllOverrides', 'XInput1_3', 'native,builtin');
    MsgBox(CustomMessage('WineDetected'), mbInformation, MB_OK);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  //if CurStep = ssInstall then preInstall();
  if CurStep = ssPostInstall then postInstall();
end;

procedure CurPageChanged(CurPage: Integer);
var
  sh2pcFilesExist : Boolean;
  i : Integer;
begin
  // Only enable the lang button if we're in the main maintenance page
  if maintenanceMode and not selfUpdateMode then
  begin
    if (CurPage = wpMaintenance.ID) then
      LanguageButton.Enabled := true
    else
      LanguageButton.Enabled := false;
  end;

  // Update ComponentsList changes
  if (CurPage = wpSelectComponents) then
  begin
    // Text adjustments for maintenanceMode
    if maintenanceMode then
    begin
      // Hide TypesCombo
      WizardForm.TypesCombo.Visible := False;
      WizardForm.IncTopDecHeight(WizardForm.ComponentsList, - (WizardForm.ComponentsList.Top - WizardForm.TypesCombo.Top));

      // "Install/Repair" page
      if installRadioBtn.Checked then
      begin
        // Text adjustments
        WizardForm.PageDescriptionLabel.Caption := CustomMessage('installPageDescriptionLabel');
        WizardForm.SelectComponentsLabel.Caption := CustomMessage('installSelectComponentsLabel');
        WizardForm.SelectComponentsLabel.Height := 40; // Default value
        WizardForm.ComponentsList.Top := 50; // Default value
        WizardForm.ComponentsList.Height := ScaleY(150);

        // Update the components title/desc Top pos
        CompTitle.Top := WizardForm.ComponentsList.Top + WizardForm.ComponentsList.Height - CompTitle.Height - ScaleY(-40);
        CompDescription.Top := CompTitle.Top + CompTitle.Height - ScaleY(20);
      end else if updateRadioBtn.Checked or updateMode then // "Update" page
      begin
        // Text adjustments
        WizardForm.PageDescriptionLabel.Caption := CustomMessage('updatePageDescriptionLabel');
        WizardForm.SelectComponentsLabel.Caption := CustomMessage('updateSelectComponentsLabel');
        WizardForm.SelectComponentsLabel.Height := 20;
        WizardForm.ComponentsList.Top := 30;
        WizardForm.ComponentsList.Height := ScaleY(170);

        // Gotta update the components title/desc Top pos as well
        CompTitle.Top := WizardForm.ComponentsList.Top + WizardForm.ComponentsList.Height - CompTitle.Height - ScaleY(-40);
        CompDescription.Top := CompTitle.Top + CompTitle.Height - ScaleY(20);
      end;

      // ComponentsList adjustments
      for i := 0 to GetArrayLength(WebCompsArray) - 1 do begin
        if not (WebCompsArray[i].id = 'setup_tool') then
        begin
          with Wizardform.ComponentsList do
          begin
            // Unchecked and enabled by default
            Checked[i - 1] := false;
            ItemEnabled[i - 1] := true;

            if updateRadioBtn.Checked or updateMode then // "Update" page
            begin
              Checked[i - 1] := isUpdateAvailable(WebCompsArray[i].Version, MaintenanceCompsArray[i].Version, MaintenanceCompsArray[i].isInstalled);
              ItemEnabled[i - 1] := isUpdateAvailable(WebCompsArray[i].Version, MaintenanceCompsArray[i].Version, MaintenanceCompsArray[i].isInstalled);
            end;
          end;
        end;
      end;
    end;
    update_ComponentsList();
  end;

  // Disable the run checkbox if the sh2pc files were not present when the installation directory was selected, and we're not in maintenance mode
  if (CurPage = wpFinished) and not maintenanceMode and not sh2pcFilesWerePresent then
  begin
    WizardForm.RunList.ItemEnabled[0] := False;
    WizardForm.RunList.Checked[0] := False;
    WizardForm.RunList.ItemCaption[0] := CustomMessage('StartGameAfterExiting') + ' (' + CustomMessage('UnavailableOption') + ')';
  end;

  // Check the run checkbox if the sh2pc files were present when the installation directory was selected, and we're not in maintenance mode
  if (CurPage = wpFinished) and not maintenanceMode and sh2pcFilesWerePresent then
  begin
    WizardForm.RunList.Checked[0] := true;
    RunListLastChecked := 0;
  end;

  // maintenanceMode's wpFinished tweaks
  if (CurPage = wpFinished) and maintenanceMode then
  begin
    sh2pcFilesExist := FileExists(AddBackslash(WizardDirValue) + 'data\pic\etc\konami.tex');

    // Check run box for updateMode
    if updateMode then
    begin
      WizardForm.RunList.Visible       := true;
      WizardForm.RunList.Checked[0]    := true;
      RunListLastChecked := 0;
    end else
    if installRadioBtn.Checked then
    begin
      // Change default labels to fit the install action
      WizardForm.FinishedLabel.Caption := CustomMessage('InstallSuccess');
      WizardForm.RunList.Visible       := true;
      WizardForm.RunList.Checked[0]    := true;
      RunListLastChecked := 0;
    end else
    if updateRadioBtn.Checked then
    begin
      // Change default labels to fit the update action
      WizardForm.FinishedHeadingLabel.Caption := CustomMessage('updateFinishedHeadingLabel');
      WizardForm.FinishedLabel.Caption        := CustomMessage('UpdateSuccess');
      WizardForm.RunList.Visible              := true;
      WizardForm.RunList.Checked[0]           := true;
      RunListLastChecked := 0;
    end else
    if uninstallRadioBtn.Checked then
    begin
      // Change default labels to fit the uninstaller action
      WizardForm.FinishedHeadingLabel.Caption := CustomMessage('uninstallFinishedHeadingLabel');
      WizardForm.FinishedLabel.Caption        := CustomMessage('UninstallSuccess');
      // Hide and uncheck the run checkbox when uninstalling
      WizardForm.RunList.Visible    := false;
      WizardForm.RunList.Checked[0] := false;
      WizardForm.RunList.Checked[1] := false;
    end;

    // Hide and uncheck the run checkbox if the data folder doesn't exist
    if not sh2pcFilesExist then
    begin
      WizardForm.RunList.Visible    := false;
      WizardForm.RunList.Checked[0] := false;
      WizardForm.RunList.Checked[1] := false;
    end;

    // Disable the run checkbox if the sh2pc.exe doesn't exist
    if not FileExists(ExpandConstant('{src}\') + 'sh2pc.exe') then
    begin
      WizardForm.RunList.ItemEnabled[0] := False;
      WizardForm.RunList.Checked[0] := False;
      WizardForm.RunList.ItemCaption[0] := CustomMessage('StartGameAfterExiting') + ' (' + CustomMessage('UnavailableOption') + ')';
    end;
  end;
end;
