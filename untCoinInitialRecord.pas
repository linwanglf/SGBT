unit untCoinInitialRecord;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, SPComm, DB, ADODB, Grids, DBGrids,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  IdAntiFreezeBase, IdAntiFreeze;

type
  TfrmCoinInitial = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    edtShopID: TEdit;
    Label2: TLabel;
    cbCoinType: TComboBox;
    btnInitial: TButton;
    dgInitial: TDBGrid;
    ADOQueryInitial: TADOQuery;
    dsInitial: TDataSource;
    commInitial: TComm;
    lblMessage: TLabel;
    edtBandID: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    edtAPPID: TEdit;
    Label6: TLabel;
    edtCoin: TEdit;
    Label7: TLabel;
    edtCoinCost: TEdit;
    label5: TLabel;
    edtTypeID: TEdit;
    btnDelete: TButton;
  //  memo1: TMemo;
    procedure commInitialReceiveData(Sender: TObject; Buffer: Pointer;
      BufferLength: Word);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnInitialClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }

        //���ݿ����
    function initCoinRecord(): string;
    procedure saveInitialRecord(); //�����ֵ��¼
    procedure updateCoinInitialRecord(coinid:string);
    function checkUniqueCoinID(ID_INIT: string): Boolean;
    function  getInitValueByTypeName(strTypeName: string): string;
    function  getTypeIDFromTypeName(strTypeName: string): string;
    function  getTypeNameFromTypeID(StrIDtype: string): string;
    function  getTypeNameByTypeID(coinid:string):String; //��DB
    
        //��ͷ��������
    procedure checkCMDInfo();
    procedure initIncrOperation(strRechargeCoin: string); //��ֵ������д���ݸ���
    function  caluSendCMD(strCMD: string; strIncrValue: string): string;
    procedure generateIncrValueCMD(S: string);
    procedure prcSendDataToCard();
    procedure showCardInformation();
    procedure returnFromReadCMD();
    procedure returnFromIncrCMD();
//    function  checkSUMData(orderStr: string): string;
  //  function transferTypeNameToTypeID(StrIDtype: string): string;
   // function transferTypeIDToTypeName(strTypeName: string): string;
    procedure initComboxCardtype;



    //��ʼ������BandID�ӿ�
    //function bandIDActiveInterface(): string;

    //ƴ�Ӽ���ӿ�URL
//    function generateActiveURL(): string;
   // ƴ��ǩ���ӿ�URL
//    function getActiveSignature(bandId: string; appId: string; shopId: string; timeStamp: string): string;
 //   ��΢��
//    function generateBindWeiWinURL(): string;
//    function getBindWeiXinSignature(appId: string; bandId: string; shopId: string; timeStamp: string): string;


  end;

var
  frmCoinInitial: TfrmCoinInitial;
  curOrderNo: integer = 0; //???
  curOperNo: integer = 0;
  Operate_No: integer = 0; //ʲô����?������ڳ�ֵ��
  orderLst, recDataLst: Tstrings; //����ȫ�ֱ����������ݣ���������
  ID_UserCard_Text: string;
  IncValue_Enable: boolean; //�Ƿ�������ֵ�ı�־,��Ա����֤ͨ������ΪTrue
  buffer: array[0..2048] of byte;
  ID_System: string;
  Password3F_System: string;

implementation
uses ICDataModule, ICCommunalVarUnit, ICmain, ICEventTypeUnit, ICFunctionUnit, dateProcess, IdHashMessageDigest, uLkJSON, QRCode;
{$R *.dfm}


function TfrmCoinInitial.initCoinRecord(): string;
var
  strSQL: string;
begin
  with ADOQueryInitial do begin
    Connection := DataModule_3F.ADOConnection_Main;
    Active := false;
    SQL.Clear;
    strSQL := 'select * from T_COIN_INITIAL order by operate_time desc limit 10';
    ICFunction.loginfo('strSQL: ' + strSQL);
    SQL.Add(strSQL);
    Active := True;
  end;
  result := '1';
end;


procedure TfrmCoinInitial.saveInitialRecord(); //�����ʼ����¼
var
  strID3F, strBandid, strShopID, strTypeID, strOperateTime, strOperatorNO, strAppID, strIDTypeName, strCoin, strsql: string;
