Create Procedure mERP_spr_SOVsInvoice_Abs
(
@Salesman  nVarchar(255),
@Beat nVarchar(255) ,
@Customer nVarchar(4000),
@Prod_Hierarchy  nVarchar(100),
@Category  nVarchar(255),
@UOM  nVarchar(20),
@BtWiseBreakUp nVarchar(5),
@FromDate Datetime,
@ToDate Datetime
)
As
Begin

Declare @CategoryID1 Int
Declare @Continue Int          
Declare @Continue2 Int
Declare @Inc Int          
Declare @TCat Int          
Declare @Delimeter as char
Set @Delimeter = Char(15)



Create Table #tmpSalesman(SalesmanID Int)
Create Table #tmpBeat(BeatID Int)
Create table #tmpCat(Category nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)     
Create Table #temp2 (IDS Int IDENTITY(1, 1), CatID Int)          
Create Table #temp3 (CatID Int, Status Int)          
Create Table #temp4 (LeafID Int, CatID Int, Parent nVarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)   
Create Table #tmpCustomer(CustomerID NVarchar(255))


If @Salesman = '%' Or @Salesman = ''
	Insert Into #tmpSalesman Select SalesmanID From Salesman Where Active = 1
Else
	Insert Into #tmpSalesman Select SalesmanID From Salesman Where Salesman_Name In(Select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter))


If @Beat = '%' Or @Beat = ''
	Insert Into #tmpBeat Select BeatID From Beat Where Active = 1
Else
	Insert Into #tmpBeat Select BeatID From Beat Where Description In(Select * From dbo.sp_Splitin2Rows(@Beat,@Delimeter))

If @Customer = '%' Or @Customer = ''
	Insert Into #tmpCustomer Select CustomerID From Customer Where Active = 1
Else
	Insert Into #tmpCustomer Select CustomerID From Customer Where Company_Name In(Select * From dbo.sp_SplitIn2Rows(@Customer,@Delimeter))

If @Category <> '%' And @Category  <> ''
	Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter) 
Else 
Begin
	 If @Category = N'%' And @Prod_Hierarchy = N'%'  
		Insert into #tmpCat select Category_Name from ItemCategories Where [level] = 1  
	 Else If @Category = N'%' And @Prod_Hierarchy <> N'%'    
		Insert InTo #tmpCat select Category_Name From itemcategories itc, itemhierarchy ith          
		where itc.[level] = ith.hierarchyid and ith.hierarchyname = @Prod_Hierarchy   
End



