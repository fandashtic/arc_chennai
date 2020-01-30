Create PROCEDURE spr_list_stock_ledger_category_details
(
 @Category Int,
 @FromDate DateTime, 
 @ShowItems NVarChar(50),
 @StockVal NVarChar(100),
 @ItemCode NVarChar(2550),
 @ItemName NVarChar(2550)
)
As          

Declare @Delimeter As NVarChar(1)  
Set @Delimeter = Char(15)

Declare @TmpProd table(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @ItemCode = '%'  
 Insert InTo @TmpProd Select Product_code From Items  
Else  
 Insert into @TmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)  


--This table is to display the categories in the Order
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)  
Exec sp_CatLevelwise_ItemSorting 


If (DatePart(dy, @FromDate) < DatePart(dy, GetDate()) And DatePart(yyyy, @FromDate) = DatePart(yyyy, GetDate())) OR DatePart(yyyy, @FromDate) < DatePart(yyyy, GetDate())          
 Begin
----
	create table #tmptotal_Invd_qty	( 	
		product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		,Invoiced_qty decimal(18, 6)
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

	-- total_Invoiced_qty(Saleable+Free)
	Insert Into #tmptotal_Invd_qty
	select tmp.product_code, isnull(sum(IDR.quantity), 0) from
		 @TmpProd tmp 
		left outer join InvoiceDetailReceived IDR on IDR.product_code = tmp.product_code				
		left outer join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
		where IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FromDate) 		
		/*and IAR.Invoicetype = 0 */
		group by tmp.product_code 
	---

	-- total_received_qty(Saleable), total_received_qty(Free)
	Insert Into #tmptotal_rcvd_qty
	select tmp.product_code, IsNull(sum(gdt.quantityreceived), 0), IsNull(sum(gdt.Freeqty), 0) from @TmpProd tmp 
		  left outer join 
		  ( select IsNull(gdt.quantityreceived, 0) as quantityreceived, 
			IsNull(gdt.freeqty, 0) as freeqty, gdt.product_code as product_code
			from grndetail gdt 
			join grnabstract gab on gab.grnId = gdt.grnId and gab.grnstatus & 96 = 0 and gab.RecdInvoiceId in 
		(	select InvoiceId from Invoiceabstractreceived IAR 
			where IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FromDate) 
			and IAR.Invoicetype = 0 
		)
	) gdt on gdt.product_code = tmp.product_code
	group by tmp.product_code

	-- total_Invoiced_Saleableonly_qty
	Insert Into #tmptotal_Invd_Saleonly_qty
	select tmp.product_code, IsNull(sum(IDR.quantity), 0) from @TmpProd tmp
		left outer join InvoiceDetailReceived IDR on IDR.product_code = tmp.product_code 
		left outer join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId				
		where IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FromDate) 
			and IDR.product_code = tmp.Product_code /*and IAR.Invoicetype = 0 */
			and IDR.Saleprice > 0 			
		group by tmp.product_code 

	  -----		    
	       
  If @ShowItems = 'Items With Stock'      
   Begin         
    Select 
     Items.Product_Code,"Item Code" = Items.Product_Code,"Item Name" = Items.ProductName,           
     "Total On Hand Qty" = Cast(IsNull(OpeningDetails.Opening_Quantity, 0) As NVarChar) + ' ' + Cast(IsNull(UOM.Description,'') As NVarChar),           
	---- Total SIT Qty
	 "Total SIT Qty" = Cast(IsNull(tmpInvqty.Invoiced_qty - tmprcvdqty.rcvdqty - tmprcvdqty.freeqty ,0) AS nvarchar) + ' ' + Cast(IsNull(UOM.Description,'') As NVarChar),           
    ----	
     "Conversion Unit" = Cast(Cast(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.ConversionFactor,0) As Decimal(18,6)) As NVarChar) + ' ' + Cast(IsNull(ConversionTable.ConversionUnit,0) As NVarChar),          
 "Reporting UOM" = dbo.sp_Get_ReportingQty(IsNull(OpeningDetails.Opening_Quantity, 0), IsNull(Items.ReportingUnit,0)),
     "UOM Description" = Cast((Select IsNull(Description,'') From UOM Where UOM = Items.ReportingUOM) As NVarChar),
     "Total On Hand Value" =     
     Case @StockVal      
     When 'PTS' Then ((IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(Free_Opening_Quantity, 0) * IsNull(Items.PTS, 0)))          
     When 'PTR' Then ((IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(Free_Opening_Quantity, 0) * IsNull(Items.PTR, 0)))          
     When 'ECP' Then ((IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(Free_Opening_Quantity, 0) * IsNull(Items.ECP, 0)))          
     When 'MRP' Then ((IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(Free_Opening_Quantity, 0) * IsNull(Items.MRP, 0)))          
     When 'Special Price' Then ((IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(Free_Opening_Quantity, 0) * IsNull(Items.Company_Price, 0)))          
     Else (IsNull(OpeningDetails.Opening_Value, 0))        
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
     "Saleable Stock" = (IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(OpeningDetails.Free_Saleable_Quantity,0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0)),        
	 ---- Saleable SIT Qty
	"Saleable SIT Qty" =(IsNull(tmpInvdSaleqty.Saleableonly_qty,0) - IsNull(tmprcvdqty.rcvdqty,0)),
	----
     "Saleable Value" =     
     Case @StockVal      
     When 'PTS' Then (IsNull(OpeningDetails.Opening_Quantity,0) * IsNull(Items.PTS, 0)) - (IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTS, 0))        
     When 'PTR' Then (IsNull(OpeningDetails.Opening_Quantity,0) * IsNull(Items.PTR, 0)) - (IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTR, 0))        
     When 'ECP' Then (IsNull(OpeningDetails.Opening_Quantity,0) * IsNull(Items.ECP, 0)) - (IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.ECP, 0))        
     When 'MRP' Then (IsNull(OpeningDetails.Opening_Quantity,0) * IsNull(Items.MRP, 0)) - (IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.MRP, 0))        
     When 'Special Price' Then (IsNull(OpeningDetails.Opening_Quantity,0) * IsNull(Items.Company_Price, 0)) - (IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.Company_Price, 0))        
     Else(IsNull(OpeningDetails.Opening_Value,0) - IsNull(OpeningDetails.Damage_Opening_Value,0))    
     End,   

     ----Saleable SIT Value 
	"Saleable SIT Value" =       
	 case @StockVal        
	 When 'PTS' Then (IsNull (tmpInvdSaleqty.Saleableonly_qty,0)  - IsNull(tmprcvdqty.rcvdqty , 0) * Isnull(Items.PTS, 0))          
	 When 'PTR' Then (IsNull (tmpInvdSaleqty.Saleableonly_qty,0) - IsNull(tmprcvdqty.rcvdqty , 0) * Isnull(Items.PTR, 0))          
	 When 'ECP' Then (IsNull (tmpInvdSaleqty.Saleableonly_qty,0) - IsNull(tmprcvdqty.rcvdqty , 0) * Isnull(Items.ECP, 0))          
	 When 'MRP' Then (IsNull (tmpInvdSaleqty.Saleableonly_qty,0) - IsNull(tmprcvdqty.rcvdqty , 0) * Isnull(Items.MRP, 0))          
	 When 'Special Price' Then (IsNull(tmpInvdSaleqty.Saleableonly_qty,0) -IsNull(tmprcvdqty.rcvdqty,0) * Isnull(Items.Company_Price, 0))          
	 Else (IsNull(tmpInvdSaleqty.Saleableonly_qty,0) - IsNull(tmprcvdqty.rcvdqty,0 ) * Isnull(Items.PTS, 0))      
	 End,    
	----
    "Free OnHand Qty" = IsNull(OpeningDetails.Free_Saleable_Quantity, 0),   
	---- Free SIT Qty
	"Free SIT Qty" = IsNull(tmpInvqty.Invoiced_qty,0) - IsNull(tmpInvdSaleqty.Saleableonly_qty,0) - isNull(tmprcvdqty.freeqty,0),        
	----       
     "Damages Qty" = IsNull(OpeningDetails.Damage_Opening_Quantity,0),    
     "Damages Value" =     
     Case @StockVal      
     When 'PTS' Then IsNull((IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTS, 0)), 0)        
     When 'PTR' Then IsNull((IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTR, 0)), 0)        
     When 'ECP' Then IsNull((IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.ECP, 0)), 0)        
     When 'MRP' Then IsNull((IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.MRP, 0)), 0)        
     When 'Special Price' Then IsNull((IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.Company_Price, 0)), 0)        
     Else IsNull((OpeningDetails.Damage_Opening_Value), 0)        
     End,    
     "PTS" = IsNull(Items.PTS, 0),      
     "PTR" = IsNull(Items.PTR, 0),      
     "ECP" = IsNull(Items.ECP, 0),      
     "Manufacturer Name" = Manufacturer.Manufacturer_Name      
    From
     Items
	 Inner Join OpeningDetails On  Items.Product_Code = OpeningDetails.Product_Code
	 Left Outer Join UOM On Items.UOM = UOM.UOM
	 Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID
	 Left Outer Join Manufacturer On Items.ManufacturerID   = Manufacturer.ManufacturerID 
	--
	Left Outer Join #tmptotal_Invd_qty tmpInvqty On Items.Product_Code = tmpInvqty.Product_Code
	Left Outer Join #tmptotal_rcvd_qty tmprcvdqty On  Items.Product_Code = tmprcvdqty.Product_Code
	Left Outer Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty On Items.Product_Code = tmpInvdSaleqty.Product_Code
	Inner Join #tempCategory1 T1 On Items.CategoryID = T1.CategoryID                  
	--     
    Where
    OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate) 
	--------          
     And Items.CategoryID = @Category 
     And Items.Active = 1 And IsNull(OpeningDetails.Opening_Quantity, 0) > 0      
     And Items.Product_Code in (Select product_code Collate SQL_Latin1_General_CP1_CI_As From @TmpProd)
	 Order by T1.IDS
   End      
  Else      
   Begin      
    Select
     Items.Product_Code, "Item Code" = Items.Product_Code,"Item Name" = Items.ProductName,           
     "Total On Hand Qty" = Cast(IsNull(OpeningDetails.Opening_Quantity, 0) As NVarChar) + ' ' + Cast(IsNull(UOM.Description,'') As NVarChar),           
	  ----Total SIT Qty
	 "Total SIT Qty" = CAST(IsNull(tmpInvqty.Invoiced_qty,0) - IsNull(tmprcvdqty.rcvdqty,0) - IsNull(tmprcvdqty.freeqty,0) AS nvarchar)   + ' ' + Cast(IsNull(UOM.Description,'') As NVarChar),         	 
	  ----	
     "Conversion Unit" = Cast(Cast(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.ConversionFactor,0) As Decimal(18,6)) As NVarChar)+ ' ' + Cast(IsNull(ConversionTable.ConversionUnit,'') As NVarChar),
     "Reporting UOM" = dbo.sp_Get_ReportingQty(IsNull(OpeningDetails.Opening_Quantity,0),IsNull(Items.ReportingUnit,0)),
     "UOM Description" = Cast((Select IsNull(Description,'') From UOM Where UOM = Items.ReportingUOM) As NVarChar),
     "Total On Hand Value" =     
      Case @StockVal      
       When 'PTS' Then ((IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(Free_Opening_Quantity, 0) * IsNull(Items.PTS, 0)))          
       When 'PTR' Then ((IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(Free_Opening_Quantity, 0) * IsNull(Items.PTR, 0)))          
       When 'ECP' Then ((IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(Free_Opening_Quantity, 0) * IsNull(Items.ECP, 0)))          
       When 'MRP' Then ((IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(Free_Opening_Quantity, 0) * IsNull(Items.MRP, 0)))          
       When 'Special Price' Then ((IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(Free_Opening_Quantity, 0) * IsNull(Items.Company_Price, 0)))          
       Else (IsNull(OpeningDetails.Opening_Value, 0))        
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
	"Saleable Stock" = (IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(OpeningDetails.Free_Saleable_Quantity,0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0)),        
	----Saleable SIT Qty
	"Saleable SIT Qty" = (IsNull(tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty,0)),
	---
     "Saleable Value" =     
      Case @StockVal      
       When 'PTS' Then (IsNull(OpeningDetails.Opening_Quantity,0) * IsNull(Items.PTS, 0))  - (IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTS, 0))        
       When 'PTR' Then (IsNull(OpeningDetails.Opening_Quantity,0) * IsNull(Items.PTR, 0)) - (IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTR, 0))        
       When 'ECP' Then (IsNull(OpeningDetails.Opening_Quantity,0) * IsNull(Items.ECP, 0)) - (IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.ECP, 0))        
       When 'MRP' Then (IsNull(OpeningDetails.Opening_Quantity,0) * IsNull(Items.MRP, 0)) - (IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.MRP, 0))        
       When 'Special Price' Then (IsNull(OpeningDetails.Opening_Quantity,0) * IsNull(Items.Company_Price, 0)) - (IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.Company_Price, 0))        
       Else(IsNull(OpeningDetails.Opening_Value,0) - IsNull(OpeningDetails.Damage_Opening_Value,0))    
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
	----	   
     "Free OnHand Qty" = IsNull(OpeningDetails.Free_Saleable_Quantity, 0),          
	---- Free SIT Qty
	"Free SIT Qty" = IsNull(tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty  - tmprcvdqty.freeqty, 0),        
	----
     "Damages Qty" = IsNull(OpeningDetails.Damage_Opening_Quantity,0),          
     "Damages Value" =     
      Case @StockVal      
       When 'PTS' Then IsNull((IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTS, 0)), 0)        
       When 'PTR' Then IsNull((IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTR, 0)), 0)        
       When 'ECP' Then IsNull((IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.ECP, 0)), 0)        
       When 'MRP' Then IsNull((IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.MRP, 0)), 0)        
       When 'Special Price' Then IsNull((IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.Company_Price, 0)), 0)        
       Else IsNull((OpeningDetails.Damage_Opening_Value), 0)        
      End,    
     "PTS" = IsNull(Items.PTS, 0),      
     "PTR" = IsNull(Items.PTR, 0),      
     "ECP" = IsNull(Items.ECP, 0),      
     "Manufacturer Name" = Manufacturer.Manufacturer_Name      
    From
     Items
	 Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code 
	 Left Outer Join UOM On Items.UOM = UOM.UOM          
	 Left Outer Join ConversionTable On Items.UOM = UOM.UOM And Items.ConversionUnit = ConversionTable.ConversionID          
	 Left Outer Join Manufacturer On Manufacturer.ManufacturerID = Items.ManufacturerID      
	----
	Left Outer Join #tmptotal_Invd_qty tmpInvqty On Items.Product_Code = tmpInvqty.Product_Code
	Left Outer Join  #tmptotal_rcvd_qty tmprcvdqty On Items.Product_Code = tmprcvdqty.Product_Code
	Left Outer Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty On Items.Product_Code = tmpInvdSaleqty.Product_Code
	Inner Join #tempCategory1 T1 On Items.CategoryID = T1.CategoryID
	----	     
    Where 
     OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate)
	----          
     And Items.CategoryID = @Category 
    And Items.Active = 1 And 
	Items.Product_Code in (Select product_code Collate SQL_Latin1_General_CP1_CI_As From @TmpProd)
     Order by T1.IDS
   End      
 End          
