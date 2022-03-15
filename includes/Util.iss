// Inno Setup - Util.iss

[Code]
var
  GCS_sh2pcPath: string;

procedure ExitProcess(uExitCode: Integer);
  external 'ExitProcess@kernel32.dll stdcall';

function BytesToString(size: Int64): PAnsiChar; 
  external 'BytesToString@files:BytesToString.dll cdecl';

// Determines if there is enough free space on a drive of a specific folder
function IsEnoughFreeSpace(const Path: string; MinSpace: Cardinal): Boolean;
var
  FreeSpace, TotalSpace: Cardinal;
begin
  // the second parameter set to True means that the function operates with
  // megabyte units; if you set it to False, it will operate with bytes; by
  // the chosen units you must reflect the value of the MinSpace paremeter
  if GetSpaceOnDisk(Path, False, FreeSpace, TotalSpace) then
    Result := FreeSpace >= MinSpace
  else
    RaiseException('Failed to check free space.');
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

// String to boolean -- ** Already defined in idp.iss. UNCOMMENT IF NOT USING IDP
// function StrToBool(value: String): Boolean;
// var s: String;
// begin
//     s := LowerCase(value);
// 
//     if      s = 'true'  then result := true
//     else if s = 't'     then result := true
//     else if s = 'yes'   then result := true
//     else if s = 'y'     then result := true
//     else if s = 'false' then result := false
//     else if s = 'f'     then result := false
//     else if s = 'no'    then result := false
//     else if s = 'n'     then result := false
//     else                     result := StrToInt(value) > 0;
// end;

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