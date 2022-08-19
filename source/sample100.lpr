program  sample100;

{.$I platform.inc}

USES
{$IFDEF OS2PM}
     {$IFDEF OS_OS2} Os2Def, os2PmApi,  {$ENDIF}
{$ENDIF OS2PM}
     Objects, SysUtils, Video, Mouse, Drivers, TUI;


//scrollbar
type
   TScrollChars = Array [0..4] of Char;
const
  VChars: array[boolean] of TScrollChars =
     (('^','V', #177, #254, #178),(#30, #31, #177, #254, #178));
  HChars: array[boolean] of TScrollChars =
     (('<','>', #177, #254, #178),(#17, #16, #177, #254, #178));
(*procedure WriteBuf(X, Y, W, H: Sw_Integer; var Buf);
var
  i : Sw_integer;
begin
  if h>0 then
   for i:= 0 to h-1 do
    do_writeView(X,X+W,Y+i,TVideoBuf(Buf)[W*i]);
end;
procedure DrawPos(Pos: Sw_Integer);
var
  S: Sw_Integer;
  B: TDrawBuffer;
  Chars : boolean;
begin
  Chars := HChars[LowAscii];
  S := GetSize - 1;
  MoveChar(B[0], Chars[0], GetColor(2), 1);
  if Max = Min then
    MoveChar(B[1], Chars[4], GetColor(1), S - 1)
  else
   begin
     MoveChar(B[1], Chars[2], GetColor(1), S - 1);
     MoveChar(B[Pos], Chars[3], GetColor(3), 1);
   end;
  MoveChar(B[S], Chars[1], GetColor(2), 1);
  WriteBuf(0, 0, Size.X, Size.Y, B);
end;
*)

procedure ListVideo;
Var
  I : Integer;
  d : TVideoDriver;
  m : TVideoMode;
begin
  GetVideoDriver(d);
  {I:= d.GetVideoModeCount -1;
  While (I>=0) do
  begin
    with d.[i] do
         writeln(format('Row:%d  Col:%d  Color:%d',[col,row,Color]);
      Dec(I);
  end;}

end;

var
  s : string;
  p : Pointer;
begin
  initkeyboard;
  if not Drivers.InitVideo then
  begin
    donekeyboard;
    writeln('VideoFailed');
    halt(1);
  end;
  Drivers.InitEvents;
  Drivers.InitSysError;
  video.SetCursorType(crHidden);
  ListVideo();
  Mouse.SetMouseXY(1,1);
  //readln;
  s := 'ge~t~uk';
  //Move(pchar(s), VideoBuf^, length(s));
  //MoveStr(VideoBuf^, s, $5678);
  //MoveCStr(VideoBuf^, s, $5678);
  p := VideoBuf;
  inc(p, 40 *2);
  MoveCStr(p^, s, $5678);
  //readln;
  {with TTUIControl.Create(nil) do
  begin
    Left := 20;
    Top := 2;
    Paint;
  end;}
  UpdateScreen(false);
  readln;
end.
