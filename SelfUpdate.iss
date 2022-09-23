[Code]

var
  wpSelfUpdate : TWizardPage;

procedure wpSelfUpdateOnActivate(Page: TWizardPage);
begin
  WizardForm.NextButton.OnClick(WizardForm.NextButton);
end;

// Prepare for the self-update procedure
procedure PrepareSelfUpdate();
begin
  ExtractTemporaryFile('renamefile_util.exe');

  // Add file to IDP list
  idpAddFile(WebCompsArray[0].URL, tmp('SH2EEsetup_new.exe'));

  // The "Retry" button sometimes bugs out in this page, for some reason. Best to just disable it.
  idpSetOption('RetryButton', '0');

  // Create a dummy self update page, so IDP can start straight away
  wpSelfUpdate := CreateCustomPage(wpWelcome, 'Silent Hill 2: EE Setup Tool self-update', 'Self-update in progress');
  idpDownloadAfter(wpSelfUpdate.ID);

  with wpSelfUpdate do
  begin
      OnActivate := @wpSelfUpdateOnActivate;
  end;
end;

procedure SelfUpdate_postInstall();
var
  webInstallerChecksum: String;
  i: Integer;
  intErrorCode: Integer;
  ShouldUpdateComps: Boolean;
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

  // Copy installer to orig folder
  if not FileCopy(tmp('SH2EEsetup_new.exe'), ExpandConstant('{src}\SH2EEsetup_new.exe'), false) then
    RaiseException('Failed to copy installer to folder.');

  // Do stuff if we're selfUpdating from an existing install
  if DirExists(ExpandConstant('{src}\') + 'data') and FileExists(ExpandConstant('{src}\') + 'SH2EEsetup.dat') then
  begin
    UpdateMaintenanceCSV(false);
  
    // Check if there's an update available for any component
    for i := 0 to GetArrayLength(WebCompsArray) - 1 do begin
      if not (WebCompsArray[i].id = 'setup_tool') then
      begin
        if isUpdateAvailable(WebCompsArray[i].Version, MaintenanceCompsArray[i].Version, MaintenanceCompsArray[i].isInstalled) then
          ShouldUpdateComps := True;
      end;
    end;
  end;

  // Schedule SH2EEsetup_new.exe for renaming as soon as possible
  if not ShouldUpdateComps and CmdLineParamExists('-selfUpdate') then
  begin
    // Don't reopen the setup tool if launched with the -selfUpdate parameter and there's no update available
    ShellExec('', ExpandConstant('{tmp}\') + 'renamefile_util.exe', AddQuotes(ExpandConstant('{srcexe}')) + ' false false', '', SW_HIDE, ewNoWait, intErrorCode);
    // Run launcher
    if FileExists(ExpandConstant('{src}\') + 'SH2EEconfig.exe') then
      ShellExec('', ExpandConstant('{src}\') + 'SH2EEconfig.exe', '', '', SW_SHOW, ewNoWait, intErrorCode);
  end
  else
  if ShouldUpdateComps and CmdLineParamExists('-selfUpdate') then
    // Open the updater page after renaming
    ShellExec('', ExpandConstant('{tmp}\') + 'renamefile_util.exe', AddQuotes(ExpandConstant('{srcexe}')) + ' true true', '', SW_HIDE, ewNoWait, intErrorCode)
  else
    // Don't open the updater page after renaming
    ShellExec('', ExpandConstant('{tmp}\') + 'renamefile_util.exe', AddQuotes(ExpandConstant('{srcexe}')) + ' true false', '', SW_HIDE, ewNoWait, intErrorCode);
end;