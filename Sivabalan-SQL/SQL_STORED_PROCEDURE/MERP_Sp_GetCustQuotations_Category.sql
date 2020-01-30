Create Procedure MERP_Sp_GetCustQuotations_Category(@CustCode as nvarchar(50),@ItemCode as nvarchar(255))  
As  
Begin  
 Declare @QuotationID int 
 Declare @QuoID int 
 Declare @Flag as int  
 Declare @CategoryID as int, @ItemCategoryID as Int  
 Declare @Category_name as nVarchar(100)  
 Declare @DataExist as int
 Declare @TmpFlag as Int
 Set @DataExist = 0
 Set @Flag = 0
 Set @QuoID = 0
 Set @TmpFlag = 0
 Create table #tempCategory(CategoryID int,Status int)

Declare AllQuotes Cursor For select A.QuotationId from (Select QAbs.QuotationId  
From QuotationAbstract QAbs, QuotationCustomers QCust  
Where QCust.CustomerID = @CustCode    
And Active = 1   
And Getdate() Between ValidFromDate and ValidToDate   
And QAbs.QuotationId = QCust.QuotationId)A  
Open AllQuotes
Fetch From AllQuotes into @QuotationID
While @@fetch_status = 0
BEGIN
		if @DataExist <> 1
		BEGIN
			if Exists(select Top 1 * from QuotationMFRCategory where QuotationID=@QuotationID)
			Begin
				Select @ItemCategoryID = CategoryID From Items Where Product_Code = @ItemCode And Active = 1
				Set @CategoryID = @ItemCategoryID
				While @CategoryID <> 0 
				Begin
					Set @CategoryID = 0
					If @TmpFlag = 0 
						Set @CategoryID = @ItemCategoryID
					Else
						Select @CategoryID = IsNull(ParentID, 0) From ItemCategories Where CategoryID = (@ItemCategoryID)
					If Exists(Select MfrCategoryID From QuotationMfrCategory Where QuotationID = @QuotationID And MfrCategoryID = @CategoryID)
					Begin
						Set @QuoID = @QuotationID
						Set @Flag = 1 
						Set @DataExist = 1		
						Break
					End
					Set @ItemCategoryID = @CategoryID
					Set @TmpFlag = 1
				End	
			End
		END
Fetch next from AllQuotes into @QuotationID
END
Close AllQuotes
Deallocate AllQuotes

if @Flag=1 
Select @QuoID
else
Select 0	
End
