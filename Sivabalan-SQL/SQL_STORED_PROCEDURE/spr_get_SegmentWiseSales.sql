CREATE procedure [dbo].[spr_get_SegmentWiseSales]        
(        
@FromDate DateTime,        
@ToDate   DateTime,        
@BCSOption int,  -- B-Beat/C-Category/S-SalesMan Option        
@SegmentIDs nVarChar(2000),      
@Flag int,      
@CategoryID int = 0,
@CateLevel int = 1  
)        
AS       


	Declare @CatID as int       
	Declare @Delimeter as Char(1)          
	Set @Delimeter=Char(44) -- Char(44) - for (,) Comma Delimeter        
	
	Create Table #TmpSegmentIDs(SegmentID int)        
	Insert into  #TmpSegmentIDs Select * from dbo.sp_SplitIn2Rows(@SegmentIDs,@Delimeter)        
	
	Create Table #TmpCustList (CustCode Varchar(15)  COLLATE SQL_Latin1_General_CP1_CI_AS)        
	Insert into  #TmpCustList   Select CustomerID From Customer where SegmentID in (Select SegmentID from #TmpSegmentIDs)        

	Create Table #TmpResult (CatId  int, CatName  VarChar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS, Quantity decimal(18,6), UOM varchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS, QuantityRU decimal(18,6), RUOM varchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,  GrossValue  decimal(18,6), Tax decimal(18,6),  Discount decimal(18,6), NetValue decimal(18,6))         
	Create Table #TempLevel(ParentId int , CategoryId int)

	IF @BCSOption = 1         
	Begin        
		If @Flag = 1      
		Begin      
			SELECT isnull(InvoiceAbstract.BeatID,0) as BeatID,         
			"BeatName" = (case (isnull(InvoiceAbstract.BeatID,0)) WHEN 0 THEN 'Others' ELSE Beat.Description end),        
			"Quantity" = cast(isnull(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.UOM) ,         
			"Quantity RU" = cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.ReportingUOM),        
			"Gross Value" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END),        
			"Tax" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End),        
			"Discount" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End),        
			--"Net Value" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceAbstract.NetValue Else InvoiceAbstract.NetValue End)        
			"Net Value" = Sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight End)
			From InvoiceAbstract, InvoiceDetail, Beat , Items
			WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and         
			InvoiceAbstract.InvoiceType in (1, 3, 4) And        
			(InvoiceAbstract.Status & 128) = 0 And         
			InvoiceAbstract.InvoiceDate Between @FromDate and @ToDate And         
			InvoiceAbstract.BeatID *= Beat.BeatID And         
			InvoiceAbstract.CustomerID in (Select CustCode from #TmpCustList) And       
			InvoiceDetail.Product_Code = Items.Product_Code         
			Group By InvoiceAbstract.BeatID,Beat.Description, Items.UOM, Items.ReportingUOM      
			Order By InvoiceAbstract.BeatID, Beat.Description        
		End      
		Else      
		Begin      
			SELECT isnull(InvoiceAbstract.BeatID,0) as BeatID,         
			"BeatName" = (case (isnull(InvoiceAbstract.BeatID,0)) WHEN 0 THEN 'Others' ELSE Beat.Description end),        
			"Quantity" = cast(isnull(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar),
       		"Quantity RU" = cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) ,        
			"Gross Value" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END),        
			"Tax" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End),        
			"Discount" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End),        
			--"Net Value" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceAbstract.NetValue Else InvoiceAbstract.NetValue End)        
			"Net Value" = Sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight End)
			From InvoiceAbstract, InvoiceDetail, Beat , Items
			WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and         
			InvoiceAbstract.InvoiceType in (1, 3, 4) And        
			(InvoiceAbstract.Status & 128) = 0 And         
			InvoiceAbstract.InvoiceDate Between @FromDate and @ToDate And         
			InvoiceAbstract.BeatID *= Beat.BeatID And         
			InvoiceAbstract.CustomerID in (Select CustCode from #TmpCustList) and       
			InvoiceDetail.Product_Code = Items.Product_Code         
			Group By InvoiceAbstract.BeatID,Beat.Description
			Order By InvoiceAbstract.BeatID, Beat.Description        
		End      
	End      
	Else IF @BCSOption = 2        
	Begin    
		If @Flag = 1        
		Begin    
			IF (Select Count(*) from ItemCategories where ParentID = @CategoryID) > 0      
			Begin      
				Declare CurCategory Cursor For Select CategoryId From ItemCategories Where ParentID = @CategoryID
				Open CurCategory      
				Fetch Next From CurCategory Into @CatID      
				While @@Fetch_Status = 0      
				Begin
					Insert Into #TmpResult SELECT isnull(ItemCategories.CategoryID,0) as CategoryID,    
					ItemCategories.Category_Name as CategoryName, 
					isnull(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as Quantity,         
					(select ISNULL(Description, '') from UOM WHERE UOM = Items.UOM) as UOM,
					cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as [Quantity RU],        
					(select ISNULL(Description, '') from UOM WHERE UOM = Items.ReportingUOM) as RUOM,
					sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END) as [Gross Value],      
					sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End) as Tax,      
					sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End)as Discount,      
					--sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceAbstract.NetValue Else InvoiceAbstract.NetValue End) as [Net Value]      
					"Net Value" = Sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight End)
					From ItemCategories, InvoiceAbstract, InvoiceDetail, Items       
					WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and       
					InvoiceAbstract.InvoiceDate Between @FromDate and @ToDate And       
					InvoiceAbstract.CustomerID In (Select CustCode from #TmpCustList) And      
					InvoiceDetail.Product_Code = Items.Product_Code And      
					Items.CategoryId = ItemCategories.CategoryID And      
					Items.CategoryID in (Select CategoryID From sp_get_LeafNodes(@CatID) ) And      
					InvoiceAbstract.InvoiceType in (1, 3, 4) And      
					(InvoiceAbstract.Status & 128) = 0       
					Group By ItemCategories.CategoryID, ItemCategories.Category_Name, Items.UOM, Items.ReportingUOM      
					Order By ItemCategories.CategoryID      
					Fetch Next From CurCategory Into @CatID      
				End      
				Close CurCategory      
				Deallocate CurCategory

				Declare CurTemp Cursor For Select CategoryID From ItemCategories Where Level = @CateLevel
				Open CurTemp
				Fetch Next From CurTemp Into @CatID
				While @@Fetch_Status =0
				Begin
					Insert Into #TempLevel Select @CatID, CategoryID From dbo.sp_get_LeafNodes(@CatID)
					Fetch Next From CurTemp Into @CatID
				End	
				
				Select  T1.ParentID as CategoryID, (Select dbo.fn_GetCategoryName(T1.ParentID) ) as CategoryName,  Cast(Sum(T2.Quantity) as varchar) + ' ' + T2.UOM as Quantity, Cast(Sum(T2.QuantityRU) as varchar) + ' ' + T2.RUOM  as [Quantity RU], Sum(T2.GrossValue) as [Gross Value], Sum(T2.Tax) as Tax, Sum(T2.Discount) as Discount, Sum(T2.NetValue) as [Net Value] From #TempLevel T1, #TmpResult T2 
				Where T2.CatId = T1.CategoryID Group By T1.ParentID, T2.UOM, T2.RUOM
				Close CurTemp
				Deallocate CurTemp
			End

			Else      
			Begin      
				SELECT InvoiceDetail.Product_Code,Items.ProductName, Sum(InvoiceDetail.SalePrice) as [Sale Price],
				cast(isnull(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity       
				ELSE InvoiceDetail.Quantity END),0) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.UOM) as Quantity,         
				cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.ReportingUOM) as [Quantity RU],        
				sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END) as [Gross Value],      
				sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End) as Tax,      
				sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End)as Discount,      
				--sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceAbstract.NetValue Else InvoiceAbstract.NetValue End) as [Net Value]      
				"Net Value" = Sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight End)
				From ItemCategories, InvoiceAbstract, InvoiceDetail, Items       
				WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and       
				InvoiceAbstract.InvoiceDate Between @FromDate and @ToDate And       
				InvoiceAbstract.CustomerID In (Select CustCode from #TmpCustList) And      
				InvoiceDetail.Product_Code = Items.Product_Code And      
				Items.CategoryId = ItemCategories.CategoryID And      
				Items.CategoryID = @CategoryID And      
				InvoiceAbstract.InvoiceType in (1, 3, 4) And      
				(InvoiceAbstract.Status & 128) = 0       
				Group By InvoiceDetail.Product_Code,Items.ProductName, Items.UOM, Items.ReportingUOM      
				Order By InvoiceDetail.Product_Code      
			End      
		End    
		Else --Else of If @Flag = 1    
		Begin     
			IF (Select Count(*) from ItemCategories where ParentID = @CategoryID) > 0      
			Begin      
				Declare CurCategory Cursor For Select CategoryId From ItemCategories Where ParentID = @CategoryID      
				Open CurCategory      
				Fetch Next From CurCategory Into @CatID      
				While @@Fetch_Status = 0      
				Begin      
					Insert Into #TmpResult(CatId, CatName, Quantity, QuantityRU, GrossValue , Tax , Discount , NetValue) SELECT isnull(ItemCategories.CategoryID,0) as CategoryID,ItemCategories.Category_Name,   
					cast(isnull(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar) as Quantity,
 		      		cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) as [Quantity RU],           
					sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END) as GrossValue,      
					sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End) as Tax,      
					sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End)as Discount,      
					--sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceAbstract.NetValue Else InvoiceAbstract.NetValue End) as NetValue      
					"Net Value" = Sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight End)
					From ItemCategories, InvoiceAbstract, InvoiceDetail, Items       
					WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and       
					InvoiceAbstract.InvoiceDate Between @FromDate and @ToDate And       
					InvoiceAbstract.CustomerID In (Select CustCode from #TmpCustList) And      
					InvoiceDetail.Product_Code = Items.Product_Code And      
					--ItemCategories.ParentID = @CateLevel And      
					Items.CategoryId = ItemCategories.CategoryID And      
					Items.CategoryID in (Select CategoryID From sp_get_LeafNodes(@CatID) ) And      
					InvoiceAbstract.InvoiceType in (1, 3, 4) And      
					(InvoiceAbstract.Status & 128) = 0       
					Group By ItemCategories.CategoryID, ItemCategories.Category_Name      
					Order By ItemCategories.CategoryID      
					Fetch Next From CurCategory Into @CatID      
					End      
					Close CurCategory      
					Deallocate CurCategory       

					Declare CurTemp Cursor For Select CategoryID From ItemCategories Where Level = @CateLevel
					Open CurTemp
					Fetch Next From CurTemp Into @CatID
					While @@Fetch_Status =0
					Begin
						Insert Into #TempLevel Select @CatID, CategoryID From dbo.sp_get_LeafNodes(@CatID)
						Fetch Next From CurTemp Into @CatID
					End	
					
					Select  T1.ParentID as CategoryID, (Select dbo.fn_GetCategoryName(T1.ParentID) ) as CategoryName,  Sum(T2.Quantity) as Quantity, Sum(T2.QuantityRU) as [Quantity RU], Sum(T2.GrossValue) as [Gross Value], Sum(T2.Tax) as Tax, Sum(T2.Discount) as Discount, Sum(T2.NetValue) as [Net Value] From #TempLevel T1, #TmpResult T2 
					Where T2.CatId = T1.CategoryID Group By T1.ParentID
					Close CurTemp
					Deallocate CurTemp
				End      
				Else      
				Begin      
					SELECT InvoiceDetail.Product_Code,Items.ProductName, Sum(InvoiceDetail.SalePrice) as [Sale Price],     
					cast(isnull(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar) as Quantity,
		      		cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) as [Quantity RU],           
					sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END) as [Gross Value],      
					sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End) as Tax,      
					sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End)as Discount,      
					--sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceAbstract.NetValue Else InvoiceAbstract.NetValue End) as [Net Value]      
					"Net Value" = Sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight End)
					From ItemCategories, InvoiceAbstract, InvoiceDetail, Items       
					WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and       
					InvoiceAbstract.InvoiceDate Between @FromDate and @ToDate And       
					InvoiceAbstract.CustomerID In (Select CustCode from #TmpCustList) And      
					InvoiceDetail.Product_Code = Items.Product_Code And      
					--ItemCategories.ParentID = @CateLevel And      
					Items.CategoryId = ItemCategories.CategoryID And      
					Items.CategoryID = @CategoryID And      
					InvoiceAbstract.InvoiceType in (1, 3, 4) And      
					(InvoiceAbstract.Status & 128) = 0       
					Group By InvoiceDetail.Product_Code,Items.ProductName
					Order By InvoiceDetail.Product_Code      
				End      
			End    
		End        
		
	Else IF @BCSOption = 3        
	Begin        
		If @Flag = 1      
		Begin      
			SELECT isnull(InvoiceAbstract.SalesmanID,0) as SalesmanID,         
			"SalesmanName" = (case (isnull(InvoiceAbstract.SalesmanID,0)) WHEN 0 THEN 'Others' ELSE SalesMan.Salesman_Name end),        
			"Quantity" = cast(isnull(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity       
			ELSE InvoiceDetail.Quantity END),0) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.UOM) ,         
			"Quantity RU" = cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18,2)) as varchar) + ' ' + (select ISNULL(Description, '') from UOM WHERE UOM = Items.ReportingUOM),        
			"Gross Value" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END),        
			"Tax" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End),        
			"Discount" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End),        
			--"Net Value" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceAbstract.NetValue Else InvoiceAbstract.NetValue End)        
			"Net Value" = Sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight End)
			From InvoiceAbstract, InvoiceDetail,Salesman, Items 
			WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and         
			InvoiceAbstract.InvoiceType in (1, 3, 4) And        
			(InvoiceAbstract.Status & 128) = 0 And         
			InvoiceAbstract.InvoiceDate Between @FromDate and @ToDate And         
			InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And         
			InvoiceAbstract.CustomerID in (Select CustCode from #TmpCustList) And       
			InvoiceDetail.Product_Code = Items.Product_Code         
			Group By InvoiceAbstract.SalesmanID,Salesman.SalesMan_Name, Items.UOM, Items.ReportingUOM        
			Order By InvoiceAbstract.SalesmanID, SalesMan.SalesMan_Name        
		End        
		Else      
		Begin      
		
			SELECT isnull(InvoiceAbstract.SalesmanID,0) as SalesmanID,         
			"SalesmanName" = (case (isnull(InvoiceAbstract.SalesmanID,0)) WHEN 0 THEN 'Others' ELSE SalesMan.Salesman_Name end),        
			"Quantity" = cast(isnull(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END),0) as varchar)  ,        
			"Quantity RU" = cast(cast(isnull(sum((case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Quantity ELSE InvoiceDetail.Quantity END) / (case isnull(Items.ReportingUnit,0) when 0 then 1 else isnull(Items.ReportingUnit,0) end)),0) as decimal(18	,2)) as varchar),        
			"Gross Value" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.Amount ELSE InvoiceDetail.Amount END),        
			"Tax" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.TaxAmount Else InvoiceDetail.TaxAmount End),        
			"Discount" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceDetail.DiscountValue Else InvoiceDetail.DiscountValue End),        
			--"Net Value" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - InvoiceAbstract.NetValue Else InvoiceAbstract.NetValue End)        
			"Net Value" = Sum(case InvoiceAbstract.InvoiceType when 4 then 0- (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) Else (InvoiceDetail.Amount +  InvoiceDetail.TaxSuffAmount - InvoiceDetail.SplCatDiscAmount - InvoiceDetail.SchemeDiscAmount) + InvoiceAbstract.Freight End)
			From InvoiceAbstract, InvoiceDetail,Salesman, Items--, ItemCategories, Salesman        
			WHERE   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and         
			InvoiceAbstract.InvoiceType in (1, 3, 4) And        
			(InvoiceAbstract.Status & 128) = 0 And         
			InvoiceAbstract.InvoiceDate Between @FromDate and @ToDate And         
			InvoiceAbstract.SalesmanID *= Salesman.SalesmanID And         
			InvoiceAbstract.CustomerID in (Select CustCode from #TmpCustList) And        
			InvoiceDetail.Product_Code = Items.Product_Code          
			Group By InvoiceAbstract.SalesmanID,Salesman.SalesMan_Name       
			Order By InvoiceAbstract.SalesmanID, SalesMan.SalesMan_Name        


		End         
	End      

	Drop Table #TmpResult    
	Drop Table #TempLevel
	Drop Table #TmpCustList      
	Drop Table #TmpSegmentIDs
