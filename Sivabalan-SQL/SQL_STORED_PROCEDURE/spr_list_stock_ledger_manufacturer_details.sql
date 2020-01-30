CREATE PROCEDURE spr_list_stock_ledger_manufacturer_details(@MANUFACTURER int,         
 @FROM_DATE datetime, @UnUsed nvarchar(50), @StockVal nvarchar(100),        
 @ItemCode nvarchar(2550), @ItemName nvarchar(255))                  
AS                  
        
Declare @Delimeter as Char(1)          
Set @Delimeter=Char(15)    
        
Declare @tmpProd table(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
        
if @ItemCode = N'%'        
 Insert InTo @tmpProd Select Product_code From Items        
Else        
 Insert into @tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)        

--This table is to display the categories in the Order
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)  
Exec sp_CatLevelwise_ItemSorting 

IF (DATEPART(dy, @FROM_DATE) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FROM_DATE) = DATEPART(yyyy, GETDATE())) OR DATEPART(yyyy, @FROM_DATE) < DATEPART(yyyy, GETDATE())                
BEGIN           
 --previous date start--
	print ('previous date')
	----
	create table #tmptotal_Invd_qty( 
		product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		, Invoiced_qty decimal(18, 6)
		)

	create table #tmptotal_rcvd_qty( 
		product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		, rcvdqty decimal(18, 6)
		, freeqty decimal(18, 6)
		)

	create table #tmptotal_Invd_Saleonly_qty( 
		product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		, Saleableonly_qty decimal(18, 6)
		)

--total_Invoiced_qty(Saleable+Free)
Insert Into #tmptotal_Invd_qty
select tmp.product_code, isnull(sum(IDR.quantity), 0) 
	from @tmpProd tmp left outer join 
	( select IDR.product_code as product_code, idr.quantity as quantity 
		from InvoiceDetailReceived IDR join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
		where IAR.Status & 64 = 0 and  IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE) 
		and IAR.Invoicetype = 0 
	) idr on IDR.product_code = tmp.product_code
	group by tmp.product_code 


--total_received_qty(Saleable), total_received_qty(Free)
Insert Into #tmptotal_rcvd_qty
select tmp.product_code, isnull(sum(gdt.quantityreceived),0), isnull(sum(gdt.Freeqty),0)
	from @tmpProd tmp left outer join 
	( select IsNull(gdt.quantityreceived, 0) as quantityreceived, 
		IsNull(gdt.freeqty, 0) as freeqty, gdt.product_code as product_code
		from grndetail gdt 
		join grnabstract gab on gab.grnId = gdt.grnId and gab.grnstatus = 1 and gab.RecdInvoiceId in 
		(	select InvoiceId from Invoiceabstractreceived IAR 
			where  IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE) 
			and IAR.Invoicetype = 0 
		)
		where gab.GrnDate < dateadd(d, 1, @FROM_DATE) 
	) gdt on gdt.product_code = tmp.product_code
group by tmp.product_code

-- total_Invoiced_Saleableonly_qty
Insert Into #tmptotal_Invd_Saleonly_qty
select tmp.product_code, isnull(sum(IDR.quantity), 0) 
	from @tmpProd tmp left outer join 
	( select IDR.product_code as product_code, idr.quantity as quantity 
		from InvoiceDetailReceived IDR join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
		where  IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE) 
		and IAR.Invoicetype = 0 and IDR.Saleprice > 0 
	) idr on IDR.product_code = tmp.product_code
	group by tmp.product_code 



Select  Items.Product_Code,                 
 "Item Code" = Items.Product_Code,                   
 "Item Name" = Items.ProductName,                   
 "Total On Hand Qty" = CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) AS nvarchar)   + N' ' + CAST(UOM.Description AS nvarchar),                   
 ----
  "Total SIT Qty" = CAST( tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty AS nvarchar)         
  + ' ' +  CAST(UOM.Description AS nvarchar) ,         
 ----
 "Conversion Unit" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) * Items.ConversionFactor AS Decimal(18,6)) AS nvarchar)   + N' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),                  
 "Reporting UOM" = Cast(dbo.sp_Get_ReportingQty(OpeningDetails.Opening_Quantity, Items.ReportingUnit) As nvarchar) + N' ' + CAST((SELECT Description               
   From UOM Where UOM = Items.ReportingUOM) AS nvarchar),                  
