program tuiProject;

uses
    Objects,
  SysUtils, Video, Mouse, Drivers,
  Tui, Tui_widgets, Unit1
  { you can add units after this };

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
  Mouse.SetMouseXY(1,1);
  //readln;
  //s := 'ge~t~uk';
  //Move(pchar(s), VideoBuf^, length(s));
  //MoveStr(VideoBuf^, s, $5678);
  //MoveCStr(VideoBuf^, s, $5678);
  //p := VideoBuf;
  //inc(p, 40 *2);
  //MoveCStr(p^, s, $5678);
  //readln;
  tuiWindow1 := TtuiWindow1.Create(nil);
  tuiWindow1.Invalidate(True);

  UpdateScreen(false);
  readln;
  {Application.Initialize;
  Application.CreateForm(TtuiWindow1, tuiWindow1);
  Application.Run;}
end.

