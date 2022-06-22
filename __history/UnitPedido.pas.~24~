unit UnitPedido;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, uLoading,
  uSession, uFunctions;

type
  TFrmPedido = class(TForm)
    LytToolbar: TLayout;
    Label1: TLabel;
    ImgMenu: TImage;
    LvPedidos: TListView;
    ImgShop: TImage;
    procedure FormShow(Sender: TObject);
    procedure LvPedidosItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private
    procedure AddPedidoLv(id_pedido, qtd_itens: integer;
                           nome, endereco, dt_pedido: string;
                           vl_pedido: double);
    procedure ListarPedidos;
    procedure ThreadDadosTerminate(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPedido: TFrmPedido;

implementation

{$R *.fmx}

uses UnitPrincipal, UnitPedidoDetalhe, DataModule.Usuario;

procedure TFrmPedido.AddPedidoLv(id_pedido, qtd_itens: integer;
                                  nome, endereco, dt_pedido: string;
                                  vl_pedido: double);
var img: TListItemImage;
    txt: TListItemText;
begin
      with lvPedidos.Items.add do
      Begin
        height  := 120;
        Tag := id_pedido;

        img := TListItemImage(Objects.FindDrawable('imgShop'));
        img.Bitmap := imgShop.Bitmap;
        txt := TListItemText(Objects.FindDrawable('TxtNome'));
        txt.Text := nome;
        txt := TListItemText(Objects.FindDrawable('TxtPedido'));
        txt.Text := 'Pedido ' + id_pedido.ToString;
        txt := TListItemText(Objects.FindDrawable('TxtEndereco'));
        txt.Text := endereco;
        txt := TListItemText(Objects.FindDrawable('TxtValor'));
        txt.Text := FormatFloat('R$ #,##0.00', vl_pedido) + ' - ' + qtd_itens.ToString + ' itens';
        txt := TListItemText(Objects.FindDrawable('TxtData'));
        txt.Text := Copy(dt_pedido, 1, 16);
      End;
end;

procedure TFrmPedido.ListarPedidos;
var
  t: TThread;
begin
  LvPedidos.Items.Clear;
  LvPedidos.BeginUpdate;
  TLoading.Show(FrmPedido, '');
  t := TThread.CreateAnonymousThread(procedure
    begin
      DmUsuario.ListarPedido(TSession.ID_USUARIO);

      with DmUsuario.TabPedido do
       begin
        while NOT Eof do
        begin
          TThread.Synchronize(TThread.CurrentThread, procedure
          begin
            AddPedidoLv(fieldbyname('id_pedido').asinteger,
                        fieldbyname('qtd_itens').asinteger,
                        fieldbyname('nome').asstring,
                        fieldbyname('endereco').asstring,
                        UTCtoDateBR(fieldbyname('dt_pedido').asstring),
                        fieldbyname('vl_total').asfloat);
          end);

          Next;
        end;
       end;
    end);

  t.OnTerminate := ThreadDadosTerminate;
  t.Start;
end;

procedure TFrmPedido.LvPedidosItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  if NOT assigned(FrmPedidoDetalhe) then
    Application.CreateForm(TFrmPedidoDetalhe, FrmPedidoDetalhe);
    FrmPedidoDetalhe.id_pedido := AItem.Tag;
    FrmPedidoDetalhe.Show;
end;

procedure TFrmPedido.FormShow(Sender: TObject);
begin
  ListarPedidos;
end;

procedure TFrmPedido.ThreadDadosTerminate(Sender: TObject);
begin
   LvPedidos.EndUpdate;
   TLoading.Hide;
   if Sender is TThread then
   begin
     if Assigned(TThread(Sender).FatalException) then
     begin
      showmessage(Exception(TThread(Sender).FatalException).Message);
      exit;
     end;
   end;
end;

end.