-- "Reporting UOM" = CAST(CAST(ISNULL(OpeningDetails.Opening_Quantity, 0) / (CASE Items.ReportingUnit WHEN 0 THEN 1 ELSE Items.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)   + N' ' + CAST((SELECT Description               
--   From UOM Where UOM = Items.ReportingUOM) AS nvarchar),                  
  "On Hand Value" =             
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
 ----
  "Total SIT Value" =     
	 case @StockVal      
	 When 'PTS' Then     
	 ( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.PTS, 0) )          
	 When 'PTR' Then     
	 ( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.PTR, 0) )          
	 When 'ECP' Then     
	 ( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.ECP, 0) )          
	 When 'MRP' Then     
	 ( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.MRP, 0) )          
	 When 'Special Price' Then     
	 ( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.Company_Price, 0) )          
	 Else    
	 ( (tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty) * Isnull(Items.PTS, 0) )          
	 End,
 ----
 
 "Tax Suffered (%)" = IsNull(OpeningDetails.TaxSuffered_Value,0),            
 "Tax Suffered" = ISNULL(OpeningDetails.Opening_Value * (OpeningDetails.TaxSuffered_Value/100), 0),            
  "Total On Hand Value" =                     
  case @StockVal                        
  When N'PTS' Then                       
  Cast(ISNULL((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTS, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTS, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))                  

  
  When N'PTR' Then                       
  Cast(ISNULL((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTR, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTR, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))                  

  
  When N'ECP' Then                       
  Cast(ISNULL((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))                  

  
  When N'MRP' Then                       
  Cast(ISNULL((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))     
When N'Special Price' Then                       
  Cast(ISNULL((ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18, 
6))                    
  Else                    
  Cast(ISNULL((OpeningDetails.Opening_Value + (OpeningDetails.Opening_Value * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))                    
  End,             
 "Saleable Stock" = (ISNULL(openingdetails.Opening_Quantity,0) - ISNULL(openingdetails.Free_Saleable_Quantity,0) - ISNULL(openingdetails.Damage_Opening_Quantity,0)),                
 ----
  "Saleable SIT Qty" = (tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),
 ----
 "Saleable Value" =                 
 case @StockVal                  
 When N'PTS' Then                 
 (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTS, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTS, 0))                    
 When N'PTR' Then                 
 (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTR, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTR, 0))                    
 When N'ECP' Then                 
 (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))                    
 When N'MRP' Then                 
 (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))                    
 When N'Special Price' Then                 
 (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))                    
 Else                
 (isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))                
 End,                
 "Free OnHand Qty" = isnull(openingdetails.Free_Saleable_Quantity, 0),                  
 ----
  "Free SIT Qty" = (tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,        
 ----

 "Damages Qty" = isnull(openingdetails.Damage_Opening_Quantity,0),                  
            
 "Damages Value" =               
 case @StockVal                
 When N'PTS' Then               
 (isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTS, 0))                  
 When N'PTR' Then              
 (Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTR, 0))                  
 When N'ECP' Then              
 (Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0))                  
 When N'MRP' Then              
 (Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0))                  
 When N'Special Price' Then              
 (Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0))                  
 Else              
 isnull((openingdetails.Damage_Opening_Value), 0)                  
 End               
from    Items
Inner Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code                   
Left Outer Join UOM On Items.UOM = UOM.UOM                  
Left Outer Join ConversionTable On  Items.ConversionUnit = ConversionTable.ConversionID                  
Inner Join  #tempCategory1 T1  On  Items.CategoryID = T1.CategoryID           
 ----
Left Outer Join #tmptotal_Invd_qty tmpInvqty On Items.Product_Code = tmpInvqty.Product_Code
Left Outer Join  #tmptotal_rcvd_qty tmprcvdqty On Items.Product_Code = tmprcvdqty.Product_Code
Left Outer Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty On Items.Product_Code = tmpInvdSaleqty.Product_Code
 ----
WHERE  OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                  
 AND Items.ManufacturerID = @MANUFACTURER                  
 AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)        
 and items.active = 1 And ISNULL(OpeningDetails.Opening_Quantity, 0) <> 0      

 Order by T1.IDS      
