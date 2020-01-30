CREATE Procedure mERP_spr_TMDOutletSalDmg_ITC(@FromDate DateTime, @ToDate DateTime)
As
Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)

Declare @InvoiceID Integer
Declare @Serial Integer
Declare @FreeSerial nVarchar(255)
Declare @SplCatSerial nVarChar(255)
Declare @ItemList nVarChar(1500)

declare @CUSTID nVarChar(50)
Declare @SUBTOTAL NVarchar(50)  
Declare @GRNTOTAL NVarchar(50)  

Set @SUBTOTAL = dbo.LookupDictionaryItem(N'SubTotal:', Default)   
Set @GRNTOTAL = dbo.LookupDictionaryItem(N'GrandTotal:', Default)   
Set @CUSTID = dbo.LookupDictionaryItem(N'Customer ID', Default) 

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
Select Top 1 @WDCode = RegisteredOwner From Setup    
  
If @CompaniesToUploadCode='ITC001'  
 Set @WDDest= @WDCode  
Else  
Begin  
 Set @WDDest= @WDCode  
 Set @WDCode= @CompaniesToUploadCode  
End  

Create Table #TempConsolidate 
(WDCode NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, WDDest NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
RCSID nVarChar(255),SKUCode nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Sales Decimal(18,6), SRDmg Decimal(18,6),Seqno Integer,BUOM nVarChar(255),
SalVal Decimal(18,6), Status nVarChar(5),PrySeqno nVarChar(255),SchVal Decimal(18,6),NoOfBills Integer,DSCode nVarChar(255),DSName nVarChar(255),DSType nVarChar(255) )  

Create Table #TempSales 
(SNo Integer Identity(1,1),CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SKUCode nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, DSCode Integer, 
Qty Decimal(18,6), SalVal Decimal(18,6), SchValue Decimal(18,6), NoOfBillsCnt Integer)

Create Table #TempSRDSales 
(SNo Integer Identity(1,1),CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SKUCode nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, DSCode Integer, 
Qty Decimal(18,6), Free Decimal(18,6),NoOfBillsCnt Integer)

Create Table #TempFreeSales 
(SNo Integer Identity(1,1),CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SKUCode nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, DSCode Integer, 
Qty Decimal(18,6), SchSKUCodes nVarChar(1500), SplSchSKUCodes nVarChar(1500),NoOfBillsCnt Integer)

Create Table #SaleWithFree 
(SeqNo Integer Identity(1,1),Sno Integer, CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SKUCode nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, DSCode Integer, 
Qty Decimal(18,6), SalVal Decimal(18,6), SchValue Decimal(18,6),
Free Integer, SchSKUCodes nVarChar(1500), SplSchSKUCodes nVarChar(1500),NoOfBillsCnt Integer)

Create Table #PrimarySeqNo 
(SeqNo Integer Identity(1,1),Sno Integer, CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
SKUCode nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, DSCode Integer, 
Qty Decimal(18,6), SRDQty Decimal(18,6), SalVal Decimal(18,6), SchValue Decimal(18,6),
Free Integer, SchSKUCodes nVarChar(1500), SplSchSKUCodes nVarChar(1500),PrimarySeqNo nVarChar(255), NoOfBillsCnt Integer)

Insert Into #TempSales (CustomerID, SKUCode, DSCode, Qty, SalVal, SchValue,NoOfBillsCnt)
Select IA.CustomerID , ID.Product_Code, IA.SalesmanID, Sum(Case When IA.InvoiceType = 4 Then -1 * ID.Quantity Else ID.Quantity End), 
Sum((Case When IA.InvoiceType = 4 Then -1 * ID.Quantity Else ID.Quantity End) * ID.SalePrice),
Sum( (Case When IA.InvoiceType = 4 Then -1 * ID.DiscountValue Else ID.DiscountValue End) + 
(
(((Case When IA.InvoiceType = 4 Then -1 * ID.Quantity Else ID.Quantity End) * ID.SalePrice) - ID.DiscountValue) * IA.DiscountPercentage / 100) +
((((Case When IA.InvoiceType = 4 Then -1 * ID.Quantity Else ID.Quantity End) * ID.SalePrice)- ID.DiscountValue) * IA.AdditionalDiscount / 100)
),
Count(Distinct IA.InvoiceID)
From InvoiceAbstract IA, InvoiceDetail ID
Where IsNull(IA.Status,0) & 128 = 0 
And (
(IA.InvoiceType = 4 and IsNull(IA.Status,0) & 32 = 0) OR IA.InvoiceType in (1,3)
)
And IA.InvoiceType in (1,3,4)
And ID.SalePrice <> 0
And IA.InvoiceDate between @FromDate and @ToDate
And IA.InvoiceID = ID.InvoiceID
Group By IA.CustomerID, ID.Product_Code, IA.SalesmanID

