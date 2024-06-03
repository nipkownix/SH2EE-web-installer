[Code]

function GetLocalCompIndexByID(const ID: String): Integer;
var
  i: Integer;
begin
  Result := -1; // Default result if not found
  for i := 0 to GetArrayLength(LocalCompsArray) - 1 do
  begin
    if LocalCompsArray[i].ID = ID then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function GetWebCompIndexByID(const ID: String): Integer;
var
  i: Integer;
begin
  Result := -1; // Default result if not found
  for i := 0 to GetArrayLength(WebCompsArray) - 1 do
  begin
    if WebCompsArray[i].ID = ID then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function GetMaintCompIndexByID(const ID: String): Integer;
var
  i: Integer;
begin
  Result := -1; // Default result if not found
  for i := 0 to GetArrayLength(MaintenanceCompsArray) - 1 do
  begin
    if MaintenanceCompsArray[i].ID = ID then
    begin
      Result := i;
      Exit;
    end;
  end;
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
function MaintenanceCSVToInfoArray(Filename: String): array of TMaintenanceComponentsInfo;
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
          Log('user might have edited the maintenance .csv');
        end;
      end;
    end;
  end else begin
    SetArrayLength(Result, 0);
  end;
end;

// Same as above, but tailored to use a different format(2)
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
        ID := RowValues[0];
        Name := RowValues[1]; 
        fileName := RowValues[2]; 
        Version := RowValues[3];
      end;
    end;
  end else begin
    SetArrayLength(Result, 0);
  end;
end;

procedure CreateLocalCSV();
var
  i: Integer;
begin
  Log('# updating local csv');

  SaveStringToFile(localDataDir('local_sh2ee.dat')
  ,'# SH2EE local csv' + #13#10 +
  'id,name,fileName,version' + #13#10 +
  'setup_tool,SH2:EE Setup Tool,SH2EEsetup.exe,' + ExpandConstant('{#INSTALLER_VER}') + #13#10,
  False);

  // Populate entries based on the local csv
  for i := 0 to GetArrayLength(WebCompsArray) - 1 do
  begin
    if not (WebCompsArray[i].id = 'setup_tool') then
    begin
      SaveStringToFile(localDataDir('local_sh2ee.dat')
      ,WebCompsArray[i].ID + ',' + WebCompsArray[i].Name + ',notDownloaded,' + '0.0' + #13#10,
      True);
    end;
  end;

  // Update entries
  for i := 0 to GetArrayLength(WebCompsArray) - 1 do
  begin
    if not (WebCompsArray[i].id = 'setup_tool') then
    begin
      if WizardForm.ComponentsList.Checked[i - 1] then
        FileReplaceString(localDataDir('local_sh2ee.dat'), WebCompsArray[i].ID + ',' + WebCompsArray[i].Name + ',notDownloaded,' + '0.0'
        ,WebCompsArray[i].ID + ',' + WebCompsArray[i].Name + ',' +  GetURLFilePart(WebCompsArray[i].URL) + ',' + WebCompsArray[i].Version);
    end;
  end;
end;

procedure UpdateMaintenanceCSV(recoverOnly: Boolean);
var
  i: Integer;
  compIndex: Integer;
