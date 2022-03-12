[Code]

var
  wpMaintenance : TWizardPage;

  installRadioBtn   : TRadioButton;
  updateRadioBtn    : TRadioButton;
  uninstallRadioBtn : TRadioButton;

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
  
  // Hide TypesCombo 
  WizardForm.TypesCombo.Visible := False;
  WizardForm.IncTopDecHeight(WizardForm.ComponentsList, - (WizardForm.ComponentsList.Top - WizardForm.TypesCombo.Top));
end;