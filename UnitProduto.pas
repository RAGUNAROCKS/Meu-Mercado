unit UnitProduto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

type
  TFrmProduto = class(TForm)
    LytToolbar: TLayout;
    ImgVoltar: TImage;
    LytFoto: TLayout;
    ImgFoto: TImage;
    LblNome: TLabel;
    Layout1: TLayout;
    Layout2: TLayout;
    LblUnidade: TLabel;
    LblValor: TLabel;
    LblDescricao: TLabel;
    RectRodap�: TRectangle;
    Layout3: TLayout;
    ImgMais: TImage;
    ImgMenos: TImage;
    LblQtd: TLabel;
    BtnAdicionar: TButton;
    LytFundo: TLayout;
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmProduto: TFrmProduto;

implementation

{$R *.fmx}

uses UnitPrincipal;

procedure TFrmProduto.FormResize(Sender: TObject);
begin
    if (FrmProduto.Width > 400) then
    begin
      LytFundo.Align := TAlignLayout.Center;
      BtnAdicionar.Align := TAlignLayout.Right;
    end
    else
    begin
      LytFundo.Align := TAlignLayout.Client;
      BtnAdicionar.Align := TAlignLayout.Client;
    end
end;

end.