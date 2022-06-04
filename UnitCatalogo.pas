unit UnitCatalogo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit, FMX.ListBox,
  uLoading, System.Net.HttpClientComponent, System.Net.HttpClient, uFunctions;

type
  TFrmCatalogo = class(TForm)
    LytToolbar: TLayout;
    LblTitulo: TLabel;
    ImgVoltar: TImage;
    ImgCarrinho: TImage;
    LtyEndereco: TLayout;
    LblEndereco: TLabel;
    Image3: TImage;
    LblTaxa: TLabel;
    Image4: TImage;
    LblPreco: TLabel;
    LytPesquisa: TLayout;
    RectPesquisa: TRectangle;
    EdtBusca: TEdit;
    Image5: TImage;
    BtnBusca: TButton;
    LtbCategoria: TListBox;
    TbiAlimentos: TListBoxItem;
    TbiBebidas: TListBoxItem;
    Rectangle1: TRectangle;
    Label1: TLabel;
    Label2: TLabel;
    Rectangle2: TRectangle;
    LtbProdutos: TListBox;
    procedure FormShow(Sender: TObject);
    procedure LtbCategoriaItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure LtbProdutosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure BtnBuscaClick(Sender: TObject);
    procedure ImgVoltarClick(Sender: TObject);
  private
    FId_Mercado: integer;
    procedure AddProduto(id_produto: integer;
                         descricao, unidade, url_foto: string;
                         valor: double);
    procedure ListarProdutos(id_categoria: integer; busca: string);
    procedure ListarCategorias;
    procedure AddCategoria(id_categoria: integer; descricao: string);
    procedure SelecionarCategoria(item: TListBoxItem);
    procedure CarregarDados;
    procedure ThreadDadosTerminate(Sender: TObject);
    procedure ThreadProdutosTerminate(Sender: TObject);
    procedure DownloadFoto(lb: TListBox);
    { Private declarations }
  public
    property Id_mercado: integer read FId_Mercado write FId_Mercado;
    { Public declarations }
  end;

var
  FrmCatalogo: TFrmCatalogo;

implementation

{$R *.fmx}

uses UnitPrincipal, Frame.ProdutoCard, UnitProduto, DataModule.Mercado;

procedure TFrmCatalogo.DownloadFoto(lb: TListBox);
var
    t: TThread;
    foto: TBitmap;
    frame: TFrameProdutCard;
