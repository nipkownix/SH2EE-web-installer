; -- SH2EE Web Installer --

#define INSTALLER_VER  "1.0"
#define DEBUG          "false"
#define SH2EE_CSV_URL  "http://etc.townofsilenthill.com/sandbox/ee_itmp/_sh2ee.csv"
#define HELP_URL       "https://github.com/elishacloud/Silent-Hill-2-Enhancements/issues"
#define LOCAL_REPO     "D:\Porgrams\git_repos\SH2EE-web-installer\"

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
LicenseFile=resources\license.rtf
WizardImageFile=resources\side.bmp
WizardSmallImageFile=resources\top.bmp
WizardImageAlphaFormat=premultiplied
VersionInfoVersion={#INSTALLER_VER}
VersionInfoCompany=nipkow
VersionInfoDescription=Silent Hill 2: Enhanced Edition Web Installer
VersionInfoTextVersion={#INSTALLER_VER}

[Types]
Name: full; Description: Full installation (Recommended)
Name: custom; Description: Custom installation; Flags: iscustom

[Components]
; *** component name MUST match the component "id" in _sh2ee.csv! ***
Name: sh2emodule;    Description: SH2 Enhancements Module;          Types: full custom
Name: ee_exe;        Description: Enhanced Executable;              Types: full custom
Name: ee_essentials; Description: Enhanced Edition Essential Files; Types: full
Name: img_pack;      Description: Image Enhancement Pack;           Types: full
Name: fmv_pack;      Description: FMV Enhancement Pack;             Types: full
Name: audio_pack;    Description: Audio Enhancement Pack;           Types: full
Name: dsoal;         Description: DSOAL;                            Types: full
Name: xinput_plus;   Description: XInput Plus;                      Types: full

[Files]
; Tools below
Source: "includes\7zip\7za_x86.exe"; Flags: dontcopy
Source: "includes\7zip\7za_x64.exe"; Flags: dontcopy
Source: "includes\cmdlinerunner\cmdlinerunner.dll"; Flags: dontcopy
Source: "includes\BytesToString\BytesToString.dll"; Flags: dontcopy
Source: "includes\deletefile_util\deletefile_util.exe"; Flags: dontcopy
Source: "includes\renamefile_util\renamefile_util.exe"; Flags: dontcopy
//Source: "includes\unshield\unshield.exe"; Flags: dontcopy
Source: "{srcexe}"; DestDir: "{tmp}"; DestName: "SH2EEsetup.exe"; Flags: external 
Source: "resources\maintenance\icon_install.bmp"; Flags: dontcopy
Source: "resources\maintenance\icon_update.bmp"; Flags: dontcopy
Source: "resources\maintenance\icon_uninstall.bmp"; Flags: dontcopy
[Icons]
//Name: "{commondesktop}\Silent Hill 2 Enhanced Edition"; Filename: "{app}\sh2pc.exe"; Tasks: add_desktopicon

[Tasks]
//Name: add_desktopicon; Description: Create a &Desktop shortcut for the game; GroupDescription: Additional Icons:; Components: sh2emodule

[Run]
Filename: "{app}\sh2pc.exe"; Description: Start Silent Hill 2 after finishing the wizard; Flags: nowait postinstall skipifsilent unchecked

[CustomMessages]
HelpButton=Help

[Messages]
StatusExtractFiles=Placing files...
WelcomeLabel1=[name] Installation Wizard
SelectDirLabel3=[name] must be installed in the same folder as Silent Hill 2 PC. Please specify the directory where Silent Hill 2 PC is located.
WizardSelectComponents=Select Enhancement Packages
SelectComponentsDesc=Please select which enhancement packages you would like to install. 
SelectComponentsLabel2=Silent Hill 2: Enhanced Edition is comprised of several enhancement packages. Select which enhancement packages you wish to install. For the full, intended experience, install all enhancement packages. 
FinishedHeadingLabel=Installation Complete!
ExitSetupMessage=Are you sure you want to close the wizard?

// Seems IDP must be included before [Code]
#include "includes/innosetup-download-plugin/idp.iss"

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
  maintenanceMode : Boolean;
  updateMode      : Boolean;
  selfUpdateMode  : Boolean;
  CurIniArray     : array of TIniArray;
  FileSizeArray   : array of TSizeArray;
  sh2pcFilesWerePresent : Boolean;

#include "includes/Extractore.iss"
#include "includes/Util.iss"
#include "CustomUninstall.iss"
#include "wpMaintenance.iss"
#include "CSVparser.iss"
#include "CustomLabels.iss"
#include "SelfUpdate.iss"
#include "wpSelectComponents.iss"
#include "wpExtract.iss"

// Runs before anything else
function InitializeSetup(): Boolean;
var i: integer;
begin
  Result := True;

  // Store the path to sh2ee.csv in a global variable
  if not {#DEBUG} then
    CSVFilePath := tmp(GetURLFilePart('{#SH2EE_CSV_URL}'))
  else
    CSVFilePath := '{#LOCAL_REPO}' + 'testfiles\_sh2ee.csv';

  // Download sh2ee.csv; show an error message and exit the installer if downloading fails
  if not {#DEBUG} and not idpDownloadFile('{#SH2EE_CSV_URL}', CSVFilePath) then
  begin
    MsgBox('Error: Download Failed' #13#13 'Couldn''t download sh2ee.csv.' #13#13 'The installation cannot continue.', mbCriticalError, MB_OK);
    Result := False;
    exit;
  end;

  // Create an array of TWebComponentsInfo records from sh2ee.csv and store them in a global variable
  WebCompsArray := WebCSVToInfoArray(CSVFilePath);
  // Check if above didn't work
  if GetArrayLength(WebCompsArray) = 0 then
  begin
    MsgBox('Error: Parsing Failed' #13#13 'Couldn''t parse sh2ee.csv.' #13#13 'The installation cannot continue.', mbCriticalError, MB_OK);
    Result := False;
    exit;
  end;

  // Determine weather or not we should be in "maintenance mode"
  if FileExists(ExpandConstant('{src}\') + 'sh2pc.exe') and FileExists(ExpandConstant('{src}\') + 'SH2EEsetup.dat') then
  begin
    maintenanceMode := True;

    // Create an array of TWebComponentsInfo records from the existing SH2EEsetup.dat and store it in a global variable
    LocalCompsArray := LocalCSVToInfoArray(ExpandConstant('{src}\SH2EEsetup.dat'));

    // Check if above didn't work
    if GetArrayLength(WebCompsArray) = 0 then
    begin
      MsgBox('Error: Parsing Failed' #13#13 'Couldn''t parse SH2EEsetup.dat.' #13#13 'The installation cannot continue.', mbCriticalError, MB_OK);
      Result := False;
      exit;
    end;

    // Update and reload local CSV if array sizes are different
    if not SamePackedVersion(GetArrayLength(LocalCompsArray), GetArrayLength(WebCompsArray)) then // [2] Using SamePackedVersion() to compare lengths isn't the fanciest approach, but it works
    begin
      UpdateLocalCSV(true);
      LocalCompsArray := LocalCSVToInfoArray(ExpandConstant('{src}\SH2EEsetup.dat'));
    end;

    // Update and reload local CSV if the order of ids don't match  
    for i := 0 to GetArrayLength(WebCompsArray) - 1 do
    begin
      if not SameText(LocalCompsArray[i].id, WebCompsArray[i].id) then
        UpdateLocalCSV(true);
        LocalCompsArray := LocalCSVToInfoArray(ExpandConstant('{src}\SH2EEsetup.dat'));
    end;
  end;

  // Enable Update if started with argument
  if CmdLineParamExists('-update') and maintenanceMode then
  begin
    updateMode := True;
  end;

  // Enable selfUpdate if started with argument
  if CmdLineParamExists('-selfUpdate') and maintenanceMode then
  begin
    selfUpdateMode := True;
  end;

  // Check if the installer should work correctly with with the current server-side files
  if not selfUpdateMode then
  begin
    for i := 0 to GetArrayLength(WebCompsArray) - 1 do begin
      if WebCompsArray[i].id = 'setup_tool' then
      begin
        if not SameText(WebCompsArray[i].version, ExpandConstant('{#INSTALLER_VER}')) then
        begin
          if MsgBox('Error: Outdated Version' #13#13 'The SH2:EE Setup Tool must be updated in order to use.' #13#13 'Update the Setup Tool?', mbConfirmation, MB_YESNO) = IDYES then
          begin
            selfUpdateMode := True;
          end else
          begin
            Result := False;
            exit;
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

procedure InitializeWizard();
var
  HelpButton : TButton;
  DebugLabel : TNewStaticText;
  i: integer;
begin
  // Compare the lenght of the web CSV array with the installer's component list
  if not SamePackedVersion(WizardForm.ComponentsList.Items.Count, GetArrayLength(WebCompsArray) - 1) then // Using SamePackedVersion() to compare lengths isn't the fanciest approach, but it works
  begin
    MsgBox('Error: Invalid Components List Size' #13#13 'The installer should be updated to handle the new components from sh2ee.csv.', mbCriticalError, MB_OK);
    Abort;
  end;

  // Replace some normal labels with RTF equivalents if not in maintenance mode
  if not maintenanceMode then
    create_RTFlabels();

  // IDP settings
  idpSetOption('AllowContinue',  '1');
  idpSetOption('DetailsVisible', '1');
  idpSetOption('DetailsButton',  '1');
  idpSetOption('RetryButton',    '1');
  idpSetOption('UserAgent',      'SH2 EE web installer');
  idpSetOption('InvalidCert',    'ignore');

  // Get file sizes from host, exit if we fail for some reason
  SetArrayLength(FileSizeArray, GetArrayLength(WebCompsArray) - 1);
  for i := 0 to GetArrayLength(WebCompsArray) - 1 do
  begin
      if not (WebCompsArray[i].id = 'setup_tool') then
      begin  
        if not idpGetFileSize(WebCompsArray[i].URL, FileSizeArray[i - 1].Bytes) then
          begin
            MsgBox('Error: Files unavailable' #13#13 'Failed to query for one or more components.' #13#13 'The installation cannot continue. Please try again, and if the issue persists, report it to the developers.', mbCriticalError, MB_OK);
            ExitProcess(1);
          end;
        FileSizeArray[i - 1].String := BytesToString(FileSizeArray[i - 1].Bytes);
        if {#DEBUG} then Log('# ' + WebCompsArray[i].ID + ' size = ' + FileSizeArray[i - 1].String);
      end;
  end;

  // Register new OnClick event
  ComponentsListClickCheckPrev := WizardForm.ComponentsList.OnClickCheck;
  WizardForm.ComponentsList.OnClickCheck := @NewComponentsListClickCheck;
  
  // Register new OnChange event
  TypesComboOnChangePrev := WizardForm.TypesCombo.OnChange;
  WizardForm.TypesCombo.OnChange := @NewTypesComboOnChange;

  // Start the download after wpReady
  idpDownloadAfter(wpReady);
  
  // "Install/Update/Uninstall", etc
  if maintenanceMode then
    PrepareMaintenance();
  
  // Updates the setup tool itself  
  if selfUpdateMode then
    PrepareSelfUpdate();

  // Create the file extraction page
  create_wpExtract();

  // Force installation of the SH2E module and EE exe if not in maintenance mode
  if not maintenanceMode then
  begin
    WizardForm.ComponentsList.Checked[0] := true;
    WizardForm.ComponentsList.Checked[1] := true;
    WizardForm.ComponentsList.ItemEnabled[0] := false;
    WizardForm.ComponentsList.ItemEnabled[1] := false;
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
      Caption    := ExpandConstant('{cm:HelpButton}');
      Cursor     := crHelp;
      Font.Color := clHighlight;
      OnClick    := @HelpButtonClick;
      Parent     := WizardForm;
  end;

  // Show "DEBUG ON" text
  if {#DEBUG} then
  begin
    DebugLabel := TNewStaticText.Create(WizardForm);
    with DebugLabel do
    begin
        Top        := HelpButton.Top + 4;
        Anchors    := [akLeft, akBottom];
        Left       := HelpButton.Left + HelpButton.Width + 10;
        Caption    := ExpandConstant('DEBUG ON');
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
    if (CurPage = wpMaintenance.ID) or
       (CurPage = wpSelectComponents) or
       (CurPage = wpExtract.ID) or
       (CurPage = wpFinished) then
    begin
      Result := True;
    end;
  end;

  // Skip wpSelectComponents if uninstalling
  if maintenanceMode and not selfUpdateMode then
  begin
    if (CurPage = wpSelectComponents) or
       (CurPage = wpExtract.ID) then
          if uninstallRadioBtn.Checked then
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
      MsgBox('Error:' #13#13 'No componentes are selected.', mbInformation, MB_OK);
      Result := False;
      exit;
    end;

    // Check if we have enough free space
    iRequiredSize := iTotalCompSize * 2;
    if not IsEnoughFreeSpace(ExtractFileDrive(WizardDirValue), iRequiredSize) then
    begin
      MsgBox('Error: Not enough free space!' #13#13 'The installation requires at least double the total size of components (' + BytesToString(iRequiredSize) + ') to be completed safely.' #13#13 'Please free some space and try again.', mbCriticalError, MB_OK);
      ExitProcess(666);
    end;
  
    // Add files to IDP
    iTotalCompCount := 0; // Clear list
    idpClearFiles(); // Make sure idp file list is clean
    for i := 0 to WizardForm.ComponentsList.Items.Count - 1 do
    begin
      if WizardForm.ComponentsList.Checked[i] then
      begin
        iTotalCompCount := iTotalCompCount + 1;
        idpAddFile(WebCompsArray[i + 1].URL, tmp(GetURLFilePart(WebCompsArray[i + 1].URL)));
      end;
    end;

    selectedComponents := WizardSelectedComponents(false);  
    Log('# The following [' + IntToStr(iTotalCompCount) + '] components are selected: ' + selectedComponents);
  end;


  // Check for file presence in WizardDirValue
  if CurPage = wpSelectDir then
  begin
    if not FileExists(AddBackslash(WizardDirValue) + 'sh2pc.exe') or not DirExists(AddBackslash(WizardDirValue) + 'data') then 
    begin 
      if MsgBox('The selected folder may not be where Silent Hill 2 PC is located.' #13#13 'Proceed anyway?', mbConfirmation, MB_YESNO) = IDYES then
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
      MsgBox('Error: Invalid path detected' #13#13 'The chosen directory name contains a semicolon.' #13#13 'This breaks the game. Please rename the game''s directory before continuing.', mbInformation, MB_OK);
      Result := False;
    end;
  end;
end;

procedure postInstall();
var
  intErrorCode: Integer;
  ShouldUpdate: Boolean;
  i: Integer;
  webInstallerChecksum: String;
begin
  // Update local CSV file after installation
  if maintenanceMode then
  begin 
    if not uninstallRadioBtn.Checked then
      UpdateLocalCSV(false);
  end else
  if not maintenanceMode then
    UpdateLocalCSV(false);

  if selfUpdateMode then
  begin
    // Check for the newly downloaded .exe checksum
    if not (WebCompsArray[0].SHA256 = 'notUsed') then
    begin
      webInstallerChecksum := GetSHA256OfFile(tmp(GetURLFilePart(WebCompsArray[0].URL)));
  
      Log('# ' + WebCompsArray[0].name + ' - Checksum (from .csv): ' + WebCompsArray[i].SHA256);
      Log('# ' + WebCompsArray[0].name + ' - Checksum (temp file): ' + webInstallerChecksum);
  
      if not SameText(webInstallerChecksum, WebCompsArray[0].SHA256) then
      begin
        MsgBox('Error: Checksum mismatch' #13#13 'The downloaded "SH2EEsetup" is corrupted.' #13#13 'The installation cannot continue. Please try again, and if the issue persists, report it to the developers.', mbInformation, MB_OK);
        ExitProcess(1);
      end;
    end; 

    // Check if there's an update available for any component
    for i := 0 to GetArrayLength(WebCompsArray) - 1 do begin
      if not (WebCompsArray[i].id = 'setup_tool') then
      begin
        if isUpdateAvailable(WebCompsArray[i].Version, LocalCompsArray[i].Version, LocalCompsArray[i].isInstalled) then
          ShouldUpdate := True;
      end;
    end;

    // Schedule SH2EEsetup_new.exe for renaming as soon as possible
    if not ShouldUpdate and CmdLineParamExists('-selfUpdate') then
    begin
      // Don't reopen the setup tool if launched with the -selfUpdate parameter and there's no update available
      ShellExec('', ExpandConstant('{tmp}\') + 'renamefile_util.exe', AddQuotes(ExpandConstant('{srcexe}')) + ' false false', '', SW_HIDE, ewNoWait, intErrorCode);
      // Reopen the game
      ShellExec('', ExpandConstant('{src}\') + 'sh2pc.exe', '', '', SW_SHOW, ewNoWait, intErrorCode);
    end
    else
    if ShouldUpdate and CmdLineParamExists('-selfUpdate') then 
      // Open the updater page after renaming
      ShellExec('', ExpandConstant('{tmp}\') + 'renamefile_util.exe', AddQuotes(ExpandConstant('{srcexe}')) + ' true true', '', SW_HIDE, ewNoWait, intErrorCode)
    else
      // Don't open the updater page after renaming
      ShellExec('', ExpandConstant('{tmp}\') + 'renamefile_util.exe', AddQuotes(ExpandConstant('{srcexe}')) + ' true false', '', SW_HIDE, ewNoWait, intErrorCode);
  end;

  // Copy SH2EEsetup.exe to the game's directory if we're not currently running from it
  if not FileExists(ExpandConstant('{src}\') + 'sh2pc.exe') and not FileExists(ExpandConstant('{src}\') + 'SH2EEsetup.dat') then
    FileCopy(ExpandConstant('{tmp}\SH2EEsetup.exe'), ExpandConstant('{app}\SH2EEsetup.exe'), false);
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
  // Customize wpSelectComponents
  if (CurPage = wpSelectComponents) then
  begin
    if maintenanceMode then
      begin
        // Hide TypesCombo 
        WizardForm.TypesCombo.Visible := False;
        WizardForm.IncTopDecHeight(WizardForm.ComponentsList, - (WizardForm.ComponentsList.Top - WizardForm.TypesCombo.Top));
    
        // "Install/Repair" page
        if installRadioBtn.Checked then
        begin
          // Text adjustments
          WizardForm.PageDescriptionLabel.Caption := 'Please select which enhancement packages you would like to install or repair.';
          WizardForm.SelectComponentsLabel.Caption := 'Silent Hill 2: Enhanced Edition is comprised of several enhancement packages. Select which enhancement packages you wish to install. For the full, intended experience, install all enhancement packages.'
          WizardForm.SelectComponentsLabel.Height := 40; // Default value
          WizardForm.ComponentsList.Top := 50; // Default value
          WizardForm.ComponentsList.Height := ScaleY(150);
      
          // Update the components title/desc Top pos
          CompTitle.Top := WizardForm.ComponentsList.Top + WizardForm.ComponentsList.Height - CompTitle.Height - ScaleY(-40);
          CompDescription.Top := CompTitle.Top + CompTitle.Height - ScaleY(20);
        end else if updateRadioBtn.Checked then // "Update" page
        begin
          // Text adjustments
          WizardForm.PageDescriptionLabel.Caption := 'Please select which enhancement packages you would like to update.'
          WizardForm.SelectComponentsLabel.Caption := 'Updates will be listed below if available.'
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
  
              if updateRadioBtn.Checked then // "Update" page
              begin
                Checked[i - 1] := isUpdateAvailable(WebCompsArray[i].Version, LocalCompsArray[i].Version, LocalCompsArray[i].isInstalled);
                ItemEnabled[i - 1] := isUpdateAvailable(WebCompsArray[i].Version, LocalCompsArray[i].Version, LocalCompsArray[i].isInstalled);
              end;
            end;
          end;
        end;
      end;
    // Customize ComponentsList
    custom_ComponentsList();
  end;

  // Hide the run checkbox if the sh2pc files were present when the installation directory was selected, and we're not in maintenance mode 
  if (CurPage = wpFinished) and not maintenanceMode and not sh2pcFilesWerePresent then
  begin
    WizardForm.RunList.Visible := false;
  end;

  // Check the run checkbox if the sh2pc files were present when the installation directory was selected, and we're not in maintenance mode 
  if (CurPage = wpFinished) and not maintenanceMode and sh2pcFilesWerePresent then
  begin
    WizardForm.RunList.Checked[0] := true;
  end;

  // maintenanceMode's wpFinished tweaks
  if (CurPage = wpFinished) and maintenanceMode then 
  begin
    sh2pcFilesExist := DirExists(AddBackslash(WizardDirValue) + 'data');

    if installRadioBtn.Checked then
    begin
      // Change default labels to fit the install action
      WizardForm.FinishedLabel.Caption := 'The wizard has successfully installed the selected enhancement packages.' #13#13 'Click finish to exit the wizard.';
      WizardForm.RunList.Visible       := true;
      WizardForm.RunList.Checked[0]    := true;
    end else
    if updateRadioBtn.Checked then
    begin
      // Change default labels to fit the update action
      WizardForm.FinishedHeadingLabel.Caption := 'Update complete!';
      WizardForm.FinishedLabel.Caption        := 'The wizard has successfully updated the selected enhancement packages.' #13#13 'Click finish to exit the wizard.';
      WizardForm.RunList.Visible              := true;
      WizardForm.RunList.Checked[0]           := true;
    end else 
    if uninstallRadioBtn.Checked then
    begin
      // Change default labels to fit the uninstaller action
      WizardForm.FinishedHeadingLabel.Caption := 'Uninstallation complete.';
      WizardForm.FinishedLabel.Caption        := 'The wizard has successfully uninstalled the enhancement packages.' #13#13 'Click finish to exit the wizard.';
      // Hide and uncheck the run checkbox when uninstalling
      WizardForm.RunList.Visible    := false;
      WizardForm.RunList.Checked[0] := false;
    end;

    // Hide and uncheck the run checkbox if the data folder doesn't exist
    if not sh2pcFilesExist then
    begin
      WizardForm.RunList.Visible    := false;
      WizardForm.RunList.Checked[0] := false;
    end;
  end;
end;