begin

  strBandid := trim(edtBandID.Text);
  strID3F := Receive_CMD_ID_Infor.ID_3F;
  strAppID := trim(edtAPPID.Text);
  strIDTypeName := cbCoinType.Text;
  strShopID := ICFunction.getInitShopIDByTypeName(strIDTypeName);

//  strTypeID := ICFunction.transferTypeNameToTypeID(strIDTypeName);
//  ICFunction.loginfo(' strTypeID' + strTypeID +' strIDTypeName' + strIDTypeName);
//
// if (strTypeID = 'A5') then //�û���
//  begin
//    strCoin := Trim(edtCoin.Text);
//    strCoin := '0';
//  end
//  else if (strTypeID = 'DD') then //������
//  begin
//   strCoin := SGBTCONFIGURE.coinlimit;
//
//  end
//  else if (strTypeID = '72') then //�����ÿ�
//  begin
//  strCoin := trim(edtCoinCost.Text);
//  end
//  else if (strTypeID = '4A') then // �ϰ�/�ɼ���
//  begin
//   strCoin := '0';
//  end;


    //ָ�����ڸ�ʽ ��Ҫ
  ShortDateFormat := 'yyyy-MM-dd'; //ָ����ʽ����
  DateSeparator := '-';
    //ָ�����ڸ�ʽ ����ᱨis not an valid date and time;
  strOperatorNO := '001';
  strOperateTime := FormatDateTime('yyyy-MM-dd HH:mm:ss', now);

  //����ֻ��׷������,��������ʾ
  with ADOQueryInitial do begin
    Connection := DataModule_3F.ADOConnection_Main;
    Active := false;
    SQL.Clear;
    strSQL := 'select * from T_COIN_INITIAL order by operate_time desc limit 10'; //ΪʲôҪ��ȫ����
    ICFunction.loginfo('Initial database append��strSQL: ' + strSQL);
    SQL.Add(strSQL);
    Active := True;
    Append;
    FieldByName('COIN_ID').AsString := strBandid;
    FieldByName('APPID').AsString := strAppID;
    FieldByName('SHOPID').AsString := strShopID;
    FieldByName('TYPE_ID').AsString := getTypeIDFromTypeName(cbCoinType.Text);
    FieldByName('TYPE_NAME').AsString := cbCoinType.Text;
    FieldByName('INITIAL_COIN').AsString := getInitValueByTypeName(cbCoinType.Text);
    FieldByName('OPERATE_TIME').AsString := strOperatetime;
    FieldByName('OPERATOR_NO').AsString := strOperatorNo;
    post;
  end;

end;


//����TypeName���س�ʼ����ID_Value
function TfrmCoinInitial.getInitValueByTypeName(strTypeName: string): string;
begin
  if (strTypeName = copy(INit_Wright.User, 1, 6)) then //�û���
    result :=  '0'//����A5
  else if (strTypeName = copy(INit_Wright.OPERN, 1, 6)) then //�ϰ忪����
    result :=SGBTCONFIGURE.coinlimit //����DD
 else if (strTypeName = copy(INit_Wright.SETTING, 1, 6)) then //���ÿ�
    result := trim(edtCoinCost.Text)
  else if (strTypeName = copy(INit_Wright.MANEGER, 1, 6)) then //�ɼ���
    result := '0'; //����4A


end;


function  TfrmCoinInitial.getTypeIDFromTypeName(strTypeName: string): string;
begin
  if (strTypeName = copy(INit_Wright.User, 1, 6)) then //�û���
    result := copy(INit_Wright.User, 8, 2) //����A5
  else if (strTypeName = copy(INit_Wright.OPERN, 1, 6)) then //�ϰ忪����
    result := copy(INit_Wright.OPERN, 8, 2) //����DD
  else if (strTypeName = copy(INit_Wright.SETTING, 1, 6)) then //���ÿ�
    result := copy(INit_Wright.SETTING, 8, 2) //����72
  else if (strTypeName = copy(INit_Wright.MANEGER, 1, 6)) then
    result := copy(INit_Wright.MANEGER, 8, 2);//4A

end;


