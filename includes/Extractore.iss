// InnoSetup - Extractore.iss

[Code]
var
  extProcHandle: Longword;

// "Application.ProcessMessage" Helper
type
  TMsg = record
    hwnd: HWND;
   message: UINT;
    wParam: Longint;
    lParam: Longint;
    time: DWORD;
    pt: TPoint;
  end;

const
  PM_REMOVE = 1;

function PeekMessage(var lpMsg: TMsg; hWnd: HWND; wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL; external 'PeekMessageA@user32.dll stdcall';
function TranslateMessage(const lpMsg: TMsg): BOOL; external 'TranslateMessage@user32.dll stdcall';
function DispatchMessage(const lpMsg: TMsg): Longint; external 'DispatchMessageA@user32.dll stdcall';

procedure AppProcessMessage;
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, WizardForm.Handle, 0, 0, PM_REMOVE) do begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
end;

// Helper functions from cmdlinerunner.dll 
function ProcStart(cmdline, workdir: string): Longword;
  external 'proc_start@files:cmdlinerunner.dll cdecl';
function ProcGetExitCode(inst: Longword): DWORD;
  external 'proc_get_exit_code@files:cmdlinerunner.dll cdecl';
function ProcGetOutput(inst: Longword; dest: PAnsiChar; sz: DWORD): DWORD;
  external 'proc_get_output@files:cmdlinerunner.dll cdecl';
procedure ProcEnd(inst: Longword);
  external 'proc_end@files:cmdlinerunner.dll cdecl';

// ProgressBar updater    
procedure updtExtractionProgressBar(S: AnsiString; progressBarName: TNewProgressBar);
var
  P: Integer;
  Progress: string;
  Percent: Integer;
  Found: Boolean;
begin
  Found := False;
  if S = '' then
  begin
    Log('String %s is empty');
  end;
 
  if S <> '' then
  begin
    // Log(S);
    P := Pos('Extracted', S);
    if P > 0 then
    begin
      Log('Extraction done');
      Percent := 100;
      Found := True;
    end
      else
    begin
      P := Pos('%', S);
      if P > 0 then
      begin
        repeat
          Progress := Copy(S, 1, P - 1);
          Delete(S, 1, P);
          P := Pos('%', S);
        until (P = 0);

        P := Length(Progress);
        while (P > 0) and
              (((Progress[P] >= '0') and (Progress[P] <= '9')) or
               (Progress[P] = '.')) do
        begin
          Dec(P);
        end;

        Progress := Copy(Progress, P + 1, Length(Progress) - P);

        P := Pos('.', Progress);
        if P > 0 then
        begin
          Progress := Copy(Progress, 1, P - 1);
        end;

        Percent := StrToInt(Progress);
        Log(Format('Percent: %d', [Percent]));
        Found := True;
      end;
    end;
  end;

  if not Found then
  begin
    Log('No new progress data found');
  end
    else
  begin
    progressBarName.Position := Percent
  end;
end;
  
// String helpers
procedure StringsAddLine(boxName: TNewListBox; Line: String; var ReplaceLastLine: Boolean);
begin
  if ReplaceLastLine then
  begin
    boxName.Items.Strings[boxName.Items.Count - 1] := Line;
    ReplaceLastLine := False;
  end else begin
    boxName.Items.Add(Line);
  end;
  boxName.ItemIndex := boxName.Items.Count - 1;
  boxName.Selected[boxName.ItemIndex] := False;
end;

procedure StrSplitAppendToList(Text: AnsiString; boxName: TNewListBox; var LastLine: String);
var
  pCR, pLF, Len: Integer;
  Tmp: String;
  ReplaceLastLine: Boolean;
begin
  if Length(LastLine) > 0 then
  begin
    ReplaceLastLine := True;
    Text := LastLine + Text;
  end;
  repeat
    Len := Length(Text);
    pLF := Pos(#10, Text);
    pCR := Pos(#13, Text);
    if (pLF > 0) and ((pCR = 0) or (pLF < pCR) or (pLF = pCR + 1)) then
    begin
      if pLF < pCR then
        Tmp := Copy(Text, 1, pLF - 1)
      else
        Tmp := Copy(Text, 1, pLF - 2);
      StringsAddLine(boxName, Tmp, ReplaceLastLine);
      Text := Copy(Text, pLF + 1, Len)
    end else begin
      if (pCR = Len) or (pCR = 0) then
      begin
        break;
      end;
      Text := Copy(Text, pCR + 1, Len)
    end;
  until (pLF = 0) and (pCR = 0);

  LastLine := Text;
  if pCR = Len then
  begin
    Text := Copy(Text, 1, pCR - 1);
  end;
  if Length(LastLine) > 0 then
  begin
    StringsAddLine(boxName, Text, ReplaceLastLine);
  end;
end;

// Extractore procedure begin
procedure Extractore(source: String; targetdir: String; extractTool: String; logToListBox: Boolean; 
          boxName: TNewListBox; logPercentageToProgressBar: Boolean; progressBarName: TNewProgressBar);
var
  extractParams : String; // params for the extraction tool
  ExitCode: Integer;
  LogTextAnsi: AnsiString;
  LogText, LeftOver: String;
  Res: Integer;
begin
  // source and targetdir might contain {tmp} or {app} constant, so expand/resolve it to path names
  source := ExpandConstant(source);
  targetdir := ExpandConstant(targetdir);

  // prepare execution tool and parameters
  if extractTool = '7zip' then 
  begin
    if IsWin64 then
      extractTool := '"' + ExpandConstant('{tmp}\7za_x64.exe') + '"'
    else
      extractTool := '"' + ExpandConstant('{tmp}\7za_x86.exe') + '"';
    extractParams := ' x -sopg -ba "' + source + '" -o"' + targetdir + '" -y'; // -sopg isn't part of the official 7za.exe build. See: https://stackoverflow.com/a/40931992/16421617
  end
  else
  if extractTool = 'unshield' then
  begin
    extractTool := '"' + ExpandConstant('{tmp}\unshield.exe') + '"';
    extractParams := ' -d "' + targetdir + '" x "' + source + '"';
  end;

  if not FileExists(RemoveQuotes(extractTool)) then 
    MsgBox('extractTool not found: ' + extractTool, mbError, MB_OK)
  else if not FileExists(source) then 
    MsgBox('File was not found while trying to unzip: ' + source, mbError, MB_OK)
  else
  begin
    ExitCode := -1;
    if ({#DEBUG} and logToListBox) then 
       boxName.Items.Add('Running command: ' + extractTool + extractParams);
    Log(extractTool + extractParams);
    extProcHandle := ProcStart(extractTool + extractParams, ExpandConstant('{tmp}'))
    if extProcHandle = 0 then
    begin
      Log('ProcStart failed');
      ExitCode := -2;
    end;
    while (ExitCode = -1) do
    begin
      AppProcessMessage;
      WizardForm.Refresh();
      ExitCode := ProcGetExitCode(extProcHandle);
      SetLength(LogTextAnsi, 4096);
      Res := ProcGetOutput(extProcHandle, LogTextAnsi, 4096)
      if Res > 0 then
      begin
        SetLength(LogTextAnsi, Res);
        LogText := LeftOver + String(LogTextAnsi);

        if logToListBox then 
           StrSplitAppendToList(LogText, boxName, LeftOver);

        if logPercentageToProgressBar then 
           updtExtractionProgressBar(LogText, progressBarName);
      end;
      Sleep(10);
    end;
    ProcEnd(extProcHandle);
    //boxName.Lines.Clear();
  end;
end;