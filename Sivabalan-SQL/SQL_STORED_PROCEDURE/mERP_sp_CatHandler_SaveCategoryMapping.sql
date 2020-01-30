CREATE Procedure mERP_sp_CatHandler_SaveCategoryMapping(@CustomerCode nVarchar(50), @ParentID Int, @CategoryID Int, @ActiveFlag Int)
As     
Begin
  If @ParentID = 999999 and @CategoryID = 999999
  Begin
    Insert into CustomerProductCategory(CustomerID, CategoryID, Active) 
    Select @CustomerCode, CategoryID, @ActiveFlag from ItemCategories 
    Where ([Level] = 3 or [Level] = 2)  and Active = 1 and CategoryID Not In (
    Select CategoryID From CustomerProductCategory Where Active = 1 and CustomerID = @CustomerCode)
  End
  Else If @CategoryID = 999999
  Begin
    Insert into CustomerProductCategory(CustomerID, CategoryID, Active) 
    Select @CustomerCode, CategoryID, @ActiveFlag from ItemCategories 
    Where (([Level] = 3 and ParentID = @ParentID) Or ([Level] = 2 and CategoryID = @ParentID))
    and Active = 1
    and CategoryID Not In (Select CategoryID From CustomerProductCategory 
    Where Active = 1 and CustomerID = @CustomerCode)
  End
  Else
  Begin 
    If Not Exists(Select CustomerID, CategoryID From CustomerProductCategory Where CustomerID =@CustomerCode and CategoryID = @CategoryID)
    Begin    
      Insert into CustomerProductCategory(CustomerID, CategoryID, Active) Values (@CustomerCode, @CategoryID, @ActiveFlag)    
      /*Save Parent Category when all the subcategories are mapped for the customer*/
      If Not Exists(Select CategoryID from ItemCategories Where ParentID = @ParentID and Active = 1 and 
                    IsNull(Level,0) = 3 and CategoryID not in (Select CategoryID from CustomerProductCategory Where CustomerID = @CustomerCode)
                    Union
                    Select CategoryID from CustomerProductCategory Where CustomerID = @CustomerCode and CategoryID =@ParentID)
      Begin
        Insert into CustomerProductCategory(CustomerID, CategoryID, Active) Values (@CustomerCode, @ParentID, @ActiveFlag)      
      End
    End
  End
  Select @@RowCount
End
