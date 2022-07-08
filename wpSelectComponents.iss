[Code]

var
  CompTitle       : TLabel;
  CompDescription : TLabel;
  iTotalCompSize  : Int64;
  iTotalCompCount : integer;
  TypesComboOnChangePrev       : TNotifyEvent;
  ComponentsListClickCheckPrev : TNotifyEvent;

// Customize ComponentsList according to our needs 
procedure update_ComponentsList();
  var
  i: integer;
begin
  // Reset component lists
  iTotalCompCount := 0;
  iTotalCompSize  := 0;

  // Update ComponentsList sizes when using localInstallMode
  if localInstallMode then
  begin
    for i := 0 to GetArrayLength(LocalCompsArray) - 1 do begin
      if not (LocalCompsArray[i].id = 'setup_tool') then
      begin
        with Wizardform.ComponentsList do
        begin
          ItemSubItem[i - 1] := FileSizeArray[i - 1].String
  
          if (LocalCompsArray[i].fileName = 'notDownloaded') then
          begin
            Checked[i - 1] := false;
            ItemEnabled[i - 1] := false;
            ItemSubItem[i - 1] := 'Package missing';
          end;
  
          // Calculate how many components are selected
          if Checked[i - 1] then
          begin
            iTotalCompCount := iTotalCompCount + 1;
            iTotalCompSize := iTotalCompSize + FileSizeArray[i - 1].Bytes;
          end;
        end;
      end;
    end;
  end;

  // Update component SubItem
  for i := 0 to GetArrayLength(WebCompsArray) - 1 do
  begin
    if not (WebCompsArray[i].id = 'setup_tool') then
    begin
      with Wizardform.ComponentsList do
      begin
        if not maintenanceMode then
          ItemSubItem[i - 1] := FileSizeArray[i - 1].String
        else
        begin
          // Show custom text if the component is already installed
          if MaintenanceCompsArray[i].isInstalled then
            ItemSubItem[i - 1] := 'Already installed - ' + FileSizeArray[i - 1].String
          else if installRadioBtn.Checked then // "Install/Repair" page 
            ItemSubItem[i - 1] := FileSizeArray[i - 1].String;
  
          if updateRadioBtn.Checked or updateMode then // "Update" page
            ItemSubItem[i - 1] := wpUVersionLabel(WebCompsArray[i].Version, MaintenanceCompsArray[i].Version, MaintenanceCompsArray[i].isInstalled);
        end;

        // Calculate how many components are selected
        if Checked[i - 1] then
        begin
          iTotalCompCount := iTotalCompCount + 1;
          iTotalCompSize := iTotalCompSize + FileSizeArray[i - 1].Bytes;
        end;
      end;
    end;
  end;

  if {#DEBUG} then Log('# ' + IntToStr(iTotalCompCount) + ' components selected, with a total size of ' + BytesToString(iTotalCompSize));

  // Replace DiskSpaceLabel //-> TODO: Maybe create a new label and hide the old one? 
  WizardForm.ComponentsDiskSpaceLabel.Caption := 'Current selection requires at least ' + BytesToString(iTotalCompSize) + ' of disk space.';

  // Show disk space label if components are selected
  if not (iTotalCompCount = 0) then
    WizardForm.ComponentsDiskSpaceLabel.Visible := True
  else
    WizardForm.ComponentsDiskSpaceLabel.Visible := False
end;

// Called when you change the installation type in the components list
procedure NewTypesComboOnChange(Sender: TObject);
begin
  // Call Inno's original OnChange action
  TypesComboOnChangePrev(Sender);

  // Customize ComponentsList
  update_ComponentsList();
end;

// Called when you click somewhere in the components list
procedure NewComponentsListClickCheck(Sender: TObject);
begin
  // Call Inno's original OnClick action
  ComponentsListClickCheckPrev(Sender);

  // Customize ComponentsList
  update_ComponentsList();
end;

procedure customize_wpSelectComponents();
begin
  // Register new ComponentsList OnClick event
  with WizardForm.ComponentsList do
  begin
      ComponentsListClickCheckPrev := OnClickCheck; 
      OnClickCheck := @NewComponentsListClickCheck;
  end;

  // Register new TypesCombo OnChange event
  with WizardForm.TypesCombo do
  begin
      TypesComboOnChangePrev := OnChange; 
      OnChange := @NewTypesComboOnChange;
  end;
end;

// Create new labels for name and descriptions
procedure create_CompNameDesc();
begin
  CompTitle := TLabel.Create(WizardForm);
  with CompTitle do
  begin
      Caption     := '';
      Font.Style  := [fsBold];
      Parent      := WizardForm.SelectComponentsPage;
      Left        := WizardForm.ComponentsList.Left;
      Width       := WizardForm.ComponentsList.Width;
      Height      := ScaleY(35);
      Top         := WizardForm.ComponentsList.Top + WizardForm.ComponentsList.Height - CompTitle.Height - ScaleY(25);
      Anchors     := [akLeft, akBottom];
      AutoSize    := False;
      WordWrap    := True;
  end;

  CompDescription := TLabel.Create(WizardForm);
  with CompDescription do
  begin
      Caption     := '';
      Parent      := WizardForm.SelectComponentsPage;
      Left        := WizardForm.ComponentsList.Left;
      Width       := WizardForm.ComponentsList.Width;
      Height      := ScaleY(60);
      Top         := CompTitle.Top + CompTitle.Height - ScaleY(20);
      Anchors     := [akLeft, akBottom];
      AutoSize    := False;
      WordWrap    := True;
  end;

  WizardForm.ComponentsList.Height := WizardForm.ComponentsList.Height - CompTitle.Height - ScaleY(30);
end;

// "On hover" item descriptions
var
  LastMouse        : TPoint;

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
         Description := 'The Enhanced Edition Essential Files provides geometry fixes, camera clipping adjustments, high resolution text, and language/textual improvements for the game.';
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