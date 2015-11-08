unit TUI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Drivers, Video;

type

  { TTUIControl }

  TTUIControl = class(TComponent)
  private
    FColor: Word;
    function    ConstraintWidth(NewWidth: Integer): Integer;
    function    ConstraintHeight(NewHeight: Integer): Integer;
    procedure SetColor(AValue: Word);
  protected
    FTop: Integer;
    FLeft: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FPrevTop: Integer;
    FPrevLeft: Integer;
    FPrevWidth: Integer;
    FPrevHeight: Integer;
    FMinWidth: Integer;
    FMinHeight: Integer;
    FMaxHeight: Integer;
    FMaxWidth: Integer;
    FSizeIsDirty: Boolean;
    FPosIsDirty: Boolean;
    FMouseCursorIsDirty: Boolean;
    procedure   SetTop(const AValue: Integer);
    procedure   SetLeft(const AValue: Integer);
    procedure   SetHeight(const AValue: Integer);
    procedure   SetWidth(const AValue: Integer);
    procedure   HandleMove(x, y: Integer); virtual;
    procedure   HandleResize(AWidth, AHeight: Integer); virtual;
  public
    // The standard constructor.
    constructor Create(AOwner: TComponent); override;
    procedure Invalidate; virtual; //also call the designer
    procedure Paint; virtual;      //internal paint

    property    Color: Word read FColor write SetColor;
  published
    property    Left: Integer read FLeft write SetLeft;
    property    Top: Integer read FTop write SetTop;
    property    Width: Integer read FWidth write SetWidth;
    property    Height: Integer read FHeight write SetHeight;
    property    MinWidth: Integer read FMinWidth write FMinWidth;
    property    MinHeight: Integer read FMinHeight write FMinHeight;
    property    MaxWidth: Integer read FMaxWidth write FMaxWidth default 0;
    property    MaxHeight: Integer read FMaxHeight write FMaxHeight default 0;
  end;

implementation

function GetScreenBufPos(x,y: integer ): Pointer;
begin
  result := VideoBuf;
  inc(result, ScreenWidth * y + (x* SizeOf(Word)))
end;

constructor TTUIControl.Create(AOwner: TComponent);
begin
  inherited;
  FHeight := 1;
  FWidth := 10;
  FColor := $5678;//debug
end;

procedure TTUIControl.Invalidate;
begin
  paint;
end;

procedure TTUIControl.Paint;
begin
  MoveCStr(GetScreenBufPos(FLeft,FTop)^, 'Test ~P~aint!', FColor);
end;

function TTUIControl.ConstraintWidth(NewWidth: Integer): Integer;
begin
  Result := NewWidth;
  if (MaxWidth >= MinWidth) and (Result > MaxWidth) and (MaxWidth > 0) then
    Result := MaxWidth;
  if Result < MinWidth then
    Result := MinWidth;
end;

function TTUIControl.ConstraintHeight(NewHeight: Integer): Integer;
begin
  Result := NewHeight;
  if (MaxHeight >= MinHeight) and (Result > MaxHeight) and (MaxHeight > 0) then
    Result := MaxHeight;
  if Result < MinHeight then
    Result := MinHeight;
end;

procedure TTUIControl.SetColor(AValue: Word);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
  Invalidate;
end;

procedure TTUIControl.SetTop(const AValue: Integer);
begin
  HandleMove(Left, AValue);
end;

procedure TTUIControl.SetLeft(const AValue: Integer);
begin
  HandleMove(AValue, Top);
end;

procedure TTUIControl.SetHeight(const AValue: Integer);
begin
  HandleResize(Width, AValue);
end;

procedure TTUIControl.SetWidth(const AValue: Integer);
begin
  HandleResize(AValue, Height);
end;

procedure TTUIControl.HandleMove(x, y: Integer);
begin
  if FTop <> y then
  begin
    if not (csLoading in ComponentState) then
      FPrevTop := FTop
    else
      FPrevTop := y;
    FTop := y;
    FPosIsDirty := FPosIsDirty or (FTop <> FPrevTop);
  end;

  if FLeft <> x then
  begin
    if not (csLoading in ComponentState) then
      FPrevLeft := FLeft
    else
      FPrevLeft := x;
    FLeft := x;
    FPosIsDirty := FPosIsDirty or (FLeft <> FPrevLeft);
  end;
end;

procedure TTUIControl.HandleResize(AWidth, AHeight: Integer);
begin
  if FWidth <> AWidth then
  begin
    if not (csLoading in ComponentState) then
      FPrevWidth := FWidth
    else
      FPrevWidth := AWidth;
    FWidth := ConstraintWidth(AWidth);
    FSizeIsDirty := FSizeIsDirty or (FWidth <> FPrevWidth);
  end;

  if FHeight <> AHeight then
  begin
    if not (csLoading in ComponentState) then
      FPrevHeight := FHeight
    else
      FPrevHeight := AHeight;
    FHeight := ConstraintHeight(AHeight);
    FSizeIsDirty := FSizeIsDirty or (FHeight <> FPrevHeight);
  end;
end;
end.