Insert Into #TempSRDSales (CustomerID, SKUCode, DSCode, Qty ,Free,NoOfBillsCnt)
Select IA.CustomerID , ID.Product_Code, IA.SalesmanID, Sum(ID.Quantity) ,
Case When SalePrice = 0 Then 1 Else 0 End, Count(Distinct IA.InvoiceID)
From InvoiceAbstract IA, InvoiceDetail ID
Where IsNull(IA.Status,0) & 128 = 0 And IsNull(IA.Status,0) & 32 <> 0 
and IA.InvoiceType in (4)
And IA.InvoiceDate between @FromDate and @ToDate
And IA.InvoiceID = ID.InvoiceID
Group By IA.CustomerID, ID.Product_Code, IA.SalesmanID , ID.SalePrice

Select ID.InvoiceID , Product_Code , Quantity , SalePrice , 
Serial, FreeSerial , SplCatSerial , "SchSKUCodes" = Cast(' ' as nVarChar(1500)) , "SplSchSKUCodes" = Cast(' ' as nVarChar(1500))
InTo #TempInvDet from InvoiceAbstract IA , InvoiceDetail ID
Where IsNull(IA.Status,0) & 128 = 0 
And (
(IA.InvoiceType = 4 And IsNull(IA.Status,0) & 32 = 0) Or IA.InvoiceType in (1,3)
)
And IA.InvoiceType in (1,3,4)
And IA.InvoiceDate between @FromDate and @ToDate
And ID.SalePrice = 0
And IA.InvoiceID = ID.InvoiceID

Declare PrimaryItems Cursor for Select ID.InvoiceID , Serial, FreeSerial , SplCatSerial 
from InvoiceAbstract IA , InvoiceDetail ID
Where IsNull(IA.Status,0) & 128 = 0 
And (
(IA.InvoiceType = 4 And IsNull(IA.Status,0) & 32 = 0) Or IA.InvoiceType in (1,3)
)
And IA.InvoiceType in (1,3,4)
And IA.InvoiceDate between @FromDate and @ToDate
And ID.SalePrice = 0 
And (IsNull(FreeSerial,'') <> '' Or IsNull(SplCatSerial,'') <> '')
And IA.InvoiceID = ID.InvoiceID

Open PrimaryItems
Fetch From PrimaryItems Into @InvoiceID, @Serial, @FreeSerial, @SplCatSerial

While @@Fetch_status = 0
Begin

Set @ItemList = ''

If @FreeSerial <> ''
Begin
Exec mERP_sp_getItemList_ITC @InvoiceID , @FreeSerial , @ItemList OUTPUT
if IsNull(@ItemList,'') <> ''
Update #TempInvDet Set SchSKUCodes = @ItemList 
Where InvoiceID = @InvoiceID And Serial = @Serial
End

Set @ItemList = ''

If @SplCatSerial <> ''
Begin
Exec mERP_sp_getItemList_ITC @InvoiceID , @SplCatSerial , @ItemList OUTPUT
if IsNull(@ItemList,'') <> ''
Update #TempInvDet Set SplSchSKUCodes = @ItemList 
Where InvoiceID = @InvoiceID And Serial = @Serial
End

Fetch Next From PrimaryItems Into @InvoiceID, @Serial, @FreeSerial, @SplCatSerial
End