function TfrmCoinInitial.getTypeNameFromTypeID(StrIDtype: string): string;
begin
  if (StrIDtype = copy(INit_Wright.User, 8, 2)) then //�û���
    result := copy(INit_Wright.User, 1, 6) //����A5
  else if (StrIDtype = copy(INit_Wright.OPERN, 8, 2)) then //�ϰ忪����
    result := copy(INit_Wright.OPERN, 1, 6) //����DD
  else if (StrIDtype = copy(INit_Wright.SETTING, 8, 2)) then //���ÿ�
    result := copy(INit_Wright.SETTING, 1, 6) //����72
  else if (StrIDtype = copy(INit_Wright.MANEGER, 8, 2)) then //�ɼ���
    result := copy(INit_Wright.MANEGER, 1, 6); //����4A

 end;


procedure TfrmCoinInitial.checkCMDInfo();
var
  tmpStr: string;
begin
   //���Ƚ�ȡ���յ���Ϣ

  tmpStr := recDataLst.Strings[0];


  ICCommunalVarUnit.Receive_CMD_ID_Infor.ID_CheckNum := copy(tmpStr, 39, 4); //У���
  ICCommunalVarUnit.CMD_CheckSum_OK := true;
  ICCommunalVarUnit.Receive_CMD_ID_Infor.CMD := copy(recDataLst.Strings[0], 1, 2); //֡ͷ43

  ICFunction.loginfo('Initial: return from card : ' + tmpStr);
  if ICCommunalVarUnit.Receive_CMD_ID_Infor.CMD = CMD_COUMUNICATION.CMD_READ then //�յ���ͷд����ӱҳ�ֵ�ɹ��ķ��� 53
  begin
    returnFromReadCMD();
  end
  else if Receive_CMD_ID_Infor.CMD = ICCommunalVarUnit.CMD_COUMUNICATION.CMD_INCValue_RE then //��ָ��
  begin
   // returnFromIncrCMD(); //��ֵ
    lblMessage.Caption := 'Ȧ��ɹ�';
  end;


end;


//��ͷ���س�ֵ�ɹ�ָ��

procedure TfrmCoinInitial.returnFromIncrCMD();
var
  strResponseStr, strURL, strResultCode: string;
  jsonApplyResult, jsonAckResult: TlkJSONbase;
begin
  begin
    saveInitialRecord(); //�����ֵ��¼
    initCoinRecord();

  end;
end;


//��ͷ������Ϣ��ȡָ��

procedure TfrmCoinInitial.returnFromReadCMD();
begin
  Receive_CMD_ID_Infor.ID_INIT := copy(recDataLst.Strings[0], 3, 8); //��ID
  Receive_CMD_ID_Infor.ID_3F := copy(recDataLst.Strings[0], 11, 6); //����ID--��ʱû�ã�����Ҫռλ6
  Receive_CMD_ID_Infor.Password_3F := copy(recDataLst.Strings[0], 17, 6); //appid
  Receive_CMD_ID_Infor.Password_USER := copy(recDataLst.Strings[0], 23, 6); //shopid
  Receive_CMD_ID_Infor.ID_value := copy(recDataLst.Strings[0], 29, 8); //��������
  Receive_CMD_ID_Infor.ID_type := copy(recDataLst.Strings[0], 37, 2); //����������

  showCardInformation();




end;


//�����������б�ʵʼ��

procedure TfrmCoinInitial.initComboxCardtype;
begin
  cbCoinType.Items.clear();
  cbCoinType.Items.Add(copy(INit_Wright.User, 1, 6)); //�û���A5
  cbCoinType.Items.Add(copy(INit_Wright.SETTING, 1, 6)); //���ÿ�72

  //�������Ȩ��
  if rootEnable = true then
  begin 
    cbCoinType.Items.Add(copy(INit_Wright.MANEGER, 1, 6)); //������4A
    cbCoinType.Items.Add(copy(INit_Wright.OPERN, 1, 6)); //�ϰ忪����DD

  end; //�������Ȩ��

end;



//�û�����Ϣչʾ

procedure TfrmCoinInitial.showCardInformation();
begin

  edtBandID.Text := Receive_CMD_ID_Infor.ID_INIT; //�û���ID
  edtTypeID.Text := Receive_CMD_ID_Infor.ID_type;
  edtCoin.Text := ICFunction.transferHEXByteToDECValue(Receive_CMD_ID_Infor.ID_value);
//  lblMessage.Caption := '�˿�Ϊ ' + getTypeNameFromTypeID(edtTypeID.Text);

end; //end


//��ʼȦ��

procedure TfrmCoinInitial.initIncrOperation(strRechargeCoin: string);
var
  strValue: string;
