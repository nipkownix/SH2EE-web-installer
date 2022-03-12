[Code]

var
  wpExtract : TWizardPage;

  intTotalComponents : Integer;
  selectedComponents : String;

  ExtractoreListBox : TNewListBox;

  CurrentComponentProgressBar  : TNewProgressBar;
  TotalProgressBar             : TNewProgressBar;

  TotalProgressLabel    : TLabel;
  CurrentComponentLabel : TLabel;

  intInstalledComponentsCounter : Integer;

// Called when the extraction of a component is finished
procedure UpdateTotalProgressBar();
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
begin
    CurrentComponentLabel := TLabel(wpExtract.FindComponent('CurrentComponentLabel'));
    CurrentComponentLabel.Caption := component;
    if not bIsHashChecking then
      Log('# Extracting Component: ' + component);
end;

// Called by wpExtract's OnActivate
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

// Start file extraction 
procedure wpExtractOnActivate(Sender: TWizardPage);
begin
  Wizardform.NextButton.Enabled := false;
  WizardForm.BackButton.Visible := false;
  ExtractFiles();
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
  // Create wpExtract and show it after the download page
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
      OnActivate          := @wpExtractOnActivate;
      OnCancelButtonClick := @wpExtractCancelButtonClick;
      OnShouldSkipPage    := @wpExtractShouldSkipPage;
  end;
end;