END        
ELSE                  
BEGIN                  
 print 'current date'
	create table #tmpCurrentDate(
		  IDS Int
		, sortorder Int
		, [Item Code] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		, [Item Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		, [Total On Hand Qty NoUOM] decimal(18, 6)
		, [Total On Hand Qty]  nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		, [Conversion Unit] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		, [Reporting UOM] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		, [On Hand Value] decimal(18, 6)
		, [Tax_Suffered_(%)] decimal(18, 6)
		, [Tax suffered] decimal(18, 6)
		, [Total On Hand Value] decimal(18, 6)
		, [Saleable Stock] decimal(18, 6)
		, [Free OnHand Qty] decimal(18, 6)
		, [Damages Qty] decimal(18, 6)
		)


	create table #tmp_sit_qty( 
		  sortorder Int
		, Item_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		, sitqty decimal(18, 6)
 		)

	

--sify
Insert Into #tmpCurrentDate
Select IDS, "sortorder" = 10, [Item Code], [Item Name],         
"Total On Hand Qty NoUOM" = Sum([Total On Hand Qty]),
"Total On Hand Qty" = Cast(Sum([Total On Hand Qty]) As nvarchar) +  N' ' + IsNull((select         
IsNull(uom.Description, N'') From uom, items Where         
UOM.UOM = Items.UOM And Items.product_code = std.[Item Code]), N''),         
----
--"Total SIT Qty" = 
--	CAST(	Isnull( ( select IsNull(sum(IDR.pending), 0)
--						from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR
--						where IDR.Product_code = std.[Item Code] and /*IAR.Status = 32 and*/ IAR.InvoiceId = IDR.InvoiceId  
--					), 0) AS nvarchar
--		)  + ' ' +  CAST(IsNull((select IsNull(uom.Description, N'') From uom, items Where          
--		UOM.UOM = Items.UOM And Items.product_code = std.[Item Code]), N'') AS nvarchar) ,         
----

"Conversion Unit" = Cast(Sum([Conversion Unit]) As nvarchar) + N' ' + IsNull((select         
IsNull(Conversiontable.ConversionUnit, N'') From conversiontable, items Where         
Conversiontable.ConversionID = Items.ConversionUnit And       
Items.product_code = std.[Item Code]), N''),        
      
"Reporting UOM" = Cast(Sum([Reporting UOM]) As nvarchar) + N' ' + IsNull((select       
IsNull(uom.Description, N'') From uom, items Where         
UOM.UOM = Items.ReportingUOM And Items.product_code = std.[Item Code]), N''),        
      
"On Hand Value" = Sum([On Hand Value]),       
      
--"Tax Suffered (%)" = Sum([Tax Suffered (%)]),       
"Tax Suffered (%)" = [Tax Suffered (%)],      
"Tax Suffered" = Sum([Tax suffered]),         
      
"Total On Hand Value" = Sum([Total On Hand Value]),       
----
--"Total SIT Value" = (Select 
--	 case @StockVal      
--	 When 'PTS' Then     
--		Sum( Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0))
--				Else (Isnull(IDR.pending, 0) * Isnull(Items.PTS, 0)) End )
--	 When 'PTR' Then      
--		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0)) 
--				Else (Isnull(IDR.pending, 0) * Isnull(Items.PTR, 0)) End )
--	 When 'ECP' Then 
--	 --pts instead of ecp	   
--		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(Items.pts, 0)) 
--				Else (Isnull(IDR.pending, 0) * Isnull(Items.pts, 0)) End )
--	 When 'MRP' Then      
--		isnull(Sum(isnull(IDR.pending, 0) * Isnull(Items.MRP, 0)),0)            
--	 When 'Special Price' Then    
--		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.Company_Price, 0)) 
--				Else (Isnull(IDR.pending, 0) * Isnull(Items.Company_Price, 0)) End )
--	 Else    
--	 --pts instead of PurchasePrice
--		isnull(Sum(isnull(IDR.pending, 0) * isnull(Items.pts, 0)),0)            
--	 End    
--	 from InvoiceDetailReceived IDR, InvoiceabstractReceived IAR, Items, ItemCategories IC  
--	 where IAR.InvoiceId = IDR.InvoiceId /*and IAR.Status = 32*/
--	 and Items.Product_Code = IDR.Product_Code and Items.CategoryID = IC.CategoryID 
--	 and isnull(IDR.saleprice, 0) > 0 And items.product_code = std.[Item Code]),        
----
      
