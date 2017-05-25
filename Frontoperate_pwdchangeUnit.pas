unit Frontoperate_pwdchangeUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, IniFiles,
  Dialogs, StdCtrls, DBGrids, DB, ADODB, Buttons, ExtCtrls, SPComm;

type
  Tfrm_Frontoperate_pwdchange = class(TForm)
    Panel2: TPanel;
    BitBtn3: TBitBtn;
    Panel1: TPanel;
    comReader: TComm;
    Image1: TImage;
    BitBtn2: TBitBtn;
    Image2: TImage;
    Edit_ID: TEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    procedure BitBtn3Click(Sender: TObject);
    procedure comReaderReceiveData(Sender: TObject; Buffer: Pointer;
      BufferLength: Word);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure Edit3KeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }
  public
    { Public declarations }
    function exchData(orderStr: string): string;
    procedure sendData();
    procedure checkOper();
    procedure CheckCMD();
    procedure Query_MenberInfor(StrID: string);
    procedure ClearState;
    procedure Update_Pwd;
  end;

var
  frm_Frontoperate_pwdchange: Tfrm_Frontoperate_pwdchange;

  orderLst, recDataLst, recData_fromICLst: Tstrings;
implementation
uses ICDataModule, ICCommunalVarUnit, ICFunctionUnit, ICmain, Frontoperate_EBincvalueUnit, ICEventTypeUnit;
{$R *.dfm}

procedure Tfrm_Frontoperate_pwdchange.BitBtn3Click(Sender: TObject);
begin
  Close;
end;

//ת�ҷ������ݸ�ʽ �����ַ�ת��Ϊ16����

function Tfrm_Frontoperate_pwdchange.exchData(orderStr: string): string;
var
  ii, jj: integer;
  TmpStr: string;
  reTmpStr: string;
begin
  if (length(orderStr) = 0) then
  begin
    MessageBox(handle, '�����������Ϊ��!', '����', MB_ICONERROR + MB_OK);
    result := '';
    exit;
  end;
  if (length(orderStr) mod 2) <> 0 then
  begin
    MessageBox(handle, '�����������!', '����', MB_ICONERROR + MB_OK);
    result := '';
    exit;
  end;
  for ii := 1 to (length(orderStr) div 2) do
  begin
    tmpStr := copy(orderStr, ii * 2 - 1, 2);
    jj := strToint('$' + tmpStr);
    reTmpStr := reTmpStr + chr(jj);
  end;
  result := reTmpStr;
end;

//�������ݹ���

procedure Tfrm_Frontoperate_pwdchange.sendData();
var
  orderStr: string;
begin
  if orderLst.Count > curOrderNo then
  begin
    orderStr := orderLst.Strings[curOrderNo];
        //memComSeRe.Lines.Add('==>> '+orderStr);
    orderStr := exchData(orderStr);
    comReader.WriteCommData(pchar(orderStr), length(orderStr));
    inc(curOrderNo);
  end;
end;

//��鷵�ص�����

procedure Tfrm_Frontoperate_pwdchange.checkOper();
var
  i: integer;
  tmpStr: string;
begin
  case curOperNo of
    2: begin //�����������ֵ����
        for i := 0 to recData_fromICLst.Count - 1 do
          if copy(recData_fromICLst.Strings[i], 9, 2) <> '01' then // д�����ɹ���������
          begin
                       // recData_fromICLst.Clear;
            exit;
          end;
      end;
  end;
end;


//�����趨�ĳ�������

procedure Tfrm_Frontoperate_pwdchange.BitBtn2Click(Sender: TObject);
var
  myIni: TiniFile;
  MenberControl_short_New: string;
  MenberControl_Enable: string;
  strtemp: string;
begin

  if Edit_ID.Text = '' then
  begin
    ShowMessage('��ȷ���Ƿ��Ѿ��ɹ�ˢ��');
    exit;

  end
  else
  begin
    Update_Pwd; //��������
    ClearState;
  end;

end;


//�����ʼ������

procedure Tfrm_Frontoperate_pwdchange.Update_Pwd;
var
  ADOQ: TADOQuery;
  strSQL, strRet: string;
  MaxID: string;
  setvalue: string;
