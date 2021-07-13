; -- Prototype SH2EE Online Installer --

#define DEBUG "false"
#include "includes\innosetup-download-plugin\idp.iss"

[Setup]
AppName=Silent Hill 2: Enhanced Edition
AppVersion=1.0
WizardStyle=modern
DefaultDirName={autopf}\Konami\Silent Hill 2\
DefaultGroupName=Silent Hill 2 Enhanced Edition
UninstallDisplayIcon={app}\sh2.ico
OutputDir=build
DirExistsWarning=no
DisableWelcomePage=False
RestartIfNeededByRun=False
AppendDefaultDirName=False
DisableProgramGroupPage=no
RestartApplications=False
UninstallDisplayName=Silent Hill 2: Enhanced Edition
DisableDirPage=no
ShowLanguageDialog=no
WizardResizable=True

[Types]
Name: full; Description: Full installation (Recommended)
Name: custom; Description: Custom installation; Flags: iscustom

[Components]
Name: sh2emodule; Description: SH2 Enhancements Module; ExtraDiskSpaceRequired: 4174272; Types: full custom; Flags: fixed
Name: ee_essentials; Description: Enhanced Edition Essential Files; ExtraDiskSpaceRequired: 288792943; Types: full
Name: img_pack; Description: Image Enhancement Pack; ExtraDiskSpaceRequired: 1229057424; Types: full
Name: audio_pack; Description: Audio Enhancement Pack; ExtraDiskSpaceRequired: 2487799726; Types: full
Name: dsoal; Description: DSOAL; ExtraDiskSpaceRequired: 2217690; Types: full
Name: fmv_pack; Description: FMV Enhancement Pack; ExtraDiskSpaceRequired: 3427749254; Types: full
Name: xinput_plus; Description: XInput Plus; ExtraDiskSpaceRequired: 941770; Types: full
Name: ee_exe; Description: Enhanced Executable; ExtraDiskSpaceRequired: 5459968; Types: full

[Files]
; Extraction tools bellow
Source: "includes\7zip\7za.exe"; Flags: dontcopy
Source: "includes\unshield\unshield.exe"; Flags: dontcopy
Source: "includes\cmdlinerunner\cmdlinerunner.dll"; DestDir: "{tmp}"; Flags: dontcopy
; Files bellow will be downloaded
Source: "{tmp}\sh2emodule\*"; DestDir: "{app}"; Flags: external recursesubdirs createallsubdirs; ExternalSize: 4174272; Components: sh2emodule
Source: "{tmp}\ee_essentials\SILENT HILL 2\*"; DestDir: "{app}"; Flags: external recursesubdirs createallsubdirs; ExternalSize: 288792943; Components: ee_essentials
Source: "{tmp}\img_pack\SILENT HILL 2\*"; DestDir: "{app}"; Flags: external recursesubdirs createallsubdirs; ExternalSize: 1229057424; Components: img_pack
Source: "{tmp}\audio_pack\SILENT HILL 2\*"; DestDir: "{app}"; Flags: external recursesubdirs createallsubdirs; ExternalSize: 2487799726; Components: audio_pack
Source: "{tmp}\dsoal\SILENT HILL 2\*"; DestDir: "{app}"; Flags: external recursesubdirs createallsubdirs; ExternalSize: 2217690; Components: dsoal
Source: "{tmp}\fmv_pack\SILENT HILL 2\*"; DestDir: "{app}"; Flags: external recursesubdirs createallsubdirs; ExternalSize: 3427749254; Components: fmv_pack
Source: "{tmp}\xinput_plus\SILENT HILL 2\*"; DestDir: "{app}"; Flags: external recursesubdirs createallsubdirs; ExternalSize: 941770; Components: xinput_plus
Source: "{tmp}\ee_exe\*"; DestDir: "{app}"; Flags: external recursesubdirs createallsubdirs; ExternalSize: 5459968; Components: ee_exe

[Icons]
Name: "{group}\Silent Hill 2 Enhanced Edition"; Filename: "{app}\sh2pc.exe"; Tasks: add_startmenu
Name: "{group}\Silent Hill 2 Enhanced Edition"; Filename: "{app}\sh2pc.exe"; Tasks: add_desktopicon
Name: "{group}\Silent Hill 2 Enhanced Edition"; Filename: "{app}\sh2pc.exe"; Tasks: add_quicklaunchicon

[Tasks]
Name: portablemode; Description: "todo?"; Flags: unchecked
Name: add_startmenu; Description: Create Startmenu entries; Components: sh2emodule
Name: add_quicklaunchicon; Description: Create a &Quick Launch shortcut for the game; GroupDescription: Additional Icons:; Components: sh2emodule
Name: add_desktopicon; Description: Create a &Desktop for the game; GroupDescription: Additional Icons:; Components: sh2emodule

[CustomMessages]
HelpButton=Help

[Messages]
StatusExtractFiles=Placing files...

[Code]
#include "includes/Extractore.iss"

