unit TUI_Forms;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, TUI;

type

  { TTUIForm }

  TTUIForm = class(TTUIControl)
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateNew(AOwner: TComponent); virtual;
  end;


implementation

{ TTUIForm }

constructor TTUIForm.Create(AOwner: TComponent);
begin
  CreateNew(AOwner);
    //InitInheritedComponent (Self , TTUIForm);
    if (ClassType<>TTUIForm) and ([csDesignInstance, csDesigning]*ComponentState=[]) then
    begin
      if not InitInheritedComponent(Self, TTUIForm) then
        //raise EResNotFound.CreateFmt(rsResourceNotFound, [ClassName]);
    end
end;

constructor TTUIForm.CreateNew(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAcceptChildren := True;
  FWidth := 60;
  FHeight := 18;
end;

end.

