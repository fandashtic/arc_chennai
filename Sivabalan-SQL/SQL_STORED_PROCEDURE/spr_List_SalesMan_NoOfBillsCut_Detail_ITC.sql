CREATE Procedure spr_List_SalesMan_NoOfBillsCut_Detail_ITC      
  (      
   @SalesmanID int,      
   @CATEGORY_GROUP nVarchar(4000),       
   @CATEGORY NVARCHAR(4000),          
   @DS nVarchar(4000),      
   @Beat nVarchar(4000),      
   @ValueType nVarChar(100),        
   @UOM nVarChar(100),        
   @DSType nVarchar(4000),
   @FROMDATE DATETIME,          
   @TODATE DATETIME      
  )          
AS        
      
Begin      
DECLARE @Delimiter as Char(1)            
DECLARE @tmp_sql1 as nvarchar(4000)      
DECLARE @tmp_sql as nvarchar(4000)      
DECLARE @tmpsum_sql as nvarchar(4000)      
DECLARE @tmp_Col as nvarchar(4000)      
DECLARE @create_sql as nvarchar(4000)      
DECLARE @Fields_sql as nvarchar(4000)      
SET @Delimiter=Char(15)         
DECLARE @CategoryID as int        
DECLARE @Category_Name as nvarchar(510)      
DECLARE @CategoryIDS as int      
      
--Parameter Validation      
--If @ValueType is deleted then make it as Value      
If @ValueType = '%'      
set @ValueType = 'Value'      
--If @ValueType = 'Volume' and @UOM = 'N/A' then Make 'Base UOM' as @UOM      
If @ValueType = 'Volume' and (@UOM <> 'Base UOM' and @UOM <> 'UOM 1' and @UOM <> 'UOM 2')      
set @UOM = 'Base UOM'      
      
--Create the temporary tables      
Create Table #tempCategoryGroup (CategoryGroup NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)        
             
If @CATEGORY_GROUP = '%'         
 Insert Into #tempCategoryGroup Select GroupName From productcategorygroupabstract        
Else        
 Insert Into #tempCategoryGroup Select * From DBO.sp_SplitIn2Rows(@CATEGORY_GROUP,@Delimiter)        
      
Create Table #tempCategoryName (Category_Name NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)        
      
If @CATEGORY = '%'         
 Insert Into #tempCategoryName Select Category_Name From ItemCategories        
Else        
 Insert Into #tempCategoryName Select * From DBO.sp_SplitIn2Rows(@CATEGORY,@Delimiter)      
      
-- Category Group Handling based on the CategoryGroup definition 