begin
  strValue := caluSendCMD(CMD_COUMUNICATION.CMD_INCValue, strRechargeCoin); //�����ֵָ��
  generateIncrValueCMD(strValue); //�ѳ�ֵָ��д��ID��
  ICFunction.loginfo('Initial: Data send to card : ' + strValue);
end;
//��ֵ����

//���ɳ�ֵ�Ĳ���ָ��

procedure TfrmCoinInitial.generateIncrValueCMD(S: string);
begin
  orderLst.Clear();
  recDataLst.Clear();
  curOrderNo := 0;
  curOperNo := 2;
  orderLst.Add(S); //����ֵָ��д�뻺��
  prcSendDataToCard(); //д�뿨ͷ��
end;

//�����ֵָ��

function TfrmCoinInitial.caluSendCMD(strCMD: string; strIncrValue: string): string;
var
  TmpStr_CheckSum: string; //У���
  TmpStr_SendCMD: string; //ָ������
  reTmpStr, strTypeID: string;
begin

  INit_3F.CMD := StrCMD; //֡����
  INit_3F.ID_INIT := edtBandID.Text; //��ID
  INit_3F.ID_3F := FormatDateTime('yyMMdd', now);
  INit_3F.Password_3F := SGBTCONFIGURE.appid;
  INit_3F.ID_type := getTypeIDFromTypeName(cbCoinType.Text); //ȡ�ÿ����͵�ֵ  Ȧ�������ȷ��ID
  strTypeID := getTypeIDFromTypeName(cbCoinType.Text);
  if (strTypeID = 'A5') then //�û���
  begin
    INit_3F.Password_USER := SGBTCONFIGURE.shopid;
    INit_3F.ID_value := '00000000';
  end
  else if (strTypeID = 'DD') then //�ϰ忪����
  begin
    INit_3F.Password_USER := SGBTCONFIGURE.shopid;
    //���õ��޶����������ļ�
    INit_3F.ID_value := ICFunction.transferDECValueToHEXByte(SGBTCONFIGURE.coinlimit);  

  end
  else if (strTypeID = '72') then //�����ÿ�
  begin
    INit_3F.ID_3F := FormatDateTime('yyyyMM', now);
    INit_3F.Password_USER := FormatDateTime('ddhhmm', now);
//   ��������
    INit_3F.ID_value := ICFunction.transferDECValueToHEXByte(trim(edtCoinCost.Text));
  end
  else if (strTypeID = '4A') then // ������
  begin
    INit_3F.Password_USER := SGBTCONFIGURE.shopid;
    INit_3F.ID_value := '00000000';
  end;

  //���ܷ�������
  TmpStr_SendCMD := INit_3F.CMD + INit_3F.ID_INIT + INit_3F.ID_3F + INit_3F.Password_3F + INit_3F.Password_USER + INit_3F.ID_value + INit_3F.ID_type;
  TmpStr_CheckSum := ICFunction.checkSUMData(TmpStr_SendCMD);
  INit_3F.ID_CheckNum := ICFunction.transferCheckSumByte(TmpStr_CheckSum);
  reTmpStr := TmpStr_SendCMD + INit_3F.ID_CheckNum;
  result := reTmpStr;
end;







procedure TfrmCoinInitial.prcSendDataToCard();
var
  orderStr: string;
begin
  if orderLst.Count > curOrderNo then
  begin
    orderStr := orderLst.Strings[curOrderNo];
    orderStr := ICFunction.funcTransferExchData(orderStr);
    commInitial.WriteCommData(pchar(orderStr), length(orderStr)); //����д����ͷ
    inc(curOrderNo); //�ۼ�
  end;
end;

procedure TfrmCoinInitial.commInitialReceiveData(Sender: TObject; Buffer: Pointer;
  BufferLength: Word);
var
  i: integer;
  recStr: string;
  tmpStr: string;
  tmpStrend: string;
begin
   //����----------------
  recStr := '';
  SetLength(tmpStr, BufferLength);
  move(buffer^, pchar(tmpStr)^, BufferLength);
  for i := 1 to BufferLength do
  begin
    recStr := recStr + intTohex(ord(tmpStr[i]), 2); //���������ת��Ϊ16������
    if i = BufferLength then
    begin
      tmpStrend := 'END';
    end;
  end;
  recDataLst.Clear;
  recDataLst.Add(recStr);
  begin
    checkCMDInfo(); //���ȸ��ݽ��յ������ݽ����жϣ�ȷ�ϴ˿��Ƿ�����Ϊ��ȷ�Ŀ�
  end;
