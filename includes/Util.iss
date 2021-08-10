// Inno Setup - Util.iss



[Code]
var
  GCS_sh2pcPath: string;


type
  TWebComponentsInfo    = record
    ID                  : String;
    Name                : String;
    Version             : String;
    URL                 : String;
    ReqInstallerVersion : String;
    SHA512              : String;
  end;

  TLocalComponentsInfo  = record
    ID                  : String;
    isInstalled         : Boolean;
    Version             : String;
  end;

  TIniArray             = record
    Section             : String;
    Key                 : String;
    Value               : String;
  end;

// Returns true if the setup was started with a specific parameter
function CmdLineParamExists(const Value: string): Boolean;
var
  I: Integer;  
begin
  Result := False;
  for I := 1 to ParamCount do
    if CompareText(ParamStr(I), Value) = 0 then
    begin
      Result := True;
      Exit;
    end;
end;

// Given a text filename, replace a string with another
function FileReplaceString(const FileName, SearchString, ReplaceString: string): Boolean;
var
  MyFile : TStrings;
  MyText : string;
begin
  MyFile := TStringList.Create;

  try
    result := true;

    try
      MyFile.LoadFromFile(FileName);
      MyText := MyFile.Text;

      { Only save if text has been changed. }
      if StringChangeEx(MyText, SearchString, ReplaceString, True) > 0 then
      begin;
        MyFile.Text := MyText;
        MyFile.SaveToFile(FileName);
      end;
    except
      result := false;
    end;
  finally
    MyFile.Free;
  end;
end;

// BoolToStr Helper function
function BoolToStr(Value: Boolean): String; 
begin
  if Value then Result := 'true'
  else Result := 'false';
end;

