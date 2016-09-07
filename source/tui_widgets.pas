unit TUI_widgets;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Drivers, tui;

type

  { TStaticText }

  TStaticText = class(TView)
  private
    FText: string;
    procedure SetText(AValue: string);
  protected
    procedure   SetName(const NewName: TComponentName); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Text : string read FText write SetText;
    property Height default 1;
    property Width default 8;
  end;

  { TtuiLabel }

  TtuiLabel = class (TStaticText)
  public
    constructor Create(AOwner: TComponent); override;
    procedure Draw; override;
  end;

  TLabel = class(TtuiLabel)

  end;

implementation

{ TtuiLabel }

constructor TtuiLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TtuiLabel.Draw;
var B: TDrawBuffer;
begin
  //inherited Draw;
  MoveChar(B[0], ' ', Byte(Color), Width);          { Clear the buffer }
  MoveCStr(B[1], FText, Color);{ Transfer label text }
  WriteLine(0, 0, Width, 1, B);                     { Write the text at self bound at screen }
end;

{ TStaticText }

procedure TStaticText.SetText(AValue: string);
begin
  if FText=AValue then Exit;
  FText:=AValue;
  Invalidate;
end;

procedure TStaticText.SetName(const NewName: TComponentName);
begin
  if Name=FText then Text:=NewName;
  inherited SetName(NewName);
end;

constructor TStaticText.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Height := 1;
  Width := 8;
  Options := Options OR (ofPreProcess+ofPostProcess);{ Set pre/post process }
  EventMask := EventMask OR evBroadcast;             { Sees broadcast events }
end;



end.

