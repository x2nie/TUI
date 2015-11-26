unit Tuir_widgets;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Drivers, Tuir;

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
  //MoveCStr(GetScreenBufPos(FLeft,FTop)^, FText, $7c7f);
  WriteLine(0, 0, Width, 1, B);                     { Write the text }
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
  Options := Options OR (ofPreProcess+ofPostProcess);{ Set pre/post process }
  EventMask := EventMask OR evBroadcast;             { Sees broadcast events }
end;



end.

