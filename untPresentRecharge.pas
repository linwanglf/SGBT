unit untPresentRecharge;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, DBGrids, SPComm, DB, ADODB, uLkJSON, StrUtils;

type
  TfrmPresentRecharge = class(TForm)
    Panel1: TPanel;
    GroupBox2: TGroupBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edtPresentName: TEdit;
    btnSubmit: TButton;
    btnCancel: TButton;
    GroupBox3: TGroupBox;
    dgRecharge: TDBGrid;
    dsRecharge: TDataSource;
    ADOQ: TADOQuery;
    lblMessage: TLabel;

    lbl1: TLabel;
    edtTotalNum: TEdit;
    lbl2: TLabel;
    edtPresentValue: TEdit;
    lbl3: TLabel;
    edtOperNum: TEdit;
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);

    procedure btnSubmitClick(Sender: TObject);


  private
    { Private declarations }
  public
    { Public declarations }

        //数据库相关
    function initDBRecord(): string;                                               
    procedure savePresentRecord(totalnum:string;opernum:string);
    function  getOperTypeNameByCode(opertype :string ):string;
    function  getTotalNumByPresentName(presentname:string):Integer;
    function  checkUniqueCoin(presentname: string): boolean;
    procedure updateMemberConfiguration(presentname:string);
  end;

var
  frmPresentRecharge: TfrmPresentRecharge;
  curOrderNo: integer = 0; //???
  curOperNo: integer = 0;
  Operate_No: integer = 0; //什么作用?标记正在充值？
  orderLst, recDataLst: Tstrings; //定义全局变量发送数据，接收数据
  ID_UserCard_Text: string;
  IncValue_Enable: boolean; //是否允许充值的标志,会员卡认证通过后置为True
  buffer: array[0..2048] of byte;

  //全局变量用来共享SG3F平台事务ID;
  GLOBALsg3ftrxID: string; //
  GLOBALstrPayID: string; //支付方式　在线01/现金02
  globalOperCoin : string; //操作金额
  globalOperType : string; //操作方式01充值,02消费
  operaSuccess : boolean;


implementation
uses ICDataModule, ICCommunalVarUnit, ICmain, ICEventTypeUnit, ICFunctionUnit, dateProcess, strprocess, IdHashMessageDigest, IdHTTP;
{$R *.dfm}


procedure TfrmPresentRecharge.FormShow(Sender: TObject);
begin  

  //初始化数据库数据
  initDBRecord();          
  
end;

function TfrmPresentRecharge.initDBRecord(): string;
var
  strSQL: string;
  
begin
  with ADOQ do begin
    Connection := DataModule_3F.ADOConnection_Main;
    Active := false;
    SQL.Clear;
    strSQL := ' select ID,PRESENT_NAME,PRESENT_VALUE,TOTAL_NUM,OPER_NUM,OPER_TYPE,OPER_STATE  ' +
            ' ,OPERATE_TIME, OPERATOR_NO ' +
             ' from T_PRESENT_LOG ' +         
             ' order by OPERATE_TIME desc limit 10';
    ICFunction.loginfo('strSQL: ' + strSQL);
    SQL.Add(strSQL);
    Active := True;
  end;
  result := '';

end;






//会员开户操作

procedure TfrmPresentRecharge.btnSubmitClick(Sender: TObject);
var
  totalcoin :string;
  leftNumber :Integer;

begin
  globalOperType :='01';

  if( (IsNumberic(edtPresentValue.Text) = False) or (IsNumberic(edtOperNum.Text) = False) ) then
  begin
      ShowMessage('请输入正确的数字');
      exit
  end;
  if (edtPresentName.Text = '') then
  begin
      ShowMessage('请输入正确的礼品名称');
      exit
  end;

   if checkUniqueCoin(edtPresentName.Text) then
      updateMemberConfiguration(edtPresentName.Text)
   else
   begin
      totalcoin := IntToStr(0 + StrToInt(edtOperNum.Text));
      savePresentRecord(totalcoin,edtOperNum.Text);
   end;
    edtTotalNum.Text := totalcoin;
    initDBRecord();
    lblMessage.Caption := '礼品入库成功';

end;


