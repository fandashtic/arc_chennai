Create Procedure spr_WDAvailableBookStock_Abstract_ITC  
  (    
    @Mfr nvarchar(2550),     
    @CategoryGroup nvarchar(2550),    
    @ProductHierarchy nvarchar(100),      
    @Category nvarchar(2550),    
    @ShowItems nvarchar(2000),       
    @UOM nvarchar(50),      
    @StockValuation nvarchar(10),     
    @ItemCode nvarchar(2550),    
    @FromDate datetime)            
AS          
Declare @Delimeter as Char(1)          
Set @Delimeter=Char(15)       
       
Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
Create Table #tempCategory (CategoryID Int, Status Int)           
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)      
Create Table #tempItems (CategoryID Int , Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)                 
Create Table #temp2 (IDS Int IDENTITY(1, 1), CatID Int)        
Create Table #temp3 (CatID Int, Status Int)        
Create Table #temp4 (LeafID Int, CatID Int, Parent nVarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)   

If IsNull(@StockValuation,N'') = N'' or IsNull(@StockValuation,N'') = N'%'     
 Set @StockValuation = N'PTS'     
  
If @Mfr=N'%'           
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer          
Else          
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Mfr,@Delimeter)   
         
If IsNull(@ShowItems,N'') = N'%' or IsNull(@ShowItems,N'') = N''    
 Set @ShowItems = N'All Items'    
    
If IsNull(@UOM,N'') = N'' or @UOM = N'%' or @UOM = N'Base UOM'      
 Set @UOM = N'Sales UOM'       
  
If @ProductHierarchy = N'%' or @ProductHierarchy = N'Division'  
 Set @ProductHierarchy = (select distinct HierarchyName from ItemHierarchy where HierarchyID = 2)    
  
If @ItemCode = N'%'      
Begin  
    Exec Sp_GetCGLeafCat_ITC @CategoryGroup, @ProductHierarchy, @CATEGORY   
	
  Insert Into #TempItems select CategoryID,Product_Code from Items   
    where CategoryID in (Select Distinct CategoryID from #TempCategory)        
End  
Else  
Begin       
   Insert into #TempItems   
  select CategoryID,Product_Code from Items Where Product_Code in  
   (select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter))     
