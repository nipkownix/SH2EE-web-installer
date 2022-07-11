[Code]

procedure WebsiteLabelClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('open', '{#PROJECT_URL}', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure TroubleshootLabelClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('open', '{#TROUBLESHOOT_URL}', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure GitHubLabelClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('open', '{#HELP_URL}', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure Replace_Labels;
var
  newWelcomeLabel1: TNewStaticText;
  newWelcomeLabel2: TNewStaticText;
  newWelcomeLabel3: TNewStaticText;
  newWelcomeLabel4: TNewStaticText;
  newWelcomeLabel5: TNewStaticText;

  newFinishedLabel              : TNewStaticText;
  UsefulLinksLabel              : TNewStaticText;
  ProjectWebsiteLabelTitle      : TNewStaticText;
  ProjectWebsiteLabelDesc       : TNewStaticText;
  TroubleshootingPageLabelTitle : TNewStaticText;
  TroubleshootingPageLabelDesc  : TNewStaticText;
  GitHubPageLabelTitle          : TNewStaticText;
  GitHubPageLabelDesc           : TNewStaticText;
begin
  // Gotta use multiple labels here, because Inno doesn't support having bold words, only entire labels can be formatted. Meh. 

  // "Welcome" page
  WizardForm.WelcomeLabel2.Visible := False; // Disable original "welcome" label

  newWelcomeLabel1 := TNewStaticText.Create(WizardForm);
  with newWelcomeLabel1 do
  begin
    AutoSize  := False;
    WordWrap  := True;
    Left      := WizardForm.WelcomeLabel2.Left;
    Top       := WizardForm.WelcomeLabel2.Top;
    Height    := ScaleY(40);
    Parent    := WizardForm.WelcomeLabel2.Parent;
    Caption   := CustomMessage('newWelcomeLabel1');
  end;
  
  newWelcomeLabel2 := TNewStaticText.Create(WizardForm);
  with newWelcomeLabel2 do
  begin
    AutoSize   := False;
    WordWrap   := True;
    Left       := newWelcomeLabel1.Left;
    Top        := newWelcomeLabel1.Top + newWelcomeLabel1.Height;
    Height     := ScaleY(30);
    Parent     := newWelcomeLabel1.Parent;
    Caption    := CustomMessage('newWelcomeLabel2');
    Font.Style := [fsBold];
  end;

  newWelcomeLabel3 := TNewStaticText.Create(WizardForm);
  with newWelcomeLabel3 do
  begin
    AutoSize  := False;
    WordWrap  := True;
    Left      := newWelcomeLabel2.Left;
    Top       := newWelcomeLabel2.Top + newWelcomeLabel2.Height;
    Height    := ScaleY(40);
    Parent    := newWelcomeLabel2.Parent;
    Caption   := CustomMessage('newWelcomeLabel3');
  end;

  newWelcomeLabel4 := TNewStaticText.Create(WizardForm);
  with newWelcomeLabel4 do
  begin
    AutoSize   := False;
    WordWrap   := True;
    Left       := newWelcomeLabel3.Left;
    Top        := newWelcomeLabel3.Top + newWelcomeLabel3.Height;
    Height     := ScaleY(30);
    Parent     := newWelcomeLabel3.Parent;
    Caption    := CustomMessage('newWelcomeLabel4');
    Font.Style := [fsBold];
  end;

  newWelcomeLabel5 := TNewStaticText.Create(WizardForm);
  with newWelcomeLabel5 do
  begin
    AutoSize  := False;
    WordWrap  := True;
    Left      := newWelcomeLabel4.Left;
    Top       := newWelcomeLabel4.Top + newWelcomeLabel4.Height;
    Height    := ScaleY(30);
    Parent    := newWelcomeLabel4.Parent;
    Caption   := CustomMessage('newWelcomeLabel5');
  end;
  
  // "Finished" page
  WizardForm.FinishedLabel.Visible := False; // Hide original "FinishedLabel"

  newFinishedLabel := TNewStaticText.Create(WizardForm);
  with newFinishedLabel do
  begin
    AutoSize  := False;
    WordWrap  := True;
    Left      := WizardForm.FinishedLabel.Left;
    Top       := WizardForm.FinishedLabel.Top;
    Height    := ScaleY(80);
    Parent    := WizardForm.FinishedLabel.Parent;
    Caption   := CustomMessage('newFinishedLabel');
  end;

  UsefulLinksLabel := TNewStaticText.Create(WizardForm);
  with UsefulLinksLabel do
  begin
    AutoSize   := False;
    WordWrap   := True;
    Left       := newFinishedLabel.Left;
    Top        := newFinishedLabel.Top + newFinishedLabel.Height;
    Height     := ScaleY(20);
    Parent     := newFinishedLabel.Parent;
    Caption    := CustomMessage('UsefulLinksLabel');
    Font.Style := [fsBold];
  end;

  ProjectWebsiteLabelTitle := TNewStaticText.Create(WizardForm);
  with ProjectWebsiteLabelTitle do
  begin
    AutoSize   := False;
    WordWrap   := True;
    Left       := UsefulLinksLabel.Left;
    Top        := UsefulLinksLabel.Top + UsefulLinksLabel.Height;
    Height     := ScaleY(20);
    Parent     := UsefulLinksLabel.Parent;
    Caption    := CustomMessage('ProjectWebsiteLabelTitle');
    Font.Color := clBlue;
    Font.Style := [fsUnderline];
    OnClick    := @WebsiteLabelClick;;
  end;

  ProjectWebsiteLabelDesc := TNewStaticText.Create(WizardForm);
  with ProjectWebsiteLabelDesc do
  begin
    AutoSize  := False;
    WordWrap  := True;
    Left      := ProjectWebsiteLabelTitle.Left;
    Top       := ProjectWebsiteLabelTitle.Top + ProjectWebsiteLabelTitle.Height;
    Height    := ScaleY(30);
    Parent    := ProjectWebsiteLabelTitle.Parent;
    Caption   := '     ' + CustomMessage('ProjectWebsiteLabelDesc');
  end;

  TroubleshootingPageLabelTitle := TNewStaticText.Create(WizardForm);
  with TroubleshootingPageLabelTitle do
  begin
    AutoSize   := False;
    WordWrap   := True;
    Left       := ProjectWebsiteLabelDesc.Left;
    Top        := ProjectWebsiteLabelDesc.Top + ProjectWebsiteLabelDesc.Height;
    Height     := ScaleY(20);
    Parent     := ProjectWebsiteLabelDesc.Parent;
    Caption    := CustomMessage('TroubleshootingPageLabelTitle');
    Font.Color := clBlue;
    Font.Style := [fsUnderline];
    OnClick    := @TroubleshootLabelClick;;
  end;

  TroubleshootingPageLabelDesc := TNewStaticText.Create(WizardForm);
  with TroubleshootingPageLabelDesc do
  begin
    AutoSize  := False;
    WordWrap  := True;
    Left      := TroubleshootingPageLabelTitle.Left;
    Top       := TroubleshootingPageLabelTitle.Top + TroubleshootingPageLabelTitle.Height;
    Height    := ScaleY(30);
    Parent    := TroubleshootingPageLabelTitle.Parent;
    Caption   := '     ' + CustomMessage('TroubleshootingPageLabelDesc');
  end;

  GitHubPageLabelTitle := TNewStaticText.Create(WizardForm);
  with GitHubPageLabelTitle do
  begin
    AutoSize   := False;
    WordWrap   := True;
    Left       := TroubleshootingPageLabelDesc.Left;
    Top        := TroubleshootingPageLabelDesc.Top + TroubleshootingPageLabelDesc.Height;
    Height     := ScaleY(20);
    Parent     := TroubleshootingPageLabelDesc.Parent;
    Caption    := CustomMessage('GitHubPageLabelTitle');
    Font.Color := clBlue;
    Font.Style := [fsUnderline];
    OnClick    := @GitHubLabelClick;
  end;

  GitHubPageLabelDesc := TNewStaticText.Create(WizardForm);
  with GitHubPageLabelDesc do
  begin
    AutoSize  := False;
    WordWrap  := True;
    Left      := GitHubPageLabelTitle.Left;
    Top       := GitHubPageLabelTitle.Top + GitHubPageLabelTitle.Height;
    Height    := ScaleY(30);
    Parent    := GitHubPageLabelTitle.Parent;
    Caption   := '     ' + CustomMessage('GitHubPageLabelDesc');
  end;

  // Tweak RunList
  with WizardForm.RunList do
  begin
    Anchors := [akLeft, akBottom];
    Top     := WizardForm.CancelButton.Top - ScaleY(30);
  end;
end;