begin
  Log('# updating maintenance csv');

  // Create fresh local .csv in the game's directory
  if localInstallMode then
  begin
    SaveStringToFile(ExpandConstant('{app}\SH2EEsetup.dat')
    ,'# **DO NOT MODIFY THIS FILE!**' + #13#10 +
    'id,isInstalled,version' + #13#10 +
    'setup_tool,true,' + ExpandConstant('{#INSTALLER_VER}') + #13#10,
    False);
  end else
  if maintenanceMode then
  begin
    SaveStringToFile(ExpandConstant('{src}\SH2EEsetup.dat')
    ,'# **DO NOT MODIFY THIS FILE!**' + #13#10 +
    'id,isInstalled,version' + #13#10 +
    'setup_tool,true,' + WebCompsArray[0].Version + #13#10,
    False);
  end else
  begin
    SaveStringToFile(ExpandConstant('{app}\SH2EEsetup.dat')
    ,'# **DO NOT MODIFY THIS FILE!**' + #13#10 +
    'id,isInstalled,version' + #13#10 +
    'setup_tool,true,' + WebCompsArray[0].Version + #13#10,
    False);
  end;

  // Populate entries based on the local csv
  if localInstallMode then
  begin
    for i := 0 to GetArrayLength(LocalCompsArray) - 1 do
    begin
      if not (LocalCompsArray[i].id = 'setup_tool') then
      begin
        SaveStringToFile(ExpandConstant('{app}\SH2EEsetup.dat')
        ,LocalCompsArray[i].ID + ',false,' + '0.0' + #13#10,
        True);
      end;
    end;
  end else
  // Populate entries based on the web csv
  begin
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

          // Re-save DSOAL's info if it exists, and we just wrote audio_pack
          if (WebCompsArray[i].id = 'audio_pack') then
          begin
            compIndex := GetMaintCompIndexByID('dsoal');
            if compIndex > -1 then
            begin
              if MaintenanceCompsArray[compIndex].isInstalled then
              begin
                Log('# User has installed DSOAL in the past, keeping .csv entry');
                SaveStringToFile(ExpandConstant('{src}\SH2EEsetup.dat')
                ,MaintenanceCompsArray[compIndex].ID + ',true,' + MaintenanceCompsArray[compIndex].Version + #13#10,
                True);
              end;
            end;
          end;
        end;
      end;
    end;
  end;

  // Write version info and installation status using local csv
  if localInstallMode then
  begin
    for i := 0 to GetArrayLength(LocalCompsArray) - 1 do
    begin
      if not (LocalCompsArray[i].id = 'setup_tool') then
      begin
        if WizardForm.ComponentsList.Checked[i - 1] then
          FileReplaceString(ExpandConstant('{app}\SH2EEsetup.dat'), LocalCompsArray[i].ID + ',false,0.0', LocalCompsArray[i].ID + ',true,' + LocalCompsArray[i].Version);
      end;
    end;
  end else
  begin
    // Write version info and installation status using web csv
    for i := 0 to GetArrayLength(WebCompsArray) - 1 do
    begin
      if not (WebCompsArray[i].id = 'setup_tool') then
      begin
        compIndex := GetMaintCompIndexByID(WebCompsArray[i].id);
        if compIndex > -1 then
        begin
          // Rewrite existing local csv info
          if maintenanceMode then
          begin
            try
              begin
                if MaintenanceCompsArray[compIndex].isInstalled then
                  FileReplaceString(ExpandConstant('{src}\SH2EEsetup.dat'), MaintenanceCompsArray[compIndex].ID + ',false,' + '0.0', MaintenanceCompsArray[compIndex].ID + ',true,' + MaintenanceCompsArray[compIndex].Version);
              end;
            except
              Log('# Entry is missing from CSV.');
            end;
          end;
    
          // If in maintenance mode, check for maintenance page's radio buttons
          if maintenanceMode and not selfUpdateMode and not recoverOnly then
          begin
            // Write info from new selected components using wpSelectComponents' list box
            if installRadioBtn.Checked or updateRadioBtn.Checked or updateMode then
            begin
              if WizardForm.ComponentsList.Checked[i - 1] then
                FileReplaceString(ExpandConstant('{src}\SH2EEsetup.dat'), MaintenanceCompsArray[compIndex].ID + ',' + BoolToStr(MaintenanceCompsArray[compIndex].isInstalled) + ',' + MaintenanceCompsArray[compIndex].Version, WebCompsArray[i].ID + ',true,' + WebCompsArray[i].Version);
            end;
          end;
    
          // If not in maintenance mode, use the default method
          if not maintenanceMode then
          begin
            if WizardForm.ComponentsList.Checked[i - 1] then
              FileReplaceString(ExpandConstant('{app}\SH2EEsetup.dat'), WebCompsArray[i].ID + ',false,0.0', WebCompsArray[i].ID + ',true,' + WebCompsArray[i].Version);
          end;
        end;
      end;
    end;
  end;
end;

procedure UpdateMaintenanceCSV_SetupToolOnly();
var
  i: Integer;
begin
    for i := 0 to GetArrayLength(WebCompsArray) - 1 do
    begin
      if (WebCompsArray[i].id = 'setup_tool') then
      begin
        if maintenanceMode then
        begin
          try
            Log('Updating Setup Tool''s version');
            FileReplaceString(ExpandConstant('{src}\SH2EEsetup.dat'), MaintenanceCompsArray[i].ID + ',true,' + MaintenanceCompsArray[i].Version, MaintenanceCompsArray[i].ID + ',true,' + ExpandConstant('{#INSTALLER_VER}'));
          except
            Log('# Entry is missing from local CSV.');
          end;
        end;
      end;
    end;
end;