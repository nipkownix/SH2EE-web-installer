; -- Prototype SH2EE Online Installer --

#define INSTALLER_VER  "1.0"
#define DEBUG          "false"
#define SH2EE_CSV_URL  "http://etc.townofsilenthill.com/sandbox/ee_itmp/sh2ee.csv"

#include "includes\innosetup-download-plugin\idp.iss"

[Setup]
AppName=Silent Hill 2: Enhanced Edition
AppVersion=1.0
WizardStyle=modern
DefaultDirName={autopf}\Konami\Silent Hill 2\
UninstallDisplayIcon={app}\sh2.ico
OutputDir=build
DirExistsWarning=no
DisableWelcomePage=False
RestartIfNeededByRun=False
AppendDefaultDirName=False
DisableProgramGroupPage=Yes
RestartApplications=False
UninstallDisplayName=Silent Hill 2: Enhanced Edition
DisableDirPage=no
ShowLanguageDialog=no
WizardResizable=True
LicenseFile=license.rtf

[Types]
Name: full; Description: Full installation (Recommended)
Name: custom; Description: Custom installation; Flags: iscustom

[Components]
Name: sh2emodule; Description: SH2 Enhancements Module; ExtraDiskSpaceRequired: 4174272; Types: full custom; Flags: fixed
Name: ee_exe; Description: Enhanced Executable; ExtraDiskSpaceRequired: 5459968; Types: full custom; Flags: fixed
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

[Icons]
//Name: "{commondesktop}\Silent Hill 2 Enhanced Edition"; Filename: "{app}\sh2pc.exe"; Tasks: add_desktopicon

[Tasks]
//Name: add_desktopicon; Description: Create a &Desktop shortcut for the game; GroupDescription: Additional Icons:; Components: sh2emodule

[CustomMessages]
HelpButton=Help

[Messages]
StatusExtractFiles=Placing files...
WelcomeLabel1=Silent Hill 2: Enhanced Edition Installation Wizard
WelcomeLabel2=This wizard will guide you through installing Silent Hill 2: Enhanced Edition for use with Silent Hill 2 PC.%n%nNote: This wizard does not include a copy of Silent Hill 2 PC.%n%nYou must install your own copy of Silent Hill 2 PC in order to use Silent Hill 2: Enhanced Edition.%n%nYou should install Silent Hill 2 PC before running this wizard.

[Code]
#include "includes/Extractore.iss"
#include "includes/Util.iss"

