unit Tuir;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Drivers, Video, FVCommon;

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

{---------------------------------------------------------------------------}
{                          TWindow NUMBER CONSTANTS                         }
{---------------------------------------------------------------------------}
const
   wnNoNumber = 0;                                    { Window has no num }
   MaxViewWidth = 255;                                { Max view width }

    
{---------------------------------------------------------------------------}
{                              PALETTE RECORD                               }
{---------------------------------------------------------------------------}
type
   TPalette = String;                                 { Palette record }
   PPalette = ^TPalette;                              { Pointer to palette }

{---------------------------------------------------------------------------}
{                            TDrawBuffer RECORD                             }
{---------------------------------------------------------------------------}
type
   TDrawBuffer = Array [0..MaxViewWidth - 1] Of Word; { Draw buffer record }
   PDrawBuffer = ^TDrawBuffer;                        { Ptr to draw buffer }


   {---------------------------------------------------------------------------}
   {                 INITIALIZED DOS/DPMI/WIN/NT/OS2 VARIABLES                 }
   {---------------------------------------------------------------------------}
   CONST
      UseNativeClasses: Boolean = True;                  { Native class modes }
      CommandSetChanged: Boolean = False;                { Command change flag }
      ShowMarkers: Boolean = False;                      { Show marker state }
      ErrorAttr: Byte = $CF;                             { Error colours }
      PositionalEvents: Word = evMouse;                  { Positional defined }
      FocusedEvents: Word = evKeyboard + evCommand;      { Focus defined }
      MinWinSize: TPoint = (X: 16; Y: 6);                { Minimum window size }
      ShadowSize: TPoint = (X: 2; Y: 1);                 { Shadow sizes }
      ShadowAttr: Byte = $08;                            { Shadow attribute }

   { Characters used for drawing selected and default items in  }
   { monochrome color sets                                      }
      SpecialChars: Array [0..5] Of Char = (#175, #174, #26, #27, ' ', ' ');
{ COMPONENT SECTION }
type

  ITUIRDesigner = interface;

  TVideoBuf = array[0..4095] of TVideoCell; //80 x 50, aligned
  TAnchorKind = (akTop, akLeft, akRight, akBottom);
  TAnchors = set of TAnchorKind;

  { TView }

  TGroup = class;

  TView = class(TComponent)
  private
    FAnchors: TAnchors;
    FDesigner: ITUIRDesigner;
    FParent: TGroup;
    //FParent: TView;
    function    ConstraintWidth(NewWidth: Integer): Integer;
    function    ConstraintHeight(NewHeight: Integer): Integer;
    //function GetControlChildren(Index: integer): TView;
    function GetDesigner: ITUIRDesigner;
    procedure SetAnchors(AValue: TAnchors);
    procedure SetColor(AValue: Word);
    function GetBoundsRect: TRect;
    procedure SetBoundsRect(const Value: TRect);
    //procedure SetParent(AValue: TView);
    procedure do_WriteView(x1,x2,y:Sw_Integer; var Buf);
    procedure ResetCursor;
    procedure SetParent(AValue: TGroup);
  protected
    GrowMode : Byte;                             { View grow mode }
    Options  : Word;                             { View options masks }
    EventMask: Word;                             { View event masks }
    State    : Word;                             { View state masks }
    FColor: Word;
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
    FPaintPending : Integer;
    procedure BeginPainting;
    procedure EndPainting;
    function  Painting: Boolean;
    procedure   SetTop(const AValue: Integer);
    procedure   SetLeft(const AValue: Integer);
    procedure   SetHeight(const AValue: Integer);
    procedure   SetWidth(const AValue: Integer);
    procedure   HandleMove(x, y: Integer); virtual;
    procedure   HandleResize(AWidth, AHeight: Integer); virtual;
    procedure   RealignChildren; virtual;
  protected
    {requires by IDE}
    //FChilds: TList; // list of Widget
    //FAcceptChildren : boolean;
    //FText:      string;
    //procedure   SetText(const AValue: string); virtual;
    procedure   SetParentComponent(Value: TComponent); override;
    //procedure   GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    //procedure   SetName(const NewName: TComponentName); override;
    //property    Text : string read FText write SetText;
    procedure DrawUnderView;
    procedure DrawUnderRect(var R: TRect);
    procedure Draw; virtual;
    procedure DrawCursor;
  public
    // requires by IDE Designer
    //function    ChildrenCount: integer;

    function    GetParentComponent: TComponent; override;
    function    HasParent: Boolean; override;
    //function    GetParent: TGroup; //override;

    //property    AcceptChildren : boolean read FAcceptChildren;
    //property    Children[Index: integer]: TView read GetControlChildren; //GetChildren has been reserved obove
    //property    Parent: TView read FParent write SetParent;
    property    Parent   : TGroup read FParent write SetParent;
    property    Designer : ITUIRDesigner read GetDesigner write FDesigner;
  public
    ColourOfs: Sw_Integer;                          { View palette offset }
    constructor Create(AOwner: TComponent); override;
    procedure Invalidate(RefreshParent: Boolean = False); virtual; //also tell the designer
    //procedure Paint; virtual;      //internal paint
    procedure SetBounds(ALeft,ATop, AWidth, AHeight: Integer); virtual;
    procedure GetBounds(var R: TRect);
    property BoundsRect: TRect read GetBoundsRect write SetBoundsRect;
    procedure DrawView; virtual;
    procedure ParentResized; virtual; //called by parent, to realign / anchoring
    function GetColor (Color: Word): Word;
    function GetPalette: PPalette; Virtual;
    procedure WriteLine (X, Y, W, H: Sw_Integer; Var Buf);
    function ClientToScreen(X,Y: SW_Integer) : TPoint; overload;
    function ClientToScreen(P: TPoint) : TPoint; overload;

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
    property  Anchors : TAnchors read FAnchors write SetAnchors default [akLeft, akTop];
  end;

  { TGroup }

  TGroup = class(TView)
  private
    FClipRect: TRect;
    FChildren : TFpList;
    function GetChildIndex(Index : integer): TView;
    procedure Insert(AChild:TView);
    procedure Remove(AChild:TView);
    function GetBuffer: PVideoBuf;
    procedure ChildrenDrawView(Child: TComponent);
    procedure ChildrenDrawViewInClipRect(Child: TComponent);
    procedure ChildrenParentResize(Child: TComponent);

  protected
    FBuffer: PVideoBuf;
    procedure Draw; override;
    procedure DrawClippedRect; virtual;
    property ClipRect : TRect read FClipRect write FClipRect;
    procedure   RealignChildren; override;
    procedure   GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  public
    function    ChildrenCount: integer;
    property Child[Index : integer] : TView read GetChildIndex;
    property Buffer : PVideoBuf read GetBuffer write FBuffer;                         { Screen Buffer }
    constructor Create(AOwner: TComponent); override;
    procedure DrawSubViews(R: TRect); overload;
    procedure DrawSubViews(); overload;

  end;

  { TFrame }

  TFrame = class(TView)
  protected
    procedure Draw; override;
  public
    constructor Create(AOwner: TComponent); override;

  end;
  TtuiFrame = class(TFrame)

  end;

  { TCustomWindow }

  TCustomWindow = class(TGroup) //doesn't load *.lfm
  private
    FFrame : TFrame;
  public
    constructor Create(AOwner: TComponent); override;
  end;


  { TtuiWindow }

  TtuiWindow = class(TCustomWindow)
  private

  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateNew(AOwner: TComponent); virtual;
  end;

  { proxy designer for TMediatorDesigner }

  ITUIRDesigner = interface(IUnknown)
    procedure InvalidateRect(ConsoleRect: TRect);
    procedure InvalidateBound(Sender: TObject);
  end;


  function GetScreenBufPos(x,y: integer ): Pointer;

var
  EmptyRect : TRect;

implementation

function GetScreenBufPos(x,y: integer ): Pointer;
begin
  result := VideoBuf;
  inc(result, (ScreenWidth * y + x) * SizeOf(TVideoCell) );
end;

procedure DrawScreenBuf(Force: Boolean); //views.pas
begin
  if (GetLockScreenCount=0) then
  begin
    UpdateScreen(Force); //call os-dependent: currentVideo.UpdateScreen
  end;
end;

function ScreenRect():TRect ;
begin
  result := Rect(0,0, Video.ScreenWidth-1, Video.ScreenHeight-1);
end;


{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{                           TRect OBJECT METHODS                            }
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
procedure CheckEmpty (Var R: TRect);
begin
   With R Do begin
     If (Left >= Right) OR (Top >= Bottom) Then begin       { Zero or reversed }
       Left := 0;                                      { Clear Left }
       Top := 0;                                      { Clear Top }
       Right := 0;                                      { Clear Right }
       Bottom := 0;                                      { Clear Bottom }
     end;
   end;
end;

{--TRect--------------------------------------------------------------------}
{  Empty -> Platforms DOS/DPMI/WIN/OS2 - Checked 10May96 LdB                }
{---------------------------------------------------------------------------}
function RectEmpty(R:TRect): Boolean;
begin
   With R Do Result := (Left >= Right) OR (Top >= Bottom);             { Empty result }
end;

{--TRect--------------------------------------------------------------------}
{  Equals -> Platforms DOS/DPMI/WIN/OS2 - Checked 10May96 LdB               }
{---------------------------------------------------------------------------}
function RectEquals (R,R2: TRect): Boolean;
begin
   With R2 Do 
   Result := (Left = R.Left) AND (Top = R.Top) AND
   (Right = R.Right) AND (Bottom = R.Bottom);                   { Equals result }
end;

{--TRect--------------------------------------------------------------------}
{  Contains -> Platforms DOS/DPMI/WIN/OS2 - Checked 10May96 LdB             }
{---------------------------------------------------------------------------}
function RectContains (R: TRect; P: TPoint): Boolean;
begin
   With R Do 
   Result := (P.X >= Left) AND (P.X < Right) AND
     (P.Y >= Top) AND (P.Y < Bottom);                    { Contains result }
end;

{--TRect--------------------------------------------------------------------}
{  Union -> Platforms DOS/DPMI/WIN/OS2 - Checked 10May96 LdB                }
{---------------------------------------------------------------------------}
function RectUnion (R1,R: TRect): TRect;
begin
  with R1 do begin
    If (R.Left < Left) Then Left := R.Left;                { Take if smaller }
    If (R.Top < Top) Then Top := R.Top;                { Take if smaller }
    If (R.Right > Right) Then Right := R.Right;                { Take if larger }
    If (R.Bottom > Bottom) Then Bottom := R.Bottom;                { Take if larger }
  end;
  Result := R1;
end;

{--TRect--------------------------------------------------------------------}
{  Intersect -> Platforms DOS/DPMI/WIN/OS2 - Checked 10May96 LdB            }
{---------------------------------------------------------------------------}
function RectIntersect (R1,R: TRect):TRect;
begin
  with R1 do begin
   If (R.Left > Left) Then Left := R.Left;                { Take if larger }
   If (R.Top > Top) Then Top := R.Top;                { Take if larger }
   If (R.Right < Right) Then Right := R.Right;                { Take if smaller }
   If (R.Bottom < Bottom) Then Bottom := R.Bottom;                { Take if smaller }
  end;
  //CheckEmpty(R1);
  Result := R1;
end;

function IsRectIntersectEmpty (R1,R2: TRect):Boolean;
var R : TRect;
begin
  R :=  RectIntersect(R1,R2);
  CheckEmpty(R);
  Result := RectEquals(R,EmptyRect);
end;

{--TRect--------------------------------------------------------------------}
{  Move -> Platforms DOS/DPMI/WIN/OS2 - Checked 10May96 LdB                 }
{---------------------------------------------------------------------------}
procedure RectMove (var R : TRect; ADX, ADY: Sw_Integer);
begin
  with R do begin
   Inc(Left, ADX);                                     { Adjust Left }
   Inc(Top, ADY);                                     { Adjust Top }
   Inc(Right, ADX);                                     { Adjust Right }
   Inc(Bottom, ADY);                                     { Adjust Bottom }
  end;
end;

{--TRect--------------------------------------------------------------------}
{  Grow -> Platforms DOS/DPMI/WIN/OS2 - Checked 10May96 LdB                 }
{---------------------------------------------------------------------------}
procedure RectGrow (var R:TRect; ADX, ADY: Sw_Integer);
begin
  with R do begin
   Dec(Left, ADX);                                     { Adjust Left }
   Dec(Top, ADY);                                     { Adjust Top }
   Inc(Right, ADX);                                     { Adjust Right }
   Inc(Bottom, ADY);                                     { Adjust Bottom }
   CheckEmpty(R);                                  { Check if empty }
  end;
end;

{ TCustomWindow }

constructor TCustomWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //FFrame := TFrame.Create(self);
end;


{ TFrame }

procedure TFrame.Draw;
begin
  inherited Draw;
end;

constructor TFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  GrowMode := gfGrowHiX + gfGrowHiY;                 { Set grow modes }
  EventMask := EventMask OR evBroadcast;             { See broadcasts }

end;

{ TGroup }

procedure TGroup.ChildrenDrawView(Child: TComponent);
begin
  TView(Child).DrawView;
end;

procedure TGroup.ChildrenDrawViewInClipRect(Child: TComponent);
var cv : TView;
begin
  cv := TView(Child);
  if not IsRectIntersectEmpty(cv.BoundsRect, FClipRect) then
    cv.DrawView;
end;

procedure TGroup.ChildrenParentResize(Child: TComponent);
begin
  TView(Child).ParentResized;
end;

constructor TGroup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Options := Options OR (ofSelectable + ofBuffered); { Set options }
end;

procedure TGroup.Draw;
begin
  DrawClippedRect; //inherited Draw;
  ///If Buffer=Nil then
    Self.DrawSubViews()
  ///else
    ///WriteBuf(0,0,Size.X,Size.Y,Buffer);
end;


procedure TGroup.DrawClippedRect;
var
  B : TDrawBuffer;
  R : TRect;
begin
  if RectEquals(FClipRect, EmptyRect) then
  begin
    R := BoundsRect;
    RectMove(R, -Left, -Top); //clientrect
  end
  else
    R := FClipRect;

  with R do begin
    //MoveChar(B, '&', GetColor(1), Width);
    MoveChar(B, ' ', Self.FColor, Right-Left);
    WriteLine(Left, Top, Right-Left, Bottom-Top, B);
  end;

end;

procedure TGroup.RealignChildren;
var t : Talignment;
begin
  //inherited RealignChildren;
  GetChildren(@ChildrenParentResize,Self);
end;

procedure TGroup.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  i: Integer;
begin
  for i:=0 to ChildrenCount-1 do
    //if Child[i].Owner=Root then
      Proc(Child[i]);

  if Root = self then
    for i:=0 to ComponentCount-1 do
      if Components[i].GetParentComponent = nil then
        Proc(Components[i]);
end;

function TGroup.ChildrenCount: integer;
begin
  if FChildren = nil then
     result :=0
  else
    result := FChildren.Count;
end;

procedure TGroup.DrawSubViews();
begin
  GetChildren(@ChildrenDrawView,Self);
		{# it is called by:
			- TView.DrawUnderRec
			> TGroup.Draw;
			> TGroup.Redraw}
end;

procedure TGroup.DrawSubViews(R: TRect);
begin
  FClipRect := R;
  DrawClippedRect; //inherited Draw;

  GetChildren(@ChildrenDrawViewInClipRect,Self);
  FClipRect := EmptyRect;
		{# it is called by:
			> TView.DrawUnderRec
			- TGroup.Draw;
			- TGroup.Redraw}
end;

procedure TGroup.Insert(AChild: TView);
begin
  If not assigned(FChildren) then
    FChildren:=TFpList.Create;
  FChildren.Add(AChild);
  AChild.FParent:=Self;
end;

function TGroup.GetChildIndex(Index : integer): TView;
begin
  if FChildren = nil then
     result := nil
  else
    result := TView(FChildren[Index]);
end;

procedure TGroup.Remove(AChild: TView);
begin
  AChild.FParent:=Nil;
  If assigned(FChildren) then
    begin
    FChildren.Remove(AChild);
    if FChildren.Count=0 then
      begin
      FChildren.Free;
      FChildren:=Nil;
      end;
    end;
end;

function TGroup.GetBuffer: PVideoBuf;
begin
  Result := FBuffer;
  if (Result = nil) and HasParent then
    Result := Parent.Buffer;
end;

{ TtuiWindow }

constructor TtuiWindow.Create(AOwner: TComponent);
begin
  CreateNew(AOwner);
  if (ClassType<>TtuiWindow) and ([csDesignInstance, csDesigning]*ComponentState=[]) then
  begin
    if not InitInheritedComponent(Self, TtuiWindow) then
      //raise EResNotFound.CreateFmt(rsResourceNotFound, [ClassName]);
  end;
  FColor := $c7fa;//debug
end;

constructor TtuiWindow.CreateNew(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWidth := 60;
  FHeight := 18;
end;

constructor TView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //Parent := AOwner;
  FWidth  := 10;
  FHeight := 1;
  FMaxWidth  := 0;
  FMaxHeight := 0;
  //FChilds := TList.Create;
  FAnchors := [akLeft, akTop];
  FColor := $7c7f;//debug
end;


procedure TView.Invalidate(RefreshParent: Boolean = False);
var oldBounds : TRect;
begin
  //if {Painting or} (csLoading in ComponentState) then exit;

  //paint;
  if FSizeIsDirty or  FPosIsDirty {RefreshParent} then
  begin
    if FSizeIsDirty then
      RealignChildren;

    DrawUnderView;

    if Designer <> nil then
    begin
      oldBounds := Bounds( FPrevLeft, FPrevTop, FPrevWidth, FPrevHeight);
      Designer.InvalidateRect(oldBounds);
    end;

    FSizeIsDirty := False;
    FPosIsDirty := False;
    FPrevLeft   := FLeft;
    FPrevTop    := FTop;
    FPrevWidth  := FWidth;
    FPrevHeight := FHeight;

  end
  else
    DrawView;
    
  if Designer <> nil then
    Designer.InvalidateRect(self.BoundsRect);
end;

(*procedure TView.Paint;
{var
  i : integer;}
begin
  {for i := 0 to Height -1 do
    MoveCStr(GetScreenBufPos(FLeft,FTop+i)^, 'Test ~P~aint!', FColor);}
  //MoveCStr(GetScreenBufPos(FLeft,FTop)^, FText, FColor);
end;*)

procedure TView.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  BeginPainting;
  HandleMove(ALeft, ATop);
  HandleResize(AWidth, AHeight);
  EndPainting;
  Invalidate(True);
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
   if Parent <> nil then
     result := Parent.Designer
  else
    result := FDesigner;
end;

procedure TView.SetAnchors(AValue: TAnchors);
begin
  if FAnchors=AValue then Exit;
  FAnchors:=AValue;
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

  if not Painting then
    Invalidate(True);
  //if Designer <> nil then
    //Designer.InvalidateBound(self);
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

  if not Painting then
    Invalidate(True);
  //if Designer <> nil then
    //Designer.InvalidateBound(self);
end;

procedure TView.RealignChildren;
begin

end;

procedure TView.SetParentComponent(Value: TComponent);
begin
  SetParent(TGroup(Value));
end;

{function TView.ChildrenCount: integer;
begin
  result := ComponentCount
end;}

                                                                          
(*procedure TView.GetChildren(Proc: TGetChildProc; Root: TComponent);
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
      if OwnedComponent is TView then Proc(OwnedComponent);
    end;
end;*)

function TView.GetParentComponent: TComponent;
begin
  Result:= Parent;
end;

function TView.HasParent: Boolean;
begin
  Result:= Parent <> nil;
end;

{function TView.GetParent: TGroup;
begin
  result := TGroup(Owner)
end;}






procedure TView.DrawUnderView;
  // it shall invalidate the screen because it is final call on Show,Hide,Move,Resize
  // I can't believe : why this method is called after 'DrawView' on DrawShow ?
  // it seem 
var
  R: TRect;
begin
  GetBounds(R);
  {if DoShadow then begin
    inc(R.B.X,ShadowSize.X);
    inc(R.B.Y,ShadowSize.Y);
  end;}
  DrawUnderRect(R{, LastView});
end;

procedure TView.DrawUnderRect(var R: TRect);
  // it shall invalidate the screen because it is final call on Show/Hide
var
  oldBounds : TRect;
begin
  if HasParent then begin
    //Owner^.Clip.Intersect(R);
    //todo: is it need to suply self or R ?
    oldBounds := Bounds( FPrevLeft, FPrevTop, FPrevWidth, FPrevHeight);
    R := RectUnion( R, oldBounds);
    Parent.DrawSubViews(R);//(NextView, LastView); //it seem as later calls DrawView also. So, DoShow call double DrawView. I guessing.
    //Owner^.GetExtent(Owner^.Clip); //reset to bounds
  end;
end;

function TView.GetBoundsRect: TRect;
begin
  {Result.Left := FLeft;
  Result.Top := FTop;
  Result.Right := FLeft + FWidth ;
  Result.Bottom := FTop + FHeight ;}
  Result := Bounds(FLeft, FTop, FWidth, FHeight);
end;

procedure TView.SetBoundsRect(const Value: TRect);
begin
  with Value do
    SetBounds(Left, Top, Right - Left , Bottom - Top );
end;

procedure TView.GetBounds(var R: TRect);
begin
  R := GetBoundsRect;
end;



procedure TView.DrawView;
  // Primarily, it is called by 'Show' and is NOT called by 'Hide'
  //it's only here. no things such TGroup.DrawView 
begin
  //if Exposed then
   begin
     LockScreenUpdate; { don't update the screen yet }
     Draw;
     UnLockScreenUpdate;
     DrawScreenBuf(false); //<------------------------------------ CALL VIDEO TO UPDATE ????
     DrawCursor;
   end;
end;

procedure TView.ParentResized;
var
  L,T,R,B,W,H : Integer;
begin
  L := Left;
  T := Top;
  W := Width;
  H := Height;
  if akRight in FAnchors then
  begin
    R := Parent.FPrevWidth - (Left + Width -1); //distance to right
    if akLeft in FAnchors then
      W := (Parent.Width - R) - Left
    else
      L := Left - R;
  end;

  if akBottom in FAnchors then
  begin
    B := Parent.FPrevHeight - (Top + Height -1); //distance to bottom
    if akTop in FAnchors then
      H := (Parent.Height - B) - Top
    else
      T := Top - B;
  end;
  self.SetBounds(L,T,W,H);
end;

function TView.GetColor(Color: Word): Word;
var Col: Byte; W: Word; P: PPalette; Q: TView;
begin
   W := 0;                                            { Clear colour Sw_Word }
   If (Hi(Color) > 0) Then Begin                      { High colour req }
     Col := Hi(Color) + ColourOfs;                    { Initial offset }
     Q := Self;                                      { Pointer to self }
     Repeat
       P := Q.GetPalette;                            { Get our palette }
       If (P <> Nil) Then Begin                       { Palette is valid }
         If (Col <= Length(P^)) Then
           Col := Ord(P^[Col]) Else                   { Return colour }
           Col := ErrorAttr;                          { Error attribute }
       End;
       Q := Q.Parent;                                 { Move up to owner }
     Until (Q = Nil);                                 { Until no owner }
     W := Col SHL 8;                                  { Translate colour }
   End;
   If (Lo(Color) > 0) Then Begin
     Col := Lo(Color) + ColourOfs;                    { Initial offset }
     Q := Self;                                      { Pointer to self }
     Repeat
       P := Q.GetPalette;                            { Get our palette }
       If (P <> Nil) Then Begin                       { Palette is valid }
         If (Col <= Length(P^)) Then
           Col := Ord(P^[Col]) Else                   { Return colour }
           Col := ErrorAttr;                          { Error attribute }
       End;
       Q := Q.Parent;                                 { Move up to owner }
     Until (Q = Nil);                                 { Until no owner }
   End Else Col := ErrorAttr;                         { No colour found }
   GetColor := W OR Col;                              { Return color }
end;

function TView.GetPalette: PPalette;
begin
  Result := nil;
end;

{ this is the final last chance to write to buffer
  so, both runtime and designtime should take care of
  what going on by this routine }
procedure TView.WriteLine(X, Y, W, H: Sw_Integer; var Buf);
var
  J:Sw_integer;
  R : TRect;
begin
  if (h > 0) and (W > 0) then
  begin
    //for i:=0 to h-1 do
      //do_writeView(x,x+w,y+i,buf);
    R.TopLeft := ClientToScreen(X,Y);
    R.BottomRight := ClientToScreen(X+W-1, Y+H-1);
    R := RectIntersect(R, ScreenRect);
    with R do begin
      for J := Top to Bottom do
        Move(PVideoBuf(@Buf)^, GetScreenBufPos(Left,J)^, (Right-Left+1) * sizeof(TVideoCell));
    end;
    DrawScreenBuf(false);
  end;
end;



procedure TView.Draw;
var B : TDrawBuffer;
begin
	  //MoveChar(B, '&', GetColor(1), Width);
    MoveChar(B, ' ', Self.FColor, Width);
	  WriteLine(0, 0, Width, Height, B);
end;

procedure TView.DrawCursor;
begin
  if State and sfFocused <> 0 then
    ResetCursor;   
end;

procedure TView.do_WriteView(x1, x2, y: Sw_Integer; var Buf);
begin
  {if (y>=0) and (y<Size.Y) then
   begin
     if x1<0 then
      x1:=0;
     if x2>Size.X then
      x2:=Size.X;
     if x1<x2 then
      begin
        staticVar2.offset:=x1;
        staticVar2.y:=y;
        staticVar1:=@Buf;
        do_writeViewRec2( x1, x2, @Self, 0 );
      end;
   end;}
end;

procedure TView.ResetCursor;
begin

end;

procedure TView.SetParent(AValue: TGroup);
begin
  if FParent=AValue then Exit;
  if FParent <> nil then
     FParent.Remove(self);
  if AValue <> nil then
     AValue.Insert(self);
end;

function TView.ClientToScreen(X, Y: SW_Integer): TPoint;
var
  LParent: TGroup;
  ClientArea: TRect;
  ScrollOffset: TPoint;
  CurBounds: TRect;
  L,T : Integer;
begin
  L := X ;
  T := Y ;

  if not ((self is TCustomWindow) and (Designer <> nil)) then // happen in root-designer-object
  begin
    inc(L, Left);
    inc(T, Top);
  end;

  LParent := Parent;
  while LParent<>nil do
  begin

    { this is the final last chance to write to buffer
      so, both runtime and designtime should take care of
      what going on by this line }
    if ( LParent is TCustomWindow) and (Designer <> nil) then // happen in root-designer-object
      break;

    inc(L, LParent.Left);
    inc(T, LParent.Top);
    LParent := LParent.Parent;
    {Parent:=AComponent.GetParentComponent;
    if Parent=nil then break;
    GetBounds(AComponent,CurBounds);
    inc(Result.X,CurBounds.Left);
    inc(Result.Y,CurBounds.Top);
    GetClientArea(Parent,ClientArea,ScrollOffset);
    inc(Result.X,ClientArea.Left+ScrollOffset.X);
    inc(Result.Y,ClientArea.Top+ScrollOffset.Y);
    AComponent:=Parent;}
  end;
  Result := Point(L,T);
end;

function TView.ClientToScreen(P: TPoint): TPoint;
begin
  Result :=  ClientToScreen(P.X, P.Y);
end;

procedure TView.BeginPainting;
begin
  inc(FPaintPending);
end;

procedure TView.EndPainting;
begin
  dec(FPaintPending);
end;

function TView.Painting: Boolean;
begin
  result := FPaintPending > 0;
end;

initialization
  EmptyRect := Rect(0,0,0,0);
  Video.ScreenHeight := 25;
  Video.ScreenWidth := 80;
end.


