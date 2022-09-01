unit tui_designmediator;

{$mode objfpc}{$H+}

interface

uses
  LCLProc, LCLType, Classes, SysUtils, FormEditingIntf, LCLIntf, Controls, Graphics,
  ProjectIntf, Forms, tui;

type

  { TTUIControlMediator }

  { TTuirMediator }

  TTuirMediator = class(TDesignerMediator,ITUIRDesigner)
  private
    FMyForm: TtuiWindow;
    FUpdateCount : integer;
    FScreenRendered: Boolean;
    FBmp : TBitmap;
    procedure InvalidateRect(ConsoleRect: TRect);
    procedure InvalidateBound(Sender: TObject);
    procedure BeginUpdate;
    procedure EndUpdate;
    function IsUpdating: boolean;
    procedure RenderChars(x1, y1, x2, y2: integer);
  public

    // needed by the Lazarus form editor
    class function CreateMediator(TheOwner, aForm: TComponent): TDesignerMediator;
      override;
    class function FormClass: TComponentClass; override;
    destructor Destroy; override;
    procedure GetBounds(AComponent: TComponent; out CurBounds: TRect); override;
    procedure SetBounds(AComponent: TComponent; NewBounds: TRect); override;
    procedure GetClientArea(AComponent: TComponent; out
            CurClientArea: TRect; out ScrollOffset: TPoint); override;

    procedure Paint0;
    procedure Paint; override;
    function ComponentIsIcon(AComponent: TComponent): boolean; override;
    function ParentAcceptsChild(Parent: TComponent;
                Child: TComponentClass): boolean; override;
    procedure InitComponent(AComponent, NewParent: TComponent; NewBounds: TRect); override;
    procedure SetLCLForm(const AValue: TForm); override;
    procedure SetFormBounds(RootComponent: TComponent; NewBounds, ClientRect: TRect); override;
    procedure GetFormBounds(RootComponent: TComponent; out CurBounds, CurClientRect: TRect); override;

  public
    property MyForm: TtuiWindow read FMyForm;
  public
    procedure GetObjInspNodeImageIndex(APersistent: TPersistent; var AIndex: integer); override;
  end;


Const
  TERMINAL_FONT_NAME = 'Terminal'; //it's Windows XP, what else?
  TERMINAL_FONT_SIZE = 10;
const
  LCLColors : array[0..$F] of TColor = (
    //lowres:
    clBlack   ,
    clNavy    ,
    clGreen   ,
    clTeal    ,
    clMaroon  ,
    clPurple  ,
    clOlive   ,
    clSilver  ,
    //highres:
    clGray    ,
    $00FF5252 ,//clNavy    ,
    clLime    ,
    clAqua    ,
    clRed     ,
    clFuchsia ,
    clYellow  ,
    clWhite
  );

procedure Register;

implementation

uses
  Video {VideoBuf}, Math;

procedure Register;
begin
  FormEditingHook.RegisterDesignerMediator(TTuirMediator);
end;

type
  TtuiWindowAccess = class(TtuiWindow);

    type
    TBuf = packed record
      S : char;
      Att : byte;
    end;
    PBuf = ^TBuf;




var
  FontWidth, FontHeight : Integer;

function Chars2Pixel(A: TRect) : TRect;
begin
  with A do
  result := Rect(
         left* FontWidth, top * FontHeight,
         right * FontWidth, bottom * FontHeight);
end;

function InDesktopOrigin(BView: TView): TPoint;
var
  Parent: TView;
  ClientArea: TRect;
  ScrollOffset: TPoint;
  CurBounds: TRect;
begin
  Result:=Point(0,0);
  while BView<>nil do begin
    BView.GetBounds(CurBounds);
    inc(Result.X,CurBounds.Left);
    inc(Result.Y,CurBounds.Top);
    //GetClientArea(Parent,ClientArea,ScrollOffset);
    //inc(Result.X,ClientArea.Left+ScrollOffset.X);
    //inc(Result.Y,ClientArea.Top+ScrollOffset.Y);
    //BView:=Parent;
    //Parent:=BView.GetParentComponent;
    //if Parent=nil then break;
    BView:=BView.Parent;
  end;
end;

