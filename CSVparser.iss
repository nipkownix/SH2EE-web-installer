[Code]

type
  TWebComponentsInfo    = record
    ID                  : String;
    Name                : String;
    Version             : String;
    URL                 : String;
    SHA256              : String;
  end;

  TLocalComponentsInfo  = record
    ID                  : String;
    isInstalled         : Boolean;
    Version             : String;
  end;

var
  CSVFilePath : String;

  LocalCompsArray : array of TLocalComponentsInfo;
  WebCompsArray   : array of TWebComponentsInfo;

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
    SetArrayLength(Result, GetArrayLength(Rows) - 2);
    for i := 1 to GetArrayLength(Rows) - 2 do begin
      // Separate values at commas
      RowValues := SplitString(Rows[i + 1], ',');
      with Result[i - 1] do begin
        ID := RowValues[0];
        Name := RowValues[1];
        Version := RowValues[2];
        URL := RowValues[3];
        SHA256 := RowValues[4];
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

procedure UpdateLocalCSV(recoverOnly: Boolean);
var
  i: Integer;
begin
  Log('# updating local csv');

  // Create fresh local .csv in the game's directory
  if not maintenanceMode then
  begin
    SaveStringToFile(ExpandConstant('{app}\SH2EEsetup.dat')
    ,'# **DO NOT MODIFY THIS FILE!**' + #13#10 +
    'id,isInstalled,version' + #13#10 +
    'setup_tool,true,' + ExpandConstant('{#INSTALLER_VER}') + #13#10,
    False);
  end else
  begin
    SaveStringToFile(ExpandConstant('{src}\SH2EEsetup.dat')
    ,'# **DO NOT MODIFY THIS FILE!**' + #13#10 +
    'id,isInstalled,version' + #13#10 +
    'setup_tool,true,' + ExpandConstant('{#INSTALLER_VER}') + #13#10,
    False);
  end;

  // Populate entries based on the web csv
  for i := 0 to GetArrayLength(WebCompsArray) - 1 do
  begin
    if not (WebCompsArray[i].id = 'setup_tool') then
    begin
      if not maintenanceMode then
      begin
        SaveStringToFile(ExpandConstant('{app}\SH2EEsetup.dat')
        ,WebCompsArray[i].ID + ',false,' + '0.0' + #13#10,
        True);
      end else
      begin
        SaveStringToFile(ExpandConstant('{src}\SH2EEsetup.dat')
        ,WebCompsArray[i].ID + ',false,' + '0.0' + #13#10,
        True);
      end;
    end;
  end;

  // Write version info and installation status
  for i := 0 to GetArrayLength(WebCompsArray) - 1 do
  begin
    if not (WebCompsArray[i].id = 'setup_tool') then
    begin
      // Rewrite existing local csv info
      if maintenanceMode then
      begin
        try
          if LocalCompsArray[i].isInstalled then
            FileReplaceString(ExpandConstant('{src}\SH2EEsetup.dat'), LocalCompsArray[i].ID + ',false,' + '0.0', LocalCompsArray[i].ID + ',true,' + LocalCompsArray[i].Version);
        except
          Log('# Entry is missing from local CSV.');
        end;
      end;

      // If in maintenance mode, check for maintenance page's radio buttons
      if maintenanceMode and not selfUpdateMode and not recoverOnly then
      begin
        // Write info from new selected components using wpSelectComponents' list box
        if installRadioBtn.Checked or updateRadioBtn.Checked then
        begin
          if WizardForm.ComponentsList.Checked[i - 1] = true then
            FileReplaceString(ExpandConstant('{src}\SH2EEsetup.dat'), LocalCompsArray[i].ID + ',' + BoolToStr(LocalCompsArray[i].isInstalled) + ',' + LocalCompsArray[i].Version, WebCompsArray[i].ID + ',true,' + WebCompsArray[i].Version);
        end;
      end;

      // If not in maintenance mode, use the default method
      if not maintenanceMode then
      begin
        if WizardForm.ComponentsList.Checked[i - 1] = true then
          FileReplaceString(ExpandConstant('{app}\SH2EEsetup.dat'), WebCompsArray[i].ID + ',false,0.0', WebCompsArray[i].ID + ',true,' + WebCompsArray[i].Version);
      end;
    end;
  end;
end;