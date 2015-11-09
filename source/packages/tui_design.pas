{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit TUI_design;

interface

uses
  TUI_Reg, TUI_DesignMediator, TUI_DesignDescriptor, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('TUI_Reg', @TUI_Reg.Register);
  RegisterUnit('TUI_DesignMediator', @TUI_DesignMediator.Register);
  RegisterUnit('TUI_DesignDescriptor', @TUI_DesignDescriptor.Register);
end;

initialization
  RegisterPackage('TUI_design', @Register);
end.