End  

    
  Declare @Counter Int        
  Set @Counter = 1     
  
  -- Procedure for ITC Sorting logic    
  Exec sp_CatLevelwise_ItemSorting    
  
  -- =================================================== 
  -- Code to find the category name according to hierarchy for the Items displayed in Top frame 
  Declare @ContinueA int            
  Declare @CategoryID1 int            
  Set @ContinueA = 1              
   
       
   Insert InTo #temp2   
   Select CatID From dbo.fn_GetCatFrmCG_ITC(@CategoryGroup,@ProductHierarchy,Default)       
  
   Declare @Continue2 Int      
   Declare @Inc Int      
   Declare @TCat Int      
   Set @Inc = 1      
   Set @Continue2 = IsNull((Select Count(*) From #temp2), 0)      
        
   While @Inc <= @Continue2      
   Begin      
    Insert InTo #temp3 Select CatID, 0 From #temp2 Where IDS = @Inc      
    Select @TCat = CatID From #temp2 Where IDS = @Inc      
    While @ContinueA > 0          
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
      Select @ContinueA = Count(*) From #temp3 Where Status = 0          
    End          
    Delete #temp3 Where Status not in  (0, 2)  
            
    Insert InTo #temp4 Select CatID, @TCat,     
    (Select Category_Name From ItemCategories where CategoryID = @TCat) From #temp3      
    Delete #temp3      
    Set @ContinueA = 1      
    Set @Inc = @Inc + 1      
   End           
    
   --=============Code Ends==========
      
If (DatePart(dy, @FromDate) < DatePart(dy, GetDate()) And DatePart(yyyy, @FromDate) = DatePart(yyyy, GetDate())) Or  DatePart(yyyy, @FromDate) < DatePart(yyyy, GetDate())                             
   Begin      
Print 'abc'

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
		from #TempItems tmp left outer join 
		( select IDR.product_code as product_code, idr.quantity as quantity 
			from InvoiceDetailReceived IDR join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
			where IAR.Status & 64 = 0 and IAR.Status & 1 = 0 and IAR.InvoiceDate < dateadd(d, 1, @FromDate) 
			and IAR.Invoicetype = 0 
		) idr on IDR.product_code = tmp.product_code
		group by tmp.product_code 

	 --total_received_qty(Saleable), total_received_qty(Free)
	Insert Into #tmptotal_rcvd_qty
	select tmp.product_code, isnull(sum(gdt.quantityreceived),0), isnull(sum(gdt.Freeqty),0)
		from #TempItems tmp left outer join 
		( select IsNull(gdt.quantityreceived, 0) as quantityreceived, 
			IsNull(gdt.freeqty, 0) as freeqty, gdt.product_code as product_code
			from grndetail gdt 
			join grnabstract gab on gab.grnId = gdt.grnId 
				and gab.grnstatus & 64 = 0 and gab.grnstatus & 32 = 0 
				and gab.RecdInvoiceId in 
			(	select InvoiceId from Invoiceabstractreceived IAR 
				where IAR.Status & 64 = 0 and IAR.Status & 1 = 0 And IAR.InvoiceDate < dateadd(d, 1, @FromDate) 
				and IAR.Invoicetype = 0 
			)
			where gab.GrnDate < dateadd(d, 1, @FromDate) 
		) gdt on gdt.product_code = tmp.product_code
	group by tmp.product_code

	--total_Invoiced_Saleableonly_qty
	Insert Into #tmptotal_Invd_Saleonly_qty
	select tmp.product_code, isnull(sum(IDR.quantity), 0) 
		from #TempItems tmp left outer join 
		( select IDR.product_code as product_code, idr.quantity as quantity 
			from InvoiceDetailReceived IDR join Invoiceabstractreceived IAR on IAR.InvoiceId = IDR.InvoiceId
			where IAR.Status & 64 = 0 and IAR.Status & 1 = 0 And IAR.InvoiceDate < dateadd(d, 1, @FromDate) 
			and IAR.Invoicetype = 0 and IDR.Saleprice > 0 
		) idr on IDR.product_code = tmp.product_code
		group by tmp.product_code 
   
 create table #tmpPreviousDate(   
  [Item Code] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
  , [Item Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
  , [Category]  nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  
  , [UOM]  nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  
  , [Total Quantity] decimal(18, 6)  
  , [Saleable] decimal(18, 6)  
  , [Free] decimal(18, 6)  
  , [Damages] decimal(18, 6)  
  , [Van Saleable Stock ] decimal(18, 6)  
  , [Van Free Stock ] decimal(18, 6)  
  , [DC Saleable Stock ] decimal(18, 6)  
  , [DC Free Stock ] decimal(18, 6)  
  , [Saleable Value] decimal(18, 6)  
  , [Damaged Value] decimal(18, 6)  
  , [Total Value] decimal(18, 6)  
  )  


 create table #tmpPreviousDateUOM1UOM2(   
  [Item Code] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
  , [Item Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
  , [Category]  nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS  
  , [Total CFC] decimal(18, 6)  
  , [PAC] decimal(18, 6)  
  , [Saleable CFC] decimal(18, 6)  
  , [Saleable PAC] decimal(18, 6)  
  , [Free CFC] decimal(18, 6)  
  , [Free PAC] decimal(18, 6)  
  , [Damages CFC] decimal(18, 6)  
  , [Damages PAC] decimal(18, 6)  
  , [Van Saleable CFC ] decimal(18, 6)  
  , [Van Saleable PAC ] decimal(18, 6)  
  , [Van Free CFC ] decimal(18, 6)  
  , [Van Free PAC ] decimal(18, 6)  
  , [DC Saleable CFC ] decimal(18, 6)  
  , [DC Saleable PAC ] decimal(18, 6)  
  , [DC Free CFC ] decimal(18, 6)  
  , [DC Free PAC ] decimal(18, 6)  
  , [Saleable Value] decimal(18, 6)  
  , [Damaged Value] decimal(18, 6)  
  , [Total Value] decimal(18, 6)  
  )  


   If @ShowItems = N'Items with stock'                          
       Begin    
       If @UOM = N'Sales UOM' or @UOM = N'UOM1' or @UOM = N'UOM2'                          
         Begin   
		 Insert into #tmpPreviousDate   
         Select       
          --"Item Code" = Items.Product_Code,     
          "Item_Code" = Items.Product_Code,"Item_Name" = Items.ProductName,    
          "Category" =  #temp4.[Parent],     
          "UOM" = UOM.[Description],    
          "Total Quantity" = Case @UOM When N'Sales UOM' Then Sum(Isnull(Opening_Quantity,0)) - 
							(dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0))					
				  		Else dbo.sp_Get_ReportingQty(sum(Isnull(Opening_Quantity,0))- (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) 
             				 ),        
          			(Case @UOM     
            				When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
            				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
           			 End)) End,        
          "Saleable " = Case @UOM When N'Sales UOM' 
                		 Then sum(Isnull(Opening_Quantity,0) 
									- IsNull(OpeningDetails.Free_Saleable_Quantity,0) 
									- IsNull(OpeningDetails.Damage_Opening_Quantity,0)) - 
                    (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)) Else    
	                		 dbo.sp_Get_ReportingQty(
	                			sum(Isnull(Opening_Quantity,0) 
											- IsNull(OpeningDetails.Free_Saleable_Quantity,0) 
											- IsNull(OpeningDetails.Damage_Opening_Quantity,0))
						          - (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)),        
			                (Case @UOM        
					             		When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
		                   End)) End,    
	        "Free " = Case @UOM When N'Sales UOM' Then sum(Isnull(OpeningDetails.Free_Saleable_Quantity,0) 
												- dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2))        		   
               				Else    
				                dbo.sp_Get_ReportingQty(Sum(IsNull(OpeningDetails.Free_Saleable_Quantity,0)
												- dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),		             
              (Case @UOM         
                When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
                When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
                End)) End,      
          "Damages" = Case @UOM When N'Sales UOM' Then sum(Isnull(OpeningDetails.Damage_Opening_Quantity,0))    
               Else     
              	dbo.sp_Get_ReportingQty(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity,0)),    
              (Case @UOM         
                When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
                When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
                End)) End,

          "Van Saleable Stock " = Case @UOM When N'Sales UOM' 
                		 Then sum(
                   (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1))) Else    
	                		 dbo.sp_Get_ReportingQty(
				         (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)),        
			                  (Case @UOM        
					             		When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
		                   End)) End,
          "Van Free Stock "= Case @UOM When N'Sales UOM' 
                		 Then sum(
                   (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2))) Else    
	                		 dbo.sp_Get_ReportingQty(
				         (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),        
			                  (Case @UOM        
					             		When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
		                   End)) End,
          "DC Saleable Stock "= Case @UOM When N'Sales UOM' 
                		 Then sum(
                   (dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1))) Else    
	                		 dbo.sp_Get_ReportingQty(
				         (dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)),        
			                  (Case @UOM        
					             		When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
		                   End)) End,
          "DC Free Stock "= Case @UOM When N'Sales UOM' 
                		 Then sum(
                   (dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2))) Else    
	                		 dbo.sp_Get_ReportingQty(
				         (dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),        
			                  (Case @UOM        
					             		When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
		                   End)) End,
          "Saleable Value" =
              Cast(Case @StockValuation                           
               When N'PTS' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTS, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTS, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.PTS, 0))
							  - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) * Isnull(Items.PTS,0))                      
               When N'PTR' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTR, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTR, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.PTR, 0))
							  - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) * Isnull(Items.PTR,0))                      
               When N'ECP' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.ECP, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.ECP, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.ECP, 0))
							  - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) * Isnull(Items.ECP,0))                                         
               End as Decimal(18,6)),   
	        "Damaged Value" =     
	           Cast(Case @StockValuation                        
	              When N'PTS' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTS, 0)), 0)    
	              When N'PTR' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTR, 0)), 0)                          
	              When N'ECP' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.ECP, 0)), 0)     
	             End as Decimal(18,6)),       
	        "Total Value" =    
	            Cast(Case @StockValuation                        
	            When N'PTS' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.PTS, 0))
				  					 - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) * Isnull(Items.PTS,0))                           
              When N'PTR' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.PTR, 0))
									   - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) * Isnull(Items.PTR,0))                             
              When N'ECP' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.ECP, 0))
				  					 - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) * Isnull(Items.ECP,0))     
           End as Decimal(18,6))    
           From Items
				Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code
				Inner Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID 
				Inner Join UOM On Uom.Uom = Case @UOM When N'UOM1' Then Items.Uom1 When N'UOM2' Then Items.UOM2 Else Items.UOM End    
				Inner Join ItemCategories On  Items.CategoryID = ItemCategories.CategoryID                               
		        Inner Join #temp4 On #temp4.LeafID = Items.CategoryID
				Inner Join #tempCategory1 On Items.CategoryID = #tempCategory1.CategoryID
				Inner Join #tmpMfr On Manufacturer.Manufacturer_Name = #tmpMfr.Manufacturer
				Inner Join #tempItems On Items.Product_Code = #tempItems.Product_Code 
           Where ItemCategories.Active = 1      
	            And Items.Active = 1 
 		    	And OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate)                        
           Group By        
            	Items.Product_Code,Manufacturer.ManufacturerID, Items.ProductName,  
            	#temp4.[Parent], UOM.[Description],Items.UOM1_Conversion,    
            	Items.UOM2_Conversion, #tempCategory1.[IDs]          
           Having (IsNull(Sum(OpeningDetails.Opening_Quantity), 0) > 0)
           		Order By #tempCategory1.[IDs],Items.Product_Code      


		  select tempPrd.[Item Code], tempPrd.[Item Code], tempPrd.[Item Name]
		 , tempPrd.[Category] 
		 , tempPrd.[UOM]
		 , tempPrd.[Total Quantity]    
		 , tempPrd.[Saleable]  
		 , tempPrd.[Free]  
		 , tempPrd.[Damages]  
		 , tempPrd.[Van Saleable Stock ]  
		 , tempPrd.[Van Free Stock ]
		 , tempPrd.[DC Saleable Stock ] 
		 , tempPrd.[DC Free Stock] 
		 , "SIT Saleable Stock" = Case @UOM When N'Sales UOM' 
                		 Then 
                   Isnull((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),0) Else    
	                		 dbo.sp_Get_ReportingQty(
				         Isnull((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),0),        
			                  (Case @UOM        
					             		When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
		                   End)) End
		 , "SIT Free Stock" = Case @UOM When N'Sales UOM' 
                		 Then 
                   Isnull((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,0) Else    
	                		 dbo.sp_Get_ReportingQty(
				         Isnull((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,0),        
			                  (Case @UOM        
					             		When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
		                   End)) End 


		 , tempPrd.[Saleable Value]  
		 , tempPrd.[Damaged Value] 
		 , tempPrd.[Total Value]
		 from #tmpPreviousDate tempPrd  
		 join #tmptotal_Invd_qty tmpInvqty on tempPrd.[Item Code] = tmpInvqty.Product_Code
		 Join #tmptotal_rcvd_qty tmprcvdqty  on tempPrd.[Item Code] = tmprcvdqty.Product_Code  
		 Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty on tempPrd.[Item Code] = tmpInvdSaleqty.Product_Code  
         Join Items on tempPrd.[Item Code] = Items.Product_Code

        End    
        Else    
        Begin    
        -- Opening Details Top Frame  
		 Insert into #tmpPreviousDateUOM1UOM2  
         Select     
           --"Item Code" = Items.Product_Code,       
           "Item Code" = Items.Product_Code,    
           "Item Name" = Items.ProductName,    
           "Category" = #temp4.Parent,     
           "Total CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(Opening_Quantity,0))- (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0)),1),    
           "PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(Opening_Quantity,0)) - (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0)),2),
           "Saleable CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,Sum(IsNull(OpeningDetails.Opening_Quantity,0) -     
              IsNull(OpeningDetails.Free_Saleable_Quantity,0) -     
              IsNull(OpeningDetails.Damage_Opening_Quantity,0)) - dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),1),    
           "Saleable PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,Sum(IsNull(OpeningDetails.Opening_Quantity,0) -     
              IsNull(OpeningDetails.Free_Saleable_Quantity,0) -     
              IsNull(OpeningDetails.Damage_Opening_Quantity,0)) - dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),2),      
           "Free CFC"=  dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(OpeningDetails.Free_Saleable_Quantity,0)- dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),1),     
           "Free PAC"=  dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(OpeningDetails.Free_Saleable_Quantity,0)- dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),2),      
           "Damaged CFC"= dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(OpeningDetails.Damage_Opening_Quantity,0)),1),    
           "Damaged PAC"= dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(OpeningDetails.Damage_Opening_Quantity,0)),2),                      
           "Van Saleable CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),1),
           "Van Saleable PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),2),
           "Van Free CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2),1),
           "Van Free CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2),2),
		   "DC Saleable CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),1),
           "DC Saleable PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),2),
		   "DC Free CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2),1),
           "DC Free PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2),2),
           "Saleable Value" =                  
             Cast(Case @StockValuation                          
               When N'PTS' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTS, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTS, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.PTS, 0))
																		- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) * Isnull(Items.PTS,0))               
               When N'PTR' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTR, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTR, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.PTR, 0))
																		- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) * Isnull(Items.PTR,0))                      
               When N'ECP' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.ECP, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.ECP, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.ECP, 0))
																		- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) * Isnull(Items.ECP,0))                          
               End as Decimal(18,6)),      
           "Damaged Value" =     
            Cast(Case @StockValuation                        
              When N'PTS' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTS, 0)), 0)                          
              When N'PTR' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTR, 0)), 0)                          
              When N'ECP' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.ECP, 0)), 0)     
            End as Decimal(18,6)) ,       
  			   "Total Value" =    
            Cast(Case @StockValuation                        
              When N'PTS' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.PTS, 0))
				   													- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) * Isnull(Items.PTS,0))                           
              When N'PTR' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.PTR, 0))
				   													- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) * Isnull(Items.PTR,0))                             
              When N'ECP' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.ECP, 0))
				   													- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) * Isnull(Items.ECP,0))     
           End as Decimal(18,6))   
           From  Items
				Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code   
				Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID 
				Inner Join #temp4 On #temp4.LeafID = Items.CategoryID     
				Inner Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID     
				Inner Join #tempCategory1 On Items.CategoryID = #tempCategory1.CategoryID                        
				Inner Join  #tmpMfr On Manufacturer.Manufacturer_Name = #tmpMfr.Manufacturer  
				Inner Join  #tempItems On Items.Product_Code = #tempItems.Product_Code 
           Where OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate)                            
	           And ItemCategories.Active = 1      
	           And Items.Active = 1  
           Group By        
           	 Items.Product_Code, Manufacturer.ManufacturerID, Items.ProductName, #temp4.Parent,   
	           Items.UOM1_Conversion,Items.UOM2_Conversion, #tempCategory1.[IDs]         
           Having        
	           (IsNull(Sum(OpeningDetails.Opening_Quantity), 0) > 0 )
           Order By 
						 #tempCategory1.[IDs],Items.Product_Code  


		  select tempPrd.[Item Code], tempPrd.[Item Code], tempPrd.[Item Name]
		 , tempPrd.[Category] 
		 , tempPrd.[Total CFC]    
		 , tempPrd.[PAC]    
		 , tempPrd.[Saleable CFC]  
		 , tempPrd.[Saleable PAC]  
		 , tempPrd.[Free CFC]  
		 , tempPrd.[Free PAC]  
		 , tempPrd.[Damages CFC]  
		 , tempPrd.[Damages PAC]  
		 , tempPrd.[Van Saleable CFC ]  
		 , tempPrd.[Van Saleable PAC ]  
		 , tempPrd.[Van Free CFC ]
		 , tempPrd.[Van Free PAC ]
		 , tempPrd.[DC Saleable CFC ] 
		 , tempPrd.[DC Saleable PAC ] 
		 , tempPrd.[DC Free CFC ] 
		 , tempPrd.[DC Free PAC ] 
		 , "SIT Saleable CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(tempPrd.[Item Code], IsNull((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),0),1)
		 , "SIT Saleable PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(tempPrd.[Item Code], IsNull((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),0),2)
		 , "SIT Free CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(tempPrd.[Item Code], IsNull((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,0),1)
		 , "SIT Free PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(tempPrd.[Item Code], IsNull((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,0),2)     
		 , tempPrd.[Saleable Value]  
		 , tempPrd.[Damaged Value] 
		 , tempPrd.[Total Value]
		 from #tmpPreviousDateUOM1UOM2 tempPrd   
		 join #tmptotal_Invd_qty tmpInvqty on tempPrd.[Item Code] = tmpInvqty.Product_Code
		 Join #tmptotal_rcvd_qty tmprcvdqty  on tempPrd.[Item Code] = tmprcvdqty.Product_Code  
		 Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty on tempPrd.[Item Code] = tmpInvdSaleqty.Product_Code 

       End     
     End     
   Else If @ShowItems = N'All Items'   
     Begin    
      If @UOM = N'Sales UOM' or @UOM = N'UOM1' or @UOM = N'UOM2'                          
       Begin   
		 Insert into #tmpPreviousDate   
         Select       
          --"Item Code" = Items.Product_Code,     
          "Item_Code" = Items.Product_Code,"Item_Name" = Items.ProductName,    
          "Category" =  #temp4.[Parent],     
          "UOM" = UOM.[Description],    
           "Total Quantity" = Case @UOM When N'Sales UOM' Then Sum(Isnull(Opening_Quantity,0)) - 
							(dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0))					
				  		 Else dbo.sp_Get_ReportingQty(sum(Isnull(Opening_Quantity,0))- (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0)),        
          			(Case @UOM     
            				When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
            				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
           			 End)) End,        
           "Saleable " = Case @UOM When N'Sales UOM' 
                		 Then sum(Isnull(Opening_Quantity,0) 
									- IsNull(OpeningDetails.Free_Saleable_Quantity,0) 
									- IsNull(OpeningDetails.Damage_Opening_Quantity,0) 
                                   ) - (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1))			 
                		  Else    
                	dbo.sp_Get_ReportingQty(
                			sum(Isnull(Opening_Quantity,0) 
											- IsNull(OpeningDetails.Free_Saleable_Quantity,0) 
											- IsNull(OpeningDetails.Damage_Opening_Quantity,0))
				            	- (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) 
             					),        
	               	(Case @UOM        
				             		When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
			   		     				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
	                 End)) End,    
          	"Free " = Case @UOM When N'Sales UOM' Then sum(Isnull(OpeningDetails.Free_Saleable_Quantity,0)-dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2))        		   
               Else    
                dbo.sp_Get_ReportingQty(Sum(IsNull(OpeningDetails.Free_Saleable_Quantity,0) - dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),		             
              (Case @UOM         
                When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
                When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
                End)) End,      
          	"Damages" = Case @UOM When N'Sales UOM' Then sum(Isnull(OpeningDetails.Damage_Opening_Quantity,0))    
               Else     
              dbo.sp_Get_ReportingQty(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity,0)),    
              (Case @UOM  
                When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
                When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
                End)) End,     

          "Van Saleable Stock " = Case @UOM When N'Sales UOM' 
                		 Then sum(
                   (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1))) Else    
	                		 dbo.sp_Get_ReportingQty(
				         (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)),        
			                  (Case @UOM        
					             		When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
		                   End)) End,
          "Van Free Stock "= Case @UOM When N'Sales UOM' 
                		 Then sum(
                   (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2))) Else    
	                		 dbo.sp_Get_ReportingQty(
				         (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),        
			                  (Case @UOM        
					             		When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
		                   End)) End,
          "DC Saleable Stock "= Case @UOM When N'Sales UOM' 
                		 Then sum(
                   (dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1))) Else    
	                		 dbo.sp_Get_ReportingQty(
				         (dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)),        
			                  (Case @UOM        
					             		When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
		                   End)) End,
          "DC Free Stock "= Case @UOM When N'Sales UOM' 
                		 Then sum(
                   (dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2))) Else    
	                		 dbo.sp_Get_ReportingQty(
				         (dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),        
			                  (Case @UOM        
					             		When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     				When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
		                   End)) End,

          	"Saleable Value" =                  
             Cast(Case @StockValuation                          
               When N'PTS' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTS, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTS, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.PTS, 0))
										- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) * Isnull(Items.PTS,0))                      
      
               When N'PTR' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTR, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTR, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.PTR, 0))
										- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) * Isnull(Items.PTR,0))                      
      
               When N'ECP' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.ECP, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.ECP, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.ECP, 0))
										- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) * Isnull(Items.ECP,0))                   
                      
               End as Decimal(18,6)),   
          	"Damaged Value" =     
           		Cast(Case @StockValuation                        
                When N'PTS' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTS, 0)), 0)    
                When N'PTR' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTR, 0)), 0)                          
                When N'ECP' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.ECP, 0)), 0)     
            	End as Decimal(18,6)),       
            "Total Value" =    
            Cast(Case @StockValuation                        
              When N'PTS' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.PTS, 0))
				   													- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) * Isnull(Items.PTS,0))                           
              When N'PTR' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.PTR, 0))
																    - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) * Isnull(Items.PTR,0))                             
              When N'ECP' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.ECP, 0))
				   												  - Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) * Isnull(Items.ECP,0))     
           End as Decimal(18,6))    
            From Items
				Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code  
				Inner Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID     
				Inner Join UOM On Uom.Uom = Case @UOM When N'UOM1' Then Items.Uom1 When N'UOM2' Then Items.UOM2 Else Items.UOM End    
				Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID                               
	            Inner Join #temp4 On #temp4.LeafID = Items.CategoryID     
				Inner Join #tempCategory1 On Items.CategoryID = #tempCategory1.CategoryID                        
				Inner Join #tmpMfr On Manufacturer.Manufacturer_Name = #tmpMfr.Manufacturer  
				Inner Join #tempItems On Items.Product_Code = #tempItems.Product_Code                 
           Where  OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate)                        
	            And ItemCategories.Active = 1      
	            And Items.Active = 1   
	            Group By        
	            Items.Product_Code,Manufacturer.ManufacturerID, Items.ProductName,  
	            #temp4.[Parent], UOM.[Description],Items.UOM1_Conversion,    
	            Items.UOM2_Conversion, #tempCategory1.[IDs]                      
           Order By 
				#tempCategory1.[IDs],Items.Product_Code       


			  select tempPrd.[Item Code], tempPrd.[Item Code], tempPrd.[Item Name]
			 , tempPrd.[Category] 
			 , tempPrd.[UOM]
			 , tempPrd.[Total Quantity]    
			 , tempPrd.[Saleable]  
			 , tempPrd.[Free]  
			 , tempPrd.[Damages]  
			 , tempPrd.[Van Saleable Stock ]  
			 , tempPrd.[Van Free Stock ]
			 , tempPrd.[DC Saleable Stock ] 
			 , tempPrd.[DC Free Stock] 
			 , "SIT Saleable Stock" = Case @UOM When N'Sales UOM' 
                			 Then 
					   Isnull((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),0) Else    
	                			 dbo.sp_Get_ReportingQty(
							 Isnull((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),0),        
								  (Case @UOM        
					             			When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     					When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
							   End)) End
			 , "SIT Free Stock" = Case @UOM When N'Sales UOM' 
                			 Then 
					   Isnull((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,0) Else    
	                			 dbo.sp_Get_ReportingQty(
							 Isnull((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,0),        
								  (Case @UOM        
					             			When N'Uom1' Then IsNull(Items.UOM1_Conversion,1)        
				   		     					When N'Uom2' Then IsNull(Items.UOM2_Conversion,1)        
							   End)) End 
			 , tempPrd.[Saleable Value]  
			 , tempPrd.[Damaged Value] 
			 , tempPrd.[Total Value]
			 from #tmpPreviousDate tempPrd   
			 join #tmptotal_Invd_qty tmpInvqty on tempPrd.[Item Code] = tmpInvqty.Product_Code
			 Join #tmptotal_rcvd_qty tmprcvdqty  on tempPrd.[Item Code] = tmprcvdqty.Product_Code  
			 Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty on tempPrd.[Item Code] = tmpInvdSaleqty.Product_Code  
             Join Items on tempPrd.[Item Code] = Items.Product_Code
       End    
     Else    
       Begin    
        -- Code for UOM1 & UOM2    
		Insert into #tmpPreviousDateUOM1UOM2  
       	Select     
--           "Item Code" = Items.Product_Code,       
           "Item Code" = Items.Product_Code,    
           "Item Name" = Items.ProductName,    
           "Category" = #temp4.Parent,
           "Total CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(Opening_Quantity,0))- 
						  dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0),1),    
           "PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(Opening_Quantity,0)) - dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) 
             				 ,2),
           "Saleable CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,Sum(IsNull(OpeningDetails.Opening_Quantity,0) -     
              IsNull(OpeningDetails.Free_Saleable_Quantity,0) -     
              IsNull(OpeningDetails.Damage_Opening_Quantity,0)) - dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) 
             				,1),    
           "Saleable PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,Sum(IsNull(OpeningDetails.Opening_Quantity,0) -     
              IsNull(OpeningDetails.Free_Saleable_Quantity,0) -     
              IsNull(OpeningDetails.Damage_Opening_Quantity,0)) - dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) 
             				,2),      
           "Free CFC"=  dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(OpeningDetails.Free_Saleable_Quantity,0)- dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),1) 
             				 ,     
           "Free PAC"=  dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(OpeningDetails.Free_Saleable_Quantity,0)- dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2)),2) 
             				,      
           "Damaged CFC"= dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(OpeningDetails.Damage_Opening_Quantity,0)),1),    
           "Damaged PAC"= dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code,sum(Isnull(OpeningDetails.Damage_Opening_Quantity,0)),2),                      
           "Van Saleable CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),1),
           "Van Saleable PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),2),
           "Van Free CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2),1),
           "Van Free CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2),2),
		   "DC Saleable CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),1),
           "DC Saleable PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1),2),
		   "DC Free CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2),1),
           "DC Free PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(Items.Product_Code ,dbo.Fn_GetDispatchQty(Items.Product_Code,DATEADD(d, 1, @FromDate),2),2),
           "Saleable Value" =                  
             Cast(Case @StockValuation                          
            When N'PTS' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTS, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTS, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.PTS, 0))
															- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) * Isnull(Items.PTS,0))                          
               When N'PTR' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.PTR, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.PTR, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.PTR, 0))
															- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1) * Isnull(Items.PTR,0))                      
               When N'ECP' Then Sum(IsNull(OpeningDetails.Opening_Quantity, 0) * IsNull(Items.ECP, 0) - IsNull(OpeningDetails.Damage_Opening_Quantity,0) * IsNull(Items.ECP, 0) - Isnull(Free_Opening_Quantity,0) * IsNull(Items.ECP, 0))
															- Sum(dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),1)  * Isnull(Items.ECP,0))                          
               End as Decimal(18,6)),      
           "Damaged Value" =     
            Cast(Case @StockValuation                        
              When N'PTS' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTS, 0)), 0)                          
              When N'PTR' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.PTR, 0)), 0)                          
              When N'ECP' Then IsNull(Sum(IsNull(OpeningDetails.Damage_Opening_Quantity, 0) * IsNull(Items.ECP, 0)), 0)     
            End as Decimal(18,6)) ,       
  			   "Total Value" =    
            Cast(Case @StockValuation                        
              When N'PTS' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.PTS, 0))
				   												- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) * Isnull(Items.PTS,0))                           
              When N'PTR' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.PTR, 0))
				   												- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) * Isnull(Items.PTR,0))                             
              When N'ECP' Then Sum((IsNull(OpeningDetails.Opening_Quantity,0) - Isnull(Free_Opening_Quantity,0)) * IsNull(Items.ECP, 0))
				   												- Sum (dbo.Fn_GetVanLoadQty(Items.Product_Code,DATEADD(d, 1, @FromDate),0) * Isnull(Items.ECP,0))     
           End as Decimal(18,6))   
          From Items
			 Left Outer Join OpeningDetails On Items.Product_Code = OpeningDetails.Product_Code   
			 Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID                               
			 Inner Join #temp4 On #temp4.LeafID = Items.CategoryID     
			 Inner Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID     
			 Inner Join  #tempCategory1 On Items.CategoryID = #tempCategory1.CategoryID                        
			 Inner Join #tmpMfr On Manufacturer.Manufacturer_Name = #tmpMfr.Manufacturer  
			 Inner Join #tempItems On Items.Product_Code = #tempItems.Product_Code           
			 Where        
	         OpeningDetails.Opening_Date = DATEADD(d, 1, @FromDate)                            
	         And ItemCategories.Active = 1      
	         And Items.Active = 1    
	         Group By        
	           Items.Product_Code, Manufacturer.ManufacturerID, Items.ProductName, #temp4.Parent,   
	           Items.UOM1_Conversion,Items.UOM2_Conversion, #tempCategory1.[IDs]           
             Order By 
						 #tempCategory1.[IDs],Items.Product_Code     
  
		  select tempPrd.[Item Code], tempPrd.[Item Code], tempPrd.[Item Name]
		 , tempPrd.[Category] 
		 , tempPrd.[Total CFC]    
		 , tempPrd.[PAC]    
		 , tempPrd.[Saleable CFC]  
		 , tempPrd.[Saleable PAC]  
		 , tempPrd.[Free CFC]  
		 , tempPrd.[Free PAC]  
		 , tempPrd.[Damages CFC]  
		 , tempPrd.[Damages PAC]  
		 , tempPrd.[Van Saleable CFC ]  
		 , tempPrd.[Van Saleable PAC ]  
		 , tempPrd.[Van Free CFC ]
		 , tempPrd.[Van Free PAC ]
		 , tempPrd.[DC Saleable CFC ] 
		 , tempPrd.[DC Saleable PAC ] 
		 , tempPrd.[DC Free CFC ] 
		 , tempPrd.[DC Free PAC ] 
		 , "SIT Saleable CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(tempPrd.[Item Code], IsNull((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),0),1)
		 , "SIT Saleable PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(tempPrd.[Item Code], IsNull((tmpInvdSaleqty.Saleableonly_qty - tmprcvdqty.rcvdqty),0),2)
		 , "SIT Free CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(tempPrd.[Item Code], IsNull((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,0),1)
		 , "SIT Free PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(tempPrd.[Item Code], IsNull((tmpInvqty.Invoiced_qty - tmpInvdSaleqty.Saleableonly_qty ) - tmprcvdqty.freeqty,0),2)     
		 , tempPrd.[Saleable Value]  
		 , tempPrd.[Damaged Value] 
		 , tempPrd.[Total Value]
		 from #tmpPreviousDateUOM1UOM2 tempPrd   
		 join #tmptotal_Invd_qty tmpInvqty on tempPrd.[Item Code] = tmpInvqty.Product_Code
		 Join #tmptotal_rcvd_qty tmprcvdqty  on tempPrd.[Item Code] = tmprcvdqty.Product_Code  
		 Join #tmptotal_Invd_Saleonly_qty tmpInvdSaleqty on tempPrd.[Item Code] = tmpInvdSaleqty.Product_Code 
       
       End    
     End     
  End     
   Else     
   Begin          
    If @ShowItems = N'Items with stock'                          
      Begin    
       If @UOM = N'Sales UOM' or @UOM = N'UOM1' or @UOM = N'UOM2'                          
         Begin    
        -- Batch Products     
         Select        
          "Item Code" = I1.Product_Code,    
          "Item Code" = I1.Product_Code,    
          "Item Name" = I1.ProductName,     
          "Category" = #temp4.Parent,     
          "UOM" = UOM.[Description],    
          "Total Quantity" = Case @UOM When N'Sales UOM' Then sum(Batch_Products.Quantity) Else dbo.sp_Get_ReportingQty(sum(Batch_Products.Quantity),        
          (Case @UOM --When 'Sales UOM' Then 1        
           When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
           When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
          End)) End,  

      	 "Saleable " =   
            Sum(    
               		Case @UOM When N'Sales UOM'   
					        Then Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End  
          			  Else  dbo.sp_Get_ReportingQty(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End,        
                	(Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                             When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                   End))  
				      	End),     
          "Free " =   
            Sum(    
	               Case @UOM When N'Sales UOM' Then   
	               Case When Free <> 0 And IsNull(Damage, 0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End  
		             Else   
				         dbo.sp_Get_ReportingQty(Case When Free <> 0 And IsNull(Damage, 0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End,        
                            (Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                                     	 When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                             End))  
    				     End),      
          "Damaged " =   
            Sum(    
               Case @UOM When N'Sales UOM' Then   
               Case When IsNull(Damage,0) <> 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End  
             	 Else   
			         dbo.sp_Get_ReportingQty(Case When IsNull(Damage,0) <> 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End,        
        		(Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                                     When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                           End))  
			         End), 

		     "Van Saleable Stock" = Sum(   
      			 Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then   
             Case @UOM When N'Sales UOM' Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,1),0)
		           Else dbo.sp_Get_ReportingQty(Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,1),0),        
		           (Case @UOM --When 'Sales UOM' Then 1        
		            When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
		            When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
	            End))  
			      End    
      			Else 0 End  
           ),  


          "Van Free Stock " = Sum(   
      			 Case When IsNull(Free,0)<> 0 And IsNull(Damage,0) <> 1 Then   
             Case @UOM When N'Sales UOM' Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,2),0)
		           Else dbo.sp_Get_ReportingQty(Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,2),0),        
		           (Case @UOM --When 'Sales UOM' Then 1        
		            When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
		            When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
	            End))  
			      End    
      			Else 0 End  
           ),  
