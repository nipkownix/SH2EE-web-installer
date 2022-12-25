[Code]

var
  wpExtract : TWizardPage;

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
        TotalProgressBar.Max := (iTotalCompCount * 100);
        Log('# ProgressBar.Max set to: [' + IntToStr(TotalProgressBar.Max) + '].');
    end;

    // increase counter
    intInstalledComponentsCounter := intInstalledComponentsCounter + 1;

    // Update Label
    TotalProgressLabel := TLabel(wpExtract.FindComponent('TotalProgressLabel'));
    TotalProgressLabel.Caption := IntToStr(intInstalledComponentsCounter) + '/' +IntToStr(iTotalCompCount);

    // Update ProgressBar
    TotalProgressBar.Position := (intInstalledComponentsCounter * 100);
    Log('# Processed Components '+IntToStr(intInstalledComponentsCounter) +'/'+IntToStr(iTotalCompCount)+'.');
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
procedure ExtractWebCSVFiles();
var
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
      if not (WebCompsArray[i].SHA256 = 'notUsed') then
      begin
        UpdateCurrentComponentName(WebCompsArray[i].name + ' - ' + CustomMessage('ChecksumCheck'), true); // Update label
  
        curFileChecksum := GetSHA256OfFile(localDataDir(GetURLFilePart(WebCompsArray[i].URL)));
  
        Log('# ' + WebCompsArray[i].name + ' - Checksum (from .csv): ' + WebCompsArray[i].SHA256);
        Log('# ' + WebCompsArray[i].name + ' - Checksum (temp file): ' + curFileChecksum);
  
        if not SameText(curFileChecksum, WebCompsArray[i].SHA256) then
        begin
          MsgBox(FmtMessage(CustomMessage('ChecksumMismatch'), [GetURLFilePart(WebCompsArray[i].URL)]), mbInformation, MB_OK);
          doCustomUninstall(); // Try to undo the changes done so far
          ExitProcess(1);
        end;
      end;

      // Update label after integrity check
      UpdateCurrentComponentName(WebCompsArray[i].name, false);

      // Custom actions for sh2emodule before extraction
      if WebCompsArray[i].id = 'sh2emodule' then
      begin
        if FileExists(WizardDirValue + '\d3d8.ini') then
        begin 
          // Backup current .ini settings into an array
          CurIniArray := IniToSettingsArray(WizardDirValue + '\d3d8.ini');
          if {#DEBUG} then Log('# Backed up d3d8.ini settings');

          // Try to delete old/unused sh2ee project files
          DeleteFile(WizardDirValue + '\d3d8.res');
          DeleteFile(WizardDirValue + '\d3d8.dat');
          DeleteFile(WizardDirValue + '\D3DCompiler_43.dll');
          DeleteFile(WizardDirValue + '\D3DX9_43.dll');
        end;
      end;
  
      // Custom actions for Xidi before extraction
      if WebCompsArray[i].id = 'xidi' then
      begin
        // Try to delete old XInput Plus files
        DeleteFile(WizardDirValue + '\Dinput.dll');
        DeleteFile(WizardDirValue + '\Dinput8.dll');
        DeleteFile(WizardDirValue + '\XInput1_3.dll');
        DeleteFile(WizardDirValue + '\XInput1_4.dll');
        DeleteFile(WizardDirValue + '\XInputPlus.ini');
      end;

      // Custom actions for the FMV Enhancement Pack before extraction
      if WebCompsArray[i].id = 'fmv_pack' then
      begin
        // Try to delete old Bink FMV files
        DeleteFile(WizardDirValue + '\sh2e\movie\credits.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\deai.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\end.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\ending.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\end_dog.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\end_wish.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\flash.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\gero.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\hakaba.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\hei.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\knife.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\korosu_a.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\korosu_b.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\murder.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\open.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\rouya.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\saikai.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\sh2e3.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\sh3e3.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\sh3tgs.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\toilet.bik');
        DeleteFile(WizardDirValue + '\sh2e\movie\water.bik');
      end;

      // Custom actions for Xidi before extraction
      if WebCompsArray[i].id = 'credits' then
      begin
        // Try to delete old Bink FMV files
        DeleteFile(WizardDirValue + '\sh2e\movie\credits.bik');
      end;

      // Backup the original .exe before extracting the new one, if a backup doesn't already exist
      if WebCompsArray[i].id = 'ee_exe' then
      begin
        if not FileExists(WizardDirValue + '\sh2pc.exe.bak') then
          RenameFile(WizardDirValue + '\sh2pc.exe', WizardDirValue + '\sh2pc.exe.bak');
      end;
  
      // Actually extract the files
      Extractore(localDataDir(GetURLFilePart(WebCompsArray[i].URL)), WizardDirValue, '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);

      // Delete extracted file to save space.
      if (Length(userPackageDataDir) = 0) then DeleteFile(tmp(GetURLFilePart(WebCompsArray[i].URL)));
  
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

  UpdateMaintenanceCSV(false);

  WizardForm.NextButton.OnClick(WizardForm.NextButton);
end;

// Called by wpExtract's OnActivate
procedure ExtractLocalCSVFiles();
var
  i : Integer;
begin
  if IsWin64 then
    ExtractTemporaryFile('7za_x64.exe')
  else
    ExtractTemporaryFile('7za_x86.exe');

  // Extract selected components
  for i := 0 to GetArrayLength(LocalCompsArray) - 1 do
  begin
    if WizardIsComponentSelected(LocalCompsArray[i].id) then
    begin
      // Update label
      UpdateCurrentComponentName(LocalCompsArray[i].name, false);
  
      // Backup the original .exe before extracting the new one, if a backup doesn't already exist
      if LocalCompsArray[i].id = 'ee_exe' then
      begin
        if not FileExists(WizardDirValue + '\sh2pc.exe.bak') then
          RenameFile(WizardDirValue + '\sh2pc.exe', WizardDirValue + '\sh2pc.exe.bak');
      end;
  
      // Actually extract the files
      Extractore(ExpandConstant('{src}\') + LocalCompsArray[i].fileName, WizardDirValue, '7zip', true, ExtractoreListBox, true, CurrentComponentProgressBar);

      UpdateTotalProgressBar();
    end;
  end;

  UpdateMaintenanceCSV(false);

  WizardForm.NextButton.OnClick(WizardForm.NextButton);
end;

// Start file extraction 
procedure wpExtractOnActivate(Sender: TWizardPage);
begin
  Wizardform.NextButton.Enabled := false;
  WizardForm.BackButton.Visible := false;

  if not localInstallMode then
    ExtractWebCSVFiles()
  else
    ExtractLocalCSVFiles();
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
  if iTotalCompCount = 0 then
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
  if not localInstallMode then
    // Create wpExtract and show it after the download page
    wpExtract := CreateCustomPage(IDPForm.Page.ID, CustomMessage('wpExtractTitle'), CustomMessage('wpExtractDesc'))
  else
    // Create wpExtract and show it after the wpReady page
    wpExtract := CreateCustomPage(wpReady, CustomMessage('wpExtractTitle'), CustomMessage('wpExtractDesc'));

  // Progress bars
  TotalProgressStaticText := TNewStaticText.Create(wpExtract);
  with TotalProgressStaticText do
  begin
      Parent    := wpExtract.Surface;
      Caption   := CustomMessage('TotalProgress');
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
      Caption   := CustomMessage('ExtractingComp');
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
