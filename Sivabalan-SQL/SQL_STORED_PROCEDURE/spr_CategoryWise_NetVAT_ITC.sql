Create procedure [dbo].[spr_CategoryWise_NetVAT_ITC]
(
 @CategoryGroup  nVarchar(4000),               
 @Hierarchy nVarchar(255),      
 @Category nVarchar(4000),                
 @FromDate datetime,                   
 @ToDate DateTime,                  
 @Tax nvarchar(10),                  
 @Locality nvarchar(50) ,                  
 @ItemCode nvarchar(4000),      
 @TaxSplitUp NVarchar(5),
 @TaxType nVarchar(20) 
)
as
Begin
Declare @Continue AS INT       
Declare @Inc AS INT       
Declare @TCat AS INT      
Declare @Continue1 AS INT      
Declare @CategoryID AS INT      
Declare @Delimeter as Char(1)          
declare @Local1 as Int
declare @outstation as int 
Declare @taxCnt as Int
Declare @incr as int
Declare @TaxTypeID Int 

Declare @txCode Int
Declare @txPer Decimal(18,6)
Declare @MaxCnt as Int
Declare @i as int
Declare @tempSQL as nVarchar(4000)
Declare @CategoryName as nVarchar(255)
Declare @TaxCode as Int
Declare @TaxPer as nVarchar(50)
Declare @TaxDesc as nVarchar(510)
Declare @CompCode as Int
Declare @CompPer as Decimal(18,6)
Declare @CompSP_Per as Decimal(18,6)
Declare @Count as Int
Declare @Purtaxval as nvarchar
Declare @j as int
Declare @k as int
Declare @NetPurtaxval as Decimal(18,6)
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



Create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Create Table #tempCategory (CategoryID Int, Status Int)      
Create Table #tmpCat(IDS Int Identity(1,1),CatID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
Create Table #temp3 (CatID Int, Status Int)          
Create Table #tempCatGroupID (CatID Int, Status Int)          
Create Table #temp4 (LeafId int,CatID Int, Parent nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)          
Create Table #tempCatGroup(GroupName nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create Table #tempCG(IDS Int Identity(1,1),CatID Int)  
Create Table #tempTax(Tax_Code Int,Tax_Description Nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,Percentage Decimal(18,6),LstApplicableOn Int,LstPartOff Decimal(18,6))
Create Table #tempPercentage(Ids Int Identity(1,1),Percentage Decimal(18,6))
--This table helps  to identify the transaction and its corresponding tax code
Create Table #tmpTaxType(Type nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, TaxCode Int,
TaxPer nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)


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