var
  wpExtractPage                 : TWizardPage;
  intTotalComponents            : Integer;
  intInstalledComponentsCounter : Integer;
  ExtractoreListBox             : TNewListBox;
  CurrentComponentProgressBar   : TNewProgressBar;

  CSVFilePath                   : String;
  ComponentsInfoArray           : array of TComponentsInfo;

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
      Parent := wpExtractPage.Surface;
      Caption := 'Total Progress';
      Left := ScaleX(0);
      Top := ScaleY(0);
      AutoSize := False;
      TabOrder := 1;
  end;

  TotalProgressBar := TNewProgressBar.Create(wpExtractPage);
  with TotalProgressBar do
  begin
      Name := 'TotalProgressBar';
      Parent := wpExtractPage.Surface;
      Left := ScaleX(0);
      Top := ScaleY(16);
      Width := wpExtractPage.SurfaceWidth - TotalProgressBar.Left;
      Height := ScaleY(20);
      Anchors := [akLeft, akTop, akRight];
      Min := -1;
      Position := -1
      Max := 100;
  end;

  TotalProgressLabel := TLabel.Create(wpExtractPage);
  with TotalProgressLabel do
  begin
      Name := 'TotalProgressLabel';
      Parent := wpExtractPage.Surface;
      Caption := '--/--';
      Font.Style := [fsBold];
      Alignment := taRightJustify;
      Left := TotalProgressBar.Width - ScaleX(120);
      Top := ScaleY(0);
      Width := ScaleX(120);
      Height := ScaleY(14);
      Anchors := [akLeft, akTop, akRight];
      AutoSize := False;
  end;

  CurrentComponentStaticText := TNewStaticText.Create(wpExtractPage);
  with CurrentComponentStaticText do
  begin
      Parent := wpExtractPage.Surface;
      Caption := 'Extracting Component';
      Left := ScaleX(0);
      Top := ScaleY(48);
      Width := ScaleX(200);
      Height := ScaleY(14);
      AutoSize := False;
      TabOrder := 2;
  end;

  CurrentComponentProgressBar := TNewProgressBar.Create(wpExtractPage);
  with CurrentComponentProgressBar do
  begin
      Name := 'CurrentComponentProgressBar';
      Parent := wpExtractPage.Surface;
      Left := ScaleX(0);
      Top := ScaleY(64);
      Width := wpExtractPage.SurfaceWidth - CurrentComponentProgressBar.Left;
      Height := ScaleY(20);
      Anchors := [akLeft, akTop, akRight];
      Min := 0;
      Max := 100;
      //Style := npbstMarquee;
  end;

  CurrentComponentLabel := TLabel.Create(wpExtractPage);
  with CurrentComponentLabel do
  begin
      Name := 'CurrentComponentLabel';
      Parent := wpExtractPage.Surface;
      Caption := '';
      Alignment := taRightJustify;
      CurrentComponentLabel.Font.Style := [fsBold];
      Left := CurrentComponentProgressBar.Width - ScaleX(320);
      Top := ScaleY(48);
      Width := ScaleX(320);
      Height := ScaleY(14);
      Anchors := [akLeft, akTop, akRight];
      AutoSize := False;
  end;

  ExtractoreListBox := TNewListBox.Create(wpExtractPage);
  with ExtractoreListBox do
  begin
      Parent := wpExtractPage.Surface;
      Left := CurrentComponentProgressBar.Left;
      Top := CurrentComponentProgressBar.Top + ScaleY(40);
      Width := CurrentComponentProgressBar.Width;
      Height := wpExtractPage.SurfaceHeight - ExtractoreListBox.Top - ScaleY(10);
      Anchors := [akLeft, akTop, akRight, akBottom];
      Items.Clear();
  end;
end;

