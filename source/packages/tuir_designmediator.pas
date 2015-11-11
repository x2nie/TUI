unit Tuir_designMediator;

{$mode objfpc}{$H+}

interface

uses
  LCLProc, LCLType, Classes, SysUtils, FormEditingIntf, LCLIntf, Controls, Graphics,
  ProjectIntf, Tuir;

type

  { TTUIControlMediator }

  { TTuirMediator }

  TTuirMediator = class(TDesignerMediator,ITUIRDesigner)
  private
    FMyForm: TtuiWindow;
    FUpdateCount : integer;
    //ITUIDesigner
    procedure InvalidateRect(Sender: TObject);
    procedure InvalidateBound(Sender: TObject);
    procedure BeginUpdate;
    procedure EndUpdate;
    function IsUpdating: boolean;
  public
    procedure MouseDown({%H-}Button: TMouseButton; {%H-}Shift: TShiftState; {%H-}p: TPoint; var {%H-}Handled: boolean); override;

    // needed by the Lazarus form editor
    class function CreateMediator(TheOwner, aForm: TComponent): TDesignerMediator;
      override;
    class function FormClass: TComponentClass; override;
    procedure GetBounds(AComponent: TComponent; out CurBounds: TRect); override;
    procedure SetBounds(AComponent: TComponent; NewBounds: TRect); override;
    //procedure GetClientArea(AComponent: TComponent; out
      //      CurClientArea: TRect; out ScrollOffset: TPoint); override;
    //procedure GetChildren(Proc: TGetChildProc; ARoot: TComponent); override;
    procedure Paint; override;
    function ComponentIsIcon(AComponent: TComponent): boolean; override;
    function ParentAcceptsChild(Parent: TComponent;
                Child: TComponentClass): boolean; override;
  public
    // needed by TView
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //procedure InvalidateRect(Sender: TObject; ARect: TRect; Erase: boolean);
    property MyForm: TtuiWindow read FMyForm;
  public
    procedure GetObjInspNodeImageIndex(APersistent: TPersistent; var AIndex: integer); override;
  end;


procedure Register;

implementation

uses
  Video {VideoBuf}, Math;

procedure Register;
begin
  FormEditingHook.RegisterDesignerMediator(TTuirMediator);
end;

{ TTuirMediator }
var
  FontWidth, FontHeight : Integer;

const
  LCLColors : array[0..$F] of TColor = (
    //lowres:
    clBlack   ,
    clBlue    ,
    clGreen   ,
    clTeal    ,
    clMaroon  ,
    clPurple  ,
    clOlive   ,
    clSilver  ,
    //highres:
    clGray    ,
    clNavy    ,
    clLime    ,
    clAqua    ,
    clRed     ,
    clFuchsia ,
    clYellow  ,
    clWhite
  );

constructor TTuirMediator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TTuirMediator.Destroy;
begin
  if FMyForm<>nil then FMyForm.Designer:=nil;
  FMyForm:=nil;
  inherited Destroy;
end;

procedure TTuirMediator.InvalidateRect(Sender: TObject);
begin
  if (LCLForm=nil) or (not LCLForm.HandleAllocated) then exit;
  //LCLIntf.InvalidateRect(LCLForm.Handle,@ARect,Erase);
end;

procedure TTuirMediator.InvalidateBound(Sender: TObject);
var R : TRect;
begin
  if IsUpdating then exit;
  if sender is TtuiWindow then
  begin
    //position
    GetBounds(TComponent(Sender), R);
    LCLForm.SetBounds(R.Left, R.Top, LCLForm.Width, LCLForm.Height);
    //size
    OffsetRect(R, -R.Left, -R.Top);
    //R.TopLeft := Point(0,0);
    LCLForm.Width:= R.Right;
    LCLForm.Height := R.Bottom;
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
  result := FUpdateCount > 0;
end;

procedure TTuirMediator.MouseDown(Button: TMouseButton; Shift: TShiftState;
  p: TPoint; var Handled: boolean);
var
  c : TComponent;
  p2 : TPoint;
  tab : integer;
begin
  inherited MouseDown(Button, Shift, p, Handled);
  c := ComponentAtPos(P,TView, [dmcapfOnlyVisible]);
  {if c is TMyTabControl then
  begin
    p2 := GetComponentOriginOnForm(c);
    dec(p.x, p2.x);
    dec(p.y, p2.y);
    tab := TMyTabControl(c).GetTabAt(p.x, p.y);
    if tab > -1 then
      TMyTabControl(c).ActivePage:= tab;
  end;}
end;

