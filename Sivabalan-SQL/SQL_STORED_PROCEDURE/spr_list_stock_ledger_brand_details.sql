CREATE PROCEDURE [dbo].[spr_list_stock_ledger_brand_details](@BRAND int, @FROM_DATE datetime,   
 @ShowItems nvarchar(50), @StockVal nvarchar(100))

AS            
--Declare @Delimeter as Char(1)    
--Set @Delimeter=Char(15)    
--Declare @tmpProd table(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
--  
--if @ItemCode = N'%'  
-- Insert InTo @tmpProd Select Product_code From Items  
--Else  
-- Insert into @tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)  

--This table is to display the categories in the Order
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)  
Exec sp_CatLevelwise_ItemSorting 

  
IF (DATEPART(dy, @FROM_DATE) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FROM_DATE) = DATEPART(yyyy, GETDATE())) OR DATEPART(yyyy, @FROM_DATE) < DATEPART(yyyy, GETDATE())        
BEGIN   
	----
	create table #tmptotal_Invd_qty( 	
		product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		,Invoiced_qty decimal(18, 6) Default 0
		)

	create table #tmptotal_rcvd_qty( 		
		product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		, rcvdqty decimal(18, 6) Default 0
		, freeqty decimal(18, 6) Default 0
		)

	create table #tmptotal_Invd_Saleonly_qty( 
		product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		, Saleableonly_qty decimal(18, 6)  Default 0
		)	   
		
    -- total_Invoiced_qty(Saleable+Free)
	Insert Into #tmptotal_Invd_qty
	select Items.Product_Code, isnull(sum(IDR.quantity), 0) from
		Items 
		left outer join InvoiceDetailReceived IDR on IDR.product_code = Items.product_code		
		left outer join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
		where IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE) 
		and IAR.Invoicetype = 0 
		group by Items.product_code 
	------

	-- total_received_qty(Saleable), total_received_qty(Free)
	Insert Into #tmptotal_rcvd_qty
	select tmp.product_code, IsNull(sum(gdt.quantityreceived), 0), IsNull(sum(gdt.Freeqty), 0) from Items tmp
	left outer join 
		( select IsNull(gdt.quantityreceived, 0) as quantityreceived, 
		IsNull(gdt.freeqty, 0) as freeqty, gdt.product_code as product_code
		from grndetail gdt 
		join grnabstract gab on gab.grnId = gdt.grnId and gab.grnstatus = 1 and gab.RecdInvoiceId in 
		(	select InvoiceId from Invoiceabstractreceived IAR 
			where IAR.Status & 64 = 0 And IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE) 
			and IAR.Invoicetype = 0 
		)
		) gdt on gdt.product_code = tmp.product_code
	group by tmp.product_code



	-- total_Invoiced_Saleableonly_qty
	Insert Into #tmptotal_Invd_Saleonly_qty
	select Items.product_code, IsNull(sum(IDR.quantity), 0) from Items
		left outer join InvoiceDetailReceived IDR on IDR.product_code = Items.product_code 
		left outer join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId			
		where IAR.Status & 64 = 0 And IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE) 
			and IDR.product_code = Items.Product_code and IAR.Invoicetype = 0 
			and IDR.Saleprice > 0 
		group by Items.product_code 

	  -----		      

 IF @ShowItems = N'Items with stock'        
 begin        
  Select  Items.Product_Code,           
   "Item Code" = Items.Product_Code,             
   "Item Name" = Items.ProductName,             
   "Total On Hand Qty" = CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) AS nvarchar)   + N' ' + CAST(ISNULL(UOM.Description,N'') AS nvarchar),             
	---- Total SIT Qty
	 "Total SIT Qty" = CAST(ISNull(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty ,0) AS nvarchar) + ' ' + Cast(IsNull(UOM.Description,'') As NVarChar),           
    ----		
   "Conversion Unit" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) * Items.ConversionFactor AS Decimal(18,6)) AS nvarchar)   + N' ' + CAST(isnull(ConversionTable.ConversionUnit, N'') AS nvarchar),    
    "Reporting UOM" = Cast(dbo.sp_Get_ReportingQty(OpeningDetails.Opening_Quantity, Items.ReportingUnit) As nvarchar) --(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)           
      + N' ' + CAST((SELECT isnull(Description, N'') FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),            
	"Total On Hand Value" =       
	case @StockVal        
	When N'PTS' Then       
		((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTS, 0)))            
	When N'PTR' Then       
		((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTR, 0)))            
	When N'ECP' Then       
		((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))            
	When N'MRP' Then       
		((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))            
	When N'Special Price' Then       
		((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))            
	Else      
		(ISNULL(OpeningDetails.Opening_Value, 0))          
	End,  
	---- Total SIT Value
	"Total SIT Value" =     
	case @StockVal      
	When 'PTS' Then  ((IsNull(tmpInvqty.Invoiced_qty,0) - IsNull(tmprcvdqty.rcvdqty, 0) - IsNull(tmprcvdqty.freeqty, 0) * Isnull(Items.PTS, 0)))          
	When 'PTR' Then  ((IsNull(tmpInvqty.Invoiced_qty,0) - IsNull(tmprcvdqty.rcvdqty, 0) - IsNull(tmprcvdqty.freeqty, 0) * Isnull(Items.PTR, 0)))          
	When 'ECP' Then  ((ISNull(tmpInvqty.Invoiced_qty,0) - IsNull(tmprcvdqty.rcvdqty, 0) - IsNull(tmprcvdqty.freeqty, 0) * Isnull(Items.ECP, 0)))          
	When 'MRP' Then  ((IsNull(tmpInvqty.Invoiced_qty,0) - IsNull(tmprcvdqty.rcvdqty, 0) - IsNull(tmprcvdqty.freeqty, 0) * Isnull(Items.MRP, 0)))          
	When 'Special Price' Then ((Isnull(tmpInvqty.Invoiced_qty,0) - IsNull(tmprcvdqty.rcvdqty,0) - IsNull(tmprcvdqty.freeqty, 0) * Isnull(Items.Company_Price, 0)))          
	Else  (IsNull(tmpInvqty.Invoiced_qty,0) - IsNull(tmprcvdqty.rcvdqty,0) - IsNull(tmprcvdqty.freeqty ,0))
	End,
	----
   "Saleable Stock" = (isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),          
	---- Saleable SIT Qty
	"Saleable SIT Qty" =(IsNull(tmpInvdSaleqty.Saleableonly_qty,0) - IsNull(tmprcvdqty.rcvdqty,0)),	  
	----
    "Saleable Value" =       
	case @StockVal        
	When N'PTS' Then       
	(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.PTS, 0))  - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTS, 0))          
	When N'PTR' Then       
	(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.PTR, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTR, 0))          
	When N'ECP' Then       
	(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.ECP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))          
	When N'MRP' Then       
	(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.MRP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))          
	When N'Special Price' Then       
	(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Company_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))          
	Else      
	(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))      
	End,    
	  ----Saleable SIT Value 
	"Saleable SIT Value" =       
	 case @StockVal        
	 When 'PTS' Then (IsNull(tmpInvdSaleqty.Saleableonly_qty,0)  - IsNull(tmprcvdqty.rcvdqty , 0) * Isnull(Items.PTS, 0))          
	 When 'PTR' Then (IsNull (tmpInvdSaleqty.Saleableonly_qty,0) - IsNull(tmprcvdqty.rcvdqty , 0) * Isnull(Items.PTR, 0))          
	 When 'ECP' Then (IsNull (tmpInvdSaleqty.Saleableonly_qty,0) - IsNull(tmprcvdqty.rcvdqty , 0) * Isnull(Items.ECP, 0))          
	 When 'MRP' Then (IsNull (tmpInvdSaleqty.Saleableonly_qty,0) - IsNull(tmprcvdqty.rcvdqty , 0) * Isnull(Items.MRP, 0))          
	 When 'Special Price' Then (IsNull(tmpInvdSaleqty.Saleableonly_qty,0) -IsNull(tmprcvdqty.rcvdqty,0) * Isnull(Items.Company_Price, 0))          
	 Else (IsNull(tmpInvdSaleqty.Saleableonly_qty,0) - IsNull(tmprcvdqty.rcvdqty,0 ) * Isnull(Items.PTS, 0))      
	 End,    
	----  
   "Free OnHand Qty" = isnull(openingdetails.Free_Saleable_Quantity, 0),  

	---- Free SIT Qty
		"Free SIT Qty" = IsNull(((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - (tmprcvdqty.freeqty)),0),        
	--"Free SIT Qty" = (tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty, 
	----              
   "Damages Qty" = isnull(openingdetails.Damage_Opening_Quantity,0),            
    "Damages Value" =       
	case @StockVal        
	When N'PTS' Then       
		isnull((isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTS, 0)), 0)          
	When N'PTR' Then      
		isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTR, 0)), 0)          
	When N'ECP' Then      
		isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)          
	When N'MRP' Then      
		isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)          
	When N'Special Price' Then   
		isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)          
	Else      
		isnull((openingdetails.Damage_Opening_Value), 0)          
	End      
	from    Items
	Inner Join  OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
	Left Outer Join UOM On Items.UOM = UOM.UOM
	Left Outer Join conversionTable On Items.ConversionUnit = ConversionTable.ConversionID        
	--
	Left Outer Join #tmptotal_Invd_qty tmpInvqty On Items.Product_Code = tmpInvqty.Product_Code
	Left Outer Join #tmptotal_rcvd_qty tmprcvdqty On Items.Product_Code = tmprcvdqty.Product_Code
	Left Outer Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty On Items.Product_Code = tmpInvdSaleqty.Product_Code
	Inner Join #tempCategory1 T1 On Items.CategoryID = T1.CategoryID                  
	--            
	WHERE   
	ISNULL(OpeningDetails.Opening_Quantity, 0) > 0        
	AND Items.BrandID = @BRAND            
	AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)            
	--AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd) 
	--   and items.active = 1        
	Order by T1.IDS
	end        