label ExitSub;
begin


  strSQL := 'Update [TMemberInfo] set InfoKey=''' + TrimRight(Edit3.Text) + '''  where IDCardNo=''' + TrimRight(Edit_ID.Text) + '''';
  ADOQ := TADOQuery.Create(nil);
  with ADOQ do begin
    Connection := DataModule_3F.ADOConnection_Main;
    SQL.Clear;
    SQL.Add(strSQL);
    ADOQ.ExecSQL;
  end;
  FreeAndNil(ADOQ);

end;

procedure Tfrm_Frontoperate_pwdchange.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  orderLst.Free();
  recDataLst.Free();
  recData_fromICLst.Free();
  comReader.StopComm();
  ICFunction.ClearIDinfor; //�����ID��ȡ��������Ϣ


end;

procedure Tfrm_Frontoperate_pwdchange.FormShow(Sender: TObject);
begin
  comReader.StartComm();
  orderLst := TStringList.Create;
  recDataLst := tStringList.Create;
  recData_fromICLst := tStringList.Create;
  ClearState;
end;

procedure Tfrm_Frontoperate_pwdchange.comReaderReceiveData(Sender: TObject; Buffer: Pointer;
  BufferLength: Word);
var
  ii: integer;
  recStr: string;
  tmpStr: string;
  tmpStrend: string;
begin
   //����----------------
  tmpStrend := 'STR';
  recStr := '';
  SetLength(tmpStr, BufferLength);
  move(buffer^, pchar(tmpStr)^, BufferLength);
  for ii := 1 to BufferLength do
  begin
    recStr := recStr + intTohex(ord(tmpStr[ii]), 2); //���������ת��Ϊ16������
       // if  (intTohex(ord(tmpStr[ii]),2)='4A') then
    if ii = BufferLength then
    begin
      tmpStrend := 'END';
    end;
  end;
     // Edit1.Text:=recStr;
  recData_fromICLst.Clear;
  recData_fromICLst.Add(recStr);
    //����---------------
     //if  (tmpStrend='END') then
  begin
    CheckCMD(); //���ȸ��ݽ��յ������ݽ����жϣ�ȷ�ϴ˿��Ƿ�����Ϊ��ȷ�Ŀ�
         //AnswerOper();//���ȷ���Ƿ�����Ҫ�ظ�IC��ָ��
  end;
    //����---------------
  if curOrderNo < orderLst.Count then // �ж�ָ���Ƿ��Ѿ���������ϣ����ָ�����С��ָ���������������
    sendData()
  else begin
    checkOper();
  end;

end;
 //���ݽ��յ��������жϴ˿��Ƿ�Ϊ�Ϸ���

procedure Tfrm_Frontoperate_pwdchange.CheckCMD();
var
  i: integer;
  tmpStr: string;
  stationNoStr: string;
  tmpStr_Hex: string;
  tmpStr_Hex_length: string;
  Send_value: string;
  RevComd: integer;
  ID_No: string;
  length_Data: integer;
begin
   //���Ƚ�ȡ���յ���Ϣ
  tmpStr := recData_fromICLst.Strings[0];

  Receive_CMD_ID_Infor.ID_CheckNum := copy(tmpStr, 39, 4); //У���

      // if (CheckSUMData(copy(tmpStr, 1, 38))=copy(tmpStr, 41, 2)+copy(tmpStr, 39, 2)) then//У���
  begin
    CMD_CheckSum_OK := true;
    Receive_CMD_ID_Infor.CMD := copy(recData_fromICLst.Strings[0], 1, 2); //֡ͷ43
  end;
                 //1���жϴ˿��Ƿ�Ϊ�Ѿ���ɳ�ʼ��
  if Receive_CMD_ID_Infor.CMD = CMD_COUMUNICATION.CMD_READ then
  begin

    Receive_CMD_ID_Infor.ID_INIT := copy(recData_fromICLst.Strings[0], 3, 8); //��ƬID
    Receive_CMD_ID_Infor.ID_3F := copy(recData_fromICLst.Strings[0], 11, 6); //����ID
    Receive_CMD_ID_Infor.Password_3F := copy(recData_fromICLst.Strings[0], 17, 6); //����
    Receive_CMD_ID_Infor.Password_USER := copy(recData_fromICLst.Strings[0], 23, 6); //�û�����
    Receive_CMD_ID_Infor.ID_value := copy(recData_fromICLst.Strings[0], 29, 8); //��������
    Receive_CMD_ID_Infor.ID_type := copy(recData_fromICLst.Strings[0], 37, 2); //������

                 //1���ж��Ƿ�������ʼ������ֻ��3F��ʼ�����Ŀ�������Ϊ���ܿ�AA �� �ϰ忨BB�Ĳ��ܲ���
               //  if ICFunction.CHECK_3F_ID(Receive_CMD_ID_Infor.ID_INIT,Receive_CMD_ID_Infor.ID_3F,Receive_CMD_ID_Infor.Password_3F) and ( (Receive_CMD_ID_Infor.ID_type=copy(INit_Wright.Produecer_3F,8,2))or (Receive_CMD_ID_Infor.ID_type=copy(INit_Wright.BOSS,8,2)) ) then
    if ((Receive_CMD_ID_Infor.ID_type = copy(INit_Wright.Produecer_3F, 8, 2)) or (Receive_CMD_ID_Infor.ID_type = copy(INit_Wright.RECV_CASE, 8, 2))) then

    begin
      Edit_ID.Text := Receive_CMD_ID_Infor.ID_INIT;
      Query_MenberInfor(Receive_CMD_ID_Infor.ID_INIT); //��ѯ��ǰ��Ա�����趨����
      Edit1.Enabled := true; //�������������
      Edit1.SetFocus;
    end
    else //�������ܿ�AA��Ҳ�����ϰ忨BB
    begin
                         // ShowMessage('����ʧ�ܣ�����Ȩ�ޣ�');
      Edit_ID.Text := '����ʧ�ܣ�����Ȩ�ޣ�';
      exit;
    end;
  end;

end;

//��ѯ��ǰ��Ա���ľ�����

procedure Tfrm_Frontoperate_pwdchange.Query_MenberInfor(StrID: string);
var
  ADOQTemp: TADOQuery;
  strSQL: string;
  reTmpStr: string;
  strsexOrg: string;
begin
  ADOQTemp := TADOQuery.Create(nil);
  strSQL := 'select * from [TMemberInfo] where IDCardNo=''' + StrID + '''';

  with ADOQTemp do
  begin
    Connection := DataModule_3F.ADOConnection_Main;
    SQL.Clear;
    SQL.Add(strSQL);
    Active := True;

    Edit4.text := TrimRight(FieldByName('InfoKey').AsString); //��ѯ��Ա������

  end;
  FreeAndNil(ADOQTemp);
end;

procedure Tfrm_Frontoperate_pwdchange.ClearState;
begin
  Edit1.Enabled := false;
  Edit2.Enabled := false;
  Edit3.Enabled := false;
  Edit4.Enabled := false;
  Edit_ID.Enabled := false;
  BitBtn2.Enabled := false;
end;

procedure Tfrm_Frontoperate_pwdchange.Edit1KeyPress(Sender: TObject;
  var Key: Char);
var
  strtemp: string;
  strvalue: Double;
begin

  if not (key in ['0'..'9', #8, #13]) then
  begin
    key := #0;
    ShowMessage('�������ֻ���������֣�');
  end
  else if key = #13 then
  begin
    if (Edit4.Text <> '') and (TrimRight(Edit4.Text) = TrimRight(Edit1.Text)) and (length(TrimRight(Edit1.Text)) = 6) then
    begin
      Edit2.Enabled := True;
      Edit2.SetFocus;
      Edit3.Enabled := True;
    end
    else
    begin

      ShowMessage('���������ȷ�����볤���Ƿ�Ϊ6λ �� �������˴������룡');
      exit;
    end;
  end;

end;

procedure Tfrm_Frontoperate_pwdchange.Edit2KeyPress(Sender: TObject;
  var Key: Char);
var
  strtemp: string;
  strvalue: Double;
begin

  if not (key in ['0'..'9', #8, #13]) then
  begin
    key := #0;
    ShowMessage('�������ֻ���������֣�');
  end
  else if key = #13 then
  begin
    if (Edit2.Text <> '') and (length(TrimRight(Edit2.Text)) = 6) then
    begin
      Edit3.SetFocus;
    end
    else
    begin

      ShowMessage('���������ȷ�����볤���Ƿ�Ϊ6λ ��');
      exit;
    end;
  end;

end;

procedure Tfrm_Frontoperate_pwdchange.Edit3KeyPress(Sender: TObject;
  var Key: Char);
var
  strtemp: string;
  strvalue: Double;
begin

  if not (key in ['0'..'9', #8, #13]) then
  begin
    key := #0;
    ShowMessage('�������ֻ���������֣�');
  end
  else if key = #13 then
  begin
    if (Edit3.Text <> '') and (TrimRight(Edit3.Text) = TrimRight(Edit2.Text)) and (length(TrimRight(Edit3.Text)) = 6) and (length(TrimRight(Edit2.Text)) = 6) then
    begin

      BitBtn2.Enabled := True;
      BitBtn2.SetFocus;
    end
    else
    begin

      ShowMessage('�������ȷ��������ǰ������������벻һ�£�');
      exit;
    end;
  end;

end;


end.