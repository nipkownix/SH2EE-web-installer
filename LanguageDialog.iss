[Code]

function SelectLanguage(forceDialog: Boolean): Boolean;
var
  progBmp     : TBitmapImage;
  LanguageForm: TSetupForm;
  CancelButton: TNewButton;
  OKButton    : TNewButton;
  LangCombo   : TNewComboBox;
  SelectLabel : TNewStaticText;
  Languages   : TStrings;
  RegLanguage : String;
  Params      : string;
  Instance    : THandle;
  P, I        : Integer;
  S, L        : string;
begin
  if RegValueExists(HKEY_CURRENT_USER, 'Software\nipkow\SH2EEsetup', 'lang') then
    RegQueryStringValue(HKEY_CURRENT_USER, 'Software\nipkow\SH2EEsetup', 'lang', RegLanguage);

  // Use registry value if it exists
  if not (RegLanguage = '') and maintenanceMode and not forceDialog then
  begin
    // Collect current instance parameters
    for I := 1 to ParamCount do
    begin
      S := ParamStr(I);
      // Unique log file name for the elevated instance
      if CompareText(Copy(S, 1, 5), '/LOG=') = 0 then
      begin
        S := S + '-localized';
      end;
      // /SL5 switch is an internal switch used to pass data
      // from the master Inno Setup process to the child process.
      // As we are starting a new master process, we have to remove it.
      // This should not be needed since Inno Setup 6.2,
      // see https://groups.google.com/g/innosetup/c/pDSbgD8nbxI
      if CompareText(Copy(S, 1, 5), '/SL5=') <> 0 then
      begin
        Params := Params + AddQuotes(S) + ' ';
      end;
    end;

    // ... and add selected language
    Params := Params + '/LANG=' + RegLanguage;

    Instance := ShellExecute(0, '', ExpandConstant('{srcexe}'), Params, '', SW_SHOW);
    if Instance <= 32 then
    begin
      S := 'Running installer with the selected language failed. Code: %d';
      MsgBox(Format(S, [Instance]), mbError, MB_OK);
      Result := false;
    end else
      Result := true;
  end else
  // Show dialog
  begin
    ExtractTemporaryFile('top.bmp');
  
    Languages := TStringList.Create();
  
    Languages.Add('en={#english_lang_name}');
    Languages.Add('pt_br={#brazilianPortuguese_lang_name}');
    Languages.Add('es={#spanish_lang_name}');
  
    LanguageForm := CreateCustomForm;
    with LanguageForm do
    begin
      Caption := SetupMessage(msgSelectLanguageTitle);
      ClientWidth := ScaleX(297);
      ClientHeight := ScaleY(110);
      Color := clWhite;
      BorderStyle := bsDialog;
    end;
  
    progBmp := TBitmapImage.Create(LanguageForm);
    with progBmp do
    begin;
      AutoSize          := False;
      Stretch           := True;
      BackColor         := LanguageForm.Color;
      ReplaceColor      := $FFFFFF;
      ReplaceWithColor  := LanguageForm.Color;
      Left              := ScaleX(16);
      Top               := ScaleY(5);
      Anchors           := [akTop, akLeft];
      Width             := ScaleX(38);
      Height            := ScaleY(38);
      Parent            := LanguageForm;
      Bitmap.LoadFromFile(ExpandConstant('{tmp}\top.bmp'));
    end;
  
    SelectLabel := TNewStaticText.Create(LanguageForm);
    with SelectLabel do
    begin
      Parent    := LanguageForm;
      Left      := progBmp.Left + progBmp.Width + ScaleY(15);
      Top       := ScaleY(8);
      Width     := LanguageForm.ClientWidth;
      Height    := ScaleY(39);
      AutoSize  := False
      Caption   := SetupMessage(msgSelectLanguageLabel);
      TabOrder  := 0;
      WordWrap  := True;
    end;
  
    LangCombo := TNewComboBox.Create(LanguageForm);
    with LangCombo do
    begin
      Parent        := LanguageForm;
      Left          := SelectLabel.Left;
      Top           := ScaleY(56);
      Width         := LanguageForm.ClientWidth - ScaleX(16) * 2;
      Height        := ScaleY(21);
      Style         := csDropDownList;
      DropDownCount := 16;
      TabOrder      := 1;
    end;
  
    CancelButton := TNewButton.Create(LanguageForm);
    with CancelButton do
    begin
      Parent      := LanguageForm;
      Top         := ScaleY(93);
      Width       := ScaleY(75);
      Left        := LangCombo.Left + LangCombo.Width - CancelButton.Width;
      Height      := ScaleY(23);
      TabOrder    := 3;
      ModalResult := mrCancel;
      Caption     := SetupMessage(msgButtonCancel);
    end;
  
    OKButton := TNewButton.Create(LanguageForm);
    with OKButton do
    begin
      Parent      := LanguageForm;
      Top         := LangCombo.Top + LangCombo.Height + ScaleX(16);
      Width       := ScaleY(75);
      Left        := CancelButton.Left - OKButton.Width - ScaleX(8);
      Height      := ScaleY(23);
      Caption     := SetupMessage(msgButtonOK);
      Default     := True
      ModalResult := mrOK;
      TabOrder    := 2;
    end;
  
    for I := 0 to Languages.Count - 1 do
    begin
      P := Pos('=', Languages.Strings[I]);
      L := Copy(Languages.Strings[I], 0, P - 1);
      S := Copy(Languages.Strings[I], P + 1, Length(Languages.Strings[I]) - P);
      LangCombo.Items.Add(S);
      if L = ActiveLanguage then
        LangCombo.ItemIndex := I;
    end;
  
    // Restart the installer with the selected language
    if LanguageForm.ShowModal = mrOK then
    begin
      // Collect current instance parameters
      for I := 1 to ParamCount do
      begin
        S := ParamStr(I);
        // Unique log file name for the elevated instance
        if CompareText(Copy(S, 1, 5), '/LOG=') = 0 then
        begin
          S := S + '-localized';
        end;
        // /SL5 switch is an internal switch used to pass data
        // from the master Inno Setup process to the child process.
        // As we are starting a new master process, we have to remove it.
        // This should not be needed since Inno Setup 6.2,
        // see https://groups.google.com/g/innosetup/c/pDSbgD8nbxI
        if CompareText(Copy(S, 1, 5), '/SL5=') <> 0 then
        begin
          Params := Params + AddQuotes(S) + ' ';
        end;
      end;
  
      L := Languages.Strings[LangCombo.ItemIndex];
      P := Pos('=', L);
      L := Copy(L, 0, P-1);
  
      // ... and add selected language
      Params := Params + '/LANG=' + L;
  
      RegWriteStringValue(HKEY_CURRENT_USER, 'Software\nipkow\SH2EEsetup', 'lang', L);
  
      Instance := ShellExecute(0, '', ExpandConstant('{srcexe}'), Params, '', SW_SHOW);
      if Instance <= 32 then
      begin
        S := 'Running installer with the selected language failed. Code: %d';
        MsgBox(Format(S, [Instance]), mbError, MB_OK);
        Result := false;
      end else
        Result := true;
    end else
    begin
      Result := false;
    end;
  end;
end;