--pkb for uom1
          "DC Saleable Stock " = 				   
				 (Case @UOM When N'Sales UOM'   
        		 	Then (Select IsNull(Sum(DD.Quantity),0) 
					from DispatchAbstract DA, DispatchDetail DD, Batch_Products BP
					Where DA.DispatchID = DD.DispatchID
					And DD.Batch_Code = BP.Batch_Code
					And DD.Product_Code = I1.Product_Code
					And DD.Product_Code = BP.Product_Code
					And IsNull(BP.Free,0)= 0 And IsNull(BP.Damage,0) = 0
					)
             	   Else dbo.sp_Get_ReportingQty
									((Select IsNull(Sum(DD.Quantity),0) 
					from DispatchAbstract DA, DispatchDetail DD, Batch_Products BP
					Where DA.DispatchID = DD.DispatchID
					And DD.Batch_Code = BP.Batch_Code
					And DD.Product_Code = I1.Product_Code
					And DD.Product_Code = BP.Product_Code
					And IsNull(BP.Free,0)= 0 And IsNull(BP.Damage,0) = 0)
                     ,        
                	(Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                             When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                   End))  
		          End) ,
          "DC Free Stock " = 				
                 (Case @UOM When N'Sales UOM'   
        		 	Then (Select IsNull(Sum(DD.Quantity),0) 
					from DispatchAbstract DA, DispatchDetail DD, Batch_Products BP
					Where DA.DispatchID = DD.DispatchID
					And DD.Batch_Code = BP.Batch_Code
					And DD.Product_Code = I1.Product_Code
					And DD.Product_Code = BP.Product_Code
					And IsNull(BP.Free,0) <> 0 And IsNull(BP.Damage, 0) <> 1
                  )

             	   Else dbo.sp_Get_ReportingQty
									( (Select IsNull(Sum(DD.Quantity),0) 
					from DispatchAbstract DA, DispatchDetail DD, Batch_Products BP
					Where DA.DispatchID = DD.DispatchID
					And DD.Batch_Code = BP.Batch_Code
					And DD.Product_Code = I1.Product_Code
					And DD.Product_Code = BP.Product_Code
					And IsNull(BP.Free,0) <> 0 And IsNull(BP.Damage, 0) <> 1)
                     ,        
                	(Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                             When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                   End))  
		          End),


          "SIT Saleable Stock " =				 
				(Case @UOM When N'Sales UOM'   
        		 	Then (select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) > 0)
             	   Else dbo.sp_Get_ReportingQty
									( (select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) > 0)
                     ,        
                	(Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                             When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                   End))  
		          End) ,
          "SIT Free Stock " = 				
				(Case @UOM When N'Sales UOM'   
        		 	Then (select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) = 0)
             	   Else dbo.sp_Get_ReportingQty
									( (select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) = 0),        
                	(Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                             When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                   End))  
		          End),

        
      		"Saleable Value " =    
	        	Case @StockValuation        
              	When N'PTS'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTS, 0) Else IsNull(I1.PTS, 0) End) *   
                   (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End))      
                When N'PTR'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTR, 0) Else IsNull(I1.PTR, 0) End) *   
                   (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End))   
                When N'ECP'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.ECP, 0) Else IsNull(I1.ECP, 0) End) *   
                    (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End))   
            End,     
          "Damaged Value " =    
        		Case @StockValuation        
              	When N'PTS'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTS, 0) Else IsNull(I1.PTS, 0) End) *   
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End))      
                When N'PTR'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTR, 0) Else IsNull(I1.PTR, 0) End) *   
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End))   
                When N'ECP'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.ECP, 0) Else IsNull(I1.ECP, 0) End) *   
                    (Case When IsNull(Damage,0) <> 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End))   
            End,   
          "Total Value" =                         
           Case @StockValuation        
            When N'PTS' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Batch_Products.Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Batch_Products.Quantity, 0) * IsNull(I1.PTS, 0)) End) End)           
            When N'PTR' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Batch_Products.Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Batch_Products.Quantity, 0) * IsNull(I1.PTR, 0)) End) End)                  
            When N'ECP' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Batch_Products.Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Batch_Products.Quantity, 0) * IsNull(I1.ECP, 0)) End) End)                                   
           End                            
         From  Items I1
			Inner Join Batch_Products On I1.Product_Code = Batch_Products.Product_Code 
			Inner Join ItemCategories On   I1.CategoryID = ItemCategories.CategoryID        
			Inner Join Uom On Uom.Uom = Case @UOM When N'UOM1' Then I1.Uom1 When N'UOM2' Then I1.UOM2 Else I1.UOM End                             
			Left Outer Join #temp4 On I1.CategoryID = #temp4.LeafID    
			Inner Join #tempCategory1 On I1.CategoryID = #tempCategory1.CategoryID                           
			Inner Join Manufacturer On I1.ManufacturerID = Manufacturer.ManufacturerID  
			Inner Join  #tmpMfr On Manufacturer.Manufacturer_Name = #tmpMfr.Manufacturer       
			Inner Join  #tempItems On I1.Product_Code = #tempItems.Product_Code                             
         Where ItemCategories.Active = 1 And I1.Active = 1        
	        Group BY        
          	I1.Product_Code, I1.ProductName,Manufacturer.ManufacturerID,ItemCategories.CategoryID,#temp4.[Parent], UOM.[Description],    
          	I1.UOM1_Conversion,I1.UOM2_Conversion,#tempCategory1.[IDs]    
          Having        
           	(Sum(IsNull(Batch_Products.Quantity,0)) > 0) 
         	Order By 
						#tempCategory1.[IDs],I1.Product_Code                       
       End    
      Else    
       Begin  
	
        -- Code for UOM1 & UOM2    
         Select        
         "Item Code" = I1.Product_Code,    
         "Item Code" = I1.Product_Code,    
         "Item Name" = I1.ProductName,     
         "Category" = #temp4.Parent,     
         "Total CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,sum(Isnull(Batch_Products.Quantity,0)),1),     
         "PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,sum(Isnull(Batch_Products.Quantity,0)),2),         
         "Saleable CFC " = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
             Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End),1),     
         "Saleable PAC " = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
             Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End),2),    
     	 "Free CFC " = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
             Sum(Case When Free <> 0 And IsNull(Damage, 0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End),1),   
         "Free PAC " = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
             Sum(Case When Free <> 0 And IsNull(Damage, 0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End),2),   
		 "Damaged CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
             Sum(Case When IsNull(Damage,0) <> 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End),1),   
         "Damaged PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
             Sum(Case When IsNull(Damage,0) <> 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End),2), 

		 "Van Saleable Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
								Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0   
							                  Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,1),0) Else 0 End),1),  


		 "Van Saleable Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
								Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0   
							                  Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,1),0) Else 0 End),2),  

		 "Van Free Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
			                          Sum(Case When Free <> 0 And IsNull(Damage, 0) <> 1   
							                  Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,2),0) Else 0 End),1),  


		 "Van Free Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
			                          Sum(Case When Free <> 0 And IsNull(Damage, 0) <> 1   
							                  Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,2),0) Else 0 End),2),  