If @TaxSplitUp = N'Yes'
Begin
    Create Table #tempTaxComp (Tax_Code Int, tax_value Decimal(18,6), tax_component_code Int, 
        Invoiceid Int, Product_Code Nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)
    Insert Into #tempTaxComp
    select tax_code, sum(tax_value) tax_value, tax_component_code, invoiceid, Product_Code
    from invoicetaxcomponents where Invoiceid in (
        Select Invoiceid from #InvoiceTaxType #I )
    group by tax_code, tax_component_code, invoiceid,Product_Code  
end 

If @TaxSplitUp = N'Yes'
Begin
	Create Table #tmpMax(CompCount Int)
	Create Table #tmpTaxComp(TaxCode Int, TaxCompCode Int)
	Create Table #tmpComp(Comp_Code Int,Comp_Per Decimal(18,6),CompSP_Per Decimal(18,6))
End

Insert Into #tempPercentage
Select Distinct Percentage From Tax
--When more than one taxCode has same percentage and different Description then the latest tax row will be selected.
Set @incr = 1
Select @taxCnt = Count(*) From #tempPercentage
While @incr <= @taxCnt
Begin
    Insert Into #tempTax
	Select top 1 Tax_Code,Tax_Description,Percentage,LstApplicableOn,LstPartOff From Tax
	Where Percentage In (Select Percentage From #tempPercentage Where Ids = @incr)
    Order By Tax_Code Desc
Set @incr = @incr + 1
End

Drop Table #tempPercentage

Set @Delimeter=Char(15)
SET @Inc =1
select @Local1 = case when @Locality = N'Local' then 1 when @Locality='%' then 1 else 0 end
select @outstation = case when @Locality = N'OutStation' then 2 when @Locality='%' then 2 else 0 end

if @CategoryGroup = N'%'
	Insert Into #tempCatGroup Select GroupName From ProductCategoryGroupAbstract
else
Begin
  Insert Into #tempCatGroup select * from dbo.sp_SplitIn2Rows( @CategoryGroup,@Delimeter)
End

if @ItemCode='%'        
	insert into #tmpProd select product_code from items        
else        
	insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter)        
                
If @Hierarchy = N'%'   Or @Hierarchy = N'Division'
	Insert into #tmpCat select CategoryID from ItemCategories Where [level] = 2        
else if @Hierarchy <> N'%'   
	Insert InTo #tmpCat select Categoryid From itemcategories itc, itemhierarchy ith          
    where itc.[level] = ith.hierarchyid and ith.hierarchyname =@Hierarchy        

 declare @TaxValue decimal(18,6)          
 If @Tax = '%'           
 set @TaxValue = 0          
 else          
 Set @TaxValue = convert(decimal(18,6),@Tax)          

--Get All LeafID'S For the ProductHierarchy  selected      
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
-- Set @Continue1 = 1          
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



if @Category =N'%'  
 Insert into #tempCG    
 select PD.CategoryID     
 from ProductCategorygroupAbstract PA,@TempCGCatMapping PD  
 where PA.groupid = PD.groupid    
 and PA.GroupName In (Select GroupName COLLATE SQL_Latin1_General_CP1_CI_AS From  #tempCatGroup)      
ELSE  
    Insert into #tempCG  
 select Categoryid From itemcategories itc Where Category_Name   
 In(Select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter))                

Set @Inc =1  
Set @CategoryID  =0  
Delete #temp3          

--Inserts leaf categories for the selected category group  
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

Select @TaxTypeID = TaxID From tbl_mERP_Taxtype 
Where TaxType = @TaxType 

--=============
--Select @TaxTypeID 
--=============

create table #tempTaxCode           
( 
[Type] Nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS,                 
[Category Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,      
[Tax Code] Int ,        
[Temp Tax Desc] nvarchar(520) COLLATE SQL_Latin1_General_CP1_CI_AS,               
[Tax Desc] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,                  
[Tax %] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS)                  

create table #VATReport                  
( 
[Tax Code] Int,        
[Temp Tax Desc] nvarchar(520) COLLATE SQL_Latin1_General_CP1_CI_AS,                  
[Category Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,      
[Tax Desc] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,                  
[Tax %] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,                  
)                  

if Isnumeric(@Tax) = 1         
begin                  
	set @Tax = convert(nvarchar,convert(decimal(18,6),@Tax))                  
end                  
else                  
begin                  
	set @Tax = '%'                  
end                  


insert into #tempTaxCode([Type],[Category Name],[Tax Code], [Temp Tax Desc], [Tax Desc], [Tax %])                       
--Bills Local/Outstation                  
select (Case @TaxTypeID When 2 Then N'OB' Else 'LB' End), #temp4.Parent,(Case BD.TaxSuffered When 0 Then -1 Else IsNull(Tax.Tax_Code, 0) End)
--,convert(nVarChar, IsNull( #temp4.CatID, 0)) + char(15)+ convert(nVarChar, IsNull(Tax.Tax_Code, 0)) + char(15) + convert(nvarchar,BD.TaxSuffered)+char(15)+     
,convert(nVarChar, IsNull( #temp4.CatID, 0)) + char(15)+ (Case BD.TaxSuffered When 0 Then Cast('-1' as nVarchar) Else convert(nVarChar, IsNull(Tax.Tax_Code, 0)) End ) + char(15) + convert(nvarchar,BD.TaxSuffered)+char(15)+     
(case when BD.TaxSuffered = 0  then 'Exempt' else max([Tax_Description]) end),           
(case when BD.TaxSuffered = 0  then 'Exempt' else max([Tax_Description]) end),            
(case when BD.TaxSuffered = 0  then 'Exempt' else convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) end)          
from Items It
Inner Join BillDetail BD On  BD.Product_Code = It.Product_Code         
Inner Join BillAbstract BA On BA.BillID = BD.BillID                  
Inner Join  Vendors V On V.VendorID = BA.VendorID         
Left Outer Join Tax On BD.TaxCode = Tax.Tax_Code        
Inner Join #temp4 On It.CategoryID = #temp4.LeafID            
where          
--It.ProductName like @ItemName and                 
 BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)                 
 

         
 and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
 and BA.BillDate between @FromDate and @ToDate     
 and IsNull(BA.TaxType, 1) = @TaxTypeID 
 and BA.Status = 0                  
 and (          
  BD.TaxSuffered = @TaxValue          
  Or @Tax = '%'          
 )          
-- and BD.TaxSuffered *= Tax.Percentage          
 

-- and V.Locality like (                  
-- case @Locality                   
-- when 'Local' then '1'                  
-- when 'Outstation' then '2'                  
-- else '%' end)                  
group by #temp4.Parent,#temp4.CatID,Tax.Tax_Code, BD.TaxSuffered
--having SUM(BD.Amount + BD.TaxAmount)>0                  
--purchase Return Local/Outstation                  
union        
Select (Case @TaxTypeID When 2 Then N'OBR' Else N'LBR' End),#temp4.Parent,
--IsNull(Tax.Tax_Code, 0),convert(nVarChar, IsNull( #temp4.CatID, 0)) + char(15)+ convert(nVarChar, IsNull(Tax.Tax_Code, 0)) + char(15) + convert(nvarchar,ARD.Tax)+char(15)+          
(case when ARD.Tax = 0 Then -1 else IsNull(Tax.Tax_Code, 0) End),convert(nVarChar, IsNull( #temp4.CatID, 0)) + char(15)+ (case when ARD.Tax = 0 Then Cast('-1' as nVarchar) else convert(nVarChar, IsNull(Tax.Tax_Code, 0)) End) 
+ char(15) + convert(nvarchar,ARD.Tax)+char(15)+          
(case when ARD.Tax = 0  then 'Exempt' else max([Tax_Description]) end),           
(case when ARD.Tax = 0  then 'Exempt' else max([Tax_Description]) end),           
(case when ARD.Tax = 0  then 'Exempt' else convert(nvarchar,convert(decimal(18,6),ARD.Tax)) end)          
from Items It
Inner Join AdjustmentReturnDetail ARD On ARD.Product_Code = It.Product_Code 
Inner Join  AdjustmentReturnAbstract ARA On ARA.AdjustmentID = ARD.AdjustmentID 
Inner Join  Vendors V On ARA.VendorID = V.VendorID                  
Left Outer Join  ( select min(tax_code) tax_code, percentage, 1 taxtype, min(Tax_Description) Tax_Description from Tax group by percentage 
            union 
          select min(tax_code) tax_code, cst_percentage percentage, 2 taxtype, min(Tax_Description) Tax_Description from Tax group by cst_percentage ) tax On ARD.Tax = Tax.Percentage   
Inner Join #temp4 On It.CategoryID = #temp4.LeafID      
Inner Join Batch_Products bp  On ARD.BatchCode = bp.Batch_Code 
where         
--It.ProductName like @ItemName and                 
 It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)                  
 and (isnull(ARA.Status,0) & 128) = 0                  
 and Tax.taxtype = Case when ( IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3) then 1 
                        when IsNull(bp.TaxType, 1) = 2 then 2 end 
 and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
 and ARA.AdjustmentDate between @FromDate and @ToDate 
 
 And IsNull(bp.TaxType, 1) = @TaxTypeID 
 and (          
  ARD.Tax = @TaxValue          
  Or @Tax = '%'          
 )          
 
-- and ARD.Tax *= Tax.Percentage          
-- and ARD.TaxSuffApplicableOn *= Tax.LSTApplicableOn         
-- and ARD.TaxSuffPartOff *= Tax.LSTPartOff         
-- and cast(V.Locality as nvarchar) like                
-- (case @Locality                   
-- when 'Local' then '1'                   
-- when 'Outstation' then '2'                   
-- else '%' end) + '%'                  
group by #temp4.Parent,#temp4.CatID,Tax.Tax_Code, ARD.Tax
--Outstation Purchase Return
Union      
--Sales locality = 1      
Select N'LI',#temp4.parent,(Case When IDt.TaxCode = 0 Then -1 Else IsNull(Tax.Tax_Code, 0) End),
convert(nVarChar, IsNull( #temp4.CatID, 0)) + char(15)+ (Case When IDt.TaxCode = 0 Then Cast('-1' as nVarchar) Else convert(nVarChar, IsNull(Tax.Tax_Code, 0)) End) + char(15) + convert(nvarchar,IDt.TaxCode)+char(15)+           
(Case When  IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),           
(Case When  IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),           
(Case When  IDt.TaxCode = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end)          
from Items It
Inner Join InvoiceDetail IDt On IDt.Product_Code = It.Product_Code                  
Inner Join InvoiceAbstract IA On IA.InvoiceID = IDt.InvoiceID                  
Inner Join Customer C On C.CustomerID = IA.CustomerID                  
Left Outer Join  Tax  On IDt.TaxID = Tax.Tax_Code        
Inner Join #temp4 On it.CategoryID = #temp4.LeafID        
Inner Join  tbl_mERP_TaxType TxzType On TxzType.TaxID = @TaxTypeID 
Inner Join  #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
where                   
--It.ProductName like @ItemName and                 
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
--and IA.InvoiceDate between @FromDate and @ToDate 
--and IsNull(C.Locality, 1) =  @TaxTypeID 
and #I.[taxtype] = 'LST'
and (                  
 (--Trade Invoice----------------                  
  (IA.Status & 192) = 0                  
  and IA.InvoiceType in (1, 3)                  
 )-------------------------------                  
)                  
and (IDt.TaxCode = @TaxValue or @Tax = '%' )          
--and IDt.TaxCode *= Tax.Percentage          

--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )

--and @Local1 =1
group by #temp4.Parent,#temp4.CatID,Tax.Tax_Code,IDt.TaxCode
Union      
--Local Sales Return Saleable/Damage
Select (Case (IA.Status & 32) When 0 Then N'LSRS' Else N'LSRD' End),#temp4.parent,
(Case When IDt.TaxCode = 0 Then -1 Else IsNull(Tax.Tax_Code, 0) End),
convert(nVarChar, IsNull( #temp4.CatID, 0)) + char(15)+ (Case When IDt.TaxCode = 0 Then Cast('-1' as nVarchar) Else convert(nVarChar, IsNull(Tax.Tax_Code, 0)) End) + char(15) + convert(nvarchar,IDt.TaxCode) +char(15)+           
(Case When  IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),           
(Case When  IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),           
(Case When  IDt.TaxCode = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end)          
from Items It
Inner Join  InvoiceDetail IDt On IDt.Product_Code = It.Product_Code                  
Inner Join InvoiceAbstract IA On IA.InvoiceID = IDt.InvoiceID
Inner Join Customer C On C.CustomerID = IA.CustomerID                  
Left Outer Join  Tax  On IDt.TaxID = Tax.Tax_Code        
Inner Join #temp4 On it.CategoryID = #temp4.LeafID        
Inner Join  tbl_mERP_TaxType TxzType On TxzType.TaxID = @TaxTypeID 
Inner Join  #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
where                   
--It.ProductName like @ItemName and                 
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
--and IA.InvoiceDate between @FromDate and @ToDate 
--and IsNull(C.Locality, 1) = @TaxTypeID 
and #I.[taxtype] = 'LST'
and (           
 (--Sales Return-----------------                
 (IA.Status & 192) = 0  and  ((IA.Status & 32) = 0  or (IA.Status & 32) <> 0)                
    and IA.InvoiceType = 4                
 )-------------------------------                
)                  
and (IDt.TaxCode = @TaxValue or @Tax = '%' )          
--and IDt.TaxCode *= Tax.Percentage          
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
--and @Local1 =1
group by #temp4.Parent,#temp4.CatID,Tax.Tax_Code,IDt.TaxCode,(IA.Status & 32)          
Union
--Outstation Invoice
Select N'OI',#temp4.Parent,(Case When IDt.TaxCode2 = 0 Then -1 Else IsNull(Tax.Tax_Code, 0) End),
convert(nVarChar, IsNull( #temp4.CatID, 0)) + char(15)+ (Case When IDt.TaxCode2 = 0 Then Cast('-1' as nVarchar) Else convert(nVarChar, IsNull(Tax.Tax_Code, 0)) End) + char(15) + convert(nvarchar,IDt.TaxCode2)+char(15)+           
(Case When IDt.TaxCode2 = 0 then 'Exempt' else max([Tax_Description]) end),           
(Case When IDt.TaxCode2 = 0 then 'Exempt' else max([Tax_Description]) end),           
(Case When IDt.TaxCode2 = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) end)          
from Items It
Inner Join  InvoiceDetail IDt On IDt.Product_Code = It.Product_Code                  
Inner Join InvoiceAbstract IA On IA.InvoiceID = IDt.InvoiceID
Inner Join  Customer C On C.CustomerID = IA.CustomerID                  
Left Outer Join Tax  On IDt.TaxID = Tax.Tax_Code        
Inner Join #temp4 On It.CategoryID = #temp4.LeafID      
Inner Join  tbl_mERP_TaxType TxzType On TxzType.TaxID = @TaxTypeID 
Inner Join  #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
where                   
--It.ProductName like @ItemName and                 
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
--and IA.InvoiceDate between @FromDate and @ToDate  
--and IsNull(C.Locality, 1) = @TaxTypeID                 
and #I.[taxtype] = 'CST'
and (                  
 (--Trade Invoice----------------                  
  (IA.Status & 192) = 0                  
  and IA.InvoiceType in (1, 3)                  
 )-------------------------------                  
)                  
and (          
  IDt.TaxCode2 = @TaxValue     
  or @Tax = '%'          
  )          
--and IDt.TaxCode2 *= Tax.CST_Percentage          
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
--and @outstation = 2
group by #temp4.Parent,#temp4.CatID,Tax.Tax_Code, IDt.TaxCode2
--having sum(IDt.Amount)>0                  
union          
--Outstation sales return Saleable/Damage
Select (Case (IA.Status & 32) When 0 Then N'OSRS' Else N'OSRD' End),#temp4.Parent,
(Case When  IDt.TaxCode2 = 0 Then -1 Else IsNull(Tax.Tax_Code, 0) End),
convert(nVarChar, IsNull( #temp4.CatID, 0)) + char(15)+(Case When  IDt.TaxCode2 = 0 Then Cast('-1' as nVarchar) Else convert(nVarChar, IsNull(Tax.Tax_Code, 0)) End)+ char(15) + convert(nvarchar,IDt.TaxCode2)+char(15)+           
(Case When  IDt.TaxCode2 = 0 then 'Exempt' else max([Tax_Description]) end),           
(Case When  IDt.TaxCode2 = 0 then 'Exempt' else max([Tax_Description]) end),           
(Case When  IDt.TaxCode2 = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) end)          
from Items It
Inner Join InvoiceDetail IDt On IDt.Product_Code = It.Product_Code                  
Inner Join  InvoiceAbstract IA On IA.InvoiceID = IDt.InvoiceID                  
Inner Join Customer C On C.CustomerID = IA.CustomerID                  
Left Outer Join  Tax  On IDt.TaxID = Tax.Tax_Code        
Inner Join #temp4 On It.CategoryID = #temp4.LeafID      
Inner Join tbl_mERP_TaxType TxzType On TxzType.TaxID = @TaxTypeID 
Inner Join  #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
where                 
--It.ProductName like @ItemName and                 
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
--and IA.InvoiceDate between @FromDate and @ToDate 
--and IsNull(C.Locality, 1) = @TaxTypeID                    
and #I.[taxtype] = 'CST'
and (                  
 (--Sales Return-----------------                
 (IA.Status & 192) = 0  and ((IA.Status & 32) = 0  Or (IA.Status & 32) <> 0 )                
    and IA.InvoiceType = 4                
 )-------------------------------                
)                  
and (          
  IDt.TaxCode2 = @TaxValue          
  or @Tax = '%'          
  )          
--and IDt.TaxCode2 *= Tax.CST_Percentage          
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
--and @outstation = 2
group by #temp4.Parent,#temp4.CatID,Tax.Tax_Code, IDt.TaxCode2, (IA.Status & 32)           
--having sum(IDt.Amount)>0                  


--Inserts Retail Invoice,Retail Invoice Return,STI and STO only when Locality all or local is selected.
If @TaxTypeID = 1 or @TaxTypeID = 3 
Begin
-- Retail Invoice       
insert into #tempTaxCode([Type],[Category Name],[Tax Code], [Temp Tax Desc], [Tax Desc], [Tax %])                       
Select N'RI',#temp4.Parent,(Case When  IDt.TaxCode = 0 Then -1 Else IsNull(Tax.Tax_Code, 0) End),
convert(nVarChar, IsNull( #temp4.CatID, 0)) + char(15)+ (Case When  IDt.TaxCode = 0 Then Cast('-1' as nVarchar) Else convert(nVarChar, IsNull(Tax.Tax_Code, 0)) End)+ char(15) + convert(nvarchar,IDt.TaxCode)+char(15)+           
(Case When  IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),           
(Case When  IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),           
(Case When  IDt.TaxCode = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end)          
from Items It
Inner Join InvoiceDetail IDt On IDt.Product_Code = It.Product_Code                  
Inner Join InvoiceAbstract IA On IA.InvoiceID = IDt.InvoiceID                  
Left Outer Join Customer C On C.CustomerID = Cast(IA.CustomerID  as int) and @Local1 = 1 
Left Outer Join Tax  On IDt.TaxCode = Tax.Percentage and IDt.TaxID = Tax.Tax_Code                
Inner Join #temp4 On It.CategoryID = #temp4.LeafID      
Inner Join  tbl_mERP_TaxType TxzType On TxzType.TaxID = @TaxTypeID 
Inner Join  #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
where                   
--It.ProductName like @ItemName and                 
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
--and IA.InvoiceDate between @FromDate and @ToDate 
--and IsNull(C.Locality, 1) = @TaxTypeID                  
and (Isnull(IA.Status, 0) & 192) = 0                  
and IA.InvoiceType in (2)                  
and (          
  IDt.TaxCode = @TaxValue          
  or @Tax = '%'          
  )          
--and (Cast(rtrim(ltrim(@Locality)) as nVarchar) = N'Outstation'  and  @Local1 = 1)
--and (Case Cast(@Locality as nVarchar) When N'Outstation' Then 0 Else 1 End) = 1                  
group by #temp4.Parent,#temp4.CatID,Tax.Tax_Code, IDt.TaxCode
--having sum(IDt.Amount)>0                  
--order By BD.TaxSuffered                  
union
--Retail Invoice Return
Select N'RIR',#temp4.Parent,(Case When  IDt.TaxCode = 0 Then -1 Else IsNull(Tax.Tax_Code, 0) End),
convert(nVarChar, IsNull( #temp4.CatID, 0)) + char(15)+ (Case When  IDt.TaxCode = 0 Then Cast('-1' as nVarchar) Else convert(nVarChar, IsNull(Tax.Tax_Code, 0)) End)+ char(15) + convert(nvarchar,IDt.TaxCode)+char(15)+           
(Case When  IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),           
(Case When  IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),           
(Case When  IDt.TaxCode = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end)          
from Items It
Inner Join  InvoiceDetail IDt On IDt.Product_Code = It.Product_Code                  
Inner Join  InvoiceAbstract IA On IA.InvoiceID = IDt.InvoiceID
Left Outer Join  Customer C On C.CustomerID = Cast(IA.CustomerID  as int)                
Left Outer Join Tax  On IDt.TaxID = Tax.Tax_Code  
Inner Join #temp4 On It.CategoryID = #temp4.LeafID      
Inner Join tbl_mERP_TaxType TxzType On TxzType.TaxID = @TaxTypeID 
Inner Join  #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
where                   
--It.ProductName like @ItemName and                 
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
--and IA.InvoiceDate between @FromDate and @ToDate 
--and IsNull(C.Locality, 1) = @TaxTypeID                   
and (Isnull(IA.Status, 0) & 192) = 0                  
and IA.InvoiceType in (5,6)                  
and (          
  IDt.TaxCode = @TaxValue          
  or @Tax = '%'          
  )          
--and IDt.TaxCode *= Tax.Percentage          
and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1                  
group by #temp4.Parent,#temp4.CatID,Tax.Tax_Code, IDt.TaxCode           
--having sum(IDt.Amount)>0                  
--order By BD.TaxSuffered      
End 
insert into #tempTaxCode([Type],[Category Name],[Tax Code], [Temp Tax Desc], [Tax Desc], [Tax %])
select N'TI', #temp4.Parent,(Case When SD.TaxSuffered = 0 Then -1 Else IsNull(tax.Tax_Code, 0) End),
convert(nVarChar, IsNull( #temp4.CatID, 0)) + char(15)+ (Case When SD.TaxSuffered = 0 Then Cast('-1' as nVarchar) Else convert(nVarChar, IsNull(tax.Tax_Code, 0)) End)+ char(15) + convert(nvarchar,SD.TaxSuffered)+char(15)+           
(case when SD.TaxSuffered = 0  then 'Exempt' else max([Tax_Description]) end),           
(case when SD.TaxSuffered = 0  then 'Exempt' else max([Tax_Description]) end),            
(case when SD.TaxSuffered = 0  then 'Exempt' else convert(nvarchar,convert(decimal(18,6),SD.TaxSuffered)) end)          
From StockTransferInAbstract SA
Inner Join StockTransferInDetail SD On SA.Docserial = SD.Docserial
Inner Join Items It On SD.Product_Code = It.Product_Code         
Left Outer Join ( select min(tax_code) tax_code, percentage, 1 taxtype, min(Tax_Description) Tax_Description from Tax group by percentage 
        union 
      select min(tax_code) tax_code, cst_percentage percentage, 2 taxtype, min(Tax_Description) Tax_Description from Tax group by cst_percentage ) tax On SD.TaxCode = tax.Tax_Code 
Inner Join #temp4 On It.CategoryID = #temp4.LeafID               
Where 
(SA.Status & 192)=0  
and SA.DocumentDate Between @FromDate and @ToDate 
and IsNull(SA.TaxType, 0) = @TaxTypeID and tax.TaxType = ( Case when @TaxTypeID = 1 or @TaxTypeID = 3 then 1 else 2 end  )
and SD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and #temp4.LeafID In(Select CatID From #tempCatGroupID) 
and (          
  SD.TaxSuffered = @TaxValue          
  Or @Tax = '%'          
 )          

--and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1          
group by #temp4.Parent,#temp4.CatID,tax.Tax_Code, SD.TaxSuffered           
----StockTranferOut
Union
Select N'TO',#temp4.parent,(Case When SD.TaxSuffered = 0 Then -1 Else Tax_Code End),
convert(nVarChar, IsNull( #temp4.CatID, 0)) + char(15)+ (Case When SD.TaxSuffered = 0 Then Cast('-1' as nVarchar) Else convert(nVarChar, Tax_Code) End)  + char(15) + convert(nvarchar,SD.TaxSuffered)+char(15)+           
(Case When  SD.TaxSuffered = 0 then 'Exempt' else max(Tax_Description)  end),          
(Case When  SD.TaxSuffered = 0 then 'Exempt' else max(Tax_Description)  end),           
(Case When  SD.TaxSuffered = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),SD.TaxSuffered)) end)          
From StockTransferOutAbstract SA,StockTransferOutDetail SD,#temp4 ,Items It ,
    ( select min(tax_code) tax_code, percentage, 1 taxtype, min(Tax_Description) Tax_Description from Tax group by percentage 
        union 
      select min(tax_code) tax_code, cst_percentage percentage, 2 taxtype, min(Tax_Description) Tax_Description from Tax group by cst_percentage ) tax, Batch_Products bp
Where 
(Isnull(SA.Status,0)&192)  = 0
and  SA.DocumentDate Between @FromDate and @ToDate
and SD.Batch_Code = bp.Batch_Code
and IsNull(bp.TaxType, 1) = @TaxTypeID 
and SA.DocSerial = SD.DocSerial
and SD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and SD.Product_Code = It.Product_Code         
and It.CategoryID = #temp4.LeafID               
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
and (          
  SD.TaxSuffered = @TaxValue          
  Or @Tax = '%'          
 )
and ( tax.Percentage = SD.Taxsuffered 
		and (Case when (IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3) 
			then 1 Else 2 End ) = tax.taxtype ) 
--and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1          
group by #temp4.Parent,#temp4.CatID,SD.TaxSuffered, tax.Tax_Code 




Insert Into  #tmpTaxType
Select Distinct [Type],[Category Name],[Tax Code],[Tax %] From #tempTaxCode



Update #tempTaxCode set Type=''


Insert Into #VatReport([Category Name],[Tax Code],[Temp Tax Desc] ,[Tax Desc] ,[Tax %])
Select  Distinct [Category Name],[Tax Code],[Temp Tax Desc] ,[Tax Desc] ,[Tax %] 
From #tempTaxCode


Drop Table #tempTaxCode


Set @tempSQL = N'Alter Table #VatReport Add[Total Purchase (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Purchase (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 

     
--Total Purchase amount                  
Set @tempSQL = N'update #VATReport set [Total Purchase (%c)] =  (                  
 select SUM(BD.Amount)                  
 from BillDetail BD, BillAbstract BA, Vendors V, Items ,#temp4         
 where BD.BillID = BA.BillID                  
 and BD.Product_Code = Items.Product_code 
 and IsNull(BA.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + ' 
 and Items.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
 and Items.CategoryID = #temp4.LeafID      
 and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
 AND [Category Name] = #temp4.Parent      
 and BA.Status = 0                   
 and BA.BillDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
 + N' and (case when BD.TaxSuffered = 0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) end) = [Tax %]          
 and V.VendorID = BA.VendorID                  
 and (          
  ([Tax Desc] = ' + '''' + Cast('Exempt' as nVArchar) + '''' + N' and BD.TaxSuffered = 0) or           
  (          
   BD.TaxSuffered = (select (Case IsNull(BA.TaxType,1) When 2 Then Tax.CST_Percentage Else Tax.Percentage End) from tax where tax_description = [Tax Desc])            
     and [Tax Desc] = (Case when BD.TaxSuffered=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)          
  )          
 )          
 and [Tax Code] = (Case When BD.TaxSuffered = 0 Then -1 Else  BD.TaxCode End) ' + 
--' and V.Locality like (case ' + '''' + Cast(@Locality as nVarchar) + ''''                   
--+ N' when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''              
--+N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + '''' + Cast('2' as nVarchar) + ''''                 
--+N' else ' + ''''+ N'%' + '''' + N' end) ' +                   
' Group By #temp4.Parent      
)' + ''                  
Exec sp_ExecuteSQL @tempSQL                 

----Tax amount on Purchase                  
Set @tempSQL = N' update #VATReport set [Tax on Purchase (%c)] =  (                  
  select SUM(BD.TaxAmount)                  
  from BillDetail BD, BillAbstract BA, Vendors V, Items ,#temp4            
  where BD.BillID = BA.BillID               
  and BD.Product_code = Items.Product_code    
  and IsNull(BA.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + '          
  and Items.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
  and Items.CateGoryID = #temp4.LeafID      
  and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
  AND [Category Name] = #temp4.Parent      
  and BA.Status = 0                   
  and BA.BillDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
  + N' and convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) = [Tax %]          
  and V.VendorID = BA.VendorID                  
  and BD.TaxSuffered = (select (Case IsNull(BA.TaxType,1) When 2 Then Tax.CST_Percentage Else Tax.Percentage End) from tax where tax_description = [Tax Desc])
  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc])          
  and [Tax Code] = IsNull(BD.TaxCode, 0) ' + 
--  ' and V.Locality like (case ' + '''' + Cast(@Locality as nVarchar) + ''''                   
--  + N' when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''                  
--  +N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + '''' + Cast('2' as nVarchar) + ''''                 
--  +N' else ' + ''''+ N'%' + '''' + N' end) ' + 
  ' Group By #temp4.Parent      
  )' + ''                  
Exec sp_ExecuteSQL @tempSQL                 


--LST Purchase column and TaxComponent SplitUp
if @TaxSplitUp = 'Yes'
Begin
	if Exists(Select * From #tmpTaxType Where Type  = N'LB') --and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') <> N'Exempt' and isNull(TaxPer,'') <> '')
	Begin
		Set @tempSQL = N'Alter Table #VatReport Add[VAT Total Purchase (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
		Set @tempSQL = N'Alter Table #VatReport Add[VAT Tax on Purchase (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
	
	
	
		--LST Total Purchase amount                  
		Set @tempSQL = N'update #VATReport set [VAT Total Purchase (%c)] =  (                  
		 select SUM(BD.Amount)                  
		 from BillDetail BD, BillAbstract BA, Vendors V, Items ,#temp4         
		 where BD.BillID = BA.BillID                  
		 and BD.Product_Code = Items.Product_code    
		 and IsNull(BA.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + ' 
		 and Items.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
		 and Items.CategoryID = #temp4.LeafID      
		 and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
		 AND [Category Name] = #temp4.Parent      
		 and BA.Status = 0                   
		 and BA.BillDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
		+ N' and (case when BD.TaxSuffered=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) end) = [Tax %]          
		 and V.VendorID = BA.VendorID                  
		 and (          
		  ([Tax Desc] = ' + '''' + Cast('Exempt' as nVArchar) + '''' + N' and BD.TaxSuffered = 0) or           
		  (          
		   BD.TaxSuffered = (select (Case IsNull(BA.TaxType,1) When 2 Then Tax.CST_Percentage Else Tax.Percentage End) from tax where tax_description = [Tax Desc])
		     and [Tax Desc] = (Case when BD.TaxSuffered=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)          
		  )          
		 )          
		 and [Tax Code] =(Case When BD.TaxSuffered = 0 Then -1 Else  BD.TaxCode End) 
		 Group By #temp4.Parent 
		)' 
		Exec sp_ExecuteSQL @tempSQL                 

		----LST Tax amount on Purchase                  
		Set @tempSQL = N' update #VATReport set [VAT Tax on Purchase (%c)] =  (                  
		 select SUM(BD.TaxAmount)                  
		 from BillDetail BD, BillAbstract BA, Vendors V, Items ,#temp4            
		 where BD.BillID = BA.BillID               
		  and BD.Product_code = Items.Product_code  
		  and IsNull(BA.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + '  
		  and Items.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
		  and Items.CateGoryID = #temp4.LeafID      
		  and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
		  AND [Category Name] = #temp4.Parent      
		  and BA.Status = 0                   
		  and BA.BillDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
		  + N' and convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) = [Tax %]          
		  and V.VendorID = BA.VendorID                  
		  and BD.TaxSuffered = (select (Case IsNull(BA.TaxType,1) When 2 Then Tax.CST_Percentage Else Tax.Percentage End) from tax where tax_description = [Tax Desc])
		  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc])          
	  	 and [Tax Code] = IsNull(BD.TaxCode, 0) 
		 Group By #temp4.Parent 
		)' 
		Exec sp_ExecuteSQL @tempSQL                 
		if @TaxTypeID = 1 or @TaxTypeID = 3 
		Begin
			Delete From #tmpTaxComp
			Insert Into #tmpTaxComp
			Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
			Where Type = N'LB' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 1 group By Tax_Code, TaxComponent_Code

			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_Purchase] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_Purchase] Decimal(18,6) '
				Exec sp_executesql @TempSql
				Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
			End
		End
	End
End

--CST Purchase column and TaxComponent SplitUp
if @TaxSplitUp = 'Yes' 
Begin
	if Exists(Select * From #tmpTaxType Where Type  = N'OB') --and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') <> N'Exempt' and isNull(TaxPer,'') <> '')
	Begin

		Set @tempSQL = N'Alter Table #VatReport Add[CST Total Purchase (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
		Set @tempSQL = N'Alter Table #VatReport Add[CST Tax on Purchase (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
	
	
	
		--CST Total Purchase amount                  
		Set @tempSQL = N'update #VATReport set [CST Total Purchase (%c)] =  (                  
		 select SUM(BD.Amount)                  
		 from BillDetail BD, BillAbstract BA, Vendors V, Items ,#temp4         
		 where BD.BillID = BA.BillID                  
		 and BD.Product_Code = Items.Product_code   
		 and IsNull(BA.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + '   
		 and Items.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
		 and Items.CategoryID = #temp4.LeafID      
		 and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
		 AND [Category Name] = #temp4.Parent      
		 and BA.Status = 0                   
		 and BA.BillDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
		+ N' and (case when BD.TaxSuffered=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) end) = [Tax %]          
		 and V.VendorID = BA.VendorID                  
		 and (          
		  ([Tax Desc] = ' + '''' + Cast('Exempt' as nVArchar) + '''' + N' and BD.TaxSuffered = 0) or           
		  (          
		   BD.TaxSuffered = (select (Case IsNull(BA.TaxType,1) When 2 Then Tax.CST_Percentage Else Tax.Percentage End) from tax where tax_description = [Tax Desc])
		     and [Tax Desc] = (Case when BD.TaxSuffered=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)          
		  )          
		 )          
		 and [Tax Code] = (Case When BD.TaxSuffered = 0 Then -1 Else BD.TaxCode End) ' + 
--         and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--                                when 'Outstation' then '2'
--                                else '%'
--          end ) + 
		' Group By #temp4.Parent 
		)' + ''                  
		Exec sp_ExecuteSQL @tempSQL                 
		
		----CST Tax amount on Purchase                  
		Set @tempSQL = N' update #VATReport set [CST Tax on Purchase (%c)] =  (                  
		 select SUM(BD.TaxAmount)                  
		 from BillDetail BD, BillAbstract BA, Vendors V, Items ,#temp4 
		 where BD.BillID = BA.BillID               
		  and BD.Product_code = Items.Product_code 
		  and IsNull(BA.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + '  
		  and Items.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
		  and Items.CateGoryID = #temp4.LeafID      
		  and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
		  AND [Category Name] = #temp4.Parent      
		  and BA.Status = 0                   
		  and BA.BillDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
		  + N' and convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) = [Tax %]          
		  and V.VendorID = BA.VendorID                  
		  and BD.TaxSuffered = (select (Case IsNull(BA.TaxType,1) When 2 Then Tax.CST_Percentage Else Tax.Percentage End) from tax where tax_description = [Tax Desc])
		  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc])          
		  and [Tax Code] = IsNull(BD.TaxCode, 0) ' + 
--         and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--                                when 'Outstation' then '2'
--                                else '%'
--          end ) + 
		' Group By #temp4.Parent 
		)' + ''                  
		Exec sp_ExecuteSQL @tempSQL                 
	
		if @TaxTypeID = 2
		Begin
			Delete From #tmpTaxComp
			Insert Into #tmpTaxComp
			Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
			Where Type = N'OB' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 0 group By Tax_Code, TaxComponent_Code

			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_Purchase] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_Purchase] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
			End
		End
	End
End

--Total Purchase Return amount                  
Set @tempSQL = N'Alter Table #VatReport Add[Total Purchase Return (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Purchase Return (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 


Set @tempSQL = N'update #VATReport set [Total Purchase Return (%c)] = (                  
 select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))          
 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items ,#temp4, Batch_Products bp 
 where ARA.AdjustmentID = ARD.AdjustmentID                  
  and ARD.Product_Code = Items.Product_Code 
  and ARD.BatchCode = bp.Batch_Code
  and IsNull(bp.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + ' 
  and Items.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
  and Items.CateGoryID = #temp4.LeafID      
  and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
  AND [Category Name] = #temp4.Parent      
  and (isnull(ARA.Status,0) & 128) = 0                  
  and ARA.AdjustmentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
  + N' and (Case when ARD.Tax=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else convert(nvarchar,convert(decimal(18,6),ARD.Tax)) end) = [Tax %]          
  and V.VendorID = ARA.VendorID                  
  and (          
  ([Tax Desc] = ' + '''' + Cast('Exempt' as nVarchar) + '''' +  N'and ARD.Tax = 0) or           
  (          
   ARD.Tax = (case when ' + convert(varchar, @TaxTypeID) + ' = 1 or ' + convert(varchar, @TaxTypeID) + ' = 3 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)           
     and [Tax Desc] = (Case when ARD.Tax=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)          
  )          
 ) ' +          
--and V.Locality like (                  
--  case ' + '''' + Cast(@Locality as nVarchar)  + ''''                   
-- + N' when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''                  
-- + N' when '+ '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + '''' + Cast('2' as nVarchar) + ''''                  
-- + N' else ' + '''' + N'%' + '''' + N' end                  
-- )                  
' Group By #temp4.CatID                  
)' + ''                  
Exec sp_ExecuteSQL @tempSQL                 

--Tax amount on Purchase Return                  
Set @tempSQL = N'update #VATReport set [Tax on Purchase Return (%c)] = (                  
 select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))          
 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items,#temp4, Batch_Products bp          
 where ARA.AdjustmentID = ARD.AdjustmentID                  
  and ARD.Product_Code = Items.Product_Code 
  and ARD.BatchCode = bp.Batch_Code
  and IsNull(bp.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + '          
  and Items.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
  and Items.CateGoryID = #temp4.LeafID      
  and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
  AND [Category Name] = #temp4.Parent      
  and (isnull(ARA.Status,0) & 128) = 0                  
  and ARA.AdjustmentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''       
  + N' and convert(nvarchar,convert(decimal(18,6),ARD.Tax)) = [Tax %]   
  and ARA.VendorID = V.VendorID                  
  and ARD.Tax = (case when ' + convert(varchar, @TaxTypeID) + ' = 1 or ' + convert(varchar, @TaxTypeID) + ' = 3 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)           
  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc])' +
--  and cast(V.Locality as nvarchar) like (case ' + '''' + Cast(@Locality as nVarchar)  + ''''                    
--  + N' when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVArchar) + ''''                  
--  + N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + '''' + Cast('2' as nVarchar) + ''''                   
--  + N' else ' + '''' + N'%' + '''' + ' end ) + ' + '''' + N'%' + '''' + N'                  
' Group By #temp4.CatID      
)' + ''                  
Exec sp_ExecuteSQL @tempSQL                 

--Local Purchase Return Value and Tax Component Splitup
if @TaxSplitUp = 'Yes'
Begin
	if Exists(Select * From #tmpTaxType Where Type  = N'LBR') --and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') <> N'Exempt' and isNull(TaxPer,'') <> '')
	Begin
		Set @tempSQL = N'Alter Table #VatReport Add[VAT Total Purchase Return (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
		Set @tempSQL = N'Alter Table #VatReport Add[VAT Tax on Purchase Return (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
		
		
		Set @tempSQL = N'update #VATReport set [VAT Total Purchase Return (%c)] = (                  
		 select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))          
		 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items ,#temp4, Batch_Products bp 
		 where ARA.AdjustmentID = ARD.AdjustmentID                  
		  and ARD.Product_Code = Items.Product_Code 
		  and ARD.BatchCode = bp.Batch_Code
          and IsNull(bp.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + '  
		  and Items.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
		  and Items.CateGoryID = #temp4.LeafID      
		  and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
		  AND [Category Name] = #temp4.Parent      
		  and (isnull(ARA.Status,0) & 128) = 0                  
		  and ARA.AdjustmentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
		  + N' and (Case when ARD.Tax=0 then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else convert(nvarchar,convert(decimal(18,6),ARD.Tax)) end) = [Tax %]          
		  and V.VendorID = ARA.VendorID                  
		  and (          
		  ([Tax Desc] = ' + '''' + Cast('Exempt' as nVarchar) + '''' +  N'and ARD.Tax = 0) or           
		  (          
		   ARD.Tax = (case when ' + convert(varchar, @TaxTypeID) + ' = 1 or ' + convert(varchar, @TaxTypeID) + ' = 3 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)           
		     and [Tax Desc] = (Case when ARD.Tax=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)          
		  )          
		 ) ' + 
--         and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--                                when 'Outstation' then '2'
--                                else '%'
--          end ) + 
		' Group By #temp4.CatID
		)' + ''                  
		Exec sp_ExecuteSQL @tempSQL                 
	
	
	
		--Tax amount on Purchase Return                  
		Set @tempSQL = N'update #VATReport set [VAT Tax on Purchase Return (%c)] = (                  
		 select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))          
		 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items,#temp4, Batch_Products bp           
		 where ARA.AdjustmentID = ARD.AdjustmentID                  
		  and ARD.Product_Code = Items.Product_Code  
		  and ARD.BatchCode = bp.Batch_Code
          and IsNull(bp.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + ' 
		  and Items.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
		  and Items.CateGoryID = #temp4.LeafID      
		  and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
		  AND [Category Name] = #temp4.Parent      
		  and (isnull(ARA.Status,0) & 128) = 0                  
		  and ARA.AdjustmentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
		  + N' and convert(nvarchar,convert(decimal(18,6),ARD.Tax)) = [Tax %]   
		  and ARA.VendorID = V.VendorID                  
		  and ARD.Tax = (case when ' + convert(varchar, @TaxTypeID) + ' = 1 or ' + convert(varchar, @TaxTypeID) + ' = 3 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)           
		  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc]) ' + 
--         and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--                                when 'Outstation' then '2'
--                                else '%'
--          end ) + 
		' Group By #temp4.CatID
		)' + ''                  
		Exec sp_ExecuteSQL @tempSQL                 
		if @TaxTypeID = 1 or @TaxTypeID = 3 	
		Begin
			Delete From #tmpTaxComp
			Insert Into #tmpTaxComp 
			Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
			Where Type = N'LBR' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 1 group By Tax_Code, TaxComponent_Code

			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_PR] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_PR] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
			End
		End
	End
End

--CST Purchase Return Value and Tax Component Splitup
if @TaxSplitUp = 'Yes'
Begin
	if Exists(Select * From #tmpTaxType Where Type  = N'OBR') --and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') <> N'Exempt' and isNull(TaxPer,'') <> '')
	Begin

		Set @tempSQL = N'Alter Table #VatReport Add[CST Total Purchase Return (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 
		Set @tempSQL = N'Alter Table #VatReport Add[CST Tax on Purchase Return (%c)]  Decimal(18,6)'
		Exec sp_ExecuteSQL @tempSQL                 

		Set @tempSQL = N'update #VATReport set [CST Total Purchase Return (%c)] = (                  
		 select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))          
		 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items ,#temp4, Batch_Products bp             
		 where ARA.AdjustmentID = ARD.AdjustmentID                  
		  and ARD.Product_Code = Items.Product_Code          
		  and ARD.BatchCode = bp.Batch_Code
          and IsNull(bp.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + '  
		  and Items.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
		  and Items.CateGoryID = #temp4.LeafID     
		  and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
		  AND [Category Name] = #temp4.Parent      
		  and (isnull(ARA.Status,0) & 128) = 0                  
		  and ARA.AdjustmentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
		  + N' and (Case when ARD.Tax=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else convert(nvarchar,convert(decimal(18,6),ARD.Tax)) end) = [Tax %]          
		  and V.VendorID = ARA.VendorID                  
		  and (          
		  ([Tax Desc] = ' + '''' + Cast('Exempt' as nVarchar) + '''' +  N'and ARD.Tax = 0) or           
		  (          
		   ARD.Tax = (case when ' + convert(varchar, @TaxTypeID) + ' = 1 or ' + convert(varchar, @TaxTypeID) + ' = 3 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)           
		     and [Tax Desc] = (Case when ARD.Tax=0 then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)          
		  )          
		 )'+           
--         and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--                                when 'Outstation' then '2'
--                                else '%'
--          end ) + 
		' Group By #temp4.CatID
		)' + ''                  
		Exec sp_ExecuteSQL @tempSQL                 

		--Tax amount on Purchase Return                  
		Set @tempSQL = N'update #VATReport set [CST Tax on Purchase Return (%c)] = (                  
		 select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))          
		 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items,#temp4, Batch_Products bp          
		 where ARA.AdjustmentID = ARD.AdjustmentID                  
		  and ARD.Product_Code = Items.Product_Code   
		  and ARD.BatchCode = bp.Batch_Code
          and IsNull(bp.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + '        
		  and Items.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
		  and Items.CateGoryID = #temp4.LeafID      
		  and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
		  AND [Category Name] = #temp4.Parent      
		  and (isnull(ARA.Status,0) & 128) = 0                  
		  and ARA.AdjustmentDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
		  + N' and convert(nvarchar,convert(decimal(18,6),ARD.Tax)) = [Tax %]   
		  and ARA.VendorID = V.VendorID                  
		  and ARD.Tax = (case when ' + convert(varchar, @TaxTypeID) + ' = 1 or ' + convert(varchar, @TaxTypeID) + ' = 3 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)           
		  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc]) ' + 
--         and V.Locality like ''' + 
--         ( case @Locality when 'Local' then '1'
--                                when 'Outstation' then '2'
--                                else '%'
--          end ) + 
		' Group By #temp4.CatID
		)' + ''                  
		Exec sp_ExecuteSQL @tempSQL                 
		
		if @TaxTypeID = 2
		Begin
			Delete From #tmpTaxComp
			Insert Into #tmpTaxComp
			Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
			Where Type = N'OBR' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 0 group By Tax_Code, TaxComponent_Code

			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
			While @TC <> 0
			Begin
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_PR] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_PR] Decimal(18,6) '
				Exec sp_executesql @TempSql 
				Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
				Set @TC = 0
				Set @TCC = 0
				Set @TaxCompHead = ''
				Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
			End
		End
	End