else        
 begin        
  Select  Items.Product_Code,           
   "Item Code" = Items.Product_Code,             
   "Item Name" = Items.ProductName,             
   "Total On Hand Qty" = CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) AS nvarchar)   + N' ' + CAST(ISNULL(UOM.Description,N'') AS nvarchar),             
	----Total SIT Qty
	"Total SIT Qty" = CAST(ISNULL(tmpInvqty.Invoiced_qty,0) - IsNull(tmprcvdqty.rcvdqty,0) - IsNull(tmprcvdqty.freeqty,0) AS nvarchar)   + ' ' + Cast(IsNull(UOM.Description,'') As NVarChar),         	 
	----	
   "Conversion Unit" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) * Items.ConversionFactor AS Decimal(18,6)) AS nvarchar)   + N' ' + CAST(isnull(ConversionTable.ConversionUnit, N'') AS nvarchar),            
   "Reporting UOM" = Cast(dbo.sp_Get_ReportingQty(OpeningDetails.Opening_Quantity, Items.ReportingUnit) As nvarchar) --(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)           
   + N' ' + CAST((SELECT isnull(Description, N'') FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),            
  
--    "Reporting UOM" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)           
--      + ' ' + CAST((SELECT isnull(Description, '') FROM UOM WHERE UOM = Items.ReportingUOM) AS nvarchar),            
  "Total On Hand Value" =       
  case @StockVal        
  When N'PTS' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTS, 0)))            
  When N'PTR' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTR, 0)))            
  When N'ECP' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))            
  When N'MRP' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))            
  When N'Special Price' Then       
  ((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))            
  Else      
  (ISNULL(OpeningDetails.Opening_Value, 0))          
  End, 
	 ---Total On SIT Value
	"Total SIT Value" =     
	 case @StockVal      
	 When 'PTS' Then ((IsNull(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0) * Isnull(Items.PTS, 0)))          
	 When 'PTR' Then ((IsNull(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0) * Isnull(Items.PTR, 0)))          
	 When 'ECP' Then ((IsNull(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0) * Isnull(Items.ECP, 0)))          
	 When 'MRP' Then ((IsNull(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty, 0) * Isnull(Items.MRP, 0)))          
	 When 'Special Price' Then  ((IsNull(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty ,0) * Isnull(Items.Company_Price, 0)))          
	 Else (IsNull(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty,0)* Isnull(Items.PTS, 0) )    
	 End,
	----	    
   "Saleable Stock" = (isnull(openingdetails.Opening_Quantity,0) - isnull(openingdetails.Free_Saleable_Quantity,0) - isnull(openingdetails.Damage_Opening_Quantity,0)),          
	----Saleable SIT Qty
	"Saleable SIT Qty" = (IsNull(tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty,0)),
	---
    "Saleable Value" =       
	case @StockVal        
	When N'PTS' Then       
		(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.PTS, 0))  - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTS, 0))          
	When N'PTR' Then       
		(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.PTR, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTR, 0))          
	When N'ECP' Then       
		(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.ECP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))          
	When N'MRP' Then       
		(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.MRP, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))          
	When N'Special Price' Then       
		(isnull(openingdetails.Opening_Quantity,0) * Isnull(Items.Company_Price, 0)) - (isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))          
	Else      
		(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))      
	End,      
	----Saleable SIT Value
   "Saleable SIT Value" =       
	 case @StockVal  
	 When 'PTS' Then (IsNull(tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty, 0) * Isnull(Items.PTS, 0))          
	 When 'PTR' Then (IsNull(tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty, 0) * Isnull(Items.PTR, 0))          
	 When 'ECP' Then (IsNull(tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty, 0) * Isnull(Items.ECP, 0))          
	 When 'MRP' Then (IsNull(tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty, 0) * Isnull(Items.MRP, 0))          
	 When 'Special Price' Then   (IsNull(tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty , 0) * Isnull(Items.Company_Price, 0) )          
	 Else  (IsNull(tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty,0 )* Isnull(Items.PTS, 0))    
	 End, 
   "Free OnHand Qty" = isnull(openingdetails.Free_Saleable_Quantity, 0),            
	---- Free SIT Qty
	"Free SIT Qty" = IsNull((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - (tmprcvdqty.freeqty),0),              
	--"Free SIT Qty" = (tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty, 
	----
   "Damages Qty" = isnull(openingdetails.Damage_Opening_Quantity,0),            
    "Damages Value" =       
	case @StockVal        
	When N'PTS' Then       
		isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTS, 0)), 0)          
	When N'PTR' Then      
		isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTR, 0)), 0)          
	When N'ECP' Then      
		isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)          
	When N'MRP' Then      
		isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)          
	When N'Special Price' Then      
		isnull((Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)          
	Else      
		isnull((openingdetails.Damage_Opening_Value), 0)          
	End      
	from    Items
	Inner Join OpeningDetails On  Items.Product_Code = OpeningDetails.Product_Code
	Left Outer Join UOM On Items.UOM = UOM.UOM
	Left Outer Join conversionTable On Items.ConversionUnit = ConversionTable.ConversionID                  
	----
	Left Outer Join #tmptotal_Invd_qty tmpInvqty On Items.Product_Code = tmpInvqty.Product_Code
	Left Outer Join #tmptotal_rcvd_qty tmprcvdqty On Items.Product_Code = tmprcvdqty.Product_Code 
	Left Outer Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty On  Items.Product_Code = tmpInvdSaleqty.Product_Code
	Inner Join #tempCategory1 T1 On Items.CategoryID = T1.CategoryID      
	----	
	WHERE   
	Items.BrandID = @BRAND  
   --AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)  
   AND OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)            