function TfrmPresentRecharge.getTotalNumByPresentName(presentname:string):Integer;
var strSQL :string;
var TotalNum :Integer;
ADOQTemp: TADOQuery;
begin
  TotalNum :=0;
  strSQL := 'select total_num  from T_PRESENT_LOG where PRESENT_NAME =''' + presentname  + ''' order by operate_time desc ';
  ICFunction.loginfo('strSQL :' + strSQL);
  ADOQTemp := TADOQuery.Create(nil);
  with ADOQTemp do
  begin
    Connection := DataModule_3F.ADOConnection_Main;
    SQL.Clear;
    SQL.Add(strSQL);
    Active := True;
    if (not eof) then
    begin
      TotalNum := ADOQTemp.Fields[0].AsInteger;
      Close;
    end;
    FreeAndNil(ADOQTemp);
  end;
  result := TotalNum;
end;


procedure TfrmPresentRecharge.btnCancelClick(Sender: TObject);
var
  totalcoin :string;
  leftNumber :Integer;
begin
  globalOperType := '02'; //兑换

  if( (IsNumberic(edtPresentValue.Text) = False) or (IsNumberic(edtOperNum.Text) = False) ) then
  begin
      ShowMessage('请输入正确的数字');
      exit
  end;
  if (edtPresentName.Text = '') then
  begin
      ShowMessage('请输入正确的礼品名称');
      exit
  end;
  leftNumber := getTotalNumByPresentName(edtPresentName.text);
  ICFunction.loginfo('leftNumber: ' + IntToStr(leftNumber));
  if  leftNumber <1  then
  begin
       ShowMessage('礼品不存在');
       exit;
  end;
  edtTotalNum.Text := IntToStr(leftNumber);
  totalcoin := IntToStr( leftNumber - StrToInt(edtOperNum.Text));
  if  StrToInt(totalcoin) <1  then
  begin
       ShowMessage('库存不足');
       exit;
  end;

  savePresentRecord(totalcoin,edtOperNum.Text);

  edtTotalNum.Text := totalcoin;
  initDBRecord();
  lblMessage.Caption := '礼品兑换成功';
  
end;


procedure TfrmPresentRecharge.updateMemberConfiguration(presentname:string);
var
  ADOQ: TADOQuery;
  strSQL, strTemp: string;
begin
  strSQL := 'select TOTAL_NUM,OPER_NUM,OPER_TYPE, operate_time,OPERATORNO from  '
    + ' T_PRESENT_LOG where PRESENT_NAME = ''' + presentname + '''';
  strTemp := '';
  ADOQ := TADOQuery.Create(nil);
  with ADOQ do begin
    Connection := DataModule_3F.ADOConnection_Main;
    Active := false;
    SQL.Clear;
    SQL.Add(strSQL);
    Active := true;
    if (RecordCount > 0) then begin
      Edit;
      FieldByName('TOTAL_NUM').AsInteger := StrToInt(edtTotalNum.Text);
      FieldByName('OPER_NUM').AsInteger := StrToInt(edtOperNum.Text);
      FieldByName('OPER_TYPE').AsString := '01';
      FieldByName('OPERATE_TIME').AsString := FormatDateTime('yyyy-MM-dd HH:mm:ss',Now);
      FieldByName('OPERATORNO').AsString  := SGBTCONFIGURE.shopid;      
      Post;
    end;
    Active := False;
  end;
  FreeAndNil(ADOQ);
  initDBRecord();
  lblMessage.Caption := '会员卡销户完成';
 end;
 


procedure TfrmPresentRecharge.savePresentRecord(totalnum:string;opernum:string);
var
  strTrxid, strAppID, strBandid, strShopid, strPayid, strOperateTime, strOperatorNO, strPayState, strNote, strExpireTime, strsql: string;
  intCoin, intLeftCoin, intTotalCoin: Integer;

begin    
  ICFunction.loginfo('Begin savePresentRecord ');
      //指定日期格式 重要
  ShortDateFormat := 'yyyy-MM-dd'; //指定格式即可
  DateSeparator := '-';
    //指定日期格式 否则会报is not an valid date and time;
  strOperateTime := FormatDateTime('yyyy-MM-dd HH:mm:ss', now);
  strOperatorNO := G_User.UserNO;
  
  with ADOQ do begin
    Connection := DataModule_3F.ADOConnection_Main;
    Active := false;
    SQL.Clear;
    strSQL := 'select * from T_PRESENT_LOG order by operate_time desc';
    ICFunction.loginfo('strSQL :' + strSQL);
    SQL.Add(strSQL);
    Active := True;
    Append;
    FieldByName('PRESENT_NAME').AsString := edtPresentName.text;
    FieldByName('PRESENT_VALUE').AsString := edtPresentValue.text;
    FieldByName('TOTAL_NUM').AsInteger := StrToInt(totalnum);
    FieldByName('OPER_NUM').AsInteger := StrToInt(opernum);
    FieldByName('OPER_TYPE').AsString := getOperTypeNameByCode(globalOperType);
    FieldByName('OPER_STATE').AsString := '成功';
    FieldByName('OPERATE_TIME').AsString := strOperateTime;
    FieldByName('OPERATOR_NO').AsString := strOperatorNO;
    post;
  end;
  ICFunction.loginfo('End saveMemberRechargeRecord ');
end;

function TfrmPresentRecharge.checkUniqueCoin(presentname: string): boolean;
var
  ADOQ: TADOQuery;
  strSQL :String;
begin
  ADOQ := TADOQuery.Create(Self);
  ADOQ.Connection := DataModule_3F.ADOConnection_Main;

  with ADOQ do begin
    Close;
    SQL.Clear;
    strSQL := 'select 1 from T_PRESENT_LOG where present_name=''' + presentname + '''';
    ICFunction.loginfo('Exist check  strSQL: ' + strSQL);
    SQL.Add(strSQL);
    Open;
    if (Eof) then
      result := false
    else
      result := true;
  end;
  ADOQ.Close;
  ADOQ.Free;
end;


function TfrmPresentRecharge.getOperTypeNameByCode(opertype :string ):string;
begin
   if opertype='01' then
      Result := '入库'
   else if opertype='02' then
      Result :='兑换';

end;

end.

