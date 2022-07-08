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
      wpSelectBackupDir := CreateInputDirPage(wpInstallMode.ID, 'Select Enhancement Packages Backup Location', 'Where should the backup files be stored?',
      'The Enhancement Packages be stored in the following folder.'#13#10#13#10 +
      'To continue, click Next. If you would like to select a different folder, click Browse.',
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

  wpInstallMode := CreateCustomPage(wpLicense, 'Select Installation Mode', 'How should Silent Hill 2: Enhanced Edition be installed?');

  normalInstallRadioBtn := TRadioButton.Create(wpInstallMode);
  with normalInstallRadioBtn do
  begin
    Parent     := wpInstallMode.Surface;
    Caption    := 'Install enhancement packages (recommended)';
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
    Caption    := 'Install and backup enhancement packages';
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
    Caption    := 'Downloads the enhancement packages to a temporary folder for project installation.';
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
    Caption    := 'Downloads the enhancement packages to a specified folder as a backup and install the project files.';
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