begin
    // Carregar imagens...
    t := TThread.CreateAnonymousThread(procedure
    var
        i : integer;
    begin

        for i := 0 to lb.Items.Count - 1 do
        begin
            frame := TFrameProdutCard(lb.ItemByIndex(i).Components[0]);


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

procedure TFrmCatalogo.AddProduto(id_produto: integer;
                                  descricao, unidade, url_foto: string;
                                  valor: double);
var
    item: TListBoxItem;
    frame: TFrameProdutCard;
begin
    item := TListBoxItem.Create(LtbProdutos);
    item.Selectable := false;
    item.Text := '';
    item.Height := 175;
    item.Tag := id_produto;

    frame := TFrameProdutCard.Create(item);
    //frame.img Produto(
    frame.LblDescricao.Text := descricao;
    frame.LblPreco.Text := FormatFloat('R$ #,##0.00', valor);
    frame.LblUnidade.Text := unidade;
    frame.ImgProduto.TagString := url_foto;

    item.AddObject(frame);

    LtbProdutos.AddObject(item);
end;

procedure TFrmCatalogo.BtnBuscaClick(Sender: TObject);
begin
        ListarProdutos(LtbCategoria.Tag, EdtBusca.Text);
end;

procedure TFrmCatalogo.ListarProdutos(id_categoria: integer; busca: string);
var
  t : TThread;
begin
    LtbProdutos.Items.Clear;
    Tloading.Show(FrmCatalogo, '');

    t := TThread.CreateAnonymousThread(procedure
    begin
      DmMercado.ListarProduto(Id_mercado, id_categoria, busca);
      with DmMercado.TabProduto do
       begin
        while NOT Eof do
        begin
          TThread.Synchronize(TThread.CurrentThread, procedure
          begin
            AddProduto(fieldbyname('id_produto').asinteger,
                       fieldbyname('nome').asstring,
                       fieldbyname('unidade').asstring,
                       fieldbyname('url_foto').asstring,
                       fieldbyname('preco').asfloat);
          end);

          Next;
        end;
       end;
    end);
    t.OnTerminate := ThreadProdutosTerminate;
    t.Start;
end;

procedure TFrmCatalogo.LtbCategoriaItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
    SelecionarCategoria(Item);
    ListarProdutos(LtbCategoria.Tag, EdtBusca.Text);
end;

procedure TFrmCatalogo.LtbProdutosItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
    if NOT assigned(FrmProduto) then
      application.CreateForm(TFrmProduto, FrmProduto);

      FrmProduto.Id_produto := Item.Tag;
      FrmProduto.Show;
end;

procedure TFrmCatalogo.SelecionarCategoria(item: TListBoxItem);
 var
    x: Integer;
    item_loop: TListBoxItem;
    rect: TRectangle;
    lbl: TLabel;
 begin
    //Zerar os itens...
    for x := 0 to LtbCategoria.Items.Count - 1 do
    begin
      item_loop := LtbCategoria.ItemByIndex(x);

      rect := TRectangle(item_loop.Components[0]);
      rect.Fill.Color := $FFE2E2E2;

      lbl := TLabel(rect.Components[0]);
      lbl.FontColor := $FF3A3A3A;
    end;

    //Ajusta somente o item selecionado...
    rect := TRectangle(item.Components[0]);
    rect.Fill.Color := $FF64BA01;

    lbl := TLabel(rect.Components[0]);
    lbl.FontColor := $FFFFFFFF;

    //Salvar a categoria selecionada...
    LtbCategoria.Tag := item.Tag;
 end;

procedure TFrmCatalogo.AddCategoria(id_categoria: integer;
                                    descricao: string);
var
    item:TListBoxItem;
    rect:TRectangle;
    lbl:TLabel;
begin
    item := TListBoxItem.Create(LtbCategoria);
    item.Selectable := false;
    item.Text := '';
    item.Width := 100;
    item.Tag := id_categoria;

    rect := TRectangle.Create(item);
    rect.Cursor := crHandPoint;
    rect.HitTest := false;
    rect.Fill.Color := $FFE2E2E2;
    rect.Align := TAlignLayout.Client;
    rect.Margins.Top := 8;
    rect.Margins.Left := 8;
    rect.Margins.Right := 8;
    rect.Margins.Bottom := 8;
    rect.XRadius := 6;
    rect.YRadius := 6;
    rect.Stroke.Kind := TBrushKind.None;

    lbl := TLabel.Create(rect);
    lbl.Align := TAlignLayout.Client;
    lbl.Text := descricao;
    lbl.TextSettings.HorzAlign := TTextAlign.Center;
    lbl.TextSettings.VertAlign := TTextAlign.Center;
    lbl.StyledSettings := lbl.StyledSettings - [TStyledSetting.Size,
                                                TStyledSetting.FontColor,
                                                TStyledSetting.Style,
                                                TStyledSetting.Other];
    lbl.Font.Size := 13;
    lbl.FontColor := $FF3A3A3A;

    rect.AddObject(lbl);
    item.AddObject(rect);
    LtbCategoria.AddObject(item);
end;

procedure TFrmCatalogo.ListarCategorias;
begin
    DmMercado.ListarCategoria(Id_mercado);
     with DmMercado.TabCategoria do
     begin
      while NOT Eof do
      begin
        TThread.Synchronize(TThread.CurrentThread, procedure
        begin
          AddCategoria(fieldbyname('id_categoria').asinteger,
                      fieldbyname('descricao').asstring);
        end);

        Next;
      end;
     end;

     if LtbCategoria.Items.Count > 0 then
      TThread.Synchronize(TThread.CurrentThread, procedure
        begin
          SelecionarCategoria(LtbCategoria.ItemByIndex(0));
        end);
end;

procedure TFrmCatalogo.FormShow(Sender: TObject);
begin
   CarregarDados;
end;

procedure TFrmCatalogo.ImgVoltarClick(Sender: TObject);
begin
   close;
end;

procedure TFrmCatalogo.CarregarDados;
var
  t : TThread;
begin
  TLoading.Show(FrmCatalogo, '');
  LtbCategoria.Items.Clear;
  LtbProdutos.Items.Clear;
  LblTitulo.Opacity := 0;
  LtyEndereco.Opacity := 0;
  t := TThread.CreateAnonymousThread(procedure
  begin
     //Listar dados do mercado...
     DmMercado.ListarMercadoId(Id_mercado);

     with DmMercado.TabMercado do
     begin
        TThread.Synchronize(TThread.CurrentThread, procedure
        begin
           LblTitulo.Text := fieldbyname('nome').asstring;
           LblEndereco.Text := fieldbyname('endereco').asstring;
           LblTaxa.Text := 'Entrega: ' + FormatFloat('R$#,##0.00',fieldbyname('vl_entrega').asfloat);
           LblPreco.Text := 'Compra M�nima: ' + FormatFloat('R$#,##0.00',fieldbyname('vl_compra_min').asfloat);
        end);
     end;

     //Listar as categorias...
     ListarCategorias;
  end);

  t.OnTerminate := ThreadDadosTerminate;
  t.Start;
end;

procedure TFrmCatalogo.ThreadDadosTerminate(Sender: TObject);
begin
   LblTitulo.Opacity := 1;
   LtyEndereco.Opacity := 1;
   TLoading.Hide;

   if Sender is TThread then
   begin
     if Assigned(TThread(Sender).FatalException) then
     begin
      showmessage(Exception(TThread(Sender).FatalException).Message);
      exit;
     end;
   end;

   ListarProdutos(LtbCategoria.Tag, EdtBusca.Text);
end;

procedure TFrmCatalogo.ThreadProdutosTerminate(Sender: TObject);
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

   DownloadFoto(ltbProdutos);
end;

end.
