unit DataModule.Usuario;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  DataSet.Serialize.Config, RESTRequest4D, System.JSON;

type
  TDmUsuario = class(TDataModule)
    TabUsuario: TFDMemTable;
    procedure DataModuleCreate(Sender: TObject);
  private

    { Private declarations }
  public
    procedure Login(email, senha: string);
    procedure CriarConta(nome, email, senha, endereco, bairro, cidade, uf,
      cep: string);
    { Public declarations }
  end;

var
  DmUsuario: TDmUsuario;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmUsuario.DataModuleCreate(Sender: TObject);
begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
end;

procedure TDmUsuario.Login(email, senha : string);
var
  resp: Iresponse;
  json: TJSONObject;
begin
   try
     json := TJSONObject.Create;
     json.AddPair('email', email);
     json.AddPair('senha', senha);

     resp := TRequest.New.BaseURL('http://localhost:3000')
             .Resource('usuarios/login')
             .DataSetAdapter(TabUsuario)
             .AddBody(json.ToJSON)
             .Accept('application/json')
             .BasicAuthentication('99coders', '123456').Post;

     if (resp.StatusCode = 401) then
      raise Exception.Create('Email ou senha inv�lida!')
     else if (resp.StatusCode <> 200) then
      raise Exception.Create(resp.Content);

   finally
     json.DisposeOf;
   end;
end;

procedure TDmUsuario.CriarConta(nome, email, senha, endereco, bairro,
                                 cidade, uf, cep : string);
var
  resp: Iresponse;
  json: TJSONObject;
begin
   try
     json := TJSONObject.Create;
     json.AddPair('nome', nome);
     json.AddPair('email', email);
     json.AddPair('senha', senha);
     json.AddPair('endereco', endereco);
     json.AddPair('bairro', bairro);
     json.AddPair('cidade', cidade);
     json.AddPair('uf', uf);
     json.AddPair('cep', cep);

     resp := TRequest.New.BaseURL('http://localhost:3000')
             .Resource('usuarios/cadastro')
             .DataSetAdapter(TabUsuario)
             .AddBody(json.ToJSON)
             .Accept('application/json')
             .BasicAuthentication('99coders', '123456').Post;

     if (resp.StatusCode = 401) then
      raise Exception.Create('Usuario n�o autorizado!')
     else if (resp.StatusCode <> 201) then
      raise Exception.Create(resp.Content);

   finally
     json.DisposeOf;
   end;
end;

end.