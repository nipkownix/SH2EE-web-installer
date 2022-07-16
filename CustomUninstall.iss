[Code]

procedure doCustomUninstall();
var
  intErrorCode: Integer;
  path : String;
begin
  if maintenanceMode then
    path := ExpandConstant('{src}')
  else
    path := WizardDirValue;

  ExtractTemporaryFile('deletefile_util.exe');

  DelTree(path + '\sh2e', True, True, True);
  DeleteFile(path + '\alsoft.ini');
  DeleteFile(path + '\d3d8.cfg');
  DeleteFile(path + '\d3d8.dll');
  DeleteFile(path + '\d3d8.ini');
  DeleteFile(path + '\d3d8.log');
  DeleteFile(path + '\d3d8.res');
  DeleteFile(path + '\D3DCompiler_43.dll');
  DeleteFile(path + '\D3DX9_43.dll');
  DeleteFile(path + '\Dinput.dll');
  DeleteFile(path + '\Dinput8.dll');
  DeleteFile(path + '\dsoal-aldrv.dll');
  DeleteFile(path + '\dsound.dll');
  DeleteFile(path + '\keyconf.dat');
  DeleteFile(path + '\local.fix');
  DeleteFile(path + '\SH2EEsetup.dat');
  DeleteFile(path + '\SH2EEconfig.exe');
  DeleteFile(path + '\SH2EEconfig.xml');
  DeleteFile(path + '\sh2pc.exe');
  DeleteFile(path + '\XInput1_3.dll');
  DeleteFile(path + '\XInputPlus.ini');

  // Remove Wine DLL overrides
  if RegValueExists(HKEY_CURRENT_USER, 'Software\Wine\DllOverrides', 'd3d8') then
  begin
    RegDeleteValue(HKEY_CURRENT_USER, 'Software\Wine\DllOverrides', 'd3d8');
    RegDeleteValue(HKEY_CURRENT_USER, 'Software\Wine\DllOverrides', 'Dinput');
    RegDeleteValue(HKEY_CURRENT_USER, 'Software\Wine\DllOverrides', 'Dinput8');
    RegDeleteValue(HKEY_CURRENT_USER, 'Software\Wine\DllOverrides', 'dsound');
    RegDeleteValue(HKEY_CURRENT_USER, 'Software\Wine\DllOverrides', 'XInput1_3');
  end;

  // Restore the .exe backup if it exists
  if FileExists(path + '\sh2pc.exe.bak') then
    RenameFile(path + '\sh2pc.exe.bak', path + '\sh2pc.exe');

  // Schedule SH2EEsetup.exe for removal as soon as possible
  if maintenanceMode then
    Exec(ExpandConstant('{tmp}\') + 'deletefile_util.exe', AddQuotes(ExpandConstant('{srcexe}')), '', SW_HIDE, ewNoWait, intErrorCode);
end;