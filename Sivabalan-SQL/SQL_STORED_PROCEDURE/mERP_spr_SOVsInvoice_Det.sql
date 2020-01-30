Create Procedure mERP_spr_SOVsInvoice_Det
(
@SmanCatName nVarchar(4000),
@Salesman nVarchar(255),
@Beat nVarchar(255),
@Customer nVarchar(4000),
@Prod_Hierarchy  nVarchar(100),
@Category nVarchar(255),
@UOM  nVarchar(20),
@BtWiseBreakUp nVarchar(5),
@FromDate Datetime,
@ToDate Datetime
)
As
Begin

Declare @SmanID as Int
Declare @SmanName as nVarchar(255)
Declare @CatName as nVarchar(255)
Declare @BeatName as nVarchar(255)
Declare @Pos Int
Declare @Delimeter as char
Set @Delimeter = Char(15)


set @Pos = charindex (char(15), @SmanCatName, 1)  
Set @SmanName = substring(@SmanCatName, 1, @Pos-1) 
Set @SmanCatName = substring(@SmanCatName, @Pos + 1, len(@SmanCatName)) 
If @BtWiseBreakUp = 'Yes' Or @BtWiseBreakUp = '%'
Begin
	set @Pos = charindex (char(15), @SmanCatName, 1)  
	Set @CatName = substring(@SmanCatName,1,@Pos-1) 
	Set @BeatName = substring(@SmanCatName,@Pos+1,len(@SmanCatName)) 
End
Else
	Set @CatName = @SmanCatName


Select @SmanID = SalesmanID From Salesman Where Salesman_Name = @SmanName


Create Table #tmpBeat(BeatID Int)
Create Table #tmpCustomer(CustomerID NVarchar(255))


If @BtWiseBreakUp = 'Yes'
	Insert Into #tmpBeat Select BeatID From Beat Where  Description = @BeatName
Else
Begin
	If @Beat = '%' Or @Beat = ''
		Insert Into #tmpBeat Select BeatID From Beat Where Active = 1
	Else
		Insert Into #tmpBeat Select BeatID From Beat Where Description In(Select * From dbo.sp_Splitin2Rows(@Beat,@Delimeter))
End


If @Customer = '%' Or @Customer = ''
	Insert Into #tmpCustomer Select CustomerID From Customer Where Active = 1
Else
	Insert Into #tmpCustomer Select CustomerID From Customer Where Company_Name In(Select * From dbo.sp_SplitIn2Rows(@Customer,@Delimeter))


--select * from #tmpBeat
Create Table #tempCategory (CategoryID Int, Status Int) 
Exec GetLeafCategories @Prod_Hierarchy, @CatName

Create Table #tempCategory1 (CategoryID Int, Status Int) 
Insert Into #tempCategory1
Select Distinct CategoryID,Status From #tempCategory


Drop Table  #tempCategory



Create Table #tmpSO(SOID Int,SODate Datetime,CustName nVarchar(500),SONo nVarchar(255),ItemName nVarchar(255),SOQty Decimal(18,6),SOUom nVarchar(255),SOValue Decimal(18,6))
Insert Into #tmpSO
Select 
	SOA.SONumber,SODate ,
	Company_Name ,
	DocumentReference ,
	I.ProductName ,
	Sum(Case @UOM When N'UOM1' Then isNull(SOD.Quantity,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
    When N'UOM2' Then isNull(SOD.Quantity,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
	Else isNull(SOD.Quantity,0) End),
	UOM.Description ,
	Sum(isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0) +  (isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0) * Saletax/100)) 
From 
	SOAbstract SOA,SODetail SOD,Customer C ,
	Items I,#tempCategory1,UOM
Where 
	SODate Between @FromDate And @ToDate And
	SOA.SalesmanID = @SmanID And
	SOA.BeatID In (Select BeatID From #tmpBeat) And
	SOA.CustomerID In (Select CustomerID From #tmpCustomer) And
	SOA.CustomerID = C.CustomerID And
	SOA.SONumber = SOD.SONumber And
	SOD.Product_Code = I.Product_Code And
	I.CategoryID In (Select CategoryID From #tempCategory1) And
	I.CategoryID = #tempCategory1.CategoryID And
	(UOM.UOM = Case @UOM When 'Base UOM' Then I.UOM 
	When 'UOM1' Then I.UOM1
	Else I.UOM2 End) And
	isNull(SOA.Status,0) In (2,130)
Group By 
	SOA.SONumber,SODate ,Company_Name ,DocumentReference ,I.ProductName ,UOM.Description


Create Table #tmpInv(SOID Int,InvDate Datetime,InvNo nVarchar(255),ItemName nVarchar(255),InvQty Decimal(18,6),InvUom nVarchar(255))
Insert Into #tmpInv
Select 
	(Case isNull(SONumber,0) When 0 Then (Select Top 1 SONumber From InvoiceAbstract Where Documentid = IA.DocumentID) Else SONumber End) ,
	InvoiceDate,(Cast('I' as nVarchar) + Cast(IA.InvoiceID as nVarchar) ),
	I.ProductName ,
	Sum(Case @UOM When N'UOM1' Then isNull(ID.Quantity,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
	When N'UOM2' Then isNull(ID.Quantity,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
	Else isNull(ID.Quantity,0) End) ,
	(Case Sum(isNull(ID.Quantity,0)) When 0 Then ''  Else UOM.Description End)
From
	InvoiceAbstract IA,InvoiceDetail ID,
	Items I,#tempCategory1,UOM
Where 
	(
		IA.SONumber In(Select SOID From #tmpSO) Or 
		IA.DocumentID In(Select DocumentID From InvoiceAbstract Where SONumber In(Select SOID From #tmpSO))
	)And
	isNull(IA.Status,0) & 128 = 0 And
	IA.InvoiceID = ID.InvoiceID And
	ID.Product_Code = I.Product_Code And
	I.CategoryID In (Select CategoryID From #tempCategory1) And
	I.CategoryID = #tempCategory1.CategoryID And
	(UOM.UOM = Case @UOM When 'Base UOM' Then I.UOM 
	When 'UOM1' Then I.UOM1
	Else I.UOM2 End)
Group By 
	SONumber,DocumentID,IA.InvoiceDate,(Cast('I' as nVarchar) + Cast(IA.InvoiceID as nVarchar) ),
	I.ProductName ,UOM.Description 
	 

--Select * From #tmpSO
--Select * From #tmpInv

Select SO.SOID ,SODate as [Order Date],CustName As [Customer Name],SONo As [Order No],
	   InvDate As [Invoice Date],InvNo As [Invoice No],	
	   SO.ItemName As [Item Name],SOQty As [Order Qty],SOUom As [Order UOM],SOValue As [Ord Item Value],
	   InvQty As [Inv Qty],
	   InvUom As [Inv UOM]  		
From 
	   #tmpSO SO
	   Left Outer Join #tmpInv Inv On SO.SOID = Inv.SOID And SO.ItemName = Inv.ItemName

Drop Table #tmpBeat
Drop Table #tmpCustomer
Drop Table #tempCategory1
Drop Table #tmpSO
Drop Table #tmpInv

End


