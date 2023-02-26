[Code]

var
  wpMaintenance : TWizardPage;

  installRadioBtn   : TRadioButton;
  updateRadioBtn    : TRadioButton;
  adjustRadioBtn    : TRadioButton;
  uninstallRadioBtn : TRadioButton;

// Helper to populate wpSelectComponents's CheckListBox's labels
function wpUVersionLabel(OnlineVer: String; ExistVer: String; isInstalled: Boolean): String;
begin
  if isInstalled then
  begin
    if SameText(OnlineVer, ExistVer) then
      Result := CustomMessage('NoUpdateAvailable')
    else
      Result := CustomMessage('NewVersionAvailable') + ': ' + OnlineVer
  end else 
    Result := CustomMessage('NotInstalled');
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
var
  intErrorCode: Integer;
begin
    Result := True;

    if installRadioBtn.Checked or updateRadioBtn.Checked then
      GetComponentSizes();

    if adjustRadioBtn.Checked then
    begin
      if FileExists(ExpandConstant('{src}\') + 'SH2EEconfig.exe') then
        ShellExec('', ExpandConstant('{src}\') + 'SH2EEconfig.exe', '', '', SW_SHOW, ewNoWait, intErrorCode)
      else
      begin
        MsgBox(CustomMessage('SH2EEconfigNotFound'), mbCriticalError, MB_OK);
        Result := False;
      end;
    end;

    if uninstallRadioBtn.Checked then
    begin 
      if MsgBox(CustomMessage('UninstallConfirm'), mbConfirmation, MB_YESNO) = IDNO then
        Result := False
      else
        doCustomUninstall();
    end;
end;

// Creates the maintenance page
procedure PrepareMaintenance();
var
  installBmp         : TBitmapImage;
  updateBmp          : TBitmapImage;
  adjustBmp          : TBitmapImage;
  uninstallBmp       : TBitmapImage;
  nointernetBmp      : TBitmapImage;

  installLabel       : TLabel;
  updateLabel        : TLabel;
  adjustLabel        : TLabel;
  uninstallLabel     : TLabel;

begin
  ExtractTemporaryFile('icon_install.bmp');
  ExtractTemporaryFile('icon_update.bmp');
  ExtractTemporaryFile('icon_adjust.bmp');
  ExtractTemporaryFile('icon_uninstall.bmp');
  ExtractTemporaryFile('icon_nointernet.bmp');

  wpMaintenance := CreateCustomPage(wpWelcome, CustomMessage('MaintenanceTitle'), CustomMessage('MaintenanceLabel'));

  if uninstallOnly then
  begin
    nointernetBmp := TBitmapImage.Create(WizardForm);
    with nointernetBmp do
    begin
      AutoSize          := False;
      Stretch           := True;
      BackColor         := WizardForm.Color;
      ReplaceColor      := $FFFFFF;
      ReplaceWithColor  := WizardForm.Color;
      Left              := WizardForm.NextButton.Left - ScaleX(35);
      Top               := WizardForm.NextButton.Top - ScaleY(3);
      Anchors           := [akBottom, akRight];
      Width             := ScaleX(25);
      Height            := ScaleY(25);
      Parent            := WizardForm;
      Bitmap.LoadFromFile(ExpandConstant('{tmp}\icon_nointernet.bmp'));
    end;
  end;

  installBmp := TBitmapImage.Create(wpMaintenance);
  with installBmp do
  begin
    AutoSize          := False;
    Stretch           := True;
    BackColor         := wpMaintenance.Surface.Color;
    ReplaceColor      := $FFFFFF;
    ReplaceWithColor  := wpMaintenance.Surface.Color;
    Left              := ScaleX(16);
    Top               := ScaleY(5);
    Anchors           := [akTop, akLeft];
    Width             := ScaleX(38);
    Height            := ScaleY(38);
    Parent            := wpMaintenance.Surface;
    Bitmap.LoadFromFile(ExpandConstant('{tmp}\icon_install.bmp'));
  end;

  updateBmp := TBitmapImage.Create(wpMaintenance);
  with updateBmp do
  begin
    AutoSize          := False;
    Stretch           := True;
    BackColor         := wpMaintenance.Surface.Color;
    ReplaceColor      := $FFFFFF;
    ReplaceWithColor  := wpMaintenance.Surface.Color;
    Left              := installBmp.Left;
    Top               := installBmp.Top + ScaleY(74);
    Anchors           := [akTop, akLeft];
    Width             := ScaleX(38);
    Height            := ScaleY(38);
    Parent            := wpMaintenance.Surface;
    Bitmap.LoadFromFile(ExpandConstant('{tmp}\icon_update.bmp'));
  end;
  
  adjustBmp := TBitmapImage.Create(wpMaintenance);
  with adjustBmp do
  begin
    AutoSize          := False;
    Stretch           := True;
    BackColor         := wpMaintenance.Surface.Color;
    ReplaceColor      := $FFFFFF;
    ReplaceWithColor  := wpMaintenance.Surface.Color;
    Left              := updateBmp.Left;
    Top               := updateBmp.Top + ScaleY(74);
    Anchors           := [akTop, akLeft];
    Width             := ScaleX(38);
    Height            := ScaleY(38);
    Parent            := wpMaintenance.Surface;
    Bitmap.LoadFromFile(ExpandConstant('{tmp}\icon_adjust.bmp'));
  end;

  uninstallBmp := TBitmapImage.Create(wpMaintenance);
  with uninstallBmp do
  begin
    AutoSize          := False;
    Stretch           := True;
    BackColor         := wpMaintenance.Surface.Color;
    ReplaceColor      := $FFFFFF;
    ReplaceWithColor  := wpMaintenance.Surface.Color;
    Left              := adjustBmp.Left;
    Top               := adjustBmp.Top + ScaleY(74);
    Anchors           := [akTop, akLeft];
    Width             := ScaleX(38);
    Height            := ScaleY(38);
    Parent            := wpMaintenance.Surface;
    Bitmap.LoadFromFile(ExpandConstant('{tmp}\icon_uninstall.bmp'));
  end;

  installRadioBtn := TRadioButton.Create(wpMaintenance);
  with installRadioBtn do
  begin
    Enabled    := not uninstallOnly;
    Parent     := wpMaintenance.Surface;
    Caption    := CustomMessage('MaintenanceButtonInstall');
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
    Enabled    := not uninstallOnly;
    Parent     := wpMaintenance.Surface;
    Caption    := CustomMessage('MaintenanceButtonUpdate');
    Font.Style := [fsBold];
    Checked    := True;
    Left       := updateBmp.Left + ScaleX(54);
    Top        := updateBmp.Top;
    Anchors    := [akTop, akLeft];
    Width      := wpMaintenance.SurfaceWidth;
  end;
  
  adjustRadioBtn := TRadioButton.Create(wpMaintenance);
  with adjustRadioBtn do
  begin
    Parent     := wpMaintenance.Surface;
    Caption    := CustomMessage('MaintenanceButtonAdjust');
    Font.Style := [fsBold];
    Checked    := True;
    Left       := adjustBmp.Left + ScaleX(54);
    Top        := adjustBmp.Top;
    Anchors    := [akTop, akLeft];
    Width      := wpMaintenance.SurfaceWidth;
  end;

  uninstallRadioBtn := TRadioButton.Create(wpMaintenance);
  with uninstallRadioBtn do
  begin
    Parent     := wpMaintenance.Surface;
    Caption    := CustomMessage('MaintenanceButtonUninstall');
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
    Enabled    := not uninstallOnly;
    Parent     := wpMaintenance.Surface;
    Caption    := CustomMessage('MaintenanceLabelInstall');
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
    Enabled    := not uninstallOnly;
    Parent     := wpMaintenance.Surface;
    Caption    := CustomMessage('MaintenanceLabelUpdate');
    Left       := updateRadioBtn.Left;
    Top        := updateRadioBtn.Top + ScaleX(22);
    Width      := wpMaintenance.SurfaceWidth - ScaleX(70);
    Anchors    := [akTop, akLeft, akRight];
    WordWrap   := True;
    AutoSize   := True;
  end;
  
  adjustLabel := TLabel.Create(wpMaintenance);
  with adjustLabel do
  begin
    Parent     := wpMaintenance.Surface;
    Caption    := CustomMessage('MaintenanceLabelAdjust');
    Left       := adjustRadioBtn.Left;
    Top        := adjustRadioBtn.Top + ScaleX(22);
    Width      := wpMaintenance.SurfaceWidth - ScaleX(70);
    Anchors    := [akTop, akLeft, akRight];
    WordWrap   := True;
    AutoSize   := True;
  end;

  uninstallLabel := TLabel.Create(wpMaintenance);
  with uninstallLabel do
  begin
    Parent     := wpMaintenance.Surface;
    Caption    := CustomMessage('MaintenanceLabelUninstall');
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
end;