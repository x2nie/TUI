unit Tuir;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Drivers, Video;

{***************************************************************************}
{                              PUBLIC CONSTANTS                             }
{***************************************************************************}

{---------------------------------------------------------------------------}
{                              TView STATE MASKS                            }
{---------------------------------------------------------------------------}
CONST
   sfVisible   = $0001;                               { View visible mask }
   sfCursorVis = $0002;                               { Cursor visible }
   sfCursorIns = $0004;                               { Cursor insert mode }
   sfShadow    = $0008;                               { View has shadow }
   sfActive    = $0010;                               { View is active }
   sfSelected  = $0020;                               { View is selected }
   sfFocused   = $0040;                               { View is focused }
   sfDragging  = $0080;                               { View is dragging }
   sfDisabled  = $0100;                               { View is disabled }
   sfModal     = $0200;                               { View is modal }
   sfDefault   = $0400;                               { View is default }
   sfExposed   = $0800;                               { View is exposed }
   sfIconised  = $1000;                               { View is iconised }

{---------------------------------------------------------------------------}
{                             TView OPTION MASKS                            }
{---------------------------------------------------------------------------}
CONST
   ofSelectable  = $0001;                             { View selectable }
   ofTopSelect   = $0002;                             { Top selectable }
   ofFirstClick  = $0004;                             { First click react }
   ofFramed      = $0008;                             { View is framed }
   ofPreProcess  = $0010;                             { Pre processes }
   ofPostProcess = $0020;                             { Post processes }
   ofBuffered    = $0040;                             { View is buffered }
   ofTileable    = $0080;                             { View is tileable }
   ofCenterX     = $0100;                             { View centred on x }
   ofCenterY     = $0200;                             { View centred on y }
   ofCentered    = $0300;                             { View x,y centred }
   ofValidate    = $0400;                             { View validates }
   //ofVersion     = $3000;                             { View TV version }
   //ofVersion10   = $0000;                             { TV version 1 view }
   //ofVersion20   = $1000;                             { TV version 2 view }

 {---------------------------------------------------------------------------}
 {                            TView GROW MODE MASKS                          }
 {---------------------------------------------------------------------------}
 CONST
    gfGrowLoX = $01;                                   { Left side grow }
    gfGrowLoY = $02;                                   { Top side grow  }
    gfGrowHiX = $04;                                   { Right side grow }
    gfGrowHiY = $08;                                   { Bottom side grow }
    gfGrowAll = $0F;                                   { Grow on all sides }
    gfGrowRel = $10;                                   { Grow relative }
type

  ITUIRDesigner = interface;

  TVideoBuf = array[0..4095] of TVideoCell; //80 x 50, aligned

  { TView }

  TGroup = class;

  TView = class(TComponent)
  private
    FColor: Word;
    FDesigner: ITUIRDesigner;
    //FParent: TView;
    function    ConstraintWidth(NewWidth: Integer): Integer;
    function    ConstraintHeight(NewHeight: Integer): Integer;
    //function GetControlChildren(Index: integer): TView;
    function GetDesigner: ITUIRDesigner;
    procedure SetColor(AValue: Word);
    //procedure SetParent(AValue: TView);
  protected
    GrowMode : Byte;                             { View grow mode }
    Options  : Word;                             { View options masks }
    EventMask: Word;                             { View event masks }
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
    //FChilds: TList; // list of Widget
    //FAcceptChildren : boolean;
    //FText:      string;
    //procedure   SetText(const AValue: string); virtual;
    //procedure   SetParentComponent(Value: TComponent); override;
    procedure   GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    //procedure   SetName(const NewName: TComponentName); override;
    //property    Text : string read FText write SetText;
  public
    // requires by IDE Designer
    function    ChildrenCount: integer;

    function    GetParentComponent: TComponent; override;
    function    HasParent: Boolean; override;
    function    GetParent: TGroup; //override;

    //property    AcceptChildren : boolean read FAcceptChildren;
    //property    Children[Index: integer]: TView read GetControlChildren; //GetChildren has been reserved obove
    //property    Parent: TView read FParent write SetParent;
    property    Parent   : TGroup read GetParent;
    property    Designer : ITUIRDesigner read GetDesigner write FDesigner;
  public
    constructor Create(AOwner: TComponent); override;
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

  { TGroup }

  TGroup = class(TView)
  public
    constructor Create(AOwner: TComponent); override;

  end;

  TCustomWindow = class(TGroup) //doesn't load *.lfm

  end;

  { TFrame }

  TFrame = class(TView)
  public
    constructor Create(AOwner: TComponent); override;

  end;

  { TWindow }

  TWindow = class(TCustomWindow)
  private

  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateNew(AOwner: TComponent); virtual;
  end;

  { proxy designer for TMediatorDesigner }

  ITUIRDesigner = interface(IUnknown)
    procedure InvalidateRect(Sender: TObject);
    procedure InvalidateBound(Sender: TObject);
  end;


  function GetScreenBufPos(x,y: integer ): Pointer;