function InCharsBounds(AView: TView):TRect;
var p : TPoint; //R: TRect;
begin
  AView.GetBounds(Result);
  p := InDesktopOrigin(AView);
  //p.Offset(MyForm.Left* FontWidth, MyForm.Top * FontHeight);
  //Result := Bounds(p.x, p.y, AView.Width * FOntWidth, AView.Height * FontHeight);
  Result.Offset(p);
end;

{ TTuirMediator }


class function TTuirMediator.CreateMediator(TheOwner, aForm: TComponent
  ): TDesignerMediator;
var
  Mediator: TTuirMediator;

  function NewVideoBuf ():PVideoBuf;
  var NewVideoBufSize : longint;
  begin
    //NewVideoBufSize:=ScreenWidth*ScreenHeight*sizeof(TVideoCell);
    NewVideoBufSize:=Mediator.FMyForm.DesktopSize.X * Mediator.FMyForm.DesktopSize.Y *sizeof(TVideoCell);
    GetMem(Result,NewVideoBufSize);
    fillchar(Result^, NewVideoBufSize, $00);
  end;


begin
  Result:=inherited CreateMediator(TheOwner,aForm);
  Mediator:=TTuirMediator(Result);
  Mediator.FMyForm:=aForm as TtuiWindow;
  Mediator.FBmp := TBitmap.Create;
  with Mediator.FBmp.Canvas do
    begin
      Font.Size := TERMINAL_FONT_SIZE;
      Font.Name:= TERMINAL_FONT_NAME;

      Brush.Style:=bsSolid;
      with TextExtent('H') do begin
        FontWidth := cx;
        FontHeight := cy;
      end;
  end;
  Mediator.FBmp.SetSize(Mediator.FMyForm.DesktopSize.X * FontWidth, Mediator.FMyForm.DesktopSize.Y * FontHeight);

  with Mediator.FMyForm do
  begin
    Designer:=Mediator;
    if Buffer = nil then
      Buffer:= NewVideoBuf();
    Invalidate;
  end;
end;

class function TTuirMediator.FormClass: TComponentClass;
begin
  Result:=TtuiWindow;
end;

destructor TTuirMediator.Destroy;
begin
  FBmp.Free;
  inherited Destroy;
end;

procedure TTuirMediator.InvalidateRect(ConsoleRect: TRect);
var R : TRect;
begin
  if (LCLForm=nil) or (not LCLForm.HandleAllocated) then exit;
  //it's wrong:
  with ConsoleRect do begin
    R.Left  := Left * FontWidth;
    R.Right := Right * FontWidth;
    R.Top   := Top * FontHeight;
    R.Bottom:= Bottom * FontHeight;
  end;
  LCLIntf.InvalidateRect(LCLForm.Handle,@R,False);
end;

procedure TTuirMediator.InvalidateBound(Sender: TObject);
var R : TRect; P : TPoint;
  Container: TView;
begin
  if IsUpdating then exit;
  if sender is TView then
  begin
    {P := self.GetComponentOriginOnForm(TView(Sender));
    GetBounds(TView(Sender), R);
    OffsetRect(R, -R.Left, -R.Top);
    OffsetRect(R, P.x, P.y);
    //LCLIntf.InvalidateRect(LCLForm.Handle,@R,False);
    R := LCLForm.ClientRect;
    Container := TView(Sender);
    if Assigned(Container.Parent) then
       Container := Container.Parent;
    GetBounds(TComponent(Container), R);
    // lazarus draw selection artifact !
    }
    //R := LCLForm.ClientRect;
    //GetBounds(Self.FMyForm, R);
    //LCLIntf.InvalidateRect(LCLForm.Handle,@R,True);
    R := InCharsBounds(TView(Sender));
    RenderChars(r.Left,r.Top, r.Right, r.Bottom);
  end;
end;

procedure TTuirMediator.BeginUpdate;
begin
  inc(FUpdateCount);
end;

procedure TTuirMediator.EndUpdate;
begin
  dec(FUpdateCount);
end;

function TTuirMediator.IsUpdating: boolean;
begin
  result := (FUpdateCount > 0) or (LCLForm=nil) or (not LCLForm.HandleAllocated);
end;


procedure TTuirMediator.GetBounds(AComponent: TComponent; out
  CurBounds: TRect);
var
  c: TView;
  l,t : Integer;
begin
  if AComponent is TView then
  begin
    c:=TView(AComponent);
    CurBounds:=Bounds(
      c.Left * FontWidth,  c.Top * FontHeight,
      c.Width * FontWidth, c.Height * FontHeight);
  end else
    inherited GetBounds(AComponent,CurBounds);
