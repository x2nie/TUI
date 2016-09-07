{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit tui_designtime;

{$warn 5023 off : no warning about unused units}
interface

uses
  tui_reg, tui_designmediator, tui_designdescriptor, tui_prop_color, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('tui_reg', @tui_reg.Register);
  RegisterUnit('tui_designmediator', @tui_designmediator.Register);
  RegisterUnit('tui_designdescriptor', @tui_designdescriptor.Register);
end;

initialization
  RegisterPackage('tui_designtime', @Register);
end.
