program Project1;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitLogin in 'UnitLogin.pas' {FrmLogin},
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  UnitCatalogo in 'UnitCatalogo.pas' {FrmCatalogo},
  Frame.ProdutoCard in 'Frames\Frame.ProdutoCard.pas' {FrameProdutCard: TFrame},
  UnitSplash in 'UnitSplash.pas' {FrmSplash};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TFrmCatalogo, FrmCatalogo);
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TFrmSplash, FrmSplash);
  Application.Run;
end.
