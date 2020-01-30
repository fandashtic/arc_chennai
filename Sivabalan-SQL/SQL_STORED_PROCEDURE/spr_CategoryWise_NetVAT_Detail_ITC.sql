Create procedure spr_CategoryWise_NetVAT_Detail_ITC         
(        
 @Tax nvarchar(550),  
 @CatGroup nVarchar(4000),  
 @Hierarchy nvarchar(255),  
 @Category nVarchar(4000),        
 @FromDate datetime,         
 @ToDate DateTime,        
 @TaxUnusedParameter nvarchar(10),        
 @Locality nvarchar(50),        
 @ItemCode nvarchar(4000),        
 @ItemName nvarchar(4000),
 @TaxSplitUp nVarchar(5), 
 @TaxType nVarchar(20) 
)         
as        
Begin        
 declare @TaxCode int  
 declare @TaxDesc nvarchar(510)  
 declare @Pos as int  
 declare @Pos1 as int  
 declare @CatID as int  
 declare @Continue as int  
 declare @Continue1 as int  
 declare @inc as int  
 declare @TCat as int  
 declare @CategoryID as int  
 Declare @Delimeter as Char(1)        
 Declare @taxCnt as Int
 Declare @incr as int
 Declare @TaxTypeID Int 

 Declare @tempSQL as nVarchar(4000)
 Declare @Local1 as Int
 Declare @outstation as Int
 Declare @LstLevelCnt as Int
 Declare @CstLevelCnt as Int
 Declare @i as Int
 Declare @itmCode as nVarchar(100)
 Declare @TaxPer as Decimal(18,6)
 Declare @CompCode as Int
 Declare @CompPer as Decimal(18,6)
 Declare @count as Int
 Declare @CountCST as Int
 Declare @CompSP_Per as Decimal(18,6)

 Declare @TC as Int, @TCC as Int	-- To store tax code and tax component code
 Declare @TaxCompHead as nVarchar(1000)
 Declare @temp datetime
 Set DATEFormat DMY
 set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)


if(@FROMDATE > @temp )
begin
select 0,'This report cannot be generated for GST period' as Reason
goto GSTOut
 end


if(@TODATE > @temp )
begin
set @TODATE  = @temp 
--goto GSTOut
end


 Set @Delimeter=Char(15)  
 set @Pos = charindex (char(15), @Tax, 1)  
 set @CatID = substring(@Tax, 1, @Pos-1)  
 set @Tax = substring(@Tax, @Pos + 1, 1000)  
 set @Pos = charindex (char(15), @Tax, 1)  
 set @TaxCode = substring(@Tax, 1, @Pos-1)  
 set @Tax = substring(@Tax, @Pos + 1, 1000)  
 set @Pos = charindex (char(15), @Tax, 1)  
 set @TaxDesc = substring(@Tax, @Pos + 1, 510)  
 set @Tax = substring(@Tax, 1, @Pos - 1)  
 Set @inc = 1  


 
Create Table #tmpCat(IDS Int Identity(1,1),CatID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
Insert Into #tmpCat Values(@CatID)  
Create Table #temp3 (CatID Int, Status Int)      
Create Table #temp4 (LeafId int,CatID Int, Parent nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create Table #tmpProd(Prod_Code  nvarchar(455) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create Table #tempCatGroup(GroupName nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create Table #tempCatGroupID (CatID Int, Status Int)        
Create Table #tempCG(IDS Int Identity(1,1),CatID Int)
Create Table #tempTax(Tax_Code Int,Tax_Description Nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,Percentage Decimal(18,6),LstApplicableOn Int,LstPartOff Decimal(18,6))
Create Table #tempPercentage(Ids Int Identity(1,1),Percentage Decimal(18,6))

Insert Into #tempPercentage
Select Distinct Percentage From Tax

-- get all the Sales for the given taxtype filter
select InvoiceId, [taxtype]
Into #InvoiceTaxType from (
    select InvoiceId, ( Case when cstpayable > 0 then 'CST' Else 'LST' End) [taxtype] 
    from (
        select Ia.InvoiceId, max(Id.stpayable) stpayable, max(Id.cstpayable) cstpayable
        from Invoiceabstract Ia Join InvoiceDetail Id on Ia.InvoiceId = Id.InvoiceId
		where Ia.InvoiceDate >= @FromDate and Ia.InvoiceDate <= @ToDate and status & 128 = 0
        group by Ia.InvoiceId ) tmp 
    )Idtmp 
	where taxtype = @TaxType 

--Inserts Distinct TaxPercentage
Set @incr = 1
Select @taxCnt = Count(*) From #tempPercentage
While @incr <= @taxCnt
Begin
     	Insert Into #tempTax
	Select top 1 Tax_Code,Tax_Description,Percentage,LstApplicableOn,LstPartOff From Tax
	Where Percentage = (Select Percentage From #tempPercentage Where Ids = @incr)
           Order By Tax_Code Desc
Set @incr = @incr + 1
End

drop table #tempPercentage

If @TaxSplitUp = N'Yes'
Begin
	Create Table #tmpMax(CompCount Int)
	Create Table #tmpComp(Comp_Code Int,Comp_Per Decimal(18,6),CompSP_Per Decimal(18,6))
	Create Table #tmpTaxComp(TaxCode Int, TaxCompCode Int, Flag Int)
	Create Table #tmpTaxComp1(TaxCode Int, TaxCompCode Int)

	--Gets the LST Comp level count
	Delete From #tmpMax  
	Insert Into #tmpMax  
	Select count(Tax_Code) From TaxComponents Where Tax_Code = @TaxCode And LST_Flag = 1 group By Tax_Code
	Set @LSTLevelCnt = 0
	Select @LSTLevelCnt = Max(CompCount) From #tmpMax

	Delete From #tmpTaxComp
	Insert Into #tmpTaxComp
	Select Tax_Code, TaxComponent_Code, LST_Flag From TaxComponents Where Tax_Code = @TaxCode And LST_Flag = 1 group By Tax_Code, TaxComponent_Code, LST_Flag

	--Gets the CST Comp level count
	Delete From #tmpMax  
	Insert Into #tmpMax  
	Select count(Tax_Code) From TaxComponents Where Tax_Code = @TaxCode And LST_Flag = 0 group By Tax_Code
	Set @CSTLevelCnt = 0
	Select @CSTLevelCnt = Max(CompCount) From #tmpMax

	Insert Into #tmpTaxComp
	Select Tax_Code, TaxComponent_Code, LST_Flag From TaxComponents Where Tax_Code = @TaxCode And LST_Flag = 0 group By Tax_Code, TaxComponent_Code, LST_Flag

	Drop Table #tmpMax  
End

select @Local1 = case when @Locality = N'Local' then 1 when @Locality='%' then 1 else 0 end
select @outstation = case when @Locality = N'OutStation' then 2 when @Locality='%' then 2 else 0 end

  
if @ItemCode='%'      
	insert into #tmpProd select product_code from items      
else      
	insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter) 

if @CatGroup = N'%'  
	Insert Into #tempCatGroup Select GroupName From ProductCategoryGroupAbstract 
else
	Insert Into #tempCatGroup select * from dbo.sp_SplitIn2Rows( @CatGroup,@Delimeter)  


