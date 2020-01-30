CREATE PROCEDURE spr_list_stock_ledger_by_category    
(    
 @Category NVarChar(2550),    
 @FromDate DateTime,               
 @ShowItems NVarChar(50),    
 @StockVal NVarChar(100),    
 @ItemCode NVarChar(2550)    
)    
As                          
Declare @UOMDesc NVarChar(50)                          
Declare @ReportingUOM NVarChar(50)                          
Declare @ConversionUnit NVarChar(50)                          
Declare @Delimeter As NVarChar(1)                
    
Set @Delimeter = Char(15)                
    
Declare @TmpProd Table(Product_Code NVarChar(255) Collate SQL_LatIn1_General_CP1_CI_As)    
Create Table #TempCategory(CategoryID Int, Status Int)     
Declare @TmpAllUOMCnt Table(CategoryID BigInt,UOMCnt BigInt,CUOMCnt BigInt,RUOMCnt BigInt)    
Declare @TmpUOMDes Table(CategoryID BigInt,UOM NVarChar(510) Collate SQL_LatIn1_General_CP1_CI_As)    
Declare @TmpCUOMDes Table(CategoryID BigInt,CUOM NVarChar(510) Collate SQL_LatIn1_General_CP1_CI_As)    
Declare @TmpRUOMDes Table(CategoryID BigInt,RUOM NVarChar(510) Collate SQL_LatIn1_General_CP1_CI_As)    
-- To get the leaf level categories for the given parent category    
Exec GetLeafCategories N'%', @Category    

Select     
 Distinct "Category"=ItemCategories.Category_Name    
Into    
 #TmpCategory    
From    
 #TempCategory,ItemCategories    
Where    
 ItemCategories.CategoryID = #TempCategory.CategoryID    

If @ItemCode = N'%'    
 Insert Into @TmpProd Select Product_Code From Items    
Else    
 Insert Into @TmpProd Select * From dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)    

If (DatePart(dy, @FromDate) < DatePart(dy, GetDate()) And DatePart(yyyy, @FromDate) = DatePart(yyyy, GetDate())) Or  DatePart(yyyy, @FromDate) < DatePart(yyyy, GetDate())                         
 Begin  
	----temp tables for SIT
	create table #tmptotal_Invd_Saleonly_qty( 
		CategoryID int
		, Saleableqty decimal(18, 6)
		, salablevalue decimal(18, 6)
		)

	create table #tmptotal_Invd_Freeonly_qty( 
		CategoryID int
		, freeqty decimal(18, 6)
		, freevalue decimal(18, 6)
		)

	create table #tmptotal_rcvd_qty( 
		CategoryID int
		, saleableqty decimal(18, 6)
		, freeqty decimal(18, 6)
		, salablevalue decimal(18, 6)
		, freevalue decimal(18, 6)
		)


		create table #tmpPreviousDate( 
		CategoryID int
		, Category  nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
		, [Total On Hand Qty]  NVarChar(255) Collate SQL_LatIn1_General_CP1_CI_As
		, [Conversion Unit] NVarChar(50) Collate SQL_LatIn1_General_CP1_CI_As
		, [Reporting UOM]   NVarChar(50) Collate SQL_LatIn1_General_CP1_CI_As
		, [Total On Hand Value] decimal(18, 6)	
		, [Saleable Stock] decimal(18, 6)
		, [Saleable Value] decimal(18, 6)
		, [Free OnHand Qty] decimal(18, 6)
		, [Damages Qty] decimal(18, 6)
		, [Damages Value] decimal(18, 6)
		)
--, [Reporting UOM]  NVarChar(50) Collate SQL_LatIn1_General_CP1_CI_As

	-- total_Invoiced_qty(SaleableOnly-Qty)

		Insert Into #tmptotal_Invd_Saleonly_qty
		select tempCtg.CategoryID, isnull(sum(IDR.quantity), 0)
		,isnull(sum(IDR.quantity * (case @StockVal                    
					   When 'PTS' Then Items.PTS
					   When 'PTR' Then Items.PTR
					   When 'ECP' Then Items.ECP
					   When 'MRP' Then Items.MRP
					   When 'Special Price' Then Items.Company_Price
					   Else Items.MRP End)), 0) 
		from  #TempCategory tempCtg					
		join Items  on tempctg.CategoryID= Items.categoryid
		left outer join InvoiceDetailReceived IDR on IDR.product_code = Items.product_code and IDR.Saleprice > 0 
		left outer join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
			and IAR.Status & 64 = 0 and  IAR.InvoiceDate < dateadd(d, 1, @FromDate) 
			and IAR.Invoicetype = 0 and IDR.Saleprice > 0 
		where Items.Active = 1 
		group by tempCtg.CategoryID 

		-- total_Invoiced_Freeonly_qty
		Insert Into #tmptotal_Invd_Freeonly_qty
		select  tempCtg.CategoryID, isnull(sum(IDR.quantity), 0)
		,isnull(sum(IDR.quantity * (case @StockVal                    
					   When 'PTS' Then Items.PTS
					   When 'PTR' Then Items.PTR
					   When 'ECP' Then Items.ECP
					   When 'MRP' Then Items.MRP
					   When 'Special Price' Then Items.Company_Price
					   Else Items.MRP End)), 0) 
		from #TempCategory tempCtg		
		join Items on tempctg.CategoryID = Items.categoryid
		left outer join InvoiceDetailReceived IDR on IDR.product_code = Items.product_code  and IDR.Saleprice = 0 
		left outer join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId and IAR.Invoicetype = 0 
			and IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FromDate) 
		where Items.Active = 1 
		group by tempCtg.CategoryID  
 

	-- total_received_qty(Saleable), total_received_qty(Free)
	Insert Into #tmptotal_rcvd_qty
	select tempCtg.CategoryID, IsNull(sum(gdt.quantityreceived), 0), IsNull(sum(gdt.Freeqty), 0)
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
		from #TempCategory tempCtg		 
		join Items on tempctg.CategoryID = Items.categoryid
		join grndetail gdt on gdt.product_code = Items.product_code
		join grnabstract gab on gab.grnId = gdt.grnId and gab.RecdInvoiceId in 
			(	select InvoiceId from Invoiceabstractreceived IAR 
				where IAR.Status & 64 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FromDate) 
				and IAR.Invoicetype = 0 
			)  and  gab.grnstatus & 96 = 0
		where Items.Active = 1 
		group by tempCtg.CategoryID
	