--   and items.active = 1         
	Order by T1.IDS
 end        
END            
ELSE            
BEGIN          
 IF @ShowItems = N'Items with stock'        
 begin        
  Select  a.Product_Code,            
   "Item Code" = a.Product_Code,           
   "Item Name" = a.ProductName,             
   "Total On Hand Qty" = CAST(ISNULL(SUM(Quantity), 0) AS nvarchar)  + N' ' + CAST(ISNULL(UOM.Description,N'') AS nvarchar),             
   --Total SIT Qty	  
	"Total SIT Qty" =  (select CAST(ISNULL(SUM(IDR.Pending), 0) AS nvarchar) from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items  Where Items.Product_Code = IDR.Product_Code  And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 = 0 And  Items.BrandID = @Brand And Items.Product_Code = a.Product_Code )  + N' ' +  CAST(ISNULL(UOM.Description,N'') AS nvarchar),  	
   	"Conversion Unit" = CAST(CAST(ISNULL(SUM(Quantity), 0) * a.ConversionFactor AS Decimal(18,6)) AS nvarchar)   + N' ' + CAST(isnull(ConversionTable.ConversionUnit, N'') AS nvarchar),            
	"Reporting UOM" = Cast(dbo.sp_Get_ReportingQty(SUM(IsNull(Quantity,0)), a.ReportingUnit) As nvarchar) --(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)           
   + N' ' + CAST((SELECT isnull(Description, N'') FROM UOM WHERE UOM = a.ReportingUOM) AS nvarchar),            
  