end;



procedure TfrmCoinInitial.FormShow(Sender: TObject);
begin

   //��ʼ��������������

  edtAPPID.Text := '';
  edtShopID.Text := '';
  edtBandID.Text := '';
  edtTypeID.Text := '';
  edtCoin.Text := '';

  label5.Visible := false;
  edtTypeID.Visible := false;

  initComboxCardtype();
  initCoinRecord();

  //��ʼ������
  orderLst := TStringList.Create;
  recDataLst := tStringList.Create;
  edtAPPID.Text := SGBTCONFIGURE.appid;
  edtShopID.Text := SGBTCONFIGURE.shopid;

  //�򿪴���
//  commInitial.StartComm();
  try
    commInitial.StartComm();
  except on E: Exception do //���������쳣
    begin
      showmessage(SG3FERRORINFO.commerror+ e.message);
      exit;
    end;
  end;



end;

procedure TfrmCoinInitial.formClose(Sender: TObject; var Action: TCloseAction);
begin
  //
  orderLst.Free;
  recDataLst.Free;
  commInitial.StopComm();

end;

procedure TfrmCoinInitial.btnInitialClick(Sender: TObject);
var
  intWriteValue: Integer;
  jsonApplyResult, jsonAckResult: TlkJSONbase;
  strURL, strResponseStr, strTypeID: string;
  ResponseStream: TStringStream; //������Ϣ
  activeIdHTTP: TIdHTTP;
begin


  if  checkUniqueCoinID(trim(edtBandID.Text)) = true then
//          updateCoinInitialRecord(trim(edtBandID.Text))
  begin
          lblMessage.Caption := '���ӱ��Ѿ���ʼ��,���³�ʼ������ɾ��';
          Exit;
  end;
   intWriteValue := 0; //��ʼ��ʱ��ֵ�趨Ϊ0
 //Ȧ��
  initIncrOperation(intToStr(intWriteValue));
      //���

  saveInitialRecord();
  //ˢ������չʾ
  initCoinRecord();
  lblMessage.Caption := '��ʼ���ɹ�';

end;



function TfrmCoinInitial.checkUniqueCoinID(ID_INIT: string): Boolean;
var
  ADOQ: TADOQuery;
  strSQL :String;
