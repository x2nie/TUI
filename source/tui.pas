unit TUI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Drivers, Video;

type

  ITUIDesigner = interface;

  TVideoBuf = array[0..4095] of TVideoCell; //80 x 50, aligned

  { TTUIControl }

  TTUIControl = class(TComponent)
  private
    FColor: Word;
    FDesigner: ITUIDesigner;
    FParent: TTUIControl;
    function    ConstraintWidth(NewWidth: Integer): Integer;
    function    ConstraintHeight(NewHeight: Integer): Integer;
    function GetControlChildren(Index: integer): TTUIControl;
    function GetDesigner: ITUIDesigner;
    procedure SetColor(AValue: Word);
    procedure SetParent(AValue: TTUIControl);
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
  protected
    {requires by IDE}
    FChilds: TList; // list of Widget
    FAcceptChildren : boolean;
    FText:      string;
    procedure   SetText(const AValue: string); virtual;
    procedure   SetParentComponent(Value: TComponent); override;
    procedure   GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure   SetName(const NewName: TComponentName); override;
    property    Text : string read FText write SetText;
  public
    // requires by IDE Designer
    function    ChildrenCount: integer;

    function    HasParent: Boolean; override;
    function    GetParentComponent: TComponent; override;

    property    AcceptChildren : boolean read FAcceptChildren;
    property    Children[Index: integer]: TTUIControl read GetControlChildren; //GetChildren has been reserved obove
    property    Parent: TTUIControl read FParent write SetParent;
    property    Designer : ITUIDesigner read GetDesigner write FDesigner;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; virtual; //also tell the designer
    procedure Paint; virtual;      //internal paint
    procedure SetBounds(ALeft,ATop, AWidth, AHeight: Integer); virtual;

  published
    property    Color: Word read FColor write SetColor;
    property    Left: Integer read FLeft write SetLeft;
    property    Top: Integer read FTop write SetTop;
    property    Width: Integer read FWidth write SetWidth;
    property    Height: Integer read FHeight write SetHeight;
    property    MinWidth: Integer read FMinWidth write FMinWidth  default 0;
    property    MinHeight: Integer read FMinHeight write FMinHeight  default 0;
    property    MaxWidth: Integer read FMaxWidth write FMaxWidth default 0;
    property    MaxHeight: Integer read FMaxHeight write FMaxHeight default 0;
  end;

  { proxy designer for TMediatorDesigner }

  ITUIDesigner = interface(IUnknown)
    procedure InvalidateRect(Sender: TObject);
    procedure InvalidateBound(Sender: TObject);
  end;




implementation

function GetScreenBufPos(x,y: integer ): Pointer;
begin
  result := VideoBuf;
  inc(result, (ScreenWidth * y + x) * SizeOf(TVideoCell) );
end;

constructor TTUIControl.Create(AOwner: TComponent);
begin
  inherited;
  FWidth  := 10;
  FHeight := 1;
  FMaxWidth  := 0;
  FMaxHeight := 0;
  FChilds := TList.Create;

  FColor := $7c7f;//debug
end;

destructor TTUIControl.Destroy;
begin
  FChilds.Free;
  inherited Destroy;
end;

procedure TTUIControl.Invalidate;
begin
  if csLoading in ComponentState then exit;

  paint;
  if Designer <> nil then
    Designer.InvalidateRect(self);
end;

procedure TTUIControl.Paint;
{var
  i : integer;}
begin
  {for i := 0 to Height -1 do
    MoveCStr(GetScreenBufPos(FLeft,FTop+i)^, 'Test ~P~aint!', FColor);}
  MoveCStr(GetScreenBufPos(FLeft,FTop)^, FText, FColor);

end;

procedure TTUIControl.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  HandleMove(ALeft, ATop);
  HandleResize(AWidth, AHeight);
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


function TTUIControl.GetControlChildren(Index: integer): TTUIControl;
begin
  Result:=TTUIControl(FChilds[Index]);
end;

function TTUIControl.GetDesigner: ITUIDesigner;
begin
  if HasParent then
     result := Parent.Designer
  else
    result := FDesigner;
end;

procedure TTUIControl.SetColor(AValue: Word);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
  Invalidate;
end;

procedure TTUIControl.SetParent(AValue: TTUIControl);
begin
  if FParent=AValue then Exit;
  if FParent<>nil then begin
    Invalidate;
    FParent.FChilds.Remove(Self);
  end;
  FParent:=AValue;
  if FParent<>nil then begin
    FParent.FChilds.Add(Self);
  end;
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

  if Designer <> nil then
    Designer.InvalidateBound(self);
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

  if Designer <> nil then
    Designer.InvalidateBound(self);
end;

procedure TTUIControl.SetText(const AValue: string);
begin
  FText := AValue;
  Invalidate;
end;

procedure TTUIControl.SetParentComponent(Value: TComponent);
begin
  if Value is TTUIControl then
    Parent:=TTUIControl(Value);
end;

procedure TTUIControl.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  i: Integer;
  OwnedComponent: TComponent;
begin
  for i:=0 to ChildrenCount-1 do
      if Children[i].Owner=Root then
        Proc(Children[i]);

  if Root = Self then
    for I := 0 to ComponentCount - 1 do
    begin
      OwnedComponent := Components[I];
      if not OwnedComponent.HasParent then Proc(OwnedComponent);
    end;
end;

procedure TTUIControl.SetName(const NewName: TComponentName);
begin
  if Name=FText then Text:=NewName;
  inherited SetName(NewName);
end;

function TTUIControl.ChildrenCount: integer;
begin
  result := FChilds.Count;
end;

function TTUIControl.HasParent: Boolean;
begin
  Result:= FParent <> nil;
end;

function TTUIControl.GetParentComponent: TComponent;
begin
  Result := Parent;
end;

initialization
  Video.ScreenHeight := 25;
  Video.ScreenWidth := 80;
end.
