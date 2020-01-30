Create Procedure spr_Vanwise_Stock_Movement_Detail_itc
					(@Van Int, 
					 @UOM nVarChar(50), 
				         @ProHier nVarChar(255),  
					 @Category nVarchar(2550),  
                                         @ToDate DateTime)  
As
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
--select * from items
Declare @Continue int    
Declare @CategoryID int    
Declare @Counter Int
Declare @VanDocID Int
Declare @NEXT_DATE DateTime
Declare @CORRECTED_DATE DateTime
  
Select @VanDocID = documentid from VanstatementAbstract 
where DocSerial = @van

-- Select documentid from VanstatementAbstract 
-- where DocSerial = @van

SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS NVarchar) + N'/' 
+ CAST(DATEPART(mm, @TODATE) as NVarchar) + N'/' 
+ cast(DATEPART(yyyy, @TODATE) AS NVarchar) 


SET  @NEXT_DATE = CAST(DATEPART(dd, GETDATE()) AS NVarchar) + N'/'             
+ CAST(DATEPART(mm, GETDATE()) as NVarchar) + N'/'             
+ cast(DATEPART(yyyy, GETDATE()) AS NVarchar)            

Set @Continue = 1    
Set @Counter = 1

----------

Create table #tmpCat1(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)

Insert into #tmpCat1 select Category_Name from ItemCategories 
Where [Level] = 1 Order By Category_Name

Insert into #tempCategory1 select CategoryID, Category_Name, 0     
From ItemCategories  
Where ItemCategories.Category_Name In (Select Category from #tmpCat1)  
Order By Category_Name

While @Continue > 0    
Begin    
	Declare Parent Cursor Keyset For    
	Select CategoryID From #tempCategory1 Where Status = 0    
	Open Parent    
	Fetch From Parent Into @CategoryID    
	While @@Fetch_Status = 0    
	Begin    
		Insert into #tempCategory1
                Select CategoryID, Category_Name, 0 From ItemCategories     
		Where ParentID = @CategoryID Order By Category_Name
		If @@RowCount > 0     
			Update #tempCategory1 Set Status = 1 Where CategoryID = @CategoryID    
		Else    
			Update #tempCategory1 Set Status = 2 Where CategoryID = @CategoryID    
			Fetch Next From Parent Into @CategoryID    
	End    
	Close Parent    
	DeAllocate Parent    
	Select @Continue = Count(*) From #tempCategory1 Where Status = 0    
End    

-- select * from #tempCategory1
----------

----------

Create table #tmpCat(Category varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
If @Category = '%' And @ProHier = '%'  
Begin  
	Insert into #tmpCat select Category_Name from ItemCategories Where [level] = 1  
End  
Else If @Category = '%' And @ProHier != '%'  
Begin  
	Insert InTo #tmpCat select Category_Name From itemcategories itc, itemhierarchy ith  
	Where itc.[level] = ith.hierarchyid and ith.hierarchyname = @ProHier  
End  
Else        
Begin  
	Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@Category, @Delimeter)        
End  

