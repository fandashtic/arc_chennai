Create procedure mERP_sp_CatHandler_ListCustomerMapping  
 (@SalesManList nVarchar(Max),  
  @BeatList nVarchar(Max),  
  @Active Int,  
  @MapFilter Int)  
as  
Begin  
 Create Table #TmpSalesManID(SalesmanID Int) 
 Create Table #TmpBeatID(BeatID Int) 
 Create table #tmpCatHandler(Serial Int, 
                            CustomerID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
                            CustomerName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, 
                            CategoryID Int Default 0,
                            CategoryName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS Default NULL,
                            SubCategoryID Int  Default 0,
                            SubCategoryName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS Default NULL)

  If Len(@SalesManList) > 0
   Begin
   Insert into #TmpSalesManID
   Select * from dbo.sp_SplitIn2Rows(@SalesManList,',')
   End
  Else
   Begin
   Insert into #TmpSalesManID
   Select SalesmanId From Salesman Where Active = 1
   End
  If LEN(@BeatList) > 0
   Begin
   Insert into #TmpBeatID
   Select * from dbo.sp_SplitIn2Rows(@BeatList,',')
   End
  Else
   Begin
   Insert into #TmpBeatID
   Select BeatID From Beat Where Active = 1  
  End  
  
 Create Table #tmpCatMapping(ParentID Int, CategoryID Int,  CategoryName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, CatLevel Int) Insert into #tmpCatMapping Select ParentID, CategoryID, Category_Name, [Level]     
 From ItemCategories IC, CategoryLevelInfo CLI    
 Where IC.[Level] = CLI.LevelNo    
 And IC.Active = 1    
 Order by IC.[Level], IC.CategoryID, IC.ParentID     
  
 If @MapFilter = 1  
  Begin  
  --Mapped -Active   
  Insert into #tmpCatHandler(Serial, CustomerID, CustomerName, CategoryID, CategoryName, SubCategoryID, SubCategoryName)  
  Select 1, CM.CustomerID, CM.Company_Name, tCatGrp.CategoryID, tCatGrp.CategoryName as 'Category', tSCatGrp.CategoryID, tSCatGrp.CategoryName as 'SubCategory'  
  From Customer CM, #TmpSalesmanID tSM, #TmpBeatID tBM,   
  CustomerProductCategory CPC, Beat_Salesman BSM,  
  #tmpCatMapping tSCatGrp, #tmpCatMapping tCatGrp  
  Where CM.Active= Case @Active When 1 Then 1 When 2 Then 0 Else CM.Active End  
  and CPC.Active = 1   
  and CM.CustomerID = CPC.CustomerID  
  and CPC.CategoryID = tSCatGrp.CategoryID  
  and tSCatGrp.ParentID = tCatGrp.CategoryID  
  and tSCatGrp.CatLevel = 3  
  and tCatGrp.CatLevel = 2  
  and tSM.SalesmanID = BSM.SalesManID  
  and tBM.BeatID = BSM.BeatID  
  and CM.CustomerID = IsNull(BSM.CustomerID,'')  
  Group by CM.CustomerID, CM.Company_Name, tCatGrp.CategoryName, tSCatGrp.CategoryName, tCatGrp.CategoryID,tSCatGrp.CategoryID  
  Order by CM.Company_Name,tCatGrp.CategoryName, tSCatGrp.CategoryName  
 End  
Else if @MapFilter = 2  
 Begin   
 --UnMapped  
 Insert into #tmpCatHandler(Serial, CustomerID, CustomerName)  
 Select 1, CM.CustomerID, CM.Company_Name  
 From Customer CM, #TmpSalesmanID tSM, #TmpBeatID tBM, Beat_Salesman BSM  
 Where CM.Active=Case @Active When 1 Then 1 When 2 Then 0 Else CM.Active End   
 and CM.CustomerCategory = 2   
 and tSM.SalesmanID = BSM.SalesManID  
 and tBM.BeatID = BSM.BeatID  
 and CM.CustomerID = BSM.CustomerID  
 and CM.CustomerID not in (Select CustomerID From CustomerProductCategory Where Active = 1 Group by CustomerID)  
 Group By CM.CustomerID, CM.Company_Name  
 Order by CM.Company_Name  
 End  
Else  
 Begin  
 --ALL  
 Insert into #tmpCatHandler(Serial, CustomerID, CustomerName, CategoryID, CategoryName, SubCategoryID, SubCategoryName)  
 (Select 2, CM.CustomerID, CM.Company_Name, 0,N'',0,N''  
 From Customer CM, #TmpSalesmanID tSM, #TmpBeatID tBM, Beat_Salesman BSM  
 Where CM.Active=Case @Active When 1 Then 1 When 2 Then 0 Else CM.Active End   
 and CM.CustomerCategory = 2   
 and tSM.SalesmanID = BSM.SalesManID  
 and tBM.BeatID = BSM.BeatID  
 and CM.CustomerID = BSM.CustomerID  
 and CM.CustomerID not in (Select CustomerID From CustomerProductCategory Where Active = 1 Group by CustomerID)  
 Group By CM.CustomerID, CM.Company_Name  
 Union  
 Select 1, CM.CustomerID, CM.Company_Name, tCatGrp.CategoryID, tCatGrp.CategoryName as 'Category', tSCatGrp.CategoryID, tSCatGrp.CategoryName as 'SubCategory'  
 From Customer CM, #TmpSalesmanID tSM, #TmpBeatID tBM,   
 CustomerProductCategory CPC, Beat_Salesman BSM,  
 #tmpCatMapping tSCatGrp, #tmpCatMapping tCatGrp  
 Where CM.Active=Case @Active When 1 Then 1 When 2 Then 0 Else CM.Active End   
 and CPC.Active = 1   
 and CM.CustomerID = CPC.CustomerID  
 and CPC.CategoryID = tSCatGrp.CategoryID  
 and tSCatGrp.ParentID = tCatGrp.CategoryID  
 and tSCatGrp.CatLevel = 3  
 and tCatGrp.CatLevel = 2  
 and tSM.SalesmanID = BSM.SalesManID  
 and tBM.BeatID = BSM.BeatID  
 and CM.CustomerID = IsNull(BSM.CustomerID,'')  
 Group by CM.CustomerID, CM.Company_Name, tCatGrp.CategoryName, tSCatGrp.CategoryName, tCatGrp.CategoryID,tSCatGrp.CategoryID)  
 End  
  
 Select Count(*) From #tmpCatHandler 
 
 Select CustomerID, CustomerName, CategoryID, CategoryName, SubCategoryID, SubCategoryName from #tmpCatHandler  
 Order By Serial, CustomerName, CategoryName, SubCategoryName  
  
 Drop table #TmpSalesmanID
 Drop table #TmpBeatID  
 Drop table #tmpCatMapping  
 Drop table #tmpCatHandler  
  
End
