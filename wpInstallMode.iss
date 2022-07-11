[Code]

var
  wpInstallMode : TWizardPage;
  wpSelectBackupDir : TInputDirWizardPage;

  normalInstallRadioBtn   : TRadioButton;
  backupInstallRadioBtn   : TRadioButton;

function wpSelectBackupDir_NextClick(Page: TWizardPage): Boolean;
begin
    Result := True;

    userPackageDataDir := wpSelectBackupDir.Values[0] + '_' + GetDateTimeString('dd-mm_h.n.ss', #0, #0);
	
	if not CreateDir(userPackageDataDir) then
		RaiseException('Failed create backup folder.');
		
    Log(userPackageDataDir);
end;

function wpSelectBackupDir_ShouldSkip(Page: TWizardPage): Boolean;
begin
    Result := normalInstallRadioBtn.Checked;
end;

function wpInstallModeNextClick(Page: TWizardPage): Boolean;
begin
    Result := True;

    if backupInstallRadioBtn.Checked then
    begin
      wpSelectBackupDir := CreateInputDirPage(wpInstallMode.ID, CustomMessage('BackupLocationTitle'),
        CustomMessage('BackupLocationDesc'), CustomMessage('BackupLocationBrowse'),
        True, 'sh2ee_packages');

      wpSelectBackupDir.Add('');

      with wpSelectBackupDir do
      begin
          OnNextButtonClick := @wpSelectBackupDir_NextClick;
          OnShouldSkipPage := @wpSelectBackupDir_ShouldSkip;
      end;

    end;
end;

// Creates the maintenance page
procedure PrepareInstallModePage();
var
  normalInstallLabel       : TLabel;
  backupInstallLabel       : TLabel;

begin

  wpInstallMode := CreateCustomPage(wpLicense, CustomMessage('IstallModeTitle'), CustomMessage('IstallModeDesc'));

  normalInstallRadioBtn := TRadioButton.Create(wpInstallMode);
  with normalInstallRadioBtn do
  begin
    Parent     := wpInstallMode.Surface;
    Caption    := CustomMessage('normalInstallBtn');
    Font.Style := [fsBold];
    Checked    := True;
    Left       := ScaleX(16);
    Top        := ScaleY(5);
    Anchors    := [akTop, akLeft];
    Width      := wpInstallMode.SurfaceWidth;
  end;

  backupInstallRadioBtn := TRadioButton.Create(wpInstallMode);
  with backupInstallRadioBtn do
  begin
    Parent     := wpInstallMode.Surface;
    Caption    := CustomMessage('backupInstallBtn');
    Font.Style := [fsBold];
    Checked    := False;
    Left       := normalInstallRadioBtn.Left;
    Top        := normalInstallRadioBtn.Top + ScaleY(74);
    Anchors    := [akTop, akLeft];
    Width      := wpInstallMode.SurfaceWidth;
  end;

  normalInstallLabel := TLabel.Create(wpInstallMode);
  with normalInstallLabel do
  begin
    Parent     := wpInstallMode.Surface;
    Caption    := CustomMessage('normalInstallLabel');
    Left       := normalInstallRadioBtn.Left + ScaleX(17);
    Top        := normalInstallRadioBtn.Top + ScaleX(22);
    Width      := wpInstallMode.SurfaceWidth - ScaleX(70);
    Anchors    := [akTop, akLeft, akRight];
    WordWrap   := True;
    AutoSize   := True;
  end;

  backupInstallLabel := TLabel.Create(wpInstallMode);
  with backupInstallLabel do
  begin
    Parent     := wpInstallMode.Surface;
    Caption    := CustomMessage('backupInstallLabel');
    Left       := backupInstallRadioBtn.Left + ScaleX(17);
    Top        := backupInstallRadioBtn.Top + ScaleX(22);
    Width      := wpInstallMode.SurfaceWidth - ScaleX(70);
    Anchors    := [akTop, akLeft, akRight];
    WordWrap   := True;
    AutoSize   := True;
  end;

  with wpInstallMode do
  begin
      OnNextButtonClick := @wpInstallModeNextClick;
  end;

end;