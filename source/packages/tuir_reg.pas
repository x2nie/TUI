unit Tuir_reg;

interface

uses
  Classes, SysUtils;

procedure Register;

implementation
uses PropEdits,tuir_prop_color, Tuir, Tuir_Widgets;

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