--		"DC Saleable Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
--								Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0   
--							                  Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,Batch_Products.Batch_Code,1),0) Else 0 End),1),  
--
--
--		"DC Saleable Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
--								Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0   
--							                  Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,Batch_Products.Batch_Code,1),0) Else 0 End),2),  
--
--		"DC Free Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
--			                          Sum(Case When Free <> 0 And IsNull(Damage, 0) <> 1   
--							                  Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,Batch_Products.Batch_Code,2),0) Else 0 End),1),  
--
--		"DC Free Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
--			                          Sum(Case When Free <> 0 And IsNull(Damage, 0) <> 1   
--							                  Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,Batch_Products.Batch_Code,2),0) Else 0 End),2),  
"DC Salable Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code, 
					(Select IsNull(Sum(DDT.Quantity),0) 
					from DispatchAbstract DAB, DispatchDetail DDT, Batch_Products BPD
					Where DAB.DispatchID = DDT.DispatchID
					And DDT.Batch_Code = BPD.Batch_Code
					And DDT.Product_Code = I1.Product_Code
					And BPD.Product_Code = DDT.Product_Code 
					And (DAB.Status & 128) = 0
					And IsNull(BPD.Free,0)= 0 And IsNull(BPD.Damage,0) = 0 ),1), 

		"DC Salable Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code, 
					(Select IsNull(Sum(DDT.Quantity),0) 
					from DispatchAbstract DAB, DispatchDetail DDT, Batch_Products BPD
					Where DAB.DispatchID = DDT.DispatchID
					And DDT.Batch_Code = BPD.Batch_Code
					And DDT.Product_Code = I1.Product_Code
					And BPD.Product_Code = DDT.Product_Code 
					And (DAB.Status & 128) = 0
					And IsNull(BPD.Free,0)= 0 And IsNull(BPD.Damage,0) = 0 ),2), 

		"DC Free Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code, 
					(Select IsNull(Sum(DDT.Quantity),0) 
					from DispatchAbstract DAB, DispatchDetail DDT, Batch_Products BPD
					Where DAB.DispatchID = DDT.DispatchID
					And DDT.Batch_Code = BPD.Batch_Code
					And DDT.Product_Code = I1.Product_Code
					And BPD.Product_Code = DDT.Product_Code 
					And (DAB.Status & 128) = 0
					And IsNull(BPD.Free,0)<> 0 And IsNull(BPD.Damage,0) <> 1 ),1),

		"DC Free Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code, 
					(Select IsNull(Sum(DDT.Quantity),0) 
					from DispatchAbstract DAB, DispatchDetail DDT, Batch_Products BPD
					Where DAB.DispatchID = DDT.DispatchID
					And DDT.Batch_Code = BPD.Batch_Code
					And DDT.Product_Code = I1.Product_Code
					And BPD.Product_Code = DDT.Product_Code 
					And (DAB.Status & 128) = 0
					And IsNull(BPD.Free,0)<> 0 And IsNull(BPD.Damage,0) <> 1 ),2),  