End

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
 
Set @tempSQL = N'update #VATReport set [Total Sales (%c)] = (                  
select sum(IDt.Amount) - sum(case #I.[taxtype] ' 
+ N' when ' + '''' + Cast('LST' as nVArchar) + '''' + N' then isnull(IDt.STPayable,0)                  
when ' + '''' + Cast('CST' as nVarchar) + '''' + N' then isnull(IDT.CSTPayable,0)                  
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)          
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It,#temp4, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
where Idt.InvoiceID = IA.InvoiceID                  
and It.Product_Code = IDt.Product_Code '
-- ' and IsNull(C.Locality, 1) =  ' + Cast(@TaxTypeID As nVarchar) +   
+ ' and It.CategoryID = #temp4.LeafID        
and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
and (IA.Status & 192) = 0                  
and IA.InvoiceType in (1, 3)                  
and IDt.SalePrice <> 0                  
and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
--' and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
N' AND [Category Name] = #temp4.Parent      
and #I.InvoiceId = Ia.InvoiceId
and [Tax %] = (case when #I.taxtype = ''LST'' then          
     (case when IDt.TaxCode=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' 
+ N' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) End)          
      else           
     (case when IDt.TaxCode2=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N'          
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) End)           
    End)          
and [Tax Code] = (case when #I.taxtype = ''LST'' then 
	(Case When IDt.TaxCode = 0  Then -1 Else    IsNull(IDt.TaxID, 0) End)
    Else
	(Case When IDt.TaxCode2 = 0  Then -1 Else    IsNull(IDt.TaxID, 0) End)
    End)         