--    "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE a.ReportingUnit WHEN 0 THEN 1 ELSE a.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)   + ' ' + CAST((SELECT isnull(Description, '') FROM UOM WHERE UOM = a.ReportingUOM) AS nvarchar),    
       
 "Total On Hand Value" =         
  case @StockVal        
  When N'PTS'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.PTS, 0)) End) End)  
  When N'PTR' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.PTR, 0)) End) End)  
  When N'ECP' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.ECP, 0)) End) End)  
  When N'MRP' Then      
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(a.MRP, 0)End)),0)       
  When N'Special Price' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Company_Price, 0)) End) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End,      

 --Total SIT Value		
  "Total SIT Value" = Isnull((Select         
  case @StockVal        
  When N'PTS'  Then 
	Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTS, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0)) End) End)
	       
  When N'PTR' Then      
	Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTR, 0))Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0)) End) End) 	
  When N'ECP' Then  
	Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0)) End) End)	
  When N'MRP' Then 		       
	isnull(Sum((Case (IDR.SalePrice) When 0 Then 0 Else isnull(IDR.Pending, 0) * isnull(Items.MRP, 0)End)),0)       	   	      
  When N'Special Price' Then  
	Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.Company_Price, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0)) End) End)
 Else      
	isnull(Sum(isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)),0)          
  End   
	from InvoiceDetailReceived IDR, InvoiceAbstractReceived IAR, Items, ItemCategories IC 
	where  Items.CategoryID = IC.CategoryID 
	And Items.Product_Code = IDR.Product_Code 
    And IDR.InvoiceID = IAR.InvoiceID
    And IAR.Status & 64 = 0
	And Items.BrandID = @Brand
	And Items.Product_Code = a.Product_Code),0), 
	    
   "Saleable Stock" = isnull((select Sum(Quantity) from batch_products, Items where Items.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And Items.BrandID = @Brand And Items.Product_Code = a.Product_Code),0),     

	--Saleable SIT
  	"Saleable SIT" = isnull((select Sum(IDR.Pending) from InvoiceDetailReceived IDR, Items, InvoiceAbstractReceived IAR 
	 where Items.Product_Code = IDR.Product_Code 
     And IDR.InvoiceID = IAR.InvoiceID
     And IAR.Status & 64 = 0
	 And Items.BrandID = @Brand 
	 And Items.Product_Code = a.Product_Code
	 And isnull (IDR.SalePrice,0) > 0),0), 

   "Saleable Value" = Isnull((Select         
	case @StockVal        
	When N'PTS'  Then      
		Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End)  
	When N'PTR' Then      
		Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End)  
	When N'ECP' Then      
		Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
	When N'MRP' Then      
		isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
	When N'Special Price' Then      
		Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
	Else      
		isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
	End       
	from batch_products, Items, ItemCategories IC         
     where 
	 isnull(free,0)=0 
	 and isnull(damage,0) = 0 
	 And Items.BrandID = @Brand 
	 and Items.CategoryID = IC.CategoryID 
	 AND Items.Product_Code = Batch_Products.Product_Code 
	 And Items.Product_Code = a.Product_Code
	 ),0),          
	
	-- Salable SIT Value 
	"Saleable SIT Value" = Isnull((Select             
	case @StockVal            
	When 'PTS'  Then          
		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTS, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0)) End)      
	When 'PTR' Then          
		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTR, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0)) End)      
	When 'ECP' Then          
		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0)) End)      
	When 'MRP' Then          
		isnull(Sum(isnull(IDR.Pending, 0) * isnull(Items.MRP, 0)),0)           
	When 'Special Price' Then          
		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.Company_Price, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0)) End)      
	Else          
		isnull(Sum(isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)),0)              
	End           
	from InvoiceDetailReceived IDR, Items, ItemCategories IC, InvoiceAbstractReceived IAR
	where 	
	Items.BrandID = @Brand
	And Items.CategoryID = IC.CategoryID 
	And Items.Product_Code = IDR.Product_Code 
    And IDR.InvoiceID = IAR.InvoiceID
    And IAR.Status & 64 = 0
	And Items.Product_Code = a.Product_Code
	And IDR.SalePrice > 0),0),        	

   "Free OnHand Qty" = isnull((select sum(Quantity) from Batch_Products, Items 
   where 
   free <> 0 
   And IsNull(Damage, 0) <> 1 
   And Items.BrandID = @Brand 
   and Items.Product_Code = Batch_Products.Product_Code 
   And Items.Product_Code = a.Product_Code
   ),0),         
   
	-- Free SIT QTY
	"Free SIT Qty" = isnull((select sum(IDR.Pending) from InvoiceDetailReceived IDR, Items, InvoiceAbstractReceived IAR
	where Items.BrandID = @Brand 
	And Items.Product_Code = IDR.Product_Code 
    And IDR.InvoiceID = IAR.InvoiceID
    And IAR.Status & 64 = 0
	And Items.Product_Code = a.Product_Code
	And IDR.SalePrice = 0 ),0),

   "Damages Qty" = isnull((select sum(Quantity) from Batch_Products, Items 
   where 
   damage <> 0 
   And Items.BrandID = @Brand 
   and Items.Product_Code = Batch_Products.Product_Code 
   And Items.Product_Code = a.Product_Code
   ), 0),           
  "Damages Value" = isnull((select        
  case @StockVal        
  When N'PTS'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End)  
  When N'PTR' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End)  
  When N'ECP' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
  When N'MRP' Then      
     Sum(Case IsNull(Free, 0) When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0) End )  
  When N'Special Price' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End      