end;


procedure TTuirMediator.InitComponent(AComponent, NewParent: TComponent;
  NewBounds: TRect);
var R : TRect; W,H : integer;
begin
  if (AComponent = self.FMyForm)  then
  begin
    if EqualRect(FMyForm.DesktopBound, EmptyRect) then
    begin
      self.GetBounds(FMyForm, R); //get width,height in LCL coordinate world
      OffsetRect(R, -R.Left, -R.Top); //move to zero
      OffsetRect(R, NewBounds.Left, NewBounds.Top); //move to newbound pos

      FMyForm.DesktopBound := R;
    end;
  end
  else
  if (AComponent is TView)  then
  begin
    self.GetBounds(AComponent, R); //get width,height in LCL coordinate world
    OffsetRect(R, -R.Left, -R.Top); //move to zero
    OffsetRect(R, NewBounds.Left, NewBounds.Top);
    inherited InitComponent(AComponent, NewParent, R);
  end
  else
    inherited InitComponent(AComponent, NewParent, NewBounds);
end;

procedure TTuirMediator.SetLCLForm(const AValue: TForm);
begin
  inherited SetLCLForm(AValue);
  if AValue <> nil then
    AValue.BoundsRect := FMyForm.DesktopBound;
end;

procedure TTuirMediator.SetBounds(AComponent: TComponent; NewBounds: TRect);
var AView : TView;

  function InFormBounds():TRect;
  var p : TPoint; R: TRect;
  begin
    p := GetComponentOriginOnForm(AView);
    //p.Offset(MyForm.Left* FontWidth, MyForm.Top * FontHeight);
    Result := Bounds(p.x, p.y, AView.Width * FOntWidth, AView.Height * FontHeight);
  end;

  {function InDesktopOrigin(BView: TView): TPoint;
  var
    Parent: TView;
    ClientArea: TRect;
    ScrollOffset: TPoint;
    CurBounds: TRect;
  begin
    Result:=Point(0,0);
    while BView<>nil do begin
      BView.GetBounds(CurBounds);
      inc(Result.X,CurBounds.Left);
      inc(Result.Y,CurBounds.Top);
      //GetClientArea(Parent,ClientArea,ScrollOffset);
      //inc(Result.X,ClientArea.Left+ScrollOffset.X);
      //inc(Result.Y,ClientArea.Top+ScrollOffset.Y);
      //BView:=Parent;
      //Parent:=BView.GetParentComponent;
      //if Parent=nil then break;
      BView:=BView.Parent;
    end;
  end;

  function InCharsBounds():TRect;
  var p : TPoint; //R: TRect;
  begin
    AView.GetBounds(Result);
    p := InDesktopOrigin(AView);
    //p.Offset(MyForm.Left* FontWidth, MyForm.Top * FontHeight);
    //Result := Bounds(p.x, p.y, AView.Width * FOntWidth, AView.Height * FontHeight);
    Result.Offset(p);
  end; }


var l,t,w,h : integer; R1, R2, R : TRect;
begin //here the form created by ide.new() -> width=50,height=50
  if AComponent is TView then begin
    AView := TView(AComponent);
//    BeginUpdate;
    //GetBounds(AComponent, R1);
//    R1 := InCharsBounds();
    w := (NewBounds.Right-NewBounds.Left +1);// div FontWidth;
    h := (NewBounds.Bottom-NewBounds.Top +1);// div FontHeight;

    l := NewBounds.Left div FontWidth;
    t := NewBounds.Top div FontHeight;
    w := w div FontWidth;
    h := h div FontHeight;
    TView(AComponent).SetBounds(l,t,  w, h);
    //GetBounds(AComponent, R2);
//    R2 := InCharsBounds();
//    R := R1 + R2;
    {With R1 do Writeln('R1:', Left, ', ', TOP, ', ', right, ', ',  bottom, ', ', width, ', ', Height);
    With R2 do Writeln('R2:', Left, ', ', TOP, ', ', right, ', ',  bottom, ', ', width, ', ', Height);
    With R do Writeln('R:',   Left, ', ', TOP, ', ', right, ', ',  bottom, ', ', width, ', ', Height);}
    {Writeln(R2);
    Writeln(R);}
