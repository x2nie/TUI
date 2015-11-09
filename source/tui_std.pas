unit TUI_Std;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, TUI;

type

  { TTUILabel }

  TTUILabel = class(TTUIControl)
  public
    constructor Create(AOwner:TComponent); override;
  published
    property Text;
  end;

implementation

{ TTUILabel }

constructor TTUILabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHeight := 1;
  FMinHeight := 1;
  FMaxHeight := 1;
end;

end.

