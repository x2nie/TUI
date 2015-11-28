unit Unit1;

{$ifdef fpc}
{$mode objfpc}{$H+}
{$endif}

interface

uses
  Classes, SysUtils, Tuir, Tuir_widgets;

type

  { TtuiWindow1 }

  TtuiWindow1 = class(TtuiWindow)
    Group1: TGroup;
    tuiLabel1: TtuiLabel;
    tuiLabel2: TtuiLabel;
    tuiLabel3: TtuiLabel;
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

