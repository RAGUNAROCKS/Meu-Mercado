unit UnitLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects, FMX.Edit,
  uLoading, uSession;

type
  TFrmLogin = class(TForm)
    Image1: TImage;
    TabControl: TTabControl;
    TabLogin: TTabItem;
    Layout1: TLayout;
    Label1: TLabel;
    EdtEmail: TEdit;
    EdtSenha: TEdit;
    BtnLogin: TButton;
    TabConta1: TTabItem;
    TabConta2: TTabItem;
    LblCadConta: TLabel;
    Label3: TLabel;
    EdtEmailCad: TEdit;
    EdtSenhaCad: TEdit;
    BtnProx: TButton;
    Image2: TImage;
    LblLogin1: TLabel;
    Label5: TLabel;
    EdtNomeCad: TEdit;
    Image3: TImage;
    Layout3: TLayout;
    Label6: TLabel;
    EdtBairroCad: TEdit;
    EdtCidadeCad: TEdit;
    BtnCriarConta: TButton;
    Label7: TLabel;
    EdtEnderecoCad: TEdit;
    LblLogin2: TLabel;
    Layout4: TLayout;
    EdtUFCad: TEdit;
    EdtCEPCad: TEdit;
    Layout2: TLayout;
    StyleBook: TStyleBook;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    Rectangle4: TRectangle;
    Rectangle5: TRectangle;
    Rectangle6: TRectangle;
    Rectangle7: TRectangle;
    Rectangle8: TRectangle;
    Rectangle9: TRectangle;
    Rectangle10: TRectangle;
    procedure BtnLoginClick(Sender: TObject);
    procedure LblCadContaClick(Sender: TObject);
    procedure LblLoginClick(Sender: TObject);
    procedure BtnProxClick(Sender: TObject);
    procedure BtnCriarContaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure ThreadLoginTerminate(Sender: TObject);
    procedure ThreadShowTerminate(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.fmx}

uses DataModule.Usuario, UnitPrincipal;

procedure TFrmLogin.LblLoginClick(Sender: TObject);
begin
  TabControl.GotoVisibleTab(0);
end;

procedure TFrmLogin.BtnProxClick(Sender: TObject);
begin
  TabControl.GotoVisibleTab(2);
end;

procedure TFrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    //Action := TCloseAction.caFree;
    //FrmLogin := nil;
end;

procedure TFrmLogin.ThreadShowTerminate(Sender: TObject);
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

   if DmUsuario.QryUsuario.RecordCount > 0 then
   begin
      //Abrir o Unit Principal
      if NOT Assigned(FrmPrincipal) then
        Application.CreateForm(TFrmPrincipal, FrmPrincipal);

      Application.MainForm := FrmPrincipal;
      TSession.ID_USUARIO := DmUsuario.QryUsuario.FieldByName('id_usuario').AsInteger;
      FrmPrincipal.LblMenuNome.text := DmUsuario.QryUsuario.FieldByName('nome').AsString;
      FrmPrincipal.LblMenuEmail.text := DmUsuario.QryUsuario.FieldByName('email').AsString;
      FrmPrincipal.Show;
      FrmLogin.Close;
   end;
end;

procedure TFrmLogin.FormShow(Sender: TObject);
var
  t: TThread;
begin
  TLoading.Show(FrmLogin, '');
  t := TThread.CreateAnonymousThread(procedure
    begin
      DmUsuario.ListarUsuarioLocal;
    end);

  t.OnTerminate := ThreadShowTerminate;
  t.Start;
end;

procedure TFrmLogin.LblCadContaClick(Sender: TObject);
begin
  TabControl.GotoVisibleTab(1);
end;

procedure TFrmLogin.ThreadLoginTerminate(Sender: TObject);
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

   //Abrir o Unit Principal
   if NOT Assigned(FrmPrincipal) then
      Application.CreateForm(TFrmPrincipal, FrmPrincipal);
   try
     DmUsuario.ListarUsuarioLocal;
   finally
   end;
   Application.MainForm := FrmPrincipal;
   TSession.ID_USUARIO := DmUsuario.QryUsuario.FieldByName('id_usuario').AsInteger;
   FrmPrincipal.LblMenuNome.text := DmUsuario.QryUsuario.FieldByName('nome').AsString;
   FrmPrincipal.LblMenuEmail.text := DmUsuario.QryUsuario.FieldByName('email').AsString;
   FrmPrincipal.Show;
   FrmLogin.Close;
end;

procedure TFrmLogin.BtnCriarContaClick(Sender: TObject);
var
  t : TThread;
begin
  TLoading.Show(FrmLogin, '');
  t := TThread.CreateAnonymousThread(procedure
  begin
     DmUsuario.CriarConta(EdtNomeCad.Text, EdtEmailCad.Text, EdtSenhaCad.Text,
                          EdtEnderecoCad.Text, EdtBairroCad.Text, EdtCidadeCad.Text,
                          EdtUFCad.Text, EdtCepCad.Text);

     with DmUsuario.TabUsuario do
     begin
       if RecordCount > 0 then
       begin
          DmUsuario.SalvarUsuarioLocal(fieldbyname('id_usuario').asinteger,
                                       EdtEmailCad.Text,
                                       EdtNomeCad.Text,
                                       EdtEnderecoCad.Text,
                                       EdtBairroCad.Text,
                                       EdtCidadeCad.Text,
                                       EdtUFCad.Text,
                                       EdtCepCad.Text);
       end;
     end;
  end);

  t.OnTerminate := ThreadLoginTerminate;
  t.Start;
end;

procedure TFrmLogin.BtnLoginClick(Sender: TObject);
var
  t : TThread;
begin
  TLoading.Show(FrmLogin, '');
  t := TThread.CreateAnonymousThread(procedure
  begin
     DmUsuario.Login(edtEmail.Text, edtSenha.Text);
     with DmUsuario.TabUsuario do
     begin
       if RecordCount > 0 then
       begin
          DmUsuario.SalvarUsuarioLocal(fieldbyname('id_usuario').asinteger,
                                       fieldbyname('email').asstring,
                                       fieldbyname('nome').asstring,
                                       fieldbyname('endereco').asstring,
                                       fieldbyname('bairro').asstring,
                                       fieldbyname('cidade').asstring,
                                       fieldbyname('uf').asstring,
                                       fieldbyname('cep').asstring);
       end;
     end;
     
  end);

  t.OnTerminate := ThreadLoginTerminate;
  t.Start;
end;

end.
