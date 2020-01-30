Create PROCEDURE spr_list_stock_ledger_by_mfr(@MANUFACTURER nvarchar(2550),           
 @FROM_DATE datetime, @ShowItems nvarchar(50), @StockVal nvarchar(100),        
 @ItemCode nvarchar(2550))        
AS                                
          
Declare @Delimeter as Char(1)            
Set @Delimeter=Char(15)            
Declare @tmpMfr table(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)            
Declare @tmpProd table(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
        
if @MANUFACTURER='%'             
   Insert into @tmpMfr select Manufacturer_Name from Manufacturer            
Else            
   Insert into @tmpMfr select * from dbo.sp_SplitIn2Rows(@MANUFACTURER,@Delimeter)            
        
if @ItemCode = '%'        
 Insert InTo @tmpProd Select Product_code From Items        
Else        
 Insert into @tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)        
          
                            
IF (DATEPART(dy, @FROM_DATE) < DATEPART(dy, GETDATE()) AND DATEPART(yyyy, @FROM_DATE) = DATEPART(yyyy, GETDATE())) or DATEPART(yyyy, @FROM_DATE) < DATEPART(yyyy, GETDATE())                            
BEGIN                            
 ----temp tables for SIT  
 create table #tmptotal_Invd_Saleonly_qty(   
  Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  
  , Saleableqty decimal(18, 6)  
  , salablevalue decimal(18, 6)  
  )  
  
 create table #tmptotal_Invd_Freeonly_qty(   
  Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  
  , freeqty decimal(18, 6)  
  , freevalue decimal(18, 6)  
  )  
  
 create table #tmptotal_rcvd_qty(   
  Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  
  , saleableqty decimal(18, 6)  
  , freeqty decimal(18, 6)  
  , salablevalue decimal(18, 6)  
  , freevalue decimal(18, 6)  
  )  
  
 create table #tmpPreviousDate(   
  ManufacturerID int  
  , Manufacturer  nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  
  , [Total On Hand Qty] decimal(18, 6)  
  , [On Hand Value] decimal(18, 6)  
  , [Tax suffered ] decimal(18, 6)  
  , [Total On Hand Value] decimal(18, 6)  
  , [Saleable Stock] decimal(18, 6)  
  , [Saleable Value] decimal(18, 6)  
  , [Free OnHand Qty] decimal(18, 6)  
  , [Damages Qty] decimal(18, 6)  
  , [Damages Value] decimal(18, 6)  
  )  
 ----temp tables for SIT  
  
 -- total_Invoiced_qty(Saleable only)  
 Insert Into #tmptotal_Invd_Saleonly_qty  
 select tmp.Manufacturer, isnull(sum(IDR.quantity), 0)  
  ,isnull(sum(IDR.quantity * (case @StockVal                      
        When 'PTS' Then Items.PTS  
        When 'PTR' Then Items.PTR  
        When 'ECP' Then Items.ECP  
        When 'MRP' Then Items.MRP  
        When 'Special Price' Then Items.Company_Price  
        Else Items.MRP End)), 0)   
  from @tmpMfr tmp join Manufacturer mfr on tmp.Manufacturer = mfr.Manufacturer_Name  
  join Items on mfr.ManufacturerID = Items.ManufacturerID   
  join @tmpProd tmpprod on Items.product_code  = tmpprod.product_code   
  left outer join ( select IDR.product_code as product_code, IDR.quantity as quantity   
       from InvoiceDetailReceived IDR join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId  
       where IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE)   
       and IAR.Invoicetype = 0 and IDR.Saleprice > 0   
      ) IDR on IDR.product_code = Items.product_code  
  group by tmp.Manufacturer  
  
  
 -- total_Invoiced_freeonly_qty  
 Insert Into #tmptotal_Invd_Freeonly_qty  
 select tmp.Manufacturer, isnull(sum(IDR.quantity), 0)  
  ,isnull(sum(IDR.quantity * (case @StockVal                      
        When 'PTS' Then Items.PTS  
        When 'PTR' Then Items.PTR  
        When 'ECP' Then Items.ECP  
        When 'MRP' Then Items.MRP  
        When 'Special Price' Then Items.Company_Price  
        Else Items.MRP End)), 0)   
  from @tmpMfr tmp join Manufacturer mfr on tmp.Manufacturer = mfr.Manufacturer_Name  
  join Items on mfr.ManufacturerID = Items.ManufacturerID   
  join @tmpProd tmpprod on Items.product_code  = tmpprod.product_code   
  left outer join ( select IDR.product_code as product_code, IDR.quantity as quantity   
       from InvoiceDetailReceived IDR join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId  
       where IAR.Status & 64 = 0 and  IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE)   
       and IAR.Invoicetype = 0 and IDR.Saleprice = 0   
      ) IDR on IDR.product_code = Items.product_code  
  group by tmp.Manufacturer  
  
 -- total_received_qty(Saleable), total_received_qty(Free)  
 Insert Into #tmptotal_rcvd_qty  
 select tmp.Manufacturer, IsNull(sum(gdt.quantityreceived), 0), IsNull(sum(gdt.Freeqty), 0)  
  ,isnull(sum(gdt.quantityreceived * (case @StockVal                      
        When 'PTS' Then Items.PTS  
        When 'PTR' Then Items.PTR  
        When 'ECP' Then Items.ECP  
        When 'MRP' Then Items.MRP  
        When 'Special Price' Then Items.Company_Price  
        Else Items.MRP End)), 0)   
  ,isnull(sum(gdt.freeqty * (case @StockVal                      
        When 'PTS' Then Items.PTS  
        When 'PTR' Then Items.PTR  
        When 'ECP' Then Items.ECP  
        When 'MRP' Then Items.MRP  
        When 'Special Price' Then Items.Company_Price  
        Else Items.MRP End)), 0)   
  from @tmpMfr tmp join Manufacturer mfr on tmp.Manufacturer = mfr.Manufacturer_Name  
  join Items on mfr.ManufacturerID = Items.ManufacturerID  
  join @tmpProd tmpprod on Items.product_code  = tmpprod.product_code   
  left outer join   
  ( select gdt.quantityreceived as quantityreceived,   
   gdt.freeqty as freeqty, gdt.product_code as product_code  
   from grndetail gdt   
   join grnabstract gab on gab.grnId = gdt.grnId and gab.grnstatus = 1 and gab.RecdInvoiceId in   
   ( select InvoiceId from Invoiceabstractreceived IAR   
    where IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FROM_DATE)   
    and IAR.Invoicetype = 0   
   )  
   where gab.GrnDate < dateadd(d, 1, @FROM_DATE)   
  ) gdt on gdt.product_code = items.product_code  
  group by tmp.Manufacturer   