//    RenderChars(r.Left,r.Top, r.Right, r.Bottom);
    //LCLIntf.InvalidateRect(LCLForm.Handle,@R,True);
//    EndUpdate;
  end
  else
    inherited SetBounds(AComponent,NewBounds);

end;

{procedure TTuirMediator.InvalidateRect(Sender: TObject; ARect: TRect;
  Erase: boolean);
begin
  if (LCLForm=nil) or (not LCLForm.HandleAllocated) then exit;
  LCLIntf.InvalidateRect(LCLForm.Handle,@ARect,Erase);
end;}

procedure TTuirMediator.GetObjInspNodeImageIndex(APersistent: TPersistent;
  var AIndex: integer);
begin
  if Assigned(APersistent) then
  begin
    if (APersistent is TGroup) then
      AIndex := FormEditingHook.GetCurrentObjectInspector.ComponentTree.ImgIndexBox
    else
    if (APersistent is TView) then
      AIndex := FormEditingHook.GetCurrentObjectInspector.ComponentTree.ImgIndexControl
    else
      inherited;
  end
end;


procedure TTuirMediator.GetClientArea(AComponent: TComponent; out
  CurClientArea: TRect; out ScrollOffset: TPoint);
begin
  if AComponent = FMyForm then begin
    //Widget:=TMyWidget(AComponent);
    with FMyForm do
        //CurClientArea := Rect(Left* FontWidth, Top* FontHeight, Width* FontWidth, Height* FontHeight);
    CurClientArea := Bounds(Left* FontWidth, Top* FontHeight, Width* FontWidth, Height* FontHeight);
    ScrollOffset:=Point(0,0);
  end else
    inherited GetClientArea(AComponent, CurClientArea, ScrollOffset);
end;


