unit TUI_Reg;

interface

uses
  Classes, SysUtils;

procedure Register;

implementation
uses PropEdits,TUI, TUI_Std  ;

procedure Register;
begin
  RegisterComponents('Standard',[TTUIControl,TTUILabel]);

  //RegisterPropertyEditor(TypeInfo(widestring), TlqWidget, 'Caption', TStringMultilinePropertyEditor);
  //RegisterPropertyEditor(TypeInfo(widestring), TlqWidget, 'Text', TStringMultilinePropertyEditor);
///  RegisterPropertyEditor(TypeInfo(lq_main.TCursor), TlqWidget, 'Cursor', TCursorPropertyEditor);
  //RegisterPropertyEditor(TypeInfo(string), TlqWidget, 'FontDesc', TFontDescPropertyEditor);

end;

end.