--select * from #tmptotal_Invd_Saleonly_qty  
--select * from #tmptotal_Invd_Freeonly_qty  
--select * from #tmptotal_rcvd_qty  
--select * from #tmpPreviousDate  
 IF @ShowItems = 'Items with stock'                            
 BEGIN  
  print 'previous date Stock only Items'  
  
  Insert into #tmpPreviousDate  
  Select "ManufacturerID" = Items.ManufacturerID,                                 
   "Manufacturer" = Manufacturer.Manufacturer_Name,                                 
   "Total On Hand Qty" = ISNULL(SUM(OpeningDetails.Opening_Quantity), 0),                                 
   "On Hand Value" =                     
   case @StockVal                      
   When 'PTS' Then                     
   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTS, 0)))                          
   When 'PTR' Then                     
   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTR, 0)))                          
   When 'ECP' Then                     
   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))                          
   When 'MRP' Then                     
   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))                          
   When 'Special Price' Then                     
   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))                          
   Else                    
   SUM(ISNULL(OpeningDetails.Opening_Value, 0))                        
   End,                                
   --"Tax Suffered (%)" = Sum(OpeningDetails.TaxSuffered_Value),                            
   "Tax suffered" = Cast(ISNULL(SUM(OpeningDetails.Opening_Value * (OpeningDetails.TaxSuffered_Value/100)), 0) As Decimal(18,6)),                            
                             
   "Total On Hand Value" =                             
case @StockVal                                
   When 'PTS' Then                               
   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTS, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTS, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))              
  
   When 'PTR' Then                               
   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTR, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTR, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))              
  
   When 'ECP' Then                               
   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))              
  
   When 'MRP' Then       
   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))              
 
   When 'Special Price' Then             
   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(
18,6))            
   Else                            
   Cast(ISNULL(SUM(OpeningDetails.Opening_Value + (OpeningDetails.Opening_Value * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))                            
   End,                            
   "Saleable Stock" = isnull(sum(openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0)), 0),                                
  "Saleable Value" =                               
  case @StockVal                                
  When 'PTS' Then                               
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTS, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTS, 0))                                  
  When 'PTR' Then                               
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTR, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTR, 0))                                  
  When 'ECP' Then                               
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))                                  
  When 'MRP' Then                               
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))                                  
  When 'Special Price' Then                               
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))                                  
  Else                              
  sum(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))                              
  End,                              
   "Free OnHand Qty" = isnull(sum(openingdetails.Free_Saleable_Quantity), 0),                                
   "Damages Qty" = isnull(sum(openingdetails.Damage_Opening_Quantity),0),                                
  "Damages Value" =                             
  case @StockVal                              
  When 'PTS' Then                             
  isnull(Sum(isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTS, 0)), 0)                                
  When 'PTR' Then                            
  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTR, 0)), 0)                                
  When 'ECP' Then                            
  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)                                
  When 'MRP' Then                            
  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)                                
  When 'Special Price' Then                            
  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)                                
  Else                            
  isnull(Sum(openingdetails.Damage_Opening_Value), 0)                                
  End                             
  from Items
  Left Outer Join OpeningDetails On  Items.Product_Code = OpeningDetails.Product_Code
  Inner Join  Manufacturer On  Items.ManufacturerID = Manufacturer.ManufacturerID                                                          
  WHERE  OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                                
   AND Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpMfr)         
   AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)        
   and Manufacturer.Active = 1                               
  GROUP BY Items.ManufacturerID, Manufacturer.Manufacturer_Name                                
  HAVING ISNULL(SUM(OpeningDetails.Opening_Quantity), 0) > 0  
   
  select tempMfr.ManufacturerID, tempMfr.Manufacturer  
 , tempMfr.[Total On Hand Qty]  
 , "Total SIT Qty" = ( ( tmpInvdSale.Saleableqty + tmpInvdfree.freeqty ) - tmprcvdqty.saleableqty - tmprcvdqty.freeqty )  
 , tempMfr.[On Hand Value]  
 , "Total SIT Value" = ( tmpInvdSale.salablevalue - tmprcvdqty.salablevalue )  
 , tempMfr.[Tax suffered]    
 , tempMfr.[Total On Hand Value]  
 , tempMfr.[Saleable Stock]  
    , "Saleable SIT Qty" = ( tmpInvdSale.Saleableqty - tmprcvdqty.saleableqty  )  
 , tempMfr.[Saleable Value]  
 , "Saleable SIT Value" = ( tmpInvdSale.salablevalue - tmprcvdqty.salablevalue )      
 , tempMfr.[Free OnHand Qty]  
 , "Free SIT Qty" =  ( tmpInvdfree.freeqty - tmprcvdqty.freeqty )    
 , tempMfr.[Damages Qty]  
 , tempMfr.[Damages Value]  
 from #tmpPreviousDate tempMfr   
 join #tmptotal_Invd_Saleonly_qty tmpInvdSale on tempMfr.[Manufacturer] = tmpInvdSale.Manufacturer  
 Join #tmptotal_Invd_Freeonly_qty tmpInvdfree on tempMfr.[Manufacturer] = tmpInvdfree.Manufacturer  
 Join #tmptotal_rcvd_qty tmprcvdqty on tempMfr.[Manufacturer] = tmprcvdqty.Manufacturer  
  
