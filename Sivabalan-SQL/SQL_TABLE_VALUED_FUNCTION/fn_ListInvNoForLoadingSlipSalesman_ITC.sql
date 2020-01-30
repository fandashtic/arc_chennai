
Create Function fn_ListInvNoForLoadingSlipSalesman_ITC(
@SalesmanID nvarchar(4000) , 
@BeatID nvarchar(4000) ,
@FromDate DateTime ,
@ToDate DateTime,
@DocType as nVarchar(250))  
Returns @Invoice Table(InvoiceID Int)  
As  
Begin  

Declare @Delimeter as Char(1) 
Set @Delimeter = char(44) 

Declare @TmpSalesMan Table(SalesManID nVarchar(50))      
Declare @TmpBeat Table(BeatID nVarchar(50))      

If @SalesmanID = N'%%'  Or @SalesmanID = N'All Salesman'
	 Insert InTo @TmpSalesMan  Select Distinct SalesManID From SalesMan      
Else
	Insert into @TmpSalesMan Select SalesmanID From Salesman Where Salesman_Name In (select * from dbo.sp_SplitIn2Rows(@SalesmanID, @Delimeter))


If @BeatID = N'%%'  Or @BeatID = N'All Beats'
	Insert InTo @TmpBeat  Select Distinct BeatID From Beat      
Else
	Insert into @TmpBeat Select BeatID From Beat Where Description In( select * from dbo.sp_SplitIn2Rows(@BeatID, @Delimeter)	)

if @DocType = N'All DocType' or @DocType ='%'  
	Set @DocType ='%'     

	
Insert Into @Invoice  
Select InvoiceID From InvoiceAbstract 
Where dbo.StripDateFromTime(InvoiceDate) Between dbo.StripDateFromTime(@FromDate) And dbo.StripDateFromTime(@ToDate) And  
--Where InvoiceDate Between @FromDate And @ToDate And  
SalesmanID In (Select SalesmanID From @TmpSalesMan) And
BeatID In(Select BeatID From @TmpBeat) And
DocSerialType like @DocType And IsNull(Status,0) & 192 =0      


Return  
End
  
