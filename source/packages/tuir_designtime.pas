{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit Tuir_designtime;

interface

uses
  Tuir_reg, Tuir_designMediator, Tuir_designdescriptor, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('Tuir_reg', @Tuir_reg.Register);
  RegisterUnit('Tuir_designMediator', @Tuir_designMediator.Register);
  RegisterUnit('Tuir_designdescriptor', @Tuir_designdescriptor.Register);
end;

initialization
  RegisterPackage('Tuir_designtime', @Register);
end.
