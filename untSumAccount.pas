unit untSumAccount;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, Grids, DBGrids, SPComm, StdCtrls, ExtCtrls;

type
  TfrmAccountSum = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    commAccountSum: TComm;
    dsAccountSum: TDataSource;
    dgAccountSum: TDBGrid;
    ADOQAccountSum: TADOQuery;
    Label1: TLabel;
    edtAPPID: TEdit;
    edtShopID: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edtAccountSum: TEdit;
    edtBandID: TEdit;
    Label5: TLabel;
    edtGatherID: TEdit;
    btnCollect: TButton;
    btnUpload: TButton;
    lblMessage: TLabel;
    Label6: TLabel;
    edtTypeName: TEdit;
    procedure commAccountSumReceiveData(Sender: TObject; Buffer: Pointer; BufferLength: Word);
    procedure btnCollectClick(Sender: TObject);
    procedure btnUploadClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }

    function initDatabaseRecord(): string;
    procedure saveDatabaseRecord(); overload;
    procedure saveDatabaseRecord(strAccountSum: string); overload;
    procedure checkCMDInfo();
    procedure returnFromReadCMD();
    procedure returnFromIncrCMD();
    procedure showCardInformation();

    procedure initIncrOperation(strRechargeCoin: string);
    procedure sendDataToCard();
    function caluSendCMD(strCMD: string; strIncrValue: string): string;
    procedure generateIncrValueCMD(S: string);

    function generateUploadURL(): string; overload;
    function generateUploadURL(appId: string; coin: string; collectId: string; shopId: string): string; overload;

    function getUploadSignature(appId: string; coin: string; collectId: string; shopId: string; timeStamp: string): string;
  end;

var
  frmAccountSum: TfrmAccountSum;

  orderLst, recDataLst: Tstrings; //����ȫ�ֱ����������ݣ���������
  curOrderNo: integer = 0; //???
  curOperNo: integer = 0;
  Operate_No: integer = 0; //ʲô����?������ڳ�ֵ��

  ID_UserCard_Text: string;
  IncValue_Enable: boolean; //�Ƿ�������ֵ�ı�־,��Ա����֤ͨ������ΪTrue
  buffer: array[0..2048] of byte;

  //ȫ�ֱ�����������SG3Fƽ̨����ID;
  globalCollectID: string; //
  globalUploadState: string;


implementation
uses ICDataModule, ICCommunalVarUnit, ICmain, ICEventTypeUnit, ICFunctionUnit, dateProcess, strprocess, IdHashMessageDigest, IdHTTP, uLkJSON;
{$R *.dfm}




//���˲ɼ��ϴ�����ӿ�URL

function TfrmAccountSum.generateUploadURL(appId: string; coin: string; collectId: string; shopId: string): string;
var
  strURL, timestamp, strSignature, strActiveURL, strhkscURL: string;
begin
  timestamp := getTimestamp();
  strSignature := getUploadSignature(appId, coin, collectId, shopId, timestamp);
  strActiveURL := SGBTCONFIGURE.coindatauploadurl;
  strhkscURL := SGBTCONFIGURE.hkscURL;

  strURL := strhkscURL + strActiveURL
    + '?appId=' + appId
    + '&coin=' + coin
    + '&collectId=' + collectId
    + '&shopId=' + shopId
    + '&timestamp=' + timestamp
    + '&sign=' + strSignature;

  result := strURL;
end;



function TfrmAccountSum.generateUploadURL(): string;
var
  strURL, appId, collectId, coin, shopId, timestamp, strSignature, strActiveURL, strhkscURL: string;
begin
  appId := SGBTCONFIGURE.appid;
  coin := edtAccountSum.Text;
  collectId := globalCollectID;
  shopId := SGBTCONFIGURE.shopid;
  timestamp := getTimestamp();
  strSignature := getUploadSignature(appId, coin, collectId, shopId, timestamp);
  strActiveURL := SGBTCONFIGURE.coindatauploadurl;
  strhkscURL := SGBTCONFIGURE.hkscURL;

  strURL := strhkscURL + strActiveURL
    + '?appId=' + appId
    + '&coin=' + coin
    + '&collectId=' + collectId
    + '&shopId=' + shopId
    + '&timestamp=' + timestamp
    + '&sign=' + strSignature;

  result := strURL;
end;



//�����ϴ�����ǩ���㷨

function TfrmAccountSum.getUploadSignature(appId: string; coin: string; collectId: string; shopId: string; timeStamp: string): string;
var
  strTempC, strTempD: string;
  myMD5: TIdHashMessageDigest5;