procedure TTuirMediator.Paint0;
var TheCanvas : TCanvas;
  procedure PaintBuffer();
  // copy the VideoBuffer to LCLForm

  type
    TBuf = packed record
      S : char;
      Att : byte;
    end;
    PBuf = ^TBuf;

    procedure ApplyColor(Att:Byte);
    var c : Byte;
    begin
      with TheCanvas do begin
        //background
        c := (Att and $F0) shr 4;
        Brush.Color := LCLColors[c];

        //text
        c := Att and $F;
        Font.Color := LCLColors[c];

      end;
    end;

  var
    Buf : TBuf;
    BufP : PBuf;
    //CharH, CharW: Integer;
    x,y,x1,y1 : Integer;
    s :   string;
    LastAtt : byte;
    CurrentVideoBuf : PVideoBuf;
  begin
    CurrentVideoBuf := FMyForm.Buffer;
    //if CurrentVideoBuf = nil then
      // CurrentVideoBuf := VideoBuf; //use global if not found

    {with LCLForm do
    begin
    //try
      Font.Size := TERMINAL_FONT_SIZE;
      Font.Name:= TERMINAL_FONT_NAME;
    //except    end;
    end;}

    TheCanvas := FBmp.Canvas;
    with TheCanvas do
    begin
      Font.Size := TERMINAL_FONT_SIZE;
      Font.Name:= TERMINAL_FONT_NAME;

      Brush.Style:=bsSolid;
      {with TextExtent('H') do begin
        FontWidth := cx;
        FontHeight := cy;
        CharW := cx;
        CharH := cy;
      end;}

      // fill background
      Brush.Style:=bsSolid;
      Brush.Color:= clLime;// clBlack;
      //Fillrect(LCLForm.ClientRect);
      FillRect(Rect(0,0, FMyForm.DesktopSize.X * FontWidth, FMyForm.DesktopSize.Y * FontHeight));
      //exit;

      // first color
      {Buf := PBuf(VideoBuf)^;
      ApplyColor(Buf.Att);
      LastAtt := Buf.Att;}
      LastAtt := $FE;
{
      //we should offset the Window on BufferScreen into DesignerForm
      x1 := FMyForm.Left;
      y1 := FMyForm.Top;

      {//but now we are in designtime
      x1 := 0;
      y1 := 0;
      }

      // Y = 0..height
      for y := y1 to Min(ScreenHeight-1, y1+FMyForm.Height-1 ) do
      begin
        x := x1;
        //BufP := Pointer(VideoBuf + (((y * ScreenWidth) + x) * SizeOf(TVideoCell)) );

        // X = 0..Width
        while x < Min(ScreenWidth, x1+self.FMyForm.Width)  do
        begin
          BufP := PBuf(longint(CurrentVideoBuf) + ((y) * ScreenWidth + (x) ) * SizeOf(TVideoCell) );
          //inc(BufP, (y * ScreenWidth + x) * SizeOf(TVideoCell));
          if BufP^.Att <> LastAtt then
          begin
            ApplyColor(BufP^.Att);
            LastAtt := BufP^.Att;
          end;
          //if BufP^.S > #30 then
            TextOut(x * FontWidth, y * FontHeight, BufP^.S);

          //inc(BufP, sizeof(TBuf));
          inc(x);
        end;
      end; //for y
}
      //we should offset the Window on BufferScreen into DesignerForm
      x1 := FMyForm.Left;
      y1 := FMyForm.Top;

      for y := 0 to FMyForm.DesktopSize.y - 1 do
      // Y = 0..height
      //for y := y1 to Min(FMyForm.DesktopSize.y, y1+FMyForm.Height ) - 1 do
      //for y := 0 to FMyForm.Height - 1 do
      begin
        for x := 0 to FMyForm.DesktopSize.x - 1 do
        //for x := x1 to Min(FMyForm.DesktopSize.x, x1+FMyForm.Width ) - 1 do
        //for x := 0 to FMyForm.Width - 1 do
        begin
          BufP := PBuf(Pointer(CurrentVideoBuf) + (
            (
              (y * FMyForm.DesktopSize.x)
              + x
            ) * SizeOf(TBuf) ));
          if(ord(BUfP^.S)) < 32 then
            continue;

          if BufP^.Att <> LastAtt then
          begin
            ApplyColor(BufP^.Att);
            LastAtt := BufP^.Att;
          end;
          //if BufP^.S > #30 then
          //TextOut(x1 + x * FontWidth, y1 + y * FontHeight, BufP^.S);
          TextOut( x * FontWidth,  y * FontHeight, BufP^.S);
        end;
      end;

      Brush.Color := clBlack;
      Line(
           FMyForm.DesktopSize.X * FontWidth, 0,
           FMyForm.DesktopSize.x * FontWidth, LCLForm.Height);
      Line(
           0, FMyForm.DesktopSize.Y * FontHeight,
           FMyForm.DesktopSize.X * FontWidth, FMyForm.DesktopSize.y* FontHeight);
    end; //with canvas

    if TheCanvas <> LCLForm.Canvas then
    with LCLForm.Canvas do
    begin
      SaveHandleState;
        //BitBlt( LCLForm.Canvas.Handle, 0,0, min(FBmp.Width, LCLForm.ClientWidth), min(FBmp.Height, LCLForm.ClientHeight), FBmp.Canvas.Handle,0,0, SRCCOPY)
        BitBlt( LCLForm.Canvas.Handle, 0,0, FBmp.Width, FBmp.Height, FBmp.Canvas.Handle,0,0, SRCCOPY);
      RestoreHandleState;
    end;
    FScreenRendered := true;
  end;

begin
  if csLoading in FMyForm.ComponentState then exit;

  {LCLForm.Canvas.Brush.Style:=bsSolid;
  LCLForm.Canvas.Brush.Color:=clFuchsia;
  LCLForm.Canvas.FillRect(LCLForm.ClientRect);}

  if not FScreenRendered then //PaintBuffer();
  begin
    RenderChars(0,0,  FMyForm.DesktopSize.X,  FMyForm.DesktopSize.y );
    FScreenRendered := True;
  end;
  //else
      //BitBlt( LCLForm.Canvas.Handle, 0,0, FBmp.Width, FBmp.Height, FBmp.Canvas.Handle,0,0, SRCCOPY);
  LCLForm.Canvas.Draw(0,0, FBmp);
  {with LCLForm.Canvas do
    begin
      //SaveHandleState;
        //BitBlt( LCLForm.Canvas.Handle, 0,0, min(FBmp.Width, LCLForm.ClientWidth), min(FBmp.Height, LCLForm.ClientHeight), FBmp.Canvas.Handle,0,0, SRCCOPY)
        BitBlt( LCLForm.Canvas.Handle, 0,0, FBmp.Width, FBmp.Height, FBmp.Canvas.Handle,0,0, SRCCOPY);
      //RestoreHandleState;
    end;}

  inherited Paint;
