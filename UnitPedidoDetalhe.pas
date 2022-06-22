unit UnitPedidoDetalhe;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, uLoading,
  System.JSON, uFunctions;

type
  TFrmPedidoDetalhe = class(TForm)
    LtyEndereco: TLayout;
    LblNomeMerc: TLabel;
    LblEnderecoMerc: TLabel;
    LytToolbar: TLayout;
    LblTitulo: TLabel;
    ImgVoltar: TImage;
    Rectangle1: TRectangle;
    Layout1: TLayout;
    Label1: TLabel;
    LblSubtotal: TLabel;
    Layout2: TLayout;
    Label3: TLabel;
    LblTaxa: TLabel;
    Layout3: TLayout;
    Label5: TLabel;
    LblTotal: TLabel;
    Label7: TLabel;
    LblEndEntrega: TLabel;
    LtbProdutos: TListBox;
    procedure FormShow(Sender: TObject);
    procedure ImgVoltarClick(Sender: TObject);
  private
    Fid_pedido: integer;
    procedure AddProduto(id_produto: integer;
                         descricao, url_foto: string;
                         qtd, valor_unit: double);
    procedure CarregarPedido;
    procedure ThreadDadosTerminate(Sender: TObject);
    procedure DownloadFoto(lb: TListBox);
    { Private declarations }
  public
     property id_pedido: integer read Fid_pedido write Fid_pedido;
    { Public declarations }
  end;

var
  FrmPedidoDetalhe: TFrmPedidoDetalhe;

implementation

{$R *.fmx}

uses Frame.ProdutoLista, DataModule.Usuario;

procedure TFrmPedidoDetalhe.DownloadFoto(lb: TListBox);
var
    t: TThread;
    foto: TBitmap;
    frame: TFrameProdutLista;
begin
    // Carregar imagens...
    t := TThread.CreateAnonymousThread(procedure
    var
        i : integer;
    begin

        for i := 0 to lb.Items.Count - 1 do
        begin
            frame := TFrameProdutLista(lb.ItemByIndex(i).Components[0]);


            if frame.ImgProduto.TagString <> '' then
            begin
                foto := TBitmap.Create;
                LoadImageFromURL(foto, frame.ImgProduto.TagString);

                frame.ImgProduto.TagString := '';
                frame.ImgProduto.bitmap := foto;
            end;
        end;

    end);

    t.Start;
end;

procedure TFrmPedidoDetalhe.AddProduto(id_produto: integer;
                                 descricao, url_foto: string;
                                 qtd, valor_unit: double);
var
    item: TListBoxItem;
    frame: TFrameProdutLista;
begin
    item := TListBoxItem.Create(LtbProdutos);
    item.Selectable := false;
    item.Text := '';
    item.Height := 80;
    item.Tag := id_produto;

    frame := TFrameProdutLista.Create(item);
    frame.ImgProduto.TagString := url_foto;
    frame.LblDescricao.Text := descricao;
    frame.LblQtd.Text := qtd.ToString + ' x ' + FormatFloat('R$ #,##0.00', valor_unit);
    frame.LblValor.Text := FormatFloat('R$ #,##0.00', qtd * valor_unit);

    item.AddObject(frame);

    LtbProdutos.AddObject(item);
end;

procedure TFrmPedidoDetalhe.CarregarPedido;
var
  t: TThread;
  jsonObj: TJsonObject;
  arrayItem: TJSONArray;
begin
  TLoading.Show(FrmPedidoDetalhe, '');
  LtbProdutos.Items.Clear;
  t := TThread.CreateAnonymousThread(procedure
    begin
      jsonObj := DmUsuario.JsonPedido(id_pedido);
      TThread.Synchronize(TThread.CurrentThread, procedure
      var
        I: integer;
      begin
        LblTitulo.Text := 'Pedido #' + jsonObj.GetValue<string>('id_pedido', '');
        LblNomeMerc.Text := jsonObj.GetValue<string>('nome_mercado', '');
        LblEnderecoMerc.Text := jsonObj.GetValue<string>('endereco_mercado', '');
        LblSubtotal.Text := FormatFloat('R$ #,##0.00', jsonObj.GetValue<double>('vl_subtotal', 0));
        LblTaxa.Text := FormatFloat('R$ #,##0.00', jsonObj.GetValue<double>('vl_entrega', 0));
        LblTotal.Text := FormatFloat('R$ #,##0.00', jsonObj.GetValue<double>('vl_total', 0));
        LblEndEntrega.Text := jsonObj.GetValue<string>('endereco', '');

        arrayItem := jsonObj.GetValue<TJSONArray>('itens');

        for I := 0 to arrayItem.Size - 1 do
        begin
           AddProduto(arrayItem.get(I).GetValue<integer>('id_produto', 0),
                      arrayItem.get(I).GetValue<string>('descricao', ''),
                      arrayItem.get(I).GetValue<string>('url_foto', ''),
                      arrayItem.get(I).GetValue<integer>('qtd', 0),
                      arrayItem.get(I).GetValue<double>('vl_unitario', 0))

        end;

      end);
      jsonObj.DisposeOf;
    end);

  t.OnTerminate := ThreadDadosTerminate;
  t.Start;
end;

procedure TFrmPedidoDetalhe.ThreadDadosTerminate(Sender: TObject);
begin
   TLoading.Hide;
   if Sender is TThread then
   begin
     if Assigned(TThread(Sender).FatalException) then
     begin
      showmessage(Exception(TThread(Sender).FatalException).Message);
      exit;
     end;
   end;
   DownloadFoto(LtbProdutos);
end;

procedure TFrmPedidoDetalhe.FormShow(Sender: TObject);
begin
      CarregarPedido;
end;

procedure TFrmPedidoDetalhe.ImgVoltarClick(Sender: TObject);
begin
  close;
end;

end.