END                 
 ELSE                        
 BEGIN                 
  
  print 'previous date all Items'  
  Insert into #tmpPreviousDate  
  Select "ManufacturerID" = Items.ManufacturerID,                                 
   "Manufacturer" = Manufacturer.Manufacturer_Name,                                 
   "Total On Hand Qty" = ISNULL(SUM(OpeningDetails.Opening_Quantity), 0),                                 
   "On Hand Value" =                     
   case @StockVal                      
   When 'PTS' Then                     
   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTS, 0)))                          
   When 'PTR' Then                     
   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTR, 0)))                          
   When 'ECP' Then              
   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0)))                          
   When 'MRP' Then                     
   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0)))                          
   When 'Special Price' Then                     
   (SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0)))                          
   Else                    
   SUM(ISNULL(OpeningDetails.Opening_Value, 0))                        
   End,                                
   --"Tax Suffered (%)" = Sum(OpeningDetails.TaxSuffered_Value),                            
   "Tax suffered" = Cast(ISNULL(SUM(OpeningDetails.Opening_Value * (OpeningDetails.TaxSuffered_Value/100)), 0) As Decimal(18,6)),                            
   "Total On Hand Value" =                             
   case @StockVal                                
   When 'PTS' Then                               
   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTS, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTS, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))              
  
   When 'PTR' Then                               
   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.PTR, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTR, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))              
  
   When 'ECP' Then                               
   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.ECP, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))              
  
   When 'MRP' Then       
   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.MRP, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))              
 
   When 'Special Price' Then             
   Cast(ISNULL(SUM(ISNULL(openingdetails.Opening_Quantity - Free_opening_Quantity, 0) * Isnull(Items.Company_Price, 0) + (ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(
18,6))            
   Else                            
   Cast(ISNULL(SUM(OpeningDetails.Opening_Value + (OpeningDetails.Opening_Value * OpeningDetails.TaxSuffered_Value /100)), 0) As Decimal(18,6))                            
   End,                            
   "Saleable Stock" = isnull(sum(openingdetails.Opening_Quantity - IsNull(openingdetails.Free_Saleable_Quantity,0) - IsNull(openingdetails.Damage_Opening_Quantity,0)), 0),                                
  "Saleable Value" =                               
  case @StockVal                                
  When 'PTS' Then                               
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTS, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTS, 0))                                  
  When 'PTR' Then                               
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.PTR, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.PTR, 0))                                  
  When 'ECP' Then                               
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.ECP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.ECP, 0))                                  
  When 'MRP' Then                               
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.MRP, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.MRP, 0))                           
  When 'Special Price' Then                               
  sum(ISNULL(openingdetails.Opening_Quantity, 0) * Isnull(Items.Company_Price, 0) - isnull(openingdetails.Damage_Opening_Quantity,0) * Isnull(Items.Company_Price, 0))                                  
  Else                              
  sum(isnull(openingdetails.Opening_Value,0) - isnull(openingdetails.Damage_Opening_Value,0))                              
  End,                              
   "Free OnHand Qty" = isnull(sum(openingdetails.Free_Saleable_Quantity), 0),                                
   "Damages Qty" = isnull(sum(openingdetails.Damage_Opening_Quantity),0),                                
  "Damages Value" =                             
  case @StockVal                              
  When 'PTS' Then                             
  isnull(Sum(isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTS, 0)), 0)                                
  When 'PTR' Then                            
  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.PTR, 0)), 0)                                
  When 'ECP' Then                            
  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.ECP, 0)), 0)                                
  When 'MRP' Then                            
  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.MRP, 0)), 0)                                
  When 'Special Price' Then                            
  isnull(Sum(Isnull(openingdetails.Damage_Opening_Quantity, 0) * Isnull(Items.Company_Price, 0)), 0)                                
  Else                            
  isnull(Sum(openingdetails.Damage_Opening_Value), 0)                                
  End                             
  from Items
  Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
  Inner Join  Manufacturer  On Items.ManufacturerID = Manufacturer.ManufacturerID                                                         
  WHERE   OpeningDetails.Opening_Date = DATEADD(d, 1, @FROM_DATE)                                
   AND Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpMfr)         
   AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)        
   and Manufacturer.Active = 1                               
  GROUP BY Items.ManufacturerID, Manufacturer.Manufacturer_Name                                
   
  select tempMfr.ManufacturerID, tempMfr.Manufacturer  
 , tempMfr.[Total On Hand Qty]  
 , "Total SIT Qty" = ( ( tmpInvdSale.Saleableqty + tmpInvdfree.freeqty ) - tmprcvdqty.saleableqty - tmprcvdqty.freeqty )  
 , tempMfr.[On Hand Value]  
 , "Total SIT Value" = ( tmpInvdSale.salablevalue - tmprcvdqty.salablevalue )  
 , tempMfr.[Tax suffered]    
 , tempMfr.[Total On Hand Value]  
 , tempMfr.[Saleable Stock]  
    , "Saleable SIT Qty" = ( tmpInvdSale.Saleableqty - tmprcvdqty.saleableqty  )  
 , tempMfr.[Saleable Value]  
 , "Saleable SIT Value" = ( tmpInvdSale.salablevalue - tmprcvdqty.salablevalue )      
 , tempMfr.[Free OnHand Qty]  
 , "Free SIT Qty" =  ( tmpInvdfree.freeqty - tmprcvdqty.freeqty )    
 , tempMfr.[Damages Qty]  
 , tempMfr.[Damages Value]  
 from #tmpPreviousDate tempMfr   
 join #tmptotal_Invd_Saleonly_qty tmpInvdSale on tempMfr.[Manufacturer] = tmpInvdSale.Manufacturer  
 Join #tmptotal_Invd_Freeonly_qty tmpInvdfree on tempMfr.[Manufacturer] = tmpInvdfree.Manufacturer  
 Join #tmptotal_rcvd_qty tmprcvdqty on tempMfr.[Manufacturer] = tmprcvdqty.Manufacturer  
  
 END                                