from Batch_Products, Items, ItemCategories IC 
where 
damage <> 0 
And Items.BrandID = @Brand 
and Items.CategoryID = IC.CategoryID 
AND Items.Product_Code = Batch_Products.Product_Code 
And Items.Product_Code = a.Product_Code
),  0)          
  from Items a
  Left Outer Join Batch_Products On a.Product_Code = Batch_Products.Product_Code
  Left Outer Join  UOM On a.UOM = UOM.UOM
  Left Outer Join ConversionTable On a.ConversionUnit = ConversionTable.ConversionID
  Inner Join ItemCategories IC On  a.CategoryID = IC.CategoryID 
  Inner Join #tempCategory1 T1 On a.CategoryId = T1.CategoryID
  WHERE 
   a.BrandID = @BRAND               
  GROUP BY T1.IDS, a.Product_Code, a.ProductName, a.UOM, a.ConversionUnit,            
   a.ConversionFactor, a.ReportingUnit, a.ReportingUOM, ConversionTable.ConversionUnit,            
   UOM.Description            
   HAVING ISNULL(SUM(QUANTITY), 0) > 0        
  Order By T1.IDS
 end        
 else        
 begin   
      
  Select  a.Product_Code,            
   "Item Code" = a.Product_Code,           
   "Item Name" = a.ProductName,             
   "Total On Hand Qty" = CAST(ISNULL(SUM(Quantity), 0) AS nvarchar)  + N' ' + CAST(ISNULL(UOM.Description,N'') AS nvarchar),             
	--Total SIT Qty		
	--"Total SIT Qty" =  isnull((select (CAST(ISNULL(SUM(IDR.Pending), 0) AS nvarchar)  + N' ' + CAST(ISNULL(UOM.Description,N'') AS nvarchar)) from InvoiceDetailReceived IDR ,Items, UOM  Where Items.Product_Code = IDR.Product_Code  And  Items.BrandID = @Brand And Items.UOM = UOM.UOM  And Items.Product_Code = a.Product_Code group By UOM.Description),0),              
	"Total SIT Qty" =  (select CAST(ISNULL(SUM(IDR.Pending), 0) AS nvarchar) from InvoiceDetailReceived IDR ,Items, InvoiceAbstractReceived IAR  Where Items.Product_Code = IDR.Product_Code  And IDR.InvoiceID = IAR.InvoiceID And IAR.Status & 64 =0 And  Items.BrandID = @Brand And Items.Product_Code = a.Product_Code )  + N' ' +  CAST(ISNULL(UOM.Description,N'') AS nvarchar),
	-----
   "Conversion Unit" = CAST(CAST(ISNULL(SUM(Quantity), 0) * a.ConversionFactor AS Decimal(18,6)) AS nvarchar)   + N' ' + CAST(isnull(ConversionTable.ConversionUnit, N'') AS nvarchar),            
    "Reporting UOM" = Cast(dbo.sp_Get_ReportingQty(SUM(IsNull(Quantity,0)), a.ReportingUnit) As nvarchar) --(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)           
   + N' ' + CAST((SELECT isnull(Description, N'') FROM UOM WHERE UOM = a.ReportingUOM) AS nvarchar),            

	  --   "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE a.ReportingUnit WHEN 0 THEN 1 ELSE a.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)   + ' ' + CAST((SELECT isnull(Description, '') FROM UOM WHERE UOM = a.ReportingUOM) AS nvarchar),     
      
 "Total On Hand Value" =         
  case @StockVal        
  When N'PTS'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.PTS, 0)) End) End)  
  When N'PTR' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.PTR, 0)) End) End)  
  When N'ECP' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.ECP, 0)) End) End)  
  When N'MRP' Then    
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(a.MRP, 0)End)),0)       
  When N'Special Price' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Company_Price, 0)) End) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End,        

  --Total SIT Value
 "Total SIT Value" = Isnull((Select         
  case @StockVal        
  When N'PTS'  Then 
	Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTS, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0))End) End) 
  When N'PTR' Then      
	Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTR, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0))End) End) 	
  When N'ECP' Then  
	Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0))End) End)      
  When N'MRP' Then 	
	isnull(Sum((Case (IDR.SalePrice) When 0 then 0 Else isnull(IDR.Pending, 0) * Isnull(Items.MRP, 0)  End)),0)           	
  When N'Special Price' Then  
	Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.Company_Price, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0))End) End)      	
  Else      
	isnull(Sum(isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)),0)           	
  End   
	from InvoiceDetailReceived IDR, Items, ItemCategories IC, InvoiceAbstractReceived IAR
	where  Items.CategoryID = IC.CategoryID 
	And Items.Product_Code = IDR.Product_Code 
    And IDR.InvoiceID = IAR.InvoiceID
    And IAR.Status & 64 = 0
	And Items.BrandID = @Brand
	And Items.Product_Code = a.Product_Code),0), 
	
	
   "Saleable Stock" = isnull((select Sum(Quantity) from batch_products, Items 
   where 
   isnull(free,0)=0 
   and isnull(damage,0) = 0 
   And Items.BrandID = @Brand 
   and Items.Product_Code = Batch_Products.Product_Code 
   And Items.Product_Code = a.Product_Code
   ),0),     
	
   --Saleable SIT
  "Saleable SIT" = isnull((select Sum(IDR.Pending) from InvoiceDetailReceived IDR, Items, InvoiceAbstractReceived IAR
   where Items.Product_Code = IDR.Product_Code 
   And IDR.InvoiceID = IAR.InvoiceID
   And IAR.Status & 64 = 0
   And Items.BrandID = @Brand 
   And Items.Product_Code = a.Product_Code
  And isnull (IDR.SalePrice,0) > 0),0), 	


  "Saleable Value" = Isnull((Select         
  case @StockVal        
  When N'PTS'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End)  
  When N'PTR' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End)  
  When N'ECP' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
  When N'MRP' Then      
  isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)       
  When N'Special Price' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End        
 from batch_products, Items, ItemCategories IC         
     where 
	 isnull(free,0)=0 and         
     isnull(damage,0) = 0 
	 And Items.BrandID = @Brand 
	 and Items.CategoryID = IC.CategoryID 
	 And Items.Product_Code = Batch_Products.Product_Code 
	 And Items.Product_Code = a.Product_Code
	 )  ,0),  

	--Saleable SIT Value
	"Saleable SIT Value" = Isnull((Select    
	case @StockVal            
	When 'PTS'  Then          		 
		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTS, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0)) End)      		
	When 'PTR' Then          		
		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTR, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0)) End)      
	When 'ECP' Then          
		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0)) End)      
	When 'MRP' Then          
		isnull(Sum(isnull(IDR.Pending, 0) * isnull(Items.MRP, 0)),0)           
	When 'Special Price' Then          
		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.Company_Price, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0)) End)      
	Else          
		isnull(Sum(isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)),0)              
	End           
	from InvoiceDetailReceived IDR, Items, ItemCategories IC, InvoiceAbstractReceived IAR
	where 	
	Items.BrandID = @Brand
	And Items.CategoryID = IC.CategoryID 
	And Items.Product_Code = IDR.Product_Code 
    And IDR.InvoiceID = IAR.InvoiceID
    And IAR.Status & 64 = 0
	And Items.Product_Code = a.Product_Code
	And IDR.SalePrice > 0
	),0),        	

        
   "Free OnHand Qty" = isnull((select sum(Quantity) from Batch_Products, Items 
   where 
   free <> 0 And IsNull(Damage, 0) <> 1 
   And Items.BrandID = @Brand 
   and Items.Product_Code = Batch_Products.Product_Code 
   And Items.Product_Code = a.Product_Code
   ),0),     

   -- Free SIT QTY	       
   "Free SIT Qty" = isnull((select sum(IDR.Pending) from InvoiceDetailReceived IDR, Items, InvoiceAbstractReceived IAR
    where Items.BrandID = @Brand 
	And Items.Product_Code = IDR.Product_Code 
    And IDR.InvoiceID = IAR.InvoiceID
    And IAR.Status & 64 = 0
	And Items.Product_Code = a.Product_Code
	And IDR.SalePrice = 0 ),0),	

   "Damages Qty" = isnull((select sum(Quantity) from Batch_Products, Items 
   where 
   damage <> 0 And Items.BrandID = @Brand 
   and Items.Product_Code = Batch_Products.Product_Code 
   And Items.Product_Code = a.Product_Code), 0),           
  "Damages Value" = isnull((select        
  case @StockVal        
  When N'PTS'  Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End)  
  When N'PTR' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End)  
  When N'ECP' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)  
  When N'MRP' Then      
  Sum(Case IsNull(Free, 0) When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0) End )  
  When N'Special Price' Then      
  Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)  
  Else      
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)          
  End       
from Batch_Products, Items, ItemCategories IC where Items.CategoryID = IC.CategoryID AND Items.Product_Code = Batch_Products.Product_Code and damage <> 0 And Items.BrandID = @Brand And Items.Product_Code = a.Product_Code),  0)          
  from Items a
  Left Outer Join  Batch_Products On a.Product_Code = Batch_Products.Product_Code
  Left Outer Join UOM On a.UOM = UOM.UOM
  Left Outer Join ConversionTable On a.ConversionUnit = ConversionTable.ConversionID
  Inner Join ItemCategories IC On a.CategoryID = IC.CategoryID
  Inner Join #tempCategory1  T1  On  a.CategoryID = T1.CategoryID        
  WHERE 
  a.BrandID = @BRAND              
  GROUP BY T1.IDS,
   a.Product_Code, a.ProductName, a.UOM, a.ConversionUnit,            
   a.ConversionFactor, a.ReportingUnit, a.ReportingUOM, ConversionTable.ConversionUnit,            
   UOM.Description 
  Order By T1.IDS           
 end        
END