Insert InTo #temp2 Select CategoryID           
From ItemCategories            
Where ItemCategories.Category_Name In (Select Category from #tmpCat) 


Set @Inc = 1          
Set @Continue = IsNull((Select Count(*) From #temp2), 0)   
Set @Continue2 = 1
While @Inc <= @Continue
Begin          
    Insert InTo #temp3 Select CatID, 0 From #temp2 Where IDS = @Inc          
    Select @TCat = CatID From #temp2 Where IDS = @Inc          
    While @Continue2 > 0              
    Begin              
		  Declare Parent Cursor Keyset For              
		  Select CatID From #temp3  Where Status = 0              
		  Open Parent              
		  Fetch From Parent Into @CategoryID1        
		  While @@Fetch_Status = 0          
		  Begin              
			  Insert into #temp3 Select CategoryID, 0 From ItemCategories               
			  Where ParentID = @CategoryID1              
			  If @@RowCount > 0               
			  Update #temp3 Set Status = 1 Where CatID = @CategoryID1              
			  Else                 
			  Update #temp3 Set Status = 2 Where CatID = @CategoryID1              
			  Fetch Next From Parent Into @CategoryID1              
		  End         
		  Close Parent              
		  DeAllocate Parent              
		  Select @Continue2 = Count(*) From #temp3 Where Status = 0              
    End              
    Delete #temp3 Where Status not in  (0, 2)              
    Insert InTo #temp4 Select CatID, @TCat,         
    (Select Category_Name From ItemCategories where CategoryID = @TCat) From #temp3          
    Delete #temp3          
    Set @Continue2 = 1          
    Set @Inc = @Inc + 1          
End          


Create Table #tmpOutput([Salesman Name] nVarchar(500),Category nVarchar(255),
Beat nVarchar(500),[Order Qty] Decimal(18,6),[Invoice Qty] Decimal(18,6),
[Order Value] Decimal(18,6),[Invoice Value] Decimal(18,6))



Create Table #tmpSO(SONo Int,SmanName nVarchar(255),Category nVarchar(255),BeatName nVarchar(255),OrdQty Decimal(18,6),OrdValue Decimal(18,6))
Create Table #tmpFinalSO(SmanName nVarchar(255),Category nVarchar(255),BeatName nVarchar(255),OrdQty Decimal(18,6),OrdValue Decimal(18,6))
Create Table #tmpInv(SmanName nVarchar(255),Category nVarchar(255),BeatName nVarchar(255),InvQty Decimal(18,6),InvValue Decimal(18,6))

Insert Into #tmpSO
Select 
	SOA.SONumber,SM.Salesman_Name,TCat.Parent,B.Description,
	(Case @UOM When N'UOM1' Then isNull(SOD.Quantity,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
    When N'UOM2' Then isNull(SOD.Quantity,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
	Else isNull(SOD.Quantity,0) End),
	(isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0)  + (isNull(SOD.Quantity,0) * isNull(SOD.Saleprice,0) * Saletax/100))
From 
	Salesman SM,Beat B,SOAbstract SOA,SODetail SOD,
	Items I,#temp4 TCat
Where 
	SODate Between @FromDate And @ToDate And
	SM.SalesmanID In (Select SalesmanID From #tmpSalesman) And
	SOA.BeatID In (Select BeatID From #tmpBeat) And
	SOA.CustomerID In (Select CustomerID From #tmpCustomer) And
	SOA.SalesmanID = SM.SalesmanID And
	SOA.BeatID = B.BeatID And
	SOA.SONumber = SOD.SONumber And
	SOD.Product_Code = I.Product_Code And
	I.CategoryID In (Select LeafID From #temp4) And
	I.CategoryID = TCat.LeafID And
	ISnULL(SOA.Status,0) in (2,130) 


Insert Into #tmpInv
Select 
	SM.Salesman_Name,TCat.Parent,B.Description,
	Sum(Case @UOM When N'UOM1' Then isNull(ID.Quantity,0)/(Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End) 	 
    When N'UOM2' Then isNull(ID.Quantity,0)/(Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End) 	 		
    Else isNull(ID.Quantity,0) End ),
	Sum(isNull(ID.Quantity,0) * isNull(ID.Saleprice,0) + STPayable + CSTPayable)
From 
	InvoiceAbstract IA,InvoiceDetail ID,
	Salesman SM,Beat B,
	Items I,#temp4 TCat
Where
	(
		IA.SONumber In(Select SONo From #tmpSO) Or 
		IA.DocumentID In(Select DocumentID From InvoiceAbstract Where SONumber In(Select SONo From #tmpSO))
	)And
	isNull(IA.Status,0) & 128 = 0 And
	IA.InvoiceID = ID.InvoiceID And
	IA.SalesmanID = SM.SalesmanID And
	IA.BeatID = B.BeatID And
	ID.Product_Code = I.Product_Code And
	I.CategoryID In (Select LeafID From #temp4) And
	I.CategoryID = TCat.LeafID 
Group By SM.Salesman_Name,B.Description,TCat.Parent
	

Insert Into #tmpFinalSO
Select SmanName ,Category ,BeatName ,Sum(OrdQty) ,Sum(OrdValue )
From #tmpSO
Group By SmanName,BeatName,Category


--Select * From #tmpFinalSO
--Select * From #tmpInv


Drop Table #tmpSO




Insert Into #tmpOutput
Select 
	SO.SmanName ,SO.Category,SO.BeatName,OrdQty,
	(Select InvQty From #tmpInv Where SmanName = SO.SmanName And BeatName = SO.BeatName  And Category = SO.Category) ,
	OrdValue,
	(Select InvValue From #tmpInv Where SmanName = SO.SmanName And BeatName = SO.BeatName  And Category = SO.Category) 
From
	#tmpFinalSO SO
	



If @BtWiseBreakUp = N'Yes' Or @BtWiseBreakUp = '%'
	Select 
		Cast([Salesman Name] as nVarchar(255)) + Char(15) + Cast(Category as nVarchar(255)) + Char(15) + Cast(Beat as Nvarchar(255)),
		[Salesman Name] ,Category ,
		Beat ,[Order Qty]  ,[Invoice Qty],
		[Order Value],[Invoice Value]
	From 
		#tmpOutput
Else
	Select 
		Cast([Salesman Name] as nVarchar) + Char(15) + Cast(Category as nVarchar) ,[Salesman Name] ,Category ,
		Sum(isNull([Order Qty],0)) [Order Qty] ,Sum(isNull([Invoice Qty],0)) [Invoice Qty],
		Sum(isNull([Order Value],0)) [Order Value],Sum(isNull([Invoice Value],0)) [Invoice Value]
	From 
		#tmpOutput
	Group By 
		Cast([Salesman Name] as nVarchar) + Char(15) + Cast(Category as nVarchar) ,[Salesman Name],Category


Drop Table #tmpSalesman
Drop Table #tmpBeat
Drop Table #tmpCustomer
Drop Table #tmpCat
Drop Table #temp2
Drop Table #temp3
Drop Table #temp4
Drop Table #tmpFinalSO
Drop Table #tmpInv
Drop Table #tmpOutput

End


