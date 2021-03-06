unit Fileinput_cardsaleUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, Buttons, ExtCtrls, DB, ADODB, DateUtils;

type
  Tfrm_Fileinput_cardsale = class(TForm)
    Panel4: TPanel;
    Bit_Update_Package: TBitBtn;
    Bit__Del_TPackage: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn1: TBitBtn;
    Panel1: TPanel;
    DBGrid_Package: TDBGrid;
    Label1: TLabel;
    Edit_PackNo: TEdit;
    Label2: TLabel;
    Edit_CostMoney: TEdit;
    Label3: TLabel;
    Edit_CoinCount: TEdit;
    Label4: TLabel;
    Edit_GivePer: TEdit;
    Label5: TLabel;
    Edit_cUserNo: TEdit;
    Label6: TLabel;
    IfStart: TRadioGroup;
    Label7: TLabel;
    DataSource_Package: TDataSource;
    ADOQuery_Package: TADOQuery;
    Memo_Remark: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Edit_CostMoneyKeyPress(Sender: TObject; var Key: Char);
    procedure Edit_CoinCountKeyPress(Sender: TObject; var Key: Char);
    procedure Edit_GivePerKeyPress(Sender: TObject; var Key: Char);
    procedure DBGrid_PackageDblClick(Sender: TObject);
    procedure Bit_Update_PackageClick(Sender: TObject);
    procedure Bit__Del_TPackageClick(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
  private
    { Private declarations }
    procedure InitDataBase;
  public
    { Public declarations }
  end;

var
  frm_Fileinput_cardsale: Tfrm_Fileinput_cardsale;

implementation

uses ICDataModule, ICCommunalVarUnit, ICmain, ICEventTypeUnit;

{$R *.dfm}

procedure Tfrm_Fileinput_cardsale.FormCreate(Sender: TObject);
begin
  InitDataBase; //显示出型号
end;


procedure Tfrm_Fileinput_cardsale.InitDataBase;
var
  strSQL: string;
begin
      //充值套餐
  with ADOQuery_Package do begin
    Connection := DataModule_3F.ADOConnection_Main;
    Active := false;
    SQL.Clear;
    strSQL := 'select * from [TPackage]';
    SQL.Add(strSQL);
    Active := True;
  end;
end;

procedure Tfrm_Fileinput_cardsale.BitBtn1Click(Sender: TObject);
var
  str3, str4, strinputdatetime, strcore, strlevel, strlevelname, strMemo_instruction, strOperator: string;
  strIsUse: Boolean;
label ExitSub;
begin
  strcore := Edit_PackNo.Text;
  strlevel := Edit_CostMoney.Text;
  str3 := Edit_CoinCount.Text;
  str4 := Edit_GivePer.Text;
  strOperator := G_User.UserNO;
  strinputdatetime := DateTimetostr((now())); //录入时间，读取系统时间
  strMemo_instruction := Memo_Remark.Text;

  if IfStart.ItemIndex = 0 then
    strIsUse := true
  else
    strIsUse := false;

  if Edit_PackNo.Text = '' then
  begin
    ShowMessage('套餐编号不能空');
    exit;
  end
  else if Edit_CostMoney.Text = '' then
  begin
    ShowMessage('套餐金额不能空');
    exit;
  end
  else if Edit_CoinCount.Text = '' then
  begin
    ShowMessage('套餐币数不能空');
    exit;
  end
 //   else if  Edit_GivePer.Text='' then
  // begin
 ////      ShowMessage('套餐赠送币数不能空');
 //      exit;
 //  end
  else begin
    with ADOQuery_Package do begin
      if (Locate('PackNo', strcore, [])) then begin
        if (MessageDlg('已经存在  ' + strcore + '  要更新吗？', mtInformation, [mbYes, mbNo], 0) = mrYes) then
          Edit
        else
          goto ExitSub;
      end
      else
        Append;
      FieldByName('PackNo').AsString := strcore;
      FieldByName('CostMoney').AsString := strlevel;
      FieldByName('CoinCount').AsString := str3;
      FieldByName('GivePer').AsString := str4;

      FieldByName('cUserNo').AsString := strOperator;
      FieldByName('GetTime').AsString := strinputdatetime;
      FieldByName('IfStart').AsBoolean := strIsUse;

      FieldByName('Remark').AsString := strMemo_instruction;
      try
        Post;
      except
        on e: Exception do ShowMessage(e.Message);
      end;
    end;
    ExitSub:
    strcore := Edit_PackNo.Text;
    strlevel := Edit_CostMoney.Text;
    str3 := Edit_CoinCount.Text;
    str4 := Edit_GivePer.Text;
    strOperator := G_User.UserNO;
    strinputdatetime := DateTimetostr((now())); //录入时间，读取系统时间
    strMemo_instruction := Memo_Remark.Text;


    Edit_PackNo.Text := '';
    Edit_CostMoney.Text := '';
    Edit_CoinCount.Text := '';

    Edit_GivePer.Text := '';
    Memo_Remark.Text := '';
  end;
end;

procedure Tfrm_Fileinput_cardsale.Edit_CostMoneyKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (key in ['0'..'9', #8, #13]) then
  begin
    key := #0;
  end
end;

procedure Tfrm_Fileinput_cardsale.Edit_CoinCountKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (key in ['0'..'9', #8, #13]) then
  begin
    key := #0;
        //  ShowMessage('用户或密码输入错误');
  end
end;

procedure Tfrm_Fileinput_cardsale.Edit_GivePerKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (key in ['0'..'9', #8, #13]) then
  begin
    key := #0;
        //  ShowMessage('用户或密码输入错误');
  end
end;

procedure Tfrm_Fileinput_cardsale.DBGrid_PackageDblClick(Sender: TObject);
begin

  Edit_PackNo.Text := DBGrid_Package.DataSource.DataSet.FieldByName('PackNo').AsString;
  Edit_CostMoney.Text := DBGrid_Package.DataSource.DataSet.FieldByName('CostMoney').AsString;
  Edit_CoinCount.Text := DBGrid_Package.DataSource.DataSet.FieldByName('CoinCount').AsString;
  Edit_GivePer.Text := DBGrid_Package.DataSource.DataSet.FieldByName('GivePer').AsString;
  Memo_Remark.Text := DBGrid_Package.DataSource.DataSet.FieldByName('Remark').AsString;
  Edit_cUserNo.Text := DBGrid_Package.DataSource.DataSet.FieldByName('cUserNo').AsString;

  if DBGrid_Package.DataSource.DataSet.FieldByName('IfStart').AsBoolean = true then
    IfStart.ItemIndex := 0
  else
    IfStart.ItemIndex := 1;

  Bit_Update_Package.Enabled := True;
end;

procedure Tfrm_Fileinput_cardsale.Bit_Update_PackageClick(Sender: TObject);
var
  str3, str4, strinputdatetime, strcore, strlevel, strlevelname, strMemo_instruction, strOperator: string;
  strIsUse: Boolean;
label ExitSub;
begin
  strcore := Edit_PackNo.Text;
  strlevel := Edit_CostMoney.Text;
  str3 := Edit_CoinCount.Text;
  str4 := Edit_GivePer.Text;
  strOperator := G_User.UserNO;
  strinputdatetime := DateTimetostr((now())); //录入时间，读取系统时间
  strMemo_instruction := Memo_Remark.Text;

  if IfStart.ItemIndex = 0 then
    strIsUse := true
  else
    strIsUse := false;

  if Edit_PackNo.Text = '' then
  begin
    ShowMessage('套餐编号不能空');
    exit;
  end
  else if Edit_CostMoney.Text = '' then
  begin
    ShowMessage('套餐金额不能空');
    exit;
  end
  else if Edit_CoinCount.Text = '' then
  begin
    ShowMessage('套餐币数不能空');
    exit;
  end
  else begin
    with ADOQuery_Package do begin
      if (not Locate('PackNo', strcore, [])) then begin
        exit;
      end
      else
        Edit;
      FieldByName('PackNo').AsString := strcore;
      FieldByName('CostMoney').AsString := strlevel;
      FieldByName('CoinCount').AsString := str3;
      FieldByName('GivePer').AsString := str4;

      FieldByName('cUserNo').AsString := strOperator;
      FieldByName('GetTime').AsString := strinputdatetime;
      FieldByName('IfStart').AsBoolean := strIsUse;

      FieldByName('Remark').AsString := strMemo_instruction;
      try
        Post;
      except
        on e: Exception do ShowMessage(e.Message);
      end;
    end;

    Edit_PackNo.Text := '';
    Edit_CostMoney.Text := '';
    Edit_CoinCount.Text := '';

    Edit_GivePer.Text := '';
    Memo_Remark.Text := '';

    Bit_Update_Package.Enabled := false;

  end;

end;

procedure Tfrm_Fileinput_cardsale.Bit__Del_TPackageClick(Sender: TObject);

var
  strTemp: string;
begin
  strTemp := ADOQuery_Package.FieldByName('PackNo').AsString;
  if (MessageDlg('确实要删除 编号为' + strTemp + ' 的相关记录吗?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    ADOQuery_Package.DataSource.DataSet.Delete;
end;

procedure Tfrm_Fileinput_cardsale.BitBtn8Click(Sender: TObject);
begin
  close;
end;

end.