--
		"SIT Saleable Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,
					(select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) > 0), 1),

		"SIT Saleable Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,
					(select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) > 0), 2),

		"SIT Free Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,
					(select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) = 0), 1),

		"SIT Free Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,
					(select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) = 0), 2),

    	 "Saleable Value " =    
	        	Case @StockValuation        
              		When N'PTS'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTS, 0) Else IsNull(I1.PTS, 0) End) *   
                   (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End))      
                	When N'PTR'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTR, 0) Else IsNull(I1.PTR, 0) End) *   
                   (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End))   
                	When N'ECP'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.ECP, 0) Else IsNull(I1.ECP, 0) End) *   
                    (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End))   
                	End,     
         "Damaged Value " =    
        			Case @StockValuation        
              	  When N'PTS'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTS, 0) Else IsNull(I1.PTS, 0) End) *   
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End))      
	              	When N'PTR'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTR, 0) Else IsNull(I1.PTR, 0) End) *   
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End))   
                  When N'ECP'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.ECP, 0) Else IsNull(I1.ECP, 0) End) *   
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Batch_Products.Quantity,0) Else 0 End))   
	                End,                
         "Total Value" =                         
           	Cast(Case @StockValuation        
           			When N'PTS' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Batch_Products.Quantity, 0) * IsNull(Batch_Products.PTS, 0)) 
									Else (Case [Free] When 1 Then 0 Else (IsNull(Batch_Products.Quantity, 0) * IsNull(I1.PTS, 0)) End) End)           
           			When N'PTR' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Batch_Products.Quantity, 0) * IsNull(Batch_Products.PTR, 0)) 
									Else (Case [Free] When 1 Then 0 Else (IsNull(Batch_Products.Quantity, 0) * IsNull(I1.PTR, 0)) End) End)                  
           			When N'ECP' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Batch_Products.Quantity, 0) * IsNull(Batch_Products.ECP, 0)) 
                	Else (Case [Free] When 1 Then 0 Else (IsNull(Batch_Products.Quantity, 0) * IsNull(I1.ECP, 0)) End) End)                                    
	 				  End 
						as Decimal(18,6))                           
        From        
	        Items I1
			Left Outer Join Batch_Products On 	I1.Product_Code = Batch_Products.Product_Code     
			Inner Join ItemCategories On I1.CategoryID = ItemCategories.CategoryID                            
			Inner Join #temp4 On I1.CategoryID = #Temp4.LeafID    
			Inner Join #tempCategory1 On I1.CategoryID = #TempCategory1.CategoryID     
			Inner Join Manufacturer On I1.ManufacturerID = Manufacturer.ManufacturerID  
			Inner Join #tmpMfr On Manufacturer.Manufacturer_Name = #tmpMfr.Manufacturer        
			Inner Join #tempItems  On I1.Product_Code = #tempItems.Product_Code                                    
        Where ItemCategories.Active = 1 And I1.Active = 1                                                         
         Group BY        
	        	I1.Product_Code,Manufacturer.ManufacturerID, I1.ProductName,
						ItemCategories.CategoryID, #temp4.[Parent],I1.UOM1_Conversion,
						I1.UOM2_Conversion,#TempCategory1.[IDs]      
         Having        
           	IsNull(Sum(Quantity), 0) > 0     
         Order By 
						#TempCategory1.[IDs],I1.Product_Code      
        End                
     End     
   Else If @ShowItems = N'All Items'    
     Begin    
      If @UOM = N'Sales UOM' or @UOM = N'UOM1' or @UOM = N'UOM2'                          
       Begin    
        -- Code for UOM1 or UOM2 or Sales UOM    
       Select        
          "Item Code" = I1.Product_Code,  
          "Item Code" = I1.Product_Code,    
          "Item Name" = I1.ProductName,     
          "Category" = #temp4.Parent,     
          "UOM" = UOM.[Description],    
          "Total Quantity" = 
					Case @UOM When N'Sales UOM' 
					Then sum(Isnull(Quantity,0)) Else dbo.sp_Get_ReportingQty(sum(Isnull(Quantity,0)),        
	         (Case @UOM --When 'Sales UOM' Then 1        
    		     When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
		         When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
		       End)) End,      
          "Saleable " =   
            Sum(Case @UOM When N'Sales UOM'   
        		 	Then Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End  
             	Else dbo.sp_Get_ReportingQty
									(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End,        
                	(Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                             When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                   End))  
		          End),     
          "Free " =   
            Sum(    
              Case @UOM When N'Sales UOM' 
							Then Case When Free <> 0 And IsNull(Damage, 0) = 0 Then Isnull(Quantity,0) Else 0 End  
             	Else dbo.sp_Get_ReportingQty
										(Case When Free <> 0 And IsNull(Damage, 0) = 0 Then Isnull(Quantity,0) Else 0 End,        
                    (Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                               When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                     End))  
         	End),      
		  "Damaged " =   
            Sum(    
               Case @UOM When N'Sales UOM' Then   
               Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End  
             	 Else dbo.sp_Get_ReportingQty
								(Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End,        
              	(Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                           When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
		              		End))  
         			 End),     

		     "Van Saleable Stock" = Sum(   
      			 Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then   
             Case @UOM When N'Sales UOM' Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,1),0)
		           Else dbo.sp_Get_ReportingQty(Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,1),0),        
		           (Case @UOM --When 'Sales UOM' Then 1        
		            When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
		            When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
	            End))  
			      End    
      			Else 0 End  
           ),  


          "Van Free Stock " = Sum(   
      			 Case When IsNull(Free,0)<> 0 And IsNull(Damage,0) <> 1 Then   
             Case @UOM When N'Sales UOM' Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,2),0)
		           Else dbo.sp_Get_ReportingQty(Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,2),0),        
		           (Case @UOM --When 'Sales UOM' Then 1        
		            When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
		            When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
	            End))  
			      End    
      			Else 0 End  
           ),  

       /*   "DC Saleable Stock " = Sum(   
      			 Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then   
             Case @UOM When N'Sales UOM' Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,Batch_Products.Batch_Code,1),0)
		           Else dbo.sp_Get_ReportingQty(Isnull(dbo.Fn_GetDispQty(I1.Product_Code,Batch_Products.Batch_Code,1),0),        
		           (Case @UOM --When 'Sales UOM' Then 1        
		            When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
		            When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
	            End))  
			      End    
      			Else 0 End  
           ),  
          "DC Free Stock " = Sum(   
      			 Case When IsNull(Free,0) <> 0 And IsNull(Damage,0) <> 1 Then   
             Case @UOM When N'Sales UOM' Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,Batch_Products.Batch_Code,2),0)
		           Else dbo.sp_Get_ReportingQty(Isnull(dbo.Fn_GetDispQty(I1.Product_Code,Batch_Products.Batch_Code,2),0),        
		           (Case @UOM --When 'Sales UOM' Then 1        
		            When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
		            When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
	            End))  
			      End    
      			Else 0 End  
           ),  */