"Saleable Stock" = Sum([Saleable Stock]),         
----
--"Saleable SIT Qty" =     
--	CAST(	Isnull(( select IsNull(sum(IDR.pending), 0)
--						from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR 
--						where IDR.Product_code = std.[Item Code] and /*IAR.Status = 32 and*/ IAR.InvoiceId = IDR.InvoiceId  
--						and isnull(IDR.saleprice, 0) > 0 
--					), 0) AS nvarchar
--	)  + ' ' +  CAST(IsNull((select IsNull(uom.Description, N'') From uom, items Where          
--	UOM.UOM = Items.UOM And Items.product_code = std.[Item Code]), N'') AS nvarchar) ,         

----
      
--"Saleable Value" = Sum([Saleable Value]),         
"Free OnHand Qty" = Sum([Free OnHand Qty]),        
----
--"Free SIT Qty" = 	
--	CAST(	IsNull( (select IsNull(sum(IDR.pending), 0)
--						from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR 
--						where IDR.Product_code = std.[Item code] and /*IAR.Status = 32 and*/ IAR.InvoiceId = IDR.InvoiceId  
--						and isnull(IDR.saleprice, 0) = 0 
--					), 0) AS nvarchar
--		)  + ' ' +  CAST(IsNull((select IsNull(uom.Description, N'') From uom, items Where          
--		UOM.UOM = Items.UOM And Items.product_code = std.[Item Code]), N'') AS nvarchar) ,         
----
      
"Damages Qty" = Sum([Damages Qty]) --"Damages Value" = Sum([Damages Value])         
From (        
      
Select  "IDS" = T1.IDS, "Item Code" = a.Product_Code,                 
-- "Item Code" = a.Product_Code,                 
      
 "Item Name" = a.ProductName,                   
      
-- "Total On Hand Qty" = CAST(ISNULL(SUM(Quantity), 0) AS nvarchar) + ' ' + CAST(UOM.Description AS nvarchar),                   
"Total On Hand Qty" = ISNULL(SUM(Quantity), 0),       
      
--AS nvarchar) + ' ' + CAST(UOM.Description AS nvarchar),                   
-- "Conversion Unit" = CAST(CAST(ISNULL(SUM(Quantity), 0) * a.ConversionFactor AS Decimal(18,6)) AS nvarchar)   + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),                  
"Conversion Unit" = CAST(ISNULL(SUM(Quantity), 0) * a.ConversionFactor AS Decimal(18,6)),        
      
--AS nvarchar)   + ' ' + CAST(ConversionTable.ConversionUnit AS nvarchar),                  
-- "Reporting UOM" = Cast(dbo.sp_Get_ReportingQty(SUM(IsNULL(Quantity, 0)), a.ReportingUnit) As nvarchar) + ' ' + CAST((SELECT Description               
--   From UOM Where UOM = a.ReportingUOM) AS nvarchar),                  
"Reporting UOM" = dbo.sp_Get_ReportingQty(SUM(IsNULL(Quantity, 0)), a.ReportingUnit),       
--As nvarchar) + ' ' + CAST((SELECT Description               
-- "Reporting UOM" = CAST(CAST(ISNULL(SUM(Quantity), 0) / (CASE a.ReportingUnit WHEN 0 THEN 1 ELSE a.ReportingUnit END) AS Decimal(18,6)) AS nvarchar)   + ' ' + CAST((SELECT Description From UOM Where UOM = a.ReportingUOM) AS nvarchar),                  

                
"On Hand Value" =               
  case @StockVal              
  When N'PTS'  Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.PTS, 0)) End) End)        
  When N'PTR' Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.PTR, 0)) End) End)        
  When N'ECP' Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.ECP, 0)) End) End)        
  When N'MRP' Then            
  isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(a.MRP, 0)End)),0)             
  When N'Special Price' Then            
  Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(a.Company_Price, 0)) End) End)        
  Else            
  isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                
  End,             
      
 "Tax Suffered (%)" = (select Sum(Batch_Products.TaxSuffered)            
   from Items It, Batch_Products bts            
   where It.Product_Code = bts.Product_Code and             
--   It.ManufacturerID = M1.ManufacturerID             
--   And ItemCategories.CategoryID = It.CategoryID            
--   And IsNull(bts.Damage,0) NOT IN (1,2) And         
bts.Batch_Code = Batch_products.batch_code),         
      