--select * from #tmptotal_Invd_Saleonly_qty 
--select * from #tmptotal_Invd_Freeonly_qty
--select * from #tmptotal_rcvd_qty
--  -----	


	    
  Insert Into @TmpAllUOMCnt(CategoryID,UOMCnt,CUOMCnt,RUOMCnt)    
  Select    
   Items.CategoryID,Count(Distinct Items.UOM),    
   Count(Distinct Items.ConversionUnit),Count(Distinct Items.ReportingUOM)    
  From    
   Items
   Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
   Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID                             
  Where    
   ItemCategories.Category_Name In (Select Category Collate SQL_LatIn1_General_CP1_CI_As From #TmpCategory)    
   And Items.Product_Code In (Select Product_Code Collate SQL_LatIn1_General_CP1_CI_As From @TmpProd)    
   And OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate)                          
  Group By    
   Items.CategoryID    
    
  Insert Into @TmpUOMDes(CategoryID,UOM)    
  Select     
   TA.CategoryID,UOM.[Description]    
  From    
   @TmpAllUOMCnt TA,Items,UOM,ConversionTable    
  Where    
   UOMCnt = 1    
   And TA.CategoryID = Items.CategoryID    
   And Items.UOM = UOM.UOM    
  Group by    
   TA.CategoryID,UOM.[Description]    
    
  Insert Into @TmpCUOMDes(CategoryID,CUOM)    
  Select     
   TA.CategoryID,ConversionTable.ConversionUnit    
  From    
   @TmpAllUOMCnt TA,Items,UOM,ConversionTable    
  Where    
   CUOMCnt = 1    
   And TA.CategoryID = Items.CategoryID    
   And Items.ConversionUnit = ConversionTable.ConversionID      
  Group by    
   TA.CategoryID,ConversionTable.ConversionUnit    
    
  Insert Into @TmpRUOMDes(CategoryID,RUOM)    
  Select     
   TA.CategoryID, UOM.[Description]    
  From    
   @TmpAllUOMCnt TA,Items,UOM,ConversionTable    
  Where    
   RUOMCnt = 1    
   And TA.CategoryID = Items.CategoryID    
   And Items.ReportingUOM = UOM.UOM      
  Group by    
   TA.CategoryID,UOM.[Description]    
    
  If @ShowItems = 'Items with stock'                      
   Begin 
	Insert into #tmpPreviousDate	                      	
    Select    
    Items.CategoryID,"Category" = ItemCategories.Category_Name,                           
    "Total On Hand Qty" = Cast(IsNull(Sum(OpeningDetails.Opening_Quantity),0) As NVarChar)   + ' ' + IsNull((Select UOM From @TmpUOMDes Where CategoryID = Items.CategoryID),''),    
	"Conversion Unit" =     
	 Case (Select TA.CUOMCnt From @TmpAllUOMCnt TA Where TA.CategoryID = Items.CategoryID)     
	 When 1 Then Cast(Cast(Sum(IsNull(Items.ConversionFactor,0) * IsNull(OpeningDetails.Opening_Quantity, 0))As Decimal(18,6)) As NVarChar) + ' ' + IsNull((Select CUOM From @TmpCUOMDes Where CategoryID = Items.CategoryID),'')    
     Else ''       
     End,     
     "Reporting UOM" =     
     Case (Select TA.RUOMCnt From @TmpAllUOMCnt TA Where TA.CategoryID = Items.CategoryID)     
     When 1 Then Cast(Sum(dbo.Sp_Get_ReportingQty(IsNull(OpeningDetails.Opening_Quantity, 0), (Case IsNull(Items.ReportingUnit,0) When 0 Then 1 Else IsNull(Items.ReportingUnit,0) End))) As NVarChar)+ ' ' +   
	 IsNull((Select RUOM From @TmpRUOMDes Where CategoryID = Items.CategoryID),'')    
     Else ''       
     End,    
     "Total On Hand Value" =                   
     Case @StockVal                    
     When 'PTS' Then Sum((IsNull(OpeningDetails.Opening_Quantity - Free_Opening_Quantity, 0) * IsNull(Items.PTS, 0)))                        
     When 'PTR' Then Sum((IsNull(OpeningDetails.Opening_Quantity - Free_Opening_Quantity, 0) * IsNull(Items.PTR, 0)))                        
     When 'ECP' Then Sum((IsNull(OpeningDetails.Opening_Quantity - Free_Opening_Quantity, 0) * IsNull(Items.ECP, 0)))                        
     When 'MRP' Then Sum((IsNull(OpeningDetails.Opening_Quantity - Free_Opening_Quantity, 0) * IsNull(Items.MRP, 0)))                        
     When 'Special Price' Then Sum((IsNull(OpeningDetails.Opening_Quantity - Free_Opening_Quantity, 0) * IsNull(Items.Company_Price, 0)))                        
     Else Sum(IsNull(OpeningDetails.Opening_Value, 0))                      
     End,	                  
     "Saleable Stock" = Sum(IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(OpeningDetails.Free_Saleable_Quantity,0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0)),                        	 
     "Saleable Value" =                     
      Case @StockVal                      
      When 'PTS' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTS, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTS, 0))                        
      When 'PTR' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTR, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTR, 0))                        
      When 'ECP' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.ECP, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.ECP, 0))                        
      When 'MRP' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.MRP, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.MRP, 0))                        
      When 'Special Price' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.Company_Price, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.Company_Price, 0))                        
      Else Sum(IsNull(OpeningDetails.Opening_Value,0) - IsNull(OpeningDetails.Damage_Opening_Value,0))                    
      End, 		                   
     "Free OnHand Qty" = IsNull(Sum(OpeningDetails.Free_Saleable_Quantity ), 0),                          	
     "Damages Qty" = IsNull(Sum(OpeningDetails.Damage_Opening_Quantity),0),                          
     "Damages Value" =                   
      Case @StockVal                    
      When 'PTS' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTS, 0)), 0)                      
      When 'PTR' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTR, 0)), 0)                      
      When 'ECP' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.ECP, 0)), 0)                      
      When 'MRP' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.MRP, 0)), 0)      
      When 'Special Price' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.Company_Price, 0)), 0)                      
      Else IsNull(Sum(OpeningDetails.Damage_Opening_Value), 0)                      
      End                  
	  From     
      Items
	  Left Outer Join  OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
	  Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID
	  Inner Join ConversionTable CT On CT.ConversionID = Items.ConversionUnit       
	  Where    
      ItemCategories.Active = 1                      
      And ItemCategories.Category_Name In (Select Category Collate SQL_LatIn1_General_CP1_CI_As From #TmpCategory)    
      And Items.Product_Code In (Select Product_Code From @TmpProd)    
      And OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate)    	
      Group By    
      Items.CategoryID, ItemCategories.Category_Name    
      Having    
      IsNull(Sum(OpeningDetails.Opening_Quantity), 0) > 0 
	 

	 select tempPre.CategoryID, tempPre.Category
	 , tempPre.[Total On Hand Qty]
	 , "Total SIT Qty" = ( ( tmpInvdSale.Saleableqty + tmpInvdfree.freeqty ) - tmprcvdqty.saleableqty - tmprcvdqty.freeqty )
	 , tempPre.[Conversion Unit]
	 , tempPre.[Reporting UOM]
	 , tempPre.[Total On Hand Value]
	 , "Total SIT Value" = ( tmpInvdSale.salablevalue - tmprcvdqty.salablevalue )		
	 , tempPre.[Saleable Stock]
     , "Saleable SIT Qty" = ( tmpInvdSale.Saleableqty - tmprcvdqty.saleableqty  )
	 , tempPre.[Saleable Value]
	 , "Saleable SIT Value" = ( tmpInvdSale.salablevalue - tmprcvdqty.salablevalue )    
	 , tempPre.[Free OnHand Qty]
	 , "Free SIT Qty" =  ( tmpInvdfree.freeqty - tmprcvdqty.freeqty )  
	 , tempPre.[Damages Qty]
	 , tempPre.[Damages Value]
	 from #tmpPreviousDate tempPre --tempMfr 
	 join #tmptotal_Invd_Saleonly_qty tmpInvdSale on tempPre.[CategoryID] = tmpInvdSale.CategoryID
	 Join #tmptotal_Invd_Freeonly_qty tmpInvdfree on tempPre.[CategoryID] = tmpInvdfree.CategoryID
	 Join #tmptotal_rcvd_qty tmprcvdqty on tempPre.[CategoryID] = tmprcvdqty.CategoryID                     
    End                      
  Else                      
   Begin  
	Insert into #tmpPreviousDate                      
    Select    
    Items.CategoryID,"Category" = ItemCategories.Category_Name,                           
    "Total On Hand Qty" = Cast(IsNull(Sum(OpeningDetails.Opening_Quantity), 0) As NVarChar)   + ' ' + IsNull((Select UOM From @TmpUOMDes Where CategoryID = Items.CategoryID),''),    	 			
    "Conversion Unit" =     
     Case (Select TA.CUOMCnt From @TmpAllUOMCnt TA Where TA.CategoryID = Items.CategoryID)     
     When 1 Then Cast(Cast(Sum(IsNull(Items.ConversionFactor,0) * IsNull(OpeningDetails.Opening_Quantity, 0))As Decimal(18,6)) As NVarChar) + ' ' + IsNull((Select CUOM From @TmpCUOMDes Where CategoryID = Items.CategoryID),'')    
     Else ''       
     End,     
     "Reporting UOM" =     
     Case (Select TA.RUOMCnt From @TmpAllUOMCnt TA Where TA.CategoryID = Items.CategoryID)     
     When 1 Then Cast(Sum(dbo.Sp_Get_ReportingQty(IsNull(OpeningDetails.Opening_Quantity, 0), (Case IsNull(Items.ReportingUnit,0) When 0 Then 1 Else IsNull(Items.ReportingUnit,0) End))) As NVarChar)+ ' '   
		+ IsNull((Select RUOM From @TmpRUOMDes Where CategoryID = Items.CategoryID),'')    
     Else ''       
     End,    
     "Total On Hand Value" =                   
	  Case @StockVal               
      When 'PTS' Then Sum((IsNull(OpeningDetails.Opening_Quantity - Free_Opening_Quantity, 0) * IsNull(Items.PTS, 0)))                        
      When 'PTR' Then Sum((IsNull(OpeningDetails.Opening_Quantity - Free_Opening_Quantity, 0) * IsNull(Items.PTR, 0)))                        
      When 'ECP' Then Sum((IsNull(OpeningDetails.Opening_Quantity - Free_Opening_Quantity, 0) * IsNull(Items.ECP, 0)))                        
      When 'MRP' Then Sum((IsNull(OpeningDetails.Opening_Quantity - Free_Opening_Quantity, 0) * IsNull(Items.MRP, 0)))                        
      When 'Special Price' Then Sum((IsNull(OpeningDetails.Opening_Quantity - Free_Opening_Quantity, 0) * IsNull(Items.Company_Price, 0)))                        
      Else Sum(IsNull(OpeningDetails.Opening_Value, 0))                      
      End, 	 
	
     "Saleable Stock" = Sum(IsNull(OpeningDetails.Opening_Quantity,0) - IsNull(OpeningDetails.Free_Saleable_Quantity,0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0)),                        
	 "Saleable Value" =                     
      Case @StockVal                      
      When 'PTS' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTS, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTS, 0))                        
      When 'PTR' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTR, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTR, 0))                        
      When 'ECP' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.ECP, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.ECP, 0))                        
      When 'MRP' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.MRP, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.MRP, 0))                        
      When 'Special Price' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.Company_Price, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.Company_Price, 0))               
      Else Sum(IsNull(OpeningDetails.Opening_Value,0) - IsNull(OpeningDetails.Damage_Opening_Value,0))                    
      End,				                    
     "Free OnHand Qty" = IsNull(Sum(OpeningDetails.Free_Saleable_Quantity ), 0),                          
	 "Damages Qty" = IsNull(Sum(OpeningDetails.Damage_Opening_Quantity),0),                          
     "Damages Value" =                   
      Case @StockVal                    
      When 'PTS' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTS, 0)), 0)                      
      When 'PTR' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTR, 0)), 0)                      
      When 'ECP' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.ECP, 0)), 0)                     
      When 'MRP' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.MRP, 0)), 0)                      
      When 'Special Price' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.Company_Price, 0)), 0)                      
      Else IsNull(Sum(OpeningDetails.Damage_Opening_Value), 0)                      
      End                  
     From    
     Items
	 Left Outer Join OpeningDetails On  Items.Product_Code = OpeningDetails.Product_Code
	 Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID                                                    	
	 Where     
     ItemCategories.Active = 1                      
     And ItemCategories.Category_Name In (Select Category Collate SQL_LatIn1_General_CP1_CI_As From #TmpCategory)    
     And Items.Product_Code In (Select Product_Code Collate SQL_LatIn1_General_CP1_CI_As From @TmpProd)    
     And OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate)      
     Group By    
     Items.CategoryID, ItemCategories.Category_Name  

	select tempPre.CategoryID, tempPre.Category
	, tempPre.[Total On Hand Qty]
	, "Total SIT Qty" = ( ( tmpInvdSale.Saleableqty + tmpInvdfree.freeqty ) - tmprcvdqty.saleableqty - tmprcvdqty.freeqty )
	, tempPre.[Conversion Unit]
	, tempPre.[Reporting UOM]
	, tempPre.[Total On Hand Value]
	, "Total SIT Value" = ( tmpInvdSale.salablevalue - tmprcvdqty.salablevalue )		
	, tempPre.[Saleable Stock]
    , "Saleable SIT Qty" = ( tmpInvdSale.Saleableqty - tmprcvdqty.saleableqty  )
	, tempPre.[Saleable Value]
	, "Saleable SIT Value" = ( tmpInvdSale.salablevalue - tmprcvdqty.salablevalue )    
	, tempPre.[Free OnHand Qty]
	, "Free SIT Qty" =  ( tmpInvdfree.freeqty - tmprcvdqty.freeqty )  
	, tempPre.[Damages Qty]
	, tempPre.[Damages Value]
	from #tmpPreviousDate tempPre 
	join #tmptotal_Invd_Saleonly_qty tmpInvdSale on tempPre.[CategoryID] = tmpInvdSale.CategoryID
	Join #tmptotal_Invd_Freeonly_qty tmpInvdfree on tempPre.[CategoryID] = tmpInvdfree.CategoryID
	Join #tmptotal_rcvd_qty tmprcvdqty on tempPre.[CategoryID] = tmprcvdqty.CategoryID	  
   End                                         
 End                          
