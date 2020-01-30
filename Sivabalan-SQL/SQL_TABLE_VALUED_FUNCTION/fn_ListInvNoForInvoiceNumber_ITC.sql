Create Function fn_ListInvNoForInvoiceNumber_ITC(
@SalesmanID nvarchar(4000) ,
@BeatID nvarchar(4000) ,
@CustomerID nVarchar(Max),
@FromDate DateTime ,
@ToDate DateTime,
@DocType as nVarchar(250))

Returns @TmpInvoice Table(ID int, GSTFullDocID nvarchar(255), GSTDocID int)
As
Begin

Declare @Delimeter as Char(1)
Set @Delimeter = char(44)

Declare @TmpSalesMan Table(SalesManID nVarchar(50))
Declare @TmpBeat Table(BeatID nVarchar(50))
Declare @TmpCust Table(Customerid nVarchar(15))
Declare @TmpSaleType Table(Invoiceid nVarchar(501))

Declare @TmpInvoiceNumber Table(ID int Identity(1,1), GSTFullDocID nvarchar(255), GSTDocID int)

If @SalesmanID = N'%%'  Or @SalesmanID = N'All Salesman'
Insert InTo @TmpSalesMan  Select Distinct SalesManID From SalesMan
Else
Insert into @TmpSalesMan Select SalesmanID From Salesman Where Salesman_Name In (select * from dbo.sp_SplitIn2Rows(@SalesmanID, @Delimeter))

If @CustomerID = N'%%'  Or @CustomerID = N'All Customer'
Insert InTo @TmpCust  Select Distinct Customerid From Customer
Else
Insert into @TmpCust Select Customerid From Customer Where Company_Name In (select * from dbo.sp_SplitIn2Rows(@CustomerID, @Delimeter))

If @BeatID = N'%%'  Or @BeatID = N'All Beats'
Insert InTo @TmpBeat  Select Distinct BeatID From Beat
Else
Insert into @TmpBeat Select BeatID From Beat Where Description In( select * from dbo.sp_SplitIn2Rows(@BeatID, @Delimeter) )

IF @DocType = N'Both Sales & Sales Return' or @DocType ='%'
Begin
Insert Into @TmpInvoiceNumber(GSTFullDocID, GSTDocID)
Select GSTFullDocID,GSTDocID From InvoiceAbstract
Where dbo.StripDateFromTime(InvoiceDate) Between dbo.StripDateFromTime(@FromDate) And dbo.StripDateFromTime(@ToDate)
And SalesmanID In (Select SalesmanID From @TmpSalesMan)
And BeatID In(Select BeatID From @TmpBeat)
And Customerid In(Select Customerid From @TmpCust)
And isnull(Status,0) & 128 = 0
And isnull(GSTFlag,0) = 1
And InvoiceType in(1,3)
Order By GSTDocID

Insert Into @TmpInvoiceNumber(GSTFullDocID, GSTDocID)
Select GSTFullDocID,GSTDocID From InvoiceAbstract
Where dbo.StripDateFromTime(InvoiceDate) Between dbo.StripDateFromTime(@FromDate) And dbo.StripDateFromTime(@ToDate)
And SalesmanID In (Select SalesmanID From @TmpSalesMan)
And BeatID In(Select BeatID From @TmpBeat)
And Customerid In(Select Customerid From @TmpCust)
And isnull(Status,0) & 128 = 0
And isnull(GSTFlag,0) = 1
And InvoiceType in(4)
Order By GSTDocID

Insert Into @TmpInvoiceNumber(GSTFullDocID, GSTDocID)
Select GSTFullDocID,GSTDocID From DandDInvAbstract
Where dbo.StripDateFromTime(DandDInvDate) Between dbo.StripDateFromTime(@FromDate) And dbo.StripDateFromTime(@ToDate)
And CustomerID In(Select Customerid From @TmpCust)
Order By GSTDocID
End
Else IF @DocType ='Sales Return'
Begin
Insert Into @TmpInvoiceNumber(GSTFullDocID, GSTDocID)
Select GSTFullDocID,GSTDocID From InvoiceAbstract
Where dbo.StripDateFromTime(InvoiceDate) Between dbo.StripDateFromTime(@FromDate) And dbo.StripDateFromTime(@ToDate)
And SalesmanID In (Select SalesmanID From @TmpSalesMan)
And BeatID In(Select BeatID From @TmpBeat)
And Customerid In(Select Customerid From @TmpCust)
And InvoiceType In (4)
And isnull(Status,0) & 128 = 0
And isnull(GSTFlag,0) = 1
Order By GSTDocID
End
Else IF @DocType ='D & D Delivery Challan'
Begin
Insert Into @TmpInvoiceNumber(GSTFullDocID, GSTDocID)
Select DocumentID, ClaimID From DandDAbstract
Where dbo.StripDateFromTime(ClaimDate) Between dbo.StripDateFromTime(@FromDate) And dbo.StripDateFromTime(@ToDate) and ClaimStatus in(1,2)
And CustomerID In(Select CustomerID From @TmpCust)
Order By ClaimID
End
Else --IF @DocType = N'Sales with D&D Invoice'
Begin
Insert Into @TmpInvoiceNumber(GSTFullDocID, GSTDocID)
Select GSTFullDocID, GSTDocID From InvoiceAbstract
Where dbo.StripDateFromTime(InvoiceDate) Between dbo.StripDateFromTime(@FromDate) And dbo.StripDateFromTime(@ToDate)
And SalesmanID In (Select SalesmanID From @TmpSalesMan)
And BeatID In(Select BeatID From @TmpBeat)
And Customerid In(Select Customerid From @TmpCust)
And InvoiceType In (1,3)
And isnull(Status,0) & 128 = 0
And isnull(GSTFlag,0) = 1
Order By GSTDocID

Insert Into @TmpInvoiceNumber(GSTFullDocID, GSTDocID)
Select GSTFullDocID, GSTDocID From DandDInvAbstract
Where dbo.StripDateFromTime(DandDInvDate) Between dbo.StripDateFromTime(@FromDate) And dbo.StripDateFromTime(@ToDate)
And CustomerID In(Select Customerid From @TmpCust)
Order By GSTDocID
End

Insert Into @TmpInvoice(ID, GSTFullDocID, GSTDocID)
Select ID, GSTFullDocID, GSTDocID From @TmpInvoiceNumber Order By ID

Return
End
