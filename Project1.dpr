program Project1;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitLogin in 'UnitLogin.pas' {FrmLogin},
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  UnitCatalogo in 'UnitCatalogo.pas' {FrmCatalogo},
  Frame.ProdutoCard in 'Frames\Frame.ProdutoCard.pas' {FrameProdutCard: TFrame},
  UnitSplash in 'UnitSplash.pas' {FrmSplash},
  UnitCarrinho in 'UnitCarrinho.pas' {FrmCarrinho},
  Frame.ProdutoLista in 'Frames\Frame.ProdutoLista.pas' {FrameProdutLista: TFrame},
  UnitPedido in 'UnitPedido.pas' {FrmPedido},
  UnitPedidoDetalhe in 'UnitPedidoDetalhe.pas' {FrmPedidoDetalhe},
  UnitProduto in 'UnitProduto.pas' {FrmProduto},
  DataModule.Usuario in 'DataModule\DataModule.Usuario.pas' {DmUsuario: TDataModule},
  uLoading in 'Units\uLoading.pas',
  DataModule.Mercado in 'DataModule\DataModule.Mercado.pas' {DmMercado: TDataModule},
  uConsts in 'Units\uConsts.pas',
  uFunctions in 'Units\uFunctions.pas',
  uSession in 'Units\uSession.pas',
  UnitPerfil in 'UnitPerfil.pas' {FrmPerfil};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDmUsuario, DmUsuario);
  Application.CreateForm(TDmMercado, DmMercado);
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TFrmPerfil, FrmPerfil);
  Application.Run;
end.