class function TTuirMediator.CreateMediator(TheOwner, aForm: TComponent
  ): TDesignerMediator;
var
  Mediator: TTuirMediator;
begin
  Result:=inherited CreateMediator(TheOwner,aForm);
  Mediator:=TTuirMediator(Result);
  Mediator.FMyForm:=aForm as TtuiWindow;
  Mediator.FMyForm.Designer:=Mediator;
end;

class function TTuirMediator.FormClass: TComponentClass;
begin
  Result:=TtuiWindow;
end;

procedure TTuirMediator.GetBounds(AComponent: TComponent; out
  CurBounds: TRect);
var
  w: TView;
begin
  if AComponent is TView then
  begin
    w:=TView(AComponent);
    CurBounds:=Bounds(
      w.Left * FontWidth,  w.Top * FontHeight,
      w.Width * FontWidth, w.Height * FontHeight);
  end else
    inherited GetBounds(AComponent,CurBounds);
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

procedure TTuirMediator.SetBounds(AComponent: TComponent; NewBounds: TRect);
var w,h : integer;
begin //here the form created by ide.new() -> width=50,height=50
  BeginUpdate;
  if AComponent is TView then begin
    w := (NewBounds.Right-NewBounds.Left);// div FontWidth;
    h := (NewBounds.Bottom-NewBounds.Top);// div FontHeight;
    if (w=50) and (h=50) and (AComponent is TtuiWindow) then
    with TView(AComponent) do begin
      w := Width;
      h := Height;
    end
    else
    begin
      w := w div FontWidth;
      h := h div FontHeight;
    end;

    TView(AComponent).SetBounds(NewBounds.Left div FontWidth, NewBounds.Top div FontHeight,
      w, h);
  end
  else
    inherited SetBounds(AComponent,NewBounds);
  EndUpdate;
end;

{procedure TTuirMediator.GetChildren(Proc: TGetChildProc; ARoot: TComponent);
var
  i: Integer;
begin
 inherited GetChildren(Proc, ARoot);

  if ARoot = self.FMyForm then
    for i:=0 to FMyForm.ComponentCount-1 do
      //if FMyForm.Components[i].GetParentComponent = nil then
        Proc(FMyForm.Components[i]);
end; }

procedure TTuirMediator.Paint;

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
      with LCLForm.Canvas do begin
        //background
        c := Att and $F;
        Brush.Color := LCLColors[c];

        //text
        c := (Att and $F0) shr 4;
        Font.Color := LCLColors[c];

      end;
    end;

  var
    Buf : TBuf;
    BufP : PBuf;
    x,y : Integer;
    s :   string;
    LastAtt : byte;
  begin
    with LCLForm do
    begin
    //try
      Font.Size := 10;
      Font.Name:='Terminal'; //it's Windows XP, what else?
    //except    end;
    end;

    with LCLForm.Canvas do
    begin
      Brush.Style:=bsSolid;
      with TextExtent('H') do begin
        FontWidth := cx;
        FontHeight := cy;
      end;

      // fill background
      Brush.Style:=bsSolid;
      Brush.Color:= clLime;// clBlack;
      Fillrect(LCLForm.ClientRect);
      //exit;

      // first color
      {Buf := PBuf(VideoBuf)^;
      ApplyColor(Buf.Att);
      LastAtt := Buf.Att;}
      LastAtt := $FE;


      for y := 0 to Pred( Min(ScreenHeight, FMyForm.Height) ) do
      begin
        x := 0;
        //BufP := Pointer(VideoBuf + (((y * ScreenWidth) + x) * SizeOf(TVideoCell)) );
        while x < Min(ScreenWidth, self.FMyForm.Width)  do
        begin
          BufP := PBuf(longint(VideoBuf) + (y * ScreenWidth + x) * SizeOf(TVideoCell) );
          //inc(BufP, (y * ScreenWidth + x) * SizeOf(TVideoCell));
          if BufP^.Att <> LastAtt then
          begin
            ApplyColor(BufP^.Att);
            LastAtt := BufP^.Att;
          end;
          if BufP^.S > #32 then
            TextOut(x * FontWidth, y * FontHeight, BufP^.S);

          //inc(BufP, sizeof(TBuf));
          inc(x);
        end;
      end; //for y

    end; //with lclcanvas
  end;

begin
  if csLoading in FMyForm.ComponentState then exit;
  PaintBuffer();
  inherited Paint;
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

  AssignVideoBuf(0,0);//todo: make it per form, dont share VideoBuff for all

finalization
  FreeVideoBuf;
end.