--Cast(IsNull((Tax.Percentage),0) as nvarchar),               
      
 "Tax suffered" =       
Case isnull(Batch_Products.TaxOnMRP,0)              
When 1 Then              
        Case Isnull(ItemCategories.Price_option, 0)               
        When 1 Then              
        ISNULL(Round(Sum((QUANTITY * Batch_Products.purchaseprice) * (Batch_Products.TaxSuffered / 100 )),2), 0)              
     Else              
        ISNULL(Round(Sum((QUANTITY * a.ECP) * (Batch_Products.TaxSuffered / 100 )),2), 0)               
        End              
Else              
 Case Isnull(ItemCategories.Price_option, 0)              
 When 1 Then              
 ISNULL(Round(sum((QUANTITY * Batch_Products.PurchasePrice) * (Batch_Products.TaxSuffered / 100 )),2), 0)              
 Else           
  ISNULL(Round(sum((Case [Free] When 1 Then 0 Else (QUANTITY * a.Purchase_Price) * (Batch_Products.TaxSuffered / 100)End)),2), 0)                 
 End              
End,            
      
  "Total On Hand Value" =                     
  case @StockVal                        
  When N'PTS' Then                       
  ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.PTS + Round(QUANTITY * Batch_Products.PTS * (Batch_Products.TaxSuffered / 100),2))     
  Else (Case [Free] When 1 Then 0 Else (QUANTITY * a.PTS + Round(QUANTITY * a.PTS * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)                                                                      
  When N'PTR' Then                      
  ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.PTR + Round(QUANTITY * Batch_Products.PTR * (Batch_Products.TaxSuffered / 100),2))     
   Else (Case [Free] When 1 Then 0 Else (QUANTITY * a.PTR + Round(QUANTITY * a.PTR * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)        
  When N'ECP' Then                       
  ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.ECP + Round(QUANTITY * Batch_Products.ECP * (Batch_Products.TaxSuffered / 100),2))     
    Else (Case [Free] When 1 Then 0 Else (QUANTITY * a.ECP + Round(QUANTITY * a.ECP * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)        
  When N'MRP' Then                       
  ISNULL(SUM( (Case [Free] When 1 Then 0 Else QUANTITY * a.MRP + Round(QUANTITY * a.MRP * (Batch_Products.TaxSuffered / 100),2)End) ), 0)                       
  When N'Special Price' Then                       
  ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * Batch_Products.Company_Price + Round(QUANTITY * Batch_Products.Company_Price * (Batch_Products.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * a.Company_Price + 

 
     
      
        
Round(QUANTITY * a.Company_Price * (Batch_Products.TaxSuffered / 100),2)) End) End ), 0)        
  Else                    
  ISNULL(SUM(QUANTITY * PurchasePrice + Round(QUANTITY * PurchasePrice * (Batch_Products.TaxSuffered / 100),2)), 0)               
  End,                
      
 "Saleable Stock" = ISNULL((select sum(Quantity) from batch_products bts, Items where Items.Product_Code = bts.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And bts.batch_code = Batch_Products.batch_code),0),            
--Items.ManufacturerID = @MANUFACTURER And Items.Product_Code = a.Product_Code),0),            
  "Saleable Value" = Isnull((Select                 
 case @StockVal                
 When N'PTS'  Then              
 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End)          
 When N'PTR' Then              
 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End)          
 When N'ECP' Then              
 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)          
 When N'MRP' Then              
 isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)               
 When N'Special Price' Then      
 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)          
 Else              
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                  
 End        
  from batch_products bts, Items, ItemCategories where Items.CategoryID = ItemCategories.CategoryID AND Items.Product_Code = bts.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And         
--Items.ManufacturerID = @MANUFACTURER   And Items.Product_Code = a.Product_Code        
bts.batch_code = Batch_Products.batch_code),0),              
      
 "Free OnHand Qty" = ISNULL((select Quantity from Batch_Products bts, Items where Items.Product_Code = bts.Product_Code and free <> 0 And IsNull(Damage, 0) <> 1 And         
--Items.ManufacturerID = @MANUFACTURER And Items.Product_Code = a.Product_Code        
bts.batch_code = Batch_Products.batch_code),0),                  
 "Damages Qty" = ISNULL((select Quantity from Batch_Products bts, Items where Items.Product_Code = bts.Product_Code and damage <> 0 And         
--Items.ManufacturerID = @MANUFACTURER And Items.Product_Code = a.Product_Code        
bts.batch_code = Batch_Products.batch_code),0),        
            
   "Damages Value" = isnull((select                
 case @StockVal                
 When N'PTS'  Then              
 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End)          
 When N'PTR' Then              
 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End)          
 When N'ECP' Then              
 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End)          
 When N'MRP' Then              
 isnull(Sum(isnull(Quantity, 0) * isnull(Items.MRP, 0)),0)               
 When N'Special Price' Then              
 Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End)          
 Else              
 isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                  
 End                    
      
