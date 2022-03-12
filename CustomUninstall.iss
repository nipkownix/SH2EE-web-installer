[Code]

procedure doCustomUninstall;
var
  intErrorCode: Integer;
begin
  ExtractTemporaryFile('deletefile_util.exe');

  DelTree(ExpandConstant('{src}\sh2e'), True, True, True);
  DeleteFile(ExpandConstant('{src}\alsoft.ini'));
  DeleteFile(ExpandConstant('{src}\d3d8.dll'));
  DeleteFile(ExpandConstant('{src}\d3d8.ini'));
  DeleteFile(ExpandConstant('{src}\d3d8.log'));
  DeleteFile(ExpandConstant('{src}\d3d8.res'));
  DeleteFile(ExpandConstant('{src}\d3d8.cfg'));
  DeleteFile(ExpandConstant('{src}\Dinput.dll'));
  DeleteFile(ExpandConstant('{src}\Dinput8.dll'));
  DeleteFile(ExpandConstant('{src}\dsoal-aldrv.dll'));
  DeleteFile(ExpandConstant('{src}\dsound.dll'));
  DeleteFile(ExpandConstant('{src}\keyconf.dat'));
  DeleteFile(ExpandConstant('{src}\local.fix'));
  DeleteFile(ExpandConstant('{src}\SH2EEsetup.dat'));
  DeleteFile(ExpandConstant('{src}\sh2pc.exe'));
  DeleteFile(ExpandConstant('{src}\XInput1_3.dll'));
  DeleteFile(ExpandConstant('{src}\XInputPlus.ini'));

  // Restore the .exe backup if it exists
  if FileExists(ExpandConstant('{src}\') + 'sh2pc.exe.bak') then
    RenameFile(ExpandConstant('{src}\') + 'sh2pc.exe.bak', ExpandConstant('{src}\') + 'sh2pc.exe');

  // Schedule SH2EEsetup.exe for removal as soon as possible
  Exec(ExpandConstant('{tmp}\') + 'deletefile_util.exe', AddQuotes(ExpandConstant('{srcexe}')), '', SW_HIDE, ewNoWait, intErrorCode);
end;