-- select * from #tmpCat
Create Table #temp2 (IDS Int IDENTITY(1, 1), CatID Int)  
Create Table #temp3 (CatID Int, Status Int)  
Create Table #temp4 (LeafID Int, CatID Int, Parent nVarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  
Insert InTo #temp2 Select CategoryID   
From ItemCategories    
Where ItemCategories.Category_Name In (Select Category from #tmpCat)    

-- select * from #temp2
  
Declare @Continue2 Int  
Declare @Inc Int  
Declare @TCat Int  
Set @Inc = 1  
Set @Continue = 1
-- select * from #temp2
Set @Continue2 = IsNull((Select Count(*) From #temp2), 0)  
-- select @Continue2
While @Inc <= @Continue2  
Begin  
-- 	Select CatID  From #temp2 Where IDS = @Inc  
	Insert InTo #temp3 Select CatID, 0 From #temp2 Where IDS = @Inc  
	Select @TCat = CatID From #temp2 Where IDS = @Inc  
	While @Continue > 0      
	Begin      
--		select * from #temp3
		Declare Parent Cursor Keyset For      
		Select CatID From #temp3  Where Status = 0      
		Open Parent      
		Fetch From Parent Into @CategoryID      
		While @@Fetch_Status = 0      
		Begin      
			Insert into #temp3  
			Select CategoryID, 0 From ItemCategories       
			Where ParentID = @CategoryID      
			If @@RowCount > 0       
				Update #temp3 Set Status = 1 Where CatID = @CategoryID      
			Else      
				Update #temp3 Set Status = 2 Where CatID = @CategoryID

--			select * from #temp3
      
			Fetch Next From Parent Into @CategoryID      
		End      
		Close Parent      
		DeAllocate Parent      
		Select @Continue = Count(*) From #temp3 Where Status = 0      
	End      
	Delete #temp3 Where Status not in  (0, 2)      
	Insert InTo #temp4 Select CatID, @TCat,   
	(Select Category_Name From ItemCategories where CategoryID = @TCat)  
	From #temp3  
	Delete #temp3  
	Set @Continue = 1  
	Set @Inc = @Inc + 1  
End  

-- select * from #temp4
----------

Declare @IPx nVarchar(10), @Va nVarChar(10)

Select @IPx = Prefix From Voucherprefix Where Tranid = N'INVOICE'
Select @Va = Prefix From Voucherprefix Where Tranid = N'VAN LOADING STATEMENT'

Select #tempCategory1.IDS, "Product Category" = #temp4.Parent, 

"System SKU Code" = its.Product_Code, "System SKU" = its.ProductName, 

"UOM Description" = uom.[Description], 

-- "for backd" = 	IsNull((Select Sum(Case vta.TransferType When 0 Then vtd.Quantity 
-- 					  When 1 Then 
-- 	 Case When vta.ToVanID <> @Van Then 0 Else vtd.Quantity End 
-- --	 Else vtd.Quantity 
-- 	End) From VanTransferAbstract vta, VanTransferDetail vtd
-- 	Where vta.DocSerial = vtd.DocSerial And 
-- 	vta.DocumentDate > @ToDate And 
-- 	vtd.Product_Code = vstd.Product_Code And 
-- 	(Case vta.TransferType When 0 Then vta.FromVanID Else ToVanID End) = @Van), 0) - 
-- 
-- 	(IsNull((Select Sum(Case vta.TransferType When 2 Then vtd.Quantity
-- 					  When 1 Then 
-- 	Case When vta.ToVanID = @Van Then 0 Else vtd.Quantity End 
-- --	Else 0 
-- 	End) From VanTransferAbstract vta, VanTransferDetail vtd
-- 	Where vta.DocSerial = vtd.DocSerial And 
-- 	vta.DocumentDate > @ToDate And 
-- 	vtd.Product_Code = vstd.Product_Code And 
-- 	(Case vta.TransferType When 0 Then vta.ToVanID Else FromVanID End) = @Van), 0) +
-- 
-- 	IsNull((Select Sum(invd.Quantity) From InvoiceAbstract inva, InvoiceDetail invd 
-- 	Where inva.InvoiceID = invd.InvoiceID And (inva.Status & 16) <> 0 And 
-- 	(inva.Status & 192) = 0 And inva.InvoiceType In (1, 3) 
-- 	And NewReference = @Va + Cast(@VanDocID As nVarChar) And
-- 	inva.InvoiceDate > @ToDate And 
-- 	invd.Product_Code = vstd.Product_Code), 0)),
-- 


"Cl. SOH" = 	  	((((Sum(vstd.Quantity) + 

	IsNull((Select Sum(Case vta.TransferType When 2 Then 0
					  When 1 Then 0
	-- Case When vta.ToVanID <> @Van Then 0 Else vtd.Quantity End 
	-- Else vtd.Quantity 
	End) From VanTransferAbstract vta, VanTransferDetail vtd
	Where vta.DocSerial = vtd.DocSerial And 
--	vta.DocumentDate <= @ToDate And 
	vtd.Product_Code = vstd.Product_Code And 
	(Case vta.TransferType When 0 Then vta.FromVanID Else ToVanID End) = @Van), 0)) - 

	(IsNull((Select Sum(Case vta.TransferType When 2 Then vtd.Quantity
					  When 1 Then 
	Case When vta.ToVanID = @Van Then 0 Else vtd.Quantity End 
	Else 0 End) From VanTransferAbstract vta, VanTransferDetail vtd
	Where vta.DocSerial = vtd.DocSerial And 
--	vta.DocumentDate <= @ToDate And 
	vtd.Product_Code = vstd.Product_Code And 
	(Case vta.TransferType When 0 Then vta.ToVanID Else FromVanID End) = @Van), 0) +

--        @va + Cast(@VanDocID As nVarChar) 
	IsNull((Select Sum(invd.Quantity) From InvoiceAbstract inva, InvoiceDetail invd 
	Where inva.InvoiceID = invd.InvoiceID And (inva.Status & 16) <> 0 And 
	(inva.Status & 192) = 0 And inva.InvoiceType In (1, 3) 
	And NewReference = @Va + Cast(@VanDocID As nVarChar) And
--	inva.InvoiceDate <= @ToDate And 
	invd.Product_Code = vstd.Product_Code), 0)))) -
	
	(IsNull((Select Sum(Case vta.TransferType When 0 Then vtd.Quantity 
					  When 1 Then 
	 Case When vta.ToVanID <> @Van Then 0 Else vtd.Quantity End 
--	 Else vtd.Quantity 
	End) From VanTransferAbstract vta, VanTransferDetail vtd
	Where vta.DocSerial = vtd.DocSerial And 
	vta.DocumentDate > @ToDate And 
	vtd.Product_Code = vstd.Product_Code And 
	(Case vta.TransferType When 0 Then vta.FromVanID Else ToVanID End) = @Van), 0) - 

	(IsNull((Select Sum(Case vta.TransferType When 2 Then vtd.Quantity
					  When 1 Then 
	Case When vta.ToVanID = @Van Then 0 Else vtd.Quantity End 
--	Else 0 
	End) From VanTransferAbstract vta, VanTransferDetail vtd
	Where vta.DocSerial = vtd.DocSerial And 
	vta.DocumentDate > @ToDate And 
	vtd.Product_Code = vstd.Product_Code And 
	(Case vta.TransferType When 0 Then vta.ToVanID Else FromVanID End) = @Van), 0) +

	IsNull((Select Sum(invd.Quantity) From InvoiceAbstract inva, InvoiceDetail invd 
	Where inva.InvoiceID = invd.InvoiceID And (inva.Status & 16) <> 0 And 
	(inva.Status & 192) = 0 And inva.InvoiceType In (1, 3) 
	And NewReference = @Va + Cast(@VanDocID As nVarChar) And
	inva.InvoiceDate > @ToDate And 
	invd.Product_Code = vstd.Product_Code), 0))))  /

	Case @UOM When 'UOM' Then 1
	  When 'UOM1' Then Case IsNull(its.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(its.UOM1_Conversion, 1) End
	  When 'UOM2' Then Case IsNull(its.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(its.UOM2_Conversion, 1) End
	  End
,

"Value(%c)" = ((Sum(vstd.Quantity * vstd.pts) + 

	IsNull((Select Sum(Case vta.TransferType When 2 Then 0
					  When 1 Then 0
	-- Case When vta.ToVanID <> @Van Then 0 Else vtd.Quantity End 
	-- Else vtd.Quantity 
	End * bp.pts) From VanTransferAbstract vta, VanTransferDetail vtd, 
	batch_products bp
	Where vta.DocSerial = vtd.DocSerial 
	And bp.batch_code = vtd.batchcode And
--	And vta.DocumentDate <= @ToDate And 
	vtd.Product_Code = vstd.Product_Code And 
	(Case vta.TransferType When 0 Then vta.FromVanID Else ToVanID End) = @Van), 0)) - 

	(IsNull((Select Sum(Case vta.TransferType When 2 Then vtd.Quantity
					  When 1 Then 
	Case When vta.ToVanID = @Van Then 0 Else vtd.Quantity End 
	Else 0 End * bp.pts) From VanTransferAbstract vta, VanTransferDetail vtd, batch_products bp
	Where vta.DocSerial = vtd.DocSerial 
	And bp.batch_code = vtd.batchcode And
--	And vta.DocumentDate <= @ToDate And 
	vtd.Product_Code = vstd.Product_Code And 
	(Case vta.TransferType When 0 Then vta.ToVanID Else FromVanID End) = @Van), 0) +


	(IsNull((Select Sum(invd.Quantity * invd.pts) From InvoiceAbstract inva, InvoiceDetail invd 
	Where inva.InvoiceID = invd.InvoiceID And (inva.Status & 16) <> 0 And 
	(inva.Status & 192) = 0 And inva.InvoiceType In (1, 3) 
	And NewReference = @Va + Cast(@VanDocID As nVarChar) And
--	inva.InvoiceDate <= @ToDate And 
	invd.Product_Code = vstd.Product_Code), 0)))) -

	(IsNull((Select Sum(Case vta.TransferType When 0 Then vtd.Quantity 
					  When 1 Then 
	 Case When vta.ToVanID <> @Van Then 0 Else vtd.Quantity End 
--	 Else vtd.Quantity 
	End * bp.pts) From VanTransferAbstract vta, VanTransferDetail vtd, batch_products bp
	Where vta.DocSerial = vtd.DocSerial And 
	bp.batch_code = vtd.batchcode And 
	vta.DocumentDate > @ToDate And 
	vtd.Product_Code = vstd.Product_Code And 
	(Case vta.TransferType When 0 Then vta.FromVanID Else ToVanID End) = @Van), 0) - 

	(IsNull((Select Sum(Case vta.TransferType When 2 Then vtd.Quantity
					  When 1 Then 
	Case When vta.ToVanID = @Van Then 0 Else vtd.Quantity End 
--	Else 0 
	End * bp.pts) From VanTransferAbstract vta, VanTransferDetail vtd, batch_products bp
	Where vta.DocSerial = vtd.DocSerial And 
	bp.batch_code = vtd.batchcode And 
	vta.DocumentDate > @ToDate And 
	vtd.Product_Code = vstd.Product_Code And 
	(Case vta.TransferType When 0 Then vta.ToVanID Else FromVanID End) = @Van), 0) +

	IsNull((Select Sum(invd.Quantity * invd.pts) From InvoiceAbstract inva, InvoiceDetail invd 
	Where inva.InvoiceID = invd.InvoiceID And (inva.Status & 16) <> 0 And 
	(inva.Status & 192) = 0 And inva.InvoiceType In (1, 3) 
	And NewReference = @Va + Cast(@VanDocID As nVarChar) And
	inva.InvoiceDate > @ToDate And 
	invd.Product_Code = vstd.Product_Code), 0)))


	,

------------------------
-- @CORRECTED_DATE,
-- 
-- @TODATE , 
-- @NEXT_DATE,

-- CASE When (@TODATE < @NEXT_DATE) THEN  
--    				ISNULL((Select Opening_Quantity FROM OpeningDetails
-- 				WHERE OpeningDetails.Product_Code = its.Product_Code
-- 				AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0) End,
-- 
-- IsNull((Select Sum(vsdd.Pending) From VanstatementAbstract vsaa, VanstatementDetail vsdd
-- Where vsaa.DocSerial = vsdd.DocSerial And vsdd.Product_Code = vstd.Product_Code) --And 
-- --vsaa.LoadingDate <= @ToDate)
-- , 0), 
-- 
-- 	IsNull((Select Sum(Case vta.TransferType When 0 then --  Then 0
-- --					  When 1 Then 0
-- 	-- Case When vta.ToVanID <> @Van Then 0 Else vtd.Quantity End 
-- 	-- Else 	
-- 	vtd.Quantity 
-- 	End) From VanTransferAbstract vta, VanTransferDetail vtd
-- 	Where vta.DocSerial = vtd.DocSerial And 
-- 	vta.DocumentDate > @ToDate And 
-- 	vtd.Product_Code = vstd.Product_Code --And 
-- --	(Case vta.TransferType When 0 Then vta.FromVanID Else ToVanID End) = @Van
-- 	), 0),
-- 
-- 	IsNull((Select Sum(Case vta.TransferType When 2 Then vtd.Quantity
-- --					  When 1 Then 
-- --	Case When vta.ToVanID = @Van Then 0 Else vtd.Quantity 
-- 	End 
-- --	Else 0 End
-- 	) From VanTransferAbstract vta, VanTransferDetail vtd
-- 	Where vta.DocSerial = vtd.DocSerial And 
-- 	vta.DocumentDate > @ToDate And 
-- 	vtd.Product_Code = vstd.Product_Code -- And 
-- --	(Case vta.TransferType When 0 Then vta.ToVanID Else FromVanID End) = @Van
-- 	), 0) ,
-- 
-- 	IsNull((Select Sum(invd.Quantity) From InvoiceAbstract inva, InvoiceDetail invd 
-- 	Where inva.InvoiceID = invd.InvoiceID And (inva.Status & 16) = 16 And 
-- 	(inva.Status & 192) = 0 And inva.InvoiceType In (1, 3) And
-- --	And NewReference = @Va + Cast(@VanDocID As nVarChar) And
-- 	inva.InvoiceDate > @ToDate And 
-- 	invd.Product_Code = vstd.Product_Code), 0),

------------------------
"Cl. SOH in Main Godown" =  Cast(CASE When (@TODATE < @NEXT_DATE) THEN  
   				ISNULL((Select Opening_Quantity FROM OpeningDetails
				WHERE OpeningDetails.Product_Code = its.Product_Code
				AND Opening_Date = DATEADD(dd, 1, @CORRECTED_DATE)), 0) - 

(
(
IsNull((Select Sum(vsdd.Pending) From VanstatementAbstract vsaa, VanstatementDetail vsdd
Where vsaa.DocSerial = vsdd.DocSerial And vsdd.Product_Code = vstd.Product_Code) --And 
--vsaa.LoadingDate <= @ToDate)
, 0)

			 -

	IsNull((Select Sum(Case vta.TransferType When 0 then --  Then 0
--					  When 1 Then 0
	-- Case When vta.ToVanID <> @Van Then 0 Else vtd.Quantity End 
	-- Else 	
	vtd.Quantity 
	End) From VanTransferAbstract vta, VanTransferDetail vtd
	Where vta.DocSerial = vtd.DocSerial And 
	vta.DocumentDate > @ToDate And 
	vtd.Product_Code = vstd.Product_Code --And 
--	(Case vta.TransferType When 0 Then vta.FromVanID Else ToVanID End) = @Van
	), 0)
)
			 +

(

	IsNull((Select Sum(Case vta.TransferType When 2 Then vtd.Quantity
--					  When 1 Then 
--	Case When vta.ToVanID = @Van Then 0 Else vtd.Quantity 
	End 
--	Else 0 End
	) From VanTransferAbstract vta, VanTransferDetail vtd
	Where vta.DocSerial = vtd.DocSerial And 
	vta.DocumentDate > @ToDate And 
	vtd.Product_Code = vstd.Product_Code -- And 
--	(Case vta.TransferType When 0 Then vta.ToVanID Else FromVanID End) = @Van
	), 0) 

			+

--        @va + Cast(@VanDocID As nVarChar) 
	IsNull((Select Sum(invd.Quantity) From InvoiceAbstract inva, InvoiceDetail invd 
	Where inva.InvoiceID = invd.InvoiceID And (inva.Status & 16) = 16 And 
	(inva.Status & 192) = 0 And inva.InvoiceType In (1, 3) And
--	And NewReference = @Va + Cast(@VanDocID As nVarChar) And
	inva.InvoiceDate > @ToDate And 
	invd.Product_Code = vstd.Product_Code), 0)
)
)
		
-- 				 -
-- 	
-- 	(IsNull((Select Sum(Case vta.TransferType When 0 Then vtd.Quantity 
-- 					  When 1 Then 
-- 	 Case When vta.ToVanID <> @Van Then 0 Else vtd.Quantity End 
-- --	 Else vtd.Quantity 
-- 	End) From VanTransferAbstract vta, VanTransferDetail vtd
-- 	Where vta.DocSerial = vtd.DocSerial And 
-- 	vta.DocumentDate > @ToDate And 
-- 	vtd.Product_Code = vstd.Product_Code And 
-- 	(Case vta.TransferType When 0 Then vta.FromVanID Else ToVanID End) = @Van), 0) - 
-- 
-- 	(IsNull((Select Sum(Case vta.TransferType When 2 Then vtd.Quantity
-- 					  When 1 Then 
-- 	Case When vta.ToVanID = @Van Then 0 Else vtd.Quantity End 
-- --	Else 0 
-- 	End) From VanTransferAbstract vta, VanTransferDetail vtd
-- 	Where vta.DocSerial = vtd.DocSerial And 
-- 	vta.DocumentDate > @ToDate And 
-- 	vtd.Product_Code = vstd.Product_Code And 
-- 	(Case vta.TransferType When 0 Then vta.ToVanID Else FromVanID End) = @Van), 0) +
-- 
-- 	IsNull((Select Sum(invd.Quantity) From InvoiceAbstract inva, InvoiceDetail invd 
-- 	Where inva.InvoiceID = invd.InvoiceID And (inva.Status & 16) <> 0 And 
-- 	(inva.Status & 192) = 0 And inva.InvoiceType In (1, 3) 
-- 	And NewReference = @Va + Cast(@VanDocID As nVarChar) And
-- 	inva.InvoiceDate > @ToDate And 
-- 	invd.Product_Code = vstd.Product_Code), 0))))
		

        ELSE ISNULL((SELECT SUM(Quantity) FROM Batch_Products 
			    WHERE Product_Code = its.Product_Code), 0) 
			    End As Decimal(18, 6)) / 
	  Case @UOM When 'UOM' Then 1
	  When 'UOM1' Then Case IsNull(its.UOM1_Conversion, 1) When 0 Then 1 Else IsNull(its.UOM1_Conversion, 1) End
	  When 'UOM2' Then Case IsNull(its.UOM2_Conversion, 1) When 0 Then 1 Else IsNull(its.UOM2_Conversion, 1) End
	  End

-- Into #FTableOne

From VanstatementAbstract vsta, VanstatementDetail vstd, items its, ItemCategories itc,
UOM, #temp4, #tempCategory1
Where vsta.DocSerial = vstd.DocSerial And its.Product_Code = vstd.Product_Code And
its.Categoryid = itc.Categoryid And its.CategoryID = #temp4.LeafID And 
its.CategoryID = #tempCategory1.CategoryID And 
UOM.UOM = Case @UOM When 'UOM' Then its.UOM
							When 'UOM1' Then its.UOM1
							When 'UOM2' Then its.UOM2 End And
vsta.LoadingDate <= @ToDate And
--its.CategoryID In (Select CategoryID From #temp) And 
vsta.DocSerial = @Van

Group By itc.Category_Name, its.Product_Code, its.ProductName, UOM.[Description], 
its.UOM1_Conversion, its.UOM2_Conversion, vstd.Product_Code, its.PTS, 
#tempCategory1.IDS, #temp4.Parent
Order By #tempCategory1.IDS

-- select * from #FTableOne

Drop Table #tmpCat1
Drop Table #tempCategory1
Drop Table #tmpCat
Drop Table #temp2 
Drop Table #temp3 
Drop Table #temp4 

