{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit TUI_Package;

interface

uses
  TUI, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('TUI_Package', @Register);
end.
