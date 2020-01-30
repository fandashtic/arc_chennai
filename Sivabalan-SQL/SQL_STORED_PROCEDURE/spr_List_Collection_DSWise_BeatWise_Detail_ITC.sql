Create PROCEDURE [dbo].[spr_List_Collection_DSWise_BeatWise_Detail_ITC]      
(      
   @KEYPARAM nVarchar(4000),       
   @Category_Group nVarchar(4000),       
   @Hierarchy NVARCHAR(50),       
   @Category NVARCHAR(4000),               
   @DS nVarchar(50),      
   @Beat nVarchar(4000),
   @DocType nVarchar(100),	
   @szInvFromDate  nVarchar(50),          
   @szInvToDate  nVarchar(50),      
   @szCollFromDate  nVarchar(50),          
   @szCollToDate  nVarchar(50),      
   @InvPaymentMode nVarchar(50),      
   @CollPaymentMode nVarchar(50)      
)        
AS        
     
      
DECLARE @Delimiter as Char(1)            
DECLARE @CategoryID as int        
Declare @OTHERS NVarchar(50)        
Declare @InvPaymentModeNo int      
Declare @CollPaymentModeNo int      
Declare @tempString as nVarchar(1000)      
Declare @ParamSepcounter int      
Declare @SalesmanID int      
Declare @BeatID int      
Declare @GroupID int      
Declare @HierarchyCatID int      
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)       
SET @Delimiter=Char(15)        
Set @tempString = @KEYPARAM      
      
    
declare @CollectionValue decimal(18,6)    
declare @TotalAdjusted decimal(18,6)    
declare @FullDocID varchar(50)    
declare @DocRef varchar(50)    
declare @CumCollValue decimal(18,6)    
declare @CurDocRef varchar(50)    
      
Declare @MLCash nVarchar(50)        
Declare @MLCheque nVarchar(50)        
Declare @MLDD nVarchar(50)        
Declare @MLBankTransfer nVarchar(50)        
Declare @MLCredit nVarchar(50)        
      
Set @MLCash = dbo.LookupDictionaryItem(N'Cash', Default)        
Set @MLCheque = dbo.LookupDictionaryItem(N'Cheque', Default)        
Set @MLDD = dbo.LookupDictionaryItem(N'DD', Default)        
Set @MLBankTransfer = dbo.LookupDictionaryItem(N'Bank Transfer', Default)        
Set @MLCredit = 'Credit'      
      
--Handle the date parameter      
Declare @InvFromDate DATETIME          
Declare @InvToDate DATETIME      
Declare @CollFromDate DATETIME          
Declare @CollToDate DATETIME      
    
   --If hierarchy parameter deleted then make the second level as hierarchy by default    
if @Hierarchy  = '%' or @Hierarchy  = 'Division'    
select @Hierarchy = HierarchyName from itemhierarchy where hierarchyid = 2      
    
if (@szInvFromDate <> '' and @szInvFromDate <> '%' and @szInvToDate <> '' and @szInvToDate <> '%') --Both date entered properly      
begin      
 set @InvFromDate = cast(@szInvFromDate as DateTime)      
 set @InvToDate = cast(@szInvToDate as DateTime)      
end      
else      
Begin      
 Select @InvFromDate = min(InvoiceDate) from invoiceAbstract      
 select @InvToDate = max(InvoiceDate) from invoiceAbstract      
End      
      
if (@szCollFromDate <> '' and @szCollFromDate <> '%' and @szCollToDate <> '' and @szCollToDate <> '%') --Both date entered properly      
begin      
 set @CollFromDate = cast(@szCollFromDate as DateTime)      
 set @CollToDate = cast(@szCollToDate as DateTime)      
end      
else      
Begin      
 Select @CollFromDate = min(DocumentDate) from Collections      
 select @CollToDate = max(DocumentDate) from Collections      
End      
      
--Split The Key parameters      
/* @SalesmanID */                
Set @ParamSepcounter = CHARINDEX(@Delimiter,@tempString,1)                      
set @SalesmanID = cast(isnull(substring(@tempString, 1, @ParamSepcounter-1),0) as int)                  
              
/*@BeatID*/                     
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@KEYPARAM))                   
Set @ParamSepcounter = CHARINDEX(@Delimiter, @tempString, 1)                  
set @BeatID = cast(isnull(substring(@tempString, 1, @ParamSepcounter-1),'') as int)                   
      
/*@GroupID*/      
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@KEYPARAM))                   
Set @ParamSepcounter = CHARINDEX(@Delimiter, @tempString, 1)      
set @GroupID = cast(isnull(substring(@tempString, 1, @ParamSepcounter-1),'') as int)           
      
/*@HierarchyCatID*/      
Set @tempString = isnull(substring(@tempString, @ParamSepcounter + 1, len(@KEYPARAM)),'')       
set @HierarchyCatID =  cast(@tempString as int)          
      
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
      
Create Table #tempCategoryGroup (CategoryGroup NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)        
                  
If @CATEGORY_GROUP = '%'         
 Insert Into #tempCategoryGroup Select GroupName From productcategorygroupabstract        
Else        
 Insert Into #tempCategoryGroup Select * From DBO.sp_SplitIn2Rows(@CATEGORY_GROUP,@Delimiter)        
      