and IA.CustomerID = C.CustomerID                  
and (( #I.taxtype = ''LST'' and ([Tax Desc] = ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' or IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc]))) or          
( #I.taxtype = ''CST'' and ([Tax Desc] = ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' or IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]))))          
and [Tax Desc] = (Case [Tax Desc] when ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else (select Tax.Tax_Description from tax where tax_description = [Tax Desc]) end) ' +
--and cast(C.Locality as nvarchar) like (case ' + '''' + Cast(@Locality as nVarchar) + '''' + N'
--when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''
--+ N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + + '''' + Cast('2' as nVarchar) + ''''                   
--+ N' else ' + '''' +  N'%' + '''' + N' end) + ' + '''' + N'%'  + ''''                
+ N'Group By #temp4.Parent      
)' + ''

Exec Sp_ExecuteSQL @tempSQL               

 
--Tax on sales                  
Set @tempSQL = N' update #VATReport set [Tax on Sales (%c)] = (                  
select sum(case #I.[taxtype] '                   
+ N' when ' + '''' + Cast('LST' as nVarchar) + '''' + N' then isnull(IDt.STPayable,0)                  
when ' + '''' + Cast('CST' as nVarchar) + '''' + N' then isnull(IDT.CSTPayable,0)                  
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)                   
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It ,#temp4, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
where Idt.InvoiceID = IA.InvoiceID                  
and (IA.Status & 192) = 0                  
and It.Product_Code = IDt.Product_Code ' + 
-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +  
' and #I.InvoiceId = Ia.InvoiceId
and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
and It.CateGoryID = #temp4.LeafID      
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
AND [Category Name] = #temp4.Parent      
and IA.InvoiceType in (1, 3)                  
and IDt.SalePrice <> 0           
and TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
--' and IA.InvoiceDate between ' + '''' +Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                  
N' and [Tax %] = (case when #I.taxtype = ''LST'' then          
     convert(nvarchar,convert(decimal(18,6),IDt.TaxCode))           
      else           
     convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2))           
    End)          
and [Tax Code] = IsNull(IDt.TaxID, 0)        
and IA.CustomerID = C.CustomerID                  
and (( #I.taxtype = ''LST''  and IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc])) or          
( #I.taxtype = ''CST''  and IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc])))          
and [Tax Desc] = (select Tax.Tax_Description from tax where tax_description = [Tax Desc])' + 
--and cast(C.Locality as nvarchar) like (case ' + '''' + Cast(@Locality as nVarchar) + '''' + N'
--when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + ''''
--+ N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + + '''' + Cast('2' as nVarchar) + ''''                   
--+ N' else ' + '''' +  N'%' + '''' + N' end) + ' + '''' + N'%'  + ''''                
+ N'Group By #temp4.Parent      
)' + ''

