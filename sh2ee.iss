; -- Prototype SH2EE Online Installer --

#define INSTALLER_VER  "1.0"
#define DEBUG          "false"
#define SH2EE_CSV_URL  "http://etc.townofsilenthill.com/sandbox/ee_itmp/sh2ee.csv"

#include "includes\innosetup-download-plugin\idp.iss"

[Setup]
AppName=Silent Hill 2: Enhanced Edition
AppVersion={#INSTALLER_VER}
WizardStyle=modern
DefaultDirName={code:GetDefaultDirName}  
UninstallDisplayIcon={app}\sh2.ico
OutputDir=build
OutputBaseFilename=SH2EEinstaller
DirExistsWarning=no
DisableWelcomePage=False
RestartIfNeededByRun=False
AppendDefaultDirName=False
DisableProgramGroupPage=Yes
UsePreviousTasks=no
UsePreviousSetupType=no
UsePreviousAppDir=no
RestartApplications=False
UninstallDisplayName=Silent Hill 2: Enhanced Edition
DisableDirPage=no
ShowLanguageDialog=no
WizardResizable=True
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
Name: minimal; Description: Minimal installation (Not recommended)
Name: custom; Description: Custom installation; Flags: iscustom

[Components]
Name: sh2emodule; Description: SH2 Enhancements Module; ExtraDiskSpaceRequired: 4174272; Types: full minimal custom; Flags: fixed
Name: ee_exe; Description: Enhanced Executable; ExtraDiskSpaceRequired: 5459968; Types: full minimal custom; Flags: fixed
Name: ee_essentials; Description: Enhanced Edition Essential Files; ExtraDiskSpaceRequired: 288792943; Types: full
Name: img_pack; Description: Image Enhancement Pack; ExtraDiskSpaceRequired: 1229057424; Types: full
Name: fmv_pack; Description: FMV Enhancement Pack; ExtraDiskSpaceRequired: 3427749254; Types: full
Name: audio_pack; Description: Audio Enhancement Pack; ExtraDiskSpaceRequired: 2487799726; Types: full
Name: dsoal; Description: DSOAL; ExtraDiskSpaceRequired: 2217690; Types: full
Name: xinput_plus; Description: XInput Plus; ExtraDiskSpaceRequired: 941770; Types: full

[Files]
; Extraction tools bellow
Source: "includes\7zip\7za.exe"; Flags: dontcopy
Source: "includes\cmdlinerunner\cmdlinerunner.dll"; Flags: dontcopy
//Source: "includes\unshield\unshield.exe"; Flags: dontcopy
Source: "{srcexe}"; DestDir: "{app}"; DestName: "SH2EEupdater.exe"; Flags: external replacesameversion
Source: "includes\SH2EEupdater.dat"; Flags: dontcopy

[Icons]
//Name: "{commondesktop}\Silent Hill 2 Enhanced Edition"; Filename: "{app}\sh2pc.exe"; Tasks: add_desktopicon

[Tasks]
//Name: add_desktopicon; Description: Create a &Desktop shortcut for the game; GroupDescription: Additional Icons:; Components: sh2emodule

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

[UninstallDelete]
Type: filesandordirs; Name: "{app}\sh2e";
Type: files; Name: "{app}\alsoft.ini";
Type: files; Name: "{app}\d3d8.dll";
Type: files; Name: "{app}\d3d8.ini";
Type: files; Name: "{app}\d3d8.res";
Type: files; Name: "{app}\Dinput.dll";
Type: files; Name: "{app}\Dinput8.dll";
Type: files; Name: "{app}\dsoal-aldrv.dll";
Type: files; Name: "{app}\dsound.dll";
Type: files; Name: "{app}\keyconf.dat";
Type: files; Name: "{app}\local.fix";
Type: files; Name: "{app}\SH2EEupdater.dat";
Type: files; Name: "{app}\sh2pc.exe";
Type: files; Name: "{app}\XInput1_3.dll";
Type: files; Name: "{app}\XInputPlus.ini";

[Code]
var
  updaterMode: Boolean;

#include "includes/Extractore.iss"
#include "includes/Util.iss"

var
  wpUpdaterPage                 : TInputOptionWizardPage;
  wpUpdaterComponentList        : String;
  LocalCompsArray               : array of TLocalComponentsInfo;

  wpExtractPage                 : TWizardPage;
  intTotalComponents            : Integer;
  selectedComponents            : String;
  intInstalledComponentsCounter : Integer;
  ExtractoreListBox             : TNewListBox;
  CurrentComponentProgressBar   : TNewProgressBar;

  CSVFilePath                   : String;
  WebCompsArray                 : array of TWebComponentsInfo;


procedure create_RTFlabels;
var
  WelcomeLabel2_RTF: TRichEditViewer;
  FinishedLabel_RTF: TRichEditViewer;
begin
  WelcomeLabel2_RTF := TRichEditViewer.Create(WizardForm);
  with WelcomeLabel2_RTF do
  begin
      Left          := WizardForm.WelcomeLabel2.Left;
      Top           := WizardForm.WelcomeLabel2.Top;
      Width         := WizardForm.WelcomeLabel2.Width;
      Height        := WizardForm.WelcomeLabel2.Height;
      Parent        := WizardForm.WelcomeLabel2.Parent;
      BorderStyle   := bsNone;
      TabStop       := False;
      ReadOnly      := True;
      WizardForm.WelcomeLabel2.Visible := False;
      RTFText :=
          '{\rtf1 This wizard will guide you through installing Silent Hill 2: Enhanced Edition for use with Silent Hill 2 PC.\par' +
          '\par\b Note: This wizard does not include a copy of Silent Hill 2 PC.\b0\par' +
          '\par You must install your own copy of Silent Hill 2 PC in order to use Silent Hill 2: Enhanced Edition.\par' +
          '\par\b You should install Silent Hill 2 PC before running this wizard.\par\b0' +
          '\par Click Next to continue, or Cancel to exit this wizard.}';
  end;

  FinishedLabel_RTF := TRichEditViewer.Create(WizardForm);
  with FinishedLabel_RTF do
  begin
      Left          := WizardForm.FinishedLabel.Left;
      Top           := WizardForm.FinishedLabel.Top;
      Width         := WizardForm.FinishedLabel.Width;
      Height        := WizardForm.FinishedLabel.Height + ScaleY(250);
      Parent        := WizardForm.FinishedLabel.Parent;
      BorderStyle   := bsNone;
      TabStop       := False;
      ReadOnly      := True;
      WizardForm.FinishedLabel.Visible := False;
      RTFText :=
          '{\rtf1 The wizard has successfully installed the selected enhancement packages.\par' +
          '\par If you correctly selected the Silent Hill 2 PC folder at the start of this wizard, Silent Hill 2: Enhanced Edition will automatically run the next time you launch the game.\par' +
          '\par \b Useful links:\b0\par' +
          '\pard\sa50\par {\field{\*\fldinst HYPERLINK "http://enhanced.townofsilenthill.com/SH2/"}{\fldrslt Project Website}}\par' +
          '\pard\li450 Silent Hill 2: Enhanced Edition project website.\par' +
          '\pard\sa50\par {\field{\*\fldinst HYPERLINK "http://enhanced.townofsilenthill.com/SH2/troubleshoot.htm"}{\fldrslt Troubleshooting Page}}\par' +
          '\pard\li450 This page has common troubleshooting tips.\par' +
          '\pard\sa50\par {\field{\*\fldinst HYPERLINK "https://github.com/elishacloud/Silent-Hill-2-Enhancements/"}{\fldrslt GitHub Project Page}}\par' +
          '\pard\li450\ You can open a support ticket here for help.\par}';
  end;
end;
  
procedure wpExtractCancelButtonClick(Page: TWizardPage; var Cancel, Confirm: Boolean);
begin
    if ExitSetupMsgBox then
    begin
        WizardForm.Repaint;
        ExtractionCancel := true;
        ProcEnd(extProcHandle);
        Cancel  := true;
        Confirm := false;
    end
    else begin
        Cancel := false;
    end;
end;

procedure create_wpExtract;
var
  TotalProgressBar                : TNewProgressBar;
  TotalProgressLabel              : TLabel;
  TotalProgressStaticText         : TNewStaticText;

  CurrentComponentLabel           : TLabel;
  CurrentComponentStaticText      : TNewStaticText;
begin
  // wpExtract shown after the IDPForm page
  wpExtractPage := CreateCustomPage(IDPForm.Page.ID, 'Extracting compressed components', 'Please wait while Setup extracts components.');

  // Progress bars
  TotalProgressStaticText := TNewStaticText.Create(wpExtractPage);
  with TotalProgressStaticText do
  begin
      Parent    := wpExtractPage.Surface;
      Caption   := 'Total Progress';
      Left      := ScaleX(0);
      Top       := ScaleY(0);
      AutoSize  := False;
      TabOrder  := 1;
  end;

  TotalProgressBar := TNewProgressBar.Create(wpExtractPage);
  with TotalProgressBar do
  begin
      Name      := 'TotalProgressBar';
      Parent    := wpExtractPage.Surface;
      Left      := ScaleX(0);
      Top       := ScaleY(16);
      Width     := wpExtractPage.SurfaceWidth - TotalProgressBar.Left;
      Height    := ScaleY(20);
      Anchors   := [akLeft, akTop, akRight];
      Min       := -1;
      Position  := -1
      Max       := 100;
  end;

  TotalProgressLabel := TLabel.Create(wpExtractPage);
  with TotalProgressLabel do
  begin
      Name        := 'TotalProgressLabel';
      Parent      := wpExtractPage.Surface;
      Caption     := '--/--';
      Font.Style  := [fsBold];
      Alignment   := taRightJustify;
      Left        := TotalProgressBar.Width - ScaleX(120);
      Top         := ScaleY(0);
      Width       := ScaleX(120);
      Height      := ScaleY(14);
      Anchors     := [akLeft, akTop, akRight];
      AutoSize    := False;
  end;

  CurrentComponentStaticText := TNewStaticText.Create(wpExtractPage);
  with CurrentComponentStaticText do
  begin
      Parent    := wpExtractPage.Surface;
      Caption   := 'Extracting Component';
      Left      := ScaleX(0);
      Top       := ScaleY(48);
      Width     := ScaleX(200);
      Height    := ScaleY(14);
      AutoSize  := False;
      TabOrder  := 2;
  end;

  CurrentComponentProgressBar := TNewProgressBar.Create(wpExtractPage);
  with CurrentComponentProgressBar do
  begin
      Name      := 'CurrentComponentProgressBar';
      Parent    := wpExtractPage.Surface;
      Left      := ScaleX(0);
      Top       := ScaleY(64);
      Width     := wpExtractPage.SurfaceWidth - CurrentComponentProgressBar.Left;
      Height    := ScaleY(20);
      Anchors   := [akLeft, akTop, akRight];
      Min       := 0;
      Max       := 100;
      //Style   := npbstMarquee;
  end;

  CurrentComponentLabel := TLabel.Create(wpExtractPage);
  with CurrentComponentLabel do
  begin
      Name        := 'CurrentComponentLabel';
      Parent      := wpExtractPage.Surface;
      Caption     := '';
      Alignment   := taRightJustify;
      Font.Style  := [fsBold];
      Left        := CurrentComponentProgressBar.Width - ScaleX(320);
      Top         := ScaleY(48);
      Width       := ScaleX(320);
      Height      := ScaleY(14);
      Anchors     := [akLeft, akTop, akRight];
      AutoSize    := False;
  end;

  ExtractoreListBox := TNewListBox.Create(wpExtractPage);
  with ExtractoreListBox do
  begin
      Parent      := wpExtractPage.Surface;
      Left        := CurrentComponentProgressBar.Left;
      Top         := CurrentComponentProgressBar.Top + ScaleY(40);
      Width       := CurrentComponentProgressBar.Width;
      Height      := wpExtractPage.SurfaceHeight - ExtractoreListBox.Top - ScaleY(10);
      Anchors     := [akLeft, akTop, akRight, akBottom];
      Items.Clear();
  end;

  with wpExtractPage do
  begin
      OnCancelButtonClick := @wpExtractCancelButtonClick;
  end;
end;

// Helper to populate the updater's CheckListBox's labels
function VersionLabel(OnlineVer: String; ExistVer: String; isInstalled: Boolean): String;
begin
  if isInstalled = true then
  begin
    if SameText(OnlineVer, ExistVer) then
      Result := 'No update available'
    else
      Result := 'New version available: ' + OnlineVer
  end else 
    Result := 'Component not installed'
end;

// Decides whether or not the component is available for the update
function isChecked(OnlineVer: String; ExistVer: String; isInstalled: Boolean): Boolean;
begin
  if isInstalled = true then
  begin
    if SameText(OnlineVer, ExistVer) then
      Result := false
    else
      Result := true
  end else 
    Result := false
end;

// Actually creates the updater page
procedure PrepareUpdater();
var
  i: Integer;
begin
  // Create custom update selection page. It is the first page shown if updaterMode is enabled
  wpUpdaterPage := CreateInputOptionPage(
    wpWelcome,
    'Silent Hill 2: Enhanced Edition Update Wizard',
    'Setup will download and install the updated components you select.',
    'Updates will be listed below if available.',
    False, True);

  // Use both the local and web arrays to check and populate the update listbox
  for i := 0 to GetArrayLength(WebCompsArray) - 1 do begin
    with WebCompsArray[i] do begin
      wpUpdaterPage.CheckListBox.AddCheckBox(
        Name, // Label next to checkbox
        VersionLabel(WebCompsArray[i].Version, LocalCompsArray[i].Version, LocalCompsArray[i].isInstalled),  // Label right-justified in list box
        0,
        isChecked(WebCompsArray[i].Version, LocalCompsArray[i].Version, LocalCompsArray[i].isInstalled), // If new version is detected, automatically check the item
        True,
        False,
        False,
        Nil);
    end;
  end;
end;

procedure HelpButtonClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('open', 'http://www.enhanced.townofsilenthill.com/SH2/install.htm', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;

  if updaterMode = true then
  begin
    if (PageID = wpWelcome) or
       (PageID = wpLicense) or
       (PageID = wpSelectDir) or
       (PageID = wpSelectComponents) or
       (PageID = wpReady) then
    begin
      Result := True;
    end;
  end;
end;

procedure InitializeWizard();
var
  HelpButton    : TButton;
  DebugLabel    : TNewStaticText;
begin
  // Replace some normal labels with RTF equivalents
  create_RTFlabels();

  // IDP settings
  idpSetOption('AllowContinue',  '1');
  idpSetOption('DetailsVisible', '1');
  idpSetOption('DetailsButton',  '1');
  idpSetOption('RetryButton',    '1');
  idpSetOption('UserAgent',      'sh2ee web installer');
  idpSetOption('InvalidCert',    'ignore');

  // Start the download after wpReady
  idpDownloadAfter(wpReady);

  idpClearFiles();
  
  if updaterMode = true then
  begin
    PrepareUpdater();
    idpDownloadAfter(wpUpdaterPage.ID);
  end;

  // Create the wpExtract page
  create_wpExtract();

  if not updaterMode = true then
    SetTimer(0, 0, 50, CreateCallback(@HoverTimerProc));

  CompTitle := TLabel.Create(WizardForm);
  with CompTitle do
  begin
      Caption     := '';
      Font.Style  := [fsBold];
      Parent      := WizardForm.SelectComponentsPage;
      Left        := WizardForm.ComponentsList.Left;
      Width       := WizardForm.ComponentsList.Width;
      Height      := ScaleY(35);
      Top         := WizardForm.ComponentsList.Top + WizardForm.ComponentsList.Height - CompTitle.Height - ScaleY(25);
      Anchors     := [akLeft, akBottom];
      AutoSize    := False;
      WordWrap    := True;
  end;

  CompDescription := TLabel.Create(WizardForm);
  with CompDescription do
  begin
      Caption     := '';
      Parent      := WizardForm.SelectComponentsPage;
      Left        := WizardForm.ComponentsList.Left;
      Width       := WizardForm.ComponentsList.Width;
      Height      := ScaleY(60);
      Top         := CompTitle.Top + CompTitle.Height - ScaleY(20);
      Anchors     := [akLeft, akBottom];
      AutoSize    := False;
      WordWrap    := True;
  end;

  WizardForm.ComponentsList.Height := WizardForm.ComponentsList.Height - CompTitle.Height - ScaleY(30);


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

  if {#DEBUG} = true then
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

function InitializeSetup(): Boolean;
begin
  Result := True;
  // Store the path to sh2ee.csv in a global variable
  CSVFilePath := tmp(GetURLFilePart('{#SH2EE_CSV_URL}'));

  // Download sh2ee.csv; show an error message and exit the installer if downloading fails
  if not idpDownloadFile('{#SH2EE_CSV_URL}', CSVFilePath) then begin
    MsgBox('Error:' #13#13 'Downloading {#SH2EE_CSV_URL} failed.' #13#13 'The installation cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;

  // Create an array of TWebComponentsInfo records from sh2ee.csv and store them in a global variable
  WebCompsArray := WebCSVToInfoArray(CSVFilePath);
  // Check if above didn't work
  if GetArrayLength(WebCompsArray) = 0 then begin
    MsgBox('Error:' #13#13 'Parsing {#SH2EE_CSV_URL} failed.' #13#13 'The installation cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;

  // Check if the installer should work correctly with with the current server-side files
  if not SameText(WebCompsArray[0].ReqInstallerVersion, ExpandConstant('{#INSTALLER_VER}')) then
  begin
    MsgBox('Error:' #13#13 'This installer is outdated.' #13#13 'Please visit the official website and download an updated version.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;

  // Determine weather or not we should be in "updater mode"
  if FileExists(ExpandConstant('{src}\') + 'sh2pc.exe') and FileExists(ExpandConstant('{src}\') + 'SH2EEupdater.dat') then
  begin
    updaterMode := True;
    // Create an array of TWebComponentsInfo records from the existing SH2EEupdater.dat and store it in a global variable
    LocalCompsArray := LocalCSVToInfoArray(ExpandConstant('{src}\SH2EEupdater.dat'));
    // Check if above didn't work
    if GetArrayLength(LocalCompsArray) = 0 then begin
      MsgBox('Error:' #13#13 'Parsing SH2EEupdater.dat failed.' #13#13 'Please reinstall the project.', mbInformation, MB_OK);
      Result := False;
      exit;
    end;
  end;
end;

function NextButtonClick(CurPage: Integer): Boolean;
var
  i: Integer;
begin
  Result := True;

  if CurPage = wpSelectComponents then
  begin
    // Add files to IDP
    intTotalComponents := 0; // Clear list
    for i := 0 to WizardForm.ComponentsList.Items.Count - 1 do
    begin
      if WizardForm.ComponentsList.Checked[i] = true then
      begin
        intTotalComponents := intTotalComponents + 1;
        idpAddFile(WebCompsArray[i].URL, tmp(GetURLFilePart(WebCompsArray[i].URL)));
      end;
    end;
    selectedComponents := WizardSelectedComponents(false);  
    Log('# The following [' + IntToStr(intTotalComponents) + '] components are selected: ' + selectedComponents); 
  end;

  if updaterMode = true then
  begin
    if CurPage = wpUpdaterPage.ID then
    begin
      // Add files to wpUpdaterComponentList and IDP
      wpUpdaterComponentList := ''; // Clear list
      intTotalComponents := 0; // Clear list
      for i := 0 to wpUpdaterPage.CheckListBox.Items.Count - 1 do
      begin
        if wpUpdaterPage.CheckListBox.Checked[i] = true then
        begin
          wpUpdaterComponentList := wpUpdaterComponentList + WebCompsArray[i].ID + ',';
          intTotalComponents := intTotalComponents + 1;
          idpAddFile(WebCompsArray[i].URL, tmp(GetURLFilePart(WebCompsArray[i].URL)));
        end;
      end;
      if intTotalComponents = 0 then begin
        MsgBox('Error:' #13#13 'No componentes are selected.', mbInformation, MB_OK);
        Result := False;
        exit;
      end else begin
        selectedComponents := wpUpdaterComponentList  
        Log('# The following [' + IntToStr(intTotalComponents) + '] components are selected: ' + selectedComponents);
      end;
    end;
  end;

  // Check for file presence in WizardDirValue
  if CurPage = wpSelectDir then
  begin
    if not FileExists(AddBackslash(WizardDirValue) + 'sh2pc.exe') then 
    begin 
      if MsgBox('Could not find sh2pc.exe in folder!' #13#13 'The selected folder may not be where Silent Hill 2 PC is located.' #13#13 'Proceed anyway?', mbConfirmation, MB_YESNO) = IDNO then
        Result := False;
    end;
  end;
end;

// Called when the extraction of a component is finished
procedure UpdateTotalProgressBar();
var
    TotalProgressBar   : TNewProgressBar;
    TotalProgressLabel : TLabel;
begin
    TotalProgressBar := TNewProgressBar(wpExtractPage.FindComponent('TotalProgressBar'));
    // Initalize the ProgessBar
    if(TotalProgressBar.Position = -1) then
    begin
        TotalProgressBar.Min := 0;
        TotalProgressBar.Position := 0;
        TotalProgressBar.Max := (intTotalComponents * 100);
        Log('# ProgressBar.Max set to: [' + IntToStr(TotalProgressBar.Max) + '].');
    end;

    // increase counter
    intInstalledComponentsCounter := intInstalledComponentsCounter + 1;

    // Update Label
    TotalProgressLabel := TLabel(wpExtractPage.FindComponent('TotalProgressLabel'));
    TotalProgressLabel.Caption := IntToStr(intInstalledComponentsCounter) + '/' +IntToStr(intTotalComponents);

    // Update ProgressBar
    TotalProgressBar.Position := (intInstalledComponentsCounter * 100);
    Log('# Processed Components '+IntToStr(intInstalledComponentsCounter) +'/'+IntToStr(intTotalComponents)+'.');
end;


// Called when the extraction of a new component starts.
procedure UpdateCurrentComponentName(component: String);
var
    CurrentComponentLabel : TLabel;
begin
    CurrentComponentLabel := TLabel(wpExtractPage.FindComponent('CurrentComponentLabel'));
    CurrentComponentLabel.Caption := component;
    Log('# Extracting Component: ' + component);
end;

// Called when CurPageID=wpExtractPage.ID
procedure ExtractFiles();
var
  NullBox : TNewListBox;     // Dummy box
  NullBar : TNewProgressBar; // Dummy bar
begin
  ExtractTemporaryFile('7za.exe');
  //ExtractTemporaryFile('unshield.exe');

  // Extracte selected components
  if Pos('sh2emodule', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('SH2 Enhancements Module');
      Extractore(tmp(GetURLFilePart(WebCompsArray[0].URL)), WizardDirValue, '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('ee_exe', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('Enhanced Executable');
      if not FileExists(WizardDirValue + '\sh2pc.exe.bak') then
        // Backup the .exe before extracting the new one, if a backup doesn't already exist
        RenameFile(WizardDirValue + '\sh2pc.exe', WizardDirValue + '\sh2pc.exe.bak');
      Extractore(tmp(GetURLFilePart(WebCompsArray[1].URL)), WizardDirValue, '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar(); 
  end;
  
  if Pos('ee_essentials', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('Enhanced Edition Essential Files');
      Extractore(tmp(GetURLFilePart(WebCompsArray[2].URL)), WizardDirValue, '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('img_pack', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('Image Enhancement Pack');
      Extractore(tmp(GetURLFilePart(WebCompsArray[3].URL)), WizardDirValue, '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('fmv_pack', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('FMV Enhancement Pack');
      Extractore(tmp(GetURLFilePart(WebCompsArray[4].URL)), WizardDirValue, '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('audio_pack', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('Audio Enhancement Pack');
      Extractore(tmp(GetURLFilePart(WebCompsArray[5].URL)), WizardDirValue, '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('dsoal', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('DSOAL');
      Extractore(tmp(GetURLFilePart(WebCompsArray[6].URL)), WizardDirValue, '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('xinput_plus', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('XInput Plus');
      Extractore(tmp(GetURLFilePart(WebCompsArray[7].URL)), WizardDirValue, '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if not ExtractionCancel then WizardForm.NextButton.OnClick(WizardForm.NextButton);

end;

procedure preInstall();
var i : Integer;
begin
  ExtractTemporaryFile('SH2EEupdater.dat');

  if updaterMode = false then
  begin
    for i := 0 to WizardForm.ComponentsList.Items.Count - 1 do
    begin
      if WizardForm.ComponentsList.Checked[i] = true then
      begin
        FileReplaceString(ExpandConstant('{tmp}\SH2EEupdater.dat'), WebCompsArray[i].ID + ',false,0.0', WebCompsArray[i].ID + ',true,' + WebCompsArray[i].Version);
      end;
    end;
    FileCopy(ExpandConstant('{tmp}\SH2EEupdater.dat'), ExpandConstant('{app}\SH2EEupdater.dat'), false);
  end;
end;

procedure postInstall();
var
  i : Integer;
begin
  if updaterMode = true then
  begin
    for i := 0 to wpUpdaterPage.CheckListBox.Items.Count - 1 do
    begin
      if wpUpdaterPage.CheckListBox.Checked[i] = true then
      begin
        FileReplaceString(ExpandConstant('{src}\SH2EEupdater.dat'), LocalCompsArray[i].ID + ',' + BoolToStr(LocalCompsArray[i].isInstalled) + ',' + LocalCompsArray[i].Version, WebCompsArray[i].ID + ',true,' + WebCompsArray[i].Version);
      end;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then preInstall();
  if CurStep = ssPostInstall then postInstall();
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID=wpExtractPage.ID then 
  begin
    Wizardform.NextButton.Enabled := false;
    WizardForm.BackButton.Visible := false;
    ExtractFiles();
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Restore the .exe backup if it exists
    if FileExists(ExpandConstant('{app}\') + 'sh2pc.exe.bak') then
      RenameFile(ExpandConstant('{app}\') + 'sh2pc.exe.bak', ExpandConstant('{app}\') + 'sh2pc.exe');
  end;
end;