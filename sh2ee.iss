; -- SH2EE Web Installer --

#define INSTALLER_VER  "1.0"
#define DEBUG          "false"
#define SH2EE_CSV_URL  "http://etc.townofsilenthill.com/sandbox/ee_itmp/_sh2ee.csv"
#define LOCAL_REPO     "D:\Porgrams\git_repos\SH2EE-web-installer\"

#include "includes/innosetup-download-plugin/idp.iss"

[Setup]
AppName=Silent Hill 2: Enhanced Edition
AppVersion={#INSTALLER_VER}
WizardStyle=modern
DefaultDirName={code:GetDefaultDirName}  
OutputDir=build
OutputBaseFilename=SH2EEsetup
DirExistsWarning=no
DisableWelcomePage=False
RestartIfNeededByRun=False
AppendDefaultDirName=False
DisableProgramGroupPage=Yes
UsePreviousTasks=no
UsePreviousSetupType=no
UsePreviousAppDir=no
RestartApplications=False
Uninstallable=no
DisableDirPage=no
ShowLanguageDialog=no
WizardResizable=True
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
Name: minimal; Description: Minimal installation (Not recommended)
Name: custom; Description: Custom installation; Flags: iscustom

[Components]
; Component name MUST match the component "id" in _sh2ee.csv!
Name: sh2emodule; Description: SH2 Enhancements Module; ExtraDiskSpaceRequired: 4174272; Types: full minimal custom
Name: ee_exe; Description: Enhanced Executable; ExtraDiskSpaceRequired: 5459968; Types: full minimal custom
Name: ee_essentials; Description: Enhanced Edition Essential Files; ExtraDiskSpaceRequired: 288792943; Types: full
Name: img_pack; Description: Image Enhancement Pack; ExtraDiskSpaceRequired: 1229057424; Types: full
Name: fmv_pack; Description: FMV Enhancement Pack; ExtraDiskSpaceRequired: 3427749254; Types: full
Name: audio_pack; Description: Audio Enhancement Pack; ExtraDiskSpaceRequired: 2487799726; Types: full
Name: dsoal; Description: DSOAL; ExtraDiskSpaceRequired: 2217690; Types: full
Name: xinput_plus; Description: XInput Plus; ExtraDiskSpaceRequired: 941770; Types: full

[Files]
; Tools below
Source: "includes\7zip\7za_x86.exe"; Flags: dontcopy
Source: "includes\7zip\7za_x64.exe"; Flags: dontcopy
Source: "includes\cmdlinerunner\cmdlinerunner.dll"; Flags: dontcopy
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

[Code]
var
  maintenanceMode : Boolean;
  updateMode      : Boolean;
  selfUpdateMode  : Boolean;

#include "includes/Extractore.iss"
#include "includes/Util.iss"

var
  ComponentsListClickCheckPrev  : TNotifyEvent;

  wpMaintenance                 : TWizardPage;
  installRadioBtn               : TRadioButton;
  updateRadioBtn                : TRadioButton;
  uninstallRadioBtn             : TRadioButton;

  sh2pcFilesWerePresent         : Boolean;
  bDidSizeBackup                : Boolean;

  FileSizeArray                 : array of String;

  wpSelfUpdate                  : TWizardPage;

  LocalCompsArray               : array of TLocalComponentsInfo;

  wpExtract                     : TWizardPage;
  intTotalComponents            : Integer;
  selectedComponents            : String;
  intInstalledComponentsCounter : Integer;
  ExtractoreListBox             : TNewListBox;
  CurrentComponentProgressBar   : TNewProgressBar;

  CSVFilePath                   : String;
  WebCompsArray                 : array of TWebComponentsInfo;

  CurIniArray                   : array of TIniArray;

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
      Height        := WizardForm.FinishedLabel.Height + ScaleY(180);
      Anchors       := [akLeft, akBottom, akTop, akRight];
      Parent        := WizardForm.FinishedLabel.Parent;
      BorderStyle   := bsNone;
      TabStop       := False;
      ReadOnly      := True;
      WizardForm.FinishedLabel.Visible := False;
      WizardForm.RunList.Top := FinishedLabel_RTF.Top + ScaleY(270);
      WizardForm.RunList.Anchors := [akLeft, akBottom];
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

// Kill the extraction tool if we cancel the installation during the extraction process  
procedure wpExtractCancelButtonClick(Page: TWizardPage; var Cancel, Confirm: Boolean);
begin
  if ExitSetupMsgBox then
  begin
      WizardForm.Repaint;
      ProcEnd(extProcHandle);
      ExitProcess(1);
  end
  else begin
      Cancel := false;
  end;
end;

// Skip wpExtract if no components were selected
function wpExtractShouldSkipPage(Page: TWizardPage): Boolean;
begin
  if intTotalComponents = 0 then
    Result := true;
  Result := false;
end;

procedure create_wpExtract;
var
  TotalProgressBar                : TNewProgressBar;
  TotalProgressLabel              : TLabel;
  TotalProgressStaticText         : TNewStaticText;

  CurrentComponentLabel           : TLabel;
  CurrentComponentStaticText      : TNewStaticText;
begin
  // Create wpExtract and show it after the IDPForm page
  wpExtract := CreateCustomPage(IDPForm.Page.ID, 'Extracting compressed components', 'Please wait while Setup extracts components.');

  // Progress bars
  TotalProgressStaticText := TNewStaticText.Create(wpExtract);
  with TotalProgressStaticText do
  begin
      Parent    := wpExtract.Surface;
      Caption   := 'Total Progress';
      Left      := ScaleX(0);
      Top       := ScaleY(0);
      AutoSize  := False;
      TabOrder  := 1;
  end;

  TotalProgressBar := TNewProgressBar.Create(wpExtract);
  with TotalProgressBar do
  begin
      Name      := 'TotalProgressBar';
      Parent    := wpExtract.Surface;
      Left      := ScaleX(0);
      Top       := ScaleY(16);
      Width     := wpExtract.SurfaceWidth - TotalProgressBar.Left;
      Height    := ScaleY(20);
      Anchors   := [akLeft, akTop, akRight];
      Min       := -1;
      Position  := -1
      Max       := 100;
  end;

  TotalProgressLabel := TLabel.Create(wpExtract);
  with TotalProgressLabel do
  begin
      Name        := 'TotalProgressLabel';
      Parent      := wpExtract.Surface;
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

  CurrentComponentStaticText := TNewStaticText.Create(wpExtract);
  with CurrentComponentStaticText do
  begin
      Parent    := wpExtract.Surface;
      Caption   := 'Extracting Component';
      Left      := ScaleX(0);
      Top       := ScaleY(48);
      Width     := ScaleX(200);
      Height    := ScaleY(14);
      AutoSize  := False;
      TabOrder  := 2;
  end;

  CurrentComponentProgressBar := TNewProgressBar.Create(wpExtract);
  with CurrentComponentProgressBar do
  begin
      Name      := 'CurrentComponentProgressBar';
      Parent    := wpExtract.Surface;
      Left      := ScaleX(0);
      Top       := ScaleY(64);
      Width     := wpExtract.SurfaceWidth - CurrentComponentProgressBar.Left;
      Height    := ScaleY(20);
      Anchors   := [akLeft, akTop, akRight];
      Min       := 0;
      Max       := 100;
      //Style   := npbstMarquee;
  end;

  CurrentComponentLabel := TLabel.Create(wpExtract);
  with CurrentComponentLabel do
  begin
      Name        := 'CurrentComponentLabel';
      Parent      := wpExtract.Surface;
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

  ExtractoreListBox := TNewListBox.Create(wpExtract);
  with ExtractoreListBox do
  begin
      Parent      := wpExtract.Surface;
      Left        := CurrentComponentProgressBar.Left;
      Top         := CurrentComponentProgressBar.Top + ScaleY(40);
      Width       := CurrentComponentProgressBar.Width;
      Height      := wpExtract.SurfaceHeight - ExtractoreListBox.Top - ScaleY(10);
      Anchors     := [akLeft, akTop, akRight, akBottom];
      Items.Clear();
  end;

  with wpExtract do
  begin
      OnCancelButtonClick := @wpExtractCancelButtonClick;
      OnShouldSkipPage    := @wpExtractShouldSkipPage;
  end;
end;

procedure doCustomUninstall;
var
  intErrorCode: Integer;
begin
  ExtractTemporaryFile('deletefile_util.exe');

  DelTree(ExpandConstant('{src}\sh2e'), True, True, True);
  DeleteFile(ExpandConstant('{src}\alsoft.ini'));
  DeleteFile(ExpandConstant('{src}\d3d8.dll'));
  DeleteFile(ExpandConstant('{src}\d3d8.ini'));
  DeleteFile(ExpandConstant('{src}\d3d8.log'));
  DeleteFile(ExpandConstant('{src}\d3d8.res'));
  DeleteFile(ExpandConstant('{src}\d3d8.cfg'));
  DeleteFile(ExpandConstant('{src}\Dinput.dll'));
  DeleteFile(ExpandConstant('{src}\Dinput8.dll'));
  DeleteFile(ExpandConstant('{src}\dsoal-aldrv.dll'));
  DeleteFile(ExpandConstant('{src}\dsound.dll'));
  DeleteFile(ExpandConstant('{src}\keyconf.dat'));
  DeleteFile(ExpandConstant('{src}\local.fix'));
  DeleteFile(ExpandConstant('{src}\SH2EEsetup.dat'));
  DeleteFile(ExpandConstant('{src}\sh2pc.exe'));
  DeleteFile(ExpandConstant('{src}\XInput1_3.dll'));
  DeleteFile(ExpandConstant('{src}\XInputPlus.ini'));

  // Restore the .exe backup if it exists
  if FileExists(ExpandConstant('{src}\') + 'sh2pc.exe.bak') then
    RenameFile(ExpandConstant('{src}\') + 'sh2pc.exe.bak', ExpandConstant('{src}\') + 'sh2pc.exe');

  // Schedule SH2EEsetup.exe for removal as soon as possible
  Exec(ExpandConstant('{tmp}\') + 'deletefile_util.exe', AddQuotes(ExpandConstant('{srcexe}')), '', SW_HIDE, ewNoWait, intErrorCode);
end;

// Helper to populate wpSelectComponents's CheckListBox's labels
function wpUVersionLabel(OnlineVer: String; ExistVer: String; isInstalled: Boolean): String;
begin
  if isInstalled then
  begin
    if SameText(OnlineVer, ExistVer) then
      Result := 'No update available'
    else
      Result := 'New version available: ' + OnlineVer
  end else 
    Result := 'Not installed'
end;

// Decides whether or not there's an update available for the component
function isUpdateAvailable(OnlineVer: String; ExistVer: String; isInstalled: Boolean): Boolean;
begin
  if isInstalled then
  begin
    if SameText(OnlineVer, ExistVer) then
      Result := false
    else
      Result := true
  end else 
    Result := false
end;

function wpMaintenanceNextClick(Page: TWizardPage): Boolean;
begin
    Result := True;

    if uninstallRadioBtn.Checked then
    begin 
      if MsgBox('Are you sure you want to completely remove all Silent Hill 2: Enhanced Edition project files?', mbConfirmation, MB_YESNO) = IDNO then
        Result := False
      else
        doCustomUninstall();
    end;
end;

procedure ComponentsListClickCheck(Sender: TObject);
var
  i: integer;
  CompCount: integer;
begin
  // Call Inno's original OnClick action
  ComponentsListClickCheckPrev(Sender);
  
  // Customize components list
  CompCount := 0;

  // "Install/Repair" page
  if installRadioBtn.Checked then
  begin
    for i := 0 to GetArrayLength(WebCompsArray) - 1 do begin
      if not (WebCompsArray[i].id = 'setup_tool') then
      begin
        if LocalCompsArray[i].isInstalled then
        begin
          with Wizardform.ComponentsList do
          begin
            ItemSubItem[i - 1] := 'Already installed';
          end;
        end else
        begin
          with Wizardform.ComponentsList do
          begin
            ItemSubItem[i - 1] := FileSizeArray[i - 1];
          end;
        end;

        // Calculate how many components are selected
        if WizardForm.ComponentsList.Checked[i - 1] then
          CompCount := CompCount + 1;
      end;
    end;
  end else if updateRadioBtn.Checked then // "Update" page
  begin
    for i := 0 to GetArrayLength(WebCompsArray) - 1 do begin
      if not (WebCompsArray[i].id = 'setup_tool') then
      begin
        with Wizardform.ComponentsList do
        begin
          ItemSubItem[i - 1] := wpUVersionLabel(WebCompsArray[i].Version, LocalCompsArray[i].Version, LocalCompsArray[i].isInstalled);
        end;

        // Calculate how many components are selected
        if WizardForm.ComponentsList.Checked[i - 1] then
          CompCount := CompCount + 1;
      end;
    end;
  end;

  // Show disk space label if components are selected
  if not (CompCount = 0) then
    WizardForm.ComponentsDiskSpaceLabel.Visible := True
  else
    WizardForm.ComponentsDiskSpaceLabel.Visible := False
end;

// Creates the maintenance page
procedure PrepareMaintenance();
var
  installBmp         : TBitmapImage;
  updateBmp          : TBitmapImage;
  uninstallBmp       : TBitmapImage;

  installLabel       : TLabel;
  updateLabel        : TLabel;
  uninstallLabel     : TLabel;

begin
  ExtractTemporaryFile('icon_install.bmp');
  ExtractTemporaryFile('icon_update.bmp');
  ExtractTemporaryFile('icon_uninstall.bmp');

  wpMaintenance := CreateCustomPage(wpWelcome, 'Silent Hill 2: Enhanced Edition Maintenance Wizard', 'Install, repair, update, or uninstall files.');

  installBmp := TBitmapImage.Create(wpMaintenance);
  with installBmp do
  begin;
    AutoSize          := False;
    Stretch           := True;
    BackColor         := wpMaintenance.Surface.Color;
    ReplaceColor      := $FFFFFF;
    ReplaceWithColor  := wpMaintenance.Surface.Color;
    Left              := ScaleX(16);
    Top               := ScaleY(5);
    Anchors           := [akTop, akLeft];
    Width             := 38;
    Height            := 38;
    Parent            := wpMaintenance.Surface;
    Bitmap.LoadFromFile(ExpandConstant('{tmp}\icon_install.bmp'));
  end;

  updateBmp := TBitmapImage.Create(wpMaintenance);
  with updateBmp do
  begin;
    AutoSize          := False;
    Stretch           := True;
    BackColor         := wpMaintenance.Surface.Color;
    ReplaceColor      := $FFFFFF;
    ReplaceWithColor  := wpMaintenance.Surface.Color;
    Left              := installBmp.Left;
    Top               := installBmp.Top + ScaleY(74);
    Anchors           := [akTop, akLeft];
    Width             := 38;
    Height            := 38;
    Parent            := wpMaintenance.Surface;
    Bitmap.LoadFromFile(ExpandConstant('{tmp}\icon_update.bmp'));
  end;

  uninstallBmp := TBitmapImage.Create(wpMaintenance);
  with uninstallBmp do
  begin;
    AutoSize          := False;
    Stretch           := True;
    BackColor         := wpMaintenance.Surface.Color;
    ReplaceColor      := $FFFFFF;
    ReplaceWithColor  := wpMaintenance.Surface.Color;
    Left              := updateBmp.Left;
    Top               := updateBmp.Top + ScaleY(74);
    Anchors           := [akTop, akLeft];
    Width             := 38;
    Height            := 38;
    Parent            := wpMaintenance.Surface;
    Bitmap.LoadFromFile(ExpandConstant('{tmp}\icon_uninstall.bmp'));
  end;

  installRadioBtn := TRadioButton.Create(wpMaintenance);
  with installRadioBtn do
  begin
    Parent     := wpMaintenance.Surface;
    Caption    := 'Install or Repair Packages';
    Font.Style := [fsBold];
    Checked    := False;
    Left       := installBmp.Left + ScaleX(54);
    Top        := installBmp.Top;
    Anchors    := [akTop, akLeft];
    Width      := wpMaintenance.SurfaceWidth;
  end;

  updateRadioBtn := TRadioButton.Create(wpMaintenance);
  with updateRadioBtn do
  begin
    Parent     := wpMaintenance.Surface;
    Caption    := 'Update Packages';
    Font.Style := [fsBold];
    Checked    := True;
    Left       := updateBmp.Left + ScaleX(54);
    Top        := updateBmp.Top;
    Anchors    := [akTop, akLeft];
    Width      := wpMaintenance.SurfaceWidth;
  end;

  uninstallRadioBtn := TRadioButton.Create(wpMaintenance);
  with uninstallRadioBtn do
  begin
    Parent     := wpMaintenance.Surface;
    Caption    := 'Uninstall';
    Font.Style := [fsBold];
    Checked    := False;
    Left       := uninstallBmp.Left + ScaleX(54);
    Top        := uninstallBmp.Top;
    Anchors    := [akTop, akLeft];
    Width      := wpMaintenance.SurfaceWidth;
  end;

  installLabel := TLabel.Create(wpMaintenance);
  with installLabel do
  begin
    Parent     := wpMaintenance.Surface;
    Caption    := 'Install enhancement packages that were not previously installed, or repair broken packages.';
    Left       := installRadioBtn.Left;
    Top        := installRadioBtn.Top + ScaleX(22);
    Width      := wpMaintenance.SurfaceWidth - ScaleX(70);
    Anchors    := [akTop, akLeft, akRight];
    WordWrap   := True;
    AutoSize   := True;
  end;

  updateLabel := TLabel.Create(wpMaintenance);
  with updateLabel do
  begin
    Parent     := wpMaintenance.Surface;
    Caption    := 'Check and download updates for installed enhancement packages.';
    Left       := updateRadioBtn.Left;
    Top        := updateRadioBtn.Top + ScaleX(22);
    Width      := wpMaintenance.SurfaceWidth - ScaleX(70);
    Anchors    := [akTop, akLeft, akRight];
    WordWrap   := True;
    AutoSize   := True;
  end;

  uninstallLabel := TLabel.Create(wpMaintenance);
  with uninstallLabel do
  begin
    Parent     := wpMaintenance.Surface;
    Caption    := 'Remove all installed enhancement packages. This only removes the Silent Hill 2: Enhanced Edition project files and does not remove Silent Hill 2 PC files.';
    Left       := uninstallRadioBtn.Left;
    Top        := uninstallRadioBtn.Top + ScaleX(22);
    Width      := wpMaintenance.SurfaceWidth - ScaleX(70);
    Anchors    := [akTop, akLeft, akRight];
    WordWrap   := True;
    AutoSize   := True;
  end;

  with wpMaintenance do
  begin
      OnNextButtonClick := @wpMaintenanceNextClick;
  end;

  // wpSelectComponents changes
  WizardForm.ComponentsDiskSpaceLabel.Visible := False; // Initially hide disk space label
  
  ComponentsListClickCheckPrev := WizardForm.ComponentsList.OnClickCheck;
  WizardForm.ComponentsList.OnClickCheck := @ComponentsListClickCheck; // Register new OnClick event
  
  // Hide TypesCombo 
  WizardForm.TypesCombo.Visible := False;
  WizardForm.IncTopDecHeight(WizardForm.ComponentsList, - (WizardForm.ComponentsList.Top - WizardForm.TypesCombo.Top));
end;

procedure HelpButtonClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('open', 'https://github.com/elishacloud/Silent-Hill-2-Enhancements/issues', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;

  // Skip pages if in selfUpdateMode
  if selfUpdateMode then
  begin
    if (PageID = wpMaintenance.ID) or
       (PageID = wpSelectComponents) or
       (PageID = wpFinished) then
    begin
      Result := True;
    end;
  end;

  // Skip wpSelectComponents if uninstalling
  if maintenanceMode and not selfUpdateMode then
  begin
    if (PageID = wpSelectComponents) then
      if uninstallRadioBtn.Checked then
        Result := True;
  end;

  // Skip to updater page if started with argument
  if CmdLineParamExists('-update') and maintenanceMode then
  begin
    if (PageID = wpMaintenance.ID) then
    begin
      Result := True;
    end;
  end;

  // Skip normal setup pages if in maintenanceMode
  if maintenanceMode then
  begin
    if (PageID = wpWelcome) or
       (PageID = wpLicense) or
       (PageID = wpSelectDir) or
       (PageID = wpReady) then
    begin
      Result := True;
    end;
  end;
end;

procedure selfUpdateNext(Page: TWizardPage);
begin
  WizardForm.NextButton.OnClick(WizardForm.NextButton);
end;

// Prepare for the self-update procedure
procedure PrepareSelfUpdate();
begin
  ExtractTemporaryFile('renamefile_util.exe');

  // Add file to IDP list
  idpAddFile(WebCompsArray[0].URL, ExpandConstant('{src}\SH2EEsetup_new.exe'));

  // Create a dummy self update page, so IDP can start straight away
  wpSelfUpdate := CreateCustomPage(wpWelcome, 'Silent Hill 2: EE Setup Tool self-update', 'Self-update in progress');
  idpDownloadAfter(wpSelfUpdate.ID);

  with wpSelfUpdate do
  begin
      OnActivate := @selfUpdateNext;
  end;
end;

procedure custom_wpSelectComponents(newType: String);
var
  i : Integer;
begin
  // Backup file size info
  if (not bDidSizeBackup) then
  begin
    SetArrayLength(FileSizeArray, GetArrayLength(WebCompsArray));
  
    for i := 0 to GetArrayLength(WebCompsArray) - 1 do begin
      if not (WebCompsArray[i].id = 'setup_tool') then
      begin
        with Wizardform.ComponentsList do
        begin
          FileSizeArray[i - 1] := ItemSubItem[i - 1];
        end;
      end;
    end;
    bDidSizeBackup := True;
  end;

  // "Install/Repair" page
  if (newType = 'install') then
  begin
    for i := 0 to GetArrayLength(WebCompsArray) - 1 do begin
      if not (WebCompsArray[i].id = 'setup_tool') then
      begin
        with Wizardform.ComponentsList do
        begin
          Checked[i - 1] := false; // Uncheck all by default
          ItemEnabled[i - 1] := true; // Enable all options since they might have been disabled if the user went to the "Update" page first
        end;
    
        if LocalCompsArray[i].isInstalled then
        begin
          with Wizardform.ComponentsList do
          begin
            ItemSubItem[i - 1] := 'Already installed';
          end;
        end else
        begin
          with Wizardform.ComponentsList do
          begin
            ItemSubItem[i - 1] := FileSizeArray[i - 1];
          end;
        end;
      end;
    end;
  end else if (newType = 'update') then// "Update" page
  begin
    for i := 0 to GetArrayLength(WebCompsArray) - 1 do begin
      if not (WebCompsArray[i].id = 'setup_tool') then
      begin
        with Wizardform.ComponentsList do
        begin
          Checked[i - 1] := isUpdateAvailable(WebCompsArray[i].Version, LocalCompsArray[i].Version, LocalCompsArray[i].isInstalled);
          ItemEnabled[i - 1] := isUpdateAvailable(WebCompsArray[i].Version, LocalCompsArray[i].Version, LocalCompsArray[i].isInstalled);
          ItemSubItem[i - 1] := wpUVersionLabel(WebCompsArray[i].Version, LocalCompsArray[i].Version, LocalCompsArray[i].isInstalled);
        end;
      end;
    end;
  end;

end;

procedure UpdateLocalCSV(recoverOnly: Boolean);
var
  i: Integer;
begin
  Log('# updating local csv');

  // Create fresh local .csv in the game's directory
  if not maintenanceMode then
  begin
    SaveStringToFile(ExpandConstant('{app}\SH2EEsetup.dat')
    ,'# **DO NOT MODIFY THIS FILE!**' + #13#10 +
    'id,isInstalled,version' + #13#10 +
    'setup_tool,true,' + ExpandConstant('{#INSTALLER_VER}') + #13#10,
    False);
  end else
  begin
    SaveStringToFile(ExpandConstant('{src}\SH2EEsetup.dat')
    ,'# **DO NOT MODIFY THIS FILE!**' + #13#10 +
    'id,isInstalled,version' + #13#10 +
    'setup_tool,true,' + ExpandConstant('{#INSTALLER_VER}') + #13#10,
    False);
  end;

  // Populate entries based on the web csv
  for i := 0 to GetArrayLength(WebCompsArray) - 1 do
  begin
    if not (WebCompsArray[i].id = 'setup_tool') then
    begin
      if not maintenanceMode then
      begin
        SaveStringToFile(ExpandConstant('{app}\SH2EEsetup.dat')
        ,WebCompsArray[i].ID + ',false,' + '0.0' + #13#10,
        True);
      end else
      begin
        SaveStringToFile(ExpandConstant('{src}\SH2EEsetup.dat')
        ,WebCompsArray[i].ID + ',false,' + '0.0' + #13#10,
        True);
      end;
    end;
  end;

  // Write version info and installation status
  for i := 0 to GetArrayLength(WebCompsArray) - 1 do
  begin
    if not (WebCompsArray[i].id = 'setup_tool') then
    begin
      // Rewrite existing local csv info
      if maintenanceMode then
      begin
        try
          if LocalCompsArray[i].isInstalled then
            FileReplaceString(ExpandConstant('{src}\SH2EEsetup.dat'), LocalCompsArray[i].ID + ',false,' + '0.0', LocalCompsArray[i].ID + ',true,' + LocalCompsArray[i].Version);
        except
          Log('# Entry is missing from local CSV.');
        end;
      end;

      // If in maintenance mode, check for maintenance page's radio buttons
      if maintenanceMode and not selfUpdateMode and not recoverOnly then
      begin
        // Write info from new selected components using wpSelectComponents' list box
        if installRadioBtn.Checked or updateRadioBtn.Checked then
        begin
          Log(BoolToStr(WizardForm.ComponentsList.Checked[i - 1]));
          if WizardForm.ComponentsList.Checked[i - 1] = true then
            FileReplaceString(ExpandConstant('{src}\SH2EEsetup.dat'), LocalCompsArray[i].ID + ',' + BoolToStr(LocalCompsArray[i].isInstalled) + ',' + LocalCompsArray[i].Version, WebCompsArray[i].ID + ',true,' + WebCompsArray[i].Version);
        end;
      end;

      // If not in maintenance mode, use the default method
      if not maintenanceMode then
      begin
        if WizardForm.ComponentsList.Checked[i - 1] = true then
          FileReplaceString(ExpandConstant('{app}\SH2EEsetup.dat'), WebCompsArray[i].ID + ',false,0.0', WebCompsArray[i].ID + ',true,' + WebCompsArray[i].Version);
      end;
    end;
  end;
end;

procedure InitializeWizard();
var
  HelpButton    : TButton;
  DebugLabel    : TNewStaticText;
begin

  // Compare the lenght of the web CSV array with the installer's component list
  if not SamePackedVersion(WizardForm.ComponentsList.Items.Count, GetArrayLength(WebCompsArray) - 1) then // Using SamePackedVersion() to compare lengths isn't the fanciest approach, but it works
  begin
    MsgBox('Error: Invalid Components List Size' #13#13 'The installer should be updated to handle the new components from sh2ee.csv.', mbInformation, MB_OK);
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
  idpSetOption('UserAgent',      'SH2EE web setup');
  idpSetOption('InvalidCert',    'ignore');

  // Start the download after wpReady
  idpDownloadAfter(wpReady);
  
  if maintenanceMode then
    PrepareMaintenance();

  if updateMode then
    custom_wpSelectComponents('update');
    
  if selfUpdateMode then
    PrepareSelfUpdate();

  // Create the wpExtract page
  create_wpExtract();

  // Force installation of the SH2E module and EE exe if not in maintenance mode
  if not maintenanceMode then
  begin
    WizardForm.ComponentsList.Checked[0] := true;
    WizardForm.ComponentsList.Checked[1] := true;
    WizardForm.ComponentsList.ItemEnabled[0] := false;
    WizardForm.ComponentsList.ItemEnabled[1] := false;
  end;

  // Create onhover process for wpSelectComponents
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

function InitializeSetup(): Boolean;
var i: integer;
begin
  Result := True;

  // Store the path to sh2ee.csv in a global variable
  if not {#DEBUG} then
    CSVFilePath := tmp(GetURLFilePart('{#SH2EE_CSV_URL}'))
  else
    CSVFilePath := '{#LOCAL_REPO}' + 'resources\_sh2ee.csv';

  // Download sh2ee.csv; show an error message and exit the installer if downloading fails
  if not {#DEBUG} and not idpDownloadFile('{#SH2EE_CSV_URL}', CSVFilePath) then
  begin
    MsgBox('Error: Download Failed' #13#13 'Couldn''t download sh2ee.csv.' #13#13 'The installation cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;

  // Create an array of TWebComponentsInfo records from sh2ee.csv and store them in a global variable
  WebCompsArray := WebCSVToInfoArray(CSVFilePath);
  // Check if above didn't work
  if GetArrayLength(WebCompsArray) = 0 then
  begin
    MsgBox('Error: Parsing Failed' #13#13 'Couldn''t parse sh2ee.csv.' #13#13 'The installation cannot continue.', mbInformation, MB_OK);
    Result := False;
    exit;
  end;

  // Enable Update if started with argument
  if CmdLineParamExists('-update') then
  begin
    updateMode := True;
  end;

  // Enable selfUpdate if started with argument
  if CmdLineParamExists('-selfUpdate') then
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

  // Determine weather or not we should be in "maintenance mode"
  if FileExists(ExpandConstant('{src}\') + 'sh2pc.exe') and FileExists(ExpandConstant('{src}\') + 'SH2EEsetup.dat') then
  begin
    maintenanceMode := True;

    // Create an array of TWebComponentsInfo records from the existing SH2EEsetup.dat and store it in a global variable
    LocalCompsArray := LocalCSVToInfoArray(ExpandConstant('{src}\SH2EEsetup.dat'));

    // Check if above didn't work
    if GetArrayLength(WebCompsArray) = 0 then
    begin
      MsgBox('Error: Parsing Failed' #13#13 'Couldn''t parse SH2EEsetup.dat.' #13#13 'The installation cannot continue.', mbInformation, MB_OK);
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
end;

function NextButtonClick(CurPage: Integer): Boolean;
var
  i : Integer;
begin
  Result := True;

  if CurPage = wpSelectComponents then
  begin
    // Add files to IDP
    intTotalComponents := 0; // Clear list
    idpClearFiles(); // Make sure idp file list is clean
    for i := 0 to WizardForm.ComponentsList.Items.Count - 1 do
    begin
      if WizardForm.ComponentsList.Checked[i] = true then
      begin
        intTotalComponents := intTotalComponents + 1;
        idpAddFile(WebCompsArray[i + 1].URL, tmp(GetURLFilePart(WebCompsArray[i + 1].URL)));
      end;
    end;
    if intTotalComponents = 0 then begin
      MsgBox('Error:' #13#13 'No componentes are selected.', mbInformation, MB_OK);
      Result := False;
      exit;
    end else begin
      selectedComponents := WizardSelectedComponents(false);  
      Log('# The following [' + IntToStr(intTotalComponents) + '] components are selected: ' + selectedComponents);
    end;
  end;

  // Customize wpSelectComponents for maintenance mode
  if maintenanceMode and (not selfUpdateMode) then
  begin
    if CurPage = wpMaintenance.ID then
    begin
      // "Install/Repair" page
      if installRadioBtn.Checked then
        custom_wpSelectComponents('install')
      else if updateRadioBtn.Checked then // "Update" page
        custom_wpSelectComponents('update');
     end;
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

// Called when the extraction of a component is finished
procedure UpdateTotalProgressBar();
var
    TotalProgressBar   : TNewProgressBar;
    TotalProgressLabel : TLabel;
begin
    TotalProgressBar := TNewProgressBar(wpExtract.FindComponent('TotalProgressBar'));
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
    TotalProgressLabel := TLabel(wpExtract.FindComponent('TotalProgressLabel'));
    TotalProgressLabel.Caption := IntToStr(intInstalledComponentsCounter) + '/' +IntToStr(intTotalComponents);

    // Update ProgressBar
    TotalProgressBar.Position := (intInstalledComponentsCounter * 100);
    Log('# Processed Components '+IntToStr(intInstalledComponentsCounter) +'/'+IntToStr(intTotalComponents)+'.');
end;


// Called when the extraction of a new component starts.
procedure UpdateCurrentComponentName(component: String; bIsHashChecking: Boolean);
var
    CurrentComponentLabel : TLabel;
begin
    CurrentComponentLabel := TLabel(wpExtract.FindComponent('CurrentComponentLabel'));
    CurrentComponentLabel.Caption := component;
    if not bIsHashChecking then
      Log('# Extracting Component: ' + component);
end;

// Called when CurPageID=wpExtract.ID
procedure ExtractFiles();
var
  NullBox : TNewListBox;     // Dummy box
  NullBar : TNewProgressBar; // Dummy bar
  i : Integer;
  curFileChecksum : String;
begin
  if IsWin64 then
    ExtractTemporaryFile('7za_x64.exe')
  else
    ExtractTemporaryFile('7za_x86.exe');

  // Extract selected components
  for i := 0 to GetArrayLength(WebCompsArray) - 1 do
  begin
    if WizardIsComponentSelected(WebCompsArray[i].id) then
    begin
      // Check for corrupted files
      UpdateCurrentComponentName(WebCompsArray[i].name + ' - Checking file integrity...', true); // Update label

      curFileChecksum := GetSHA256OfFile(tmp(GetURLFilePart(WebCompsArray[i].URL)));

      Log('# ' + WebCompsArray[i].name + ' - Checksum (from .csv): ' + WebCompsArray[i].SHA256);
      Log('# ' + WebCompsArray[i].name + ' - Checksum (temp file): ' + curFileChecksum);

      if not SameText(curFileChecksum, WebCompsArray[i].SHA256) then
      begin
        MsgBox('Error: Checksum mismatch' #13#13 'File "' + GetURLFilePart(WebCompsArray[i].URL) + '" is corrupted.' #13#13 'The installation cannot continue. Please try again, and if the issue persists, report it to the developers.', mbInformation, MB_OK);
        ExitProcess(1);
      end;

      // Update label after integrity check
      UpdateCurrentComponentName(WebCompsArray[i].name, false);

      // Backup custom .ini settings if we are in maintenance mode
      if WebCompsArray[i].id = 'sh2emodule' then
      begin
        if maintenanceMode and FileExists(WizardDirValue + '\d3d8.ini') then
        begin 
          // Store current .ini settings into an array
          CurIniArray := IniToSettingsArray(WizardDirValue + '\d3d8.ini');
          if {#DEBUG} then Log('# Backed up d3d8.ini settings');
        end;
      end;
  
      // Backup the original .exe before extracting the new one, if a backup doesn't already exist
      if WebCompsArray[i].id = 'ee_exe' then
      begin
        if not FileExists(WizardDirValue + '\sh2pc.exe.bak') then
          RenameFile(WizardDirValue + '\sh2pc.exe', WizardDirValue + '\sh2pc.exe.bak');
      end;
  
      // Actually extract the files
      Extractore(tmp(GetURLFilePart(WebCompsArray[i].URL)), WizardDirValue, '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);
  
      // Restore .ini settings if we are in maintenance mode
      if WebCompsArray[i].id = 'sh2emodule' then
      begin
        if maintenanceMode and not (GetArrayLength(CurIniArray) = 0) then
        begin
          // Write stored .ini settings onto the new .ini file
          for i := 0 to GetArrayLength(CurIniArray) - 1 do begin
            with CurIniArray[i] do begin
              if not (Trim(CurIniArray[i].Key) = '') then
              begin 
                // Log(CurIniArray[i].Section + ' - ' + CurIniArray[i].Key + ' = ' + CurIniArray[i].Value);  // <--- Enabling this Log will somewhat break the SetIniString function. No idea why. Inno Setup bug?
                if IniKeyExists(CurIniArray[i].Section, CurIniArray[i].Key, WizardDirValue + '\d3d8.ini') then
                begin
                  SetIniString(CurIniArray[i].Section, CurIniArray[i].Key, CurIniArray[i].Value, WizardDirValue + '\d3d8.ini');
                  if {#DEBUG} then
                    Log('# key "' + CurIniArray[i].Key + '" has been restored');
                end else 
                if {#DEBUG} then
                  Log('# key "' + CurIniArray[i].Key + '" doesn''t exist in the new .ini file');
              end;
            end;
          end;
          if {#DEBUG} then Log('# Restored d3d8.ini settings');
        end;
      end;

      UpdateTotalProgressBar();
    end;
  end;

  WizardForm.NextButton.OnClick(WizardForm.NextButton);
end;

procedure postInstall();
var
  intErrorCode: Integer;
  ShouldUpdate: Boolean;
  i: Integer;
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
    // Check if there's an update available
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

procedure CurPageChanged(CurPageID: Integer);
var
  sh2pcFilesExist : Boolean;
begin

  // Customize wpSelectComponents for maintenanceMode
  if (CurPageID = wpSelectComponents) and maintenanceMode then
  begin
    if updateMode or updateRadioBtn.Checked then
    begin
      WizardForm.PageDescriptionLabel.Caption := 'Please select which enhancement packages you would like to update.'
      WizardForm.SelectComponentsLabel.Caption := 'Updates will be listed below if available.'
      WizardForm.SelectComponentsLabel.Height := 20;
      WizardForm.ComponentsList.Top := 30;
      WizardForm.ComponentsList.Height := 182;
    end else if installRadioBtn.Checked then 
    begin
      WizardForm.PageDescriptionLabel.Caption := 'Please select which enhancement packages you would like to install or repair.';
      WizardForm.SelectComponentsLabel.Caption := 'Silent Hill 2: Enhanced Edition is comprised of several enhancement packages. Select which enhancement packages you wish to install. For the full, intended experience, install all enhancement packages.'
      WizardForm.SelectComponentsLabel.Height := 40; // Default value
      WizardForm.ComponentsList.Top := 50; // Default value
      WizardForm.ComponentsList.Height := 162; // Default value 
    end;
  end;

  if CurPageID = wpExtract.ID then 
  begin
    Wizardform.NextButton.Enabled := false;
    WizardForm.BackButton.Visible := false;
    ExtractFiles();
  end;

  // Hide the run checkbox if the sh2pc files were present when the installation directory was selected, and we're not in maintenance mode 
  if (CurPageID = wpFinished) and not maintenanceMode and not sh2pcFilesWerePresent then
  begin
    WizardForm.RunList.Visible := false;
  end;

  // Check the run checkbox if the sh2pc files were present when the installation directory was selected, and we're not in maintenance mode 
  if (CurPageID = wpFinished) and not maintenanceMode and sh2pcFilesWerePresent then
  begin
    WizardForm.RunList.Checked[0] := true;
  end;

  // maintenanceMode's wpFinished tweaks
  if (CurPageID = wpFinished) and maintenanceMode then 
  begin
    sh2pcFilesExist := DirExists(AddBackslash(WizardDirValue) + 'data');

    if installRadioBtn.Checked = true then
    begin
      // Change default labels to fit the install action
      WizardForm.FinishedLabel.Caption := 'The wizard has successfully installed the selected enhancement packages.' #13#13 'Click finish to exit the wizard.';
      WizardForm.RunList.Visible       := true;
      WizardForm.RunList.Checked[0]    := true;
    end else
    if updateRadioBtn.Checked = true then
    begin
      // Change default labels to fit the update action
      WizardForm.FinishedHeadingLabel.Caption := 'Update complete!';
      WizardForm.FinishedLabel.Caption        := 'The wizard has successfully updated the selected enhancement packages.' #13#13 'Click finish to exit the wizard.';
      WizardForm.RunList.Visible              := true;
      WizardForm.RunList.Checked[0]           := true;
    end else 
    if uninstallRadioBtn.Checked = true then
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