begin
  ADOQ := TADOQuery.Create(Self);
  ADOQ.Connection := DataModule_3F.ADOConnection_Main;

  with ADOQ do begin
    Close;
    SQL.Clear;
    strSQL := 'select 1 from T_COIN_INITIAL where COIN_ID=''' + ID_INIT + '''';
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


function TfrmCoinInitial.getTypeNameByTypeID(coinid:string):String;
var strSQL :string;
var typename :String;
ADOQTemp: TADOQuery;
begin
  typename :='0';
  strSQL := 'select TYPE_NAME  from T_COIN_INITIAL where COIN_ID =''' + coinid  + '''';
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
      typename := ADOQTemp.Fields[0].AsString;
      Close;
    end;
    FreeAndNil(ADOQTemp);
  end;
  result := typename;
end;



procedure TfrmCoinInitial.updateCoinInitialRecord(coinid:string);
var
  ADOQ: TADOQuery;
  strSQL, MaxID,operationcoin,leftcoin: string;  
begin
  ICFunction.loginfo('Begin update Coin Initial Record ');

  strSQL := ' select INITIAL_COIN, operate_time,OPERATOR_NO from  '
    + ' T_COIN_INITIAL where  COIN_ID = ''' + coinid + '''';
  ICFunction.loginfo('strSQL: ' + strSQL );

  //ָ�����ڸ�ʽ ��Ҫ
  ShortDateFormat := 'yyyy-MM-dd'; //ָ����ʽ����
  DateSeparator := '-';
  //ָ�����ڸ�ʽ ����ᱨis not an valid date and time;

  ADOQ := TADOQuery.Create(nil);
  with ADOQ do begin
    Connection := DataModule_3F.ADOConnection_Main;
    Active := false;
    SQL.Clear;
    SQL.Add(strSQL);
    Active := true;
    if (RecordCount > 0) then begin
      Edit;
      FieldByName('INITIAL_COIN').AsInteger := strToInt('0');
      FieldByName('OPERATE_TIME').AsString := FormatDateTime('yyyy-MM-dd HH:mm:ss',Now);
      FieldByName('OPERATOR_NO').AsString  := SGBTCONFIGURE.shopid;      
      Post;
    end;
    Active := False;
  end;
  FreeAndNil(ADOQ);

  ICFunction.loginfo('End update Coin  Initial Record ');
 end;


  {


function TfrmCoinInitial.generateBindWeiWinURL(): string;
var
  strURL, appId, bandId, shopId, timestamp, strSignature, strActiveURL, strhkscURL: string;
begin
  appId := SGBTCONFIGURE.appid;
  bandId := trim(edtBandID.text);
  shopId := SGBTCONFIGURE.shopid;
  timestamp := getTimestamp();
  strSignature := getBindWeiXinSignature(appId, bandId, shopId, timestamp);
  strActiveURL := SGBTCONFIGURE.bindurl;
  strhkscURL := SGBTCONFIGURE.hkscurl;

  strURL := strhkscURL + strActiveURL
    + '?appId=' + appId
    + '&bandId=' + bandId
    + '&shopId=' + shopId
    + '&timestamp=' + timestamp
    + '&sign=' + strSignature;
  ICFunction.loginfo('Weisin bind URL:' + strURL);
  result := strURL;
end;

//��΢��ǩ���㷨

function TfrmCoinInitial.getBindWeiXinSignature(appId: string; bandId: string; shopId: string; timeStamp: string): string;
var
  strTempC, strTempD: string;
  myMD5: TIdHashMessageDigest5;
begin
  myMD5 := TIdHashMessageDigest5.Create;
  strTempC := 'appId' + appId
    + 'bandId' + bandId
    + 'shopId' + shopId
    + 'timestamp' + timeStamp; //���ַ�˳������

  strTempD := strTempC + SGBTCONFIGURE.secret_key; //����secret_key
  result := LowerCase(myMD5.AsHex(myMD5.HashValue(strTempD))); //�����ַ�����MD5,������Сд
  myMD5.Free;

end;




 //ƴ�Ӽ���ӿ�URL

function TfrmCoinInitial.generateActiveURL(): string;
var
  strURL, strAppID, strBandID, strShopID, strTimeStamp, strSignature, strActiveURL, strhkscURL: string;
begin
  strAppID := SGBTCONFIGURE.appid;
  strBandID := edtBandID.Text;
  strShopID := SGBTCONFIGURE.shopid;
  strTimeStamp := getTimestamp();
  strSignature := getActiveSignature(strBandID, strAppID, strShopID, strTimeStamp);
  strActiveURL := SGBTCONFIGURE.activeurl;
  strhkscURL := SGBTCONFIGURE.hkscURL;

  strURL := strhkscURL + strActiveURL + '?bandId=' + strBandID
    + '&appId=' + strAppID + '&shopId=' + strShopID + '&timestamp=' + strTimeStamp
    + '&sign=' + strSignature;

  result := strURL;
end;



//��������ǩ���㷨

function TfrmCoinInitial.getActiveSignature(bandId: string; appId: string; shopId: string; timeStamp: string): string;
var
  strTempC, strTempD: string;
  myMD5: TIdHashMessageDigest5;
begin
  myMD5 := TIdHashMessageDigest5.Create;
  strTempC := 'appId' + appId + 'bandId' + bandId + 'shopId' + shopId + 'timestamp' + timeStamp; //���ַ�˳������
  strTempD := strTempC + SGBTCONFIGURE.secret_key; //����secret_key
  result := LowerCase(myMD5.AsHex(myMD5.HashValue(strTempD))); //�����ַ�����MD5,������Сд
  myMD5.Free;

end;

}

procedure TfrmCoinInitial.btnDeleteClick(Sender: TObject);
var strgameno: string;
var strsql: string;
begin
  strGameno := ADOQueryInitial.FieldByName('COINID').AsString;
  if (MessageDlg('ȷʵҪɾ��' + strGameno + ' ���ӱ���?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    strsql := 'delete from T_COIN_INITIAL where COIN_ID = ''' + strGameno + '''';
    DataModule_3F.executesql(strsql);
    ICFunction.loginfo('strSQL :' + strSQL);    

    initCoinRecord();
  end;


end;


end.
