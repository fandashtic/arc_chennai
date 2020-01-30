Create Procedure mERP_Sp_ProcessDSTypeMap (@ID int)
AS
Begin

	Declare @DSTypeCode nVarchar(25)	
	Declare @CGName nVarchar(255)
	Declare @Level int
	Declare @PortFolio nvarchar(25)
	Declare @SlNo int
	Declare @CatLevel int
	Declare @DSTypeCodeMap nVarchar(25)

	Declare @DSTypeCode1 nVarchar(25)	
	Declare @CGName1 nVarchar(255)
	Declare @Level1 int
	Declare @PortFolio1 nvarchar(25)
	Declare @SlNo1 int

	Declare @Errmessage nVarchar(4000)
	Declare @ErrStatus int
	Declare @KeyValue nVarchar(255)

	Declare @DSTypeCode2 nVarchar(25)	
	Declare @CGName2 nVarchar(255)
	Declare @SlNo2 int

	Create Table #tmpCatItem(Division nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
		SubCategory nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, MarketSKU nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		ProductCode nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, DSTypeCode nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS, SlNo int)
	
	Create Table #tmpDSType(DSTypeCode nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS, SlNo int)

	Declare DSCursor Cursor For 
	Select DSTypeCode, CG_Name, Level, PortFolio,ID From Recd_DSTypeCGCategoryMap
	where RecdID = @ID and IsNull(Status,0) = 0
	Open DSCursor
	Fetch From DSCursor  Into @DSTypeCode, @CGName, @Level, @PortFolio, @SlNo
	While @@Fetch_Status = 0  
	Begin 
		Set @ErrStatus = 0
	 
		IF Not Exists(Select 'x' From DSType_Master Where DSTypeCode = @DSTypeCode)
		Begin
			Set @Errmessage = 'DSType Code(' + @DSTypeCode + ') does not exists in master table'
			Set @ErrStatus = 1
			Goto last
		End		
			
		Last:
			If (@ErrStatus = 1)
			Begin
				Set @KeyValue = ''
				Set @Errmessage = 'DSTypeCGMap:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage) 
				Set @KeyValue = Convert(nVarchar, @ID) + '|' + Convert(nVarchar,@SlNo)
				Update Recd_DSTypeCGCategoryMap Set Status = 2  Where ID = @SlNo  and RecdID = @ID
				Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
				Values('MastersConfig', @Errmessage,  @KeyValue, getdate())  
			End
		Fetch Next From DSCursor  Into @DSTypeCode, @CGName, @Level, @PortFolio, @SlNo
	End
	Close DSCursor
	DeAllocate DSCursor


	Declare DSMapCursor Cursor For
	Select Distinct DSTypeCode From Recd_DSTypeCGCategoryMap Where RecdID = @ID and IsNull(Status,0) = 0
	Open DSMapCursor
	Fetch From DSMapCursor  Into @DSTypeCodeMap
	While @@Fetch_Status = 0  
	Begin 
		Truncate Table #tmpCatItem

		Declare CatCursor Cursor For
		Select DSTypeCode, CG_Name, Level, PortFolio,ID From Recd_DSTypeCGCategoryMap
		Where RecdID = @ID and IsNull(Status,0) = 0 and DSTypeCode = @DSTypeCodeMap		

		Open CatCursor
		Fetch From CatCursor  Into @DSTypeCode1, @CGName1, @Level1, @PortFolio1, @SlNo1
		While @@Fetch_Status = 0  
		Begin 
			Select @CatLevel = Level From ItemCategories Where Category_Name = @CGName1

			IF @CatLevel = 2
				Insert Into #tmpCatItem(Division, SubCategory, MarketSKU, ProductCode, DSTypeCode, SlNo)
				Select Distinct IC2.Category_Name,IC3.Category_Name, IC4.Category_Name, I.Product_code, @DSTypeCode1, @SlNo1
				From items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 Where
				IC4.categoryid = I.categoryid 
				And IC4.Parentid = IC3.categoryid 
				And IC3.Parentid = IC2.categoryid
				And IC2.Category_Name =  @CGName1
			
			ELSE IF @CatLevel = 3
				Insert Into #tmpCatItem(Division, SubCategory, MarketSKU, ProductCode, DSTypeCode, SlNo)
				Select Distinct IC2.Category_Name,IC3.Category_Name, IC4.Category_Name, I.Product_code, @DSTypeCode1, @SlNo1
				From items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 Where
				IC4.categoryid = I.categoryid 
				And IC4.Parentid = IC3.categoryid 
				And IC3.Parentid = IC2.categoryid
				And IC3.Category_Name = @CGName1

			ELSE IF @CatLevel = 4
				Insert Into #tmpCatItem(Division, SubCategory, MarketSKU, ProductCode, DSTypeCode, SlNo)
				Select Distinct IC2.Category_Name,IC3.Category_Name, IC4.Category_Name, I.Product_code, @DSTypeCode1, @SlNo1
				From items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 Where
				IC4.categoryid = I.categoryid 
				And IC4.Parentid = IC3.categoryid 
				And IC3.Parentid = IC2.categoryid
				And IC4.Category_Name = @CGName1	

			IF @Level1 = 5
				Insert Into #tmpCatItem(Division, SubCategory, MarketSKU, ProductCode, DSTypeCode, SlNo)
				Select '','','',@CGName1,@DSTypeCode1, @SlNo1						

			Fetch Next From CatCursor  Into @DSTypeCode1, @CGName1, @Level1, @PortFolio1, @SlNo1
		End
		Close CatCursor
		DeAllocate CatCursor

		Insert Into #tmpDSType (DSTypeCode, SlNo)
		Select Distinct DSTypeCode, SlNo from #tmpCatItem where ProductCode in 
		(Select ProductCode From #tmpCatItem Group By ProductCode Having Count(ProductCode) > 1)

		Fetch Next From DSMapCursor  Into @DSTypeCodeMap
	End
	Close DSMapCursor
	DeAllocate DSMapCursor	

	Declare ErrCursor Cursor For
	Select DSTypeCode, CG_Name, ID From Recd_DSTypeCGCategoryMap Where RecdID = @ID and IsNull(Status,0) = 0 
		and ID in(Select Distinct SlNo From #tmpDSType)
	Open ErrCursor
	Fetch From ErrCursor  Into @DSTypeCode2, @CGName2, @SlNo2
	While @@Fetch_Status = 0  
	Begin		
		Set @Errmessage = ''

		Set @Errmessage = 'DSType Code(' + @DSTypeCode2 + ') has same level Category Name(' + @CGName2 + ')'
			
		Set @KeyValue = ''
		Set @Errmessage = 'DSTypeCGMap:- ' +  ' ' + Convert(nVarchar(4000), @Errmessage) 
		Set @KeyValue = Convert(nVarchar, @ID) + '|' + Convert(nVarchar,@SlNo2)
		Update Recd_DSTypeCGCategoryMap Set Status = 2  Where ID = @SlNo2  and RecdID = @ID
		Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
		Values('MastersConfig', @Errmessage,  @KeyValue, getdate())  
 
		Fetch Next From ErrCursor  Into @DSTypeCode2, @CGName2, @SlNo2
	End
	Close ErrCursor
	DeAllocate ErrCursor

	--Delete From DSTypeCGCategoryMap Where DSTypeCode in
	--	(Select Distinct DSTypeCode From Recd_DSTypeCGCategoryMap Where RecdID = @ID and IsNull(Status,0) = 0)

	Insert Into DSTypeCGCategoryMap(RecdDocID, DSTypeCode, CG_Name, Level, PortFolio)
	Select @ID, DSTypeCode, CG_Name, Level, PortFolio From Recd_DSTypeCGCategoryMap Where RecdID = @ID and IsNull(Status,0) = 0

	Update DSCG Set DSCG.DSTypeID = DSM.DSTypeID From DSTypeCGCategoryMap DSCG, DSType_Master DSM
		Where DSCG.DSTypeCode = DSM.DSTypeCode

	Update RecdDoc_DSTypeCGCategoryMap Set Status = 1 Where ID = @ID
	Update Recd_DSTypeCGCategoryMap Set Status = 1  Where RecdID = @ID and isnull(Status,0) = 0

	Drop Table #tmpCatItem
	Drop Table #tmpDSType
	
	-- Dataposting for received DSType category Mapping
	Exec sp_DSTypeWiseSKU_DataPost

End