implementation

function GetScreenBufPos(x,y: integer ): Pointer;
begin
  result := VideoBuf;
  inc(result, (ScreenWidth * y + x) * SizeOf(TVideoCell) );
end;

{ TFrame }

constructor TFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  GrowMode := gfGrowHiX + gfGrowHiY;                 { Set grow modes }
  EventMask := EventMask OR evBroadcast;             { See broadcasts }

end;

{ TGroup }

constructor TGroup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Options := Options OR (ofSelectable + ofBuffered); { Set options }
end;

{ TWindow }

constructor TWindow.Create(AOwner: TComponent);
begin
  CreateNew(AOwner);
  if (ClassType<>TWindow) and ([csDesignInstance, csDesigning]*ComponentState=[]) then
  begin
    if not InitInheritedComponent(Self, TWindow) then
      //raise EResNotFound.CreateFmt(rsResourceNotFound, [ClassName]);
  end
end;

constructor TWindow.CreateNew(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWidth := 60;
  FHeight := 18;
end;

constructor TView.Create(AOwner: TComponent);
begin
  inherited;
  FWidth  := 10;
  FHeight := 1;
  FMaxWidth  := 0;
  FMaxHeight := 0;
  //FChilds := TList.Create;

  FColor := $7c7f;//debug
end;


procedure TView.Invalidate;
begin
  if csLoading in ComponentState then exit;

  paint;
  if Designer <> nil then
    Designer.InvalidateRect(self);
end;

procedure TView.Paint;
{var
  i : integer;}
begin
  {for i := 0 to Height -1 do
    MoveCStr(GetScreenBufPos(FLeft,FTop+i)^, 'Test ~P~aint!', FColor);}
  //MoveCStr(GetScreenBufPos(FLeft,FTop)^, FText, FColor);

end;

procedure TView.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  HandleMove(ALeft, ATop);
  HandleResize(AWidth, AHeight);
end;

//

function TView.ConstraintWidth(NewWidth: Integer): Integer;
begin
  Result := NewWidth;
  if (MaxWidth >= MinWidth) and (Result > MaxWidth) and (MaxWidth > 0) then
    Result := MaxWidth;
  if Result < MinWidth then
    Result := MinWidth;
end;

function TView.ConstraintHeight(NewHeight: Integer): Integer;
begin
  Result := NewHeight;
  if (MaxHeight >= MinHeight) and (Result > MaxHeight) and (MaxHeight > 0) then
    Result := MaxHeight;
  if Result < MinHeight then
    Result := MinHeight;
end;

function TView.GetDesigner: ITUIRDesigner;
begin
  if Owner <> nil then
     result := Parent.Designer
  else
    result := FDesigner;
end;

procedure TView.SetColor(AValue: Word);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
  Invalidate;
end;

procedure TView.SetTop(const AValue: Integer);
begin
  HandleMove(Left, AValue);
end;

procedure TView.SetLeft(const AValue: Integer);
begin
  HandleMove(AValue, Top);
end;

procedure TView.SetHeight(const AValue: Integer);
begin
  HandleResize(Width, AValue);
end;

procedure TView.SetWidth(const AValue: Integer);
begin
  HandleResize(AValue, Height);
end;

procedure TView.HandleMove(x, y: Integer);
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

procedure TView.HandleResize(AWidth, AHeight: Integer);
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

function TView.ChildrenCount: integer;
begin
  result := ComponentCount
end;


procedure TView.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  i: Integer;
  OwnedComponent: TComponent;
begin
  {for i:=0 to ChildrenCount-1 do
      if Children[i].Owner=Root then
        Proc(Children[i]);
}
  if Root = Self then
    for I := 0 to ComponentCount - 1 do
    begin
      OwnedComponent := Components[I];
      {if not OwnedComponent.HasParent then} Proc(OwnedComponent);
    end;
end;

function TView.GetParentComponent: TComponent;
begin
  Result:= Owner;
end;

function TView.HasParent: Boolean;
begin
  Result:= Owner <> nil;
end;

function TView.GetParent: TGroup;
begin
  result := TGroup(Owner)
end;






initialization
  Video.ScreenHeight := 25;
  Video.ScreenWidth := 80;
end.


