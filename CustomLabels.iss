[Code]

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