Exec Sp_ExecuteSQL @tempSQL               

--Adds LST Tax Splitup
If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3
	Begin
		Delete From #tmpTaxComp
		Insert Into #tmpTaxComp 
		Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
		Where Type = N'LI' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 1 group By Tax_Code, TaxComponent_Code

		Set @TC = 0
		Set @TCC = 0
		Set @TaxCompHead = ''
		Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		While @TC <> 0
		Begin
			Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_Sales] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_Sales] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		End
	End
	if @TaxTypeID = 2
	Begin
		Delete From #tmpTaxComp
		Insert Into #tmpTaxComp 
		Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
		Where Type = N'OI' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 0 group By Tax_Code, TaxComponent_Code

		Set @TC = 0
		Set @TCC = 0
		Set @TaxCompHead = ''
		Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		While @TC <> 0
		Begin
			Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_Sales] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_Sales] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		End
	End
End

--Adds Retail Sales Column]
Set @tempSQL = N'Alter Table #VatReport Add[Total Retail Sales (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Retail Sales (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 

-- Update Total Retail Sales        
Set @tempSQL = N'update #VATReport set  [Total Retail Sales (%c)] = (                  
select sum(isnull(IDt.Amount,0)) - sum(isnull(IDt.STPayable,0))          
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt ON Idt.InvoiceID = IA.InvoiceID
Left Outer Join Customer C ON IA.CustomerID = C.CustomerID
Inner Join Items It ON It.Product_Code = IDt.Product_Code
Inner Join #temp4 ON It.CateGoryID = #temp4.LeafID
Inner Join tbl_mERP_TaxType TxzType ON TxzType.TaxID = ' + convert ( varchar, @TaxTypeID) + 
'Inner Join #InvoiceTaxType #I ON #I.InvoiceId = Ia.InvoiceId
where               
(IA.Status & 192) = 0                  
 ' + 
--' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) + 
' and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
      
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
AND [Category Name] = #temp4.Parent      
and IA.InvoiceType in (2)                  
and IDt.SalePrice <> 0' +                  

--' and IA.InvoiceDate between ' +'''' +  Cast(@FromDate as nVarchar) +'''' +  N' and ' + '''' + Cast(@ToDate as nVarchar) +'''' + + N'                 
' and (case when  IDt.TaxCode=0 then ' +''''+ Cast('Exempt' as nVarchar)+'''' + N' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end) = [Tax %]          
                  
and (Case ' + '''' +Cast(@Locality as nVarchar) +'''' +  + N' When '+  '''' + Cast('Outstation' as nVarchar)+'''' + N' Then 0 Else 1 End) = 1          
and IDt.TaxCode = (case when  IDt.TaxCode=0 then 0 else (select Tax.Percentage from tax where Tax_Description = [Tax Desc]) end)          
and [Tax Desc] = (case when  IDt.TaxCode=0 then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else (select Tax.Tax_Description from tax where Tax_Description = [Tax Desc]) end)          
and [Tax Code] = (Case When IDt.TaxCode=0 Then -1 Else IsNUll(IDt.TaxID, 0) End)        
and IDt.Amount>-1          
Group By #temp4.CatID      
)' + ''
Exec sp_ExecuteSQL @tempSQL                 

-- Update Tax Retail Sales                   
Set @tempSQL = N'update #VATReport set [Tax on Retail Sales (%c)] = (                  
select sum(isnull(IDt.STPayable,0))          
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt ON Idt.InvoiceID = IA.InvoiceID
Left Outer Join Customer C ON IA.CustomerID = C.CustomerID
Inner Join Tax ON IDt.TaxCode = Tax.Percentage
Inner Join Items It ON It.Product_Code = IDt.Product_Code
Inner Join #temp4 ON It.CateGoryID = #temp4.LeafID
Inner Join tbl_mERP_TaxType TxzType ON TxzType.TaxID = '  + convert ( varchar, @TaxTypeID) + '
Inner Join #InvoiceTaxType #I ON #I.InvoiceId = Ia.InvoiceId
where                   
 ' + 
--' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +  
'It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
      
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
And [Category Name] = #temp4.Parent      
and (IA.Status & 192) = 0                  
and IA.InvoiceType in (2)                  
and IDt.SalePrice <> 0 '
+ 
--' and IA.InvoiceDate between' + '''' + Cast(@FromDate as nVarchar) + '''' + N' and' + '''' + Cast(@ToDate as nVarchar) +'''' +                  
' and convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) = [Tax %]          
and (Case' +'''' + Cast(@Locality as nVarchar) +'''' +N' When ' + '''' + CAST('Outstation' as nVarchar)+'''' + N' Then 0 Else 1 End) = 1          
           
and Tax.Tax_Description = [Tax Desc]          
and [Tax Code] = IsNull(IDt.TaxID, 0)        
and IDt.Amount>-1          
Group By #temp4.CatID      
)' + ''          
Exec sp_ExecuteSQL @tempSQL                    

--Tax splitup for RetailInvoice
If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3
	Begin
		Delete From #tmpTaxComp
		Insert Into #tmpTaxComp 
		Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
		Where Type = N'RI' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 1 group By Tax_Code, TaxComponent_Code

		Set @TC = 0
		Set @TCC = 0
		Set @TaxCompHead = ''
		Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		While @TC <> 0
		Begin
			Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_RI] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_RI] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		End
	End
End

--Total Sales return saleable amount                  
Set @tempSQL = N'Alter Table #VatReport Add[Sales Return Saleable (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Sales Return Saleable (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 

Set @tempSQL = N'update #VATReport set [Sales Return Saleable (%c)] = (                  
select sum(isnull(IDt.Amount, 0)) - sum(case #I.[taxtype] '
+ N' when ' + '''' + Cast('LST' as nVarchar) + '''' + N' then isnull(IDt.STPayable,0)            
when ' + '''' + Cast('CST' as nVarchar) + '''' + N' then isnull(IDT.CSTPayable,0)                  
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)          
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It,#temp4, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
where Idt.InvoiceID = IA.InvoiceID                  
and (IA.Status & 192) = 0  
and It.Product_Code = IDt.Product_Code ' + 
--' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +  
' and #I.InvoiceId = Ia.InvoiceId
and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
and It.CateGoryID = #temp4.LeafID      
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
And [Category Name] = #temp4.Parent      
and (IA.Status & 32) = 0          
and IA.InvoiceType = 4                   
and IDt.SalePrice <> 0                  
and TxzType.TaxID = ' +  + convert ( varchar, @TaxTypeID) + 
--' and IA.InvoiceDate between ' + '''' + Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) +''''                 
 N' and [Tax %] = (case when #I.taxtype = ''LST'' then          
     (case when IDt.TaxCode=0  then ' + '''' + CAST('Exempt' As nVarchar) + '''' +N'
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) End)          
      else   
     (case when IDt.TaxCode2=0 then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N'
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) End)          
    End)          
and [Tax Code] = (case when #I.taxtype = ''LST'' then 
	(Case When IDt.TaxCode = 0  Then -1 Else    IsNull(IDt.TaxID, 0) End)
    Else
	(Case When IDt.TaxCode2 = 0  Then -1 Else    IsNull(IDt.TaxID, 0) End)
    End)         
and IA.CustomerID = C.CustomerID                  
and (( #I.taxtype = ''LST''  and ([Tax Desc] = ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' or IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc]))) or          
( #I.taxtype = ''CST''  and ([Tax Desc] = ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' or IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]))))          
and [Tax Desc] = (Case [Tax Desc] when ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else (select Tax.Tax_Description from tax where tax_description = [Tax Desc]) end) ' + 
--and cast(C.Locality as nvarchar) like (case '+ '''' + CasT(@Locality as nVarchar) + '''' + N'
--when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + '''' +                  
--N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + '''' + Cast('2' as nVarchar) + ''''                   
--+ N' else ' +'''' +  Cast('%' as nVarchar) + '''' + N' end) '+ N'+' + ''''+  Cast('%' as nVarchar)+ ''''+ N'
 ' Group By #temp4.CatID      
)' + ''                  

Exec Sp_ExecuteSQL @TEMPSQL 

--tax amount on sales return saleable                  
Set @tempSQL = N'update #VATReport set [Tax on Sales Return Saleable (%c)] = (                  
select sum(case #I.[taxtype]'
+ N' when ' + '''' + Cast('LST' as nVarchar) + '''' + N' then ' + N' isnull(IDt.STPayable,0)                  
when ' + '''' + Cast('CST' as nVarchar) + '''' + N' then ' + N' isnull(IDT.CSTPayable,0)                  
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C ,Items It,#temp4, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
where Idt.InvoiceID = IA.InvoiceID       
and It.Product_Code = IDt.Product_Code ' + 
--' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +   
' and #I.InvoiceId = Ia.InvoiceId
and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
and It.CateGoryID = #temp4.LeafID      
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
and [Category Name] = #temp4.Parent      
and (IA.Status & 192) = 0                   
and (IA.Status & 32) = 0                   
and IA.InvoiceType = 4                   
and IDt.SalePrice <> 0                  
and TxzType.TaxID = ' +  + convert ( varchar, @TaxTypeID) + 
--' and IA.InvoiceDate between ' + '''' + Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' +Cast(@ToDate  as nVarchar) +  '''' + 
N' and [Tax %] = (case when #I.taxtype = ''LST'' then          
     convert(nvarchar,convert(decimal(18,6),IDt.TaxCode))          
      else           
     convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2))          
    End)          
and [Tax Code] = IsNull(IDt.TaxID, 0)        
and IA.CustomerID = C.CustomerID                  
and (( #I.taxtype = ''LST'' and IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc])) or          
 ( #I.taxtype = ''CST''  and IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc])))          
and [Tax Desc] = (select Tax.Tax_Description from tax where tax_description = [Tax Desc]) ' + 
--and cast(C.Locality as nvarchar) like (case '+ '''' + CasT(@Locality as nVarchar) + '''' + N'
--when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + '''' +                  
--N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + '''' + Cast('2' as nVarchar) + ''''                   
--+ N' else ' +'''' +  Cast('%' as nVarchar) + '''' + N' end) '+ N'+' + ''''+  Cast('%' as nVarchar)+ ''''+ N'
' Group By #temp4.CatID      
)' + ''                  

EXEC Sp_ExecuteSQL @TEMPSQL 

---TaxSplitup For SalesReturn Saleable
If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3
	Begin
		Delete From #tmpTaxComp
		Insert Into #tmpTaxComp
		Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
		Where Type = N'LSRS' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 1 group By Tax_Code, TaxComponent_Code

		Set @TC = 0
		Set @TCC = 0
		Set @TaxCompHead = ''
		Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		While @TC <> 0
		Begin
			Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_SRS] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_SRS] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		End
	End
	if @TaxTypeID = 2
	Begin
		Delete From #tmpTaxComp
		Insert Into #tmpTaxComp
		Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
		Where Type = N'OSRS' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 0 group By Tax_Code, TaxComponent_Code

		Set @TC = 0
		Set @TCC = 0
		Set @TaxCompHead = ''
		Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		While @TC <> 0
		Begin
			Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_SRS] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_SRS] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		End
	End
End

Set @tempSQL = N'Alter Table #VatReport Add[Sales Return Damages (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Sales Return Damages (%c)] Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 

--total Sales Return Damages                  
Set @tempSQL = N' update #VATReport set [Sales Return Damages (%c)] = (                  
select sum(IDt.Amount)  - sum(case #I.[taxtype] 
when ' + '''' + Cast('LST ' as nVarchar) + '''' + N' then isnull(IDt.STPayable,0)                  
when ' + '''' + Cast('CST' as nVarchar) + '''' + N'then isnull(IDT.CSTPayable,0)                  
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)          
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It ,#temp4, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
where Idt.InvoiceID = IA.InvoiceID            
and It.Product_Code = IDt.Product_Code ' + 
--' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) + 
' and #I.InvoiceId = Ia.InvoiceId
and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
and It.CateGoryID = #temp4.LeafID      
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
and [Category Name] = #temp4.Parent      
and (IA.Status & 192) = 0                  
and (IA.Status & 32) <> 0                   
and IA.InvoiceType = 4                   
and IDt.SalePrice <> 0                  
and TxzType.TaxID = ' +  + convert ( varchar, @TaxTypeID) + 
--' and IA.InvoiceDate between ' + '''' + Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''          
  N' and [Tax %] = (case when #I.taxtype = ''LST'' then          
     (case when IDt.TaxCode=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N'          
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) End)          
      else           
     (case when IDt.TaxCode2=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N'          
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) End)           
    End)          
and [Tax Code] = (case when #I.taxtype = ''LST'' then 
	(Case When IDt.TaxCode = 0  Then -1 Else    IsNull(IDt.TaxID, 0) End)
    Else
	(Case When IDt.TaxCode2 = 0  Then -1 Else    IsNull(IDt.TaxID, 0) End)
    End)         
and IA.CustomerID = C.CustomerID                  
and (( #I.taxtype = ''LST'' and ([Tax Desc] = ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' or IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc]))) or          
( #I.taxtype = ''CST'' and ([Tax Desc] = ' + '''' + Cast('Exempt' as nVarchar) + '''' +  N' or IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]))))          
and [Tax Desc] = (Case [Tax Desc] when ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' then ' +'''' + Cast('Exempt' as nVarchar ) + '''' + N' else (select Tax.Tax_Description from tax where tax_description = [Tax Desc]) end) ' + 
--and cast(C.Locality as nvarchar) like (case '+ '''' + Cast(@Locality as nVarchar) + '''' + N'
--when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + '''' +                  
--N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + '''' + Cast('2' as nVarchar) + ''''                   
--+ N' else ' +'''' +  Cast('%' as nVarchar) + '''' + N' end) '+ N'+' + ''''+  Cast('%' as nVarchar)+ ''''+ N'
' Group By #temp4.CatID      
)' + ''                  
EXEC SP_EXECUTESQL @TEMPSQL

