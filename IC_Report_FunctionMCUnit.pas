unit IC_Report_FunctionMCUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DBGridEhGrouping, GridsEh, DBGridEh, ComCtrls, StdCtrls,
  Buttons, ExtCtrls;

type
  Tfrm_IC_Report_FunctionMC = class(TForm)
    Panel8: TPanel;
    Panel1: TPanel;
    Panel5: TPanel;
    BitBtn2: TBitBtn;
    BitBtn5: TBitBtn;
    Panel4: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    Panel_SaleDate_GameMC: TPanel;
    Label10: TLabel;
    DateTimePicker3: TDateTimePicker;
    DateTimePicker4: TDateTimePicker;
    DateTimePicker5: TDateTimePicker;
    DateTimePicker6: TDateTimePicker;
    Panel2: TPanel;
    pgcMachinerecord: TPageControl;
    tbsConfig: TTabSheet;
    Tab_Gamenameinput: TTabSheet;
    DBGridEh2: TDBGridEh;
    DBGridEh1: TDBGridEh;
    TabSheet1: TTabSheet;
    DBGridEh3: TDBGridEh;
    procedure BitBtn5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_IC_Report_FunctionMC: Tfrm_IC_Report_FunctionMC;

implementation

{$R *.dfm}

procedure Tfrm_IC_Report_FunctionMC.BitBtn5Click(Sender: TObject);
begin
  Close;
end;

end.
