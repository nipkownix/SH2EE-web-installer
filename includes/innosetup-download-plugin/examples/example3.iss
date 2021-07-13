; Uncomment one of following lines, if you haven't checked "Add IDP include path to ISPPBuiltins.iss" option
;#pragma include __INCLUDE__ + ";" + ReadReg(HKLM, "Software\Mitrich Software\Inno Download Plugin", "InstallDir")
;#pragma include __INCLUDE__ + ";" + "c:\lib\InnoDownloadPlugin"

[Setup]
AppName          = My Program
AppVersion       = 1.0
DefaultDirName   = {pf}\My Program
DefaultGroupName = My Program
OutputDir        = userdocs:Inno Setup Examples Output

#include <idp.iss>

[Icons]
Name: "{group}\{cm:UninstallProgram,My Program}"; Filename: "{uninstallexe}"

[Components]
Name: A; Description: "Program A"; Types: full compact custom; Flags: fixed
Name: B; Description: "Program B"; Types: full;

[UninstallDelete]
Type: files; Name: "{app}\mariadb.zip"

[Code]
procedure InitializeWizard();
begin
  idpDownloadAfter(wpReady);
end;

function NextButtonClick(CurPage: Integer): Boolean;
begin
  if CurPage = wpSelectComponents then
  begin

    if IsComponentSelected('B') then
    begin
       MsgBox('idpAddFile MariaDB', mbError, MB_OK);
       idpAddFile('http://wpn-xm.org/get.php?s=mariadb', ExpandConstant('{app}\mariadb.zip'));
    end;
  end;

  Result := True;
end;