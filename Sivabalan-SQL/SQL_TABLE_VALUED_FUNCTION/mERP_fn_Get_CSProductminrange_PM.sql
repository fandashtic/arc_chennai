Create Function mERP_fn_Get_CSProductminrange_PM(@ParamID Int)  
Returns @tblCSminrange Table (Division nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,Sub_Category nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,MarketSKU nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS, Product_Code nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS)  
  
As  
Begin   
 Declare @tmp as table (  
 Category nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,  
 CATEGORY_LEVEL Int)  
   
 Declare @tmpItems as table (Division nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,Sub_Category nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,MarketSKU nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS, Product_Code nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS)  
   
 Insert Into @tmp(Category,CATEGORY_LEVEL)  
 Select distinct Prodcat_code,Prodcat_LEVEL from tbl_mERP_PMParamFocus Where ParamID =  @ParamID and MIN_Qty>0
  
   
 Declare @Category as nVarchar(255)  
 Declare @LEVEL int  
  
 Declare Cur_tmp Cursor for  
 Select Distinct Category,CATEGORY_LEVEL From @tmp Order By CATEGORY_LEVEL Asc  
 Open Cur_tmp  
 Fetch from Cur_tmp into @Category,@LEVEL
 While @@fetch_status =0  
  Begin  
  
   If @LEVEL = 2  
   Begin  
    Insert Into @tmpItems (Division)
    Select Distinct IC2.Category_Name From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4  
    Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID   
    And IC2.Category_Name = @Category  
   End  
  
   Else If @LEVEL = 3  
   Begin  
    Insert Into @tmpItems (Sub_Category)  
    Select distinct IC3.Category_Name  From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4  
    Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID   
    And IC3.Category_Name = @Category  
    And I.Product_Code Not in (select Distinct Sub_Category From @tmpItems)  

   End  
  
   Else If @LEVEL = 4  
   Begin  
    Insert Into @tmpItems (MarketSKU)  
    Select Distinct IC4.Category_Name From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4  
    Where I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID   
    And IC4.Category_Name = @Category  
    And I.Product_Code Not in (select Distinct MarketSKU From @tmpItems)  
  
   End  
  
   Else If @LEVEL = 5  
   Begin  
    Insert Into @tmpItems (Product_Code)  
    Select Distinct I.Product_Code  From Items I, ItemCategories IC2, ItemCategories IC3, ItemCategories IC4  
	Where Product_Code = @Category And 
	I.CategoryId = IC4.CategoryID And IC3.CategoryId = IC4.ParentID And IC2.CategoryId = IC3.ParentID  and   
    Product_Code Not in (select Distinct Product_Code From @tmpItems)  
   End  
  
   Fetch Next from Cur_tmp into @Category,@LEVEL
  End  
 Close Cur_tmp  
 Deallocate Cur_tmp  
  
 Insert Into @tblCSminrange  
 Select Distinct Division,Sub_Category,MarketSKU, Product_Code From @tmpItems Order By Product_Code  
    
 Return     
End    
