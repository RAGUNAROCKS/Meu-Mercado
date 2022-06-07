unit DataModule.Mercado;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  DataSet.Serialize.Config, RESTRequest4D, uConsts, FireDAC.Stan.Async,
  FireDAC.DApt;

type
  TDmMercado = class(TDataModule)
    TabMercado: TFDMemTable;
    TabCategoria: TFDMemTable;
    TabProduto: TFDMemTable;
    TabProdDetalhe: TFDMemTable;
    QryMercado: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ListarMercado(busca, ind_entrega, ind_retira: string);
    procedure ListarMercadoId(id_mercado: integer);
    procedure ListarCategoria(id_mercado: integer);
    procedure ListarProduto(id_mercado, id_categoria : integer; busca : string);
    procedure ListarProdutoId(id_produto: integer);
    function ExistePedidoLocal(id_mercado: integer): boolean;
    { Public declarations }
  end;

var
  DmMercado: TDmMercado;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses DataModule.Usuario;

{$R *.dfm}

procedure TDmMercado.DataModuleCreate(Sender: TObject);
begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower;
end;

procedure TDmMercado.ListarMercado(busca, ind_entrega, ind_retira : string);
var
  resp: Iresponse;
begin

     resp := TRequest.New.BaseURL(BASE_URL)
             .Resource('mercados')
             .DataSetAdapter(TabMercado)
             .AddParam('busca', busca)
             .AddParam('ind_entrega', ind_entrega)
             .AddParam('ind_retira', ind_retira)
             .Accept('application/json')
             .BasicAuthentication(USER_NAME, PASSWORD).Get;

     if (resp.StatusCode <> 200) then
      raise Exception.Create(resp.Content);

end;

procedure TDmMercado.ListarMercadoId(id_mercado : integer);
var
  resp: Iresponse;
begin

     resp := TRequest.New.BaseURL(BASE_URL)
             .Resource('mercados')
             .ResourceSuffix(id_mercado.ToString)
             .DataSetAdapter(TabMercado)
             .Accept('application/json')
             .BasicAuthentication(USER_NAME, PASSWORD).Get;

     if (resp.StatusCode <> 200) then
      raise Exception.Create(resp.Content);

end;

procedure TDmMercado.ListarCategoria(id_mercado : integer);
var
  resp: Iresponse;
begin

     resp := TRequest.New.BaseURL(BASE_URL)
             .Resource('mercados')
             .ResourceSuffix(id_mercado.ToString + '/categorias')
             .DataSetAdapter(TabCategoria)
             .Accept('application/json')
             .BasicAuthentication(USER_NAME, PASSWORD).Get;

     if (resp.StatusCode <> 200) then
      raise Exception.Create(resp.Content);

end;

procedure TDmMercado.ListarProduto(id_mercado, id_categoria : integer; busca : string);
var
  resp: Iresponse;
begin

     resp := TRequest.New.BaseURL(BASE_URL)
             .Resource('mercados')
             .ResourceSuffix(id_mercado.ToString + '/produtos')
             .AddParam('id_categoria', id_categoria.ToString)
             .AddParam('busca', busca)
             .DataSetAdapter(TabProduto)
             .Accept('application/json')
             .BasicAuthentication(USER_NAME, PASSWORD).Get;

     if (resp.StatusCode <> 200) then
      raise Exception.Create(resp.Content);

end;

procedure TDmMercado.ListarProdutoId(id_produto : integer);
var
  resp: Iresponse;
begin

     resp := TRequest.New.BaseURL(BASE_URL)
             .Resource('produtos')
             .ResourceSuffix(id_produto.ToString)
             .DataSetAdapter(TabProdDetalhe)
             .Accept('application/json')
             .BasicAuthentication(USER_NAME, PASSWORD).Get;

     if (resp.StatusCode <> 200) then
      raise Exception.Create(resp.Content);

end;

function TDmMercado.ExistePedidoLocal(id_mercado: integer):boolean;
begin
   with DmMercado.QryMercado do
   begin
    Active := false;
    SQL.Clear;
    SQL.Add('SELECT * FROM TAB_CARRINHO WHERE ID_MERCADO <> :ID_MERCADO');
    parambyname('ID_MERCADO').Value := id_mercado;
    Active := true;
    Result := RecordCount > 0;
   end;
end;

end.