Create Table #tempCategoryName (Category_Name NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)        
      
If @CATEGORY = '%'         
 Insert Into #tempCategoryName Select Category_Name From ItemCategories        
Else        
 Insert Into #tempCategoryName Select * From DBO.sp_SplitIn2Rows(@CATEGORY,@Delimiter)      
      
Create Table #tempItemhierarchy (HierarchyID int)        
      
If @Hierarchy = '%'         
 Insert Into #tempItemhierarchy Select HierarchyID From Itemhierarchy        
Else        
 Insert Into #tempItemhierarchy       
 select HierarchyID From Itemhierarchy        
 where HierarchyName  = @Hierarchy      
        

-- Category Group Handling based on the CategoryGroup definition 

Declare @TempCGCatMapping Table (GroupID Int, Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryID Int, CategoryName nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert InTo @TempCGCatMapping
Select "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup, 
"CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division
From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat
Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name

Create Table #tempCategory(CategoryID int)                
--Filter #tempCategory for Category group      
insert into #tempCategory      
select distinct ItemCategories.CategoryID       
from ProductCategorygroupAbstract, @TempCGCatMapping As ProductCategorygroupDetail,ItemCategories      
where ProductCategorygroupAbstract.groupid = ProductCategorygroupDetail.groupid      
and  ProductCategorygroupDetail.CategoryID = ItemCategories.CategoryID      
and ProductCategorygroupAbstract.GroupName In (Select CategoryGroup COLLATE SQL_Latin1_General_CP1_CI_AS From #tempCategoryGroup)        
      
--Get the leaf categories for the paraent categories      
Create Table #tempCategoryTree(initParentCategoryID int,CategoryID int,HierarchyID int)                
      
DECLARE initParentCategory CURSOR KEYSET FOR                                    
SELECT CategoryID from #tempCategory      
Open  initParentCategory                                    
Fetch From initParentCategory into @CategoryID            
WHILE @@FETCH_STATUS = 0                                  
BEGIN         
     insert into #tempCategoryTree      
     select @CategoryID,* from sp_get_Catergory_RootToChild(@CategoryID)      
     Fetch next From initParentCategory into @CategoryID                                    
END      
Deallocate initParentCategory      
      
--Get the leaf categories for the parent categories for Category parameter      
Create Table #tempCategory2(CategoryID int)           
If @CATEGORY = '%'       
   insert into #tempCategory2         
   Select * From dbo.fn_GetCatFrmCG_ITC(@CATEGORY_GROUP,@Hierarchy,@Delimiter)      
else      
   insert into #tempCategory2         
   Select CategoryID From itemcategories      
   where category_Name in(Select * From DBO.sp_SplitIn2Rows(@CATEGORY,@Delimiter))      
      
Create Table #tempCategoryTree2(initParentCategoryID int, CategoryID int, HierarchyID int)          
      
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
      
Create table #TempCategory1(IDS Int Identity(1,1), CategoryID Int,Category NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Status Int)                           
      
--Get the Category Name for each item at the selected Hierarchy      
create table #tmpItems      
(Product_Code NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,      
 Productname NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryID int default 0,      
 UOM1_Conversion Decimal(18,6) Default 0,UOM2_Conversion Decimal(18,6) Default 0,      
 HierarchyCatName NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default N'',      
HierarchyCatID int default 0)      
      
Declare @HierarchyLevel int      
Declare @CntHierarchyLevel int      
select @HierarchyLevel = HierarchyID from Itemhierarchy where HierarchyName = @Hierarchy      
--set @HierarchyLevel = 2      
select  @CntHierarchyLevel = max(HierarchyID) from Itemhierarchy      
      
insert into #tmpItems(Product_Code,Productname,CategoryID,UOM1_Conversion,UOM2_Conversion,HierarchyCatName,HierarchyCatID)       
select Items.Product_Code,Items.Productname,Items.CategoryID,Items.UOM1_Conversion,      
       Items.UOM2_Conversion, Itemcategories.Category_Name, Itemcategories.CategoryID       
from Items,Itemcategories      
where Items.CategoryID = Itemcategories.CategoryID      
      
while @CntHierarchyLevel > @HierarchyLevel      
Begin      
    Update #tmpItems       
    set  #tmpItems.CategoryID = Itemcategories.ParentID ,       
         #tmpItems.HierarchyCatName = Itemcategories.ParentCategoryName,      
         #tmpItems.HierarchyCatID = Itemcategories.ParentCategoryID      
    from #tmpItems,       
         (      
             select Itemcategories.Category_Name,Itemcategories.CategoryID,      
                    Itemcategories.ParentID,Itemcategories1.Category_Name as ParentCategoryName,      
                    Itemcategories1.CategoryID as ParentCategoryID       
             from  Itemcategories, Itemcategories as Itemcategories1       
             where Itemcategories.ParentID = Itemcategories1.CategoryID      
                   and Itemcategories.[Level] > @HierarchyLevel      
         ) as Itemcategories       
    where #tmpItems.CategoryID = Itemcategories.CategoryID      
          
    set @CntHierarchyLevel = @CntHierarchyLevel - 1      
End      
delete from #tmpItems where CategoryID <= 0      
      
--Get the catogory table with sort order              
Exec sp_CatLevelwise_ItemSorting        
      
--Find the invoice Payment mode      
set @InvPaymentModeNo = -1      
if @InvPaymentMode = @MLCredit      
     set @InvPaymentModeNo = 0         
if @InvPaymentMode = @MLCash      
     set @InvPaymentModeNo = 1         
Else if @InvPaymentMode = @MLCheque      
     set @InvPaymentModeNo = 2         
if @InvPaymentMode = @MLDD      
     set @InvPaymentModeNo = 3         
      
--Find the Collection Payment mode [cash - 0/CHEQUE - 1/DD - 2/Credit Card - 3/Bank Transfer - 4/Coupon - 5/CrediNote - 6/GiftVoucher - 7]      
set @CollPaymentModeNo = -1      
if @CollPaymentMode = @MLCash      
     set @CollPaymentModeNo = 0         
else if @CollPaymentMode = @MLCheque      
     set @CollPaymentModeNo = 1         
else if @CollPaymentMode = @MLDD      
     set @CollPaymentModeNo = 2         
Else if @CollPaymentMode = @MLBankTransfer      
     set @CollPaymentModeNo = 4        
      
--Get the Abstract data's      
create table #tempCollAbstract      
(      
CollectionID int,SalesmanID int default 0, BeatID int default 0,      
FullDocID NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default '',      
PaymentMode NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS default '',      
ChequeDDNo NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS default '',      
ChequeDate Datetime,      
Bank NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default '',      
Branch NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default '',      
CollectionDate DateTime      
)      
      
if @CollPaymentModeNo = -1      
   insert into #tempCollAbstract      
   Select Collections.Documentid as CollectionID,Salesman.SalesmanID,       
          Beat.BeatID, Collections.FullDocID,      
          case PaymentMode                    
          when 0 then @MLCash        
          when 1 then @MLCheque                    
          when 2 then @MLDD              
          when 4 then @MLBankTransfer                  
          end as PaymentMode,      
          Case PaymentMode                
          When 1 then Cast(ChequeNumber as nvarchar)                
          When 2 then Cast(ChequeNumber as nvarchar)      
          When 4 then Cast(Memo as nvarchar)      
          End as ChequeDDNo,                 
          Case PaymentMode                
          When 1 then ChequeDate      
          When 2 then ChequeDate      
          End as ChequeDate,      
          BankName as Bank,                
          BranchName as Branch,Collections.DocumentDate      
   From (select Collections.*, Customer.CustomerID as CustID      
         from Collections, Customer       
         where Collections.CustomerID = Customer.CustomerID) as Collections
		 Left Outer Join  Salesman On Collections.SalesmanID = Salesman.SalesmanID       
		 Left Outer Join Beat On Collections.BeatID = Beat.BeatID       
		 Left Outer Join  BankMaster On collections.Bankcode=BankMaster.bankcode      
		 Left Outer Join  BranchMaster On collections.branchcode=branchMaster.branchcode  and collections.bankcode=branchMaster.bankcode                        
   Where 
--      and Collections.Paymentmode = @CollPaymentModeNo      
         Collections.DocumentDate between @CollFromDate And @CollToDate
		 And IsNull(Collections.DocSerialType, '') Like @DocType
         And (IsNull(Collections.Status,0) & 128) = 0       
         and (IsNull(Collections.Status,0) & 64) = 0       
         and Collections.CustomerID is Not Null            
         And Collections.Value >= 0 --to exclude invoice adjustments with credit payment mode        
         and Salesman.SalesmanID = @SalesmanID    
         and Beat.BeatID = @BeatID      
         and salesman.Salesman_Name in (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tempSalesMan)         
         and Beat.[Description] in (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tempBeat)      
   group by  Collections.Documentid,Salesman.SalesmanID, Beat.BeatID,PaymentMode,ChequeNumber,      
          Salesman.Salesman_Name, Beat.[Description],Collections.FullDocID,PaymentMode,      
          ChequeDate,BankName,BranchName,Memo, Collections.DocumentDate      
else       
   insert into #tempCollAbstract      
   Select Collections.Documentid as CollectionID,Salesman.SalesmanID,       
          Beat.BeatID, Collections.FullDocID,      
          case PaymentMode                    
          when 0 then @MLCash        
          when 1 then @MLCheque                    
          when 2 then @MLDD              
          when 4 then @MLBankTransfer                  
          end as PaymentMode,      
          Case PaymentMode                
          When 1 then Cast(ChequeNumber as nvarchar)                
          When 2 then Cast(ChequeNumber as nvarchar)      
          When 4 then Cast(Memo as nvarchar)      
          End as ChequeDDNo,                 
          Case PaymentMode                
          When 1 then ChequeDate      
          When 2 then ChequeDate      
          End as ChequeDate,      
          BankName as Bank,                
          BranchName as Branch, Collections.DocumentDate      
   From (select Collections.*, Customer.CustomerID as CustID      
         from Collections, Customer       
         where Collections.CustomerID = Customer.CustomerID) as Collections
		 Left Outer Join  Salesman On Collections.SalesmanID = Salesman.SalesmanID       
		 Left Outer Join Beat On Collections.BeatID = Beat.BeatID       
		 Left Outer Join BankMaster On collections.Bankcode=BankMaster.bankcode      
		 Left Outer Join BranchMaster On collections.branchcode=branchMaster.branchcode and collections.bankcode=branchMaster.bankcode                        
   Where Collections.Paymentmode = @CollPaymentModeNo      
         And Collections.DocumentDate between @CollFromDate And @CollToDate
		 And IsNull(Collections.DocSerialType, '') Like @DocType
         And (IsNull(Collections.Status,0) & 128) = 0       
         and (IsNull(Collections.Status,0) & 64) = 0       
         and Collections.CustomerID is Not Null            
         And Collections.Value >= 0 --to exclude invoice adjustments with credit payment mode        
         and Salesman.SalesmanID = @SalesmanID       
         and Beat.BeatID = @BeatID      
         and salesman.Salesman_Name in (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tempSalesMan)         
         and Beat.[Description] in (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tempBeat)      
   group by  Collections.Documentid,Salesman.SalesmanID, Beat.BeatID,PaymentMode,ChequeNumber,      
          Salesman.Salesman_Name, Beat.[Description],Collections.FullDocID,PaymentMode,      
          ChequeDate,BankName,BranchName,Memo, Collections.DocumentDate      
      
create table #tmpInvoiceAbstract      
(      
InvoiceID int,      
InvoiceSerialNo NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS default '',      
DocReference NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS default '',      
InvoiceDate Datetime,      
ARValue decimal(18,6) default 0,       
SalesmanID int default 0, BeatID int default 0,      
Company_Name  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS default '',      
InvoiceAdjustments decimal(18,6) default 0,       
AddlDiscountValue decimal(18,6) default 0,       
DiscountValue decimal(18,6) default 0,      
DiscountPercentage decimal(18,6) default 0,      
Balance decimal(18,6) default 0,      
InvAmount decimal(18,6) default 0      
)      
if @InvPaymentModeNo = -1      
    insert into #tmpInvoiceAbstract      
    Select InvoiceAbstract.InvoiceID,       
          Case ISNULL(InvoiceAbstract.GSTFlag,0) When 0 Then VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID as nvarchar) Else ISNULL(InvoiceAbstract.GSTFullDocID,'') End as InvoiceSerialNo,       
           InvoiceAbstract.DocReference, InvoiceAbstract.InvoiceDate, 0 as ARValue,      
           Salesman.SalesmanID, BEat.BeatID, Customer.Company_Name,      
           Sum(Isnull(Invoiceabstract.AdjustedAmount,0)) as InvoiceAdjustments,       
           Sum(Isnull(Invoiceabstract.AddlDiscountValue,0)) as AddlDiscountValue,       
           Sum(Isnull(Invoiceabstract.DiscountValue,0)) as DiscountValue,      
           Sum(Isnull(Invoiceabstract.DiscountPercentage,0) + IsNull(Invoiceabstract.AdditionalDiscount,0)) as DiscountPercentage , 
           Sum(Isnull(Invoiceabstract.Balance,0)) as Balance ,      
           Sum(Isnull(Invoiceabstract.NetValue,0)) as Amount       
    From InvoiceAbstract,customer,salesman,Beat, VoucherPrefix      
    where InvoiceAbstract.CustomerID = Customer.CustomerID       
          and InvoiceAbstract.InvoiceDate Between @InvFromDate AND @InvToDate          
          and InvoiceAbstract.Status & 128 = 0       
          and InvoiceAbstract.InvoiceType in (1,3)       
--          and InvoiceAbstract.Paymentmode = @InvPaymentModeNo      
          and InvoiceAbstract.SalesmanID = salesman.SalesmanID       
          and InvoiceAbstract.BeatID = Beat.BeatID      
          and Salesman.SalesmanID = @SalesmanID       
          and Beat.BeatID = @BeatID      
          and salesman.Salesman_Name in (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tempSalesMan)         
          and Beat.[Description] in (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tempBeat)      
          and VoucherPrefix.TranID = 'INVOICE'          
          and Invoiceabstract.NetValue >0    
     group by InvoiceAbstract.InvoiceID,InvoiceAbstract.DocumentID,InvoiceAbstract.DocReference,      
              InvoiceAbstract.InvoiceDate,Customer.Company_Name,      
              Salesman.SalesmanID, BEat.BeatID,VoucherPrefix.Prefix,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID      
else      
    insert into #tmpInvoiceAbstract      
    Select InvoiceAbstract.InvoiceID,       
          Case ISNULL(InvoiceAbstract.GSTFlag,0) When 0 Then VoucherPrefix.Prefix + Cast(InvoiceAbstract.DocumentID as nvarchar) Else ISNULL(InvoiceAbstract.GSTFullDocID,'') End as InvoiceSerialNo,       
           InvoiceAbstract.DocReference, InvoiceAbstract.InvoiceDate,0 as ARValue,      
           Salesman.SalesmanID, BEat.BeatID, Customer.Company_Name,      
           Sum(Isnull(Invoiceabstract.AdjustedAmount,0)) as InvoiceAdjustments,       
           Sum(Isnull(Invoiceabstract.AddlDiscountValue,0)) as AddlDiscountValue,       
           Sum(Isnull(Invoiceabstract.DiscountValue,0)) as DiscountValue,      
           Sum(Isnull(Invoiceabstract.DiscountPercentage,0) + IsNull(Invoiceabstract.AdditionalDiscount,0)) as DiscountPercentage ,      
           Sum(Isnull(Invoiceabstract.Balance,0)) as Balance ,      
           Sum(Isnull(Invoiceabstract.NetValue,0)) as Amount       
    From InvoiceAbstract,customer,salesman,Beat, VoucherPrefix      
    where InvoiceAbstract.CustomerID = Customer.CustomerID       
          and InvoiceAbstract.InvoiceDate Between @InvFromDate AND @InvToDate          
          and InvoiceAbstract.Status & 128 = 0       
          and InvoiceAbstract.InvoiceType in (1,3)       
          and InvoiceAbstract.Paymentmode = @InvPaymentModeNo      
          and InvoiceAbstract.SalesmanID = salesman.SalesmanID       
          and InvoiceAbstract.BeatID = Beat.BeatID      
          and Salesman.SalesmanID = @SalesmanID       
          and Beat.BeatID = @BeatID      
          and salesman.Salesman_Name in (select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tempSalesMan)         
          and Beat.[Description] in (select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tempBeat)      
          and VoucherPrefix.TranID = 'INVOICE'          
          and Invoiceabstract.NetValue >0    
     group by InvoiceAbstract.InvoiceID,InvoiceAbstract.DocumentID,InvoiceAbstract.DocReference,      
              InvoiceAbstract.InvoiceDate,Customer.Company_Name,      
              Salesman.SalesmanID, BEat.BeatID,VoucherPrefix.Prefix ,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID     
    
---------------------------------------
-- 1

select ItemCategories.IDS,ItemCategories.CategoryID,ItemCategories.Category,      
       isnull(productcategorygroupabstract.GroupName,'') as GroupName,      
       isnull(productcategorygroupabstract.GroupID,'') as GroupID      
Into #ItmCat
from productcategorygroupabstract, @TempCGCatMapping As productcategorygroupdetail,          
    (      
        select #TempCategory1.IDS,#TempCategory1.CategoryID,#TempCategory1.Category,      
               tempCategoryTree.initParentCategoryID      
        from #TempCategory1, #tempCategoryTree as tempCategoryTree      
        where #TempCategory1.CategoryID = tempCategoryTree.CategoryID      
    ) ItemCategories      
where ItemCategories.initParentCategoryID = productcategorygroupdetail.CategoryID      
      and productcategorygroupabstract.GroupID = productcategorygroupDetail.GroupID      
group by ItemCategories.IDS,ItemCategories.CategoryID,ItemCategories.Category,      
          productcategorygroupabstract.GroupName,productcategorygroupabstract.GroupID      

-- 2

select #tmpInvoiceAbstract.InvoiceID, #tmpInvoiceAbstract.InvoiceSerialNo,       
     #tmpInvoiceAbstract.DocReference, #tmpInvoiceAbstract.InvoiceDate,       
     #tmpInvoiceAbstract.ARValue, #tmpInvoiceAbstract.InvoiceAdjustments,      
     #tmpInvoiceAbstract.AddlDiscountValue, #tmpInvoiceAbstract.DiscountValue,       
     #tmpInvoiceAbstract.DiscountPercentage ,#tmpInvoiceAbstract.Company_Name,      
     #tmpInvoiceAbstract.Balance, #tmpInvoiceAbstract.InvAmount 
Into #InvAbsOne
from #tmpInvoiceAbstract      

-- 3 

   Select InvoiceDetail.InvoiceID,ItemCategories.IDS,ItemCategories.GroupName as Category_Name,                                        
          items.HierarchyCatName,items.HierarchyCatID,ItemCategories.GroupID,Items.Product_Code,      
          sum(InvoiceDetail.Amount) as ItemNetAmt   ,sum(InvoiceDetail.Saleprice) as  Saleprice    
Into #InvDtlOne
   From InvoiceDetail, #tmpItems as Items,  #ItmCat as ItemCategories
   where       
        InvoiceDetail.Product_Code = Items.product_Code       
        and Items.CategoryID = ItemCategories.CategoryID     
and InvoiceID in (select distinct InvoiceID from #tmpInvoiceAbstract)      
   Group by InvoiceDetail.InvoiceID,ItemCategories.IDS,ItemCategories.GroupName,      
          items.HierarchyCatName,items.HierarchyCatID,ItemCategories.GroupID,Items.Product_Code      
        --and ItemCategories.CategoryID in (Select CategoryID from #tempCategory)           

-- 4

select InvoiceAbstract.InvoiceID,InvoiceDetail.IDS,InvoiceAbstract.Company_Name,      
       InvoiceAbstract.InvoiceSerialNo, InvoiceAbstract.DocReference, InvoiceAbstract.InvoiceDate,       
       Invoicedetail.HierarchyCatID,Invoicedetail.GroupID,      
       InvoiceAbstract.ARValue, InvoiceAbstract.InvoiceAdjustments,      
       InvoiceAbstract.AddlDiscountValue, InvoiceAbstract.DiscountValue,       
       InvoiceAbstract.DiscountPercentage, InvoiceAbstract.Balance,      
       sum(ItemNetAmt/InvoiceAbstract.InvAmount) as ItemInvProportion,InvoiceAbstract.InvAmount as NetValue      
Into #InvDatOne
from  #InvAbsOne as InvoiceAbstract, #InvDtlOne as InvoiceDetail

     where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
        and InvoiceDetail.Saleprice>0 --Avoid diff product scheme applied free items    
     group by InvoiceAbstract.InvoiceID,InvoiceDetail.IDS,InvoiceAbstract.Company_Name,      
       Invoicedetail.HierarchyCatID,Invoicedetail.GroupID,      
       InvoiceAbstract.InvoiceSerialNo, InvoiceAbstract.DocReference, InvoiceAbstract.InvoiceDate,      
       InvoiceAbstract.ARValue, InvoiceAbstract.InvoiceAdjustments,      
       InvoiceAbstract.AddlDiscountValue, InvoiceAbstract.DiscountValue,       
       InvoiceAbstract.DiscountPercentage, InvoiceAbstract.Balance,InvoiceAbstract.InvAmount    
-- 5

select InvoiceData.InvoiceID,InvoiceData.IDS,InvoiceData.Company_Name,      
       InvoiceData.HierarchyCatID,InvoiceData.GroupID,      
           InvoiceData.InvoiceSerialNo, InvoiceData.DocReference, InvoiceData.InvoiceDate,       
           sum(InvoiceData.ARValue) as ARValue, sum(InvoiceData.InvoiceAdjustments) as InvoiceAdjustments,      
           sum(InvoiceData.AddlDiscountValue) as AddlDiscountValue, sum(InvoiceData.DiscountValue) as DiscountValue,       
           sum(InvoiceData.DiscountPercentage) as DiscountPercentage, sum(InvoiceData.Balance) as Balance,      
           sum(ItemInvProportion) as  ItemInvProportion,sum(InvoiceData.NetValue) as NetValue      
Into #tmpInvOne
from  #InvDatOne as InvoiceData

group by InvoiceData.InvoiceID,InvoiceData.IDS,InvoiceData.Company_Name,      
       InvoiceData.HierarchyCatID,InvoiceData.GroupID,      
       InvoiceData.InvoiceSerialNo, InvoiceData.DocReference, InvoiceData.InvoiceDate      
-- 6

select CollectionDetail.CollectionID,CollectionDetail.DocumentID as CollDocumentID,      
     #tempCollAbstract.SalesmanID, #tempCollAbstract.BeatID,      
     sum(ExtraCollection) as ExtraCollection,      
     sum(Adjustment) as  OrgWriteOffAmount,      
     sum( case when CollectionDetail.Discount in(0) then Adjustment else Adjustment - ((CollectionDetail.Discount/100)*CollectionDetail.DocumentValue) end)  as  WriteOffAmount,    
     sum(Collectiondetail.documentvalue) as CollectionValue,      
     sum(Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection) as TotalAdjusted,      
     sum(Collectiondetail.documentvalue - Collectiondetail.AdjustedAmount - CollectionDetail.ExtraCollection) as Outstanding,    
     sum( case when CollectionDetail.Discount in(0) then 0 else ((CollectionDetail.Discount/100)*CollectionDetail.DocumentValue) end)  as  CollDiscount,    
     sum(CollectionDetail.Discount)  as  CollDiscountPercent,    
     sum(CollectionDetail.DocAdjustAmount)  as  DocAdjustAmount,    
     Sum(Case When IsNull(CollectionDetail.CollectedAmount,0) = 0 
			   And IsNull(CollectionDetail.DocAdjustAmount,0) = 0 
			   Then  Collectiondetail.AdjustedAmount
			   Else CollectionDetail.CollectedAmount End) As CollectedAmount
Into #tmpColDtlOne
from CollectionDetail, #tempCollAbstract      
where CollectionDetail.CollectionID =  #tempCollAbstract.CollectionID      
    and CollectionDetail.DocumentType in (4)      
group by CollectionDetail.CollectionID,CollectionDetail.DocumentID,      
     #tempCollAbstract.SalesmanID, #tempCollAbstract.BeatID       


------------------------------------------------      
--Get the CollectionDetail and Invoicebased data      
select *  into #tmpCollInvoiceData from      
(      
      Select tmpCollDetail.CollectionID,tmpCollDetail.CollDocumentID,      
             tmpInvoice.HierarchyCatID,tmpInvoice.GroupID,                 
             isnull(tmpInvoice.IDS,0) as IDS ,isnull(tmpInvoice.InvoiceID,0) as InvoiceID,      
             isnull(tmpInvoice.InvoiceSerialNo,'') as InvoiceSerialNo,       
             isnull(tmpInvoice.DocReference,'') as DocReference,       
             tmpInvoice.InvoiceDate, tmpInvoice.Company_Name,      
             sum(ItemInvProportion*tmpCollDetail.ExtraCollection) as ExtraCollection,      
             sum(ItemInvProportion*tmpCollDetail.WriteOffAmount) as WriteOffAmount,      
             sum(ItemInvProportion*tmpInvoice.InvoiceAdjustments) as InvoiceAdjustments,      
             sum(ItemInvProportion*tmpInvoice.AddlDiscountValue) as AddlDiscountValue,      
             sum(ItemInvProportion*tmpInvoice.DiscountValue) as DiscountValue,      
             sum(ItemInvProportion*tmpCollDetail.TotalAdjusted) as TotalAdjusted,      
             sum(ItemInvProportion*tmpCollDetail.CollectionValue) as CollectionValue,      
             sum(ItemInvProportion*tmpCollDetail.Outstanding) as Outstanding,      
             sum(ItemInvProportion*tmpInvoice.DiscountPercentage) as DiscountPercentage,      
             sum(ItemInvProportion*tmpInvoice.NetValue) as SalesValue, sum(ItemInvProportion*tmpInvoice.Balance) as InvoiceValue,    
             sum(ItemInvProportion*tmpCollDetail.CollDiscount) as CollDiscount,      
             sum(ItemInvProportion*tmpCollDetail.CollDiscountPercent) as CollDiscountPercent,        
             sum(ItemInvProportion*tmpCollDetail.OrgWriteOffAmount) as OrgWriteOffAmount  ,    
             sum(ItemInvProportion*tmpCollDetail.DocAdjustAmount)  as  DocAdjustAmount,    
             sum(ItemInvProportion*tmpCollDetail.CollectedAmount)  as  CollectedAmount     
      from  #tmpColDtlOne as tmpCollDetail,  #tmpInvOne as tmpInvoice
      Where tmpCollDetail.CollDocumentID = tmpInvoice.Invoiceid       
            and tmpInvoice.GroupID = @GroupID       
            and tmpInvoice.HierarchyCatID=  @HierarchyCatID      
      group by tmpCollDetail.CollectionID,tmpCollDetail.CollDocumentID,      
             tmpInvoice.HierarchyCatID,tmpInvoice.GroupID,      
             tmpInvoice.IDS,tmpInvoice.InvoiceID,tmpInvoice.InvoiceSerialNo,      
             tmpInvoice.DocReference,tmpInvoice.InvoiceDate, tmpInvoice.Company_Name      
) #tmpCollInvoiceData      
      
    
    
    
Create Table #tmpFinalData     
(    
CollectionID int default 0,    
InvoiceID int default 0,    
CustomerID NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,    
FullDocID1 NVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,    
FullDocID NVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,    
[Collection Date] datetime,    
[Invoice Serial No.]  NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,    
[DocRef]  NVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,    
[Inv Date] datetime,      
[CustName] NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,    
[Sales Value] Decimal(18,6) default 0,      
[Invoice Value] Decimal(18,6) default 0,      
[CollectionMode]  NVarChar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,    
[ChqNo/DD No.]  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,    
[Instrument Date]   datetime,      
[Bank]  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,    
[Branch]  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,    
[Collection Value] Decimal(18,6) default 0,      
[Total Adjusted] Decimal(18,6) default 0,      
[Extra Collection] Decimal(18,6) default 0,      
[Writeoff] Decimal(18,6) default 0,      
[Invoice Adjustments] Decimal(18,6) default 0,      
[% Discount] Decimal(18,6) default 0,      
[Discount Amount] Decimal(18,6) default 0,      
[Outstanding] Decimal(18,6) default 0,      
OrgWriteOffAmount Decimal(18,6) default 0,    
[InvwiseOutstanding] Decimal(18,6) default 0      
)      
    
--Select the final data      
insert into #tmpFinalData    
select     
       "CollectionID" = #tmpCollInvoiceData.CollectionID,    
       "InvoiceID" = #tmpCollInvoiceData.InvoiceID,    
       "CustomerID" = Customer.CustomerID,    
  "FullDocID1" = #tempCollAbstract.FullDocID,      
       "FullDocID" = #tempCollAbstract.FullDocID,      
       "Collection Date" = #tempCollAbstract.CollectionDate,      
 "Invoice Serial No." = #tmpCollInvoiceData.InvoiceSerialNo,      
       "DocRef" = #tmpCollInvoiceData.DocReference,      
       "Inv Date" =  #tmpCollInvoiceData.InvoiceDate,      
       "CustName" =  #tmpCollInvoiceData.Company_Name,      
       "Sales Value" =  sum(#tmpCollInvoiceData.SalesValue),      
       "Invoice Value" = sum(#tmpCollInvoiceData.InvoiceValue),      
       "CollectionMode" = PaymentMode,      
       "ChqNo/DD No." = ChequeDDNo,      
       "Instrument Date" = ChequeDate,      
       "Bank" = Bank,      
       "Branch" = Branch,      
       "Collection Value" = sum(#tmpCollInvoiceData.CollectedAmount),             
       "Total Adjusted" =  sum(#tmpCollInvoiceData.DocAdjustAmount),      
--        "Collection Value" = sum(#tmpCollInvoiceData.CollectionValue),             
--        "Total Adjusted" =  sum(#tmpCollInvoiceData.TotalAdjusted),      
       "Extra Collection" = sum(#tmpCollInvoiceData.ExtraCollection),      
       "Writeoff" =  sum(#tmpCollInvoiceData.WriteOffAmount),      
       "Invoice Adjustments" =  sum(#tmpCollInvoiceData.InvoiceAdjustments),      
       "% Discount" =  sum(#tmpCollInvoiceData.DiscountPercentage + #tmpCollInvoiceData.CollDiscountPercent),      
       "Discount Amount" =  sum(#tmpCollInvoiceData.AddlDiscountValue + #tmpCollInvoiceData.DiscountValue + #tmpCollInvoiceData.CollDiscount),      
       "Outstanding" =  sum(#tmpCollInvoiceData.Outstanding)  ,    
       "OrgWriteOffAmount" = sum(#tmpCollInvoiceData.OrgWriteOffAmount),    
       "InvwiseOutstanding" = 0    
from #tempCollAbstract, #tmpCollInvoiceData  ,Customer    
where #tempCollAbstract.CollectionID = #tmpCollInvoiceData.CollectionID      
      and #tmpCollInvoiceData.Company_Name = Customer.Company_Name    
group by #tmpCollInvoiceData.CollectionID,#tmpCollInvoiceData.InvoiceID,    
         #tempCollAbstract.FullDocID,Customer.CustomerID, #tmpCollInvoiceData.InvoiceSerialNo,      
       #tmpCollInvoiceData.DocReference, #tmpCollInvoiceData.InvoiceDate,      
       #tmpCollInvoiceData.Company_Name,      
       #tempCollAbstract.PaymentMode,#tempCollAbstract.ChequeDDNo,#tempCollAbstract.ChequeDate,      
       #tempCollAbstract.Bank,#tempCollAbstract.Branch,#tempCollAbstract.CollectionDate      
	   ,#tempCollAbstract.CollectionID
order by dbo.striptimefromdate(#tempCollAbstract.CollectionDate), #tempCollAbstract.CollectionID, #tmpCollInvoiceData.InvoiceID    
    
    
--Update outstanding    

update #tmpFinalData set InvwiseOutstanding = dbo.mERP_fn_getInvwiseOutstanding_Chq(CustomerId,InvoiceId,CollectionId,@CollToDate,@CollPaymentModeNo,[Collection Date])    

select "FullDocID1" = [FullDocID1],      
       "FullDocID" = [FullDocID],      
       "Collection Date" = [Collection Date],      
       "Invoice Serial No." = [Invoice Serial No.],      
       "DocRef" = [DocRef],      
       "Inv Date" =  [Inv Date],      
       "CustName" =  [CustName],      
       "Sales Value" =  [Sales Value],      
       "Invoice Value" = [Invoice Value],      
       "CollectionMode" = [CollectionMode],      
       "ChqNo/DD No." = [ChqNo/DD No.],      
       "Instrument Date" = [Instrument Date],      
       "Bank" = [Bank],      
       "Branch" = [Branch],      
       "Collection Value" = [Collection Value],             
       "Total Adjusted" =  [Total Adjusted],      
       "Extra Collection" =  [Extra Collection],      
       "Writeoff" =  [Writeoff],      
       "Invoice Adjustments" =  [Invoice Adjustments],      
       "% Discount" =  [% Discount],      
       "Discount Amount" =  [Discount Amount],      
       "Outstanding" =  [InvwiseOutstanding],
	   "Cheque on Hand (%c)" =  (Select Sum ( Case (IsNull(C.Realised, 0)) When 3 Then dbo.mERP_fn_get_RepresentChqAmt((C.DocumentID)) 
		Else
		(Case 
		When (IsNull(CCD.ChqStatus, 0))=1  And dbo.stripdatefromtime(@CollToDate) < isnull((dbo.stripdatefromtime(CCD.Realisedate)),getdate()) Then
		(isnull(Cd.AdjustedAmount,0) - isnull(DocAdjustAmount,0))
		When isnull((CCd.ChqStatus),0) = 1 And dbo.stripdatefromtime(@CollToDate) = isnull((dbo.stripdatefromtime(CCD.Realisedate)),getdate()) Then 0
		Else (IsNull(CD.AdjustedAmount,0) - isnull(DocAdjustAmount,0)) 
		End)End)
		from Collections C,CollectionDetail CD,ChequeCollDetails CCD Where C.DocumentID = #tmpFinalData.CollectionID And 
		C.Documentid = CCD.CollectionID and
	   C.CustomerID = #tmpFinalData.CustomerID  and isnull(C.PaymentMode,0) = 1 and isnull(C.Status,0)& 192 =0 and isnull(realised,0) not in(2)
	   And C.DocumentID = CD.CollectionID and CD.DocumentID = #tmpFinalData.InvoiceID and CD.DocumentType =4)

--	   "Cheque on Hand (%c)" =  (Select isnull(sum(isnull(C.Value,0)),0) from Collections C,CollectionDetail CD Where       
--	   C.CustomerID = #tmpFinalData.CustomerID  and isnull(C.PaymentMode,0) = 1 and isnull(C.Status,0)& 192 =0 and isnull(realised,0) not in(1,2,3,4,5)
--	   And C.DocumentID = CD.CollectionID and CD.DocumentID = #tmpFinalData.InvoiceID and CD.DocumentType =4)
from #tmpFinalData      
    
Handler:      
----Drop Tables      
drop table #tempSalesMan      
drop table #tempBeat     
drop table #tmpCollInvoiceData      
drop table #tempCategory      
drop table #tempCategoryGroup      
drop table #tempCategoryName      
drop table #tempItemhierarchy      
drop table #tempCategoryTree      
drop table #TempCategory1      
drop table #tempCategory2      
drop table #tempCategoryTree2      
drop table #tmpItems      
drop table #tempCollAbstract      
drop table #tmpInvoiceAbstract      
drop table #tmpFinalData    
drop table #ItmCat
drop table #InvAbsOne
drop table #InvDtlOne
drop table #InvDatOne
drop table #tmpInvOne
drop table #tmpColDtlOne