"DC Saleable Stock " = 				   
				 (Case @UOM When N'Sales UOM'   
        		 	Then (Select IsNull(Sum(DDT.Quantity),0) 
					from DispatchAbstract DAB, DispatchDetail DDT, Batch_Products BPD
					Where DAB.DispatchID = DDT.DispatchID
					And DDT.Batch_Code = BPD.Batch_Code
					And DDT.Product_Code = I1.Product_Code
					And DDT.Product_Code = BPD.Product_Code
					And IsNull(BPD.Free,0)= 0 And IsNull(BPD.Damage,0) = 0
					)
             	   Else dbo.sp_Get_ReportingQty
									((Select IsNull(Sum(DDT.Quantity),0) 
					from DispatchAbstract DAB, DispatchDetail DDT, Batch_Products BPD
					Where DAB.DispatchID = DDT.DispatchID
					And DDT.Batch_Code = BPD.Batch_Code
					And DDT.Product_Code = I1.Product_Code
					And DDT.Product_Code = BPD.Product_Code
					And IsNull(BPD.Free,0)= 0 And IsNull(BPD.Damage,0) = 0)
                     ,        
                	(Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                             When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                   End))  
		          End) ,
          "DC Free Stock " = 				
                 (Case @UOM When N'Sales UOM'   
        		 	Then (Select IsNull(Sum(DDT.Quantity),0) 
					from DispatchAbstract DAB, DispatchDetail DDT, Batch_Products BPD
					Where DAB.DispatchID = DDT.DispatchID
					And DDT.Batch_Code = BPD.Batch_Code
					And DDT.Product_Code = I1.Product_Code
					And DDT.Product_Code = BPD.Product_Code
					And IsNull(BPD.Free,0) <> 0 And IsNull(BPD.Damage, 0) <> 1
                  )

             	   Else dbo.sp_Get_ReportingQty
									( (Select IsNull(Sum(DDT.Quantity),0) 
					from DispatchAbstract DAB, DispatchDetail DDT, Batch_Products BPD
					Where DAB.DispatchID = DDT.DispatchID
					And DDT.Batch_Code = BPD.Batch_Code
					And DDT.Product_Code = I1.Product_Code
					And DDT.Product_Code = BPD.Product_Code
					And IsNull(BPD.Free,0) <> 0 And IsNull(BPD.Damage, 0) <> 1)
                     ,        
                	(Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                             When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                   End))  
		          End),


          "SIT Saleable Stock " =				 
				(Case @UOM When N'Sales UOM'   
        		 	Then (select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) > 0)
             	   Else dbo.sp_Get_ReportingQty
									( (select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) > 0)
                     ,        
                	(Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                             When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                   End))  
		          End) ,
          "SIT Free Stock " = 				
				(Case @UOM When N'Sales UOM'   
        		 	Then (select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) = 0)
             	   Else dbo.sp_Get_ReportingQty
									( (select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) = 0),        
                	(Case @UOM When N'Uom1' Then IsNull(I1.UOM1_Conversion,1)        
                             When N'Uom2' Then IsNull(I1.UOM2_Conversion,1)        
                   End))  
		          End),

           "Saleable Value " =    
	        		Case @StockValuation        
             	When N'PTS'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTS, 0) Else IsNull(I1.PTS, 0) End) *   
                   (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End))      
             	When N'PTR'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTR, 0) Else IsNull(I1.PTR, 0) End) *   
                   (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End))   
             	When N'ECP'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.ECP, 0) Else IsNull(I1.ECP, 0) End) *   
                    (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End))   
             	End,     
           	"Damaged Value " =    
        		Case @StockValuation        
             	When N'PTS'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTS, 0) Else IsNull(I1.PTS, 0) End) *   
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End))      
             	When N'PTR'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTR, 0) Else IsNull(I1.PTR, 0) End) *   
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End))   
             	When N'ECP'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.ECP, 0) Else IsNull(I1.ECP, 0) End) *   
                    (Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End))   
             	End,       
            "Total Value" =                         
            Case @StockValuation        
		          When N'PTS' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.PTS, 0)) End) End)           
	    	      When N'PTR' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.PTR, 0)) End) End)                  
		          When N'ECP' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.ECP, 0)) End) End)                                   
           End                            
         From        
	          Items I1
			  Left Outer Join Batch_Products On I1.Product_Code = Batch_Products.Product_Code     
			  Inner Join ItemCategories On I1.CategoryID = ItemCategories.CategoryID        
			  Inner Join Uom On Uom.Uom = Case @UOM When N'UOM1' Then I1.Uom1 When N'UOM2' Then I1.UOM2 Else I1.UOM End                             
			  Inner Join #tempCategory1 On I1.CategoryID = #tempCategory1.CategoryID  
			  Inner Join Manufacturer On I1.ManufacturerID = Manufacturer.ManufacturerID       
	          Inner Join #temp4 On I1.CategoryID = #temp4.LeafID     
			  Inner Join #tempItems On I1.Product_Code = #tempItems.Product_Code                           
			  Inner Join #tmpMfr  On Manufacturer.Manufacturer_Name = #tmpMfr.Manufacturer                                
         Where ItemCategories.Active = 1          
	          And I1.Active = 1        
	          Group BY        
	          I1.Product_Code,I1.ProductName,Manufacturer.ManufacturerID,#temp4.[Parent],UOM.[Description],   
	          I1.UOM1_Conversion,I1.UOM2_Conversion,#tempCategory1.[IDs]    
         Order By 
						#tempCategory1.[IDs],I1.Product_Code                       
       End    
      Else    
       Begin                     
        -- Code for UOM1 & UOM2    
       Select        
          "Item Code" = I1.Product_Code,    
          "Item Code" = I1.Product_Code,    
          "Item Name" = I1.ProductName,     
          "Category" = #temp4.Parent,     
          "Total CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,sum(Isnull(Quantity,0)),1),     
          "PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,sum(Isnull(Quantity,0)),2),         
          "Saleable CFC " =     
           dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
             Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End),1),     
          "Saleable PAC " = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
             Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End),2),    
          "Free CFC " = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
             Sum(Case When Free <> 0 And IsNull(Damage, 0) = 0 Then Isnull(Quantity,0) Else 0 End),1),   
          "Free PAC " = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
             Sum(Case When Free <> 0 And IsNull(Damage, 0) = 0 Then Isnull(Quantity,0) Else 0 End),2),   
          "Damaged CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
             Sum(Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End),1),   
          "Damaged PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
             Sum(Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End),2),     

		 "Van Saleable Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
								Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0   
							        Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,1),0) Else 0 End),1),  


		 "Van Saleable Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
								Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0   
							                  Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,1),0) Else 0 End),2),  

		 "Van Free Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
			                          Sum(Case When Free <> 0 And IsNull(Damage, 0) <> 1   
							                  Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,2),0) Else 0 End),1),  


		 "Van Free Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
			                          Sum(Case When Free <> 0 And IsNull(Damage, 0) <> 1   
							                  Then Isnull(dbo.Fn_GetVanQty(I1.Product_Code,Batch_Products.Batch_Code,2),0) Else 0 End),2),  