Else                          
 Begin                          
  Insert Into @TmpAllUOMCnt(CategoryID,UOMCnt,CUOMCnt,RUOMCnt)    
  Select    
   Items.CategoryID,    
   Count(Distinct Items.UOM),    
   Count(Distinct Items.ConversionUnit),    
   Count(Distinct Items.ReportingUOM)    
  From    
   Items
   Left Outer Join Batch_Products On Items.Product_Code = Batch_Products.Product_Code
   Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID                             
  Where    
   ItemCategories.Category_Name In (Select Category Collate SQL_LatIn1_General_CP1_CI_As From #TmpCategory)    
   And Items.Product_Code In (Select Product_Code Collate SQL_LatIn1_General_CP1_CI_As From @TmpProd)    
  Group By    
   Items.CategoryID    
      
  Insert Into @TmpUOMDes(CategoryID,UOM)    
  Select     
   TA.CategoryID,UOM.[Description]    
  From    
   @TmpAllUOMCnt TA,Items,UOM,ConversionTable    
  Where    
   UOMCnt = 1    
   And TA.CategoryID = Items.CategoryID    
   And Items.UOM = UOM.UOM    
  Group by    
   TA.CategoryID,UOM.[Description]    
      
  Insert Into @TmpCUOMDes(CategoryID,CUOM)    
  Select     
   TA.CategoryID,ConversionTable.ConversionUnit    
  From    
   @TmpAllUOMCnt TA,Items,UOM,ConversionTable    
  Where    
   CUOMCnt = 1    
   And TA.CategoryID = Items.CategoryID    
   And Items.ConversionUnit = ConversionTable.ConversionID      
  Group by    
   TA.CategoryID,ConversionTable.ConversionUnit    
      
  Insert Into @TmpRUOMDes(CategoryID,RUOM)    
  Select     
   TA.CategoryID,UOM.[Description]    
  From    
   @TmpAllUOMCnt TA,Items,UOM,ConversionTable    
  Where    
   RUOMCnt = 1    
   And TA.CategoryID = Items.CategoryID    
   And Items.ReportingUOM = UOM.UOM      
  Group by    
   TA.CategoryID,UOM.[Description]    
      
  If @ShowItems = 'Items with stock'                      
   Begin                      
    Select    
     ItemCategories.CategoryID, "Category" = ItemCategories.Category_Name,                          
     "Total On Hand Qty" = Cast(IsNull(Sum(Quantity), 0) As NVarChar)   + ' ' + IsNULL((Select UOM From @TmpUOMDes Where CategoryID =  ItemCategories.CategoryID),''),    
	--Total SIT Qty
	 "Total SIT Qty" = IsNULL ((Select (Cast(IsNull(Sum(IDR.pending), 0) As NVarChar)) 
			from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items, ItemCategories C1  
			Where IAR.InvoiceID = IDR.InvoiceID
            And IAR.Status & 64 = 0
			And Items.CategoryID = C1.CategoryID And C1.CategoryID = ItemCategories.CategoryID 
			And Items.Product_Code = IDR.Product_Code 
			And C1.Active = 1  
			And Items.Active =1   
			Group By  Items.CategoryID, C1.Category_Name),0)  + ' ' + IsNULL((Select UOM From @TmpUOMDes Where CategoryID =  ItemCategories.CategoryID),''),    
     "Conversion Unit" =     
      Case (Select TA.CUOMCnt From @TmpAllUOMCnt TA Where TA.CategoryID = ItemCategories.CategoryID)     
       When 1 Then Cast(Cast(Sum(IsNull(I1.ConversionFactor,0) * IsNull(Quantity, 0))As Decimal(18,6)) As NVarChar) + ' ' + IsNull((Select CUOM From @TmpCUOMDes Where CategoryID = ItemCategories.CategoryID),'')    
       Else ''       
      End,    
     "Reporting UOM" =     
      Case (Select TA.RUOMCnt From @TmpAllUOMCnt TA Where TA.CategoryID = ItemCategories.CategoryID)     
		When 1 Then Cast(Sum(dbo.Sp_Get_ReportingQty(IsNull(Quantity, 0),(Case IsNull(I1.ReportingUnit,0) When 0 Then 1 Else IsNull(I1.ReportingUnit,0) End))) As NVarChar)+ ' ' + IsNull((Select RUOM From @TmpRUOMDes   
			Where CategoryID = ItemCategories.CategoryID),'')    
		Else ''    
      End,    
     "Total On Hand Value" =                     
      Case @StockVal    
       When 'PTS'  Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.PTS, 0)) End) End)       
       When 'PTR' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.PTR, 0)) End) End)              
       When 'ECP' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.ECP, 0)) End) End)              
       When 'MRP' Then IsNull(Sum((Case [Free] When 1 Then 0 Else IsNull(Quantity, 0) * IsNull(I1.MRP, 0)End)),0)                   
       When 'Special Price' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.Company_Price, 0)) End) End)               
       Else IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchasePrice, 0)),0)                      
      End,               

	 --Total SIT Value
     "Total SIT Value" =    
      IsNull((    
       Select                 
        Case @StockVal    		    
        When 'PTS' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * IsNull(IDR.PTS, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0)) End) End)           
        When 'PTR' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * IsNull(IDR.PTR, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0)) End) End)		
        When 'ECP' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0)) End) End)		
        When 'MRP' Then IsNull(Sum(Case IsNull(IDR.SalePrice, 0) When 0 Then 0 Else IsNull(IDR.Pending, 0) * IsNull(Items.MRP, 0) End ), 0)    		
        When 'Special Price' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * IsNull(IDR.Company_Price, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0)) End) End)           		
        Else IsNull(Sum(IsNull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)),0)                      
        End                
       From InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items, ItemCategories C1                           
       Where IAR.InvoiceID = IDR.InvoiceID
        And IAR.Status & 64 = 0
		And C1.Active = 1  And Items.Active =1        
        And Items.CategoryID = C1.CategoryID                           
        And C1.CategoryID = ItemCategories.CategoryID                          
        And Items.Product_Code = IDR.Product_Code                           
       Group By    
        Items.CategoryID, C1.Category_Name    
      ),0),    
	

     "Saleable Stock" =     
      IsNull((    
       Select    
        IsNull(Sum(Quantity),0)                           
       From    
        Batch_Products, Items, ItemCategories C1                           
       Where    
		IsNull(Free,0)= 0 And IsNull(Damage,0) = 0                                   
        And Items.CategoryID = C1.CategoryID                           
        And C1.CategoryID = ItemCategories.CategoryID                          
		And Items.Product_Code = Batch_Products.Product_Code                           
       Group By    
        Items.CategoryID, C1.Category_Name    
      ),0),  

	-- Saleable SIT QTY
	 "Saleable SIT Qty" = isnull((select Sum(IDR.Pending) from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items ,ItemCategories C1  
	 where IAR.InvoiceID = IDR.InvoiceID
     And IAR.Status & 64 = 0
	 And C1.Active = 1  And Items.Active =1   
	 And Items.CategoryID = C1.CategoryID
	 And C1.CategoryID = ItemCategories.CategoryID                      
	 And Items.Product_Code = IDR.Product_Code                           
	 And isnull (IDR.SalePrice,0) > 0
	 Group By    
     Items.CategoryID, C1.Category_Name),0), 	
                      
     "Saleable Value" =    
      IsNull((    
       Select                 
        Case @StockVal    
        When 'PTS' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTS, 0)) End)              
        When 'PTR' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTR, 0)) End)              
        When 'ECP' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.ECP, 0)) End)              
        When 'MRP' Then IsNull(Sum(Case IsNull(Free, 0) When 1 Then 0 Else IsNull(Quantity, 0) * IsNull(Items.MRP, 0) End ), 0)    
        When 'Special Price' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.Company_Price, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.Company_Price, 0)) End)              
        Else IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchasePrice, 0)),0)                      
        End                
       From    
        Batch_Products, Items, ItemCategories C1                           
       Where     
	IsNull(Free,0)=0 And IsNull(Damage,0) = 0                           
        And Items.CategoryID = C1.CategoryID                           
        And C1.CategoryID = ItemCategories.CategoryID                          
        And Items.Product_Code = Batch_Products.Product_Code                           
       Group By    
        Items.CategoryID, C1.Category_Name    
      ),0),    

	 --Saleable SIT Value	
	"Saleable SIT Value" = Isnull((Select             
	case @StockVal            
	When 'PTS'  Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * IsNull(IDR.PTS, 0)) Else (IsNull(IDR.Pending, 0) * IsNull(Items.PTS, 0)) End)                     		
	When 'PTR' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * IsNull(IDR.PTR, 0)) Else (IsNull(IDR.Pending, 0) * IsNull(Items.PTR, 0)) End)                      		
	When 'ECP' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)) Else (IsNull(IDR.Pending, 0) * IsNull(Items.ECP, 0)) End)                       		      
	When 'MRP' Then IsNull(Sum(Case IsNull(IDR.Pending, 0) When 0 Then 0 Else IsNull(IDR.Pending, 0) * IsNull(Items.MRP, 0) End ), 0)             		
	When 'Special Price' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * IsNull(IDR.Company_Price, 0)) Else (IsNull(IDR.Pending, 0) * IsNull(Items.Company_Price, 0)) End)                      	
	Else IsNull(Sum(IsNull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)),0)                      		
	End
	from InvoiceAbstractReceived IAR,
    InvoiceDetailReceived IDR, Items, ItemCategories C1                           
    Where IAR.InvoiceID = IDR.InvoiceID
    And IAR.Status & 64 = 0
	And C1.Active = 1  And Items.Active =1   
    And Items.CategoryID = C1.CategoryID                           
    And C1.CategoryID = ItemCategories.CategoryID                          
    And Items.Product_Code = IDR.Product_Code                           
	And IDR.SalePrice > 0
    Group By    
    Items.CategoryID, C1.Category_Name ),0),             
	

   "Free OnHand Qty" =    
   IsNull((    
    Select    
	IsNull(Sum(Quantity),0)    
    From    
    Batch_Products, Items, ItemCategories C1                           
    Where    
	Free <> 0 And IsNull(Damage, 0) <> 1            
	And Items.CategoryID = C1.CategoryID                           
	And C1.CategoryID = ItemCategories.CategoryID                          
	And Items.Product_Code = Batch_Products.Product_Code                           
		Group By    
        Items.CategoryID, C1.Category_Name    
      ),0),             

	--Free SIT Qty
	"Free SIT Qty" = isnull((select IsNULL(sum(IDR.Pending),0) from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items ,ItemCategories C1
	Where IAR.InvoiceID = IDR.InvoiceID
    And IAR.Status & 64 = 0
	And C1.Active = 1  And Items.Active =1   
	And	Items.CategoryID = C1.CategoryID                           
	And C1.CategoryID = ItemCategories.CategoryID                          
	And Items.Product_Code = IDR.Product_Code 
	And IDR.SalePrice = 0                          
	Group By    
    Items.CategoryID, C1.Category_Name ),0),
	           
     "Damages Qty" =    
      IsNull((    
       Select    
        IsNull(Sum(Quantity),0)    
       From    
        Batch_Products, Items, ItemCategories C1                           
       Where    
        IsNull(Damage,0) <> 0 And Items.CategoryID = C1.CategoryID                           
        And C1.CategoryID = ItemCategories.CategoryID                          
        And Items.Product_Code = Batch_Products.Product_Code                           
       Group By    
        Items.CategoryID, C1.Category_Name    
      ),0),                        
     "Damages Value" =     
      IsNull((    
      Select                    
       Case @StockVal    
        When 'PTS'  Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTS, 0)) End)              
        When 'PTR' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTR, 0)) End)              
        When 'ECP' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.ECP, 0)) End)              
        When 'MRP' Then IsNull(Sum(Case IsNull(Free, 0) When 1 Then 0 Else IsNull(Quantity, 0) * IsNull(Items.MRP, 0) End ), 0)    
        When 'Special Price' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.Company_Price, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.Company_Price, 0)) End)              
        Else IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchasePrice, 0)),0)                      
       End                 
      From    
       Items, Batch_Products, ItemCategories C1                         
      Where    
	IsNull(Damage,0) <> 0 And Items.CategoryID = C1.CategoryID         
	And C1.CategoryID = ItemCategories.CategoryID         
	And Items.Product_Code = Batch_Products.Product_Code                           
      Group By    
       Items.CategoryID, C1.Category_Name),  0)                        
    From    
     Items I1
	 Left Outer Join Batch_Products On  I1.Product_Code = Batch_Products.Product_Code
	 Inner Join  ItemCategories On I1.CategoryID = ItemCategories.CategoryID                                                    
    Where    
    ItemCategories.Active = 1                      
    And ItemCategories.Category_Name In (Select Category Collate SQL_LatIn1_General_CP1_CI_As From #TmpCategory)    
    And I1.Product_Code In (Select Product_Code Collate SQL_LatIn1_General_CP1_CI_As From @TmpProd)    
    Group BY    
    ItemCategories.CategoryID,ItemCategories.Category_Name    
    Having    
    IsNull(Sum(Quantity), 0) > 0                      
   End                      
  Else                      
   Begin                    
    Select    
   ItemCategories.CategoryID, "Category" = ItemCategories.Category_Name,                          
     "Total On Hand Qty" = Cast(IsNull(Sum(Quantity), 0) As NVarChar)   + ' ' + IsNULL((Select UOM From @TmpUOMDes Where CategoryID =  ItemCategories.CategoryID),''),    
	 -- Total SIT Qty	
	 "Total SIT Qty" = IsNULL((Select (Cast(IsNull(Sum(IDR.pending), 0) As NVarChar)) 
			from InvoiceAbstractReceived IAR,InvoiceDetailReceived IDR ,Items,ItemCategories C1 
			Where IAR.InvoiceID = IDR.InvoiceID And IAR.Status & 64 = 0 And Items.CategoryID = C1.CategoryID And C1.CategoryID = ItemCategories.CategoryID And Items.Product_Code = IDR.Product_Code And Items.Active =1 Group By  Items.CategoryID, C1.Category_Name),0)  + ' ' + IsNULL((Select UOM From @TmpUOMDes Where CategoryID =  ItemCategories.CategoryID),''),    
	---
     "Conversion Unit" =     
      Case (Select TA.CUOMCnt From @TmpAllUOMCnt TA Where TA.CategoryID = ItemCategories.CategoryID)     
       When 1 Then Cast(Cast(Sum(IsNull(I1.ConversionFactor,0) * IsNull(Quantity, 0))As Decimal(18,6)) As NVarChar) + ' ' + IsNull((Select CUOM From @TmpCUOMDes Where CategoryID = ItemCategories.CategoryID),'')    
       Else ''       
      End,    
     "Reporting UOM" =     
      Case (Select TA.RUOMCnt From @TmpAllUOMCnt TA Where TA.CategoryID = ItemCategories.CategoryID)     
       When 1 Then Cast(Sum(dbo.Sp_Get_ReportingQty(IsNull(Quantity, 0),(Case IsNull(I1.ReportingUnit,0) When 0 Then 1 Else IsNull(I1.ReportingUnit,0) End))) As NVarChar)+ ' ' + IsNull((Select RUOM From @TmpRUOMDes   
		Where CategoryID = ItemCategories.CategoryID),'')    
       Else ''    
      End,    
     "Total On Hand Value" =                     
      Case @StockVal                    
       When 'PTS'  Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.PTS, 0)) End) End)              
       When 'PTR' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.PTR, 0)) End) End)              
       When 'ECP' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.ECP, 0)) End) End)       
       When 'MRP' Then IsNull(Sum((Case [Free] When 1 Then 0 Else IsNull(Quantity, 0) * IsNull(I1.MRP, 0)End)),0)                   
       When 'Special Price' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.Company_Price, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.Company_Price, 0)) End) End)               
       Else IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchasePrice, 0)),0)                      
      End,                    
      
	-- Total SIT Value
	  "Total SIT Value" =    
      IsNull((    
       Select                 
        Case @StockVal    		    		
        When 'PTS' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * IsNull(IDR.PTS, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTS, 0)) End) End) 		
        When 'PTR' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * IsNull(IDR.PTR, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.PTR, 0)) End) End) 		              
        When 'ECP' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.ECP, 0)) End) End)              		
        When 'MRP' Then IsNull(Sum(Case IsNull(IDR.SalePrice, 0) When 0 Then 0 Else IsNull(IDR.Pending, 0) * IsNull(Items.MRP, 0) End ), 0)    		
        When 'Special Price' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * IsNull(IDR.Company_Price, 0)) Else (Case (IDR.SalePrice) When 0 Then 0 Else (Isnull(IDR.Pending, 0) * Isnull(Items.Company_Price, 0)) End) End)              		              		
        Else IsNull(Sum(IsNull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)),0)                      
        End                
       From InvoiceAbstractReceived IAR,
        InvoiceDetailReceived IDR, Items, ItemCategories C1                           
       Where IAR.InvoiceID = IDR.InvoiceID     
        And IAR.Status & 64 = 0
		And C1.Active = 1  And Items.Active = 1           
		And Items.CategoryID = C1.CategoryID                           
        And C1.CategoryID = ItemCategories.CategoryID                          
        And Items.Product_Code = IDR.Product_Code                  		
       Group By    
        Items.CategoryID, C1.Category_Name    
      ),0), 
	
     "Saleable Stock" =    
      IsNull((    
       Select    
        IsNull(Sum(Quantity),0)                           
       From    
        Batch_Products, Items, ItemCategories C1                           
       Where    
	IsNull(Free,0)=0 And IsNull(Damage,0) = 0                           
        And Items.CategoryID = C1.CategoryID                           
        And C1.CategoryID = ItemCategories.CategoryID                          
        And Items.Product_Code = Batch_Products.Product_Code                           		
       Group By    
        Items.CategoryID,C1.Category_Name),0),  

	 --Salabel SIT Qty
	  "Saleable SIT Qty" = isnull((select isnull(Sum(IDR.Pending),0) 
		from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items ,ItemCategories C1  
      where 
	  IAR.InvoiceID = IDR.InvoiceID 	
      And IAR.Status & 64 = 0
	  And C1.Active = 1  And Items.Active =1   
	  And Items.CategoryID = C1.CategoryID                           
      And C1.CategoryID = ItemCategories.CategoryID                          
      And Items.Product_Code = IDR.Product_Code
	  And isnull (IDR.SalePrice,0) > 0                           
      Group By    
      Items.CategoryID,C1.Category_Name),0),  


     "Saleable Value" =    
      IsNull((    
       Select                
        Case @StockVal                    
         When 'PTS'  Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTS, 0)) End)              
         When 'PTR' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTR, 0)) End)              
         When 'ECP' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.ECP, 0)) End)       
		 When 'MRP' Then IsNull(Sum(IsNull(Quantity, 0) * IsNull(Items.MRP, 0)),0)                   
         When 'Special Price' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.Company_Price, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.Company_Price, 0)) End)              
         Else IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchasePrice, 0)),0)                      
        End                
       From    
        Batch_Products, Items, ItemCategories C1                           
       Where    
        IsNull(Free,0)=0 And IsNull(Damage,0) = 0                           
        And C1.CategoryID = ItemCategories.CategoryID                          
        And Items.CategoryID = C1.CategoryID                
        And Items.Product_Code = Batch_Products.Product_Code                           
       Group By    Items.CategoryID, C1.Category_Name    
      ),0),                        