--Tax amount on sales return damages                  
Set @tempSQL = N'update #VATReport set [Tax on Sales Return Damages (%c)] = (                  
select sum(case #I.[taxtype] 
when ' + '''' + CAST('LST' As nVarchar ) + '''' + N' then isnull(IDt.STPayable,0)                  
when ' + '''' + Cast('CST' as nVarchar)+ '''' + N' then isnull(IDT.CSTPayable,0)                  
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)                   
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It,#temp4, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
where Idt.InvoiceID = IA.InvoiceID                  
and It.Product_Code = IDt.Product_Code ' + 
--' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +   
' and #I.InvoiceId = Ia.InvoiceId
and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
and It.CateGoryID = #temp4.LeafID      
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
and [Category Name] = #temp4.Parent      
and (IA.Status & 192) = 0                   
and (IA.Status & 32) <> 0                   
and IA.InvoiceType = 4          
and IDt.SalePrice <> 0                  
and TxzType.TaxID = ' +  + convert ( varchar, @TaxTypeID) + 
--' and IA.InvoiceDate between ' + '''' + Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                 
 N' and [Tax %] = (case when #I.taxtype = ''LST'' then          
     (case when IDt.TaxCode=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N'
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) End)          
      else           
     (case when IDt.TaxCode2=0 then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N'          
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) End)           
    End)          
and [Tax Code] = IsNull(IDt.TaxID, 0)        
and IA.CustomerID = C.CustomerID                  
and (( #I.taxtype = ''LST'' and IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc])) or          
 ( #I.taxtype = ''CST''  and IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc])))          
and [Tax Desc] = (select Tax.Tax_Description from tax where tax_description = [Tax Desc]) ' + 
--and cast(C.Locality as nvarchar) like (case '+ '''' + Cast(@Locality as nVarchar) + '''' + N'
--when ' + '''' + Cast('Local' as nVarchar) + '''' + N' then ' + '''' + Cast('1' as nVarchar) + '''' +                  
--N' when ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' then ' + '''' + Cast('2' as nVarchar) + ''''                   
--+ N' else ' +'''' +  Cast('%' as nVarchar) + '''' + N' end) '+ N'+ ' + ''''+  Cast('%' as nVarchar)+ ''''+ N'
' Group By #temp4.CatID      
)' + ''                  
exec sp_executeSQL @tempsql

If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3
	Begin
		Delete From #tmpTaxComp
		Insert Into #tmpTaxComp
		Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
		Where Type = N'LSRD' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 1 group By Tax_Code, TaxComponent_Code

		Set @TC = 0
		Set @TCC = 0
		Set @TaxCompHead = ''
		Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		While @TC <> 0
		Begin
			Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_SRD] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_SRD] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		End
	End
	if @TaxTypeID = 2
	Begin
		Delete From #tmpTaxComp
		Insert Into #tmpTaxComp 
		Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
		Where Type = N'OSRD' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 0 group By Tax_Code, TaxComponent_Code

		Set @TC = 0
		Set @TCC = 0
		Set @TaxCompHead = ''
		Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		While @TC <> 0
		Begin
			Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_SRD] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_SRD] Decimal(18,6) '
			Exec sp_executesql @TempSql
			Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		End
	End
End

-- Update Total Retail Sales Return          
Set @tempSQL = N'Alter Table #VatReport Add[Total Retail Sales Return (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax on Retail Sales Return (%c)] Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 

Set @tempSQL = N'update #VATReport set  [Total Retail Sales Return (%c)] = (                  
select abs(sum(isnull(IDt.Amount,0)) - sum(isnull(IDt.STPayable,0)))          
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt ON Idt.InvoiceID = IA.InvoiceID
Left Outer Join Customer C ON IA.CustomerID = C.CustomerID
Inner Join Items It ON It.Product_Code = IDt.Product_Code
Inner Join #temp4 ON It.CateGoryID = #temp4.LeafID
Inner Join tbl_mERP_TaxType TxzType ON TxzType.TaxID = ' +  + convert ( varchar, @TaxTypeID) + '
Inner Join #InvoiceTaxType #I ON #I.InvoiceId = Ia.InvoiceId
where 
(IA.Status & 192) = 0                  
 ' + 
-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +   
'
and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
      
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
and [Category Name] = #temp4.Parent
and IA.InvoiceType in (5,6)                  
and IDt.SalePrice <> 0     '             

--' and IA.InvoiceDate between ' + '''' + Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                 
+ ' and (case when  IDt.TaxCode=0 then' + '''' + Cast('Exempt' as nVarchar)+ '''' 
+ N'else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end) = [Tax %]          
' + 
--and (Case ' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) + '''' +
--+ N' Then 0 Else 1 End) = 1          
' and IDt.TaxCode = (case when  IDt.TaxCode=0 then 0 else (select Tax.Percentage from tax where Tax_Description = [Tax Desc]) end)          
and [Tax Desc] = (case when  IDt.TaxCode=0 then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else (select Tax.Tax_Description from tax where Tax_Description = [Tax Desc]) end)          
and [Tax Code] = (Case When IDt.TaxCode=0 then -1 Else IsNull(IDt.TaxID, 0) End)        
Group By #temp4.CatID      
)' + ''

Exec sp_ExecuteSQL @tempSQL          
                  
-- Update Tax Retail Sales Return          
Set @tempSQL = N'update #VATReport set [Tax on Retail Sales Return (%c)] = (                  
select  abs(sum(isnull(IDt.STPayable,0)))          
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt ON Idt.InvoiceID = IA.InvoiceID
Left Outer Join Customer C ON IA.CustomerID = C.CustomerID 
Inner Join Tax ON IDt.TaxCode = Tax.Percentage
Inner Join Items It ON It.Product_Code = IDt.Product_Code
Inner Join #temp4 ON It.CateGoryID = #temp4.LeafID
Inner Join tbl_mERP_TaxType TxzType ON TxzType.TaxID = ' +  + convert ( varchar, @TaxTypeID) + '
Inner Join  #InvoiceTaxType #I ON #I.InvoiceId = Ia.InvoiceId
where 
(IA.Status & 192) = 0                  
 ' + 
-- ' and IsNull(C.Locality, 1) = ' + Cast(@TaxTypeID As nVarchar) +   
'
and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)        
      
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
and [Category Name] = #temp4.Parent      
and IA.InvoiceType in (5,6)                  
and IDt.SalePrice <> 0                  
'
--' and IA.InvoiceDate between ' + '''' + Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar) + ''''                 
+ ' and (case when  IDt.TaxCode=0 then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end) = [Tax %]          
         
and (Case ' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' Then 0 Else 1 End) = 1          
           
and [Tax Desc] = Tax.Tax_Description          
and [Tax Code] = IsNull(IDt.TaxID, 0)        
--and IDt.Amount<0          
Group By #temp4.CatID      
) ' + ''         

Exec sp_ExecuteSQL @TEMPsql          

--TaxSplit up For RetailInvoiceReturn
If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3
	Begin
		Delete From #tmpTaxComp
		Insert Into #tmpTaxComp 
		Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
		Where Type = N'RIR' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 1 group By Tax_Code, TaxComponent_Code

		Set @TC = 0
		Set @TCC = 0
		Set @TaxCompHead = ''
		Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		While @TC <> 0
		Begin
			Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_RIR] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_RIR] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
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

--StockTransferIn
Set @tempSQL = N'Alter Table #VatReport Add[Total Tran In (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax On Tran In (%c)] Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 

Set @tempSQL = N'update #VATReport set [Total Tran In (%c)] = (
Select sum(SD.Amount) 
From StockTransferInAbstract SA,StockTransferInDetail SD,Items It,#temp4
Where
(SA.Status & 192)=0  
and SA.DocumentDate Between ' + '''' + Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar)  + ''''
+ N' and SA.Docserial = SD.Docserial
and SD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and SD.Product_Code = It.Product_Code         
and IsNull(SA.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + ' 
and It.CategoryID = #temp4.LeafID               
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
and [Category Name] = #temp4.Parent      
and (case when SD.TaxSuffered=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else convert(nvarchar,convert(decimal(18,6),SD.TaxSuffered)) end) = [Tax %]          
and (          
  ([Tax Desc] = ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' and SD.TaxSuffered = 0) or           
  (          
   SD.TaxSuffered = (select (Case IsNull(SA.TaxType,1) When 2 Then Tax.CST_Percentage Else Tax.Percentage End) from tax where tax_description = [Tax Desc])           
   and [Tax Desc] = (Case when SD.TaxSuffered=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)          
  )          
 )          
and [Tax Code] = (Case When SD.TaxSuffered = 0 Then -1 Else SD.TaxCode End) ' + 
-- 'and (Case ' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' Then 0 Else 1 End) = 1 ' +         
' Group By #temp4.Parent       
)' + ''
Exec sp_ExecuteSQL @tempSQL


Set @tempSQL = N'update #VATReport set [Tax On Tran In (%c)] = (
Select sum(SD.TaxAmount) 
From StockTransferInAbstract SA,StockTransferInDetail SD,Items It,#temp4
Where
(SA.Status & 192)=0  
and SA.DocumentDate Between ' + '''' + Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar)  + ''''
+ N' and SA.Docserial = SD.Docserial
and SD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and SD.Product_Code = It.Product_Code         
and IsNull(SA.TaxType, 1) = ' + Cast(@TaxTypeID As nVarchar) + ' 
and It.CategoryID = #temp4.LeafID               
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
and [Category Name] = #temp4.Parent      
and  convert(nvarchar,convert(decimal(18,6),SD.TaxSuffered))  = [Tax %]          
and SD.TaxSuffered = (select (Case IsNull(SA.TaxType,1) When 2 Then Tax.CST_Percentage Else Tax.Percentage End) from tax where tax_description = [Tax Desc])           
and [Tax Desc] =  (select Tax_Description from Tax where Tax_Description = [Tax Desc]) 
and [Tax Code] = SD.TaxCode ' + 
--' and (Case ' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' Then 0 Else 1 End) = 1 ' + 
' Group By #temp4.Parent       
)' + ''
Exec sp_ExecuteSQL @tempSQL

If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3
	Begin
		Delete From #tmpTaxComp
		Insert Into #tmpTaxComp
		Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
		Where Type = N'TI' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 1 group By Tax_Code, TaxComponent_Code

		Set @TC = 0
		Set @TCC = 0
		Set @TaxCompHead = ''
		Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		While @TC <> 0
		Begin
			Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_TI] Decimal(18,6)'
			Exec sp_executesql @TempSql 
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_TI] Decimal(18,6)'
			Exec sp_executesql @TempSql 
			Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		End
	End
End

--StockTransferOut

Set @tempSQL = N'Alter Table #VatReport Add[Total Tran Out (%c)]  Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 
Set @tempSQL = N'Alter Table #VatReport Add[Tax On Tran Out (%c)] Decimal(18,6)'
Exec sp_ExecuteSQL @tempSQL                 

Set @tempSQL = N'update #vatReport set [Total Tran Out (%c)]  = (
Select Sum(Amount)
From StockTransferOutAbstract SA,StockTransferOutDetail SD,Items It,#temp4, Batch_Products bp,  
    ( select min(tax_code) tax_code, percentage, 1 taxtype, min(Tax_Description) Tax_Description from Tax group by percentage 
        union 
      select min(tax_code) tax_code, cst_percentage percentage, 2 taxtype, min(Tax_Description) Tax_Description from Tax group by cst_percentage ) tax 
Where
 (isnull(SA.Status,0) & 192 )  = 0  
and SA.DocumentDate Between ' + '''' + Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar)  + ''''
+ N' and SA.Docserial = SD.Docserial
--and SD.Taxsuffered  > 0 
and SD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and SD.Product_Code = It.Product_Code         
and sd.Batch_Code = bp.Batch_Code 
and IsNull(bp.TaxType, 1) =  ' + Cast(@TaxTypeID As nVarchar) + '  
and It.CategoryID = #temp4.LeafID               
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
and [Category Name] = #temp4.Parent      
and [Tax %] = 
     (case when SD.TaxSuffered=0  then ' + '''' + Cast('Exempt' as nVarchar) + '''' + N'          
     else convert(nvarchar,convert(decimal(18,6),SD.TaxSuffered)) End)          
and ( SD.TaxSuffered = tax.percentage and 
	(Case when (IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3) then 1 Else 2 End )= tax.taxtype ) 
and [Tax Code] = (Case When SD.TaxSuffered = 0 Then -1 Else tax.Tax_Code  End)
and ([Tax Desc] = ' + '''' + Cast('Exempt' as nVarchar) + '''' + N'
 or  SD.TaxSuffered  = tax.Percentage )
and [Tax Desc] = (Case [Tax Desc] when ' + '''' + Cast('Exempt' as nVarchar) + '''' + N' then ' + '''' + 
Cast('Exempt' as nVarchar) + '''' + N' else tax.Tax_Description end) ' + 
-- ' and (Case' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) + '''' + N' Then 0 Else 1 End) = 1 ' + 
' Group By #temp4.Parent
) ' + ''