end;


procedure TTuirMediator.Paint;

  procedure PaintWidget(AView: TView);
  var
    i: Integer;
    //Child: TMyWidget;
    R : TRect;
  begin
    with LCLForm.Canvas do begin
      // fill background
      {Brush.Style:=bsSolid;
      Brush.Color:=clLtGray;
      FillRect(0,0,AWidget.Width,AWidget.Height);
      // outer frame
      Pen.Color:=clRed;
      Rectangle(0,0,AWidget.Width,AWidget.Height);
      // inner frame
      if AWidget.AcceptChildrenAtDesignTime then begin
        Pen.Color:=clMaroon;
        Rectangle(AWidget.BorderLeft-1,AWidget.BorderTop-1,
                  AWidget.Width-AWidget.BorderRight+1,
                  AWidget.Height-AWidget.BorderBottom+1);
      end;
      // caption
      TextOut(5,2,AWidget.Caption); }

      //AWidget.GetBounds(R);
      R:= InCharsBounds(AView); //console desktop
      R:= Chars2Pixel(R);
      BitBlt( LCLForm.Canvas.Handle, R.Left,r.Top, R.Width, R.Height, FBmp.Canvas.Handle,R.Left,r.Top, SRCCOPY);

      {

      // children
      if AWidget.ChildCount>0 then begin
        SaveHandleState;
        // clip client area
        MoveWindowOrgEx(Handle,AWidget.BorderLeft,AWidget.BorderTop);
        if IntersectClipRect(Handle, 0, 0, AWidget.Width-AWidget.BorderLeft-AWidget.BorderRight,
                             AWidget.Height-AWidget.BorderTop-AWidget.BorderBottom)<>NullRegion
        then begin
          for i:=0 to AWidget.ChildCount-1 do begin
            SaveHandleState;
            Child:=AWidget.Children[i];
            // clip child area
            MoveWindowOrgEx(Handle,Child.Left,Child.Top);
            if IntersectClipRect(Handle,0,0,Child.Width,Child.Height)<>NullRegion then
              PaintWidget(Child);
            RestoreHandleState;
          end;
        end;
        RestoreHandleState;
      end;
      }
    end;
  end;

begin
  if csLoading in FMyForm.ComponentState then exit;

  {LCLForm.Canvas.Brush.Style:=bsSolid;
  LCLForm.Canvas.Brush.Color:=clFuchsia;
  LCLForm.Canvas.FillRect(LCLForm.ClientRect);}

  if not FScreenRendered then //PaintBuffer();
  begin
    RenderChars(0,0,  FMyForm.DesktopSize.X,  FMyForm.DesktopSize.y );
    FScreenRendered := True;
  end;

  PaintWidget(MyForm);
  inherited Paint;
end;

procedure TTuirMediator.RenderChars(x1,y1, x2, y2: integer);
  procedure ApplyColor(Att:Byte);
  var c : Byte;
  begin
    with FBmp.Canvas do begin
      //background
      c := (Att and $F0) shr 4;
      Brush.Color := LCLColors[c];

      //text
      c := Att and $F;
      Font.Color := LCLColors[c];

    end;
  end;
var
  x,y,LastAtt: byte;
  Buf : TBuf;  BufP : PBuf;
  CurrentVideoBuf : PVideoBuf;
  R: TRect;