begin
  myMD5 := TIdHashMessageDigest5.Create;
  strTempC := 'appId' + appId
    + 'coin' + coin
    + 'collectId' + collectId
    + 'shopId' + shopId
    + 'timestamp' + timeStamp; //���ַ�˳������

  strTempD := strTempC + SGBTCONFIGURE.secret_key; //����secret_key
  result := LowerCase(myMD5.AsHex(myMD5.HashValue(strTempD))); //�����ַ�����MD5,������Сд
  myMD5.Free;

end;


procedure TfrmAccountSum.commAccountSumReceiveData(Sender: TObject;
  Buffer: Pointer; BufferLength: Word);
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

procedure TfrmAccountSum.btnCollectClick(Sender: TObject);
begin

    //�������ж�
  if ((ICFunction.transferTypeNameToTypeID(edtTypeName.text) <> copy(INit_Wright.MANEGER, 8, 2))) then //�ɼ���
  begin
    lblMessage.Caption := edtTypeName.text + '���ܲɼ�����';
    exit;
  end;

  globalUploadState := '0'; //�ɼ����
  globalCollectID := trim(edtGatherID.Text) + formatDatetime('hhmmss', now);

  //�������
  saveDatabaseRecord(edtAccountSum.Text);

  //Ȧ�����
  initIncrOperation(IntToStr(0));

  initDatabaseRecord();

  lblMessage.Caption := '���˼�¼�ɼ����,�����ϴ�';



end;

procedure TfrmAccountSum.btnUploadClick(Sender: TObject);
var
  strURL, strResponseStr, strSQL, reTmpStr: string;
  jsonApplyResult: TlkJSONbase;
  appId, collectId, coin, shopId: string;
  ADOQ: TADOQuery;
  ResponseStream: TStringStream; //������Ϣ
  activeIdHTTP: TIdHTTP;