END                             
ELSE                      
BEGIN                                
 IF @ShowItems = 'Items with stock'                 
 BEGIN                            
 print 'current date stock only Items'   
  Select [Manufacturer ID], [Manufacturer], "Total On Hand Qty" =  Sum([Total On Hand Qty]),  
  ----  
   "Total SIT Qty" =   
  ( select IsNull(sum(IDR.pending), 0)  
   from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR, Items Itm, @tmpProd tmpprd   
   where IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId and IDR.Product_code = Itm.Product_code  
    and Itm.product_code = tmpprd.Product_code  
    and Itm.ManufacturerID = Manufact.[Manufacturer ID]  
  ),           
  ----  
  "On Hand Value" = Sum([On Hand Value]),                             
  ----  
  "Total SIT Value" = (Select Isnull(   
  (case @StockVal        
  When 'PTS' Then       
  Sum( Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0))  
    Else (Isnull(IDR.pending, 0) * Isnull(Itms.PTS, 0)) End )  
  When 'PTR' Then        
  Sum(Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0))   
    Else (Isnull(IDR.pending, 0) * Isnull(Itms.PTR, 0)) End )  
  When 'ECP' Then   
  --purchaseat instead of ecp  
  Sum(Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) *   
     ( case when isnull(Itms.purchased_at, 0) = 1 then Isnull(Itms.PTS, 0) else Isnull(Itms.PTR, 0) end ))   
    Else (Isnull(IDR.pending, 0) *   
     ( case when isnull(Itms.purchased_at, 0) = 1 then Isnull(Itms.PTS, 0) else Isnull(Itms.PTR, 0) end ))  
   End )  
  When 'MRP' Then        
  isnull(Sum(isnull(IDR.pending, 0) * Isnull(Itms.MRP, 0)),0)              
  When 'Special Price' Then      
  Sum(Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.Company_Price, 0))   
    Else (Isnull(IDR.pending, 0) * Isnull(Itms.Company_Price, 0)) End )  
  Else      
  --pts instead of PurchasePrice  
  isnull(Sum(isnull(IDR.pending, 0) * isnull(itms.pts, 0)),0)              
  End), 0 )  
  from InvoiceDetailReceived IDR, InvoiceabstractReceived IAR, Items Itms, ItemCategories I_Ctg, @tmpProd tmpprd   
  where IAR.InvoiceId = IDR.InvoiceId and IAR.Status & 64 = 0 
  and Itms.product_code = tmpprd.Product_code  
  and Itms.Product_Code = IDR.Product_Code and Itms.CategoryID = I_Ctg.CategoryID   
  and isnull(IDR.saleprice, 0) > 0 And itms.ManufacturerID = Manufact.[Manufacturer ID] ),  
  ----  
  --"Tax Suffered (%)" = Sum([Tax Suffered (%)]),         
 "Tax suffered" = Sum([Tax suffered]), "Total On Hand Value" = Sum([Total On Hand Value]),        
 "Saleable Stock" = Sum([Saleable Stock]),  
 ----  
 "Saleable SIT Qty" =   
  ( select IsNull(sum(IDR.pending), 0)  
   from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR, Items Itm, @tmpProd tmpprd   
   where IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId and IDR.Product_code = Itm.Product_code  
    and Itm.product_code = tmpprd.Product_code  
    and Itm.ManufacturerID = Manufact.[Manufacturer ID]  
    and IDR.Saleprice > 0  
  ),           
 ----  
  
 "Saleable Value" =  Sum([Saleable Value]),                      
 ----  
 "Saleable SIT Value" = (Select Isnull(  
  (case @StockVal        
  When 'PTS' Then       
  Sum( Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0))  
    Else (Isnull(IDR.pending, 0) * Isnull(Itms.PTS, 0)) End )  
  When 'PTR' Then        
  Sum(Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0))   
    Else (Isnull(IDR.pending, 0) * Isnull(Itms.PTR, 0)) End )  
  When 'ECP' Then   
  --putchaseat instead of ecp      
  Sum(Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) *   
     ( case when isnull(Itms.purchased_at, 0) = 1 then Isnull(Itms.PTS, 0) else Isnull(Itms.PTR, 0) end ))   
    Else (Isnull(IDR.pending, 0) *   
     ( case when isnull(Itms.purchased_at, 0) = 1 then Isnull(Itms.PTS, 0) else Isnull(Itms.PTR, 0) end )) End )  
  When 'MRP' Then        
  isnull(Sum(isnull(IDR.pending, 0) * Isnull(Itms.MRP, 0)),0)              
  When 'Special Price' Then      
  Sum(Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.Company_Price, 0))   
    Else (Isnull(IDR.pending, 0) * Isnull(Itms.Company_Price, 0)) End )  
  Else      
  --pts instead of PurchasePrice  
  isnull(Sum(isnull(IDR.pending, 0) * isnull(itms.MRP, 0)),0)              
  End), 0)      
  from InvoiceDetailReceived IDR, InvoiceabstractReceived IAR, Items Itms, ItemCategories I_Ctg, @tmpProd tmpprd   
  where IAR.InvoiceId = IDR.InvoiceId and IAR.Status & 64 = 0 
  and Itms.product_code = tmpprd.Product_code  
  and Itms.Product_Code = IDR.Product_Code and Itms.CategoryID = I_Ctg.CategoryID   
  and isnull(IDR.saleprice, 0) > 0 And itms.ManufacturerID = Manufact.[Manufacturer ID] ),  
 ----  
  "Free OnHand Qty" = Sum([Free OnHand Qty]),  
 ----  
 "Free SIT Qty" =   
  ( select IsNull(sum(IDR.pending), 0)  
   from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR, Items Itm, @tmpProd tmpprd  
   where IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId and IDR.Product_code = Itm.Product_code  
    and Itm.product_code = tmpprd.Product_code  
    and Itm.ManufacturerID = Manufact.[Manufacturer ID]  
    and IDR.Saleprice = 0  
  ),           
 ----  
  "Damages Qty" = Sum([Damages Qty]), "Damages Value" = Sum([Damages Value]) from                            
  (      
 Select "Manufacturer ID" = Items.ManufacturerID, "Manufacturer" = M1.Manufacturer_Name,                                
   "Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0),                                 
  "On Hand Value" =                       
   case @StockVal                      
   When 'PTS'  Then                    
   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(obp.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End) End)                
   When 'PTR' Then                    
   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(obp.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End) End)                
   When 'ECP' Then                    
   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(obp.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End) End)         
   When 'MRP' Then                    
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0)End)),0)                     
   When 'Special Price' Then                    
   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(obp.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End) End)                
   Else                    
   isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                        
   End,                     
  -- "Tax Suffered (%)" = (select Sum(Batch_Products.TaxSuffered)          
  --  from Items It, Batch_Products          
  --  where It.Product_Code = Batch_Products.Product_Code and           
  --  It.ManufacturerID = M1.ManufacturerID           
  --  And ItemCategories.CategoryID = It.CategoryID          
  --  And IsNull(Batch_Products.Damage,0) NOT IN (1,2)       
  --  And Batch_Products.batch_code = obp.batch_code),                                                     
   "Tax suffered" =                             
  Case isnull(obp.TaxOnMRP,0)                              
  When 1 Then                              
   Case Isnull(ItemCategories.Price_option, 0)                               
   When 1 Then                              
   ISNULL(Round(SUM((QUANTITY * obp.purchaseprice) * (obp.TaxSuffered / 100)),2), 0)                              
   Else                              
   ISNULL(Round(SUM((QUANTITY * Items.ECP) * (obp.TaxSuffered / 100)),2), 0)                               
   End                              
  Else                     
  Case Isnull(ItemCategories.Price_option, 0)                    
  When 1 Then                    
         ISNULL(Round(SUM((QUANTITY * obp.PurchasePrice) * (obp.TaxSuffered / 100 )),2), 0)                    
  Else                 
    ISNULL(Round(SUM((Case [Free] When 1 Then 0 Else (QUANTITY * Items.Purchase_Price) * (obp.TaxSuffered / 100)End)),2), 0)                       
  End                  
  End,                      
   "Total On Hand Value" =                             
   case @StockVal                                
   When 'PTS' Then                               
   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * obp.PTS + Round(QUANTITY * obp.PTS * (obp.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.PTS + Round(QUANTITY * Items.PTS * (obp.TaxSuffered / 100),2)) End) End ), 0)                                                                              
   When 'PTR' Then                              
   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * obp.PTR + Round(QUANTITY * obp.PTR * (obp.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.PTR + Round(QUANTITY * Items.PTR * (obp.TaxSuffered / 100),2)) End) End ), 0)                
   When 'ECP' Then                               
   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * obp.ECP + Round(QUANTITY * obp.ECP * (obp.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.ECP + Round(QUANTITY * Items.ECP * (obp.TaxSuffered / 100),2)) End) End ), 0)                
   When 'MRP' Then                               
   ISNULL(SUM( (Case [Free] When 1 Then 0 Else QUANTITY * Items.MRP + Round(QUANTITY * Items.MRP * (obp.TaxSuffered / 100),2)End) ), 0)                               
   When 'Special Price' Then                    
   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * obp.Company_Price + Round(QUANTITY * obp.Company_Price * (obp.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.Company_Price + Round(QUANTITY * Items.Company_Price * (obp.TaxSuffered / 100),2)) End) End ), 0)                
   Else                            
   ISNULL(SUM(QUANTITY * PurchasePrice + Round(QUANTITY * PurchasePrice * (obp.TaxSuffered / 100),2)), 0)                               
    End,                      
   "Saleable Stock" = (select isnull(Sum(Quantity),0) from batch_products, Items It where It.Product_Code = Batch_Products.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = It.CategoryID And batch_products.batch_code = obp.batch_code) ,                                
   "Saleable Value" = (select      
   case @StockVal                            
   When 'PTS'  Then                          
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(batch_products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTS, 0)) End)                      
   When 'PTR' Then                          
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(batch_products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTR, 0)) End)                      
   When 'ECP' Then                          
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(batch_products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)                      
   When 'MRP' Then                          
   isnull(Sum(isnull(Quantity, 0) * isnull(It.MRP, 0)),0)                           
   When 'Special Price' Then                          
   Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(batch_products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)                      
   Else                          
   isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                              
   End                             
   from batch_products, Items It, ItemCategories IC where IC.CategoryID = It.CategoryID AND It.Product_Code = Batch_Products.Product_Code 
