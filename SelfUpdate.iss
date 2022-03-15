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
  idpAddFile(WebCompsArray[0].URL, ExpandConstant('{src}\SH2EEsetup_new.exe'));

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