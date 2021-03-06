unit uTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OleCtrls, SHDocVw, StrUtils, ExtCtrls,ActiveX;

type
  TForm1 = class(TForm)
    wb1: TWebBrowser;
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure LoadStream(WebBrowser:TWebBrowser; Stream:TStream);
var
  PersistStreamInit: IPersistStreamInit;
  StreamAdapter: IStream;
  MemoryStream: TMemoryStream;
begin
  WebBrowser.Navigate('about:blank');
  repeat
    Application.ProcessMessages;
    Sleep(0);
  until
  WebBrowser.ReadyState=READYSTATE_COMPLETE;
  if WebBrowser.Document.QueryInterface(IPersistStreamInit,PersistStreamInit)=S_OK then
  begin
    if PersistStreamInit.InitNew=S_OK then
    begin
      MemoryStream:=TMemoryStream.Create;
      try
        MemoryStream.CopyFrom(Stream,0);
        MemoryStream.Position:=0;
      except
        MemoryStream.Free;
      raise;
      end;
      StreamAdapter:=TStreamAdapter.Create(MemoryStream,soOwned);
      PersistStreamInit.Load(StreamAdapter);
    end;
  end;
end;

function CreateChartHtml(const ChartType:string):string;overload;
var
  sList:TStringList;
  path,fn:string;
begin
  path := ExtractFilePath(ParamStr(0));
  fn := path+'ShowChart.html';
  sList := TStringList.Create;
  if FileExists(fn) then
    sList.LoadFromFile(fn);
  sList.Text := StringReplace(sList.Text,'��ChartType��',ChartType,[rfReplaceAll]);
  sList.SaveToFile(path+ChartType+'.html');
  Result := sList.Text;
  sList.Free;
end;

function CreateChartHtml(const ChartType,XMLData:string):string;overload;
var
  sList:TStringList;
  path,fn:string;
begin
  path := ExtractFilePath(ParamStr(0));
  fn := path+'ShowChart2.html';
  sList := TStringList.Create;
  if FileExists(fn) then
    sList.LoadFromFile(fn);
  sList.Text := StringReplace(sList.Text,'��ChartType��',ChartType,[rfReplaceAll]);
  sList.Text := StringReplace(sList.Text,'��XMLData��',XMLData,[rfReplaceAll]);
  sList.Text := StringReplace(sList.Text,#$D#$A,'',[rfReplaceAll]);
  sList.SaveToFile(path+ChartType+'.html');
  Result := sList.Text;
  sList.Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  path,fn,chartType,surl:string;
  S: TStringStream;
begin
  chartType := 'MSLine';
  path := ExtractFilePath(ParamStr(0));
  //surl := CreateChartHtml(chartType,Memo1.Text);
  surl := CreateChartHtml(chartType);
  surl := path+chartType+'.html';
  wb1.Navigate(surl);
  exit;
  S:= TStringStream.Create(surl);
  try
   LoadStream(wb1,S);
  finally
    S.Free;
  end;
end;

end.
