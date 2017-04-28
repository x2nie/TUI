unit tui_prop_color;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Spin,
  Buttons, ExtCtrls, StdCtrls, Grids, PropEdits;

type

  { TTuiColorDialog }

  TTuiColorDialog = class(TForm)
    BitBtn1: TBitBtn;
    ColorGrid: TDrawGrid;
    Image1: TImage;
    Image2: TImage;
    lbSampleText1: TLabel;
    lbShortcut: TLabel;
    lbSampleText: TLabel;
    PanelPreview: TPanel;
    SpinEdit1: TSpinEdit;
    procedure ColorGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure ColorGridSelection(Sender: TObject; aCol, aRow: Integer);
    procedure FormCreate(Sender: TObject);
  private
    FtuiColor: Word;
    FColors : array[0..3] of Byte;
    function GetColors(index: integer): Byte;
    procedure SetColors(index: integer; AValue: Byte);
    procedure SettuiColor(AValue: Word);
    procedure UpdatePreviews;
    { private declarations }
  public
    { public declarations }
    property Colors[index: integer]: Byte read GetColors write SetColors;
    property tuiColor : Word read FtuiColor write SettuiColor;
  end;

  { TTuiColorEditor }

  TTuiColorEditor = class(TIntegerPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    //function GetValue: String; override;
    //procedure SetValue(const Value: String); override;
    function OrdValueToVisualValue(OrdValue: longint): string; override;

    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
                            AState: TPropEditDrawState); override;
  end;

var
  TuiColorDialog: TTuiColorDialog;

implementation

uses
  Tui_designMediator;


{$R *.lfm}



function GetLclColors(AtuiColor: Word; index: integer): TColor;
begin
  result := LCLColors[ (AtuiColor and ($0F shl (index * 4))) shr (index * 4) ]
end;
{ TTuiColorEditor }

procedure TTuiColorEditor.Edit;
var
  F: TTuiColorDialog;
begin
  //Initialize the property editor window
  F:= TTuiColorDialog.Create(Application);
  try
    F.tuiColor:= GetOrdValue;
    if F.ShowModal = mrOK then begin
      SetOrdValue(F.tuiColor);
    end;
  finally
    F.Free;
  end;
end;

function TTuiColorEditor.GetAttributes: TPropertyAttributes;
begin
  //Makes the small button show to the right of the property
  Result := inherited GetAttributes + [paDialog];
end;

function TTuiColorEditor.OrdValueToVisualValue(OrdValue: longint): string;
begin
  Result:= '$'+inttohex(OrdValue,4);
end;

procedure TTuiColorEditor.PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
  AState: TPropEditDrawState);
var
  R,R2 : TRect;
begin
  R := ARect;
  R.Left := ACanvas.TextWidth(' Preview ');
  //FillRect
  inherited PropDrawValue(ACanvas, ARect, AState);
end;

{function TTuiColorEditor.GetValue: String;
begin
  //Returns the string which should show in Object Inspector
  Result:= FormatDateTime('m/d/yy h:nn:ss ampm', GetFloatValue);
end;

procedure TTuiColorEditor.SetValue(const Value: String);
begin
  //Assigns the string typed in Object Inspector to the property
  inherited;
end;}

{ TTuiColorDialog }



procedure TTuiColorDialog.ColorGridDrawCell(Sender: TObject;
  aCol, aRow: Integer;
  aRect: TRect;
  aState: TGridDrawState);
const
  FB : array[0..1] of String = ('F','B');
begin
  with ColorGrid.Canvas, aRect do
  begin
    Brush.Color := LCLColors[aCol];
    if aCol > 7 then
      Font.Color:= clBlack
    else
      Font.Color := clWhite;

    FillRect(arect);
    if self.Colors[aRow] = aCol then
      TextOut(Left + ((Right - Left) - TextWidth('M')) div 2,
        Top + ((Bottom - Top) - TextHeight('M')) div 2,
        FB[aRow mod 2]);
  end;
end;

procedure TTuiColorDialog.ColorGridSelection(Sender: TObject; aCol,
  aRow: Integer);
begin
  Colors[aRow] := aCol;
  if aRow = 1 then //background
    Colors[3] := aCol;

  //caption := format('%d, %d',[aCol, aRow]);
end;

procedure TTuiColorDialog.FormCreate(Sender: TObject);
begin
  ColorGrid.Font := PanelPreview.Font;
  TuiColor:=31871;
end;

procedure TTuiColorDialog.SettuiColor(AValue: Word);
begin
  if FtuiColor=AValue then Exit;
  FtuiColor:=AValue;
  UpdatePreviews;
end;

procedure TTuiColorDialog.UpdatePreviews;
begin
  PanelPreview.Font.Color:= LCLColors[ Colors[0] ];
  PanelPreview.Color:=      LCLColors[ Colors[1] ];
  lbShortcut.Font.Color:=   LCLColors[ Colors[2] ];
  lbShortcut.Color:=        LCLColors[ Colors[3] ];

  SpinEdit1.Value := FtuiColor;
end;

function TTuiColorDialog.GetColors(index: integer): Byte;
begin
  result := (FtuiColor and ($0F shl (index * 4))) shr (index * 4)
end;

procedure TTuiColorDialog.SetColors(index: integer; AValue: Byte);
begin
  FtuiColor := FtuiColor and not ($0F shl (index * 4)); //reset
  FtuiColor := FtuiColor or (AValue shl (index * 4));   //set
  UpdatePreviews;
end;

end.