Exec sp_ExecuteSQL @TEMPsql      


Set @tempSQL = N'update #vatReport set [Tax On Tran Out (%c)] = (
Select Sum(SD.TaxAmount)
From StockTransferOutAbstract SA,StockTransferOutDetail SD,Items It,#temp4, Batch_Products bp,  
    ( select min(tax_code) tax_code, percentage, 1 taxtype, min(Tax_Description) Tax_Description from Tax group by percentage 
        union 
      select min(tax_code) tax_code, cst_percentage percentage, 2 taxtype, min(Tax_Description) Tax_Description from Tax group by cst_percentage ) tax 
Where
(isnull(SA.Status,0) & 192 )  = 0  
and SA.DocumentDate Between ' + '''' + Cast(@FromDate as nVarchar) + '''' + N' and ' + '''' + Cast(@ToDate as nVarchar)  + '''' 
+ N' and SA.Docserial = SD.Docserial
--and SD.Taxsuffered  > 0 
and SD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and SD.Product_Code = It.Product_Code         
and sd.Batch_Code = bp.Batch_Code 
and IsNull(bp.TaxType, 1) =  ' + Cast(@TaxTypeID As nVarchar) + '  
and It.CategoryID = #temp4.LeafID               
and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
and [Category Name] = #temp4.Parent      
and [Tax %] = 
     ( convert(nvarchar,convert(decimal(18,6),SD.TaxSuffered)))          
and ( SD.TaxSuffered = tax.percentage and 
	(Case when (IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3) then 1 Else 2 End )= tax.taxtype ) 
and [Tax Code] = tax.Tax_Code
and (SD.TaxSuffered =  tax.Percentage )
and [Tax Desc] =  tax.Tax_Description ' + 
-- ' and (Case ' + '''' + Cast(@Locality as nVarchar) + '''' + N' When ' + '''' + Cast('Outstation' as nVarchar) + '''' +  N'Then 0 Else 1 End) = 1 ' + 
' Group By #temp4.Parent
)' + ''
Exec sp_ExecuteSQL @TEMPsql      

If @TaxSplitUp = 'Yes'
Begin
	if @TaxTypeID = 1 or @TaxTypeID = 3
	Begin
		Delete From #tmpTaxComp
		Insert Into #tmpTaxComp
		Select Tax_Code, TaxComponent_Code From TaxComponents Where Tax_Code In( Select TaxCode From #tmpTaxType 
		Where Type = N'TO' and isNull(TaxPer,'') <> N'Exempt') And LST_Flag = 1 group By Tax_Code, TaxComponent_Code

		Set @TC = 0
		Set @TCC = 0
		Set @TaxCompHead = ''
		Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		While @TC <> 0
		Begin
			Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TC, @TCC)
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax %_TO] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Set @tempSQL = N'Alter Table #VatReport Add[' + @TaxCompHead + N' Tax (%c)_TO] Decimal(18,6) '
			Exec sp_executesql @TempSql 
			Delete From #tmpTaxComp Where TaxCode = @TC And TaxCompCode = @TCC
			Set @TC = 0
			Set @TCC = 0
			Set @TaxCompHead = ''
			Select Top 1 @TC = TaxCode, @TCC = TaxCompCode From #tmpTaxComp
		End
	End
End