--Gets the leafid for the passed CategoryID  
Set @Continue = IsNull((Select Count(*) From #tmpCat), 0)      
While @Inc <= @Continue      
Begin      
 Insert InTo #temp3 Select CatID, 0 From #tmpCat Where IDS = @Inc      
    Select @TCat = CatID From #tmpCat Where IDS = @Inc      
 Select @Continue1 = Count(*) From #temp3 Where Status = 0          
   While @Continue1 > 0          
 Begin          
     Declare Parent Cursor Keyset For          
     Select CatID From #temp3  Where Status = 0          
     Open Parent          
     Fetch From Parent Into @CategoryID    
     While @@Fetch_Status = 0          
     Begin          
      Insert into #temp3 Select CategoryID, 0 From ItemCategories           
      Where ParentID = @CategoryID  
      If @@RowCount > 0           
        Update #temp3 Set Status = 1 Where CatID = @CategoryID          
      Else             
        Update #temp3 Set Status = 2 Where CatID = @CategoryID  
      Fetch Next From Parent Into @CategoryID         
     End     
     Close Parent          
     DeAllocate Parent           
     Select @Continue1 = Count(*) From #temp3 Where Status = 0          
   End          
 Delete #temp3 Where Status not in  (0, 2)          
 Insert InTo #temp4 Select CatID, @TCat,     
 (Select Category_Name From ItemCategories where CategoryID = @TCat) From #temp3     
 Delete #temp3      
 Set @Continue1 = 1      
 Set @Inc = @Inc + 1      
End      


-- Category Group Handling based on the CategoryGroup definition 

Declare @TempCGCatMapping Table (GroupID Int, Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryID Int, CategoryName nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert InTo @TempCGCatMapping 
Select "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup, 
"CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division
From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat
Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name


--Gets the categoryid for the selected Catgroup or the selected category itself
if @Category =N'%'
	Insert into #tempCG  
	select PD.CategoryID   
	from ProductCategorygroupAbstract PA, @TempCGCatMapping PD
	where PA.groupid = PD.groupid  
	and PA.GroupName In (Select GroupName COLLATE SQL_Latin1_General_CP1_CI_AS From  #tempCatGroup)    
ELSE
    Insert into #tempCG
	select Categoryid From itemcategories itc Where Category_Name 
	In(Select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter))              


Set @Inc =1
Set @CategoryID  =0
Delete #temp3        

--gets leaf categories for the selected category group
Set @Continue = IsNull((Select Count(*) From #tempCG), 0)        
While @Inc <= @Continue        
Begin        
 Insert InTo #tempCatGroupID Select CatID, 0 From #tempCG Where IDS = @Inc        
 Select @Continue1 = Count(*) From #tempCatGroupID Where Status = 0            
 While @Continue1 > 0            
 Begin            
     Declare Parent Cursor Keyset For            
     Select CatID From #tempCatGroupID  Where Status = 0            
     Open Parent            
     Fetch From Parent Into @CategoryID      
     While @@Fetch_Status = 0            
     Begin            
      Insert into #tempCatGroupID Select CategoryID, 0 From ItemCategories             
      Where ParentID = @CategoryID    
      If @@RowCount > 0             
        Update #tempCatGroupID Set Status = 1 Where CatID = @CategoryID            
      Else               
        Update #tempCatGroupID Set Status = 2 Where CatID = @CategoryID    
      Fetch Next From Parent Into @CategoryID           
     End       
     Close Parent            
     DeAllocate Parent             
     Select @Continue1 = Count(*) From #tempCatGroupID Where Status = 0            
   End            
 Delete #tempCatGroupID Where Status not in  (0, 2)            
 Set @Inc = @Inc + 1        
End 

--#temp4  - has all leafid's under the selcted hierarchy
--#tempCatGroupID - has all leafid's under the selcted categorygroup or selcted category

Select @TaxTypeID = TaxID From tbl_mERP_Taxtype 
Where TaxType = @TaxType 

 create table #VATReport        
 (        
  [ICode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,        
  [Item Code] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,        
  [Item Name] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,        
  [Tax %] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS ,
  [Tax Type] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS   
 )        



Create Table #tmpVat
(
  [Type] nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
  [ICode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,        
  [Item Code] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,        
  [Item Name] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,        
  [Tax %] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
  [Tax Type] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS 
)


--take distinct (products and tax percentages) from Bills, Adj Returns and Invoices        
insert into #tmpVat ([Type],ICode, [Item Code], [Item Name], [Tax %], [Tax Type])        
---Purchase
select Distinct (Case @TaxTypeID When 2 Then N'OB' Else 'LB' End),It.Product_Code, It.Product_Code, It.ProductName, BD.TaxSuffered, TxzType.TaxType
from Items It, BillAbstract BA, BillDetail BD, Vendors V,#temp4, tbl_mERP_TaxType TxzType  
where         
   BD.Product_Code In(Select Prod_Code From #tmpProd)  
   and BA.BillID = BD.BillID        
   and BD.Product_Code = It.Product_Code        
   and It.CategoryID = #temp4.LeafID  
   and #temp4.LeafID In(Select CatID From #tempCatGroupID)
   and BA.BillDate between @FromDate and @ToDate        
   and BA.Status = 0        
   and BD.TaxSuffered =  convert(decimal(18,6),@Tax)  
   and TxzType.TaxID = IsNull(BA.TaxType,1)
   and TxzType.TaxID = @TaxTypeID 
   and (  
   @Tax = (case when @TaxTypeID = 1 or @TaxTypeID = 3 then (Select Tax.Percentage from tax where Tax_Description = @TaxDesc) else (Select Tax.CST_Percentage from tax where Tax_Description = @TaxDesc) end)  
   or (convert(decimal(18,6),@Tax) = convert(decimal(18,6),0) and @TaxDesc = 'Exempt' and BD.TaxSuffered = convert(decimal(18,6),0) )  
  )  
   and (Case When BD.TaxSuffered = 0 Then 0 Else BD.TaxCode End) =  (case When @TaxCode = -1 Then 0 Else @TaxCode End)
   and V.VendorID = BA.VendorID        
   and (case when BD.TaxSuffered=0  then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end)= @TaxDesc  
--   and V.Locality like (        
--         case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--         else '%' end        
--        )        
	group by BD.TaxCode, It.Product_Code, It.ProductName, BD.TaxSuffered,V.Locality, TxzType.TaxType        
	having SUM(BD.Amount + BD.TaxAmount)>0        
union        
---Purchase Return
select Distinct (Case @TaxTypeID When 2 Then N'OBR' Else N'LBR' End),It.Product_Code, It.Product_Code, It.ProductName,ARD.Tax, TxzType.TaxType
from Items It, AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V,#temp4, Batch_Products bp, tbl_mERP_TaxType TxzType      
where   
   It.Product_Code In(Select Prod_Code From #tmpProd)  
   and ARA.AdjustmentID = ARD.AdjustmentID        
   and (isnull(ARA.Status,0) & 128) = 0        
   and ARD.Product_Code = It.Product_Code
   and ARD.BatchCode = bp.Batch_Code 
   and IsNull(bp.TaxType, 1) =  @TaxTypeID 
   and It.CategoryID = #temp4.LeafID  
   and #temp4.LeafID In(Select CatID From #tempCatGroupID)
   and ARA.AdjustmentDate between @FromDate and @ToDate        
   and TxzType.TaxID = @TaxTypeID 
   and (  
   (ARD.Tax = 0 ) or  
   ARD.Tax = (case when @TaxTypeID = 1 or @TaxTypeID = 3 then (Select Tax.Percentage from tax where Tax_Description = @TaxDesc) else (Select Tax.CST_Percentage from tax where Tax_Description = @TaxDesc) end)  
  )  
   and ARD.Tax = convert(decimal(18,6),@Tax)  
   and ARA.VendorID = V.VendorID        
   and (case when ARD.Tax=0  then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc  
--   and cast(V.Locality as nvarchar) like (case @Locality         
--             when 'Local' then '1'         
--             when 'Outstation' then '2'         
--             else '%' end) + '%'        
	group by It.Product_Code, It.ProductName, ARD.Tax,V.Locality, TxzType.TaxType
	having sum(ARD.Total_Value)>0        
union        
--Local Invoice
select Distinct 'LI',It.Product_Code, It.Product_Code, It.ProductName,IDt.TaxCode, TxzType.TaxType
from Items It, InvoiceAbstract IA, InvoiceDetail IDt, Customer C, #temp4, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
where         
   IDt.Product_Code  In(Select Prod_Code From #tmpProd)  
   and IA.InvoiceID = IDt.InvoiceID
   and IDt.Product_Code = It.Product_Code        
--   and IsNull(C.Locality, 1) = @TaxTypeID
   and It.CategoryID = #temp4.LeafID  
   and #temp4.LeafID In(Select CatID From #tempCatGroupID)
--   and IA.InvoiceDate between @FromDate and @ToDate        
   and #I.InvoiceId = Ia.InvoiceId
   and TxzType.TaxID = @TaxTypeID 
   and (        
     (--Trade Invoice----------------        
      (IA.Status & 192) = 0        
      and IA.InvoiceType in (1, 3)        
     )-------------------------------        
    )       
   and IDt.TaxCode = convert(decimal(18,6),@Tax)  
   and (
		IsNull(IDt.TaxID, 0) = @TaxCode Or
		( @TaxCode  = -1 and IDt.Taxcode = 0 and IDt.Taxcode2 = 0 ) 
       )				
   and C.CustomerID = IA.CustomerID        
   and #I.[taxtype] = 'LST'
   and (case when IDt.TaxCode=0  then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc  
   and convert(decimal(18,6),@Tax) = (case when IDt.TaxCode=0  then 0 else (select Tax.Percentage from tax where Tax_Description = @TaxDesc) end)  
--   and cast(C.Locality as nvarchar) like (case @Locality
--             when 'Local' then '1'
--             when 'Outstation' then '2'
--             else '%' end) + '%'
  group by IDt.TaxID, It.Product_Code, It.ProductName, IDt.TaxCode, IDt.TaxCode,IA.Status, TxzType.TaxType  
  having sum(IDt.Amount)>0        
union        
---Local Sales Return Saleable/Damage
select Distinct (Case  (IA.Status & 32) When 0 Then 'LSRS' Else 'LSRD' End),  It.Product_Code, It.Product_Code, It.ProductName,IDt.TaxCode, TxzType.TaxType
from Items It, InvoiceAbstract IA, InvoiceDetail IDt, Customer C  ,#temp4, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
where         
   IDt.Product_Code  In(Select Prod_Code From #tmpProd)  
   and IA.InvoiceID = IDt.InvoiceID        
   and IDt.Product_Code = It.Product_Code        
--   and IsNull(C.Locality, 1) = @TaxTypeID
   and It.CategoryID = #temp4.LeafID  
   and #temp4.LeafID In(Select CatID From #tempCatGroupID)
--   and IA.InvoiceDate between @FromDate and @ToDate        
   and #I.InvoiceId = Ia.InvoiceId
   and TxzType.TaxID = @TaxTypeID 
   and (        
     (--Sales Return-----------------        
  (IA.Status & 192) = 0  and ((IA.Status & 32) = 0 Or (IA.Status & 32) <> 0)
        and IA.InvoiceType = 4        
     )-------------------------------        
    )        
   and IDt.TaxCode = convert(decimal(18,6),@Tax)  
   and (
		IsNull(IDt.TaxID, 0) = @TaxCode Or
		( @TaxCode  = -1 and IDt.Taxcode = 0 and IDt.Taxcode2 = 0 ) 
       )				
   and C.CustomerID = IA.CustomerID        
   and #I.[taxtype] = 'LST'
   and (case when IDt.TaxCode=0  then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc  
   and convert(decimal(18,6),@Tax) = (case when IDt.TaxCode=0  then 0 else (select Tax.Percentage from tax where Tax_Description = @TaxDesc) end)  
--   and cast(C.Locality as nvarchar) like (case @Locality
--             when 'Local' then '1'
--             when 'Outstation' then '2'
--             else '%' end) + '%'
  group by IDt.TaxID, It.Product_Code, It.ProductName, IDt.TaxCode, IDt.TaxCode,IA.Status, TxzType.TaxType  
  having sum(IDt.Amount)>0        
union        
--Outstation Invoice
select Distinct 'OI', It.Product_Code, It.Product_Code, It.ProductName, IDt.TaxCode2, TxzType.TaxType
  from Items It, InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax  ,#temp4, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
  where         
   IDt.Product_Code In(Select Prod_Code From #tmpProd)  
   and IA.InvoiceID = IDt.InvoiceID        
   and IDt.Product_Code = It.Product_Code        
--   and IsNull(C.Locality, 1) = @TaxTypeID
   and It.CategoryID = #temp4.LeafID  
   and #temp4.LeafID In(Select CatID From #tempCatGroupID)
--   and IA.InvoiceDate between @FromDate and @ToDate        
   and #I.InvoiceId = Ia.InvoiceId
   and TxzType.TaxID = @TaxTypeID 		
   and (        
     (--Trade Invoice----------------        
      (IA.Status & 192) = 0        
      and IA.InvoiceType in (1, 3)        
     )-------------------------------        
     )        
   and IDt.TaxCode2 = convert(decimal(18,6),@Tax)  
   and (
		IsNull(IDt.TaxID, 0) = @TaxCode Or
		( @TaxCode  = -1 and IDt.Taxcode = 0 and IDt.Taxcode2 = 0 ) 
       )				
   and C.CustomerID = IA.CustomerID        
   and #I.[taxtype] = 'CST'
   and (case when IDt.TaxCode2=0  then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc  
   and convert(decimal(18,6),@Tax) = (case when IDt.TaxCode2=0  then 0 else (select Tax.CST_Percentage from tax where Tax_Description = @TaxDesc) end)  
--   and cast(C.Locality as nvarchar) like (case @Locality
--             when 'Local' then '1'
--             when 'Outstation' then '2'
--             else '%' end) + '%'
  group by IDt.TaxID, It.Product_Code, It.ProductName, IDt.TaxCode, IDt.TaxCode2,IA.Status, TxzType.TaxType
  having sum(IDt.Amount)>0        
 union    
--Outstation sales return saleable/Damage
  select Distinct (Case (IA.Status & 32) When 0 then 'OSRS' Else 'OSRD' End),It.Product_Code, It.Product_Code, It.ProductName,IDt.TaxCode2, TxzType.TaxType
  from Items It, InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax  ,#temp4, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
  where         
   IDt.Product_Code In(Select Prod_Code From #tmpProd)  
   and IA.InvoiceID = IDt.InvoiceID        
   and IDt.Product_Code = It.Product_Code 
--   and IsNull(C.Locality, 1) = @TaxTypeID
   and It.CategoryID = #temp4.LeafID  
   and #temp4.LeafID In(Select CatID From #tempCatGroupID)
--   and IA.InvoiceDate between @FromDate and @ToDate        
   and #I.InvoiceId = Ia.InvoiceId
   and TxzType.TaxID = @TaxTypeID 
   and (        
     (--Sales Return-----------------        
	   (IA.Status & 192) = 0  and ((IA.Status & 32) = 0  or (IA.Status & 32) <> 0 )
        and IA.InvoiceType = 4        
     )-------------------------------        
    )        
   and IDt.TaxCode2 = convert(decimal(18,6),@Tax)  
   and (
		IsNull(IDt.TaxID, 0) = @TaxCode Or
		( @TaxCode  = -1 and IDt.Taxcode = 0 and IDt.Taxcode2 = 0 ) 
       )				
   and C.CustomerID = IA.CustomerID        
   and #I.[taxtype] = 'CST'
   and (case when IDt.TaxCode2=0  then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc  
   and convert(decimal(18,6),@Tax) = (case when IDt.TaxCode2=0  then 0 else (select Tax.CST_Percentage from tax where Tax_Description = @TaxDesc) end)  
--   and cast(C.Locality as nvarchar) like (case @Locality
--             when 'Local' then '1'
--             when 'Outstation' then '2'
--             else '%' end) + '%'
  group by IDt.TaxID, It.Product_Code, It.ProductName, IDt.TaxCode, IDt.TaxCode2,IA.Status, TxzType.TaxType
  having sum(IDt.Amount)>0        
Union        
--StockTransferIn
Select Distinct 'TI',It.Product_Code, It.Product_Code, It.ProductName,SD.TaxSuffered, TxzType.TaxType
From StockTransferInAbstract SA,StockTransferInDetail SD,Items It,#temp4, tbl_mERP_TaxType TxzType
Where 
(SA.Status & 192) = 0        
and SA.DocumentDate between @FromDate and @ToDate        
and TxzType.TaxID = IsNull(SA.TaxType,1)
and TxzType.TaxID = @TaxTypeID 
and SA.DocSerial = SD.DocSerial
and SD.Product_Code In(Select Prod_Code From #tmpProd)  
and SD.Product_Code = It.Product_Code        
and It.CategoryID = #temp4.LeafID  
and #temp4.LeafID In(Select CatID From #tempCatGroupID)
and SD.TaxSuffered = convert(decimal(18,6),@Tax)  
and IsNull(SD.TaxCode,0) = (Case When @TaxCode = -1 Then 0 Else @Taxcode End)
--and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1          
and (  
   @Tax =  (Select (Case IsNull(SA.TaxType,1) When 2 Then Tax.CST_Percentage Else Tax.Percentage End) from tax where Tax_Description = @TaxDesc) 
   or (convert(decimal(18,6),@Tax) = convert(decimal(18,6),0) and @TaxDesc = 'Exempt' and SD.TaxSuffered = convert(decimal(18,6),0) )  
  )  
group by SD.TaxCode, It.Product_Code, It.ProductName, SD.TaxSuffered, TxzType.TaxType
Union
--StkTfrOut
Select Distinct 'TO',It.Product_Code, It.Product_Code, It.ProductName,SD.TaxSuffered, TxzType.TaxType
From StockTransferOutAbstract SA,StockTransferOutDetail SD,Items It,#temp4, Batch_Products bp, tbl_mERP_TaxType TxzType, 
    ( select min(tax_code) tax_code, percentage, 1 taxtype, min(Tax_Description) Tax_Description from Tax group by percentage 
        union 
      select min(tax_code) tax_code, cst_percentage percentage, 2 taxtype, min(Tax_Description) Tax_Description from Tax group by cst_percentage ) tax
Where 
(SA.Status & 192) = 0        
and SA.DocumentDate between @FromDate and @ToDate        
and SA.DocSerial = SD.DocSerial
and SD.Product_Code In(Select Prod_Code From #tmpProd)  
and SD.Product_Code = It.Product_Code        
and SD.Batch_Code = bp.Batch_Code 
and IsNull(bp.TaxType, 1) =  @TaxTypeID 
and It.CategoryID = #temp4.LeafID  
and #temp4.LeafID In(Select CatID From #tempCatGroupID)
and SD.TaxSuffered = convert(decimal(18,6),@Tax)  
and TxzType.TaxID = @TaxTypeID 
--and IsNull(SD.TaxCode,0) = @TaxCode
and ( tax.Percentage = SD.Taxsuffered 
		and (Case when (IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3) 
			then 1 Else 2 End ) = tax.taxtype ) 
--and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1         
and (  
   ( @Tax = tax.Percentage and tax.Tax_Description = @TaxDesc and tax.Tax_Code = @TaxCode) 
   or (convert(decimal(18,6),@Tax) = convert(decimal(18,6),0) and @TaxDesc = 'Exempt' and SD.TaxSuffered = convert(decimal(18,6),0) )    
  )  
group by  It.Product_Code, It.ProductName, SD.TaxSuffered, TxzType.TaxType
Union
--Retail Invoice
select Distinct 'RI',It.Product_Code, It.Product_Code, It.ProductName,IDt.TaxCode, TxzType.TaxType
from Items It

inner join InvoiceDetail IDt on  IDt.Product_Code = It.Product_Code  
inner join InvoiceAbstract IA on   IA.InvoiceID = IDt.InvoiceID    
right outer join Customer C  on  C.CustomerID = IA.CustomerID   
inner join #temp4 on  It.CategoryID = #temp4.LeafID  
INNER JOIN tbl_mERP_TaxType TxzType ON  TxzType.TaxID = @TaxTypeID 
INNER JOIN #InvoiceTaxType #I ON  #I.InvoiceId = Ia.InvoiceId
where         
 IDt.Product_Code In(Select Prod_Code From #tmpProd)  
-- and IsNull(C.Locality, 1) = @TaxTypeID
  
 and #temp4.LeafID In(Select CatID From #tempCatGroupID)
-- and IA.InvoiceDate between @FromDate and @ToDate        

 and (IA.Status & 192) = 0        
 and IA.InvoiceType in (2)        
 and IDt.TaxCode = convert(decimal(18,6),@Tax)  
  
 and (
		IsNull(IDt.TaxID, 0) = @TaxCode Or
		( @TaxCode  = -1 and IDt.Taxcode = 0 and IDt.Taxcode2 = 0 ) 
       )				
       
-- and cast(C.Locality as nvarchar) like (case @Locality
--             when 'Local' then '1'
--             when 'Outstation' then '2'
--             else '%' end) + '%'
 and (case when IDt.TaxCode=0  then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc  
 and convert(decimal(18,6),@Tax) = (case when IDt.TaxCode=0  then 0 else (select Tax.Percentage from tax where Tax_Description = @TaxDesc) end)  
group by IDt.TaxID, It.Product_Code, It.ProductName, IDt.TaxCode, TxzType.TaxType
Union
--Retail Invoice Return
select Distinct 'RIR',It.Product_Code, It.Product_Code, It.ProductName,IDt.TaxCode, TxzType.TaxType
from Items It
inner join InvoiceDetail IDt on  IDt.Product_Code = It.Product_Code  
inner join InvoiceAbstract IA on   IA.InvoiceID = IDt.InvoiceID    
right outer join Customer C  on  C.CustomerID = IA.CustomerID   
inner join #temp4 on  It.CategoryID = #temp4.LeafID  
INNER JOIN tbl_mERP_TaxType TxzType ON  TxzType.TaxID = @TaxTypeID 
INNER JOIN #InvoiceTaxType #I ON  #I.InvoiceId = Ia.InvoiceId

where         
 IDt.Product_Code In(Select Prod_Code From #tmpProd)    
-- and IsNull(C.Locality, 1) = @TaxTypeID
 and #temp4.LeafID In(Select CatID From #tempCatGroupID)
-- and IA.InvoiceDate between @FromDate and @ToDate        
 and (IA.Status & 192) = 0        
 and IA.InvoiceType in (5,6)        
 and IDt.TaxCode = convert(decimal(18,6),@Tax)  
 and (
		IsNull(IDt.TaxID, 0) = @TaxCode Or
		( @TaxCode  = -1 and IDt.Taxcode = 0 and IDt.Taxcode2 = 0 ) 
       )				
      
-- and cast(C.Locality as nvarchar) like (case @Locality
--             when 'Local' then '1'
--             when 'Outstation' then '2'
--             else '%' end) + '%'
 and (case when IDt.TaxCode=0 then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc  
 and convert(decimal(18,6),@Tax) = (case when IDt.TaxCode=0  then 0 else (select Tax.Percentage from tax where Tax_Description = @TaxDesc) end)  
group by IDt.TaxID, It.Product_Code, It.ProductName, IDt.TaxCode, TxzType.TaxType
--order by It.ProductName, BD.TaxSuffered        



Create Table #tmpTaxType(
[Type] nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,        
[Item Code] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,        
[Tax %] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS        
)

Insert Into #tmpTaxType([Type],[Item Code],[Tax %])
Select Distinct [Type],[Item Code], [Tax %]  From #tmpVat  

Update #tmpVat Set [Type] = ''


insert into #VATReport(ICode, [Item Code], [Item Name], [Tax %], [Tax Type])        
select Distinct ICode, [Item Code], [Item Name], [Tax %],[Tax Type]  From #tmpVat  

Drop Table #tmpVat




Set @tempSQL = N'Alter Table #VatReport Add[Total Purchase (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Purchase (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 


        
----Total Purchase amount        
Set @tempSQL = N'update #VatReport set [Total Purchase (%c)]  =  (
  Select SUM(BD.Amount)  
  from BillDetail BD, BillAbstract BA, Vendors V, Items, tbl_mERP_TaxType TxzType  
  where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS        
   and Items.Product_Code = BD.Product_Code  
   and BD.BillID = BA.BillID        
   and BA.Status = 0         
   and TxzType.TaxID = IsNull(BA.TaxType,1)
   and TxzType.TaxID = ' + Cast(@TaxTypeID As nVarchar) + '  
   and TxzType.TaxType = [Tax Type] 
   and BA.BillDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
  + N' and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)  
   and (   
   BD.TaxSuffered = (select Case IsNull(BA.TaxType,1) When 2 Then Tax.CST_Percentage Else Tax.Percentage End from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' 
   + N' ) 
   or (BD.TaxSuffered = 0 )  
  )  
   and (Case When BD.TaxSuffered = 0 Then 0 Else BD.TaxCode End) = (Case When  ' + Cast(@TaxCode as nVarchar) + N' = -1 Then 0 Else ' +  Cast(@TaxCode as nVarchar)
   + N' End) 
    and (case when BD.TaxSuffered=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' 
   + N' else (select Tax.Tax_Description from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' +N' ) end) =' 
	+ '''' + Cast(@TaxDesc as nVarchar(255)) + '''' +N'  
   and V.VendorID = BA.VendorID   ' +      
--   and V.Locality like (        
--         case ' + '''' + Cast(@Locality  as nVarchar) + '''' + N'       
--         when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''       
--         + N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then' + '''' + Cast('2' as nVarchar) + ''''        
--         + N' else ' + '''' + Cast('%' as nVarchar) + '''' + N' end        
--        )
 ')'+ ''        


Exec sp_ExecuteSQL @tempSQL


        
------Tax amount on Purchase        
Set @tempSQL = N'update #VATReport set [Tax on Purchase (%c)] =  (        
  select SUM(BD.TaxAmount)  
  from BillDetail BD, BillAbstract BA, Vendors V, Tax, Items, tbl_mERP_TaxType TxzType    
  where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and Items.Product_Code = BD.Product_Code  
   and BD.BillID = BA.BillID        
   and BA.Status = 0         
   and TxzType.TaxID = IsNull(BA.TaxType,1)
   and TxzType.TaxID = ' + Cast(@TaxTypeID As nVarchar) + '  
   and TxzType.TaxType = [Tax Type] 
   and BA.BillDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
  + N' and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)   
   and BD.TaxSuffered = (case IsNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end)  
   and Tax.Tax_Description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + ''''   
   + N' and IsNull(BD.TaxCode, 0) =' + Cast(@TaxCode as nVarchar) + N' 
   and V.VendorID = BA.VendorID ' +        
--   and V.Locality like (        
--         case ' + '''' + Cast(@Locality  as nVarchar) + '''' + N'       
--         when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''       
--         + N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then' + '''' + Cast('2' as nVarchar) + ''''        
--         + N' else ' + '''' + Cast('%' as nVarchar) + '''' + N' end        
--        )
 ' )' + ''        

Exec sp_ExecuteSQL @tempSQL



If @TaxSplitUp = 'Yes'
Begin
	If Exists(Select * From #tmpTaxType Where Type = N'LB' )--and isNull([Tax %],'') <> ''  and isNull([Tax %],'') <> N'Exempt' )  
	Begin
	--Local Purchase Value and its splitup
		Set @tempSQL = N'Alter Table #VatReport Add[VAT Total Purchase (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
		Set @tempSQL = N'Alter Table #VatReport Add[VAT Tax on Purchase (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
		
		----Total Purchase amount        
		Set @tempSQL = N'update #VATReport set [VAT Total Purchase (%c)]  =  (        
	  	select SUM(BD.Amount)  
	    from BillDetail BD, BillAbstract BA, Vendors V, Items, tbl_mERP_TaxType TxzType  
	    where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS        
	    and Items.Product_Code = BD.Product_Code  
	    and BD.BillID = BA.BillID        
	    and BA.Status = 0         
        and TxzType.TaxID = IsNull(BA.TaxType,1)
        and TxzType.TaxID = ' + Cast(@TaxTypeID As nVarchar) + '  
        and TxzType.TaxType = [Tax Type] 
	    and BA.BillDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
	   + N' and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)  
	   and (   
	   BD.TaxSuffered = (select Case IsNull(BA.TaxType,1) When 2 Then Tax.CST_Percentage Else Tax.Percentage End from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' 
	   + N' ) 
	   or (BD.TaxSuffered = 0 )  
	   )  
	   and (Case When BD.TaxSuffered = 0 Then 0 Else BD.TaxCode End) = (Case When ' + Cast(@TaxCode as nVarchar) + N' = -1 Then 0 Else '
	   + Cast(@TaxCode as nVarchar) + N' End ) 
	    and (case when BD.TaxSuffered=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' 
	   + N' else (select Tax.Tax_Description from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' +N' ) end) =' 
		+ '''' + Cast(@TaxDesc as nVarchar(255)) + '''' +N'  
	   and V.VendorID = BA.VendorID ' +        
--       and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--            when 'Outstation' then '2'
--            else '%'
--           end )
         ' )'
	
	   Exec sp_ExecuteSQL @tempSQL
	
	
	        
		------Tax amount on Purchase        
		Set @tempSQL = N'update #VATReport set [VAT Tax on Purchase (%c)] =  (        
	    select SUM(BD.TaxAmount)  
	    from BillDetail BD, BillAbstract BA, Vendors V, Tax, Items, tbl_mERP_TaxType TxzType  
	    where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
	    and Items.Product_Code = BD.Product_Code  
	    and BD.BillID = BA.BillID        
	    and BA.Status = 0         
        and TxzType.TaxID = IsNull(BA.TaxType,1)
        and TxzType.TaxID = ' + Cast(@TaxTypeID As nVarchar) + '  
        and TxzType.TaxType = [Tax Type] 
	    and BA.BillDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
	    + N' and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)   
	    and BD.TaxSuffered = (case IsNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end)  
	    and Tax.Tax_Description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + ''''   
	    + N' and IsNull(BD.TaxCode, 0) =' + Cast(@TaxCode as nVarchar) + N' 
	    and V.VendorID = BA.VendorID ' + 
--        and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--            when 'Outstation' then '2'
--            else '%'
--           end )
         ')'
	
	    Exec sp_ExecuteSQL @tempSQL
		
		if @TaxTypeID = 1 or @TaxTypeID = 3 
		Begin
			if Exists(Select * From #tmpTaxType Where [Type] = N'LB' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
			Begin
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Delete From #tmpTaxComp1
				Insert Into #tmpTaxComp1
				Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 1
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
				While @TC <> 0
				Begin
					Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
					Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_Purchase] Decimal(18,6) '
					Exec sp_executesql @TempSql 
					Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_Purchase] Decimal(18,6) '
					Exec sp_executesql @TempSql 
					Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
					Set @TC = 0
					Set @TCC = 0
					Set @TaxCompHead = ''
					Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
				End
			End
		End
	End	
----Outstation Purchase Value and splitup
	If Exists(Select * From #tmpTaxType Where Type = N'OB')-- and isNull([Tax %],'') <> ''  and isNull([Tax %],'') <> N'Exempt')  
	Begin
		Set @tempSQL = N'Alter Table #VatReport Add[CST Total Purchase (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
		Set @tempSQL = N'Alter Table #VatReport Add[CST Tax on Purchase (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
		
		----Total Purchase amount        
		Set @tempSQL = N'update #VATReport set [CST Total Purchase (%c)]  = (        
	  	select SUM(BD.Amount)  
	    from BillDetail BD, BillAbstract BA, Vendors V, Items, tbl_mERP_TaxType TxzType  
	    where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS        
	    and Items.Product_Code = BD.Product_Code  
	    and BD.BillID = BA.BillID        
	    and BA.Status = 0         
        and TxzType.TaxID = IsNull(BA.TaxType,1)
		and TxzType.TaxID = ' + Cast(@TaxTypeID As nVarchar) + '  
        and TxzType.TaxType = [Tax Type] 
	    and BA.BillDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
	   + N' and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)  
	   and (   
	   BD.TaxSuffered = (select Case IsNull(BA.TaxType,1) When 2 then Tax.CST_Percentage Else Tax.Percentage End from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' 
	   + N' ) 
	   or (BD.TaxSuffered = 0 )  
	   )  
	   and (Case When BD.TaxSuffered = 0 Then 0 Else BD.TaxCode End) = (Case When ' + Cast(@TaxCode as nVarchar) + N' = -1 Then 0 Else ' + Cast(@TaxCode as nVarchar) 
	   + N' End) and (case when BD.TaxSuffered=0 then ' + '''' + Cast('Exempt' as nVarchar) + '''' 
	   + N' else (select Tax.Tax_Description from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' +N' ) end) =' 
		+ '''' + Cast(@TaxDesc as nVarchar(255)) + '''' +N'  
	   and V.VendorID = BA.VendorID '         
--       and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--            when 'Outstation' then '2'
--            else '%'
--           end )
        + ' )'
	
	   Exec sp_ExecuteSQL @tempSQL

	
	        
		------Tax amount on Purchase        
		Set @tempSQL = N'update #VATReport set [CST Tax on Purchase (%c)] =  (        
	    select SUM(BD.TaxAmount)  
	    from BillDetail BD, BillAbstract BA, Vendors V, Tax, Items, tbl_mERP_TaxType TxzType  
	    where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
	    and Items.Product_Code = BD.Product_Code  
	    and BD.BillID = BA.BillID        
	    and BA.Status = 0      
        and TxzType.TaxID = IsNull(BA.TaxType,1)
		and TxzType.TaxID = ' + Cast(@TaxTypeID As nVarchar) + '  
        and TxzType.TaxType = [Tax Type]    
	    and BA.BillDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
	    + N' and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)   
	    and BD.TaxSuffered = (case IsNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end)  
	    and Tax.Tax_Description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + ''''   
	    + N' and IsNull(BD.TaxCode, 0) =' + Cast(@TaxCode as nVarchar) + N' 
	    and V.VendorID = BA.VendorID ' 
--        and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--            when 'Outstation' then '2'
--            else '%'
--           end )
        + ')'
		
	    Exec sp_ExecuteSQL @tempSQL
		
		if @TaxTypeID = 2
		Begin
			if Exists(Select * From #tmpTaxType Where [Type] = N'OB' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
			Begin
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Delete From #tmpTaxComp1
				Insert Into #tmpTaxComp1
				Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 0
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
				While @TC <> 0
				Begin
					Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
					Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_Purchase] Decimal(18,6) '
					Exec sp_executesql @TempSql 
					Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_Purchase] Decimal(18,6) '
					Exec sp_executesql @TempSql 
					Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
					Set @TC = 0
					Set @TCC = 0
					Set @TaxCompHead = ''
					Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
				End
			End
		End
	End
End


 

--Total Purchase Return amount                  
Set @tempSQL = N'Alter Table #VatReport Add[Total Purchase Return (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Purchase Return (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 


--Total Purchase Return amount        
Set @tempSQL = N' update #VATReport set [Total Purchase Return (%c)] = (        
select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items, Batch_Products bp  
where ARA.AdjustmentID = ARD.AdjustmentID        
   and Items.Product_Code = ARD.Product_Code  
   and ARD.BatchCode = bp.Batch_Code 
   and IsNull(bp.TaxType, 1) =  ' + Cast(@TaxTypeID As nVarchar) + '  
   and (isnull(ARA.Status,0) & 128) = 0        
   and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and ARA.AdjustmentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
   + N' and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)   
   and V.VendorID = ARA.VendorID        
   and (  
   ARD.Tax = (case when ' + convert(varchar, @TaxTypeID) + ' = 1 or ' + convert(varchar, @TaxTypeID) + ' = 3 then (select Tax.Percentage from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' 
   + N' ) else (select Tax.CST_Percentage from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)  
   or (ARD.Tax=0 )  
  )  
   and (case when ARD.Tax=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' 
  + N' else (select Tax.Tax_Description from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)= ' 
  + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' +  
--   and V.Locality like (        
--         case ' + '''' + Cast(@Locality  as nVarchar) + '''' + N'       
--         when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''       
--         + N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then' + '''' + Cast('2' as nVarchar) + ''''        
--         + N' else ' + '''' + Cast('%' as nVarchar) + '''' + N' end        
--        )        
 ' )' + ''        

Exec sp_ExecuteSQL @tempSQL


----Tax amount on Purchase Return    
Set @tempSQL = N'update #VATReport set [Tax on Purchase Return (%c)] = (        
  select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
  from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Tax, Items  , Batch_Products bp  
  where ARA.AdjustmentID = ARD.AdjustmentID        
   and Items.Product_Code = ARD.Product_Code  
   and ARD.BatchCode = bp.Batch_Code 
   and IsNull(bp.TaxType, 1) =  ' + Cast(@TaxTypeID As nVarchar) + '  
   and (isnull(ARA.Status,0) & 128) = 0        
   and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and ARA.AdjustmentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
   + N' and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)    
   and ARD.Tax = (case when ' + convert(varchar, @TaxTypeID) + ' = 1 or ' + convert(varchar, @TaxTypeID) + ' = 3 then Tax.Percentage else Tax.CST_Percentage end)  
   and Tax.Tax_Description = '+ '''' + Cast(@TaxDesc as nVarchar(255)) + ''''  
   + N' and ARA.VendorID = V.VendorID ' + 
--   and cast(V.Locality as nvarchar) like ( 
--         case ' + '''' + Cast(@Locality  as nVarchar) + '''' + N'       
--         when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''       
--         + N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then' + '''' + Cast('2' as nVarchar) + ''''        
--         + N' else ' + '''' + Cast('%' as nVarchar) + '''' + N' end        
--        )        
' )' + ''        

Exec sp_ExecuteSQL @tempSQL



IF @TaxSplitUp = 'Yes'
Begin
	if Exists(Select * From #tmpTaxType Where Type = N'LBR')-- and isNull([Tax %],'') <> ''  and isNull([Tax %],'') <> N'Exempt')  
	Begin
		--Local Purchase Return and TaxSplitUp
		Set @tempSQL = N'Alter Table #VatReport Add[VAT Total Purchase Return (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
		Set @tempSQL = N'Alter Table #VatReport Add[VAT Tax on Purchase Return (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
	
	
		--Local Purchase Return amount        
		Set @tempSQL = N' update #VATReport set [VAT Total Purchase Return (%c)] = (        
		select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
		from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items  , Batch_Products bp  
		where ARA.AdjustmentID = ARD.AdjustmentID        
	    and Items.Product_Code = ARD.Product_Code  
        and ARD.BatchCode = bp.Batch_Code 
        and IsNull(bp.TaxType, 1) =  ' + Cast(@TaxTypeID As nVarchar) + '  
		and (isnull(ARA.Status,0) & 128) = 0        
		and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
		and ARA.AdjustmentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
		+ N' and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)   
		and V.VendorID = ARA.VendorID        
		and (  
		ARD.Tax = (case when ' + convert(varchar, @TaxTypeID) + ' = 1 or ' + convert(varchar, @TaxTypeID) + ' = 3 then (select Tax.Percentage from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' 
		+ N' ) else (select Tax.CST_Percentage from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)  
		or (ARD.Tax=0 )  
		)  
		and (case when ARD.Tax=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' 
		+ N' else (select Tax.Tax_Description from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)= ' 
		+ '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + 
--        and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--            when 'Outstation' then '2'
--            else '%'
--           end )
         ')'
	
		Exec sp_ExecuteSQL @tempSQL
	
	
		----Local Tax amount on Purchase Return    
		Set @tempSQL = N'update #VATReport set [VAT Tax on Purchase Return (%c)] = (        
	  	select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
		from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Tax, Items  , Batch_Products bp  
	    where ARA.AdjustmentID = ARD.AdjustmentID        
	    and Items.Product_Code = ARD.Product_Code  
        and ARD.BatchCode = bp.Batch_Code 
        and IsNull(bp.TaxType, 1) =  ' + Cast(@TaxTypeID As nVarchar) + '  
	    and (isnull(ARA.Status,0) & 128) = 0        
	    and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
	    and ARA.AdjustmentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
	    + N' and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)    
	    and ARD.Tax = (case when ' + convert(varchar, @TaxTypeID) + ' = 1 or ' + convert(varchar, @TaxTypeID) + ' = 3 then Tax.Percentage else Tax.CST_Percentage end)  
	    and Tax.Tax_Description = '+ '''' + Cast(@TaxDesc as nVarchar(255)) + ''''  
	    + N' and ARA.VendorID = V.VendorID ' 
--        and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--            when 'Outstation' then '2'
--            else '%'
--           end )
        + ')'
	
		Exec sp_ExecuteSQL @tempSQL
	
		--Local Purchase Return TaxComponent SplitUp
		if @TaxTypeID = 1 or @TaxTypeID = 3 
		Begin
			if Exists(Select * From #tmpTaxType Where [Type] = N'LBR' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
			Begin
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Delete From #tmpTaxComp1
				Insert Into #tmpTaxComp1
				Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 1
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
				While @TC <> 0
				Begin
					Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
					Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_PR] Decimal(18,6)'
					Exec sp_executesql @TempSql 
					Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_PR] Decimal(18,6) '
					Exec sp_executesql @TempSql 
					Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
					Set @TC = 0
					Set @TCC = 0
					Set @TaxCompHead = ''
					Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
				End
			End
		End
	End	

	if Exists(Select * From #tmpTaxType Where Type = N'OBR')-- and isNull([Tax %],'') <> ''  and isNull([Tax %],'') <> N'Exempt')  
	Begin
		--Outstation Purchase Return and TaxSplitUp
		Set @tempSQL = N'Alter Table #VatReport Add[CST Total Purchase Return (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
		Set @tempSQL = N'Alter Table #VatReport Add[CST Tax on Purchase Return (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
	
	
		--Local Purchase Return amount        
		Set @tempSQL = N' update #VATReport set [CST Total Purchase Return (%c)] = (        
		select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
		from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items  , Batch_Products bp  
		where ARA.AdjustmentID = ARD.AdjustmentID        
	    and Items.Product_Code = ARD.Product_Code  
		and ARD.BatchCode = bp.Batch_Code 
		and IsNull(bp.TaxType, 1) =  ' + Cast(@TaxTypeID As nVarchar) + '  
		and (isnull(ARA.Status,0) & 128) = 0        
		and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
		and ARA.AdjustmentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
		+ N' and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)   
		and V.VendorID = ARA.VendorID        
		and (  
		ARD.Tax = (case when ' + convert(varchar, @TaxTypeID) + ' = 1 or ' + convert(varchar, @TaxTypeID) + ' = 3 then (select Tax.Percentage from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' 
		+ N' ) else (select Tax.CST_Percentage from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)  
		or (ARD.Tax=0 )  
		)  
		and (case when ARD.Tax=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' 
		+ N' else (select Tax.Tax_Description from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)= ' 
		+ '''' + Cast(@TaxDesc as nVarchar(255)) + '''' 
--        and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--            when 'Outstation' then '2'
--            else '%'
--           end )
        + ' )'
	
		Exec sp_ExecuteSQL @tempSQL
	
	
		----Outstation Tax amount on Purchase Return    
		Set @tempSQL = N'update #VATReport set [CST Tax on Purchase Return (%c)] = (        
	  	select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
		from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Tax, Items  , Batch_Products bp  
	    where ARA.AdjustmentID = ARD.AdjustmentID        
	    and Items.Product_Code = ARD.Product_Code  
        and ARD.BatchCode = bp.Batch_Code 
        and IsNull(bp.TaxType, 1) =  ' + Cast(@TaxTypeID As nVarchar) + '  
	    and (isnull(ARA.Status,0) & 128) = 0        
	    and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
	    and ARA.AdjustmentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
	    + N' and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)    
	    and ARD.Tax = (case when ' + convert(varchar, @TaxTypeID) + ' = 1 or ' + convert(varchar, @TaxTypeID) + ' = 3 then Tax.Percentage else Tax.CST_Percentage end)  
	    and Tax.Tax_Description = '+ '''' + Cast(@TaxDesc as nVarchar(255)) + ''''  
	    + N' and ARA.VendorID = V.VendorID '        
--        and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--            when 'Outstation' then '2'
--            else '%'
--           end )
        + ')'
	
		Exec sp_ExecuteSQL @tempSQL
	
		if @TaxTypeID = 2
		Begin
			if Exists(Select * From #tmpTaxType Where [Type] = N'OBR' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
			Begin
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Delete From #tmpTaxComp1
				Insert Into #tmpTaxComp1
				Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 0
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
				While @TC <> 0
				Begin
					Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
					Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_PR] Decimal(18,6) '
					Exec sp_executesql @TempSql 
					Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_PR] Decimal(18,6) '
					Exec sp_executesql @TempSql 
					Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
					Set @TC = 0
					Set @TCC = 0
					Set @TaxCompHead = ''
					Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
				End
			End
		End
	End
End

--  update #VATReport set [Net Purchase (%c)] = isnull([Total Purchase (%c)],0) - isnull([Total Purchase Return (%c)],0)        
--  update #VATReport set [Net Purchase Tax (%c)] = isnull([Tax on Purchase (%c)],0) - isnull([Tax on Purchase Return (%c)],0)        


Set @tempSQL = N'Alter Table #VatReport Add[Net Purchase (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Net Purchase Tax (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 

Set @tempSQL = N' update #VATReport set [Net Purchase (%c)] = isnull([Total Purchase (%c)],0) - isnull([Total Purchase Return (%c)],0) ' + ''                  
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N' update #VATReport set [Net Purchase Tax (%c)] = isnull([Tax on Purchase (%c)],0) - isnull([Tax on Purchase Return (%c)],0) ' + ''                 
Exec sp_ExecuteSQL @tempSQL                 


--Sales
Set @tempSQL = N'Alter Table #VatReport Add[Total Sales (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Sales (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL


-----Total sales amount
Set @tempSQL = N'update #VATReport set [Total Sales (%c)] = (        
  select sum(IDt.Amount) - sum(case #I.[taxtype] 
  when ' + '''' + Cast('LST' as nVarchar) + '''' + N' then isnull(IDt.STPayable,0)        
  when ' + '''' + Cast('CST' as nVarchar) + '''' + N' then isnull(IDT.CSTPayable,0)        
  else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)  
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
  where Idt.InvoiceID = IA.InvoiceID        
  and It.Product_Code = IDt.Product_Code ' +  
--  ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) + 
  ' and #I.InvoiceId = Ia.InvoiceId
  and (IA.Status & 192) = 0        
  and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
  and IA.InvoiceType in (1, 3)        
  and IDt.SalePrice <> 0        
  and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
--  ' and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''
   N' and ((( #I.[taxtype] = ''LST'' or #I.[taxtype] = ''FLST'') and IDt.TaxCode = (case ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' when ' + '''' 
  + Cast('Exempt' as nVarchar) + '''' + N' then 0 else (select Percentage from Tax where Tax_Description= ' + '''' +
  Cast(@TaxDesc as nVarchar(255)) + '''' + N') end))  or  
  (#I.[taxtype] = ''CST'' and IDt.TaxCode2 = (case ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' when ' + '''' 
  + Cast('Exempt' as nVarchar) + '''' + N' then 0 else (select CST_Percentage from Tax where Tax_Description = ' + '''' +
  + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)))  
  and' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N'= (case ' + '''' + Cast(@TaxDesc as nVarchar(255)) +'''' + N' when '
  + '''' + Cast('Exempt' as nVarchar) + '''' + N' then ' + '''' + Cast('Exempt' as nVarchar) + '''' 
  + N' else (select Tax_Description from Tax where Tax_Description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)  
   and (IsNull(IDt.TaxID, 0) = 
		(Case When ' + Cast(@TaxCode  as nVarchar)+ N' = -1 Then 0 Else ' + Cast(@TaxCode  as nVarchar) +N' End)
		Or( ' + Cast(@TaxCode  as nVarchar) + N' = -1 and IDT.Taxcode = 0 and Idt.TaxCode2 = 0 ) )
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case when ( #I.[taxtype] = ''LST'' or #I.[taxtype] = ''FLST'') then IDt.TaxCode else IDt.TaxCode2 end)
--   and IsNull([Tax Type],'''') = TxzType.TaxType 
   and IA.CustomerID = C.CustomerID ' + 
--   and cast(C.Locality as nvarchar) like (
--         case ' + '''' + Cast(@Locality  as nVarchar) + '''' + N'       
--         when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''       
--         + N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then' + '''' + Cast('2' as nVarchar) + ''''        
--         + N' else ' + '''' + Cast('%' as nVarchar) + '''' + N' end        
--        )        
 ' )' + ''        

Exec sp_ExecuteSQL @tempSQL

        
----Tax on sales        
Set @tempSQL = N' update #VATReport set [Tax on Sales (%c)] = (        
  select sum(case #I.[taxtype] '         
   + N' when ' + '''' + Cast('LST' as nVarchar) + '''' + N' then isnull(IDt.STPayable,0)        
     when ' + '''' + Cast('CST' as nVarchar) + '''' + N' then isnull(IDT.CSTPayable,0)        
     else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)         
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, Items It, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
  where Idt.InvoiceID = IA.InvoiceID        
   and It.Product_Code = IDt.Product_Code ' +
--   and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) + 
   ' and #I.InvoiceId = Ia.InvoiceId
   and (IA.Status & 192) = 0        
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and IA.InvoiceType in (1, 3)        
   and IDt.SalePrice <> 0        
   and TxzType.TaxID = ' + convert( varchar, @TaxTypeID ) + 
   -- ' and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
   N'and ((( #I.[taxtype] = ''LST'' or #I.[taxtype] = ''FLST'') and IDt.TaxCode = Tax.Percentage)  or  
  (#I.[taxtype] = ''CST'' and IDt.TaxCode2 = CST_Percentage ))  
   and ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' = Tax_Description  
   and IsNull(IDt.TaxID, 0)  = ' + Cast(@TaxCode  as nVarchar) + N'
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS ) = (Case when ( #I.[taxtype] = ''LST'' or #I.[taxtype] = ''FLST'') then IDt.TaxCode else IDt.TaxCode2 end)   
   and IsNull([Tax Type], '''') = TxzType.TaxType 
   and IA.CustomerID = C.CustomerID  ' + 
--   and cast(C.Locality as nvarchar) like (
--         case ' + '''' + Cast(@Locality  as nVarchar) + '''' + N'       
--         when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''       
--         + N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then' + '''' + Cast('2' as nVarchar) + ''''        
--         + N' else ' + '''' + Cast('%' as nVarchar) + '''' + N' end        
--        )        
 ' )' + ''        

Exec sp_ExecuteSQL @tempSQL


If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3 
	Begin
		if Exists(Select * From #tmpTaxType Where [Type] = N'LI' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
		Begin
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Delete From #tmpTaxComp1
			Insert Into #tmpTaxComp1
			Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 1
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_Sales] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_Sales] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			End
		End
	End
	if @TaxTypeID = 2
	Begin
		if Exists(Select * From #tmpTaxType Where [Type] = N'OI' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
		Begin
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Delete From #tmpTaxComp1
			Insert Into #tmpTaxComp1
			Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 0
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_Sales] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_Sales] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			End
		End
	End
End




--Adds Retail Sales Column]
Set @tempSQL = N'Alter Table #VatReport Add[Total Retail Sales (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Retail Sales (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 

---- Update Total Retail Sales         
Set @tempSQL = N' update #VATReport set  [Total Retail Sales (%c)] = (        
 select sum(isnull(IDt.Amount,0)) - sum(isnull(IDt.STPayable,0))  
 from InvoiceAbstract IA
 inner join InvoiceDetail IDt on  Idt.InvoiceID = IA.InvoiceID
 left outer join Customer C on  IA.CustomerID = C.CustomerID
 inner join Items It on  It.Product_Code = IDt.Product_Code
inner join tbl_mERP_TaxType TxzType ON  TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) +  '
inner join #InvoiceTaxType #I on  #I.InvoiceId = Ia.InvoiceId 
 where        
   ' +  
-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +   
'  
   (IA.Status & 192) = 0        
 and IA.InvoiceType in (2)        
 and IDt.SalePrice <> 0        
 and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
 and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = IDt.TaxCode          
   ' +
-- '  and (Case ' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) + ''''
-- + N' Then 0 Else 1 End) = 1  
' and IDt.TaxCode = (case when IDt.TaxCode=0  then 0 else (select Percentage from Tax where Tax_Description = ' 
 + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)  
 and ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' = (case when IDt.TaxCode=0 then ' + ''''
 + Cast('Exempt' as nVarchar) + '''' + N'else (select Tax_Description from Tax where Tax_Description = ' + '''' + 
 Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)  
 and IsNull(IDt.TaxID, 0) = ' + Cast(@TaxCode as nVarchar) + N'
 and IDt.Amount>-1  
)' + ''        

Exec sp_ExecuteSQL @tempSQL


---- Update Tax Retail Sales         
Set @tempSQL = N' update #VATReport set [Tax on Retail Sales (%c)] = (        
 select sum(isnull(IDt.STPayable,0))  
 from InvoiceAbstract IA
 inner join InvoiceDetail IDt on Idt.InvoiceID = IA.InvoiceID  
 left outer join Customer C on  IA.CustomerID = C.CustomerID
 inner join  Tax on  IDt.TaxCode = Tax.Percentage  
 inner join tbl_mERP_TaxType TxzType on  TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + '
inner join #InvoiceTaxType #I on  #I.InvoiceId = Ia.InvoiceId
 where       
   (IA.Status & 192) = 0 ' + 
-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) + 
'  
 and IA.InvoiceType in (2)        
 and IDt.SalePrice <> 0        
  and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
 + N' and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
 and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = IDt.TaxCode          
   ' +
 -- ' and (Case ' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) 
-- + '''' + N' Then 0 Else 1 End) = 1 ' 
'   
 and IsNull(IDt.TaxID, 0) = ' + Cast(@TaxCode  as nVarchar) +
 N' and ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' = Tax.Tax_Description   
 and IDt.Amount>-1  
) ' + ''
        

Exec sp_ExecuteSQL @tempSQL


If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3 
	Begin
		if Exists(Select * From #tmpTaxType Where [Type] = N'RI' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
		Begin
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Delete From #tmpTaxComp1
			Insert Into #tmpTaxComp1
			Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 1
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_RI] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_RI] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			End
		End
	End
End


Set @tempSQL = N'Alter Table #VatReport Add[Sales Return Saleable (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Sales Return Saleable (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 


----Total Sales return saleable amount        
Set @tempSQL = N' update #VATReport set [Sales Return Saleable (%c)] = (        
select sum(IDt.Amount) - sum(case #I.[taxtype] 
when ' + '''' + Cast('LST' as nVarchar) + '''' + N' then isnull(IDt.STPayable,0)        
when ' + '''' + Cast('CST' as nVarchar) + '''' + N' then isnull(IDT.CSTPayable,0)        
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
where Idt.InvoiceID = IA.InvoiceID        
and It.Product_Code = IDt.Product_Code ' + 
--' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +   
' and #I.InvoiceId = Ia.InvoiceId 
and (IA.Status & 192) = 0         
and (IA.Status & 32) = 0  
and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
and IA.InvoiceType = 4         
and IDt.SalePrice <> 0        
and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
-- ' and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''
 N' and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case when ( #I.[taxtype] = ''LST'' or #I.[taxtype] = ''FLST'') then IDt.TaxCode else IDt.TaxCode2 end)   
and IA.CustomerID = C.CustomerID        
and ((( #I.[taxtype] = ''LST'' or #I.[taxtype] = ''FLST'') and IDt.TaxCode = (case when  IDt.TaxCode=0 then 0 else (select Percentage from Tax where Tax_Description = ' + '''' + 
Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)) or   
(#I.[taxtype] = ''CST'' and IDt.TaxCode2 = (case when  IDt.TaxCode2=0 then 0 else (select CST_Percentage from 
Tax where Tax_Description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N')end)))  
and ' + '''' +  Cast(@TaxDesc as nVarchar(255)) + '''' + N' = (case ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' 
+ N' when ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' then ' + '''' + Cast('Exempt' as nVarchar) + '''' 
+ N' else (select Tax_Description from Tax where Tax_Description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)  
and ( IsNull(IDt.TaxID, 0) = (Case When ' + Cast(@TaxCode as nVarchar) + N' = -1 Then 0 Else ' + Cast(@TaxCode as nVarchar) + N' End)
Or ( ' + Cast(@TaxCode as nVarchar) + N' = -1 and IDt.Taxcode = 0 and Idt.Taxcode2 = 0)) ' + 
--and cast(C.Locality as nvarchar) like (
--         case ' + '''' + Cast(@Locality  as nVarchar) + '''' + N'       
--         when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''       
--         + N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + '''' + Cast('2' as nVarchar) + ''''        
--         + N' else ' + '''' + Cast('%' as nVarchar) + '''' + N' end        
--     )        
 ' )' + ''        
        

Exec sp_ExecuteSQL @tempSQL


 --tax amount on sales return saleable        
Set @tempSQL = N' update #VATReport set [Tax on Sales Return Saleable (%c)] = (        
select sum(case #I.[taxtype] '        
+ N' when ' + '''' + Cast('LST' as nVarchar) + '''' + N' then isnull(IDt.STPayable,0)        
when ' + '''' + Cast('CST' as nVarchar) + '''' + N' then isnull(IDT.CSTPayable,0)        
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)         
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, Items It, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
where Idt.InvoiceID = IA.InvoiceID        
and It.Product_Code = IDt.Product_Code ' +  
--' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +   
' and #I.InvoiceId = Ia.InvoiceId
and (IA.Status & 192) = 0         
and (IA.Status & 32) = 0  
and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
and IA.InvoiceType = 4         
and IDt.SalePrice <> 0        
and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
-- ' and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''
 N' and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case when ( #I.[taxtype] = ''LST'' or #I.[taxtype] = ''FLST'') then IDt.TaxCode else IDt.TaxCode2 end)    
and IA.CustomerID = C.CustomerID        
and ((( #I.[taxtype] = ''LST'' or #I.[taxtype] = ''FLST'') and IDt.TaxCode = Percentage)  or  
(#I.[taxtype] = ''CST'' and IDt.TaxCode2 = CST_Percentage))  
and ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' = Tax_Description   
and IsNull(IDt.TaxID, 0) = ' + Cast(@TaxCode  as nVarchar) + 
--' and cast(C.Locality as nvarchar) like (
--         case ' + '''' + Cast(@Locality  as nVarchar) + '''' + N'       
--         when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''       
--         + N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + '''' + Cast('2' as nVarchar) + ''''        
--         + N' else ' + '''' + Cast('%' as nVarchar) + '''' + N' end        
--        )
 ' )' + ''        


Exec sp_ExecuteSQL @tempSQL

If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3 
	Begin
		if Exists(Select * From #tmpTaxType Where [Type] = N'LSRS' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
		Begin
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Delete From #tmpTaxComp1
			Insert Into #tmpTaxComp1
			Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 1
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_SRS] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_SRS] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			End
		End
	End
	if @TaxTypeID = 2
	Begin
		if Exists(Select * From #tmpTaxType Where [Type] = N'OSRS' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
		Begin
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Delete From #tmpTaxComp1
			Insert Into #tmpTaxComp1
			Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 0
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_SRS] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_SRS] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			End
		End
	End
End


----total Sales Return Damages        
Set @tempSQL = N'Alter Table #VatReport Add[Sales Return Damages (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Sales Return Damages (%c)] Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 


Set @tempSQL = N' update #VATReport set [Sales Return Damages (%c)] = (        
select sum(IDt.Amount) - sum(case #I.[taxtype] ' + 
N' when ' + '''' + Cast('LST' as nVarchar) + '''' + N' then isnull(IDt.STPayable,0)        
when ' + '''' + Cast('CST' as nVarchar) + '''' + N' then isnull(IDT.CSTPayable,0)        
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
where Idt.InvoiceID = IA.InvoiceID        
and It.Product_Code = IDt.Product_Code ' +  
-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) + 
' and #I.InvoiceId = Ia.InvoiceId 
and (IA.Status & 192) = 0  
and (IA.Status & 32) <> 0         
and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
and IA.InvoiceType = 4         
and IDt.SalePrice <> 0        
and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
-- ' and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''
 N' and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case when ( #I.[taxtype] = ''LST'' or #I.[taxtype] = ''FLST'') then IDt.TaxCode else IDt.TaxCode2 end)    
and IA.CustomerID = C.CustomerID        
and ((( #I.[taxtype] = ''LST'' or #I.[taxtype] = ''FLST'') and IDt.TaxCode = (case when IDt.TaxCode=0 then 0 else (select Percentage from Tax where Tax_Description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)) or   
(#I.[taxtype] = ''CST'' and IDt.TaxCode2 = (case when  IDt.TaxCode2=0 then 0 else (select CST_Percentage from Tax where Tax_Description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)))  
and ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' = (case ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' when ' + '''' + Cast('Exempt' as nVarchar) + '''' + 
+ N' then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else (select Tax_Description from Tax where Tax_Description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)  
and (IsNull(IDt.TaxID, 0) = 
		(Case When ' + Cast(@TaxCode  as nVarchar)+ N' = -1 Then 0 Else ' + Cast(@TaxCode  as nVarchar) +N' End)
		Or( ' + Cast(@TaxCode  as nVarchar) + N' = -1 and IDT.Taxcode = 0 and Idt.TaxCode2 = 0 ) )' + 
--and cast(C.Locality as nvarchar) like (
--case ' + '''' + Cast(@Locality  as nVarchar) + '''' + N'       
--when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''       
--+ N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + '''' + Cast('2' as nVarchar) + ''''        
--+ N' else ' + '''' + Cast('%' as nVarchar) + '''' + N' end        
-- )        
 ' )' + ''        

Exec sp_ExecuteSQL @tempSQL


 --Tax amount on sales return damages        
Set @tempSQL = N'update #VATReport set [Tax on Sales Return Damages (%c)] = (        
select sum(case #I.[taxtype] ' 
+ N' when ' + '''' + Cast('LST' as nVarchar) + '''' + N' then isnull(IDt.STPayable,0)        
when ' + '''' + Cast('CST' as nVarchar) + '''' + N' then isnull(IDT.CSTPayable,0)        
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)         
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
where Idt.InvoiceID = IA.InvoiceID        
and (IA.Status & 192) = 0         
and (IA.Status & 32) <> 0  
and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS ' + 
-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) 
' and #I.InvoiceId = Ia.InvoiceId
 and IA.InvoiceType = 4         
and IDt.SalePrice <> 0        
and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
-- ' and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
 N' and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case when ( #I.[taxtype] = ''LST'' or #I.[taxtype] = ''FLST'') then IDt.TaxCode else IDt.TaxCode2 end)    
and IA.CustomerID = C.CustomerID        
and ((#I.[taxtype] = ''LST'' and IDt.TaxCode = Percentage)  or  
(#I.[taxtype] = ''CST'' and IDt.TaxCode2 = CST_Percentage))  
and ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' = Tax_Description   
and IsNull(IDt.TaxID, 0) = '+ Cast(@TaxCode as nVarchar) + 
--and cast(C.Locality as nvarchar) like (
--case ' + '''' + Cast(@Locality  as nVarchar) + '''' + N'       
--when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''       
--+ N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + '''' + Cast('2' as nVarchar) + ''''        
--+ N' else ' + '''' + Cast('%' as nVarchar) + '''' + N' end        
-- )
 ')' + ''        

Exec sp_ExecuteSQL @tempSQL




If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3 
	Begin
		if Exists(Select * From #tmpTaxType Where [Type] = N'LSRD' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
		Begin
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Delete From #tmpTaxComp1
			Insert Into #tmpTaxComp1
			Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 1
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_SRD] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_SRD] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			End
		End
	End
	if @TaxTypeID = 2
	Begin
		if Exists(Select * From #tmpTaxType Where [Type] = N'OSRD' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
		Begin
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Delete From #tmpTaxComp1
			Insert Into #tmpTaxComp1
			Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 0
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_SRD] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_SRD] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			End
		End
	End

End


-- Update Total Retail Sales Return          
Set @tempSQL = N'Alter Table #VatReport Add[Total Retail Sales Return (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Retail Sales Return (%c)] Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 

        

---- Update Total Retail Sales Return  
Set @tempSQL = N' update #VATReport set [Total Retail Sales Return (%c)] = (        
 select abs(sum(isnull(IDt.Amount,0)) - sum(isnull(IDt.STPayable,0)))  
 from InvoiceAbstract IA
 inner join InvoiceDetail IDt on  Idt.InvoiceID = IA.InvoiceID   
 left outer join Customer C on   IA.CustomerID = C.CustomerID
  inner join Items It on  It.Product_Code = IDt.Product_Code
  inner join tbl_mERP_TaxType TxzType on TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + '
  inner join #InvoiceTaxType #I on  #I.InvoiceId = Ia.InvoiceId
 where      
   ' +  
-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +   
'  
   (IA.Status & 192) = 0        
 and IA.InvoiceType in (5,6)        
 and IDt.SalePrice <> 0        
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
 and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = IDt.TaxCode          
  ' + 
-- 'and (Case ' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' Then 0 Else 1 End) = 1  
 ' and IDt.TaxCode = (case when IDt.TaxCode=0  then 0 else (select Percentage from Tax where Tax_Description = ' + 
 '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N') end)  
 and ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' = (case when IDt.TaxCode=0  then' + '''' +
Cast('Exempt' as nVarchar) + '''' + N'else (select Tax_Description from Tax where Tax_Description = ' + '''' +
Cast(@TaxDesc as nVarchar(255)) + '''' +N') end)  
 and IsNull(IDt.TaxID, 0) = ' + Cast(@TaxCode as nVarchar) +N'  
 --and IDt.Amount<0  
)' + ''

Exec sp_ExecuteSQL @tempSQL


---- Update Tax Retail Sales Return  
Set @tempSQL = N'update #VATReport set [Tax on Retail Sales Return (%c)] = (        
 select Abs(sum(isnull(IDt.STPayable,0)))  
 from InvoiceAbstract IA
 inner join InvoiceDetail IDt on Idt.InvoiceID = IA.InvoiceID    
 left outer join Customer C on  IA.CustomerID = C.CustomerID 
 inner join Tax on  IDt.TaxCode = Percentage  
 inner join tbl_mERP_TaxType TxzType on   TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + '
 inner join  #InvoiceTaxType #I on  #I.InvoiceId = Ia.InvoiceId
 where     
   (IA.Status & 192) = 0    
 and IA.InvoiceType in (5,6)        
 and IDt.SalePrice <> 0        
  and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS         
 and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = IDt.TaxCode          
  ' + 
-- ' and (Case' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) + '''' +
--N' Then 0 Else 1 End) = 1 ' 
'  
 and ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' = Tax_Description  
 and IsNull(IDt.TaxID, 0) = ' + Cast(@TaxCode  as nVarchar)
 --and IDt.Amount<0  
+ N' ) ' + ''  

Exec sp_ExecuteSQL @tempSQL


If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3 
	Begin
		if Exists(Select * From #tmpTaxType Where [Type] = N'RIR' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
		Begin
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Delete From #tmpTaxComp1
			Insert Into #tmpTaxComp1
			Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 1
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_RIR] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_RIR] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			End
		End
	End
End


Set @tempSQL = N'Alter Table #VatReport Add[Net Sales Return (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Net Tax on Sales Return (%c)] Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Net Sales (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Net Tax on Sales (%c)] Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 


----StockTransferIn
Set @tempSQL = N'Alter Table #VatReport Add[Total Tran In (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax On Tran In (%c)] Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 




-- --StkTfrIn
Set @tempSQL = N'update #VATReport set [Total Tran In (%c)] =  (        
 select SUM(SD.Amount)  
From StockTransferInAbstract SA,StockTransferInDetail SD,Items It, tbl_mERP_TaxType TxzType
Where (SA.Status & 192) = 0        
and SA.DocumentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                          
+ N' and SA.DocSerial = SD.DocSerial
and SD.Product_Code  = ICode collate SQL_Latin1_General_Cp1_CI_AS        
and It.Product_Code = SD.Product_Code  
and TxzType.TaxID = IsNull(SA.TaxType,1)
and TxzType.TaxID = ' + Cast(@TaxTypeID As nVarchar) + ' 
and TxzType.TaxType = [Tax Type]   
and SD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)  
and IsNull(SD.TaxCode,0) = (Case When ' + Cast(@TaxCode as nVarchar) + N' = -1 Then 0 Else ' + Cast(@TaxCode as nVarchar) + N' End)  
 and (   
   SD.TaxSuffered = (select (Case IsNull(SA.TaxType,1) When 2 Then Tax.CST_Percentage Else Tax.Percentage End) from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' ) 
   or (SD.TaxSuffered = 0 )  
  )  
   and (case when SD.TaxSuffered=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else 
(select Tax.Tax_Description from tax where tax_description = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + 
N') end) = ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' +   
 --and (Case' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) +
--'''' + N' Then 0 Else 1 End) = 1  
' )' + ''        

Exec sp_ExecuteSQL @tempSQL

----Tax amount for StkTfrIn
Set @tempSQL = N' update #VATReport set [Tax on Tran In (%c)] =  (        
select SUM(SD.TaxAmount)  
From StockTransferInAbstract SA,StockTransferInDetail SD,Items It,Tax T, tbl_mERP_TaxType TxzType
where 
(SA.Status & 192) = 0        
and SA.DocumentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                          
+N' and SA.DocSerial = SD.DocSerial
and SD.Product_Code  = ICode collate SQL_Latin1_General_Cp1_CI_AS        
and It.Product_Code = SD.Product_Code  
and TxzType.TaxID = IsNull(SA.TaxType,1)
and TxzType.TaxID = ' + Cast(@TaxTypeID As nVarchar) + ' 
and TxzType.TaxType = [Tax Type]   
and SD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)  
and SD.TaxSuffered = (Case IsNull(SA.TaxType,1) When 2 Then T.CST_Percentage Else T.Percentage End)   
and T.Tax_Description = ' + '''' + Cast(@TaxDesc  as nVarchar(255)) + '''' + N'
and IsNull(SD.TaxCode, 0) = ' + Cast(@TaxCode  as nVarchar) + 
-- 'and (Case ' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) + '''' +
-- N' Then 0 Else 1 End) = 1  
' )' + ''        

Exec sp_ExecuteSQL @tempSQL

If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3 
	Begin
		if Exists(Select * From #tmpTaxType Where [Type] = N'TI' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
		Begin
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Delete From #tmpTaxComp1
			Insert Into #tmpTaxComp1
			Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 1
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_TI] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_TI] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			End
		End
	End
End


Set @tempSQL = N'Alter Table #VatReport Add[Total Tran Out (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax On Tran Out (%c)] Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL   

----StkTfrOut
Set @tempSQL = N'update #VATReport set [Total Tran Out (%c)] =  (        
select SUM(SD.Amount)  
From StockTransferOutAbstract SA,StockTransferOutDetail SD,Items It, Batch_Products bp,
    ( select min(tax_code) tax_code, percentage, 1 taxtype, min(Tax_Description) Tax_Description from Tax group by percentage 
        union 
      select min(tax_code) tax_code, cst_percentage percentage, 2 taxtype, min(Tax_Description) Tax_Description from Tax group by cst_percentage ) tax 
Where 
(SA.Status & 192) = 0        
and SA.DocumentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                              
+ N' and SA.DocSerial = SD.DocSerial
and SD.Product_Code  = ICode collate SQL_Latin1_General_Cp1_CI_AS        
and It.Product_Code = SD.Product_Code  
and SD.Batch_Code = bp.Batch_Code 
and IsNull(bp.TaxType, 1) =  ' + Cast(@TaxTypeID As nVarchar) + '  
and ( SD.TaxSuffered = tax.percentage and 
	(Case when (IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3) then 1 Else 2 End )= tax.taxtype ) 
and	( Case When ' + Cast(@TaxCode as nVarchar) + ' = -1 then -1 
		Else tax.Tax_Code End = ' + Cast(@TaxCode as nVarchar) + ' ) 
and ' + Cast(@Tax as nVarchar) + ' = tax.Percentage
and ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' = 
	(case ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + 
		N' when ' + '''' + Cast('Exempt' as nVarchar) + '''' + 
	N' then ' + '''' + Cast('Exempt' as nVarchar) + '''' + 
N' else tax.Tax_Description end)  '
-- N' and (Case ' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) + '''' + N'Then 0 Else 1 End) = 1 ' 
+ ' )' + ''

Exec sp_ExecuteSQL @tempSQL

--Tax On Tran Out
Set @tempSQL = N' update #VATReport set [Tax On Tran Out (%c)] =  (        
select SUM(SD.TaxAmount)  
From StockTransferOutAbstract SA,StockTransferOutDetail SD,Items It, Batch_Products bp,
	( select min(tax_code) tax_code, percentage, 1 taxtype, min(Tax_Description) Tax_Description from Tax group by percentage 
		union 
	  select min(tax_code) tax_code, cst_percentage percentage, 2 taxtype, min(Tax_Description) Tax_Description from Tax group by cst_percentage ) tax 
Where 
(SA.Status & 192) = 0        
and SA.DocumentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                              
+ N' and SA.DocSerial = SD.DocSerial
and SD.Product_Code  = ICode collate SQL_Latin1_General_Cp1_CI_AS        
and It.Product_Code = SD.Product_Code  
and SD.Batch_Code = bp.Batch_Code 
and IsNull(bp.TaxType, 1) =  ' + Cast(@TaxTypeID As nVarchar) + '  
and ( SD.TaxSuffered = tax.percentage and 
	(Case when (IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3) then 1 Else 2 End )= tax.taxtype ) 
and IsNull(SD.TaxSuffered,0) = tax.Percentage
and ' + '''' + Cast(@TaxDesc as nVarchar(255)) + '''' + N' =  tax.Tax_Description  
and tax.Percentage = SD.Taxsuffered and tax.Tax_Code = ' + Cast(@TaxCode as nVarchar)
+N' and IsNull(SD.TaxSuffered, 0) = convert(decimal(18,6), [Tax %] collate SQL_Latin1_General_Cp1_CI_AS) ' + 
-- 'and (Case ' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) + ''''
-- +N' Then 0 Else 1 End) = 1  
' )' + ''

Exec sp_ExecuteSQL @tempSQL

If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3 
	Begin
		if Exists(Select * From #tmpTaxType Where [Type] = N'TO' and isNull([Tax %],'') <> N'Exempt' and isNull([Tax %],'') = @tax)
		Begin
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Delete From #tmpTaxComp1
			Insert Into #tmpTaxComp1
			Select TaxCode, TaxCompCode From #tmpTaxComp Where Flag = 1
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_TO] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_TO] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp1 Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp1
			End
		End
	End
End



If @TaxSplitUp = 'Yes' 
Begin
	Insert Into #tmpComp Select TaxComponent_Code,Tax_Percentage,SP_Percentage From TaxComponents Where LST_Flag = 1 And Tax_Code = @TaxCode
	Select [ID] = Identity(Int,1,1),Comp_Code,Comp_Per,CompSP_Per Into #tmpComp1 From #tmpComp
	Select @Count = Count(*) From #tmpComp1
	Delete From #tmpComp

	Insert Into #tmpComp Select TaxComponent_Code,Tax_Percentage,SP_Percentage From TaxComponents Where LST_Flag = 0 And Tax_Code = @TaxCode
	Select [ID] = Identity(Int,1,1),Comp_Code,Comp_Per,CompSP_Per Into #tmpComp2 From #tmpComp
	Select @CountCST = Count(*) From #tmpComp2
	Delete From #tmpComp

	Declare CurVatReport Cursor For
	Select [Item Code],[Tax %] From #VatReport
	Open CurVatReport
	Fetch Next From CurVatReport Into @itmCode ,@TaxPer
	While @@Fetch_Status = 0
	Begin
		if @TaxTypeID = 1 or @TaxTypeID = 3 
		Begin
			Set @i =1 
			While @Count >= @i
			Begin
				Select @CompCode  =  Comp_Code , @CompPer = Comp_Per, @CompSP_Per = CompSP_Per  From  #tmpComp1 Where [ID] = @i
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TaxCode, @CompCode)
				--Purchase 
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'LB' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_Purchase] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) 
                    + N' and IsNull([Tax Type],'''') <> '''''
					exec sp_executesql  @tempSQL
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead 
					+ N' Tax (%c)_Purchase] = ( Case ' + '''' + Cast(@CompSP_Per as nVarchar) + '''' 
					+ N' When ''0'' Then  ''0'' else ' + N' IsNull([VAT Tax On Purchase (%c)],0)'+ N' * ' 
					+ Cast(@CompSP_Per as nVarchar) + N'/' + N'[Tax %]'
					+ N' end) Where [Tax %] = ' + Cast(@TaxPer as nVarchar) + N' and [Item Code] = ' 
					+ '''' +  Cast(@itmCode as NVarchar) + '''' 
                    + N' and IsNull([Tax Type],'''') <> '''''
					exec sp_executesql  @tempSQL
				End

				--Purchase Return 
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'LBR' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_PR] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
					exec sp_executesql  @tempSQL
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead 
					+ N' Tax (%c)_PR] = ( Case ' + '''' + Cast(@CompSP_Per as nVarchar) + '''' 
					+ N' When ''0'' Then  ''0'' else ' + N' IsNull([VAT Tax On Purchase Return (%c)],0)'
					+ N' * ' + Cast(@CompSP_Per as nVarchar) + N'/' + N'[Tax %]'
					+ N' end) Where [Tax %] = ' + Cast(@TaxPer as nVarchar) + N' and [Item Code] = '
					+ '''' +  Cast(@itmCode as NVarchar) + '''' + '' 
					exec sp_executesql  @tempSQL
				End

				--TransferIn
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'TI' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_TI] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
					exec sp_executesql  @tempSQL
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax (%c)_TI] = 
					( Case ' + '''' + Cast(@CompSP_Per as nVarchar) + '''' + N' When ''0'' Then  ''0'' else ' 
					+ N' IsNull( [Tax On Tran In (%c)] ,0)'+ N' * ' + Cast(@CompSP_Per as nVarchar) + N'/' + N'[Tax %]'
					+ N' end) Where [Tax %] = ' + Cast(@TaxPer as nVarchar) + N' and [Item Code] = ' + '''' +  Cast(@itmCode as NVarchar) + '''' + '' 
					exec sp_executesql  @tempSQL
				End

				--TransferOut
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'TO' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_TO] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
					exec sp_executesql  @tempSQL
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax (%c)_TO] = 
					( Case ' + '''' + Cast(@CompSP_Per as nVarchar) + '''' + N' When ''0'' Then  ''0'' else ' 
					+ N' IsNull([Tax On Tran Out (%c)] ,0)'+ N' * ' + Cast(@CompSP_Per as nVarchar) + N'/' + N'[Tax %]'
					+ N' end) Where [Tax %] = ' + Cast(@TaxPer as nVarchar) + N' and [Item Code] = ' + '''' 
					+  Cast(@itmCode as NVarchar) + '''' + '' 
					exec sp_executesql  @tempSQL
				End

				--Sales
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'LI' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_Sales] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar)  
                    + N' and IsNull([Tax Type],'''') = '''''
				    exec sp_executesql  @tempSQL
				    Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax (%c)_Sales] = 
				    (select isNull(Sum(Tax_Value),0) from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It , tbl_mERP_TaxType TxzType, InvoiceTaxComponents TaxComp, #InvoiceTaxType #I 
  				    where IA.InvoiceType in (1, 3)  and (IA.Status & 192) = 0  and Idt.InvoiceID = IA.InvoiceID and It.Product_Code = IDt.Product_Code ' + 
					-- 'and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +   
					' and #I.InvoiceId = Ia.InvoiceId 
					and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
    			    ' and IDt.SalePrice <> 0  and IDt.Product_Code = ' + '''' + Cast(@itmCode as nVarchar) + ''''     
					-- + N'and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + '''' 
					+ N' and IA.CustomerID = C.CustomerID and TaxComp.InvoiceID = IA.InvoiceID and 
					Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' and isNull(IDt.TaxID,0) = ' + Cast(@TaxCode as nVarchar)
					+ N'and isNull(Idt.TaxCode,0) = ' + Cast(@TaxPer as nVarchar) + N') Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) 
                    + N' and IsNull([Tax Type],'''') = '''''
 
					exec sp_executesql  @tempSQL
				End

				--Sales Return Saleable
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'LSRS' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_SRS] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
				    exec sp_executesql  @tempSQL
				    Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax (%c)_SRS] = 
				    (select isNull(Sum(Tax_Value),0) from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It , tbl_mERP_TaxType TxzType, InvoiceTaxComponents TaxComp, #InvoiceTaxType #I 
  				    where IA.InvoiceType in (4)  and (IA.Status & 192) = 0 and (IA.Status & 32) = 0 and Idt.InvoiceID = IA.InvoiceID and It.Product_Code = IDt.Product_Code ' + 
					-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +  
					' and #I.InvoiceId = Ia.InvoiceId 
					and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
    			    ' and IDt.SalePrice <> 0 and  IDt.Product_Code = ' + '''' + Cast(@itmCode as nVarchar) +  ''''     
					+ N'and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
					+ N' and IA.CustomerID = C.CustomerID and TaxComp.InvoiceID = IA.InvoiceID and 
					Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' and isNull(IDt.TaxID,0) = ' + Cast(@TaxCode as nVarchar)
					+ N' and isNull(Idt.TaxCode,0) = ' + Cast(@TaxPer as nVarchar) + N') Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
					exec sp_executesql  @tempSQL
				End
				
				--Sales Return Damage
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'LSRD' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_SRD] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
				    exec sp_executesql  @tempSQL
				    Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax (%c)_SRD] = 
				    (select isNull(Sum(Tax_Value),0) from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It ,tbl_mERP_TaxType TxzType, InvoiceTaxComponents TaxComp, #InvoiceTaxType #I 
  				    where IA.InvoiceType in (4)  and (IA.Status & 192) = 0 and (IA.Status & 32) <> 0 and Idt.InvoiceID = IA.InvoiceID and It.Product_Code = IDt.Product_Code ' + 
					-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +  
					' and #I.InvoiceId = Ia.InvoiceId 
					and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
    			    ' and IDt.SalePrice <> 0 and  IDt.Product_Code = ' + '''' + Cast(@itmCode as nVarchar) + ''''     
					-- + N'and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
					+ N' and IA.CustomerID = C.CustomerID and TaxComp.InvoiceID = IA.InvoiceID and 
					Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' and isNull(IDt.TaxID,0) = ' + Cast(@TaxCode as nVarchar)
					+ N'and isNull(Idt.TaxCode,0) = ' + Cast(@TaxPer as nVarchar) + N') Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
					exec sp_executesql  @tempSQL
				End

				--Retail Invoice
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'RI' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_RI] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
				    exec sp_executesql  @tempSQL
				    Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax (%c)_RI] = 
				    (select isNull(Sum(Tax_Value),0) from InvoiceAbstract IA, InvoiceDetail IDt,  Items It , tbl_mERP_TaxType TxzType, InvoiceTaxComponents TaxComp, #InvoiceTaxType #I 
  				    where IA.InvoiceType in (2) and (IA.Status & 192) = 0  and Idt.InvoiceID = IA.InvoiceID and It.Product_Code = IDt.Product_Code ' + 
					-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) + '  
					' and #I.InvoiceId = Ia.InvoiceId 
					and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
    			    ' and IDt.SalePrice <> 0  and IDt.Amount > -1   and IDt.Product_Code = ' + '''' + Cast(@itmCode as nVarchar) + ''''     
					-- + N'and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''
					+ N'  and TaxComp.InvoiceID = IA.InvoiceID and Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' and isNull(IDt.TaxID,0) = ' + Cast(@TaxCode as nVarchar)
					+ N'and isNull(Idt.TaxCode,0) = ' + Cast(@TaxPer as nVarchar) + N') Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
					exec sp_executesql  @tempSQL
				End
				
				--Retail Invoice Return
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'RIR' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_RIR] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
				    exec sp_executesql  @tempSQL
				    Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax (%c)_RIR] = 
				    (select isNull(Sum(Tax_Value),0) from InvoiceAbstract IA, InvoiceDetail IDt,  Items It, tbl_mERP_TaxType TxzType  , InvoiceTaxComponents TaxComp, #InvoiceTaxType #I 
  				    where IA.InvoiceType in (2,5,6)  and (IA.Status & 192) = 0  and Idt.InvoiceID = IA.InvoiceID and It.Product_Code = IDt.Product_Code and #I.InvoiceId = Ia.InvoiceId  ' + 
					-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +   
					' and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
    			    ' and IDt.SalePrice <> 0  and IDt.Amount > -1   and IDt.Product_Code = ' + '''' + Cast(@itmCode as nVarchar) + '''' 
					-- + N'and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
					+ N'  and TaxComp.InvoiceID = IA.InvoiceID and Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' and isNull(IDt.TaxID,0) = ' + Cast(@TaxCode as nVarchar)
					+ N'and isNull(Idt.TaxCode,0) = ' + Cast(@TaxPer as nVarchar) + N') Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
					exec sp_executesql  @tempSQL
				End
			Set @i = @i + 1
			End
		End
		if @TaxTypeID = 2
		Begin
			Set @i =1 
			While @CountCST >= @i
			Begin
				Select @CompCode  =  Comp_Code , @CompPer = Comp_Per, @CompSP_Per = CompSP_Per From  #tmpComp2 Where [ID] = @i
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TaxCode, @CompCode)
				--Purchase 
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'OB' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_Purchase] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) 
                    + N' and IsNull([Tax Type],'''') <> '''''
					exec sp_executesql  @tempSQL
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax (%c)_Purchase] = 
					( Case ' + '''' + Cast(@CompSP_Per as nVarchar) + '''' + N' When ''0'' Then  ''0'' else ' 
					+ N' IsNull([CST Tax On Purchase (%c)],0)'+ N' * ' + Cast(@CompSP_Per as nVarchar) + N'/' + N'[Tax %]'
					+ N' end) Where [Tax %] = ' + Cast(@TaxPer as nVarchar) + N' and [Item Code] = ' + '''' +  Cast(@itmCode as NVarchar) + '''' 
                    + N' and IsNull([Tax Type],'''') <> '''''
					exec sp_executesql  @tempSQL
				End

				--Purchase Return 
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'OBR' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_PR] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
					exec sp_executesql  @tempSQL
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax (%c)_PR]
					= ( Case ' + '''' + Cast(@CompSP_Per as nVarchar) + '''' + N' When ''0'' Then  ''0'' else ' 
					+ N' IsNull([CST Tax On Purchase Return (%c)],0)'+ N' * ' 
					+ Cast(@CompSP_Per as nVarchar) +  N'/' + N'[Tax %]'
					+ N' end) Where [Tax %] = ' + Cast(@TaxPer as nVarchar) + N' and [Item Code] = ' + '''' +  Cast(@itmCode as NVarchar) + '''' + '' 
					exec sp_executesql  @tempSQL
				End

				--Outstation Invoice
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'OI' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_Sales] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) 
                    + N' and IsNull([Tax Type],'''') = '''''
				    exec sp_executesql  @tempSQL
				    Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax (%c)_Sales] = 
				    (select isNull(Sum(Tax_Value),0) from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It , tbl_mERP_TaxType TxzType  , InvoiceTaxComponents TaxComp, #InvoiceTaxType #I 
  				    where IA.InvoiceType in (1, 3)  and (IA.Status & 192) = 0  and Idt.InvoiceID = IA.InvoiceID and It.Product_Code = IDt.Product_Code and #I.InvoiceId = Ia.InvoiceId ' + 
					-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +   
					' and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
    			    ' and IDt.SalePrice <> 0  and IDt.Product_Code = ' + '''' + Cast(@itmCode as nVarchar) + ''''     
					-- + N'and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
					+ N' and #I.[taxtype] = ''CST'' and IA.CustomerID = C.CustomerID and TaxComp.InvoiceID = IA.InvoiceID and 
					Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' and isNull(IDt.TaxID,0) = ' + Cast(@TaxCode as nVarchar)
					+ N'and isNull(Idt.TaxCode2,0) = ' + Cast(@TaxPer as nVarchar) + N') Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) 
                    + N' and IsNull([Tax Type],'''') = '''''
					exec sp_executesql  @tempSQL
				End


				--Sales Return Saleable
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'OSRS' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_SRS] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
				    exec sp_executesql  @tempSQL
				    Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax (%c)_SRS] = 
				    (select isNull(Sum(Tax_Value),0) from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It , tbl_mERP_TaxType TxzType  , InvoiceTaxComponents TaxComp, #InvoiceTaxType #I 
  				    where IA.InvoiceType in (4)  and (IA.Status & 192) = 0 and (IA.Status & 32) = 0 and Idt.InvoiceID = IA.InvoiceID and It.Product_Code = IDt.Product_Code and #I.InvoiceId = Ia.InvoiceId ' + 
					-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) + 
					' and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
    			    ' and IDt.SalePrice <> 0  and IDt.Product_Code = ' + '''' + Cast(@itmCode as nVarchar) + '''' 
					-- + N'and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + '''' 
					+ N' and #I.[taxtype] = ''CST'' and IA.CustomerID = C.CustomerID and TaxComp.InvoiceID = IA.InvoiceID and 
					Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' and isNull(IDt.TaxID,0) = ' + Cast(@TaxCode as nVarchar)
					+ N'and isNull(Idt.TaxCode2,0) = ' + Cast(@TaxPer as nVarchar) + N') Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
					exec sp_executesql  @tempSQL
				End
				
				--Sales Return Damage
				If Exists(Select [Item Code] From #tmpTaxType Where Type = N'OSRD' and isNull([Tax %],'') = @TaxPer and isNull([Item Code],'') = @itmCode and isNull([Tax %],'') <> N'Exempt') 
				Begin
					Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax %_SRD] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
				    exec sp_executesql  @tempSQL
				    Set @tempSQL = N'Update #VatReport Set[' + @TaxCompHead + N' Tax (%c)_SRD] = 
				    (select isNull(Sum(Tax_Value),0) from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It , tbl_mERP_TaxType TxzType , InvoiceTaxComponents TaxComp, #InvoiceTaxType #I 
  				    where IA.InvoiceType in (4)  and (IA.Status & 192) = 0 and (IA.Status & 32) <> 0 and Idt.InvoiceID = IA.InvoiceID and It.Product_Code = IDt.Product_Code and #I.InvoiceId = Ia.InvoiceId ' + 
					-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) + 
					' and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
    			    ' and IDt.SalePrice <> 0  and IDt.Product_Code = ' + '''' + Cast(@itmCode as nVarchar) + ''''     
					+ N'and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
					+ N' and #I.[taxtype] = ''CST'' and IA.CustomerID = C.CustomerID and TaxComp.InvoiceID = IA.InvoiceID and 
					Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' and isNull(IDt.TaxID,0) = ' + Cast(@TaxCode as nVarchar)
					+ N'and isNull(Idt.TaxCode2,0) = ' + Cast(@TaxPer as nVarchar) + N') Where [Item Code] = ' +''''+ Cast(@itmCode as nVarchar) +''''+
					N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) + '' 
					exec sp_executesql  @tempSQL
				End

				Set @i = @i + 1
			End
		End
		Fetch Next From CurVatReport Into @itmCode ,@TaxPer
	End
End 



Set @tempSQL = N'Alter Table #VatReport Add[Net VAT Payable (%c)] Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 




Set @tempSQL = N'update #VATReport set [Net Sales Return (%c)] = isnull([Sales Return Saleable (%c)],0) + isnull([Sales Return Damages (%c)],0) + isnull([Total Retail Sales Return (%c)],0) ' + ''
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'update #VATReport set [Net Tax on Sales Return (%c)] = isnull([Tax on Sales Return Saleable (%c)],0) + isnull([Tax on Sales Return Damages (%c)],0) + isnull([Tax on Retail Sales Return (%c)],0)' + ''       
Exec sp_ExecuteSQL @tempSQL                 

Set @tempSQL = N'Update #VATReport set [Total Sales (%c)] = Isnull([Total Sales (%c)], 0)' + ''          
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Update #VATReport set [Tax on Sales (%c)] = Isnull([Tax on Sales (%c)], 0) ' + ''          
Exec sp_ExecuteSQL @tempSQL                 

Set @tempSQL = N' Update #VATReport set [Total Purchase (%c)] = (case [Total Purchase (%c)] when 0 then null else [Total Purchase (%c)] end),                  
[Tax on Purchase (%c)] = (case [Tax on Purchase (%c)] when 0 then null else [Tax on Purchase (%c)] end),          
[Total Purchase Return (%c)] = (case [Total Purchase Return (%c)] when 0 then null else [Total Purchase Return (%c)] end),                  
[Tax on Purchase Return (%c)] = (case [Tax on Purchase Return (%c)] when 0 then null else [Tax on Purchase Return (%c)] end),                  
[Net Purchase (%c)] = (case [Net Purchase (%c)] when 0 then null else [Net Purchase (%c)] end),       
[Net Purchase Tax (%c)] = (case [Net Purchase Tax (%c)] when 0 then null else [Net Purchase Tax (%c)] end),  
[Total Sales (%c)] = (case [Total Sales (%c)] when 0 then null else [Total Sales (%c)]  end),         
[Tax on Sales (%c)] = (case [Tax on Sales (%c)] when 0 then null else [Tax on Sales (%c)] end),                  
[Sales Return Saleable (%c)] = (case [Sales Return Saleable (%c)] when 0 then null else [Sales Return Saleable (%c)] end),  
[Tax on Sales Return Saleable (%c)] = (case [Tax on Sales Return Saleable (%c)] when 0 then null else [Tax on Sales Return Saleable (%c)] end),                
[Sales Return Damages (%c)] = (case [Sales Return Damages (%c)] when 0 then null else [Sales Return Damages (%c)] end),                  
[Tax on Sales Return Damages (%c)] = (case [Tax on Sales Return Damages (%c)] when 0 then null else [Tax on Sales Return Damages (%c)] end),                  
[Total Retail Sales (%c)] = (case [Total Retail Sales (%c)] when 0 then null else [Total Retail Sales (%c)] end),    
[Tax on Retail Sales (%c)] = (case [Tax on Retail Sales (%c)] when 0 then null else [Tax on Retail Sales (%c)] end),                
[Total Retail Sales Return (%c)] = (case [Total Retail Sales Return (%c)] when 0 then null else [Total Retail Sales Return (%c)] end),                
[Tax on Retail Sales Return (%c)] = (case [Tax on Retail Sales Return (%c)] when 0 then null else [Tax on Retail Sales Return (%c)] end) ' + ''
Exec sp_ExecuteSQL @tempSQL                                
           
Set @tempSQL = N'update #VATReport set [Net Sales (%c)] = isnull([Total Sales (%c)],0) + isnull([Total Retail Sales (%c)],0) - isnull([Net Sales Return (%c)],0) ' + ''                  
Exec sp_ExecuteSQL @tempSQL                                
Set @tempSQL = N'update #VATReport set [Net Tax on Sales (%c)] = isnull([Tax on Sales (%c)],0) + isnull([Tax on Retail Sales (%c)],0) - isnull([Net Tax on Sales Return (%c)],0)' + ''           
Exec sp_ExecuteSQL @tempSQL                                
Set @tempSQL = N'update #VATReport set [Net VAT Payable (%c)] = isnull([Net Tax on Sales (%c)],0) - isnull([Net Purchase Tax (%c)],0)  - isnull([Tax On Tran In (%c)],0) + isnull([Tax On Tran Out (%c)],0)' + ''           
Exec sp_ExecuteSQL @tempSQL          
 
Set @tempSQL = N' Update #VATReport set [Net Sales Return (%c)] = (case [Net Sales Return (%c)] when 0 then null else [Net Sales Return (%c)] end),                  
[Net Tax on Sales Return (%c)] = (case [Net Tax on Sales Return (%c)] when 0 then null else [Net Tax on Sales Return (%c)] end),                  
[Net Sales (%c)] = (case [Net Sales (%c)] when 0 then null else [Net Sales (%c)] end),                  
[Net Tax on Sales (%c)] = (case [Net Tax on Sales (%c)] when 0 then null else [Net Tax on Sales (%c)] end),                  
[Net VAT Payable (%c)] = (case [Net VAT Payable (%c)] when 0 then null else [Net VAT Payable (%c)] end) ' + ''
Exec sp_ExecuteSQL @tempSQL                                



IF @Tax = Cast('0.000000' as nVarchar)
Begin
	Set @tempSQL = N'Update #VATReport Set [Tax %] = ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' Where [Tax %] = ' + Cast('0.000000' as nVarchar) + ''
	Exec sp_ExecuteSQL @tempSQL
	Select *  from #VATReport  Where [Tax %] collate SQL_Latin1_General_Cp1_CI_AS = N'Exempt'        
End
Else  
	Select *  from #VATReport  Where [Tax %] collate SQL_Latin1_General_Cp1_CI_AS = @Tax        

If @TaxSplitUp = N'Yes'
Begin
	Drop Table #tmpComp
	Drop Table #tmpTaxComp
	Drop Table #tmpTaxComp1
End


drop table #tmpCat  
drop table #temp3  
drop table #temp4  
drop table #VatReport  
drop table #tmpProd  
drop table #tempCatGroup
drop table #tempCatGroupID
drop table #tempCG
drop table #tmpTaxType
 GSTOut:
End  