Else          
 Begin          
  If @ShowItems = 'Items With Stock'      
   Begin      
    Select
     a.Product_Code, "Item Code" = a.Product_Code, "Item Name" = a.ProductName,           
     "Total On Hand Qty" = Cast(IsNull(Sum(Quantity), 0) As NVarChar) + ' ' + Cast(IsNull(UOM.Description,'') As NVarChar),           
	  --Total SIT Qty	 
	 "Total SIT Qty" =  (select CAST(ISNULL(SUM(IDR.Pending), 0) AS nvarchar) 
		from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR ,Items,ItemCategories ItC   
		Where IAR.InvoiceID = IDR.InvoiceID And IAR.Status & 64 = 0 And Items.Product_Code = IDR.Product_Code And Items.CategoryID = @Category And ItC.CategoryID =Items.CategoryID AND Items.Active =1  And Items.Product_Code = a.Product_Code )  + N' ' +  CAST(ISNULL(UOM.Description,N'') AS nvarchar),
     "Conversion Unit" = Cast(Cast(IsNull(Sum(Quantity), 0) * IsNull(a.ConversionFactor,0) As Decimal(18,6)) As NVarChar) + ' ' + Cast(IsNull(ConversionTable.ConversionUnit,'') As NVarChar),          
     "Reporting UOM" = dbo.sp_Get_ReportingQty(Sum(IsNull(Quantity, 0)),IsNull(a.ReportingUnit,0)),
     "UOM Description" = Cast((Select IsNull(Description,'') From UOM Where UOM = a.ReportingUOM) As NVarChar),
     "Total On Hand Value" =       
      Case @StockVal      
       When 'PTS' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(a.PTS, 0)) End) End)
       When 'PTR' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(a.PTR, 0)) End) End)
       When 'ECP' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(a.ECP, 0)) End) End)
       When 'MRP' Then IsNull(Sum((Case [Free] When 1 Then 0 Else IsNull(Quantity, 0) * IsNull(a.MRP, 0)End)),0)     
       When 'Special Price' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(a.Company_Price, 0)) End) End)
       Else IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchAsePrice, 0)),0)        
      End, 
	 --Total SIT Value
	 "Total SIT Value" = Isnull((Select         
		case @StockVal        
		When N'PTS' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTS, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0)) End) End)	       
		When N'PTR' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTR, 0))Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0)) End) End) 	
		When N'ECP' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.MRP, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0)) End) End)	
		When N'MRP' Then isnull(Sum((Case (IDR.SalePrice) When 0 Then 0 Else isnull(IDR.Pending, 0) * isnull(Items.MRP, 0)End)),0)       	   	      
		When N'Special Price' Then 	Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.Company_Price, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0)) End) End)
		Else isnull(Sum(isnull(IDR.Pending, 0) * isnull(IDR.SalePrice, 0)),0)          
		End   
		from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items, ItemCategories IC 
		where  IAR.InvoiceID = IDR.InvoiceID
        And IAR.Status & 64 = 0
		And Items.CategoryID = IC.CategoryID 
		And Items.Product_Code = IDR.Product_Code 
		And Items.CategoryID = @Category
		And Items.Product_Code = a.Product_Code),0), 	
		 
     "Saleable Stock" = IsNull((Select Sum(Quantity) From Batch_Products, Items Where Items.Product_Code = Batch_Products.Product_Code And IsNull(Free,0)=0 And IsNull(Damage,0) = 0 And Items.CategoryID = @Category And Items.Product_Code = a.Product_Code),0),                    
	-- Saleable SIT Qty
  	"Saleable SIT Qty" = isnull((select Sum(IDR.Pending) from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items 
	 where IAR.InvoiceID = IDR.InvoiceID
     And IAR.Status & 64 = 0
	 And Items.Product_Code = IDR.Product_Code 
	 And Items.CategoryID = @Category
	 And Items.Product_Code = a.Product_Code
	 And isnull (IDR.SalePrice,0) > 0),0), 
     "Saleable Value" = 
      IsNull((
       Select       
        Case @StockVal      
        When 'PTS'  Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTS, 0)) End)
        When 'PTR' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTR, 0)) End)
        When 'ECP' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.ECP, 0)) End)
        When 'MRP' Then IsNull(Sum(IsNull(Quantity, 0) * IsNull(Items.MRP, 0)),0)     
        When 'Special Price' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.Company_Price, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.Company_Price, 0)) End)
        Else IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchAsePrice, 0)),0)        
        End 
       From
        Batch_Products, Items, ItemCategories IC
       Where
        Items.Product_Code = Batch_Products.Product_Code And Items.CategoryID = IC.CategoryID
        And IsNull(Free,0)=0 And IsNull(Damage,0) = 0 And Items.CategoryID = @Category       
        And Items.Product_Code = a.Product_Code
      ),0), 
	 --Saleable SIT Value
	"Saleable SIT Value" = Isnull((Select             
	case @StockVal            
	When 'PTS' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTS, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0)) End)      
	When 'PTR' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTR, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0)) End)      
	When 'ECP' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.MRP, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0)) End)      
	When 'MRP' Then isnull(Sum(isnull(IDR.Pending, 0) * isnull(Items.MRP, 0)),0)           
	When 'Special Price' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.Company_Price, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0)) End)      
	Else isnull(Sum(isnull(IDR.Pending, 0) * isnull(IDR.SalePrice, 0)),0)              
	End           
	from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items, ItemCategories IC 
	where IAR.InvoiceID = IDR.InvoiceID	
    And IAR.Status & 64 = 0
	And Items.CategoryID = @Category   
	And Items.CategoryID = IC.CategoryID 
	And Items.Product_Code = IDR.Product_Code 
	And Items.Product_Code = a.Product_Code
	And IDR.SalePrice > 0),0),        	
    
     "Free OnHand Qty" = IsNull((Select Sum(Quantity) From Batch_Products, Items Where Items.Product_Code = Batch_Products.Product_Code And IsNull(Free,0) <> 0 And IsNull(Damage, 0) <> 1 And Items.CategoryID = @Category  And Items.Product_Code = a.Product_Code),0),          
	 -- Free SIT QTY
	"Free SIT Qty" = isnull((select sum(IDR.Pending) from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items 
	where IAR.InvoiceID = IDR.InvoiceID
    And IAR.Status & 64 = 0
	And Items.CategoryID = @Category
	And Items.Product_Code = IDR.Product_Code 
	And Items.Product_Code = a.Product_Code
	And IDR.SalePrice = 0 ),0),	

     "Damages Qty" = IsNull((Select Sum(Quantity) From Batch_Products, Items Where Items.Product_Code = Batch_Products.Product_Code And IsNull(Damage,0) <> 0 And Items.CategoryID = @Category  And Items.Product_Code = a.Product_Code),0),          
     "Damages Value" =
      IsNull((
       Select        
        Case @StockVal      
         When 'PTS' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTS, 0)) End)
         When 'PTR' Then	Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTR, 0)) End)
         When 'ECP' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.ECP, 0)) End)
         When 'MRP' Then Sum(Case IsNull(Free, 0) When 1 Then 0 Else IsNull(Quantity, 0) * IsNull(Items.MRP, 0) End)
         When 'Special Price' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.Company_Price, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.Company_Price, 0)) End)
         Else IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchAsePrice, 0)),0)        
        End        
       From
        Batch_Products,Items,ItemCategories IC
       Where
        Items.Product_Code = Batch_Products.Product_Code And Items.CategoryID = IC.CategoryID
        And IsNull(Damage,0) <> 0 And Items.CategoryID = @Category
        And Items.Product_Code = a.Product_Code
      ),0),       
     "PTS" = IsNull(a.PTS, 0),      
     "PTR" = IsNull(a.PTR, 0),      
     "ECP" = IsNull(a.ECP, 0),      
     "Manufacturer Name" = Manufacturer.Manufacturer_Name      
    From
     Items a
	 Left Outer Join Batch_Products On a.Product_Code = Batch_Products.Product_Code
	 Left Outer Join UOM On a.UOM = UOM.UOM
	 Left Outer Join ConversionTable On a.ConversionUnit = ConversionTable.ConversionID       
	 Left Outer Join Manufacturer On Manufacturer.ManufacturerID = a.ManufacturerID 
	 Inner Join ItemCategories IC On a.CategoryID = IC.CategoryID 
	 Inner Join  #tempCategory1 T1 On a.CategoryId =T1.CategoryID            
    Where a.CategoryID = @Category  And a.Active = 1       
     And a.Product_Code In (Select product_code Collate SQL_Latin1_General_CP1_CI_As From @TmpProd)
    Group By
     T1.IDS, a.Product_Code,a.ProductName,a.ConversionUnit,a.ReportingUnit,a.ReportingUOM,        
     UOM.Description,ConversionTable.ConversionUnit,a.ConversionFactor,a.PTS,a.PTR,
     a.ECP, Manufacturer.Manufacturer_Name      
    Having
     IsNull(Sum(Quantity), 0) > 0   
	Order by T1.IDS    
   End      
  Else      
   Begin      
    Select
     a.Product_Code, "Item Code" = a.Product_Code, "Item Name" = a.ProductName,       
     "Total On Hand Qty" = Cast(IsNull(Sum(Quantity), 0) As NVarChar)+ ' ' + Cast(IsNull(UOM.Description,'') As NVarChar),       
	 --Total SIT Qty	
	"Total SIT Qty" =  (select CAST(ISNULL(SUM(IDR.Pending), 0) AS nvarchar) 
		from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR ,Items,ItemCategories ItC   
		Where IAR.InvoiceID= IDR.InvoiceID And IAR.Status & 64 = 0 And Items.Product_Code = IDR.Product_Code And Items.CategoryID = @Category And ItC.CategoryID =Items.CategoryID AND Items.Active =1  And Items.Product_Code = a.Product_Code )  + N' ' +  CAST(ISNULL(UOM.Description,N'') AS nvarchar),
     "Conversion Unit" = Cast(Cast(IsNull(Sum(Quantity), 0) * IsNull(a.ConversionFactor,0) As Decimal(18,6)) As NVarChar)+ ' ' + Cast(IsNull(ConversionTable.ConversionUnit,'') As NVarChar),      
     "Reporting UOM" = dbo.sp_Get_ReportingQty(Sum(IsNull(Quantity, 0)), IsNull(a.ReportingUnit,0)),
     "UOM Description" = Cast((Select IsNull(Description,'') From UOM Where UOM = a.ReportingUOM) As NVarChar), 
     "Total On Hand Value" =       
      Case @StockVal      
       When 'PTS' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(a.PTS, 0)) End) End)
       When 'PTR' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(a.PTR, 0)) End) End)
       When 'ECP' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(a.ECP, 0)) End) End)
       When 'MRP' Then IsNull(Sum((Case [Free] When 1 Then 0 Else IsNull(Quantity, 0) * IsNull(a.MRP, 0)End)),0)     
       When 'Special Price' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(a.Company_Price, 0)) End) End)
       Else IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchAsePrice, 0)),0)        
      End,  
	--Total SIT Value
	 "Total SIT Value" = Isnull((Select         
		case @StockVal        
		When N'PTS' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTS, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0)) End) End)	       
		When N'PTR' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTR, 0))Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0)) End) End) 	
		When N'ECP' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.MRP, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0)) End) End)	
		When N'MRP' Then isnull(Sum((Case (IDR.SalePrice) When 0 Then 0 Else isnull(IDR.Pending, 0) * isnull(Items.MRP, 0)End)),0)       	   	      
		When N'Special Price' Then 	Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.Company_Price, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0)) End) End)
		Else isnull(Sum(isnull(IDR.Pending, 0) * isnull(IDR.SalePrice, 0)),0)          
		End   
		from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items, ItemCategories IC 
		where IAR.InvoiceID = IDR.InvoiceID
        And IAR.Status & 64 = 0
		And Items.CategoryID = IC.CategoryID 
		And Items.Product_Code = IDR.Product_Code 
		And Items.CategoryID = @Category
		And Items.active =1
		And Items.Product_Code = a.Product_Code),0), 	
	
     "Saleable Stock" = IsNull((Select Sum(Quantity) From Batch_Products, Items Where Items.Product_Code = Batch_Products.Product_Code And IsNull(Free,0)=0 And IsNull(Damage,0) = 0 And Items.CategoryID = @Category And Items.Product_Code = a.Product_Code),0),      
	-- Saleable SIT Qty
  	"Saleable SIT Qty" = isnull((select Sum(IDR.Pending) 
	from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items 
	 where IAR.InvoiceID = IDR.InvoiceID
     And IAR.Status & 64 = 0
	And Items.Product_Code = IDR.Product_Code 
	 And Items.CategoryID = @Category
	 And Items.Product_Code = a.Product_Code
	 And isnull (IDR.SalePrice,0) > 0),0), 	

     "Saleable Value" = 
      IsNull((
       Select   
        Case @StockVal      
         When 'PTS' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTS, 0)) End)
         When 'PTR' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTR, 0)) End)
         When 'ECP' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.ECP, 0)) End)
         When 'MRP' Then IsNull(Sum(IsNull(Quantity, 0) * IsNull(Items.MRP, 0)),0)     
         When 'Special Price' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.Company_Price, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.Company_Price, 0)) End)
         Else IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchAsePrice, 0)),0)        
        End      
       From
        Batch_Products, Items, ItemCategories IC
       Where
        Items.Product_Code = Batch_Products.Product_Code And Items.CategoryID = IC.CategoryID	
        And IsNull(Free,0)=0 And IsNull(Damage,0) = 0 And Items.CategoryID = @Category   
        And Items.Product_Code = a.Product_Code
      ),0),  
	
	 --Saleable SIT Value
	"Saleable SIT Value" = Isnull((Select             
	case @StockVal            
	When 'PTS' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTS, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0)) End)      
	When 'PTR' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.PTR, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0)) End)      
	When 'ECP' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.MRP, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0)) End)      
	When 'MRP' Then isnull(Sum(isnull(IDR.Pending, 0) * isnull(Items.MRP, 0)),0)           
	When 'Special Price' Then Sum(Case IC.Price_Option When 1 Then (Isnull(IDR.Pending, 0) * Isnull(IDR.Company_Price, 0)) Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0)) End)      
	Else isnull(Sum(isnull(IDR.Pending, 0) * isnull(IDR.SalePrice, 0)),0)              
	End           
	from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items, ItemCategories IC 
	where IAR.InvoiceID = IDR.InvoiceID	
    And IAR.Status & 64 = 0
	And Items.CategoryID = @Category   
	And Items.CategoryID = IC.CategoryID 
	And Items.Product_Code = IDR.Product_Code 
	And Items.Product_Code = a.Product_Code
	And IDR.SalePrice > 0),0),  

    "Free OnHand Qty" = IsNull((Select Sum(Quantity) From Batch_Products, Items Where Items.Product_Code = Batch_Products.Product_Code And IsNull(Free,0) <> 0 And IsNull(Damage, 0) <> 1 And Items.CategoryID = @Category  And Items.Product_Code = a.Product_Code),0),      

	 -- Free SIT QTY
	"Free SIT Qty" = isnull((select sum(IDR.Pending) from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items 
	where IAR.InvoiceID = IDR.InvoiceID
    And IAR.Status & 64 = 0
	And Items.CategoryID = @Category
	And Items.Product_Code = IDR.Product_Code 
	And Items.Product_Code = a.Product_Code
	And IDR.SalePrice = 0 ),0),	

     "Damages Qty" = IsNull((Select Sum(Quantity) From Batch_Products, Items Where Items.Product_Code = Batch_Products.Product_Code And IsNull(Damage,0) <> 0 And Items.CategoryID = @Category  And Items.Product_Code = a.Product_Code),0),      
     "Damages Value" =
      IsNull((
       Select   
        Case @StockVal      
         When 'PTS' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTS, 0)) End)
         When 'PTR' Then	Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTR, 0)) End)
         When 'ECP' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.ECP, 0)) End)
         When 'MRP' Then Sum(Case IsNull(Free, 0) When 1 Then 0 Else IsNull(Quantity, 0) * IsNull(Items.MRP, 0) End)
         When 'Special Price' Then Sum(Case IC.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.Company_Price, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.Company_Price, 0)) End)
         Else IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchAsePrice, 0)),0)        
        End    
       From
        Batch_Products, Items, ItemCategories IC
       Where
        Items.Product_Code = Batch_Products.Product_Code And Items.CategoryID = IC.CategoryID
        And IsNull(Damage,0) <> 0	And Items.CategoryID = @Category 
        And Items.Product_Code = a.Product_Code
      ),0),    
     "PTS" = IsNull(a.PTS, 0),  
     "PTR" = IsNull(a.PTR, 0),  
     "ECP" = IsNull(a.ECP, 0),  
     "Manufacturer Name" = Manufacturer.Manufacturer_Name  
    From
     Items a
	 Left Outer Join Batch_Products On a.Product_Code = Batch_Products.Product_Code
	 Left Outer Join  UOM On a.UOM = UOM.UOM 
	 Left Outer Join ConversionTable On a.ConversionUnit = ConversionTable.ConversionID    
	 Left Outer Join Manufacturer On Manufacturer.ManufacturerID = a.ManufacturerID  
	 Inner Join  ItemCategories IC On a.CategoryID = IC.CategoryID
	 Inner Join #tempCategory1 T1 On a.CategoryID = T1.CategoryID   
    Where a.CategoryID = @Category And a.Active = 1  
     And a.Product_Code in (Select product_code Collate SQL_Latin1_General_CP1_CI_As From @TmpProd)
    Group By
     T1.IDS, a.Product_Code, a.ProductName,a.ConversionUnit, a.ReportingUnit, a.ReportingUOM,    
     UOM.Description, ConversionTable.ConversionUnit, a.ConversionFactor,a.PTS, a.PTR,
     a.ECP, Manufacturer.Manufacturer_Name  
	Order by T1.IDS
   End  
 End

