unit tui_reg;

interface

uses
  Classes, SysUtils;

procedure Register;

implementation
uses PropEdits,tui_prop_color, tui, TUI_widgets;

procedure Register;
begin
  RegisterComponents('Standard',[TGroup, TtuiLabel, TtuiFrame]);

  RegisterPropertyEditor(TypeInfo(word), TView, 'Color', TTuiColorEditor);

  //RegisterPropertyEditor(TypeInfo(widestring), TlqWidget, 'Caption', TStringMultilinePropertyEditor);
  //RegisterPropertyEditor(TypeInfo(widestring), TlqWidget, 'Text', TStringMultilinePropertyEditor);
///  RegisterPropertyEditor(TypeInfo(lq_main.TCursor), TlqWidget, 'Cursor', TCursorPropertyEditor);
  //RegisterPropertyEditor(TypeInfo(string), TlqWidget, 'FontDesc', TFontDescPropertyEditor);

end;

end.
