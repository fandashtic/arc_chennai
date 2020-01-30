CREATE Procedure spr_BeatwiseSalesReturn_Detail (@BeatID Int, 
					         @SalesReturnType nVarChar(100),
					         @FromDate DateTime,
					         @ToDate DateTime)
As
Declare @Cnt Int
Declare @i Int
Set @i = 1
Select "BeatID" = IsNull(bs.BeatID, 0), "Cus" = cs.CustomerID InTo #temp1 From 
Beat_Salesman bs
Right Outer Join Customer cs ON cs.CustomerID = bs.CustomerID


Create Table #temp2 (ID Int IDENTITY(1, 1), CustomerName nVarChar(300) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Value Decimal(18, 6), Type nVarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, Inv nVarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

Create Table #temp3 (ID Int IDENTITY(1, 1), CustomerName nVarChar(300) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Value Decimal(18, 6), Type nVarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, Inv nVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert InTo #temp2 Select Company_Name, Sum(ids.Amount), 
(Case IsNull(ia.Status, 0) & 32 When 0 Then N'Saleable' Else N'Damages' End),
Case ISNULL(ia.GSTFlag,0) When 0 then (Select Prefix From VoucherPrefix where TranID = N'INVOICE') +   
Cast(ia.DocumentID As nVarChar) else ISNULL(ia.GSTFullDocID,'') END  
--Cast(ia.DocumentID As nVarChar) 
From InvoiceAbstract ia, InvoiceDetail ids, Customer cus, Beat bt 
Where ia.InvoiceID = ids.InvoiceID And ia.CustomerID = cus.CustomerID And 
ia.BeatID = bt.BeatID And bt.BeatID = @BeatID And 
ia.InvoiceDate Between @FromDate And @ToDate And InvoiceType = 4 And
IsNull(ia.Status, 0) & 32  = 
(Case @SalesReturnType When N'Saleable' Then 0 
		       When N'Damages' Then 32 Else IsNull(ia.Status, 0) & 32  End) And
(IsNull(ia.Status, 0) & 192) = 0
Group By Company_Name, ia.Status, ia.DocumentID,ia.GSTFlag,ia.GSTFullDocID

--------------------------
-- select * from #temp2
--------------------------

Insert InTo #temp3 (CustomerName, Value, Type) Select CustomerName, Sum(Value), Type From
#temp2 Group By CustomerName, Type 

Select @Cnt = Count(*) From #temp2

Declare @Cust nVarChar(300)
Declare @Type nVarChar(100)
Declare @Inv nVarChar(100)

While (@i <= @Cnt)
Begin
Select @Cust = CustomerName, @Type = Type, @Inv = Inv From #temp2 Where 
ID = @i

Update #temp3 Set Inv = IsNull(Inv, N'') + (Case When IsNull(Inv, N'') = N'' Then @Inv Else N', ' + @Inv End)
Where CustomerName = @Cust And Type = @Type
Set @i = @i +1
End

Select [ID], "Customer Name" = CustomerName, "Sales Return Value (%c)" = Value, 
"Type" = Type, "Invoice Nos" = Inv From #temp3

Drop Table #temp1
Drop Table #temp2
Drop Table #temp3