from Batch_Products bts, Items, ItemCategories where Items.CategoryID = ItemCategories.CategoryID AND Items.Product_Code = bts.Product_Code and damage <> 0 And         
--Items.ManufacturerID = @MANUFACTURER And Items.Product_Code = a.Product_Code        
bts.batch_code = Batch_Products.batch_code),0)               
      
from Items a
Left Outer Join  Batch_Products On a.Product_Code = Batch_Products.Product_Code                   
Left Outer Join  UOM On a.UOM = UOM.UOM                  
Left Outer Join  ConversionTable On a.ConversionUnit = ConversionTable.ConversionID                  
Inner Join  ItemCategories On  ItemCategories.CategoryID = a.CategoryID            
Left Outer Join Tax On Tax.Tax_Code = a.TaxSuffered       
Inner Join #tempCategory1 T1 On a.CategoryID = T1.CategoryID
WHERE  a.ManufacturerID = @MANUFACTURER                  
 and a.active = 1                   
AND a.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)        
 GROUP BY T1.IDS, a.Product_Code, a.ProductName, a.UOM, a.ConversionUnit,             
 a.ConversionFactor, a.ReportingUnit, a.ReportingUOM, ConversionTable.ConversionUnit,                
 UOM.Description, Batch_Products.TaxOnMRP, ItemCategories.Price_option, Tax.Percentage,        
 Batch_Products.batch_code         
--Having ISNULL(SUM(Quantity), 0) <> 0            

)  std   
      