procedure HelpButtonClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('open', 'http://www.enhanced.townofsilenthill.com/SH2/install.htm', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure InitializeWizard();
var
  CancelBtn     : TButton;
  HelpButton    : TButton;
  DebugLabel    : TNewStaticText;
begin
  // idp settings
  idpSetOption('AllowContinue',  '1');
  idpSetOption('DetailsVisible', '1');
  idpSetOption('DetailsButton',  '1');
  idpSetOption('RetryButton',    '1');
  idpSetOption('UserAgent',      'sh2ee web installer');
  idpSetOption('InvalidCert',    'ignore');

  // Start the download after wpReady
  idpDownloadAfter(wpReady);

  // Create the wpExtract page
  create_wpExtract();

  idpClearFiles();
  
  SetTimer(0, 0, 50, CreateCallback(@HoverTimerProc));

  ExtractoreListBox := TNewListBox.Create(wpExtractPage);
  with ExtractoreListBox do
  begin
      Parent := wpExtractPage.Surface;
      Left := CurrentComponentProgressBar.Left;
      Top := CurrentComponentProgressBar.Top + ScaleY(40);
      Width := CurrentComponentProgressBar.Width;
      Height := wpExtractPage.SurfaceHeight - ExtractoreListBox.Top - ScaleY(10);
      Anchors := [akLeft, akTop, akRight, akBottom];
      Items.Clear();
  end;

  CompTitle := TLabel.Create(WizardForm);
  with CompTitle do
  begin
      Caption := '';
      Font.Style := [fsBold];
      Parent := WizardForm.SelectComponentsPage;
      Left := WizardForm.ComponentsList.Left;
      Width := WizardForm.ComponentsList.Width;
      Height := ScaleY(35);
      Top := WizardForm.ComponentsList.Top + WizardForm.ComponentsList.Height - CompTitle.Height - ScaleY(25);
      Anchors := [akLeft, akBottom];
      AutoSize := False;
      WordWrap := True;
  end;

  CompDescription := TLabel.Create(WizardForm);
  with CompDescription do
  begin
      Caption := '';
      Parent := WizardForm.SelectComponentsPage;
      Left := WizardForm.ComponentsList.Left;
      Width := WizardForm.ComponentsList.Width;
      Height := ScaleY(60);
      Top := CompTitle.Top + CompTitle.Height - ScaleY(20);
      Anchors := [akLeft, akBottom];
      AutoSize := False;
      WordWrap := True;
  end;

  WizardForm.ComponentsList.Height := WizardForm.ComponentsList.Height - CompTitle.Height - ScaleY(30);


  CancelBtn                := WizardForm.CancelButton;
  HelpButton               := TButton.Create(WizardForm);
  HelpButton.Top           := CancelBtn.Top;
  HelpButton.Left          := WizardForm.ClientWidth - CancelBtn.Left - CancelBtn.Width;
  HelpButton.Height        := CancelBtn.Height;
  HelpButton.Anchors       := [akLeft, akBottom];
  HelpButton.Caption       := ExpandConstant('{cm:HelpButton}');
  HelpButton.Cursor        := crHelp;
  HelpButton.Font.Color    := clHighlight;
  HelpButton.OnClick       := @HelpButtonClick;
  HelpButton.Parent        := WizardForm;

  if {#DEBUG} = true then
  begin
    DebugLabel            := TNewStaticText.Create(WizardForm);
    DebugLabel.Top        := HelpButton.Top + 4;
    DebugLabel.Anchors    := [akLeft, akBottom];
    DebugLabel.Left       := HelpButton.Left + HelpButton.Width + 10;
    DebugLabel.Caption    := ExpandConstant('DEBUG ON');
    DebugLabel.Font.Style := [fsBold];
    DebugLabel.Parent     := WizardForm;
  end;
end;

function InitializeSetup(): Boolean;
var
  version : String;
begin
  Result := True;
  // Store the path sh2ee.csv in a global variable
  CSVFilePath := tmp(GetURLFilePart('{#SH2EE_CSV_URL}'));

  // Download sh2ee.csv; show an error message and exit the installer if downloading fails
  if not idpDownloadFile('{#SH2EE_CSV_URL}', CSVFilePath) then begin
    MsgBox('Error:' + chr(10) + chr(13) + 'Downloading {#SH2EE_CSV_URL} failed.' + chr(10) + chr(13) + 'Setup cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;

  // Create an array of TComponentsInfo records from sh2ee.csv and store them in a global variable
  ComponentsInfoArray := CSVToInfoArray(CSVFilePath);
  // Check if above didn't work
  if GetArrayLength(ComponentsInfoArray) = 0 then begin
    MsgBox('Error:' + chr(10) + chr(13) + 'Parsing {#SH2EE_CSV_URL} failed.' + chr(10) + chr(13) + 'Setup cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;

  // Check if the installer should work correctly with with the current server-side files
  if not SameText(ComponentsInfoArray[0].ReqInstallerVersion, ExpandConstant('{#INSTALLER_VER}')) then
  begin
    MsgBox('Error:' + chr(10) + chr(13) + 'This installer is outdated.' + chr(10) + chr(13) + 'Please visit the official website and download an updated version', mbInformation, MB_OK);
    Result := False;
    exit;
  end;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
var
  Res : Boolean;
begin
  Confirm := False; // Don't show the default dialog.
  Res := ExitSetupMsgBox();
  if CurPageID=wpExtractPage.ID then 
  begin
    ExtractionCancel := Res;
    ProcEnd(extProcHandle);
  end;
  Cancel := Res;
end;

function NextButtonClick(CurPage: Integer): Boolean;
begin
  if CurPage = wpSelectComponents then
  begin
    // Add files to idp
    if WizardIsComponentSelected('sh2emodule')     then idpAddFile(ComponentsInfoArray[0].URL, tmp(GetURLFilePart(ComponentsInfoArray[0].URL))); 
    if WizardIsComponentSelected('ee_exe')         then idpAddFile(ComponentsInfoArray[1].URL, tmp(GetURLFilePart(ComponentsInfoArray[1].URL)));
    if WizardIsComponentSelected('ee_essentials')  then idpAddFile(ComponentsInfoArray[2].URL, tmp(GetURLFilePart(ComponentsInfoArray[2].URL)));
    if WizardIsComponentSelected('img_pack')       then idpAddFile(ComponentsInfoArray[3].URL, tmp(GetURLFilePart(ComponentsInfoArray[3].URL)));
    if WizardIsComponentSelected('fmv_pack')       then idpAddFile(ComponentsInfoArray[4].URL, tmp(GetURLFilePart(ComponentsInfoArray[4].URL)));
    if WizardIsComponentSelected('audio_pack')     then idpAddFile(ComponentsInfoArray[5].URL, tmp(GetURLFilePart(ComponentsInfoArray[5].URL)));
    if WizardIsComponentSelected('dsoal')          then idpAddFile(ComponentsInfoArray[6].URL, tmp(GetURLFilePart(ComponentsInfoArray[6].URL)));
    if WizardIsComponentSelected('xinput_plus')    then idpAddFile(ComponentsInfoArray[7].URL, tmp(GetURLFilePart(ComponentsInfoArray[7].URL)));    
  end;
  Result := True;

  // Check for file presence in WizardDirValue
  if CurPage = wpSelectDir then
  begin
    if not FileExists(AddBackslash(WizardDirValue) + 'sh2pc.exe') then 
    begin 
      if MsgBox('Could not find sh2pc.exe in folder!' + chr(10) + chr(13) + 'The selected folder may not be where Silent Hill 2 PC is located.' + chr(10) + chr(13) + 'Proceed anyway?', mbConfirmation, MB_YESNO) = IDNO then
        Result := False;
    end;
  end;
end;

// determine the total number of components by counting the selected components.
Procedure GetNumberOfSelectedComponents(selectedComponents : String);
var
  i : Integer;
begin
  for i := 0 to WizardForm.ComponentsList.Items.Count - 1 do
    if WizardForm.ComponentsList.Checked[i] = true then
       intTotalComponents := intTotalComponents + 1;
  Log('# The following [' + IntToStr(intTotalComponents) + '] components are selected: ' + selectedComponents);
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

// Called by doExtract()
procedure ExtractFiles();
var
  selectedComponents : String;
  NullBox : TNewListBox;     // Dummy box
  NullBar : TNewProgressBar; // Dummy bar
begin
  selectedComponents := WizardSelectedComponents(false);

  ExtractTemporaryFile('7za.exe');
  //ExtractTemporaryFile('unshield.exe');

  GetNumberOfSelectedComponents(selectedComponents);

  // Extract the main module
  UpdateCurrentComponentName('SH2 Enhancements Module');
    Extractore(tmp(GetURLFilePart(ComponentsInfoArray[0].URL)), ExpandConstant('{app}'), '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
  UpdateTotalProgressBar();

  // Extract EE .exe
  UpdateCurrentComponentName('Enhanced Executable');
    Extractore(tmp(GetURLFilePart(ComponentsInfoArray[1].URL)), ExpandConstant('{app}'), '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
  UpdateTotalProgressBar(); 
  
  // Extracte selected components
  if Pos('ee_essentials', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('Enhanced Edition Essential Files');
      Extractore(tmp(GetURLFilePart(ComponentsInfoArray[2].URL)), ExpandConstant('{app}'), '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('img_pack', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('Image Enhancement Pack');
      Extractore(tmp(GetURLFilePart(ComponentsInfoArray[3].URL)), ExpandConstant('{app}'), '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('fmv_pack', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('FMV Enhancement Pack');
      Extractore(tmp(GetURLFilePart(ComponentsInfoArray[4].URL)), ExpandConstant('{app}'), '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('audio_pack', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('Audio Enhancement Pack');
      Extractore(tmp(GetURLFilePart(ComponentsInfoArray[5].URL)), ExpandConstant('{app}'), '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('dsoal', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('DSOAL');
      Extractore(tmp(GetURLFilePart(ComponentsInfoArray[6].URL)), ExpandConstant('{app}'), '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('xinput_plus', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('XInput Plus');
      Extractore(tmp(GetURLFilePart(ComponentsInfoArray[7].URL)), ExpandConstant('{app}'), '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if not ExtractionCancel then WizardForm.NextButton.OnClick(WizardForm.NextButton);

end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  //if CurStep = ssInstall then preInstall();
  //if CurStep = ssPostInstall then postInstall();
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