Create Table #TempCGCatMapping (GroupID Int, Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryID Int, CategoryName nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert InTo #TempCGCatMapping  
Select "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup, 
"CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division
From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat
Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name

      
Create Table #tempCategory(CategoryID int)                
--Filter #tempCategory for Category group      
insert into #tempCategory      
select distinct ItemCategories.CategoryID       
from ProductCategorygroupAbstract,#TempCGCatMapping,ItemCategories      
where ProductCategorygroupAbstract.groupid = #TempCGCatMapping.groupid      
and  #TempCGCatMapping.CategoryID = ItemCategories.CategoryID      
and ProductCategorygroupAbstract.GroupName In (Select CategoryGroup COLLATE SQL_Latin1_General_CP1_CI_AS From #tempCategoryGroup)        
      
--Get the leaf categories for the paraent categories      
Create Table #tempCategoryTree      
(      
initParentCategoryID int,CategoryID int,HierarchyID int,      
Category_Name NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS  default N'',      
ColSuffix NVarChar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS default N''      
)                
      
DECLARE initParentCategory CURSOR KEYSET FOR                                    
SELECT CategoryID from #tempCategory      
Open  initParentCategory                                    
Fetch From initParentCategory into @CategoryID                                    
WHILE @@FETCH_STATUS = 0                                    
BEGIN         
     insert into #tempCategoryTree(initParentCategoryID,CategoryID,HierarchyID)      
     select @CategoryID,* from sp_get_Catergory_RootToChild(@CategoryID)      
     Fetch next From initParentCategory into @CategoryID                                    
END      
Deallocate initParentCategory      
      
      
--Get the leaf categories for the parent categories for Category parameter      
      
declare @SecondLevelName nvarchar(510)      
select @SecondLevelName = HierarchyName from itemhierarchy where hierarchyid = 2      
      
Create Table #tempCategory2(CategoryID int)           
If @CATEGORY = '%'       
   insert into #tempCategory2         
--   Select * From dbo.fn_GetCatFromCatGroup_ITC(@CATEGORY_GROUP,N'Division')      
Select * From dbo.fn_GetCatFrmCG_ITC(@CATEGORY_GROUP,@SecondLevelName,@Delimiter)      
      else      
   insert into #tempCategory2         
   Select CategoryID From itemcategories      
   where category_Name in(Select * From DBO.sp_SplitIn2Rows(@CATEGORY,@Delimiter))      
      
Create Table #tempCategoryTree2(initParentCategoryID int,CategoryID int,HierarchyID int)          
      
DECLARE initParentCategory CURSOR KEYSET FOR                                    
SELECT CategoryID from #tempCategory2      
Open  initParentCategory                                    
Fetch From initParentCategory into @CategoryID                                    
WHILE @@FETCH_STATUS = 0                                    
BEGIN         
     insert into #tempCategoryTree2      
     select @CategoryID,* from sp_get_Catergory_RootToChild(@CategoryID)      
     Fetch next From initParentCategory into @CategoryID                                    
END      
Deallocate initParentCategory      
      
      
--Filter According to Hierarchy and Category      
delete from #tempCategoryTree       
where #tempCategoryTree.CategoryID not In (select categoryid from #tempCategoryTree2)      
      
--Update CategoryName      
update #tempCategoryTree      
set #tempCategoryTree.Category_Name = Itemcategories.Category_Name      
from #tempCategoryTree,Itemcategories      
where #tempCategoryTree.CategoryID = Itemcategories.CategoryID      
      
Create Table #tempSalesMan (Salesman_Name NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)        
             
If @DS = '%'         
 Insert Into #tempSalesMan Select Salesman_Name From Salesman      
Else        
 Insert Into #tempSalesMan Select * From DBO.sp_SplitIn2Rows(@DS,@Delimiter)      
      
Create Table #tempBeat (BeatName NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)        
             
If @Beat = '%'   --If @Beat = '%' and If @DS = '%' No validation         
  Begin      
      If @DS = '%'          
          Insert Into #tempBeat       
          Select [Description]  From Beat      
      else      
          Insert Into #tempBeat       
          Select [Description]  From Beat      
          where Beat.BeatID in (select * from dbo.fn_GetBeatForSalesMan_ITC(@DS,@Delimiter))      
  End      
Else        
 Insert Into #tempBeat Select * From DBO.sp_SplitIn2Rows(@Beat,@Delimiter)      

Create Table #tempDSType (SalesmanID Int, DSType NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)          

If @DSTYPE= N'%' or @DSType = N''         
   Insert Into #tempDSType 
   select Salesman.SalesmanID,DSTypeValue from DSType_Master,DSType_Details,Salesman
   Where Salesman.SalesmanID = DSType_Details.SalesmanID
   and DSType_Details.DSTypeID = DSType_Master.DSTypeID 
   and DSType_Master.DSTypeCtlPos = 1 
   Union
   Select SalesmanID,N'' from Salesman where SalesmanID not in (select SalesmanID from DSType_Details Where DSTypeCtlPos = 1)
Else  
   Insert into #tempDSType 
   select SalesmanID,DSTypeValue from DSType_Master,DSType_Details
   Where DSType_Master.DSTypeID = DSType_Details.DSTypeID  
   and DSType_Master.DSTypeCtlPos = 1 
   and DSType_Master.DSTypeValue in (select * from dbo.sp_SplitIn2Rows(@DSType,@Delimiter))       
      
--Select Temporary Data      
select * into #tmpData from        
(        
    Select isnull(Beat.BeatID,0) as BeatID,isnull(Beat.[Description],'') as Beat,      
           tmpInvoiceData.initParentCategoryID,tmpInvoiceData.InvoiceID,tmpInvoiceData.InvoiceType,      
           tmpInvoiceData.Quantity as Qty,tmpInvoiceData.NetItemAmount as NetValue,tmpInvoiceData.NetValue as InvNetValue,      
           (      
               Case @UOM When 'Base UOM' Then tmpInvoiceData.Quantity        
               When 'UOM 1' Then dbo.sp_Get_ReportingQty(tmpInvoiceData.Quantity, tmpInvoiceData.UOM1_Conversion)        
               When 'UOM 2' Then dbo.sp_Get_ReportingQty(tmpInvoiceData.Quantity, tmpInvoiceData.UOM2_Conversion)       
               End      
           ) as Quantity      
    From (        
             Select InvoiceAbstract.InvoiceID,InvoiceAbstract.InvoiceType,      
                    case       
                    when InvoiceAbstract.InvoiceType in (1,2,3) then  InvoiceAbstract.NetValue      
                    when InvoiceAbstract.InvoiceType in (4) then  -1*InvoiceAbstract.NetValue       
                    end as NetValue,      
                    case       
                    when InvoiceAbstract.InvoiceType in (1,2,3) then  InvoiceDetail.Quantity      
       when InvoiceAbstract.InvoiceType in (4) then  -1*InvoiceDetail.Quantity      
                    end as Quantity,      
                    case       
    when InvoiceAbstract.InvoiceType in (1,2,3) then      
                         (case when InvoiceDetail.SalePrice  in (0) then 0 else  InvoiceDetail.Amount end)      
                    when InvoiceAbstract.InvoiceType in (4) then      
                         (case when InvoiceDetail.SalePrice in (0) then 0 else  -1*InvoiceDetail.Amount end)      
                    end as NetItemAmount,      
                    InvoiceAbstract.SalesmanID,InvoiceAbstract.BeatID ,      
                    tmp.initParentCategoryID,tmp.UOM1_Conversion,tmp.UOM2_Conversion       
             from InvoiceAbstract,InvoiceDetail,      
                  (      
                       select items.Product_Code,#tempCategoryTree.initParentCategoryID,      
                              items.UOM1_Conversion,items.UOM2_Conversion      
                       from items,#tempCategoryTree      
                       where items.CategoryID = #tempCategoryTree.CategoryID      
                  ) tmp      
             where InvoiceAbstract.InvoiceDate Between @FROMDATE AND @TODATE             
                  and InvoiceAbstract.Status & 128 = 0            
                  and InvoiceAbstract.InvoiceType in (1,2,3,4)        
                  and InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID       
                  and tmp.Product_Code = InvoiceDetail.product_code      
         ) as tmpInvoiceData,salesman,Beat,  #tempDSType tDS
    where         
         tmpInvoiceData.SalesmanID = salesman.SalesmanID                      
         and tmpInvoiceData.BeatID = Beat.BeatID   
         and salesman.SalesmanID = tDS.SalesManID      
         and salesman.Salesman_Name in (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tempSalesMan)         
         and Beat.[Description] in (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tempBeat)         
         and salesman.SalesmanID = @SalesmanID      
) tmp        
      
create table #tmpTransformedData    
(    
BeatID int,Beat NVarChar(500) COLLATE SQL_Latin1_General_CP1_CI_AS  default N'',    
TotalQty decimal(18,6) default 0,TotalValue decimal(18,6) default 0,    
CatwiseTotalQty decimal(18,6) default 0,    
CatwiseTotalValue decimal(18,6) default 0    
)      
      
    
insert into #tmpTransformedData(BeatID,Beat,CatwiseTotalQty,CatwiseTotalValue)      
select BeatID,Beat ,sum(Quantity) as CatwiseTotalQty,sum(Netvalue) as CatwiseTotalValue    
from #tmpData       
group by BeatID,Beat      
order by Beat      
      
  
set @Fields_sql = ''      
set @tmpsum_sql = ''      
      
Create table #TempCategory1(IDS Int Identity(1,1), CategoryID Int,Category NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Status Int)                           
      
--Get the catogory table with sort order              
Exec sp_CatLevelwise_ItemSorting        
      
      
DECLARE Cur_SSV CURSOR KEYSET FOR                                    
SELECT distinct #tempCategoryTree.initParentCategoryID,#TempCategory1.Category , #TempCategory1.IDS      
from #tempCategoryTree,#TempCategory1       
where #tempCategoryTree.initParentCategoryID = #TempCategory1.CategoryID       
      and #tempCategoryTree.Category_Name in (Select Category_Name from #tempCategoryName)      
order by #TempCategory1.IDS        
      
Open  Cur_SSV                                    
Fetch From Cur_SSV into @CategoryID,@Category_Name ,@CategoryIDS                                   
WHILE @@FETCH_STATUS = 0                                    
BEGIN         
     DECLARE @SSV VARCHAR(4000)      
     SET @SSV = ''        
     --Get the Slash Seperated values       
     if @ValueType = 'Value'      
          Begin       
               set @SSV = '(%c)'      
          End       
     else if @ValueType = 'Volume'      
     Begin      
          SELECT @SSV =CASE @SSV WHEN '' THEN tmp.UOM ELSE @SSV + '/' + tmp.UOM END      
          FROM       
          (      
               select GroupName,UOM      
               from      
               (      
                    select tempCategoryTree.initParentCategoryID,tempCategoryTree.CategoryID,      
                           tempCategoryTree.HierarchyID,tempCategoryTree.Category_Name,      
                           tempCategoryTree.ColSuffix,tempCategoryTree.GroupName, UOM.[Description] as UOM      
 from       
                         (      
                              select #tempCategoryTree.initParentCategoryID,#tempCategoryTree.CategoryID,      
                                     #tempCategoryTree.HierarchyID,#tempCategoryTree.Category_Name,      
                                     #tempCategoryTree.ColSuffix,Itemcategories.Category_Name as GroupName       
                              from #tempCategoryTree,Itemcategories       
                              where #tempCategoryTree.initParentCategoryID = Itemcategories.CategoryID      
                         ) tempCategoryTree,      
                         Items,UOM      
                    where (tempCategoryTree.initParentCategoryID = Items.categoryID or tempCategoryTree.CategoryID = Items.categoryID)      
                          --Get the UOM Description based on the Units Parameter      
                          and case @UOM       
                              when 'Base UOM' then Items.UOM       
                              when 'UOM 1' then Items.UOM1       
                              when 'UOM 2' then Items.UOM2       
                              end = UOM.UOM      
                          and (tempCategoryTree.initParentCategoryID = @CategoryID or tempCategoryTree.CategoryID = @CategoryID)      
               ) tmp1      
               group by GroupName,UOM      
          ) tmp       
     End      
     else if @ValueType = 'No.of Bills'      
          Begin      
               set @SSV = 'NBC'      
          end      
      
     --Add the coulmn      
     if len(@SSV) > 0 --If a category does not have UOM1 or UOM2 then avoid the '-'        
          set @SSV = left(@Category_Name+ ' - '  + @SSV ,128) --128 is the maximum length of sql identifier        
     else       
          set @SSV = left(@Category_Name,128) --128 is the maximum length of sql identifier      
      
     set @tmp_Col = '[' + @SSV + ']'      
     set @create_sql = 'Alter table #tmpTransformedData add ' + @tmp_Col + ' Decimal(18,6) default 0'      
     exec sp_executesql @create_sql      
      
     set @tmpsum_sql = @tmpsum_sql +  @tmp_Col + ' + '      
     set @Fields_sql = @Fields_sql +  'sum(' + @tmp_Col + ') as ' + @tmp_Col + ' , '      
      
           
     if @ValueType = 'Value'      
         Begin       
      
              set @tmp_sql = 'Update #tmpTransformedData '      
              set @tmp_sql = @tmp_sql + ' set #tmpTransformedData.' + @tmp_Col + ' = tmp.UpdateVal '      
              set @tmp_sql = @tmp_sql + ' from #tmpTransformedData, '      
              set @tmp_sql = @tmp_sql + ' ( '      
              set @tmp_sql = @tmp_sql + '      select BeatID,sum(UpdateVal) as UpdateVal'      
              set @tmp_sql = @tmp_sql + '      from'      
              set @tmp_sql = @tmp_sql + '      ( '      
              set @tmp_sql = @tmp_sql + '          select  BeatID,InvoiceID,case initParentCategoryID when ' + cast( @CategoryID as nvarchar(20)) + ' then '      
              set @tmp_sql = @tmp_sql + '          isnull(#tmpData.NetValue,0) else 0 end as UpdateVal '      
              set @tmp_sql = @tmp_sql + '          from #tmpdata'      
              set @tmp_sql = @tmp_sql + '      ) tmp1 '      
              set @tmp_sql = @tmp_sql + '      group by BeatID'      
              set @tmp_sql = @tmp_sql + ' ) tmp '      
              set @tmp_sql = @tmp_sql + ' where #tmpTransformedData.BeatID = tmp.BeatID '      
     
         End       
     else if @ValueType = 'Volume'      
         Begin      
              set @tmp_sql = 'Update #tmpTransformedData '      
              set @tmp_sql = @tmp_sql + ' set #tmpTransformedData.' + @tmp_Col + ' = tmp.UpdateVal '      
              set @tmp_sql = @tmp_sql + ' from #tmpTransformedData, '      
              set @tmp_sql = @tmp_sql + ' ( '      
              set @tmp_sql = @tmp_sql + ' select BeatID,sum(case initParentCategoryID when ' + cast( @CategoryID as nvarchar(20)) + ' then '      
              set @tmp_sql = @tmp_sql + ' isnull(#tmpData.Quantity,0) else 0 end) as UpdateVal '      
       set @tmp_sql = @tmp_sql + ' from #tmpdata group by BeatID '      
              set @tmp_sql = @tmp_sql + ' ) tmp '      
              set @tmp_sql = @tmp_sql + ' where #tmpTransformedData.BeatID = tmp.BeatID '      
         End      
     else if @ValueType = 'No.of Bills'      
         Begin      
              set @tmp_sql = 'Update #tmpTransformedData '      
              set @tmp_sql = @tmp_sql + ' set #tmpTransformedData.' + @tmp_Col + ' = tmp.UpdateVal '      
              set @tmp_sql = @tmp_sql + ' from #tmpTransformedData, '      
              set @tmp_sql = @tmp_sql + ' ( '      
              set @tmp_sql = @tmp_sql + ' select BeatID, sum(UpdateVal) as UpdateVal '      
              set @tmp_sql = @tmp_sql + ' from '      
              set @tmp_sql = @tmp_sql + ' ( '      
              set @tmp_sql = @tmp_sql + ' select BeatID,(case initParentCategoryID when ' + cast( @CategoryID as nvarchar(20)) + ' then  count(distinct case when  #tmpdata.InvoiceType in (1,3) then #tmpdata.InvoiceID end) else 0 end) as UpdateVal  '     
 
              set @tmp_sql = @tmp_sql + ' from #tmpdata group by BeatID  ,initParentCategoryID '      
              set @tmp_sql = @tmp_sql + ' ) tmp1 group by BeatID '      
              set @tmp_sql = @tmp_sql + ' ) tmp '      
              set @tmp_sql = @tmp_sql + ' where #tmpTransformedData.BeatID = tmp.BeatID '      
         end      
     --Update the data for the column      
     exec sp_executesql @tmp_sql      
      
--     set @Fields_sql = @Fields_sql + '[' + @SSV + '] , '      
     Fetch next From Cur_SSV into @CategoryID,@Category_Name ,@CategoryIDS                                 
END      
Deallocate Cur_SSV      
      
--Remove the last comma      
set @tmpsum_sql = left(@tmpsum_sql , len(@tmpsum_sql) -2)       
set @Fields_sql = left(@Fields_sql , len(@Fields_sql) -2)       
      
set @tmp_sql = 'Update #tmpTransformedData set TotalQty = ' + @tmpsum_sql      
exec sp_executesql @tmp_sql      
      
--Final Data      
if @ValueType = 'No.of Bills' -- Make the total column visible      
Begin      
     --To avoid the duplication - a invoice may created on more than one Division      
     update #tmpTransformedData      
     set  #tmpTransformedData.TotalQty = tmp.BillsCnt      
     from #tmpTransformedData,      
     (select BeatID, count(distinct case when  #tmpdata.InvoiceType in (1,3) then #tmpdata.InvoiceID end) as BillsCnt from #tmpData group by BeatID) tmp      
     where #tmpTransformedData.BeatID = tmp.BeatID       
      
     set @Fields_sql = 'Select BeatID,Beat , ' + @Fields_sql + ', sum(TotalQty) as [Cat.Grp Wise Total No.Of  Bills Cut], Sum(CatwiseTotalValue) as [Value]' + ' from  #tmpTransformedData group by BeatID,Beat  having sum(TotalQty) > 0'           
     exec sp_executesql @Fields_sql --Selects the data      
End      
else if @ValueType = 'Value' -- Make the total Value visible      
Begin      
     set @Fields_sql = 'Select BeatID,Beat , ' + @Fields_sql + ',Sum(CatwiseTotalValue) as [Value] ' + ' from  #tmpTransformedData group by BeatID,Beat'           
     exec sp_executesql @Fields_sql --Selects the data      
End      
else if @ValueType = 'Volume' -- Make the total Value visible      
Begin      
     set @Fields_sql = 'Select BeatID,Beat , ' + @Fields_sql + ', Sum(CatwiseTotalQty) as [Total Volume],Sum(CatwiseTotalValue) as [Value] ' + ' from  #tmpTransformedData group by BeatID,Beat'           
     exec sp_executesql @Fields_sql --Selects the data      
End      
Handler:      
----Drop  Temp Tables      
drop table #tempCategoryName      
drop table #tempCategoryGroup      
drop table #tempCategory      
drop table #tempSalesMan      
drop table #tempBeat      
drop table #tempDSType
drop table #tempCategoryTree      
drop table #tempCategory2      
drop table #tempCategoryTree2      
drop table #TempCategory1      
drop table #tmpTransformedData      
drop table #tmpData      
End      