and isnull(free,0)=0 and isnull(damage,0) = 0 
And It.ManufacturerID = M1.ManufacturerID 
And ItemCategories.CategoryID = It.CategoryID and batch_products.batch_code = obp.batch_code),        
   "Free OnHand Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items It where It.Product_Code = Batch_Products.Product_Code and free <> 0 And IsNull(Damage, 0) <> 1 And It.ManufacturerID = M1.ManufacturerID 
And ItemCategories.CategoryID = It.CategoryID And batch_products.batch_code = obp.batch_code),                      
   "Damages Qty" = (select isnull(sum(Quantity),0) from Batch_Products, Items It where It.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = It.CategoryID 
And batch_products.batch_code = obp.batch_code),              
    "Damages Value" = (select                     
    case @StockVal                            
    When 'PTS'  Then                          
    Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTS, 0)) End)              
    When 'PTR' Then                          
    Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTR, 0)) End)                      
    When 'ECP' Then                          
    Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)                      
    When 'MRP' Then                          
    IsNull(Sum(Case IsNull(Free, 0) When 1 Then 0 Else isnull(Quantity, 0) * isnull(it.MRP, 0) End ), 0)      
    When 'Special Price' Then                          
    Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(Batch_Products.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)                    
    Else                          
    isnull(Sum(isnull(Quantity, 0) * isnull(Batch_Products.PurchasePrice, 0)),0)                              
    End                              
  from Items It, Batch_Products, ItemCategories       
 where It.CategoryID = ItemCategories.CategoryID AND       
 It.Product_Code = Batch_Products.Product_Code and isnull(damage,0) <> 0 And       
 It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = It.CategoryID      
 And Batch_Products.batch_code = obp.batch_code)                                
      
  from Items
  Left Outer Join Batch_Products obp On Items.Product_Code = obp.Product_Code 
  Inner Join Manufacturer M1  On Items.ManufacturerID = M1.ManufacturerID 
  Inner Join ItemCategories On ItemCategories.CategoryID = Items.CategoryID                             
  WHERE  M1.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpMfr)        
   AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)        
   and M1.Active = 1                               
  GROUP BY Items.ManufacturerID, M1.ManufacturerID, M1.Manufacturer_Name,       
 obp.TaxOnMRP, ItemCategories.Price_option, ItemCategories.CategoryID , obp.batch_code                              
  HAVING ISNULL(SUM(QUANTITY), 0) > 0      
) Manufact                            
  Group By [Manufacturer ID], [Manufacturer]                  
 END                            
 ELSE                            
 BEGIN                            
  print 'current date all Items'   
  Select  [Manufacturer ID], [Manufacturer],  "Total On Hand Qty" =  Sum([Total On Hand Qty]),   
  ----  
   "Total SIT Qty" =   
  ( select IsNull(sum(IDR.pending), 0)  
   from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR, Items Itm, @tmpProd tmpprd  
   where IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId and IDR.Product_code = Itm.Product_code  
    and Itm.product_code = tmpprd.Product_code  
    and Itm.ManufacturerID = Manufact.[Manufacturer ID]   
  ),           
  ----  
  "On Hand Value" = Sum([On Hand Value]),                             
  ----  
  "Total SIT Value" = (Select Isnull(  
  ( case @StockVal        
  When 'PTS' Then       
  Sum( Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0))  
    Else (Isnull(IDR.pending, 0) * Isnull(Itms.PTS, 0)) End )  
  When 'PTR' Then        
  Sum(Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0))   
    Else (Isnull(IDR.pending, 0) * Isnull(Itms.PTR, 0)) End )  
  When 'ECP' Then   
  --purchaseat instead of ecp      
  Sum(Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) *   
     ( case when isnull(Itms.purchased_at, 0) = 1 then Isnull(Itms.PTS, 0) else Isnull(Itms.PTR, 0) end ))   
    Else (Isnull(IDR.pending, 0) *   
     ( case when isnull(Itms.purchased_at, 0) = 1 then Isnull(Itms.PTS, 0) else Isnull(Itms.PTR, 0) end )) End )  
  When 'MRP' Then        
  isnull(Sum(isnull(IDR.pending, 0) * Isnull(Itms.MRP, 0)),0)              
  When 'Special Price' Then      
  Sum(Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.Company_Price, 0))   
    Else (Isnull(IDR.pending, 0) * Isnull(Itms.Company_Price, 0)) End )  
  Else      
  --pts instead of PurchasePrice  
  isnull(Sum(isnull(IDR.pending, 0) * isnull(Itms.pts, 0)),0)              
  End), 0)      
  from InvoiceDetailReceived IDR, InvoiceabstractReceived IAR, Items Itms, ItemCategories I_Ctg, @tmpProd tmpprd   
  where IAR.InvoiceId = IDR.InvoiceId and IAR.Status & 64 = 0  
     and Itms.product_code = tmpprd.Product_code  
  and Itms.Product_Code = IDR.Product_Code and Itms.CategoryID = I_Ctg.CategoryID   
  and isnull(IDR.saleprice, 0) > 0 And itms.ManufacturerID = Manufact.[Manufacturer ID] ),  
  ----  
  
 -- "Tax Suffered (%)" = Sum([Tax Suffered (%)]),         
 "Tax suffered" = Sum([Tax suffered]),         
 "Total On Hand Value" = Sum([Total On Hand Value]),        
 "Saleable Stock" = Sum([Saleable Stock]),  
 ----  
 "Saleable SIT Qty" =   
  ( select IsNull(sum(IDR.pending), 0)  
   from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR, Items Itm, @tmpProd tmpprd   
   where IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId and IDR.Product_code = Itm.Product_code  
    and Itm.product_code = tmpprd.Product_code  
    and Itm.ManufacturerID = Manufact.[Manufacturer ID]  
    and IDR.Saleprice > 0  
  ),           
 ----  
 "Saleable Value" = Sum([Saleable Value]),                             
 ----  
 "Saleable SIT Value" = (Select Isnull(  
  (case @StockVal        
  When 'PTS' Then       
  Sum( Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTS, 0))  
    Else (Isnull(IDR.pending, 0) * Isnull(Itms.PTS, 0)) End )  
  When 'PTR' Then        
  Sum(Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.PTR, 0))   
    Else (Isnull(IDR.pending, 0) * Isnull(Itms.PTR, 0)) End )  
  When 'ECP' Then   
  --purchaseat instead of ecp      
  Sum(Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) *   
     ( case when isnull(Itms.purchased_at, 0) = 1 then Isnull(Itms.PTS, 0) else Isnull(Itms.PTR, 0) end ))   
   Else (Isnull(IDR.pending, 0) *   
     ( case when isnull(Itms.purchased_at, 0) = 1 then Isnull(Itms.PTS, 0) else Isnull(Itms.PTR, 0) end ))  
   End )  
  When 'MRP' Then        
  isnull(Sum(isnull(IDR.pending, 0) * Isnull(Itms.MRP, 0)),0)              
  When 'Special Price' Then      
  Sum(Case I_Ctg.Price_Option When 1 Then (Isnull(IDR.pending, 0) * Isnull(IDR.Company_Price, 0))   
    Else (Isnull(IDR.pending, 0) * Isnull(Itms.Company_Price, 0)) End )  
  Else      
  --pts instead of PurchasePrice  
  isnull(Sum(isnull(IDR.pending, 0) * isnull(itms.pts, 0)),0)              
  End), 0)      
  from InvoiceDetailReceived IDR, InvoiceabstractReceived IAR, Items Itms, ItemCategories I_Ctg, @tmpProd tmpprd   
  where IAR.InvoiceId = IDR.InvoiceId and IAR.Status & 64 = 0  
  and Itms.product_code = tmpprd.Product_code  
  and Itms.Product_Code = IDR.Product_Code and Itms.CategoryID = I_Ctg.CategoryID   
  and isnull(IDR.saleprice, 0) > 0 And itms.ManufacturerID = Manufact.[Manufacturer ID] ),  
 ----  
  "Free OnHand Qty" = Sum([Free OnHand Qty]),  
 ----  
 "Free SIT Qty" =   
  ( select IsNull(sum(IDR.pending), 0)  
   from InvoiceabstractReceived IAR, InvoiceDetailReceived IDR, Items Itm, @tmpProd tmpprd  
   where IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId and IDR.Product_code = Itm.Product_code  
    and Itm.product_code = tmpprd.Product_code  
    and Itm.ManufacturerID = Manufact.[Manufacturer ID]  
    and IDR.Saleprice = 0  
  ),           
 ----  
    
  "Damages Qty" = Sum([Damages Qty]), "Damages Value" = Sum([Damages Value]) from                            
 (      
 Select  "Manufacturer ID" = Items.ManufacturerID, "Manufacturer" = M1.Manufacturer_Name,        
   "Total On Hand Qty" = ISNULL(SUM(QUANTITY), 0),                                 
  "On Hand Value" =                       
   case @StockVal                      
   When 'PTS'  Then                    
   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(obp.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.PTS, 0)) End) End)                
   When 'PTR' Then                    
   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(obp.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.PTR, 0)) End) End)                
   When 'ECP' Then                    
   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(obp.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.ECP, 0)) End) End)                
   When 'MRP' Then                    
   isnull(Sum((Case [Free] When 1 Then 0 Else isnull(Quantity, 0) * isnull(Items.MRP, 0)End)),0)                     
   When 'Special Price' Then                    
   Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(obp.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (Isnull(Quantity, 0) * Isnull(Items.Company_Price, 0)) End) End)        
   Else                    
   isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                        
   End,                                 
 -- "Tax Suffered (%)" =  (select sum(IsNull((Tax.Percentage),0)) from         
 -- Items a, Batch_Products bts, tax where a.Product_Code *= bts.Product_Code And        
 --  and Tax.Tax_Code =* a.TaxSuffered And bts.batch_code = Batch_Products.batch_code),      
         
 --  "Tax Suffered (%)" = (select Sum(Batch_Products.TaxSuffered)            
 --   from Items It, Batch_Products            
 --   where It.Product_Code = Batch_Products.Product_Code and             
 --   It.ManufacturerID = M1.ManufacturerID             
 --   And ItemCategories.CategoryID = It.CategoryID And       
 --Batch_Products.batch_code = obp.batch_code And Batch_Products.Quantity > 0       
 --   And IsNull(Batch_Products.Damage,0) NOT IN (1,2)        
 --),                                  
   "Tax suffered" =                             
  Case isnull(obp.TaxOnMRP,0)                              
  When 1 Then                              
   Case Isnull(ItemCategories.Price_option, 0)                               
   When 1 Then                              
  ISNULL(Round(SUM((QUANTITY * obp.PurchasePrice) * (obp.TaxSuffered / 100)),2), 0)                              
   Else                              
   ISNULL(Round(SUM((QUANTITY * Items.ECP) * (obp.TaxSuffered / 100)),2), 0)                               
   End                              
  Else                              
  Case Isnull(ItemCategories.Price_option, 0)                  
  When 1 Then                  
  ISNULL(Round(SUM((QUANTITY * obp.PurchasePrice) * (obp.TaxSuffered / 100 )),2), 0)                  
  Else               
   ISNULL(Round(SUM((Case [Free] When 1 Then 0 Else (QUANTITY * Items.Purchase_Price) * (obp.TaxSuffered / 100)End)),2), 0)                     
  End                   
  End,                            
   "Total On Hand Value" =                             
   case @StockVal                                
   When 'PTS' Then                               
   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * obp.PTS + Round(QUANTITY * obp.PTS * (obp.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.PTS + Round(QUANTITY * Items.PTS * (obp.TaxSuffered / 100),2)) 
End) End ), 0)                                                                              
   When 'PTR' Then                              
   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * obp.PTR + Round(QUANTITY * obp.PTR * (obp.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.PTR + Round(QUANTITY * Items.PTR * (obp.TaxSuffered / 100),2)) End) End ), 0)                
   When 'ECP' Then                               
   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * obp.ECP + Round(QUANTITY * obp.ECP * (obp.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.ECP + Round(QUANTITY * Items.ECP * (obp.TaxSuffered / 100),2)) End) End ), 0)                
   When 'MRP' Then                               
   ISNULL(SUM( (Case [Free] When 1 Then 0 Else QUANTITY * Items.MRP + Round(QUANTITY * Items.MRP * (obp.TaxSuffered / 100),2)End) ), 0)                               
   When 'Special Price' Then                               
   ISNULL(SUM(Case ItemCategories.Price_Option When 1 Then (QUANTITY * obp.Company_Price + Round(QUANTITY * obp.Company_Price * (obp.TaxSuffered / 100),2)) Else (Case [Free] When 1 Then 0 Else (QUANTITY * Items.Company_Price + 
Round(QUANTITY * Items.Company_Price * (obp.TaxSuffered / 100),2)) End) End ), 0)                
   Else                            
   ISNULL(SUM(QUANTITY * PurchasePrice + Round(QUANTITY * PurchasePrice * (obp.TaxSuffered / 100),2)), 0)                               
    End,               
                            
   "Saleable Stock" = (select isnull(Sum(Quantity),0) from batch_products bts, Items It where It.Product_Code = bts.Product_Code and isnull(free,0)=0 and isnull(damage,0) = 0 And It.ManufacturerID = M1.ManufacturerID 
And ItemCategories.CategoryID = It.CategoryID And bts.Batch_Code = obp.batch_code),                                
   "Saleable Value" = (Select                               
    case @StockVal                            
    When 'PTS'  Then                          
    Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTS, 0)) End)                     
    When 'PTR' Then                          
    Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTR, 0)) End)                      
    When 'ECP' Then                          
    Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)                      
    When 'MRP' Then                          
    isnull(Sum(isnull(Quantity, 0) * isnull(It.MRP, 0)),0)                           
    When 'Special Price' Then                          
    Sum(Case IC.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)                      
    Else                          
    isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                              
    End                             
  from batch_products bts, Items It, ItemCategories  IC                  
                   
 where IC.CategoryID = It.CategoryID AND                  
 It.Product_Code = bts.Product_Code                   
 and isnull(free,0)=0 and isnull(damage,0) = 0                   
 And It.ManufacturerID = M1.ManufacturerID                   
 And ItemCategories.CategoryID = It.CategoryID        
 And bts.Batch_Code = obp.Batch_Code),                                  
   "Free OnHand Qty" = (select isnull(sum(Quantity),0) from Batch_Products bts,         
   Items It where It.Product_Code = bts.Product_Code and free <> 0 And IsNull(Damage, 0) <> 1 And         
   It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = It.CategoryID        
   And bts.Batch_Code = obp.Batch_Code),                        
           
 "Damages Qty" = (select isnull(sum(Quantity),0) from Batch_Products bts, Items It where         
 It.Product_Code = bts.Product_Code and isnull(damage,0) <> 0 And         
 It.ManufacturerID = M1.ManufacturerID And ItemCategories.CategoryID = It.CategoryID        
 And bts.Batch_Code = obp.Batch_Code),                
         
 "Damages Value" = (select           
    case @StockVal        
    When 'PTS'  Then                          
    Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.PTS, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTS, 0)) End)                      
    When 'PTR' Then                          
    Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.PTR, 0)) Else (Isnull(Quantity, 0) * Isnull(It.PTR, 0)) End)                      
    When 'ECP' Then                          
    Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.ECP, 0)) Else (Isnull(Quantity, 0) * Isnull(It.ECP, 0)) End)                      
    When 'MRP' Then                          
    IsNull(Sum(Case IsNull(bts.Free, 0) When 1 Then 0 Else isnull(Quantity, 0) * isnull(it.MRP, 0) End ), 0)      
    When 'Special Price' Then                          
    Sum(Case ItemCategories.Price_Option When 1 Then (Isnull(Quantity, 0) * Isnull(bts.Company_Price, 0)) Else (Isnull(Quantity, 0) * Isnull(It.Company_Price, 0)) End)                      
    Else                          
    isnull(Sum(isnull(Quantity, 0) * isnull(PurchasePrice, 0)),0)                              
    End                               
  from Items It, Batch_Products bts, ItemCategories where         
 It.CategoryID = ItemCategories.CategoryID And It.Product_Code = bts.Product_Code         
 and isnull(damage,0) <> 0 And It.ManufacturerID = M1.ManufacturerID And         
 ItemCategories.CategoryID = It.CategoryID And bts.Batch_Code = obp.Batch_Code)                                
  from Items
  Left Outer Join  Batch_Products obp On Items.Product_Code = obp.Product_Code         
  Inner Join Manufacturer M1 On Items.ManufacturerID = M1.ManufacturerID
  Left Outer Join  tax On items.taxsuffered = tax.tax_code                             
  Inner Join ItemCategories On ItemCategories.CategoryID = Items.CategoryID                                                    
  WHERE  M1.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpMfr)        
   AND Items.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpProd)        
   and M1.Active = 1                               
  GROUP BY Items.ManufacturerID, M1.ManufacturerID, M1.Manufacturer_Name,          
  obp.TaxOnMRP, ItemCategories.Price_option,         
  ItemCategories.CategoryID, obp.Batch_Code      
)   Manufact                            
  Group By [Manufacturer ID], [Manufacturer]                            
 END                              
END                            
  
                          