Close PrimaryItems
DeAllocate PrimaryItems

Insert Into #TempFreeSales (CustomerID, SKUCode, DSCode, Qty, SchSKUCodes , SplSchSKUCodes,NoOfBillsCnt)
Select IA.CustomerID , ID.Product_Code, IA.SalesmanID, Sum(Case When IA.InvoiceType = 4 Then -1 * ID.Quantity Else ID.Quantity End),
ID.SchSKUCodes , ID.SplSchSKUCodes , Count(Distinct IA.InvoiceID)
From InvoiceAbstract IA, 
(Select InvoiceID , "Product_Code" = Max(Product_Code) ,"Quantity" = Sum(Quantity) ,"SalePrice" = Max(SalePrice) ,
"SchSKUCodes" = Max(SchSKUCodes), 
"SplSchSKUCodes" = Max(SplSchSKUCodes)
From #TempInvDet Where SalePrice = 0 Group By InvoiceID,Serial) ID
Where IsNull(IA.Status,0) & 128 = 0 
And (
(IA.InvoiceType = 4 And IsNull(IA.Status,0) & 32 = 0) Or IA.InvoiceType in (1,3)
)
And IA.InvoiceType in (1,3,4)
And IA.InvoiceDate between @FromDate and @ToDate
And IA.InvoiceID = ID.InvoiceID
Group By IA.CustomerID, ID.Product_Code, IA.SalesmanID, ID.SchSKUCodes , ID.SplSchSKUCodes

Insert Into #SaleWithFree 
(Sno,CustomerID, SKUCode, DSCode, Qty, SalVal, SchValue, Free, SchSKUCodes , SplSchSKUCodes,NoOfBillsCnt)
Select Sno, CustomerID, SKUCode, DSCode, Qty, SalVal, SchValue, "Free" = 0, 
"SchSKUCodes" = '' , "SplSchSKUCodes" = '' , NoOfBillsCnt From #TempSales
Union All
Select Sno, CustomerID, SKUCode, DSCode, Qty, "SalVal" = 0, "SchValue" = 0, 1, 
SchSKUCodes , SplSchSKUCodes, NoOfBillsCnt from #TempFreeSales
Order By CustomerID, SKUCode, DSCode, Free, SchSKUCodes , SplSchSKUCodes

Insert Into #PrimarySeqNo
(Sno,CustomerID, SKUCode, DSCode, Qty, SalVal, SchValue, Free, SchSKUCodes , SplSchSKUCodes,NoOfBillsCnt)
Select Sno, CustomerID, SKUCode, DSCode, Qty, SalVal, SchValue, "Free" = 0, 
"SchSKUCodes" = '' , "SplSchSKUCodes" = '', NoOfBillsCnt From #TempSales
Union All
Select Sno, CustomerID, SKUCode, DSCode, Qty, "SalVal" = 0, "SchValue" = 0, 1, 
SchSKUCodes , SplSchSKUCodes , NoOfBillsCnt from #TempFreeSales
Order By CustomerID, SKUCode, DSCode, Free, SchSKUCodes , SplSchSKUCodes

Declare @SeqNo Integer
Declare @SetSqno Integer
Declare @CustomerID nVarChar(255)
Declare @PreCustomerID nVarChar(255)

Set @SetSqNo = 1

Declare ToSetSqNo Cursor For Select SeqNo,CustomerID from #PrimarySeqNo
Open ToSetSqNo

Fetch from ToSetSqNo into @SeqNo, @CustomerID

Set @PreCustomerID = @CustomerID

While @@Fetch_status = 0
Begin
	If @CustomerID <> @PreCustomerID 
	Begin
		Set @SetSqNo = 1
		Set @PreCustomerID = @CustomerID		
	End
	Update #PrimarySeqNo Set Sno = @SetSqNo Where Current of ToSetSqNo
	Update #SaleWithFree Set Sno = @SetSqNo Where SeqNo = @SeqNo
	Set @SetSqNo = @SetSqNo + 1
	Fetch Next From ToSetSqNo into @SeqNo, @CustomerID
End

Close ToSetSqNo
DeAllocate ToSetSqNo

Set @SeqNo = 0
Set @CustomerID =''

Declare @SKUCode nVarChar(255)
Declare @DSCode Integer
Declare @SchSKUCodes nVarChar(1500)
Declare @SplSchSKUCodes nVarChar(1500)
Declare @PICode nVarchar(30)
Declare @PSeqNo nVarChar(10)

Declare PSeqNo Cursor For 
Select SeqNo, CustomerID, SKUCode, DSCode, SchSKUCodes , SplSchSKUCodes 
From #PrimarySeqNo Where Free = 1 And (SchSKUCodes <> '' OR SplSchSKUCodes <> '')
Open PSeqNo
Fetch From PSeqNo InTo @SeqNo, @CustomerID, @SKUCode, @DSCode, @SchSKUCodes, @SplSchSKUCodes 

While @@Fetch_Status = 0
Begin
Create Table #PItemList (PICode nVarChar(30))

If @SchSKUCodes <> ''
begin
Insert InTo #PItemList Select * From dbo.sp_SplitIn2Rows( @SchSKUCodes, ',')

Declare EachItem Cursor For Select PICode From #PItemList
Open EachItem
Fetch From EachItem InTo @PICode
While @@Fetch_Status = 0
begin

Select @PSeqNo = Max(Sno) From #SaleWithFree Where CustomerID = @CustomerID And 
SKUCode = @PICode and DSCode = @DSCode And Free=0

Update #PrimarySeqNo 
Set PrimarySeqNo = IsNull(PrimarySeqNo,'') + (Case When Len(IsNull(PrimarySeqNo,'')) > 0 Then ',' Else '' End)+  IsNull(@PSeqNo,'') 
Where Current of PSeqNo

Fetch Next From EachItem InTo @PICode
End
Close EachItem
DeAllocate EachItem

End

If @SplSchSKUCodes <> ''
Begin
Insert InTo #PItemList Select * From dbo.sp_SplitIn2Rows( @SplSchSKUCodes , ',')

Declare EachItem Cursor For Select PICode From #PItemList
Open EachItem
Fetch From EachItem InTo @PICode
While @@Fetch_Status = 0
begin

Select @PSeqNo = Max(Sno) From #SaleWithFree Where CustomerID = @CustomerID And 
SKUCode = @PICode and DSCode = @DSCode And Free=0

Update #PrimarySeqNo 
Set PrimarySeqNo = IsNull(PrimarySeqNo,'') + (Case When Len(IsNull(PrimarySeqNo,'')) > 0 Then ',' Else '' End)+ IsNull(@PSeqNo,'')
Where current of PSeqNo

Fetch Next From EachItem InTo @PICode
End
Close EachItem
DeAllocate EachItem

End

Drop Table #PItemList

Fetch Next From PSeqNo InTo @SeqNo, @CustomerID, @SKUCode, @DSCode, @SchSKUCodes, @SplSchSKUCodes 
End

Close PSeqNo
DeAllocate PSeqNo
----------------------------------------------------------------
-- Select * from #TempSales
-- Select * from #TempSRDSales
-- Select * from #TempInvDet
-- Select * from #TempFreeSales
-- Select * from #SaleWithFree
-- Select * from #PrimarySeqNo
-----------------------------------------------------------------
Declare @Qty Decimal(18,6)
Declare @Free Integer

Declare SRDSal CurSor For 
Select CustomerID, SKUCode, DSCode, Qty ,Free
From #TempSRDSales
Open SRDSal
Fetch From SRDSal Into @CustomerID , @SKUCode , @DSCode , @Qty , @Free

while @@Fetch_status = 0
Begin

Set @SetSqNo = 0
Select @SetSqno = Max(Sno) from #PrimarySeqNo Where CustomerID = @CustomerID
Set @SetSqNo = ISNull(@SetSqNo,0)+1

if Exists (Select CustomerID from #PrimarySeqNo Where CustomerID = @CustomerID and SKUCode = @SKUCode
And DSCode = @DSCode And Free= @Free)
	Update #PrimarySeqNo Set SRDQty = IsNull(SRDQty,0) + @Qty Where SeqNo = 
	(Select Min(SeqNo) From #PrimarySeqNo Where CustomerID = @CustomerID and SKUCode = @SKUCode
	And DSCode = @DSCode And Free= @Free)
Else 
	Insert Into #PrimarySeqNo (Sno, CustomerID, SKUCode, DSCode, SRDQty,Free) 
	Values (@SetSqNo, @CustomerID, @SKUCode, @DSCode, @Qty, @Free)

Fetch Next From SRDSal Into @CustomerID , @SKUCode , @DSCode , @Qty , @Free
End

Close SRDSal
DeAllocate SRDSal

Insert into #TempConsolidate 
(WDCode, WDDest, CustomerID, RCSID, SKUCode, Sales, SRDmg, SeqNo, BUOM, SalVal, 
Status, PrySeqNo, SchVal , NoOfBills, DSCode ,DSName, DSTYpe)
Select @WDCode , @WDDest , P.CustomerID , C.RCSOutLetID, SKUCode, Qty, SRDQty, SNo, UOM.Description,
SalVal, Case When Free = 1 Then 'Free' Else 'Main' End,
PrimarySeqNo, SchValue, NoOfBillsCnt, DSCode , SM.SalesMan_Name ,
IsNull((Select DSTypeValue From DSType_Master Where DSTypeId in 
(Select Max(DSTypeId) From DSType_Details Where SalesManID = SM.SalesmanID and DSTypeCtlPos = 1)),'')
From #PrimarySeqNo P, Customer C, Items I, UOM, SalesMan SM
Where P.SKUCode = I.Product_Code
And P.CustomerID = C.CustomerID
And I.UOM = UOM.UOM
And P.DSCode = SM.SalesManID
Order by P.CustomerID, SNo, SM.SalesMan_Name

If (Select Count(*) From Reports Where ReportName = 'TMD- Outlet Wise Sales & Damage' And ParameterID in   
(Select ParameterID From dbo.GetReportParametersForSPR('TMD- Outlet Wise Sales & Damage') Where   
FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))>=1  
Begin  
Insert into #TempConsolidate
(WDCode, WDDest, CustomerID, RCSID, SKUCode, Sales, SRDmg, SeqNo, BUOM, SalVal, 
Status, PrySeqNo, SchVal , NoOfBills, DSCode ,DSName, DSType)
Select 
Field1, Field2, Field3, Field4, Field5, Cast(Field6 as Decimal(18,6)), 
Cast(Field7 as Decimal(18,6)), Cast(Field8 as Integer), Field9,Cast(Field10 as Decimal(18,6)),
Field11, Field12,Cast(Field13 as Decimal(18,6)), Cast(Field14 as Integer), Field15, Field16, Field17
From Reports, ReportAbstractReceived  
Where Reports.ReportID in           
(Select Distinct ReportID From Reports                 
Where ReportName = 'TMD- Outlet Wise Sales & Damage'           
And ParameterID in (Select ParameterID From dbo.GetReportParametersForSPR('TMD- Outlet Wise Sales & Damage') Where          
FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)))  
And ReportAbstractReceived.ReportID = Reports.ReportID              
and ReportAbstractReceived.Field1 <> @SUBTOTAL      
and ReportAbstractReceived.Field1 <> @GRNTOTAL   
and ReportAbstractReceived.Field3 <> @CUSTID
End

Select 1,
"WD Code" = WDCode, "WD Dest Code" = WDDest, "Customer ID" = CustomerID, "RCS ID" = RCSID,
"System SKU Code" = SKUCode, "Sales" = Sales, "Sales Return Damages" = SRDmg,
"SeqNo" = SeqNo, "BaseUOM" = BUOM, "Sales Value" = SalVal, "Status" = Status, 
"Free with (Parent)" = PrySeqNo, "SchValue" = SchVal, "No of Bills" = NoOfBills, 
"DS Code" = DSCode, "DS Name" = DSName, "DS Type" = DSType from #TempConsolidate

Drop Table #TempConsolidate 
