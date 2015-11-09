unit TUI_DesignDescriptor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazIDEIntf, ProjectIntf, Controls, Forms,
  TUI;
type
  { TProjectApplicationDescriptor }

  TTUIApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles({%H-}AProject: TLazProject): TModalResult; override;
  end;

{ TFileDescPascalUnitWithTUIForm }

  TFileDescPascalUnitWithTUIForm = class(TFileDescPascalUnitWithResource)
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
uses TUI_Forms, TUI_DesignMediator;

procedure Register;
begin
  //FileDescPascalUnitWithPgfForm := TFileDescPascalUnitWithPgfForm.Create();
  RegisterProjectFileDescriptor(TFileDescPascalUnitWithTUIForm.Create,
                                FileDescGroupName);
  RegisterProjectDescriptor(TTUIApplicationDescriptor.Create);
end;

function FileDescriptorHDForm() : TProjectFileDescriptor;
begin
  Result:=ProjectFileDescriptors.FindByName('TUIForm');
end;

{ TFileDescPascalUnitWithTUIForm }

constructor TFileDescPascalUnitWithTUIForm.Create;
begin
  inherited Create;
  Name:='TUIForm';
  ResourceClass:=TTUIForm;
  UseCreateFormStatements:=true;
end;

function TFileDescPascalUnitWithTUIForm.GetInterfaceUsesSection: string;
begin
  Result:='Classes, SysUtils, TUI, TUI_Forms';
end;

function TFileDescPascalUnitWithTUIForm.GetLocalizedName: string;
begin
  Result:='TUIForm';
end;

function TFileDescPascalUnitWithTUIForm.GetLocalizedDescription: string;
begin
  Result:='Create a new Form for TUI Console Application';
end;

function TFileDescPascalUnitWithTUIForm.GetUnitDirectives: string;
begin
  result := inherited GetUnitDirectives();
  result := '{$ifdef fpc}'+ LineEnding
           +result + LineEnding
           +'{$endif}';
end;

{function TFileDescPascalUnitWithTUIForm.GetImplementationSource(const Filename,
  SourceName, ResourceName: string): string;
begin
  Result:='{$R *.dfm}'+LineEnding+LineEnding;
end;}

{ TProjectApplicationDescriptor }

constructor TTUIApplicationDescriptor.Create;
begin
  inherited;
  Name := 'TUI Application';
end;

function TTUIApplicationDescriptor.CreateStartFiles(
  AProject: TLazProject): TModalResult;
begin
  Result:=LazarusIDE.DoNewEditorFile(FileDescriptorHDForm,'','',
                         [nfIsPartOfProject,nfOpenInEditor,nfCreateDefaultSrc]);
end;

function TTUIApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result := 'TUI Application'+LineEnding+LineEnding
           +'An application based on the TUI.'+LineEnding
           +'The program files is automatically maintained by Lazarus.';
end;

function TTUIApplicationDescriptor.GetLocalizedName: string;
begin
  Result := 'TUI Console Application';
end;

function TTUIApplicationDescriptor.InitProject(
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
  AProject.UseManifest:=true;
  AProject.LoadDefaultIcon;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'{$ifdef fpc}'+LineEnding
    +'{$mode delphi}{$H+}'+LineEnding
    +'{$endif}'+LineEnding
    +LineEnding
    +'uses'+LineEnding
    //+'  {$IFDEF UNIX}{$IFDEF UseCThreads}'+LineEnding
    //+'  cthreads,'+LineEnding
    //+'  {$ENDIF}{$ENDIF}'+LineEnding
    //+'  Interfaces, // this includes the LCL widgetset'+LineEnding
    +'  TUI, TUI_Forms '+LineEnding
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
  AProject.AddPackageDependency('TUI_runtime');
  //AProject.LazCompilerOptions.Win32GraphicApp:=true;
  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
end;

end.