--	Salabel SIT Value
 	"Saleable SIT Value" = Isnull((Select             
	case @StockVal            	        
	When 'PTS' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * IsNull(IDR.PTS, 0)) Else (IsNull(IDR.Pending, 0) * IsNull(Items.PTS, 0)) End)              		
	When 'PTR' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * IsNull(IDR.PTR, 0)) Else (IsNull(IDR.Pending, 0) * IsNull(Items.PTR, 0)) End)              
    When 'ECP' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)) Else (IsNull(IDR.Pending, 0) * IsNull(Items.ECP, 0)) End)       
	When 'MRP' Then IsNull(Sum(IsNull(IDR.Pending, 0) * IsNull(Items.MRP, 0)),0)                   
	When 'Special Price' Then Sum(Case C1.Price_Option When 1 Then (IsNull(IDR.Pending, 0) * IsNull(IDR.Company_Price, 0)) Else (IsNull(IDR.Pending, 0) * IsNull(Items.Company_Price, 0)) End)              
	Else isnull(Sum(isnull(IDR.Pending, 0) * isnull((case Items.Purchased_At When 1 Then IDR.PTS Else IDR.PTR end) ,0)),0)              
	End           
	from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items, ItemCategories C1 
	where IAR.InvoiceID = IDR.InvoiceID
     And IAR.Status & 64 = 0
	 And C1.Active = 1  And Items.Active =1   	  
	 And C1.CategoryID = ItemCategories.CategoryID                          
	 And Items.CategoryID = C1.CategoryID                
	 And Items.Product_Code = IDR.Product_Code                           
	 And IDR.SalePrice > 0
	Group By Items.CategoryID, C1.Category_Name ),0),   
	
     "Free OnHand Qty" =    
      IsNull((    
       Select    
        IsNull(Sum(Quantity),0)    
       From    
        Batch_Products,Items,ItemCategories C1                           
       Where    
	Free <> 0 And IsNull(Damage, 0) <> 1  
	And C1.CategoryID = ItemCategories.CategoryID         
	And Items.CategoryID = C1.CategoryID                           
	And Items.Product_Code = Batch_Products.Product_Code                           
       Group By    
        Items.CategoryID, C1.Category_Name    
      ),0),                        

	--Free SIT Qty		
	"Free SIT Qty" =
		isnull((
		select 
		IsNULL(sum(IDR.Pending),0) 
		from InvoiceAbstractReceived IAR, InvoiceDetailReceived IDR, Items ,ItemCategories C1
		Where IAR.InvoiceID = IDR.InvoiceID 
        And IAR.Status & 64 = 0   	
		And C1.Active = 1  And Items.Active =1   
		And C1.CategoryID = ItemCategories.CategoryID                  
		And Items.CategoryID = C1.CategoryID                           
		And Items.Product_Code = IDR.Product_Code                           
		And IDR.SalePrice = 0                          
		Group By    
		Items.CategoryID, C1.Category_Name ),0),

     "Damages Qty" =    
      IsNull((    
       Select    
        IsNull(Sum(Quantity),0)    
       From    
        Batch_Products,Items,ItemCategories C1                           
       Where    
		IsNull(Damage,0) <> 0 And Items.CategoryID = C1.CategoryID                           
		And C1.CategoryID = ItemCategories.CategoryID                          
		And Items.Product_Code = Batch_Products.Product_Code                       
       Group By    
        Items.CategoryID, C1.Category_Name    
      ),0), 
                       
     "Damages Value" =    
      IsNull((    
       Select                    
        Case @StockVal                    
         When 'PTS'  Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTS, 0)) End)              
         When 'PTR' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.PTR, 0)) End)              
         When 'ECP' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.ECP, 0)) End)              
         When 'MRP' Then IsNull(Sum(Case IsNull(Free, 0) When 1 Then 0 Else IsNull(Quantity, 0) * IsNull(Items.MRP, 0) End ), 0)    
         When 'Special Price' Then Sum(Case C1.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.Company_Price, 0)) Else (IsNull(Quantity, 0) * IsNull(Items.Company_Price, 0)) End)              
         Else IsNull(Sum(IsNull(Quantity, 0) * IsNull(PurchasePrice, 0)),0)                      
        End    
		From    
        Items, Batch_Products, ItemCategories C1                           
		Where    
		IsNull(Damage,0) <> 0 And Items.CategoryID = C1.CategoryID                           
		And C1.CategoryID = ItemCategories.CategoryID                                  
		And Items.Product_Code = Batch_Products.Product_Code                           
       Group By    
        Items.CategoryID, C1.Category_Name    
       ),0)   
    From    
     Items I1
	 Left Outer Join Batch_Products On  I1.Product_Code = Batch_Products.Product_Code
	 Inner Join  ItemCategories On I1.CategoryID = ItemCategories.CategoryID                                                    
    Where    
     ItemCategories.Active = 1                      
     And ItemCategories.Category_Name In (Select Category Collate SQL_LatIn1_General_CP1_CI_As From #TmpCategory)    
     And I1.Product_Code In (Select Product_Code Collate SQL_LatIn1_General_CP1_CI_As From @TmpProd)    
    Group BY    
     ItemCategories.CategoryID,ItemCategories.Category_Name    
   End                      
 End     

Drop Table #TempCategory    

