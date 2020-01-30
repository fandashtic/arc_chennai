CREATE procedure [dbo].[Spr_StockValueReportDetail]  (@Details NVARCHAR(4000))
AS
Begin
	Create Table #Tmp (ReasonID Int,
	Product_Code Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	Batch_Code Int,
	Batch_Number Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	PTS Decimal(18,6),
	PTR Decimal(18,6),
	MRP Decimal(18,6),
	Damage Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	DamagesReason Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	Free Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	UOM Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
	SalebleQuantity Decimal(18,6),
	SalebleStockValue Decimal(18,6),
	DamageQuantity Decimal(18,6),
	DamageStockValue Decimal(18,6),
	FreeQuantity Decimal(18,6),
	FreeStockValue Decimal(18,6),
	NetStockValueWithTax Decimal(18,6))

	Declare @ItemCode As Nvarchar(255)
	Declare @WithStock As Int
	Declare @UOM as Nvarchar(255)


	Declare @tempID as Table (ID int Identity, ItemValue Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS)
	Insert into @tempID(ItemValue)
	Select * From dbo.sp_SplitIn2Rows(@Details, ',') 

	Set @ItemCode = (Select Top 1 ItemValue From @tempID Where ID = 1)
	Set @WithStock = (Select Top 1 cast(ItemValue as Int) From @tempID Where ID = 2)
	Set @UOM = (Select Top 1 ItemValue From @tempID Where ID = 3)

	Insert Into #Tmp(ReasonID,Product_Code,Batch_Code,Batch_Number,PTS,PTR,MRP,Damage,DamagesReason,Free,SalebleQuantity,SalebleStockValue,NetStockValueWithTax) 
	select Distinct DamagesReason,batch_products.Product_Code,Batch_Code,Batch_Number,batch_products.PTS,batch_products.PTR,batch_products.ECP,Null,Null,
	Null,
	Isnull((Case 
		When @UOM = 'UOM2' Then (cast((Quantity / Isnull(Items.UOM2_Conversion,1)) as Decimal(18,6)))
		When @UOM = 'UOM1' Then (cast((Quantity / Isnull(Items.UOM1_Conversion,1)) as Decimal(18,6)))
		Else  (Quantity) End),0) Quantity,
	cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) NetStockValue ,
	cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) + (cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) * (Isnull(batch_products.TaxSuffered,0) / 100))  NetStockValueWithTax  
	from  batch_products,Items Where batch_products.Product_Code = @ItemCode and Items.Product_Code = batch_products.Product_Code
	And Isnull(Damage,0) = 0 And Isnull(Free,0) = 0 

	Insert Into #Tmp(ReasonID,Product_Code,Batch_Code,Batch_Number,PTS,PTR,MRP,Damage,DamagesReason,Free,DamageQuantity,DamageStockValue,NetStockValueWithTax) 
	select Distinct DamagesReason,batch_products.Product_Code,Batch_Code,Batch_Number,batch_products.PTS,batch_products.PTR,batch_products.ECP,(Case When Damage = 2 Then 'Yes' Else 'No' End),Null,
	Null,
	Isnull((Case 
		When @UOM = 'UOM2' Then (cast((Quantity / Isnull(Items.UOM2_Conversion,1)) as Decimal(18,6)))
		When @UOM = 'UOM1' Then (cast((Quantity / Isnull(Items.UOM1_Conversion,1)) as Decimal(18,6)))
		Else  (Quantity) End),0) Quantity,
	cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) NetStockValue ,
	cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) + (cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) * (Isnull(batch_products.TaxSuffered,0) / 100))  NetStockValueWithTax  
	from  batch_products,Items Where batch_products.Product_Code = @ItemCode and Items.Product_Code = batch_products.Product_Code
	And Isnull(Damage,0) <> 0

	Insert Into #Tmp(ReasonID,Product_Code,Batch_Code,Batch_Number,PTS,PTR,MRP,Damage,DamagesReason,Free,FreeQuantity,FreeStockValue,NetStockValueWithTax) 
	select Distinct DamagesReason,batch_products.Product_Code,Batch_Code,Batch_Number,batch_products.PTS,batch_products.PTR,batch_products.ECP,Null,(Case When Free = 0 Then 'No' Else 'Yes' End),
	Null,
	Isnull((Case 
		When @UOM = 'UOM2' Then (cast((Quantity / Isnull(Items.UOM2_Conversion,1)) as Decimal(18,6)))
		When @UOM = 'UOM1' Then (cast((Quantity / Isnull(Items.UOM1_Conversion,1)) as Decimal(18,6)))
		Else  (Quantity) End),0) Quantity,
	cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) NetStockValue ,
	cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) + (cast((Isnull(batch_products.PTS,0) *Isnull(Quantity,0)) as Decimal(18,6)) * (Isnull(batch_products.TaxSuffered,0) / 100))  NetStockValueWithTax  
	from  batch_products,Items Where batch_products.Product_Code = @ItemCode and Items.Product_Code = batch_products.Product_Code
	And Isnull(Free,0) <> 0

	Update T Set T.DamagesReason = T1.Reason_Description From #Tmp T, ReasonMaster T1 Where T.ReasonID = T1.Reason_Type_ID

	Update T Set T.UOM = (Case When @UOM = 'UOM2' Then U.UOM2 When @UOM = 'UOM1' Then U.UOM1 Else U.UOM End) From #Tmp T,
	(Select Distinct I.Product_Code,U.Description UOM,U1.Description UOM1,U2.Description UOM2 From Items I,UOM U,UOM U1,UOM U2
	Where I.UOM = U.UOM
	And I.UOM1 = U1.UOM
	And I.UOM2 = U2.UOM) U
	Where T.Product_Code = U.Product_Code

	If Isnull(@WithStock,0) = 1
	Begin
		Delete From #Tmp Where (Isnull(SalebleQuantity,0) + Isnull(DamageQuantity,0) + Isnull(FreeQuantity,0)) = 0
	End

	select Distinct Product_Code,Batch_Code,Batch_Number,PTS,PTR,MRP,Damage,DamagesReason,Free,UOM,SalebleQuantity,SalebleStockValue,DamageQuantity,DamageStockValue,FreeQuantity,FreeStockValue,NetStockValueWithTax from #Tmp
	Order By Batch_Code Asc

	Drop Table #Tmp 
End