// Wrapper function for returning a path relative to {tmp}
function tmp(Path: String): String;
begin
  Result := ExpandConstant('{tmp}\') + Path;
end;

// Search for sh2pc.exe in "\HKEY_CURRENT_USER\System\GameConfigStore\Children\"
procedure RegSearch(RootKey: Integer; KeyName: string);
var
  I: Integer;
  Names: TArrayOfString;
  Name: string;
  FoundPaths: String;
begin
  if RegGetSubkeyNames(RootKey, KeyName, Names) then
  begin
    for I := 0 to GetArrayLength(Names) - 1 do
    begin
      Name := KeyName + '\' + Names[I];

      //if {#DEBUG} then Log(Format('Found key %s', [Name]));

      RegSearch(RootKey, Name);
    end;
  end;

  if RegGetValueNames(RootKey, KeyName, Names) then
  begin
    for I := 0 to GetArrayLength(Names) - 1 do
    begin
      Name := KeyName + '\' + Names[I];

      if Pos('MatchedExeFullPath', Name) > 0 then
      begin
        //if {#DEBUG} then Log(Format('Found value %s', [Name]));

        if RegQueryStringValue(HKEY_CURRENT_USER, KeyName, 'MatchedExeFullPath', FoundPaths) then
        begin
          //if {#DEBUG} then Log(Format('Found Path %s', [FoundPaths]));

          if Pos('sh2pc.exe', FoundPaths) > 0 then
          begin
            if FileExists(ExtractFilePath(FoundPaths) + '\sh2pc.exe') then
            begin
              if {#DEBUG} then Log(Format('sh2pc.exe found at: %s', [FoundPaths]));
              GCS_sh2pcPath := ExtractFilePath(FoundPaths);
            end;
          end;
        end;
      end;
    end;
  end;
end;

// Return a DefaultDirName based on conditions
function GetDefaultDirName(Param: string): string;
var 
  InstallationPath : String;
  RetailInstallDir : String;
begin
  if InstallationPath = '' then
  begin
    // Search registry if we're not in maintenance mode
    if not maintenanceMode then 
      RegSearch(HKEY_CURRENT_USER, 'System\GameConfigStore');

    // Actually choose a path
    if maintenanceMode then
      InstallationPath := ExpandConstant('{src}\')
    else
    if RegQueryStringValue(HKLM32, 'Software\Konami\Silent Hill 2', 'INSTALLDIR', RetailInstallDir) and FileExists(RetailInstallDir + '\sh2pc.exe') then 
      InstallationPath := RetailInstallDir
    else
    if not (GCS_sh2pcPath = '') then
      InstallationPath := GCS_sh2pcPath
    else
      InstallationPath := ExpandConstant('{autopf}\') + 'Konami\Silent Hill 2\'; 
  end;
  Result := InstallationPath;
end;

// Recursive function called by SplitString
function SplitStringRec(Str: String; Delim: String; StrList: TStringList): TStringList;
var
  StrHead: String;
  StrTail: String;
  DelimPos: Integer;
begin
  DelimPos := Pos(Delim, Str);
  if DelimPos = 0 then begin
    StrList.Add(Str);
    Result := StrList;
  end else begin
    StrHead := Str;
    StrTail := Str;
    Delete(StrHead, DelimPos, Length(StrTail));
    Delete(StrTail, 1, DelimPos);
    StrList.Add(StrHead);
    Result := SplitStringRec(StrTail, Delim, StrList);
  end;
end;
// Given a string and a delimiter, returns the strings separated by the delimiter
// as a TStringList object
function SplitString(Str: String; Delim: String): TStringList;
begin
  Result := SplitStringRec(Str, Delim, TStringList.Create);
end;

// Given a .csv file, return an array of information corresponding to
// the data in the csv file.
function WebCSVToInfoArray(Filename: String): array of TWebComponentsInfo;
var
  Rows: TArrayOfString;
  RowValues: TStrings;
  i: Integer;
begin
  // Read the file at Filename and store the lines in Rows
  if LoadStringsFromFile(Filename, Rows) then begin
    // Match length of return array to number of rows
    SetArrayLength(Result, GetArrayLength(Rows) - 1);
    for i := 1 to GetArrayLength(Rows) - 1 do begin
      // Separate values at commas
      RowValues := SplitString(Rows[i], ',');
      with Result[i - 1] do begin
        ID := RowValues[0];
        Name := RowValues[1];
        Version := RowValues[2];
        URL := RowValues[3];
      end;
    end;
  end else begin
    SetArrayLength(Result, 0);
  end;
end;

// Same as above, but tailored to use a different format
function LocalCSVToInfoArray(Filename: String): array of TLocalComponentsInfo;
var
  Rows: TArrayOfString;
  RowValues: TStrings;
  i: Integer;
begin
  // Read the file at Filename and store the lines in Rows
  if LoadStringsFromFile(Filename, Rows) then begin
    // Match length of return array to number of rows
    SetArrayLength(Result, GetArrayLength(Rows) - 2);
    for i := 1 to GetArrayLength(Rows) - 2 do begin
      // Separate values at commas
      RowValues := SplitString(Rows[i + 1], ',');
      with Result[i - 1] do begin
        try
          ID := RowValues[0];
          isInstalled := StrToBool(RowValues[1]);
          Version := RowValues[2];
        except
          Log('user might have edited the local .csv');
        end;
      end;
    end;
  end else begin
    SetArrayLength(Result, 0);
  end;
end;

// Given a .ini file, return an array of settings corresponding to
// the data in the ini file.
function IniToSettingsArray(Filename: String): array of TIniArray;
var
  Rows: TArrayOfString;
  RowValues: TStrings;
  IniSection: String;
  i: Integer;
begin
  // Read the file at Filename and store the lines in Rows
  if LoadStringsFromFile(Filename, Rows) then begin
    // Match length of return array to number of rows
    SetArrayLength(Result, GetArrayLength(Rows) - 1);
    for i := 1 to GetArrayLength(Rows) - 1 do begin
      if (Pos('[', Rows[i]) > 0) and not (Pos(';', Rows[i]) > 0) then begin
        IniSection := Rows[i];
        Delete(IniSection, 1, 1); 
        Delete(IniSection, Length(IniSection), 1); 
      end;
      if (Pos('=', Rows[i]) > 0) and not (Pos(';', Rows[i]) > 0) then
      begin
        // Separate values
        RowValues := SplitString(Rows[i], '=');
        with Result[i - 1] do begin
          Section := IniSection;
          Key := RowValues[0];
          Value := RowValues[1];
        end;
      end;
    end;
  end else begin
    SetArrayLength(Result, 0);
  end;
end;

// Recursive function called by GetURLFilePart
function GetURLFilePartRec(URL: String): String;
var
  SlashPos: Integer;
begin
  SlashPos := Pos('/', URL);
  if SlashPos = 0 then begin
    Result := URL;
  end else begin;
    Delete(URL, 1, SlashPos);
    Result := GetURLFilePartRec(URL);
  end;
end;

// Given a URL to a file, returns the filename portion of the URL
function GetURLFilePart(URL: String): String;
begin
  Delete(URL, 1, Pos('://', URL) + 2);
  Result := GetURLFilePartRec(URL);
end;

// wpSelectComponents helpers
var
  LastMouse        : TPoint;
  CompTitle        : TLabel;
  CompDescription  : TLabel;

function GetCursorPos(var lpPoint: TPoint): BOOL;
  external 'GetCursorPos@user32.dll stdcall';
function SetTimer(
  hWnd: longword; nIDEvent, uElapse: LongWord; lpTimerFunc: LongWord): LongWord;
  external 'SetTimer@user32.dll stdcall';
function ScreenToClient(hWnd: HWND; var lpPoint: TPoint): BOOL;
  external 'ScreenToClient@user32.dll stdcall';
function ClientToScreen(hWnd: HWND; var lpPoint: TPoint): BOOL;
  external 'ClientToScreen@user32.dll stdcall';
function ListBox_GetItemRect(
  const hWnd: HWND; const Msg: Integer; Index: LongInt; var Rect: TRect): LongInt;
  external 'SendMessageW@user32.dll stdcall';  

const
  LB_GETITEMRECT = $0198;
  LB_GETTOPINDEX = $018E;

function FindControl(Parent: TWinControl; P: TPoint): TControl;
var
  Control: TControl;
  WinControl: TWinControl;
  I: Integer;
  P2: TPoint;
begin
  for I := 0 to Parent.ControlCount - 1 do
  begin
    Control := Parent.Controls[I];
    if Control.Visible and
       (Control.Left <= P.X) and (P.X < Control.Left + Control.Width) and
       (Control.Top <= P.Y) and (P.Y < Control.Top + Control.Height) then
    begin
      if Control is TWinControl then
      begin
        P2 := P;
        ClientToScreen(Parent.Handle, P2);
        WinControl := TWinControl(Control);
        ScreenToClient(WinControl.Handle, P2);
        Result := FindControl(WinControl, P2);
        if Result <> nil then Exit;
      end;

      Result := Control;
      Exit;
    end;
  end;

  Result := nil;
end;

function PointInRect(const Rect: TRect; const Point: TPoint): Boolean;
begin
  Result :=
    (Point.X >= Rect.Left) and (Point.X <= Rect.Right) and
    (Point.Y >= Rect.Top) and (Point.Y <= Rect.Bottom);
end;

function ListBoxItemAtPos(ListBox: TCustomListBox; Pos: TPoint): Integer;
var
  Count: Integer;
  ItemRect: TRect;
begin
  Result := SendMessage(ListBox.Handle, LB_GETTOPINDEX, 0, 0);
  Count := ListBox.Items.Count;
  while Result < Count do
  begin
    ListBox_GetItemRect(ListBox.Handle, LB_GETITEMRECT, Result, ItemRect);
    if PointInRect(ItemRect, Pos) then Exit;
    Inc(Result);
  end;
  Result := -1;
end;

procedure HoverComponentChanged(Index: Integer);
var 
  Title       : string;
  Description : string;
begin
  case Index of
    0: begin 
         Title := 'SH2 Enhancements Module';
         Description := 'The SH2 Enhancements module provides programming-based fixes and enhancements. This is the "brains" of the project and is required to be installed.';
       end;
    1: begin
         Title := 'Enhanced Executable';
         Description := 'This executable provides compatibility with newer Windows operating systems and is required to be installed.';
       end;
    2: begin
         Title := 'Enhanced Edition Essential Files';
         Description := 'The Enhanced Edition Essential Files provides geometry adjustments, camera clipping fixes, and text fixes for the game.';
       end;
    3: begin
         Title := 'Image Enhancement Pack';
         Description := 'The Image Enhancement Pack provides upscaled, remastered, and remade full screen images.';
       end;
    4: begin
         Title := 'FMV Enhancement Pack';
         Description := 'The FMV Enhancement Pack provides improved quality of the game''s full motion videos.';
       end;
    5: begin
         Title := 'Audio Enhancement Pack';
         Description := 'The Audio Enhancement Pack provides restored quality of the game''s audio files.';
       end;
    6: begin
         Title := 'DSOAL';
         Description := 'DSOAL is a DirectSound DLL replacer that enables surround sound, HRTF, and EAX audio support via OpenAL Soft. This enables 3D positional audio, which restores the sound presentation of the game for a more immersive experience.';
       end;
    7: begin
         Title := 'XInput Plus';
         Description := 'Provides compatibility with modern controllers.';
       end;
  else
    Title := 'Move your mouse over a component to see its description.';
  end;
  CompTitle.Caption := Title;
  CompDescription.Caption := Description;
end;

procedure HoverTimerProc(
  H: LongWord; Msg: LongWord; IdEvent: LongWord; Time: LongWord);
var
  P: TPoint;
  Control: TControl; 
  Index: Integer;
begin
  GetCursorPos(P);
  if P <> LastMouse then { just optimization }
  begin
    LastMouse := P;
    ScreenToClient(WizardForm.Handle, P);

    if (P.X < 0) or (P.Y < 0) or
       (P.X > WizardForm.ClientWidth) or (P.Y > WizardForm.ClientHeight) then
    begin
      Control := nil;
    end
      else
    begin
      Control := FindControl(WizardForm, P);
    end;

    Index := -1;
    if (Control = WizardForm.ComponentsList) and
       (not WizardForm.TypesCombo.DroppedDown) then
    begin
      P := LastMouse;
      ScreenToClient(WizardForm.ComponentsList.Handle, P);
      Index := ListBoxItemAtPos(WizardForm.ComponentsList, P);
    end;

    HoverComponentChanged(Index);
  end;
end;