const  
  // Define download URLs for the packages
  URL_sh2emodule        = 'https://github.com/elishacloud/Silent-Hill-2-Enhancements/releases/latest/download/d3d8.zip';   
  URL_ee_essentials     = 'http://enhanced.townofsilenthill.com/SH2/files/Enhanced_Edition_Essential_Files_1.2.1.zip'; 
  URL_img_pack          = 'http://enhanced.townofsilenthill.com/SH2/files/SH2PC_Image_Enhancement_Pack_1.1.0.zip'; 
  URL_audio_pack        = 'http://enhanced.townofsilenthill.com/SH2/files/SH2PC_Audio_Enhancement_Pack_2.0.3.zip'; 
  URL_dsoal             = 'http://enhanced.townofsilenthill.com/SH2/files/DSOAL_1.31a.02.zip'; 
  URL_fmv_pack          = 'http://enhanced.townofsilenthill.com/SH2/files/SH2PC_Enhanced_FMV_Pack_1.5.2.zip'; 
  URL_xinput_plus       = 'http://enhanced.townofsilenthill.com/SH2/files/XInputPlus_4.15.2.zip'; 
  URL_ee_exe            = 'http://enhanced.townofsilenthill.com/SH2/files/SH2PC_Enhanced_EXE_NA_v1.0.zip';

  // Define file names for the downloads
  Filename_sh2emodule           = 'd3d8.zip';
  Filename_ee_essentials        = 'Enhanced_Edition_Essential_Files_1.2.1.zip';
  Filename_img_pack             = 'SH2PC_Image_Enhancement_Pack_1.1.0.zip';
  Filename_audio_pack           = 'SH2PC_Audio_Enhancement_Pack_2.0.3.zip';
  Filename_dsoal                = 'DSOAL_1.31a.02.zip';
  Filename_fmv_pack             = 'SH2PC_Enhanced_FMV_Pack_1.5.2.zip';
  Filename_xinput_plus          = 'XInputPlus_4.15.2.zip';
  Filename_ee_exe               = 'SH2PC_Enhanced_EXE_NA_v1.0.zip';

var
  targetPath                    : String;
  appDir                        : String;
  wpExtractPage                 : TWizardPage;
  intTotalComponents            : Integer;
  intInstalledComponentsCounter : Integer;
  ExtractoreListBox             : TNewListBox;
  CurrentComponentProgressBar   : TNewProgressBar;

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

procedure OnDirEditChange(Sender: TObject);
var
  S: string;
begin
  S := WizardDirValue;

  // string must not be empty
  if (Length(S) = 0) then MsgBox('Please enter a target folder for the installation.', mbError, MB_OK);
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

  // OnChange event handling function for the "Select Destination Location" dialog
  WizardForm.DirEdit.OnChange := @OnDirEditChange;
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
    // Define "targetPath" for downloads or extractions is the temporary path.
    targetPath := ExpandConstant('{tmp}\');

    // Add files to idp
    if WizardIsComponentSelected('sh2emodule')       then idpAddFile(URL_sh2emodule,    ExpandConstant(targetPath + Filename_sh2emodule));   
    if WizardIsComponentSelected('ee_essentials')    then idpAddFile(URL_ee_essentials, ExpandConstant(targetPath + Filename_ee_essentials));
    if WizardIsComponentSelected('img_pack')         then idpAddFile(URL_img_pack,      ExpandConstant(targetPath + Filename_img_pack));     
    if WizardIsComponentSelected('audio_pack')       then idpAddFile(URL_audio_pack,    ExpandConstant(targetPath + Filename_audio_pack));   
    if WizardIsComponentSelected('dsoal')            then idpAddFile(URL_dsoal,         ExpandConstant(targetPath + Filename_dsoal));        
    if WizardIsComponentSelected('fmv_pack')         then idpAddFile(URL_fmv_pack,      ExpandConstant(targetPath + Filename_fmv_pack));     
    if WizardIsComponentSelected('xinput_plus')      then idpAddFile(URL_xinput_plus,   ExpandConstant(targetPath + Filename_xinput_plus));  
    if WizardIsComponentSelected('ee_exe')           then idpAddFile(URL_ee_exe,        ExpandConstant(targetPath + Filename_ee_exe));       
  end;
  Result := True;
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
procedure PrepareExtraction();
begin
  ExtractTemporaryFile('7za.exe');
  //ExtractTemporaryFile('unshield.exe');
  appDir := ExpandConstant('{app}');
  targetPath := ExpandConstant('{tmp}\');
end;

// Called by doExtract()
procedure ExtractFiles();
var
  selectedComponents : String;
  NullBox : TNewListBox;     // Dummy box
  NullBar : TNewProgressBar; // Dummy bar
begin
  selectedComponents := WizardSelectedComponents(false);

  GetNumberOfSelectedComponents(selectedComponents);

  // Extract the main module
  UpdateCurrentComponentName('SH2 Enhancements Module');
    Extractore(targetPath + Filename_sh2emodule, targetPath + 'sh2emodule', '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
  UpdateTotalProgressBar();

  // Extracte selected components
  if Pos('ee_essentials', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('Enhanced Edition Essential Files');
      Extractore(targetPath + Filename_ee_essentials, targetPath + 'ee_essentials', '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('img_pack', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('Image Enhancement Pack');
      Extractore(targetPath + Filename_img_pack, targetPath + 'img_pack', '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('audio_pack', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('Audio Enhancement Pack');
      Extractore(targetPath + Filename_audio_pack, targetPath + 'audio_pack', '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('dsoal', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('DSOAL');
      Extractore(targetPath + Filename_dsoal, targetPath + 'dsoal', '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('fmv_pack', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('FMV Enhancement Pack');
      Extractore(targetPath + Filename_fmv_pack, targetPath + 'fmv_pack', '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('xinput_plus', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('XInput Plus');
      Extractore(targetPath + Filename_xinput_plus, targetPath + 'xinput_plus', '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if Pos('ee_exe', selectedComponents) > 0 then
  begin
    UpdateCurrentComponentName('Enhanced Executable');
      Extractore(targetPath + Filename_ee_exe, targetPath + 'ee_exe', '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
    UpdateTotalProgressBar();
  end;

  if not ExtractionCancel then WizardForm.NextButton.OnClick(WizardForm.NextButton);

end;

// Called when we reach wpExtractPage
procedure doExtract();
begin
  PrepareExtraction();
  ExtractFiles();
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
    doExtract();
  end;
end;
