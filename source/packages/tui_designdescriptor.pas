unit tui_designdescriptor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazIDEIntf, ProjectIntf, Controls, Forms,
  tui;
type
  { TProjectApplicationDescriptor }

  TTuirApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles({%H-}AProject: TLazProject): TModalResult; override;
  end;

{ TFileDescPascalUnitWithTtuiWindow }

  TFileDescPascalUnitWithTtuiWindow = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetUnitDirectives: string; override;
    //function GetImplementationSource(const Filename, SourceName,
       //                              ResourceName: string): string; override;
  end;


procedure Register;

implementation
uses tui_designmediator;

procedure Register;
begin
  //FileDescPascalUnitWithPgfForm := TFileDescPascalUnitWithPgfForm.Create();
  RegisterProjectFileDescriptor(TFileDescPascalUnitWithTtuiWindow.Create,
                                FileDescGroupName);
  RegisterProjectDescriptor(TTuirApplicationDescriptor.Create);
end;

function FileDescriptorHDForm() : TProjectFileDescriptor;
begin
  Result:=ProjectFileDescriptors.FindByName('TUIForm');
end;

{ TFileDescPascalUnitWithTtuiWindow }

constructor TFileDescPascalUnitWithTtuiWindow.Create;
begin
  inherited Create;
  Name:='TUIForm';
  ResourceClass:=TtuiWindow;
  UseCreateFormStatements:=true;
end;

function TFileDescPascalUnitWithTtuiWindow.GetInterfaceUsesSection: string;
begin
  Result:='Classes, SysUtils, Tui';
end;

function TFileDescPascalUnitWithTtuiWindow.GetLocalizedName: string;
begin
  Result:='TUIForm';
end;

function TFileDescPascalUnitWithTtuiWindow.GetLocalizedDescription: string;
begin
  Result:='Create a new Form for TUI Console Application';
end;

function TFileDescPascalUnitWithTtuiWindow.GetUnitDirectives: string;
begin
  result := inherited GetUnitDirectives();
  result := '{$ifdef fpc}'+ LineEnding
           +result + LineEnding
           +'{$endif}';
end;

{function TFileDescPascalUnitWithTtuiWindow.GetImplementationSource(const Filename,
  SourceName, ResourceName: string): string;
begin
  Result:='{$R *.dfm}'+LineEnding+LineEnding;
end;}


{ TProjectApplicationDescriptor }

constructor TTuirApplicationDescriptor.Create;
begin
  inherited;
  Name := 'TUI Console Application';
end;

function TTuirApplicationDescriptor.CreateStartFiles(
  AProject: TLazProject): TModalResult;
begin
  Result:=LazarusIDE.DoNewEditorFile(FileDescriptorHDForm,'','',
                         [nfIsPartOfProject,nfOpenInEditor,nfCreateDefaultSrc]);
end;

function TTuirApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result := 'TUI Application'+LineEnding+LineEnding
           +'An application based on the TUI.'+LineEnding
           +'The program files is automatically maintained by Lazarus.';
end;

function TTuirApplicationDescriptor.GetLocalizedName: string;
begin
  Result := 'TUI Console Application';
end;

function TTuirApplicationDescriptor.InitProject(
  AProject: TLazProject): TModalResult;
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;
  AProject.UseAppBundle:=true;
  //AProject.UseManifest:=true;
  //AProject.LoadDefaultIcon;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    (*+'{$ifdef fpc}'+LineEnding
    +'{$mode delphi}{$H+}'+LineEnding
    +'{$endif}'+LineEnding}
    +LineEnding*)
    +'uses'+LineEnding
    //+'  {$IFDEF UNIX}{$IFDEF UseCThreads}'+LineEnding
    //+'  cthreads,'+LineEnding
    //+'  {$ENDIF}{$ENDIF}'+LineEnding
    //+'  Interfaces, // this includes the LCL widgetset'+LineEnding
    +'  TUI, TUI_widgets '+LineEnding
    +'  { you can add units after this };'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    //+'  RequireDerivedFormResource := True;'+LineEnding
    +'  Application.Initialize;'+LineEnding
    +'  Application.Run;'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  // add lcl pp/pas dirs to source search path
  AProject.AddPackageDependency('Tui_runtime');
  //AProject.LazCompilerOptions.Win32GraphicApp:=true;
  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
end;

end.


