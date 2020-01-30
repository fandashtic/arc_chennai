CREATE Procedure spr_WDVanLoadingSummary_ITC
(
	@VanNumber NVarChar(255),
	@Beat NVarChar(510),
	@Product_Hierarchy NVarChar(256),                   
	@Category NVarChar(2550),
	@FromDate DateTime,
	@ToDate DateTime,
	@UOM nVarChar(255)
)      
As      
Begin

	Declare @Delimeter As Char(1)
	Set @Delimeter = Char(15)

	Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)  
	Exec sp_CatLevelwise_ItemSorting  

	Create Table #TempCategory(CategoryID Int, Status Int)                  
	Exec dbo.GetLeafCategories @Product_Hierarchy, @Category            
	          
	Create Table #TmpCat(Category NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #TmpBeat(BeatID Int)

	Create Table #TmpInvNo (DocID int)
	Create Table #TmpSRInvoiceID (GSTReference NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Create Table #Temp
	(
		RowNum Int Identity(1,1),
		Product_Code NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
		UOM Int,
		[Description] NVarChar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
		UOMConv Decimal(18,6)
	)  
	Exec sp_GetDefaultSalesUOM_ITC    

	Create Table #TempSale
	(
		CategoryName NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		ItemCode NVarChar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,
		ItemName NVarChar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
		Qty Decimal(18,6),ECP Decimal(18,6),NetValue Decimal(18,6),
		SchemeDiscAmount Decimal(18, 6),
		SplCatDiscAmount Decimal(18, 6),
		DiscountValue Decimal(18, 6),
		TaxAmt Decimal(18, 6),
		RetSalable Decimal(18, 6),
		RetDamaged Decimal(18, 6), 
		DocumentID Int,
		GSTFlag int,
		GSTFullDocID NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS
	)

	Create Table #TempFree
	(
		CategoryName NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		ItemCode NVarChar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,
		ItemName NVarChar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
		Qty Decimal(18,6),ECP Decimal(18,6),NetValue Decimal(18,6),
		SchemeDiscAmount Decimal(18, 6),
		SplCatDiscAmount Decimal(18, 6),
		DiscountValue Decimal(18, 6),
		TaxAmt Decimal(18, 6), 
		RetSalable Decimal(18, 6),
		RetDamaged Decimal(18, 6),
		DocumentID Int
	)

	Create Table #tempDiv(Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,  
     Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
     Sub_Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
     Market_SKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)  

	Insert Into #tempDiv(Product_Code, Category, Sub_Category, Market_SKU)  
	Select  
	 Distinct I.Product_Code, IC1.Category_Name,  
	 IC2.Category_Name, IC3.Category_Name    
	From  
	 ItemCategories IC1, ItemCategories IC2, ItemCategories IC3, Items I  
	Where  
	 IC1.CategoryID = IC2.ParentID  
	 And IC2.CategoryID = IC3.ParentID   
	 And IC1.Level = 2  
	 And I.CategoryID = IC3.CategoryID  
	Order By  
	 I.Product_Code, IC1.Category_Name, IC2.Category_Name, IC3.Category_Name  



	If @Beat = '%'      
		Insert Into #TmpBeat Select BeatId From Beat      
	Else      
		Insert Into #TmpBeat       
		Select BeatId From Beat Where Description In (Select * From dbo.sp_SplitIn2Rows(@Beat,@Delimeter))
	      
	If @Category = '%' And @Product_Hierarchy = '%'        
	Begin        
		Insert Into #TmpCat Select Category_Name From ItemCategories Where [Level] = 1        
	End        
	Else If @Category = '%' And @Product_Hierarchy != '%'        
	Begin        
		Insert Into #TmpCat Select Category_Name From ItemCategories ITC, ItemHierarchy ITH        
		Where ITC.[Level] = ITH.hierarchyid and ITH.hierarchyname = @Product_Hierarchy        
	End        
	Else              
	Begin        
		Insert Into #TmpCat Select * From dbo.sp_SplitIn2Rows(@Category,@Delimeter)              
	End        

	Insert Into #TmpInvNo
	Select dbo.GetTrueVal_ITC(CD.OriginalID) 
	From InvoiceAbstract IA, CollectionDetail CD
	Where IsNull(IA.Status,0) & 128 = 0
	And IA.InvoiceType In (1, 3)
	And IA.InvoiceDate Between @FromDate And @ToDate
	And IA.VanNumber Is Not Null
	And IA.VanNumber = @VanNumber
	And IA.BeatId IN (Select BeatId From #TmpBeat)
	And IA.PaymentDetails = CD.CollectionID
	And CD.DocumentType = 1
	And IsNull(IA.GSTFlag ,0) = 0
	
	Insert Into #TmpSRInvoiceID
	Select CD.OriginalID
	From InvoiceAbstract IA, CollectionDetail CD
	Where IsNull(IA.Status,0) & 128 = 0
	And IA.InvoiceType In (1, 3)
	And IA.InvoiceDate Between @FromDate And @ToDate
	And IA.VanNumber Is Not Null
	And IA.VanNumber = @VanNumber
	And IA.BeatId IN (Select BeatId From #TmpBeat)
	And IA.PaymentDetails = CD.CollectionID
	And CD.DocumentType = 1
	And IsNull(IA.GSTFlag ,0) = 1

	Insert Into #TempSale(CategoryName,ItemCode,ItemName,Qty,ECP,NetValue, SchemeDiscAmount,
	SplCatDiscAmount, DiscountValue, TaxAmt, RetSalable, RetDamaged, DocumentID, GSTFlag,GSTFullDocID )
	Select 
	C.Category_Name,I.Product_Code,I.ProductName,
	(IsNull(IDT.Quantity,0)),IsNull(IDT.MRP,0),(IsNull(IDT.Amount,0)),

	((IsNull(IDT.SchemeDiscAmount,0) + IsNull(IDT.SplCatDiscAmount,0))      
	+ ((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0)) 
	* IsNull(IA.SchemeDiscountPercentage, 0) / 100)), 

	(IsNull(IDT.SplCatDiscAmount, 0)),

	((IsNull(IDT.DiscountValue, 0) - (IsNull(IDT.SchemeDiscAmount, 0) 
	+ IsNull(IDT.SplCatDiscAmount, 0)))      
	+ ((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))  
	*((IsNull(IA.DiscountPercentage, 0) - IsNull(IA.SchemeDiscountPercentage, 0)) / 100))      
	+ ((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0)) 
	* IsNull(IA.AdditionalDiscount, 0) / 100)),        

	(IsNull(IDT.STPayable, 0) + IsNull(IDT.CSTPayable, 0)),
	Cast(0 As Decimal(18, 6)),  Cast(0 As Decimal(18, 6)),
	IA.DocumentID , ISNULL(IA.GSTFlag ,0) ,ISNULL(IA.GSTFullDocID ,'')
	From
	Items I
	Inner Join ItemCategories C On I.CategoryId = C.CategoryId     
	Inner Join InvoiceDetail IDT On IDT.Product_Code = I.Product_Code
	Inner Join InvoiceAbstract IA On IA.InvoiceId = IDT.InvoiceId 
	Inner Join #Temp UM On IDT.Product_Code = UM.Product_Code 
	Left Outer Join Batch_Products B On IDT.Batch_Code = B.Batch_Code     
	Where 
	IsNull(IA.Status,0) & 128 = 0
	And IA.InvoiceType In (1, 3)
	And IA.InvoiceDate Between @FromDate And @ToDate     
	And IA.VanNumber Is Not Null      
	And IA.VanNumber = @VanNumber
	And IA.BeatId IN (Select BeatId From #TmpBeat)      
	And IsNull(IDT.SalePrice,0) <> 0
	And C.CategoryId In (Select CategoryId From #TempCategory)      

	Select DocumentID as ReferenceNo Into #TempPrefix From #TempSale where GSTFlag = 0
	Insert Into #TmpSRInvoiceID Select GSTFullDocID From #TempSale where GSTFlag = 1
			
	Insert Into #TempSale(CategoryName,ItemCode,ItemName,Qty,ECP,NetValue, SchemeDiscAmount,
	SplCatDiscAmount, DiscountValue, TaxAmt, RetSalable, RetDamaged, DocumentID)
	Select 
	C.Category_Name,I.Product_Code,I.ProductName,
	0, -- (IsNull(IDT.Quantity,0)), 
	IsNull(IDT.MRP,0), 0, --(IsNull(IDT.Amount,0)),
	0, --(IsNull(IDT.SchemeDiscAmount, 0)), 
	0, --(IsNull(IDT.SplCatDiscAmount, 0)),
	0, --(IsNull(IDT.DiscountValue, 0) - 
	--(IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0))),
	0, --(IsNull(IDT.STPayable, 0) + IsNull(IDT.CSTPayable, 0)),
	(Case IA.status & 32 When 0 Then IsNull(IDT.Quantity,0) Else Cast(0 As Decimal(18, 6)) End),
	(Case IA.status & 32 When 0 Then Cast(0 As Decimal(18, 6)) Else IsNull(IDT.Quantity,0) End),
	IA.DocumentID
	From
	Items I
	Inner Join ItemCategories C On I.CategoryId = C.CategoryId      
	Inner Join InvoiceDetail IDT On IDT.Product_Code = I.Product_Code
	Inner Join InvoiceAbstract IA On IA.InvoiceId = IDT.InvoiceId
	Inner Join #Temp UM On IDT.Product_Code = UM.Product_Code 
	Left Outer Join Batch_Products B On IDT.Batch_Code = B.Batch_Code--, #TempPrefix TS
	Where
	IsNull(IA.Status,0) & 128 = 0
	-- And IsNull(IDT.SalePrice,0) <> 0
	And IA.InvoiceType = 4
	And IA.InvoiceDate Between @FromDate And @ToDate