--		"DC Saleable Stock CFC" = case dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
--								Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0   
--							                  Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,Batch_Products.Batch_Code,1),0) Else 0 End),1),  

--
--
--		"DC Saleable Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
--								Sum(Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0   
--							                  Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,Batch_Products.Batch_Code,1),0) Else 0 End),2),  
--
--		"DC Free Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
--			                          Sum(Case When Free <> 0 And IsNull(Damage, 0) <> 1   
--							                  Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,Batch_Products.Batch_Code,2),0) Else 0 End),1),  
--
--		"DC Free Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,                                      
--			                          Sum(Case When Free <> 0 And IsNull(Damage, 0) <> 1   
--							                  Then Isnull(dbo.Fn_GetDispQty(I1.Product_Code,Batch_Products.Batch_Code,2),0) Else 0 End),2),

		"DC Salable Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code, 
					(Select IsNull(Sum(DDT.Quantity),0) 
					from DispatchAbstract DAB, DispatchDetail DDT, Batch_Products BPD
					Where DAB.DispatchID = DDT.DispatchID
					And DDT.Batch_Code = BPD.Batch_Code
					And DDT.Product_Code = I1.Product_Code
					And BPD.Product_Code = DDT.Product_Code 
					And (DAB.Status & 128) = 0
					And IsNull(BPD.Free,0)= 0 And IsNull(BPD.Damage,0) = 0 ),1), 

		"DC Salable Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code, 
					(Select IsNull(Sum(DDT.Quantity),0) 
					from DispatchAbstract DAB, DispatchDetail DDT, Batch_Products BPD
					Where DAB.DispatchID = DDT.DispatchID
					And DDT.Batch_Code = BPD.Batch_Code
					And DDT.Product_Code = I1.Product_Code
					And BPD.Product_Code = DDT.Product_Code 
					And (DAB.Status & 128) = 0
					And IsNull(BPD.Free,0)= 0 And IsNull(BPD.Damage,0) = 0 ),2), 

		"DC Free Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code, 
					(Select IsNull(Sum(DDT.Quantity),0) 
					from DispatchAbstract DAB, DispatchDetail DDT, Batch_Products BPD
					Where DAB.DispatchID = DDT.DispatchID
					And DDT.Batch_Code = BPD.Batch_Code
					And DDT.Product_Code = I1.Product_Code
					And BPD.Product_Code = DDT.Product_Code 
					And (DAB.Status & 128) = 0
					And IsNull(BPD.Free,0)<> 0 And IsNull(BPD.Damage,0) <> 1 ),1),

		"DC Free Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code, 
					(Select IsNull(Sum(DDT.Quantity),0) 
					from DispatchAbstract DAB, DispatchDetail DDT, Batch_Products BPD
					Where DAB.DispatchID = DDT.DispatchID
					And DDT.Batch_Code = BPD.Batch_Code
					And DDT.Product_Code = I1.Product_Code
					And BPD.Product_Code = DDT.Product_Code 
					And (DAB.Status & 128) = 0
					And IsNull(BPD.Free,0)<> 0 And IsNull(BPD.Damage,0) <> 1 ),2),  
		"SIT Saleable Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,
					(select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) > 0), 1),

		"SIT Saleable Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,
					(select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) > 0), 2),

		"SIT Free Stock CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,
					(select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) = 0), 1),

		"SIT Free Stock PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(I1.Product_Code,
					(select IsNull(sum(IDR.pending), 0)
					from InvoiceDetailReceived IDR, Invoiceabstractreceived IAR
					where IDR.Product_code = I1.Product_code and IAR.Status & 64 = 0 and IAR.InvoiceId = IDR.InvoiceId
					and Isnull(IDR.saleprice, 0) = 0), 2),
   
          "Saleable Value " =    
          Case @StockValuation        
              When N'PTS'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTS, 0) Else IsNull(I1.PTS, 0) End) *   
                   (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End))      
              When N'PTR'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTR, 0) Else IsNull(I1.PTR, 0) End) *   
                   (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End))   
              When N'ECP'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.ECP, 0) Else IsNull(I1.ECP, 0) End) *   
                    (Case When IsNull(Free,0)= 0 And IsNull(Damage,0) = 0 Then Isnull(Quantity,0) Else 0 End))   
              End,     
         "Damaged Value " =    
          Case @StockValuation        
              When N'PTS'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTS, 0) Else IsNull(I1.PTS, 0) End) *   
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End))      
              When N'PTR'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.PTR, 0) Else IsNull(I1.PTR, 0) End) *   
                   (Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End))   
              When N'ECP'  Then Sum((Case ItemCategories.Price_Option When 1 Then IsNull(Batch_Products.ECP, 0) Else IsNull(I1.ECP, 0) End) *   
                    (Case When IsNull(Damage,0) <> 0 Then Isnull(Quantity,0) Else 0 End))   
              End,       
          "Total Value" =                         
           Cast(Case @StockValuation        
           	  When N'PTS' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTS, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.PTS, 0)) End) End)           
           	  When N'PTR' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.PTR, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.PTR, 0)) End) End)                  
           	  When N'ECP' Then Sum(Case ItemCategories.Price_Option When 1 Then (IsNull(Quantity, 0) * IsNull(Batch_Products.ECP, 0)) Else (Case [Free] When 1 Then 0 Else (IsNull(Quantity, 0) * IsNull(I1.ECP, 0)) End) End)                                    
          	 End as Decimal(18,6))                           
        From        
	         	Items I1
				Left Outer Join Batch_Products On I1.Product_Code = Batch_Products.Product_Code  
				Inner Join ItemCategories On I1.CategoryID = ItemCategories.CategoryID                             
				Inner Join #temp4 On I1.CategoryID = #Temp4.LeafID    
				Inner Join #tempCategory1 On I1.CategoryID = #TempCategory1.CategoryID       
	     		Inner Join Manufacturer On I1.ManufacturerID = Manufacturer.ManufacturerID                           
				Inner Join #tmpMfr On Manufacturer.Manufacturer_Name = #tmpMfr.Manufacturer                                    
				Inner Join #tempItems On I1.Product_Code = #tempItems.Product_Code                                   
        Where ItemCategories.Active = 1     
	         	And I1.Active = 1   
	         	Group BY        
         		I1.Product_Code,I1.ProductName, Manufacturer.ManufacturerID, ItemCategories.CategoryID,  
		    		#temp4.[Parent],I1.UOM1_Conversion,I1.UOM2_Conversion, #TempCategory1.[IDs]      
	     	 Order By 
						#TempCategory1.[IDs],I1.Product_Code        
       End    
     End     
  End      
    
Drop Table #tmpMfr             
Drop Table #tempCategory1        
Drop Table #tempCategory    
Drop Table #tempItems  
Drop Table #temp2    
Drop Table #temp3    
Drop Table #temp4    