begin
    CurrentVideoBuf := FMyForm.Buffer;
    with FBmp.Canvas do
    begin
      Font.Size := TERMINAL_FONT_SIZE;
      Font.Name:= TERMINAL_FONT_NAME;

      Brush.Style:=bsSolid;
      {with TextExtent('H') do begin
        FontWidth := cx;
        FontHeight := cy;
        CharW := cx;
        CharH := cy;
      end;}

      // fill background
      Brush.Style:=bsSolid;
      Brush.Color:= clLime;// clBlack;
      //Fillrect(LCLForm.ClientRect);
      //FillRect(Rect(0,0, FMyForm.DesktopSize.X * FontWidth, FMyForm.DesktopSize.Y * FontHeight));
      //exit;

      // first color
      {Buf := PBuf(VideoBuf)^;
      ApplyColor(Buf.Att);
      LastAtt := Buf.Att;}
      LastAtt := $FE;

      //we should offset the Window on BufferScreen into DesignerForm
      //x1 := FMyForm.Left;
      //y1 := FMyForm.Top;

      for y := y1 to y2 do
      begin
        for x := x1 to x2 do
        begin
          BufP := PBuf(Pointer(CurrentVideoBuf) + (
            (
              (y * FMyForm.DesktopSize.x)
              + x
            ) * SizeOf(TBuf) ));
          if(ord(BUfP^.S)) < 32 then
            continue;

          if BufP^.Att <> LastAtt then
          begin
            ApplyColor(BufP^.Att);
            LastAtt := BufP^.Att;
          end;
          //if BufP^.S > #30 then
          //TextOut(x1 + x * FontWidth, y1 + y * FontHeight, BufP^.S);
          TextOut( x * FontWidth,  y * FontHeight, BufP^.S);
        end;
      end;
    end;
    R := Chars2Pixel(Rect(x1,y1,x2,y2));
    BitBlt( LCLForm.Canvas.Handle, r.left,r.top, r.Width, r.Height, FBmp.Canvas.Handle, r.left,r.top, SRCCOPY);
    LCLIntf.InvalidateRect(LCLForm.Handle,@R,False);


end;

function TTuirMediator.ComponentIsIcon(AComponent: TComponent): boolean;
begin
  Result:=not (AComponent is TView);
end;

function TTuirMediator.ParentAcceptsChild(Parent: TComponent;
  Child: TComponentClass): boolean;
begin
  Result:=(Parent is TGroup) and Child.InheritsFrom(TView);
end;

procedure TTuirMediator.SetFormBounds(RootComponent: TComponent; NewBounds,
  ClientRect: TRect);
begin
  //with ClientRect do
  //FBmp.SetSize(right-left+1, bottom-Top+1);
  with TtuiWindow(RootComponent) do
  begin
    DesktopBound := NewBounds;
    //DesktopClient := ClientRect;
  end;
end;

procedure TTuirMediator.GetFormBounds(RootComponent: TComponent; out CurBounds,
  CurClientRect: TRect);
begin
  with TtuiWindow(RootComponent) do
  begin
    CurBounds := DesktopBound;
    //CurClientRect := DesktopClient;
  end;
end;



//--- copied from video.inc because these are has no `interface`
//    and we don't want to activate video nor driver

Procedure FreeVideoBuf;

begin
  if (VideoBuf<>Nil) then
    begin
    FreeMem(VideoBuf);
    FreeMem(OldVideoBuf);
    VideoBuf:=Nil;
    OldVideoBuf:=Nil;
    VideoBufSize:=0;
    end;
end;

Procedure AssignVideoBuf (OldCols, OldRows : Word);

var NewVideoBuf,NewOldVideoBuf:PVideoBuf;
    old_rowstart,new_rowstart:word;
    NewVideoBufSize : longint;

begin
  NewVideoBufSize:=ScreenWidth*ScreenHeight*sizeof(TVideoCell);
  GetMem(NewVideoBuf,NewVideoBufSize);
  GetMem(NewOldVideoBuf,NewVideoBufSize);
  {Move contents of old videobuffers to new if there are any.}
  if VideoBuf<>nil then
    begin
      if ScreenWidth<OldCols then
        OldCols:=ScreenWidth;
      if ScreenHeight<OldRows then
        OldRows:=ScreenHeight;
      old_rowstart:=0;
      new_rowstart:=0;
      while oldrows>0 do
        begin
          move(VideoBuf^[old_rowstart],NewVideoBuf^[new_rowstart],OldCols*sizeof(TVideoCell));
          move(OldVideoBuf^[old_rowstart],NewOldVideoBuf^[new_rowstart],OldCols*sizeof(TVideoCell));
          inc(old_rowstart,OldCols);
          inc(new_rowstart,ScreenWidth);
          dec(OldRows);
        end;
    end;
  FreeVideoBuf;
  { FreeVideoBuf sets VideoBufSize to 0 }
  VideoBufSize:=NewVideoBufSize;
  VideoBuf:=NewVideoBuf;
  OldVideoBuf:=NewOldVideoBuf;
end;

initialization
  FontWidth  := 16;
  FontHeight := 12;
  ScreenWidth := 80;
  ScreenHeight:= 40;

  AssignVideoBuf(0,0);

finalization
  FreeVideoBuf;
end.