Group By  IDS, [Item Code], [Item Code], [Item Name], [Tax Suffered (%)]   
Order by IDS
--     select * from #tmpCurrentDate order by IDS

  Insert Into #tmp_sit_qty	
  select 20 as sortorder, tmpCrntDt.[Item Code] as Item_Code, IsNull(sum(IDR.pending), 0) as pending 
	from ( select distinct [Item Code] from #tmpCurrentDate ) tmpCrntDt 
	left outer join InvoiceDetailReceived IDR on IDR.Product_code = tmpCrntDt.[Item Code]
	left outer join InvoiceabstractReceived IAR on IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId 
	group by tmpCrntDt.[Item Code]
	having IsNull(sum(IDR.pending), 0) > 0
--  select * from #tmp_sit_qty  
  delete from #tmpCurrentDate where [Item Code] 
		not in ( select Item_Code from #tmp_sit_qty ) and [Total On Hand Qty NoUOM] = 0

--     select * from #tmpCurrentDate order by IDS
select [Item Code], [Item Code] 
	, [Item Name], [Total On Hand Qty] 
	, [Total SIT Qty]  
	, [Conversion Unit]
	, [Reporting UOM], [On Hand Value]
	, [Total SIT Value], [Tax Suffered (%)]
	, [Tax suffered], [Total On Hand Value]
	, [Saleable Stock]
	, [Saleable SIT Qty]
	, [Free OnHand Qty]
	, [Free SIT Qty]
	, [Damages Qty]  from 
(
select "sortorder" = tmpCrntDt.sortorder, "IDS" = tmpCrntDt.IDS, "Item Code" = tmpCrntDt.[Item Code]--, tmpCrntDt.[Item Code] 
	, "Item Name" = tmpCrntDt.[Item Name], "Total On Hand Qty" = tmpCrntDt.[Total On Hand Qty] 
	, "Total SIT Qty" = Null 
	, "Conversion Unit" = tmpCrntDt.[Conversion Unit]
	, "Reporting UOM" = tmpCrntDt.[Reporting UOM], "On Hand Value" = tmpCrntDt.[On Hand Value]
	, "Total SIT Value" = Null, "Tax Suffered (%)" = tmpCrntDt.[Tax_Suffered_(%)]
	, "Tax suffered" = tmpCrntDt.[Tax suffered], "Total On Hand Value" = tmpCrntDt.[Total On Hand Value]
	, "Saleable Stock" = tmpCrntDt.[Saleable Stock]
	, "Saleable SIT Qty" = Null
	, "Free OnHand Qty" = tmpCrntDt.[Free OnHand Qty]
	, "Free SIT Qty" = Null	
	, "Damages Qty" = tmpCrntDt.[Damages Qty] 
	from #tmpCurrentDate tmpCrntDt 

	union all
select "sortorder" = tmpsitqty.sortorder, "IDS" = T1.IDS, "Item Code" = tmpsitqty.[Item_code]--, "Item Code" = tmpsitqty.[Item_code]
	, "Item Name" = Itm.[productname], "Total On Hand Qty" = Null 
	, "Total SIT Qty" = CAST( Isnull(tmpsitqty.sitqty, 0) as varchar ) 
			+ ' ' +  CAST(IsNull((select IsNull(uom.Description, N'') From uom, items Where          
			UOM.UOM = Items.UOM And Items.product_code = tmpsitqty.[Item_code] ), N'') AS nvarchar)
	, "Conversion Unit" = Null
	, "Reporting UOM" = Null, "On Hand Value" = Null 
	, "Total SIT Value" = (Select 
	 case @StockVal      
	 When 'PTS' Then     
		Sum( Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0))
				Else (Isnull(IDR.pending, 0) * Isnull(Items.PTS, 0)) End )
	 When 'PTR' Then      
		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0)) 
				Else (Isnull(IDR.pending, 0) * Isnull(Items.PTR, 0)) End )
	 When 'ECP' Then 
	 --pts instead of ecp	   
		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(Items.pts, 0)) 
				Else (Isnull(IDR.pending, 0) * Isnull(Items.pts, 0)) End )
	 When 'MRP' Then      
		isnull(Sum(isnull(IDR.pending, 0) * Isnull(Items.MRP, 0)),0)            
	 When 'Special Price' Then    
		Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.Company_Price, 0)) 
				Else (Isnull(IDR.pending, 0) * Isnull(Items.Company_Price, 0)) End )
	 Else    
	 --pts instead of PurchasePrice
		isnull(Sum(isnull(IDR.pending, 0) * isnull(Items.pts, 0)),0)            
	 End    
	 from InvoiceDetailReceived IDR, InvoiceabstractReceived IAR, Items, ItemCategories IC  
	 where IAR.InvoiceId = IDR.InvoiceId and  IAR.Status & 64 = 0
	 and Items.Product_Code = IDR.Product_Code and Items.CategoryID = IC.CategoryID 
	 --and isnull(IDR.saleprice, 0) > 0 
	 And items.product_code = tmpsitqty.[Item_code])        
	, "Tax Suffered (%)" = Null
	, "Tax suffered" = Null, "Total On Hand Value" = Null
	, "Saleable Stock" = Null
	, "Saleable SIT Qty" =     
			CAST(	Isnull(( select IsNull(sum(IDR.pending), 0)
								from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR 
								where IDR.Product_code = tmpsitqty.Item_code and  IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId  
								and isnull(IDR.saleprice, 0) > 0 
							), 0) AS nvarchar
			)  + ' ' +  CAST(IsNull((select IsNull(uom.Description, N'') From uom, items Where          
			UOM.UOM = Items.UOM And Items.product_code = tmpsitqty.Item_code), N'') AS nvarchar)
	, "Free OnHand Qty" = Null
	, "Free SIT Qty" = 	
		CAST(	IsNull( (select IsNull(sum(IDR.pending), 0)
							from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR 
							where IDR.Product_code = tmpsitqty.Item_code and  IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId  
							and isnull(IDR.saleprice, 0) = 0 
						), 0) AS nvarchar
			)  + ' ' +  CAST(IsNull((select IsNull(uom.Description, N'') From uom, items Where          
			UOM.UOM = Items.UOM And Items.product_code = tmpsitqty.Item_code), N'') AS nvarchar)          
	, "Damages Qty" = Null   
	from #tmp_sit_qty tmpsitqty Join Items Itm on tmpsitqty.Item_code = Itm.product_code
	join #tempCategory1 T1 on Itm.CategoryID = T1.CategoryID
) final order by IDS, sortorder , [Tax Suffered (%)]
	
END                 

