Create Procedure sp_IsAvailableInQuote                   
	@ItemCode nVarchar(30),                  
	@sQuoteIdList nVarchar(1000)                  
As                  
Begin
	Declare @TempQuoteId Table(QuotationId Int, Scheme int)                  
	Declare @tempCategory Table(Categoryid int)                 
	Declare @QuotationId Int        
	Declare @catid as int
	Declare @CategoryID Int, @ItemCategoryID Int, @TmpItemCategoryID Int, @TmpFlag as Int
	Set @TmpFlag = 0

	If Isnull(@sQuoteIdList,N'') <> N''                   
	BEGIN        
		Set @QuotationId = Cast(@sQuoteIdList as int)         
		If (Select Distinct QuotationType From QuotationMfrCategory Where QuotationID = @QuotationId) = 2        
		BEGIN        
			--To check whether the Quotation is defined on Leaf Level    
	        
			IF Exists(Select Top 1 MfrCategoryID From Items Items, QuotationMfrCategory QMfrCat                  
			  Where Items.Product_Code = @ItemCode        
			  and Isnull(Items.CategoryID,0) = QMfrCat.MfrCategoryID         
			  and  QMfrCat.QuotationType = 2        
			  and  QMfrCat.QuotationId = @QuotationId)         
			BEGIN        
				Insert Into @tempcategory         
				Select MfrCategoryID From Items Items, QuotationMfrCategory QMfrCat                  
				Where Items.Product_Code = @ItemCode        
				and Isnull(Items.CategoryID,0) = QMfrCat.MfrCategoryID         
				and  QMfrCat.QuotationType = 2        
				and  QMfrCat.QuotationId = @QuotationId        
			END          
			ELSE        
			BEGIN    
				Select @ItemCategoryID = CategoryID From Items Where Product_Code = @ItemCode And Active = 1
				Set @TmpItemCategoryID = @ItemCategoryID
				Set @CategoryID = @ItemCategoryID
				While @CategoryID <> 0 
				Begin
					Set @CategoryID = 0
					If @TmpFlag = 0
						Set @CategoryID = @ItemCategoryID
					Else
						Select @CategoryID = IsNull(ParentID, 0) From ItemCategories Where CategoryID = (@ItemCategoryID)
					If Exists(Select MfrCategoryID From QuotationMfrCategory Where QuotationID = @QuotationID And MfrCategoryID = @CategoryID And QuotationType = 2)
					Begin
						Insert Into @tempCategory
						Select @TmpItemCategoryID
						Break
					End
					Set @ItemCategoryID = @CategoryID
					Set @TmpFlag = 1
				End
			END        
		END

		Insert Into @TempQuoteId (QuotationId, Scheme )                  
		Select QuotationID, AllowScheme                   
		From QuotationItems QItems                  
		Where                   
		QItems.Product_Code = @ItemCode and                         
		QItems.QuotationId = @sQuoteIdList                   
		Union                  
		Select QuotationID, AllowScheme                   
		From Items Items, QuotationMfrCategory QMfrCat                  
		Where Items.Product_Code = @ItemCode and                  
		((Isnull(Items.ManuFacturerID,0) = QMfrCat.MfrCategoryID     
		and QMfrCat.QuotationType = 1) Or                  
		(Isnull(Items.CategoryID,0) in (select * from @tempCategory)     
		and QMfrCat.QuotationType = 2)) and                
		QMfrCat.QuotationId = @sQuoteIdList                  
		Union                  
		Select QuotationID, 1                   
		From QuotationUniversal QUniv                  
		Where QuotationId = @sQuoteIdList

	End                  
--  Else Condition For Multiple Quotation not Handled                  
                 
Select QuotationId, Scheme                   
From @TempQuoteID                   
Where QuotationId = Isnull((Select Max(QuotationId) From @TempQuoteID),0)                  
End