--	And IA.VanNumber Is Not Null 
--	And IA.VanNumber = @VanNumber
	And IA.BeatId IN (Select BeatId From #TmpBeat)      
	And C.CategoryId In (Select CategoryId From #TempCategory)      
	And
	(
		dbo.GetTrueVal_ITC(IA.ReferenceNumber) In (Select ReferenceNo From #TempPrefix Where ReferenceNo = dbo.GetTrueVal_ITC(IA.ReferenceNumber))
		Or
		DocumentID In (Select DocID From #TmpInvNo)
		Or
		IA.ReferenceNumber In (Select GSTReference From #TmpSRInvoiceID Where GSTReference = IA.ReferenceNumber)
		OR
		IA.GSTFullDocID in (Select GSTReference From #TmpSRInvoiceID Where GSTReference = IA.ReferenceNumber)
	)

	Drop table #TempPrefix
	----------------------------------------------------------
	Insert Into #TempFree(CategoryName,ItemCode,ItemName,Qty,ECP,NetValue, SchemeDiscAmount,
	SplCatDiscAmount, DiscountValue, TaxAmt, RetSalable, RetDamaged, DocumentID)
	Select 
	C.Category_Name,I.Product_Code,I.ProductName,
	(IsNull(IDT.Quantity,0)),IsNull(IDT.MRP,0), (IsNull(IDT.Amount,0)),

	((IsNull(IDT.SchemeDiscAmount,0) + IsNull(IDT.SplCatDiscAmount,0))      
	+ ((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0)) 
	* IsNull(IA.SchemeDiscountPercentage, 0) / 100)), 

	--(IsNull(IDT.SchemeDiscAmount, 0)), 
	(IsNull(IDT.SplCatDiscAmount, 0)),

	((IsNull(IDT.DiscountValue, 0) - (IsNull(IDT.SchemeDiscAmount, 0) 
	+ IsNull(IDT.SplCatDiscAmount, 0)))      
	+ ((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0))  
	*((IsNull(IA.DiscountPercentage, 0) - IsNull(IA.SchemeDiscountPercentage, 0)) / 100))      
	+ ((IsNull(IDT.Quantity, 0) * IsNull(IDT.SalePrice, 0) - IsNull(IDT.DiscountValue, 0)) 
	* IsNull(IA.AdditionalDiscount, 0) / 100)),        

	--  (IsNull(IDT.DiscountValue, 0) - 
	--  (IsNull(IDT.SchemeDiscAmount, 0) + IsNull(IDT.SplCatDiscAmount, 0))),
	(IsNull(IDT.STPayable, 0) + IsNull(IDT.CSTPayable, 0)),
	Cast(0 As Decimal(18, 6)),  Cast(0 As Decimal(18, 6)),
	IA.DocumentID
	From
	Items I
	Inner Join ItemCategories C On I.CategoryId = C.CategoryId      
	Inner Join InvoiceDetail IDT On IDT.Product_Code = I.Product_Code
	Inner Join InvoiceAbstract IA On IA.InvoiceId = IDT.InvoiceId
	Inner Join #Temp UM On IDT.Product_Code = UM.Product_Code 
	Left Outer Join Batch_Products B On IDT.Batch_Code = B.Batch_Code        
	Where
	IsNull(IA.Status,0) & 128 = 0     
	And IA.InvoiceDate Between @FromDate And @ToDate     
	And IA.VanNumber Is Not Null      
	And IA.VanNumber = @VanNumber   
	And IA.BeatId IN (Select BeatId From #TmpBeat)      
	And IsNull(IDT.SalePrice,0) = 0
	And C.CategoryId In (Select CategoryId From #TempCategory)      
	----------------------------------------------------------------------------------------
	Insert Into #TempSale(CategoryName,ItemCode,ItemName,Qty,ECP,NetValue, SchemeDiscAmount,
	SplCatDiscAmount, DiscountValue, TaxAmt, RetSalable, RetDamaged, DocumentID)
	Select CategoryName,ItemCode,ItemName,Cast(0 As Decimal(18, 6)),ECP,NetValue, SchemeDiscAmount,
	SplCatDiscAmount, DiscountValue, TaxAmt, RetSalable, RetDamaged, DocumentID 
	From #TempFree 
	---------------------------------------------------------------------------------------
	Select [CategoryName] = CategoryName, 
	 [ItemCode] = ItemCode, [ItemName] = ItemName, 
	 [Qty] = sum(Qty), [ECP] = ECP, [NetValue] = sum(NetValue),
	 [SchemeDiscAmount] = Sum(SchemeDiscAmount),
	 [SplCatDiscAmount] = Sum(SplCatDiscAmount),
	 [DiscountValue] = Sum(DiscountValue),
	 [TaxAmt] = Sum(TaxAmt), 
	 [RetSalable] = Sum(RetSalable),
	 [RetDamaged] = Sum(RetDamaged)
	 Into #TempSaleone From #TempSale
	 Group By CategoryName, ItemCode, ItemName, ECP

	Select [CategoryName] = CategoryName, 
	 [ItemCode] = ItemCode, [ItemName] = ItemName, 
	 [Qty] = sum(Qty), [ECP] = ECP, [NetValue] = sum(NetValue),
	 [SchemeDiscAmount] = Sum(SchemeDiscAmount),
	 [SplCatDiscAmount] = Sum(SplCatDiscAmount),
	 [DiscountValue] = Sum(DiscountValue),
	 [TaxAmt] = Sum(TaxAmt),
	 [RetSalable] = Sum(RetSalable),
	 [RetDamaged] = Sum(RetDamaged)
	 Into #TempFreeone From #TempFree
	 Group By CategoryName, ItemCode, ItemName, ECP
	----------------------------------------------------------------------------------
	-- select * from #TempSaleone
	-- select * from #TempFreeone
	----------------------------------------------------------------------------------------
	--Declare @Sql nVarchar(4000)

	If @UOM = 'UOM1 & UOM2'
	Begin
		Select 
		"IDS" = TC.IDS,
		"Item CodeH" = IsNull(TS.ItemCode,''), 
		"Item Code" = IsNull(TS.ItemCode,''), 
		"Item Name" = IsNull(TS.ItemName,''),
		"Qty in CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(TS.ItemCode, Sum(IsNull(TS.Qty, 0)), 1),

		"Qty in PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(TS.ItemCode, Sum(IsNull(TS.Qty, 0)), 2),

		"Free Qty in PAC" =  IsNull((Select sum(Qty) From #TempFreeone Where ItemCode = TS.ItemCode and 
		ecp = ts.ecp), 0) / 
		Case IsNull((Select uom2_conversion From Items   
		Where Product_Code = TS.ItemCode), 0) When 0 Then 1 Else   
		IsNull((Select uom2_conversion From Items   
		Where Product_Code = TS.ItemCode), 0) End,

		"Total CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(TS.ItemCode, Sum(IsNull(TS.Qty, 0)) + 
		IsNull((Select sum(Qty) From #TempFreeone Where ItemCode = TS.ItemCode and ecp = ts.ecp), 0), 1),  

		"Total PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(TS.ItemCode, Sum(IsNull(TS.Qty, 0)) + 
		IsNull((Select sum(Qty) From #TempFreeone Where ItemCode = TS.ItemCode and 
		ecp = ts.ecp), 0), 2),  

		"Sch. Disc" = Sum(IsNull(TS.SchemeDiscAmount, 0)),

		"Discount" = Sum(TS.DiscountValue), 

		"VAT/Tax" = Sum(TS.TaxAmt), 

		"Total Value" = Cast(Sum(TS.NetValue)As Decimal(18,6)),

		"Weight(Kg)" = Cast((Sum(IsNull(TS.Qty,0)) + 
		IsNull((Select sum(Qty) From #TempFreeone Where ItemCode = TS.ItemCode 
		and ecp = ts.ecp), 0))
		* IsNull(ITS.ConversionFactor,0) As Decimal(18,6)),   

		"MRP per PAC" = Cast(IsNull(TS.ECP,0) * IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)),

		"Ret Saleable in PAC" = Sum(IsNull(TS.RetSalable, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) End,


		"Ret Damaged in PAC" = Sum(IsNull(TS.RetDamaged, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = TS.ItemCode ), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) End 

		Into #tempOT
		From #Temp T,#TempSaleone TS, 
		--#TempFreeone TF, 
		Items ITS, #tempCategory1 TC  
		Where T.Product_Code = TS.ItemCode  
		And TS.ItemCode = ITS.Product_Code  
		-- And TS.ItemCode *= TF.ItemCode  
		And TC.CategoryID = ITS.CategoryID  
		Group By  
		-- T.[Description],
		TS.ItemCode, --TS.CategoryName,
		TS.ItemName,TS.ECP, ITS.UOM2_Conversion,   
		-- TF.ItemCode, 
		TC.IDS, ITS.ConversionFactor
		Order By TC.IDS  
	End
	Else
	If @UOM = 'Base UOM'
	Begin
		------------------
		--select * from #TempFreeone 
		------------------
		Select 
		"IDS" = TC.IDS,
		"Item CodeH" = IsNull(TS.ItemCode,''), 
		"Item Code" = IsNull(TS.ItemCode,''), 
		"Item Name" = IsNull(TS.ItemName,''),
		"UOM" = IsNull((Select [Description] From UOM Where UOM In (Select UOM From Items 
		Where Product_code = IsNull(TS.ItemCode,''))), ''),
		"Qty" = Sum(IsNull(TS.Qty, 0)),

		"Free" = IsNull((Select sum(Qty) From #TempFreeone Where ItemCode = TS.ItemCode 
		and ecp = ts.ecp), 0),  

		"Total Qty" = Sum(IsNull(TS.Qty, 0)) + IsNull((Select sum(Qty) From #TempFreeone 
		Where ItemCode = TS.ItemCode and ecp = ts.ecp), 0),  

		"Sch. Disc" = Sum(IsNull(TS.SchemeDiscAmount, 0)),
		--Sum(IsNull(TS.SchemeDiscAmount, 0) + IsNull(TS.SplCatDiscAmount, 0)),

		"Discount" = Sum(TS.DiscountValue), 

		"VAT/Tax" = Sum(TS.TaxAmt), 


		"Total Value" = Cast(Sum(TS.NetValue)As Decimal(18,6)),

		"Weight(Kg)" =  Cast((Sum(IsNull(TS.Qty,0)) + 
		IsNull((Select sum(Qty) From #TempFreeone Where ItemCode = TS.ItemCode and ecp = ts.ecp), 0))
		* IsNull(ITS.ConversionFactor,0) as Decimal(18, 6)),   


		"MRP per PAC" = Cast(IsNull(TS.ECP,0) * IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)),
		"Return Saleable" = Sum(TS.RetSalable),
		"Return Damaged" = Sum(TS.RetDamaged)
		Into #tempB
		From #Temp T,#TempSaleone TS, --#TempFreeone TF, 
		Items ITS, 
		#tempCategory1 TC  
		Where T.Product_Code = TS.ItemCode  
		And TS.ItemCode = ITS.Product_Code  
		-- And TS.ItemCode *= TF.ItemCode  
		And TC.CategoryID = ITS.CategoryID  

		Group By  
		--  T.[Description],
		TS.ItemCode,
		--TS.CategoryName, 
		TS.ItemName,
		ITS.ConversionFactor, 
		TS.ECP, ITS.UOM2_Conversion ,   
		--TF.ItemCode, 
		TC.IDS  
		Order By TC.IDS  
	End
	Else
	If @UOM = 'UOM1'
	Begin
		Select 
		"IDS" = TC.IDS,
		"Item CodeH" = IsNull(TS.ItemCode,''), 
		"Item Code" = IsNull(TS.ItemCode,''), 
		"Item Name" = IsNull(TS.ItemName,''),
		"UOM" = IsNull((Select [Description] From UOM Where UOM In (Select uom1 From Items 
		Where Product_code = IsNull(TS.ItemCode,''))), ''),

		"Qty" = Sum(IsNull(TS.Qty, 0)) / Case IsNull((Select uom1_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) When 0 Then 1 Else 
		IsNull((Select uom1_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) End ,

		"Free" = IsNull((Select sum(Qty) From #TempFreeone Where ItemCode = TS.ItemCode and 
		ecp = ts.ecp), 0) / 
		Case IsNull((Select uom1_conversion From Items   
		Where Product_Code = TS.ItemCode and ecp = ts.ecp), 0) When 0 Then 1 Else   
		IsNull((Select uom1_conversion From Items   
		Where Product_Code = TS.ItemCode), 0) End ,  

		"Total Qty" = Sum(IsNull(TS.Qty, 0)) / Case IsNull((Select uom1_conversion From Items 
		Where Product_Code = TS.ItemCode ), 0) When 0 Then 1 Else 
		IsNull((Select uom1_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) End + 

		IsNull((Select sum(Qty) From #TempFreeone Where ItemCode = TS.ItemCode and 
		ecp = ts.ecp), 0) / 
		Case IsNull((Select uom1_conversion From Items   
		Where Product_Code = TS.ItemCode), 0) When 0 Then 1 Else   
		IsNull((Select uom1_conversion From Items   
		Where Product_Code = TS.ItemCode ), 0) End,  

		"Sch. Disc" = Sum(IsNull(TS.SchemeDiscAmount, 0)),

		"Discount" = Sum(TS.DiscountValue), 

		"VAT/Tax" = Sum(TS.TaxAmt), 

		"Total Value" = Cast(Sum(TS.NetValue)As Decimal(18,6)),

		"Weight(Kg)" = Cast((Sum(IsNull(TS.Qty,0)) +  
		IsNull((Select sum(Qty) From #TempFreeone Where ItemCode = TS.ItemCode 
		and ecp = ts.ecp), 0))
		* IsNull(ITS.ConversionFactor,0) As Decimal(18,6)),   

		"MRP per PAC" = Cast(IsNull(TS.ECP,0) * IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)),

		"Return Saleable" = Sum(IsNull(TS.RetSalable, 0)) / Case IsNull((Select uom1_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) When 0 Then 1 Else 
		IsNull((Select uom1_conversion From Items 
		Where Product_Code = TS.ItemCode ), 0) End ,

		"Return Damaged" = Sum(IsNull(TS.RetDamaged, 0)) / Case IsNull((Select uom1_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) When 0 Then 1 Else 
		IsNull((Select uom1_conversion From Items 
		Where Product_Code = TS.ItemCode ), 0) End 

		Into #tempUO
		From #Temp T,#TempSaleone TS, 
		--#TempFreeone TF, 
		Items ITS, #tempCategory1 TC  
		Where T.Product_Code = TS.ItemCode  
		And TS.ItemCode = ITS.Product_Code  
		-- And TS.ItemCode *= TF.ItemCode  
		And TC.CategoryID = ITS.CategoryID  
		Group By  
		-- T.[Description], 
		TS.ItemCode, --TS.CategoryName,
		TS.ItemName,TS.ECP, ITS.UOM2_Conversion,   
		--TF.ItemCode, 
		TC.IDS, ITS.ConversionFactor
		Order By TC.IDS  
	End
	Else
	If @UOM = 'UOM2'
	Begin
		Select 
		"IDS" = TC.IDS,
		"Item CodeH" = IsNull(TS.ItemCode,''), 
		"Item Code" = IsNull(TS.ItemCode,''), 
		"Item Name" = IsNull(TS.ItemName,''),
		"UOM" = IsNull((Select [Description] From UOM Where UOM In (Select uom2 From Items 
		Where Product_code = IsNull(TS.ItemCode,''))), ''),

		"Qty" = Sum(IsNull(TS.Qty, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = TS.ItemCode ), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) End ,

		"Free" = IsNull((Select sum(Qty) From #TempFreeone Where ItemCode = TS.ItemCode and 
		ecp = ts.ecp), 0) / 
		Case IsNull((Select uom2_conversion From Items   
		Where Product_Code = TS.ItemCode and ecp = ts.ecp), 0) When 0 Then 1 Else   
		IsNull((Select uom2_conversion From Items   
		Where Product_Code = TS.ItemCode), 0) End ,  

		"Total Qty" = Sum(IsNull(TS.Qty, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = TS.ItemCode ), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) End +

		IsNull((Select sum(Qty) From #TempFreeone Where ItemCode = TS.ItemCode and 
		ecp = ts.ecp), 0) / 
		Case IsNull((Select uom2_conversion From Items   
		Where Product_Code = TS.ItemCode), 0) When 0 Then 1 Else   
		IsNull((Select uom2_conversion From Items   
		Where Product_Code = TS.ItemCode), 0) End ,  

		"Sch. Disc" = Sum(IsNull(TS.SchemeDiscAmount, 0)),

		"Discount" = Sum(TS.DiscountValue), 

		"VAT/Tax" = Sum(TS.TaxAmt), 

		"Total Value" = Cast(Sum(TS.NetValue)As Decimal(18,6)),

		"Weight(Kg)" = Cast((Sum(IsNull(TS.Qty,0)) + 
		IsNull((Select sum(Qty) From #TempFreeone Where ItemCode = TS.ItemCode and 
		ecp = ts.ecp), 0))
		* IsNull(ITS.ConversionFactor,0) As Decimal(18,6)),   

		"MRP per PAC" = Cast(IsNull(TS.ECP,0) * IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)),

		"Return Saleable" = Sum(IsNull(TS.RetSalable, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) End ,

		"Return Damaged" = Sum(IsNull(TS.RetDamaged, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = TS.ItemCode), 0) End 
		Into #tempUT
		From #Temp T,#TempSaleone TS, --#TempFreeone TF, 
		Items ITS, #tempCategory1 TC  
		Where T.Product_Code = TS.ItemCode  
		And TS.ItemCode = ITS.Product_Code  
		-- And TS.ItemCode *= TF.ItemCode  
		And TC.CategoryID = ITS.CategoryID  
		Group By  
		-- T.[Description], 
		TS.ItemCode, --TS.CategoryName, 
		TS.ItemName,TS.ECP, ITS.UOM2_Conversion,   
		-- TF.ItemCode, 
		TC.IDS, ITS.ConversionFactor
		Order By TC.IDS  
	End

	If @UOM = 'UOM1 & UOM2'
	Begin
		Select 
		"Item Code" = [Item Code], 
		"Category"  = Category,
		"Sub Category" = Sub_Category,
		"Item Code" = [Item Code], 
		"Item Name" = [Item Name],
		"Qty in CFC" = Sum([Qty in CFC]),
		"Qty in PAC" = Sum([Qty in PAC]),
		"Free Qty in PAC" =  Sum([Free Qty in PAC]),
		"Total CFC" = Sum([Total CFC]),
		"Total PAC" = Sum([Total PAC]),
		"Sch. Disc" = Sum([Sch. Disc]),
		"Discount" = Sum([Discount]), 
		"VAT/Tax" = Sum([VAT/Tax]), 
		"Total Value" = Sum([Total Value]),
		"Weight(Kg)" = Sum([Weight(Kg)]),
		"MRP per PAC" = [MRP per PAC],
		"Ret Saleable in PAC" = Sum([Ret Saleable in PAC]),
		"Ret Damaged in PAC" = Sum([Ret Damaged in PAC])
		From  #tempOT t1, #tempDiv t2
		Where t1.[Item Code] = t2.Product_Code
		Group By [Item Code], [Item Name], [MRP per PAC], Category, Sub_Category, [IDS]
		Order By [IDS]		
	End
	Else
	If @UOM = 'Base UOM'
	Begin
		Select 
		"Item Code" = [Item Code],
		"Category"  = Category,
		"Sub Category" = Sub_Category, 
		"Item Code" = [Item Code], 
		"Item Name" = [Item Name],
		"UOM" = [UOM],
		"Qty" = Sum([Qty]),
		"Free" = Sum([Free]),  
		"Total Qty" = Sum([Total Qty]),  
		"Sch. Disc" = Sum([Sch. Disc]),
		"Discount" = Sum([Discount]), 
		"VAT/Tax" = Sum([VAT/Tax]), 
		"Total Value" = Sum([Total Value]),
		"Weight(Kg)" =  Sum([Weight(Kg)]),   
		"MRP per PAC" = [MRP per PAC],
		"Return Saleable" = Sum([Return Saleable]),
		"Return Damaged" = Sum([Return Damaged])
		From #tempB t1, #tempDiv t2
		Where t1.[Item Code] = t2.Product_Code
		Group By  
		[Item Code], [Item Name], [UOM],
		[MRP per PAC], [IDS], Category, Sub_Category
		Order By [IDS]
	End
	Else
	If @UOM = 'UOM1'
	Begin
		Select 
		"Item Code" = [Item Code], 
		"Category"  = Category,
		"Sub Category" = Sub_Category,
		"Item Code" = [Item Code], 
		"Item Name" = [Item Name],
		"UOM" = [UOM],
		"Qty" = Sum([Qty]), 
		"Free" = Sum([Free]),  
		"Total Qty" = Sum([Total Qty]),
		"Sch. Disc" = Sum([Sch. Disc]),
		"Discount" = Sum([Discount]),
		"VAT/Tax" = Sum([VAT/Tax]),
		"Total Value" = Sum([Total Value]),
		"Weight(Kg)" = Sum([Weight(Kg)]),
		"MRP per PAC" = [MRP per PAC],
		"Return Saleable" = Sum([Return Saleable]),
		"Return Damaged" = Sum([Return Damaged])
		From #tempUO t1, #tempDiv t2
		Where t1.[Item Code] = t2.Product_Code
		Group By  
		[Item Code], [Item Name], [UOM], [MRP per PAC],
		[IDS], Category, Sub_Category
		Order By [IDS]
	End
	Else
	If @UOM = 'UOM2'
	Begin
		Select 
		"Item Code" = [Item Code], 
		"Category"  = Category,
		"Sub Category" = Sub_Category,
		"Item Code" = [Item Code], 
		"Item Name" = [Item Name],
		"UOM" = [UOM],
		"Qty" = Sum([Qty]),
		"Free" = Sum([Free]),
		"Total Qty" = Sum([Total Qty]),  
		"Sch. Disc" = Sum([Sch. Disc]),
		"Discount" = Sum([Discount]), 
		"VAT/Tax" = Sum([VAT/Tax]), 
		"Total Value" = sum([Total Value]),
		"Weight(Kg)" = Sum([Weight(Kg)]),   
		"MRP per PAC" = [MRP per PAC],
		"Return Saleable" = Sum([Return Saleable]),
		"Return Damaged" = Sum([Return Damaged])
		From #tempUT t1, #tempDiv t2
		Where t1.[Item Code] = t2.Product_Code
		Group By  
		[Item Code], [Item Name], [UOM], [MRP per PAC],
		[IDS], Category, Sub_Category
		Order By [IDS]
	End

	Drop Table #TempCategory  
	Drop Table #TmpBeat  
	Drop Table #Temp  
	Drop Table #TmpCat
	Drop Table #TempSale
	Drop Table #TempFree
	Drop Table #tempDiv
	
	Drop Table #TmpSRInvoiceID
End
