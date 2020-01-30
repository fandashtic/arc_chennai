CREATE PROCEDURE sp_Get_InvoicesToAssignVAN_ITC
(         
    @FromDate DateTime,
	@ToDate	DateTime,
	@Beat NVarChar(4000) = N'',
	@SalesMan NVarChar(4000) = N'',
	@Zone NVarChar(4000) = N''
)
AS  

Declare @VANPrefix nvarchar(10)
Declare @All Int
SELECT @VANPrefix = Prefix FROM VoucherPrefix WHERE TranID = 'VAN LOADING STATEMENT'


Create Table #TblSalesman(SalesManID Int)
Create Table #TblBeat(BeatID Int)
Create Table #TblZone(ZoneID Int)

If Not (@Beat = N'-' And @Zone = N'-')
Begin
	If @Beat = N'-'
		Set @Beat = N''
	Else If  @Zone = N'-'
	Begin
		Set @All = 1
		Set @Zone = N''	
	End
End


If @SalesMan = N''
	Begin
		Insert InTo #TblSalesman Values(0)
		Insert InTo #TblSalesman Select SalesmanID From SalesMan Where Active = 1
	End
Else
	Insert InTo #TblSalesman Select * From sp_SplitIn2Rows(@SalesMan,N',') 

If @Beat = N''	
	Begin
		Insert InTo #TblBeat Values(0)
		Insert InTo #TblBeat Select BeatID From Beat Where Active = 1
	End
Else
	Insert InTo #TblBeat Select * From sp_SplitIn2Rows(@Beat,N',')


If @Zone = N''	
	Begin
		If @All = 1 
		Insert InTo #TblZone Values(0)

		Insert InTo #TblZone Select ZoneID From tbl_merp_Zone Where Active = 1
	End
Else
	Insert InTo #TblZone Select * From sp_SplitIn2Rows(@Zone,N',')

Select
	"CustomerID" = InvoiceAbstract.CustomerID,Company_Name,InvoiceID,InvoiceDate,         
	NetValue,InvoiceType,InvoiceAbstract.DocumentID,IsNull(InvoiceAbstract.Status, 0),IsNull(VanNumber,N''),
	"Weight" = IsNull((Select Sum(IsNull(IDE.Quantity,0) * IsNull(COnversiOnFactOr,0))
						From InvoiceDetail IDE, Items   
						Where IDE.InvoiceID = InvoiceAbstract.InvoiceID 
								And IDE.Product_Code = Items.Product_Code)
					 ,0),
	"Beat" = Beat.[Description],Customer.SequenceNo,
    "DocumentID" = InvoiceAbstract.DocReference,
    "Zone" = Zone.ZoneName 
From 
	InvoiceAbstract
	inner join Customer on 	InvoiceAbstract.CustomerID = Customer.CustomerID  
	left outer join Beat on IsNull(InvoiceAbstract.BeatID,0) = Beat.BeatID
	left outer join tbl_mERP_Zone as Zone on  IsNull(Customer.ZoneID,0) = Zone.ZoneID
Where 
	(InvoiceType = 1 Or InvoiceType = 3)           
	And	IsNull(InvoiceAbstract.BeatID,0) In (Select BeatID From #TblBeat)
	And	IsNull(InvoiceAbstract.SalesmanID,0) In (Select SalesManID From #TblSalesman)  
	And IsNull(Customer.ZoneID,0) in (Select ZoneID From #TblZone)
	And	InvoiceDate Between @FromDate And @ToDate     
	And	(IsNull(Status,0) & 128) = 0
	And IsNull(DeliveryStatus,0) = 0
 	And (NewReference Not In 
		(Select DISTINCT @VANPrefix + Cast(DocumentID as nvarchar) From VanStatementAbstract 
		Where VANID in (Select VAN From VAN Where IsNull(ReadyStockSalesVAN, 1) = 1)))

Drop Table #TblSalesman
Drop Table #TblBeat
Drop Table #TblZone

