unit Unit1;

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses
  Classes, SysUtils, Tui, Tui_widgets;

type

  { TtuiWindow1 }

  TtuiWindow1 = class(TtuiWindow)
    Group1: TGroup;
    tuiLabel1: TtuiLabel;
    tuiLabel2: TtuiLabel;
    tuiLabel3: TtuiLabel;
    tuiLabel4: TtuiLabel;
    tuiLabel5: TtuiLabel;
    tuiLabel6: TtuiLabel;
    tuiLabel7: TtuiLabel;
    tuiLabel8: TtuiLabel;
    tuiLabel9: TtuiLabel;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  tuiWindow1: TtuiWindow1;

implementation

{$R *.lfm}

end.