If @TaxSplitUp = 'Yes' 
Begin
	Declare CurVatReport Cursor For
	Select [Category Name],[Tax Code],[Tax %],[Tax Desc] From #VatReport
	Open CurVatReport
	Fetch Next From CurVatReport Into @CategoryName ,@TaxCode,@TaxPer,@TaxDesc
	While @@Fetch_Status = 0
	Begin
		if @TaxTypeID = 1 or @TaxTypeID = 3
		Begin	
			Insert Into #tmpComp Select TaxComponent_Code,Tax_Percentage,Sp_Percentage From TaxComponents Where LST_Flag = 1 And Tax_Code = @TaxCode
			Select [ID] = Identity(Int,1,1),Comp_Code,Comp_Per,CompSP_Per Into #tmpComp1 From #tmpComp
			Select @Count = Count(*) From #tmpComp1
			Set @i =1 
			While @Count >= @i
			Begin
				Select @CompCode  =  Comp_Code , @CompPer = Comp_Per , @CompSP_Per  = CompSP_Per  From  #tmpComp1 Where [ID] = @i				
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TaxCode, @CompCode)				
				--Purchase 
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'LB' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_Purchase] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Category Name] = ' +''''+ Cast(@CategoryName as nVarchar) +''''+
					+ N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' +
					N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
					exec sp_executesql  @tempSQL
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax (%c)_Purchase] = ( Case ' + '''' + Cast(@CompSP_Per as nVarchar) + '''' + N' When ''0'' Then  ''0'' 
					else ' + N' IsNull([VAT Tax on Purchase (%c)],0)'+ N' *  ' +
 					Cast(@CompSP_Per as nVarchar)+ N' / ' + N'[Tax %]  '
					+ N' end) Where [Tax %] = ' + ''''+ Cast(@TaxPer as nVarchar) + '''' + N' and [Tax Desc] =  '  +''''+ Cast(@TaxDesc as nVarchar(250))
					+ '''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' + '''' + Cast(@CategoryName as nVarchar) + '''' +  ''
					exec sp_executesql  @tempSQL
				End

				--Purchase Return
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'LBR' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_PR] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Category Name] = ' +''''+ Cast(@CategoryName as nVarchar) +''''+
					+ N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' +
					N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
					exec sp_executesql @tempSQL
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax (%c)_PR] = 
					( Case ' + '''' + Cast(@CompSP_Per as nVarchar) + '''' + N' When ''0'' Then  ''0'' else ' 
					+ N' IsNull([VAT Tax On Purchase Return (%c)],0)'+ N' * ' +
 					Cast(@CompSP_Per as nVarchar) + N'/[Tax %]'
					+ N' end) Where [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar)+ '''' + N' and [Tax Desc] =  '  +''''+ Cast(@TaxDesc as nVarchar(250))
					+'''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' + '''' + Cast(@CategoryName as nVarchar) + '''' +  ''
					exec sp_executesql  @tempSQL
				end 

				--Sales
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'LI' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
				Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_Sales] = ' 
				+ Cast(@CompPer as nVarchar) + N'Where [Category Name] = ' +''''+ Cast(@CategoryName as nVarchar) +''''+
				+ N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar)+ '''' +
				 N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
				exec sp_executesql  @tempSQL

				Set @tempSql = N'Update #VatReport Set [' + @TaxCompHead + N' Tax (%c)_Sales] = (Select 
					isNull((Select Sum(Tax_Value) from InvoiceAbstract IA, Customer C, Items It ,#temp4,
					#tempTaxComp TaxComp where TaxComp.InvoiceID = IA.InvoiceID and It.product_code = TaxComp.product_code 
					and IA.InvoiceDate between ' + ''''+ cast(@FromDate as nVarchar) +'''' + N' and' + ''''+
					Cast(@ToDate as nVarchar)+'''' + N'and (IA.Status & 192) = 0 and TaxComp.Tax_Code = ' + Cast(@TaxCode as nVarchar) 
					+ N' and Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' 
					and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) 
					and It.CateGoryID = #temp4.LeafID and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
					and  #temp4.Parent = ' +''''+ Cast(@CategoryName as nVarchar)+'''' + N' and IA.InvoiceType in (1, 3) and TaxComp.Tax_Value <> 0  
					and IA.CustomerID = C.CustomerID Group By #temp4.CatID ),0))
					Where [Tax %] = ' + '''' +Cast(@TaxPer as nVarchar) + '''' + N' and [Tax Desc] =  '  +''''+ Cast(@TaxDesc as nVarchar(250))
					+'''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' + '''' + Cast(@CategoryName as nVarchar) + '''' +  ''


				exec sp_executesql  @tempSQL
				End
				

				--SalesReturn Saleable
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'LSRS' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
				Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_SRS] = ' 
				+ Cast(@CompPer as nVarchar) + N'Where [Category Name] = ' +''''+ Cast(@CategoryName as nVarchar) +''''+
				+ N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' +
				 N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
				exec sp_executesql  @tempSQL

				Set @tempSql = N'Update #VatReport Set [' + @TaxCompHead + N' Tax (%c)_SRS] = (Select
					isNull((Select Sum(Tax_Value) from InvoiceAbstract IA, Customer C, Items It, #temp4,
					#tempTaxComp TaxComp where TaxComp.InvoiceID = IA.InvoiceID 
					and It.product_code = TaxComp.product_code and IA.InvoiceDate between ' + ''''+ cast(@FromDate as nVarchar) +'''' + N' and' + ''''+
					Cast(@ToDate as nVarchar)+'''' + N' and (IA.Status & 192) = 0 and (IA.Status & 32) = 0  and TaxComp.Tax_Code = ' + Cast(@TaxCode as nVarchar) 
					+ N' and Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' 
					and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) 
					and It.CateGoryID = #temp4.LeafID and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
					and #temp4.Parent = ' +''''+ Cast(@CategoryName as nVarchar)+'''' + N' and IA.InvoiceType in (4) and TaxComp.Tax_Value <> 0  
					and IA.CustomerID = C.CustomerID Group By #temp4.CatID ),0))
					Where [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' + N' and [Tax Desc] =  '  +''''+ Cast(@TaxDesc as nVarchar(250))
					+'''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' + '''' + Cast(@CategoryName as nVarchar) + '''' +  ''
                
				exec sp_executesql  @tempSQL
				End

				--SalesReturn Damage
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'LSRD' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
				Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_SRD] = ' 
				+ Cast(@CompPer as nVarchar) + N'Where [Category Name] = ' +''''+ Cast(@CategoryName as nVarchar) +''''+
				+ N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) +
				 N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
				exec sp_executesql  @tempSQL

				Set @tempSql = N'Update #VatReport Set [' + @TaxCompHead + N' Tax (%c)_SRD] = (Select 
					isNull((Select Sum(Tax_Value) from InvoiceAbstract IA, Customer C, Items It, #temp4,
					#tempTaxComp TaxComp where TaxComp.InvoiceID = IA.InvoiceID 
					and It.product_code = TaxComp.product_code and IA.InvoiceDate between ' + ''''+ cast(@FromDate as nVarchar) +'''' + N' and' + ''''+
					Cast(@ToDate as nVarchar)+'''' + N' and (IA.Status & 192) = 0 and (IA.Status & 32) <> 0  and TaxComp.Tax_Code = ' + Cast(@TaxCode as nVarchar) 
					+ N' and Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' 
					and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) 
					and It.CateGoryID = #temp4.LeafID and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
					and #temp4.Parent = ' +''''+ Cast(@CategoryName as nVarchar)+'''' + N' and IA.InvoiceType in (4) and TaxComp.Tax_Value <> 0  
					and IA.CustomerID = C.CustomerID Group By #temp4.CatID ),0))
					Where [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' + N' and [Tax Desc] =  '  +''''+ Cast(@TaxDesc as nVarchar(250))
					+'''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' + '''' + Cast(@CategoryName as nVarchar) + '''' +  ''
                
				exec sp_executesql  @tempSQL
				End


				--Retail Invoice
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'RI' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_RI] = ' 
					+ Cast(@CompPer as nVarchar) + N'Where [Category Name] = ' +''''+ Cast(@CategoryName as nVarchar) +''''+
					+ N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' +
					 N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
					exec sp_executesql  @tempSQL

				Set @tempSql = N'Update #VatReport Set [' + @TaxCompHead + N' Tax (%c)_RI] = (Select 
					isNull((Select Sum(Tax_Value) from InvoiceAbstract IA
					Left Outer Join Customer C IA.CustomerID = C.CustomerID
					Inner Join #tempTaxComp TaxComp ON TaxComp.InvoiceID = IA.InvoiceID
					Inner Join Items It ON It.product_code = TaxComp.product_code
					Inner Join #temp4 ON It.CateGoryID = #temp4.LeafID					
					where  
					IA.InvoiceDate between ' + ''''+ cast(@FromDate as nVarchar) +'''' + N' and' + ''''+
					Cast(@ToDate as nVarchar)+'''' + N' and (IA.Status & 192) = 0 and TaxComp.Tax_Code = ' + Cast(@TaxCode as nVarchar) 
					+ N' and Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' 
					and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) 
					 and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
					and  #temp4.Parent = ' +''''+ Cast(@CategoryName as nVarchar)+'''' + N' and IA.InvoiceType in (2) and TaxComp.Tax_Value <> 0  
					Group By #temp4.CatID ),0))
					Where [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar)  + '''' + N' and [Tax Desc] =  '  +''''+ Cast(@TaxDesc as nVarchar(250))
					+'''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' + '''' + Cast(@CategoryName as nVarchar) + '''' +  ''

					exec sp_executesql  @tempSQL
				End

				--Retail Invoice Return
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'RIR' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_RIR] = ' 
					+ Cast(@CompPer as nVarchar) + N'Where [Category Name] = ' +''''+ Cast(@CategoryName as nVarchar) +''''+
					+ N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' +  '''' + Cast(@TaxPer as nVarchar)+ '''' +
					 N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
					exec sp_executesql  @tempSQL

					Set @tempSql = N'Update #VatReport Set [' + @TaxCompHead + N' Tax (%c)_RIR] = (Select
						isNull((Select Sum(Tax_Value) from InvoiceAbstract IA
						Left Outer Join Customer C ON IA.CustomerID = C.CustomerID 
						Inner Join #tempTaxComp TaxComp ON TaxComp.InvoiceID = IA.InvoiceID
						Inner Join Items It ON It.product_code = TaxComp.product_code
						Inner Join #temp4 ON It.CateGoryID = #temp4.LeafID
						where  
						IA.InvoiceDate between ' + ''''+ cast(@FromDate as nVarchar) +'''' + N' and' + ''''+
						Cast(@ToDate as nVarchar)+'''' + N'and (IA.Status & 192) = 0 and TaxComp.Tax_Code = ' + Cast(@TaxCode as nVarchar) 
						+ N' and Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N'
						and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) 
						and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
						and  #temp4.Parent = ' +''''+ Cast(@CategoryName as nVarchar)+'''' + N' and IA.InvoiceType in (5,6) and TaxComp.Tax_Value <> 0  
						Group By #temp4.CatID ),0))
						Where [Tax %] = ' + + '''' + Cast(@TaxPer as nVarchar) + '''' + N' and [Tax Desc] =  '  +''''+ Cast(@TaxDesc as nVarchar(250))
						+'''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' + '''' + Cast(@CategoryName as nVarchar) + '''' +  ''

					exec sp_executesql  @tempSQL
				End


				
				--StockTransferIn
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'TI' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and  isNull(CategoryName,0) = @CategoryName) 
				Begin
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_TI] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Category Name] = ' +''''+ Cast(@CategoryName as nVarchar) +''''+
					+ N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' +
					N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
					exec sp_executesql  @tempSQL
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax (%c)_TI] = 
					( Case ' + '''' + Cast(@CompSP_Per as nVarchar) + '''' + N' When ''0'' Then  ''0'' else ' 
					+ N' IsNull([Tax On Tran In (%c)],0)'+ N' * ' + Cast(@CompSP_Per as nVarchar) + N'/' + N'[Tax %]' 
					+ N' end) Where [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar)+ '''' + N' and [Tax Desc] =  '  +''''+ Cast(@TaxDesc as nVarchar(250))
					+'''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' + '''' + Cast(@CategoryName as nVarchar) + '''' +  ''
					exec sp_executesql  @tempSQL
				End

				--StockTransferOut
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'TO' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_TO] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Category Name] = ' +''''+ Cast(@CategoryName as nVarchar) +''''+
					+ N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' + 
					N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
					exec sp_executesql  @tempSQL
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax (%c)_TO] = 
					(Case ' + '''' + Cast(@CompSP_Per as nVarchar) + '''' + N' When ''0'' Then  ''0'' else ' 
					+ N' IsNull([Tax On Tran Out (%c)],0)'+ N' * ' + Cast(@CompSP_Per as nVarchar) + N'/' + N'[Tax %]' 
					+ N' end) Where [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' + N' and [Tax Desc] =  '  
					+''''+ Cast(@TaxDesc as nVarchar(250))+ '''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' + '''' + Cast(@CategoryName as nVarchar) + '''' +  ''
					exec sp_executesql  @tempSQL
				End
				Set @i = @i + 1
			End
			Drop Table #tmpComp1
			Delete From #tmpComp
		End
 		if @TaxTypeID = 2
 		Begin	
 			Insert Into #tmpComp Select TaxComponent_Code,Tax_Percentage,SP_Percentage From TaxComponents Where LST_Flag = 0 And Tax_Code = @TaxCode
 			Select [ID] = Identity(Int,1,1),Comp_Code,Comp_Per , CompSP_Per Into #tmpComp2 From #tmpComp
 			Select @Count = Count(*) From #tmpComp2
 			Set @j =1 
 			While @Count >= @j
 			Begin
 				Select @CompCode  =  Comp_Code , @CompPer = Comp_Per, @CompSP_Per = CompSP_Per From  #tmpComp2 Where [ID] = @j
				Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat(@TaxCode, @CompCode)
				--Purchase 
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'OB' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead 
					+ N' Tax %_Purchase] = ' + Cast(@CompPer as nVarchar) + N' Where [Category Name] = ' +''''
					+ Cast(@CategoryName as nVarchar) + '''' + N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) 
					+ N' And [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' +
					N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
					exec sp_executesql  @tempSQL
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead
					+ N' Tax (%c)_Purchase] = ( Case ' + '''' + Cast(@CompSP_Per as nVarchar) + '''' 
					+ N' When ''0'' Then  ''0'' else ' + N' IsNull([CST Tax On Purchase (%c)],0)'+ N' * ' 
					+ Cast(@CompSP_Per as nVarchar) + '/' + N'[Tax %]' + N' end) Where [Tax %] = ' + '''' 
					+ Cast(@TaxPer as nVarchar) + '''' + N' and [Tax Desc] =  '  +''''+ Cast(@TaxDesc as nVarchar(250))
					+'''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' 
					+ '''' + Cast(@CategoryName as nVarchar) + '''' +  ''
					exec sp_executesql  @tempSQL
				End

				--Purchase Return
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'OBR' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_PR] = ' 
					+ Cast(@CompPer as nVarchar) + N' Where [Category Name] = ' + '''' + Cast(@CategoryName as nVarchar) +''''+
					N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' + Cast(@TaxPer as nVarchar) +
					N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
					exec sp_executesql @tempSQL
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead
					+ N' Tax (%c)_PR] = ( Case ' + '''' + Cast(@CompSP_Per as nVarchar) + '''' + N' When ''0'' 
					Then  ''0'' else ' + N' IsNull([CST Tax On Purchase Return (%c)],0)'+ N' * '
					+ Cast(@CompSP_Per as nVarchar) + +'/' + N'[Tax %]' +
					+ N' end) Where [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' + N' and [Tax Desc] =  '  
					+''''+ Cast(@TaxDesc as nVarchar(250))
					+'''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' 
					+ '''' + Cast(@CategoryName as nVarchar) + '''' +  ''
					exec sp_executesql  @tempSQL
				end 

				--Invoice
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'OI' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
	 				Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_Sales] = ' 
	 				+ Cast(@CompPer as nVarchar) + N'Where [Category Name] = ' +''''+ Cast(@CategoryName as nVarchar) +''''+
	 				+ N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' +
	 				 N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
	 				exec sp_executesql  @tempSQL

					Set @tempSql = N'Update #VatReport Set [' + @TaxCompHead + N' Tax (%c)_Sales] = (Select Isnull(
						(Select Sum(Tax_Value) from InvoiceAbstract IA, Customer C, Items It, #temp4,
						#tempTaxComp TaxComp where TaxComp.InvoiceID = IA.InvoiceID 
						and It.product_code = TaxComp.product_code and IA.InvoiceDate between ' + ''''+ cast(@FromDate as nVarchar) +'''' + N' and' + ''''+
						Cast(@ToDate as nVarchar)+'''' + N'and (IA.Status & 192) = 0 and TaxComp.Tax_Code = ' + Cast(@TaxCode as nVarchar) 
						+ N' and Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' 
						and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) 
						and It.CateGoryID = #temp4.LeafID and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
						and  #temp4.Parent = ' +''''+ Cast(@CategoryName as nVarchar)+'''' + N' and IA.InvoiceType in (1, 3) and TaxComp.Tax_Value <> 0  
						and IA.CustomerID = C.CustomerID Group By #temp4.CatID ),0))
						Where [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' + N' and [Tax Desc] =  '  +''''+ Cast(@TaxDesc as nVarchar(250))
						+'''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' 
						+ '''' + Cast(@CategoryName as nVarchar) + '''' +  ''
	
	 				exec sp_executesql  @tempSQL
				End
			
				--SalesReturn Saleable
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'OSRS' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
					Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_SRS] = ' 
					+ Cast(@CompPer as nVarchar) + N'Where [Category Name] = ' +''''+ Cast(@CategoryName as nVarchar) +''''+
					+ N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar)+ '''' +
					 N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
					exec sp_executesql  @tempSQL

					Set @tempSql = N'Update #VatReport Set [' + @TaxCompHead + N' Tax (%c)_SRS] = (Select 
						isNull((Select Sum(Tax_Value) from InvoiceAbstract IA, Customer C, Items It, #temp4,
						#tempTaxComp TaxComp where TaxComp.InvoiceID = IA.InvoiceID 
						and It.product_code = TaxComp.product_code and IA.InvoiceDate between ' + ''''+ cast(@FromDate as nVarchar) +'''' + N' and' + ''''+
						Cast(@ToDate as nVarchar)+'''' + N' and (IA.Status & 192) = 0 and (IA.Status & 32) = 0  and TaxComp.Tax_Code = ' + Cast(@TaxCode as nVarchar) 
						+ N' and Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' 
						and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) 
						and It.CateGoryID = #temp4.LeafID and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
						and  #temp4.Parent = ' +''''+ Cast(@CategoryName as nVarchar)+'''' + N' and IA.InvoiceType in (4) and TaxComp.Tax_Value <> 0  
						and IA.CustomerID = C.CustomerID Group By #temp4.CatID ),0))
						Where [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' + N' and [Tax Desc] =  '  +''''+ Cast(@TaxDesc as nVarchar(250))
						+'''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' + '''' + Cast(@CategoryName as nVarchar) + '''' +  ''
                    
					exec sp_executesql  @tempSQL
				End

				--SalesReturn Damage
				If Exists(Select TaxCode From #tmpTaxType Where Type = N'OSRD' and isNull(TaxCode,0) <> 0 and isNull(TaxPer,'') = @TaxPer and isNull(TaxCode,0) = @TaxCode and isNull(TaxPer,'') <> N'Exempt' and isNull(CategoryName,0) = @CategoryName) 
				Begin
				Set @tempSQL = N'Update #VatReport Set [' + @TaxCompHead + N' Tax %_SRD] = ' 
				+ Cast(@CompPer as nVarchar) + N'Where [Category Name] = ' +''''+ Cast(@CategoryName as nVarchar) +''''+
				+ N' And [Tax Code] = '  + Cast(@TaxCode as nVarchar) + N' And [Tax %] = ' + '''' + Cast(@TaxPer as nVarchar) + '''' +
				 N' And [Tax Desc] = '	 + '''' + Cast(@TaxDesc as nVarchar(250)) + '''' 
				exec sp_executesql  @tempSQL

				Set @tempSql = N'Update #VatReport Set [' + @TaxCompHead + N' Tax (%c)_SRD] = (Select 
					isNull((Select Sum(Tax_Value) from InvoiceAbstract IA, Customer C, Items It, #temp4,
					#tempTaxComp TaxComp where TaxComp.InvoiceID = IA.InvoiceID 
					and It.product_code = TaxComp.product_code and IA.InvoiceDate between ' + ''''+ cast(@FromDate as nVarchar) +'''' + N' and' + ''''+
					Cast(@ToDate as nVarchar)+'''' + N' and (IA.Status & 192) = 0 and (IA.Status & 32) <> 0  and TaxComp.Tax_Code = ' + Cast(@TaxCode as nVarchar) 
					+ N' and Tax_Component_Code = ' + Cast(@CompCode as nVarchar) + N' 
					and It.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) 
					and It.CateGoryID = #temp4.LeafID and #temp4.LeafID In(Select CatID From #tempCatGroupID)  
					and  #temp4.Parent = ' +''''+ Cast(@CategoryName as nVarchar)+'''' + N' and IA.InvoiceType in (4) and TaxComp.Tax_Value <> 0  
					and IA.CustomerID = C.CustomerID Group By #temp4.CatID ),0))
					Where [Tax %] = ' +  '''' + Cast(@TaxPer as nVarchar) + '''' + N' and [Tax Desc] =  '  +''''+ Cast(@TaxDesc as nVarchar(250))
					+'''' + N' and [Tax Code]  = ' + Cast(@TaxCode as nVarchar) + N' and [Category Name] = ' + '''' + Cast(@CategoryName as nVarchar) + '''' +  ''
                
				exec sp_executesql  @tempSQL
				End
 				Set @j = @j + 1
 			End
 			Drop Table #tmpComp2
 			Delete From #tmpComp
		End
		Fetch Next From CurVatReport Into @CategoryName ,@TaxCode,@TaxPer,@TaxDesc
		
	End
	Close CurVatReport
	Deallocate CurVatReport
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
          
Set @tempSQL = N'Update #VATReport set [Tax Desc] =' + '''' + Cast('Exempt' as nVarchar) + '''' + N' where [Tax %]=' + '''' + Cast('Exempt' as nVarchar) + ''''+''
Exec sp_ExecuteSQL @tempSQL                                
     

set @tempSQL = N'Alter Table #VATReport Drop column ' + Cast('[Tax Code]' as nVarchar) + ''
exec sp_executesql @tempSQL

set @tempSQL = N'select * from #VATReport ' --+ 
--' where [tax %] <> ''Exempt''' 
exec sp_executesql @tempSQL


 If @TaxSplitUp = N'Yes'
 Begin	
	 Drop Table #tmpMax
	 Drop Table #tmpTaxComp
	 Drop Table #tmpComp
 end 

 Drop table #tmpProd        
 drop table #tmpCat      
 drop Table #tempCategory        
 drop table #VATReport         
 drop table #temp3      
 drop table #temp4      
 drop table #tempCatGroupID  
 drop table #tempCatGroup  
 drop table #tempCG  
 drop table #tempTax     
 drop table #tmpTaxType
 GSTOut:
End      