begin

    //�������ж�
  if ((ICFunction.transferTypeNameToTypeID(edtTypeName.text) <> copy(INit_Wright.MANEGER, 8, 2))) then //�ɼ���
  begin
    lblMessage.Caption := edtTypeName.text + '���ܲɼ�����';
    exit;
  end;

  //���������ҵ�״̬Ϊδ�ϴ��� ,һ��ֻ��ȡһ��
  //����ȡappid/shopid�����⣬�п�����000023��shopid��ȡ��000024�����ǩ������ȷ�����ڲ��Ի����»������������������ᷢ��
  strSQL := 'select appid,coin,collectId,shopid from t_collect_account where state=' + '0' +' and shopid = '+SGBTCONFIGURE.shopid   + ' order by collectId limit 1';
  ICFunction.loginfo('strSQL :' + strSQL);
  ADOQ := TADOQuery.Create(nil);
  with ADOQ do
  begin
    Connection := DataModule_3F.ADOConnection_Main;
    SQL.Clear;
    SQL.Add(strSQL);
    Active := True;
    if (RecordCount > 0) then
    begin
      appId := ADOQ.Fields[0].AsString;
      coin := ADOQ.Fields[1].AsString;
      collectId := ADOQ.Fields[2].AsString;
      shopId := ADOQ.Fields[3].AsString;
    end
    else
    begin
      lblMessage.Caption := 'û����Ҫ�ϴ�����Ŀ';
      exit; //û����Ҫ�ϴ�����Ŀ
    end;
    FreeAndNil(ADOQ);
  end;


  //�����ϴ�����
  if SGBTCONFIGURE.enableInterface = '0' then
  begin
    strURL := generateUploadURL(appId, coin, collectId, shopId);
    ICFunction.loginfo('SumAccount Data Upload request URL: ' + strURL);

    activeIdHTTP := TIdHTTP.Create(nil);
    ResponseStream := TStringStream.Create('');
    try
      activeIdHTTP.HandleRedirects := true;
      activeIdHTTP.Get(strURL, ResponseStream);
    except
      on e: Exception do
      begin
        showmessage(SG3FERRORINFO.networkerror + e.message);
        exit;
      end;
    end;
    //��ȡ��ҳ���ص���Ϣ   ��ҳ�еĴ�������ʱ����Ҫ����UTF8����
    strResponseStr := UTF8Decode(ResponseStream.DataString);

    ICFunction.loginfo('SumAccount: Data Upload respones : ' + strResponseStr);
    jsonApplyResult := TlkJSON.ParseText(UTF8Encode(strResponseStr)) as TlkJSONobject; //UTF8����
    if jsonApplyResult = nil then
    begin
      Showmessage(SG3FERRORINFO.networkerror);
      exit;
    end;
    if vartostr(jsonApplyResult.Field['code'].Value) <> '0' then
    begin
      Showmessage('error code ' + vartostr(jsonApplyResult.Field['code'].Value) + ',' + vartostr(jsonApplyResult.Field['message'].Value) + ',����ϵ������Ա');
      lblMessage.Caption := '���˼�¼�ϴ�ʧ��,������';
      exit;
    end;
  end;
  //����״̬
  strSQL := 'update t_collect_account set state=1 where collectId= ''' + collectId + '''';
  ADOQ := TADOQuery.Create(nil);

  with ADOQ do begin
    Connection := DataModule_3F.ADOConnection_Main;
    SQL.Clear;
    SQL.Add(strSQL);
    ADOQ.ExecSQL;
  end;
  FreeAndNil(ADOQ);

  initDatabaseRecord();


  lblMessage.Caption := '���˼�¼�ϴ����';
  //btnCollect.Enabled := true;


end;







procedure TfrmAccountSum.checkCMDInfo();
var
  tmpStr: string;
begin
   //���Ƚ�ȡ���յ���Ϣ

  tmpStr := recDataLst.Strings[0];
  ICCommunalVarUnit.Receive_CMD_ID_Infor.ID_CheckNum := copy(tmpStr, 39, 4); //У���
  ICCommunalVarUnit.CMD_CheckSum_OK := true;
  ICCommunalVarUnit.Receive_CMD_ID_Infor.CMD := copy(recDataLst.Strings[0], 1, 2); //֡ͷ43
  ICFunction.loginfo('SumAccount: Data Read from Card : ' + tmpStr);
  if ICCommunalVarUnit.Receive_CMD_ID_Infor.CMD = CMD_COUMUNICATION.CMD_READ then //�յ���ͷд����ӱҳ�ֵ�ɹ��ķ��� 53
  begin
    returnFromReadCMD();
  end
  else if Receive_CMD_ID_Infor.CMD = ICCommunalVarUnit.CMD_COUMUNICATION.CMD_INCValue_RE then //��ָ��
  begin
//    returnFromIncrCMD();
    lblMessage.Caption := 'Ȧ����ɣ�';
  end;

end;


//��ͷ���س�ֵ�ɹ�ָ��

procedure TfrmAccountSum.returnFromIncrCMD();
begin

  if (Receive_CMD_ID_Infor.ID_type = copy(INit_Wright.MANEGER, 8, 2)) then
  begin
    saveDatabaseRecord(); //�����ֵ��¼
    initDatabaseRecord();
   //
  end;
end;


//��ͷ������Ϣ��ȡָ��

procedure TfrmAccountSum.returnFromReadCMD();
begin
  Receive_CMD_ID_Infor.ID_INIT := copy(recDataLst.Strings[0], 3, 8); //��ƬID
  Receive_CMD_ID_Infor.ID_3F := copy(recDataLst.Strings[0], 11, 6); //����ID
  Receive_CMD_ID_Infor.Password_3F := copy(recDataLst.Strings[0], 17, 6); //appid
  Receive_CMD_ID_Infor.Password_USER := copy(recDataLst.Strings[0], 23, 6); //shopid
  Receive_CMD_ID_Infor.ID_value := copy(recDataLst.Strings[0], 29, 8); //��������
  Receive_CMD_ID_Infor.ID_type := copy(recDataLst.Strings[0], 37, 2); //������

    //�����ؿ���� -----��ʼ  �ӵ��ӱ��϶�ȡ�ĳ���������������ļ����ȡ�Ĳ�һ��
  if (Receive_CMD_ID_Infor.Password_3F <> SGBTCONFIGURE.appid) then //    INit_Wright.BossPassword := MyIni.ReadString('PLC��������', 'PC����������', '������');
  begin
    lblMessage.Caption := '�Ǳ����ش˿����������';
    exit;
  end
  else
  begin //���س�ʼ����� -----��ʼ
   // if DataModule_3F.queryExistInitialRecord(Receive_CMD_ID_Infor.ID_INIT) = false then //�ɼ�����ʼ���м�¼
  //  begin
     // lblMessage.Caption := '���ȳ�ʼ����';
     // exit;
  //  end
   // else
    //begin
      showCardInformation();
   // end;
  end;

end;




//�û�����Ϣչʾ

procedure TfrmAccountSum.showCardInformation();
begin
  edtBandID.Text := Receive_CMD_ID_Infor.ID_INIT; //�û���ID
  edtGatherID.Text := Receive_CMD_ID_Infor.ID_3F; //collectid
  edtAPPID.Text := Receive_CMD_ID_Infor.Password_3F; //appid
  edtShopID.Text := Receive_CMD_ID_Infor.Password_USER; //shopid
  edtAccountSum.Text := ICFunction.transferHEXByteToDECValue(Receive_CMD_ID_Infor.ID_value); //coin����
  edtTypeName.text := ICFunction.transferTypeIDToTypeName(Receive_CMD_ID_Infor.ID_type);


end; //end prc_user_card_operation






procedure TfrmAccountSum.sendDataToCard();
var
  orderStr: string;
begin
  if orderLst.Count > curOrderNo then
  begin
    orderStr := orderLst.Strings[curOrderNo];
    orderStr := ICFunction.funcTransferExchData(orderStr);
    commAccountSum.WriteCommData(pchar(orderStr), length(orderStr)); //����д����ͷ
    inc(curOrderNo); //�ۼ�
  end;
end;




//�����ʼ������,������ȫ�ֱ���
//д��ֵ��¼

procedure TfrmAccountSum.saveDatabaseRecord();
var
  strAppID, strCollectID, strShopid, strOperateTime, strOperatorNO, strState, strsql: string;
  intCoin: Integer;

begin

  strAppID := trim(edtAppID.Text);
  strShopid := trim(edtShopID.Text);
  intCoin := strToInt(trim(edtAccountSum.Text)); //������ò�Ҫ��edit���ֵ������������λreset��
  strCollectID := globalCollectID;
  strState := '0'; //0��ʾ�ɼ��ɹ� 1��ʾ�ϴ��ɹ�
  strOperatorNO := '001';

    //ָ�����ڸ�ʽ ��Ҫ
  ShortDateFormat := 'yyyy-MM-dd'; //ָ����ʽ����
  DateSeparator := '-';
    //ָ�����ڸ�ʽ ����ᱨis not an valid date and time;
  strOperateTime := FormatDateTime('yyyy-MM-dd HH:mm:ss', now);

  with ADOQAccountSum do begin
    Connection := DataModule_3F.ADOConnection_Main;
    Active := false;
    SQL.Clear;
    strSQL := 'select * from t_collect_account order by operatetime desc'; //ΪʲôҪ��ȫ����
    SQL.Add(strSQL);
    Active := True;
    Append;
    FieldByName('collectid').AsString := strCollectID;
    FieldByName('appid').AsString := strAppID;
    FieldByName('shopid').AsString := strShopid;
    FieldByName('coin').AsInteger := intCoin;
    FieldByName('state').AsString := strState; //
    FieldByName('operatetime').AsString := strOperateTime; //�û���
    FieldByName('operatorno').AsString := strOperatorNO; //��ֵ����
    post;
  end;

end;



procedure TfrmAccountSum.saveDatabaseRecord(strAccountSum: string);
var
  strAppID, strCollectID, strShopid, strOperateTime, strOperatorNO, strState, strCoin, strsql: string;
begin

  strAppID := trim(edtAppID.Text);
  strShopid := trim(edtShopID.Text);
  strCoin := strAccountSum; //������ò�Ҫ��edit���ֵ������������λreset��
  strCollectID := globalCollectID;
  strState := globalUploadState; //0��ʾ�ɹ�
  strOperatorNO := '001';

    //ָ�����ڸ�ʽ ��Ҫ
  ShortDateFormat := 'yyyy-MM-dd'; //ָ����ʽ����
  DateSeparator := '-';
    //ָ�����ڸ�ʽ ����ᱨis not an valid date and time;
  strOperateTime := FormatDateTime('yyyy-MM-dd HH:mm:ss', now);

  with ADOQAccountSum do begin
    Connection := DataModule_3F.ADOConnection_Main;
    Active := false;
    SQL.Clear;
    strSQL := 'select * from t_collect_account order by operatetime desc '; //ΪʲôҪ��ȫ����
    SQL.Add(strSQL);
    Active := True;
    Append;
    FieldByName('collectid').AsString := strCollectID;
    FieldByName('appid').AsString := strAppID;
    FieldByName('shopid').AsString := strShopid;
    FieldByName('coin').AsString := strCoin;
    FieldByName('state').AsString := strState; //
    FieldByName('operatetime').AsString := strOperateTime; //�û���
    FieldByName('operatorno').AsString := strOperatorNO; //��ֵ����
    post;
  end;

end;



//�����ֵָ��

function TfrmAccountSum.caluSendCMD(strCMD: string; strIncrValue: string): string;
var
  TmpStr_CheckSum: string; //У���
  TmpStr_SendCMD: string; //ָ������
  reTmpStr: string;
begin

  INit_3F.CMD := StrCMD; //֡����
  INit_3F.ID_INIT := edtBandID.Text; //��ID

    //Password3F_System ��ID_System��������������������û���Żس�ʱִ�����ɵ�
 // ID_System := ICFunction.SUANFA_ID_3F(INit_3F.ID_INIT); //���ü���ID_3F�㷨
  //Password3F_System := ICFunction.SUANFA_Password_3F(INit_3F.ID_INIT); //���ü���Password_3F�㷨
//  INit_3F.ID_3F := copy(Password3F_System, 5, 2) + copy(ID_System, 1, 2) + copy(Password3F_System, 3, 2);
  INit_3F.ID_3F := FormatDateTime('yyMMdd', now);
  INit_3F.Password_3F := SGBTCONFIGURE.appid; //ֱ�Ӷ�ȡ�����ļ��еĳ������� (PC����������)
  INit_3F.Password_USER := SGBTCONFIGURE.shopid; //�û��������룬�������ĵ�����  (PC����������)
  INit_3F.ID_value := '00000000'; //�������ݳ�ʼ��Ϊ0 һ��Ҫ8λ
  INit_3F.ID_type := ICFunction.transferTypeNameToTypeID(edtTypeName.Text); //ȡ�ÿ����͵�ֵ

  //���ܷ�������
  TmpStr_SendCMD := INit_3F.CMD + INit_3F.ID_INIT + INit_3F.ID_3F + INit_3F.Password_3F + INit_3F.Password_USER + INit_3F.ID_value + INit_3F.ID_type;
   //TmpStr_SendCMD:=ָ��֡ͷ+    ��ID+             3F����ID +      3F��������+           �û���������  +         3F������ʼ��ֵ  +  3F������ʼ������

  ICFunction.loginfo('INit_3F.ID_INIT ' + INit_3F.ID_INIT);
  ICFunction.loginfo('INit_3F.ID_3F ' + INit_3F.ID_3F);
  ICFunction.loginfo('INit_3F.Password_3F ' + INit_3F.Password_3F);
  ICFunction.loginfo('INit_3F.Password_USER ' + INit_3F.Password_USER);
  ICFunction.loginfo('INit_3F.ID_value ' + INit_3F.ID_value);
  ICFunction.loginfo('INit_3F.ID_type ' + INit_3F.ID_type);

    //���������ݽ���У�˼���
  TmpStr_CheckSum := ICFunction.checkSUMData(TmpStr_SendCMD);
  INit_3F.ID_CheckNum := ICFunction.transferCheckSumByte(TmpStr_CheckSum);
  reTmpStr := TmpStr_SendCMD + INit_3F.ID_CheckNum;
  result := reTmpStr;
end;


procedure TfrmAccountSum.initIncrOperation(strRechargeCoin: string);
var
  strValue: string;
begin
  strValue := caluSendCMD(CMD_COUMUNICATION.CMD_INCValue, strRechargeCoin); //�����ֵָ��
  generateIncrValueCMD(strValue); //�ѳ�ֵָ��д��ID��
  ICFunction.loginfo('SumAccount: Data Send to Card : ' + strValue);
end;
//��ֵ����

//���ɳ�ֵ�Ĳ���ָ��

procedure TfrmAccountSum.generateIncrValueCMD(S: string);
begin
  orderLst.Clear();
  recDataLst.Clear();
  curOrderNo := 0;
  curOperNo := 2;
  orderLst.Add(S); //����ֵָ��д�뻺��
  sendDataToCard(); //д�뿨ͷ��
end;


procedure TfrmAccountSum.FormShow(Sender: TObject);
begin
      //��ʼ��
  initDatabaseRecord();

  //��ʼ������
  orderLst := TStringList.Create;
  recDataLst := tStringList.Create;

//  edtAPPID.Text := SGBTCONFIGURE.appid;
 // edtShopID.Text := SGBTCONFIGURE.shopid;

  //�򿪴���
//  commAccountSum.StartComm();
  try
    commAccountSum.StartComm();
  except on E: Exception do //���������쳣
    begin

      exit;
    end;
  end;

end;

function TfrmAccountSum.initDatabaseRecord(): string;
var
  strSQL: string;
begin
  with ADOQAccountSum do begin
    Connection := DataModule_3F.ADOConnection_Main;
    Active := false;
    SQL.Clear;
    strSQL := 'select collectid,appid,shopid,coin,state,operatetime from t_collect_account order by operatetime desc limit 10';
    SQL.Add(strSQL);
    Active := True;
  end;
  result := '1';
end;



procedure TfrmAccountSum.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  orderLst.Free();
  recDataLst.Free();
  commAccountSum.StopComm;

end;

end.
