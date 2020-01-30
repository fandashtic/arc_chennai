Create Procedure mERP_sp_Get_QuotMarginOn(@QuotationID int, @Product_Code nVarchar(30))
As
Begin
  Declare @QuotSubType int
  Declare @Catid as int           
  Declare @ParentCatId int  
  Declare @TopLevelCatID int 
  Declare @MfrID Int
  Create Table #Temp(CategoryId int)  
  Select @QuotSubType = QuotationSubType From QuotationAbstract Where QuotationID = @QuotationID
  If @QuotSubType = 1 
  Begin
	Select MarginOn from QuotationItems Where QuotationID = @QuotationID And Product_Code = @Product_Code
  End 
  Else if (@QuotSubType = 2 OR @QuotSubType = 3) 
  Begin
    If @QuotSubType = 3  
    Begin  
      Select @MfrID = Isnull(ManufacturerID,0) from Items Where Product_Code  = @Product_Code  
      Insert into #temp Values (@MfrID)  
    End 
    Else
    Begin
      Select @catid = CategoryID From Items Where Product_Code = @Product_Code  
      Select @TopLevelCatID = CategoryID From ItemCategories Where Category_Name In(Select dbo.fn_FirstLevelCategory(@Catid))  
      Select @ParentCatId  = @Catid  
   
      --This is to include 4th level category group of given item  
      Insert Into #Temp Values (@ParentCatId)  
      While @ParentCatId<>@TopLevelCatID  
      Begin  
        Select @ParentCatId = ParentID From ItemCategories Where CategoryID = @ParentCatId  
        Insert Into #Temp Values (@ParentCatId)  
      End  
    End
	Select Top 1 MarginOn from QuotationMfrCategory Where QuotationID = @QuotationID And MfrCategoryID in (Select CategoryID From #Temp)
  End
  Drop table #Temp
End
