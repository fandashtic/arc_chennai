CREATE Procedure spr_List_SalesMan_Customer_ItemWise_Abstract_ITC  
(
	@CATEGORY_GROUP nVarchar(4000),
	@Hierarchy NVARCHAR(50),
	@CATEGORY NVARCHAR(4000),
	@UOM nVarChar(100),
	@DetailedAt nVarchar(50),
	@ItemwiseOnly nVarchar(50),
	@DSwise nVarchar(50),
	@Beat nVarchar(4000),
	@Customerwise nVarchar(50),
	@Datewise nVarchar(50),
	@FROMDATE DATETIME,
	@TODATE DATETIME,
	@LevelOfReport nVarchar(50)
)
AS
Begin
	DECLARE @Delimiter as Char(1)
	DECLARE @RptType as varchar(1)
	DECLARE @ColPrefix as varchar(10)
	DECLARE @RecCnt as int
	SET @Delimiter=Char(15)
	DECLARE @CategoryID as int
	Declare @CustName as nVarchar(255), @Merchandise as nVarchar(255), @Query as nVarchar(4000), @QryStr as nVarchar(Max)

	Create Table #tmpCust(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	CustomerName nVarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Merchandise nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
    
     --If hierarchy parameter deleted then make the second level as hierarchy by default    
  if @Hierarchy  = N'%' or @Hierarchy  = N'Division'
  select @Hierarchy = HierarchyName from itemhierarchy where hierarchyid = 2
     --If @UOM parameter deleted then make the Base UOM by default    
  if @UOM  = '%'    
     set @UOM  = N'Base UOM'     
     --If @DetailedAt parameter deleted then make the "Item" by default    
   if @DetailedAt  = '%'    
     set @DetailedAt  = 'Item'    
     --If @ItemwiseOnly parameter deleted then make the "Yes" by default    
   if @ItemwiseOnly  = N'%'    
     set @ItemwiseOnly  = 'Yes'    
  --If @DSwise parameter deleted then make the "N/A" by default    
   if @DSwise  = N'%'    
     set @DSwise  = 'N/A'    
  --If @Beat parameter deleted then make the "N/A" by default    
   if @Beat  = N'%'    
     set @Beat  = 'N/A'    
  --If @Customerwise parameter deleted then make the "N/A" by default    
   if @Customerwise  =N'%'    
     set @Customerwise  = 'N/A'    
  --If @Datewise parameter deleted then make the "N/A" by default    
   if @Datewise  = N'%'    
     set @Datewise  = 'N/A'    
  --If @LevelOfReport parameter deleted then make the "N/A" by default    
   if @LevelOfReport  = N'%'    
     set @LevelOfReport  = 'All'    
    
     --As no of columns varies according to the parameter @LevelOfReport and @DetailedAt update the reportadata.Subtotals column accordingly    
     DECLARE @sql as nvarchar(Max)           
    
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

	Declare @TempCGCatMapping Table (GroupID Int, Product_Code nVarChar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,
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
     from ProductCategorygroupAbstract, @TempCGCatMapping As ProductCategorygroupDetail, ItemCategories    
     where ProductCategorygroupAbstract.groupid = ProductCategorygroupDetail.groupid    
     and  ProductCategorygroupDetail.CategoryID = ItemCategories.CategoryID    
     and ProductCategorygroupAbstract.GroupName In (Select CategoryGroup COLLATE SQL_Latin1_General_CP1_CI_AS From #tempCategoryGroup)      
    
     --Get the leaf categories for the parent categories for Category Group parameter    
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
    
    
    
     --Populate the Invoice abstract detail based on Levale Of report    
     create table #tmpInvoiceAbstract    
     (    
     InvoiceDate  Datetime,InvoiceID int default 0,DocumentID nvarchar(500) default N'' COLLATE SQL_Latin1_General_CP1_CI_AS,
	 CustomerID nvarchar(255) default N'' COLLATE SQL_Latin1_General_CP1_CI_AS,    
     InvoiceType int default 0,Status int default 0,    
     SalesmanID int default 0,BeatID int default 0,GrossValue decimal (18,6) default 0,    
     SchemeDiscountAmount decimal (18,6) default 0,DiscountValue decimal (18,6) default 0,    
     VatTaxAmount  decimal (18,6) default 0,NetValue  decimal (18,6) default 0,    
     DiscountPercentage  decimal (18,6) default 0,    
     AdditionalDiscount  decimal (18,6) default 0,    
     SchemeDiscountPercentage  decimal (18,6) default 0,    
     MultFactor int default 1,    
     DiscAndScheme  decimal (18,6) default 0,    
     freight  decimal (18,6) default 0,    
     freightlessnet  decimal (18,6) default 0,    
     freightorg  decimal (18,6) default 0,
     GSTFlag int,
     GSTFullDocID nvarchar(500) default N'' COLLATE SQL_Latin1_General_CP1_CI_AS 
        
     )    
    
     if @LevelOfReport = 'Sales'     
     begin     
          set @ColPrefix = 'Sales'    
          insert into #tmpInvoiceAbstract     
          select InvoiceAbstract.InvoiceDate,InvoiceAbstract.InvoiceID,
          Case IsNull(GSTFlag,0) when 0 then VoucherPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'') END as DocumnetID,
                 InvoiceAbstract.CustomerID,InvoiceAbstract.InvoiceType,InvoiceAbstract.Status,    
                 InvoiceAbstract.SalesmanID,InvoiceAbstract.BeatID,                     
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.GrossValue      
                 end as GrossValue,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.SchemeDiscountAmount    
                 end as SchemeDiscountAmount,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.DiscountValue    
                 end as DiscountValue,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.VatTaxAmount    
                 end as VatTaxAmount,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.NetValue    
                 end  as NetValue,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.DiscountPercentage      
                 end as DiscountPercentage,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.AdditionalDiscount      
                 end as AdditionalDiscount,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.SchemeDiscountPercentage      
                 end as SchemeDiscountPercentage,1 as MultFactor,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then (IsNull(InvoiceAbstract.DiscountPercentage,0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage,0))    
                 end as DiscAndScheme,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.Freight    
                 end as freight,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then (InvoiceAbstract.NetValue - InvoiceAbstract.Freight)    
                 end as freightlessnet,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.Freight  
                 end as freightorg   ,
                 GSTFlag,
                 GSTFullDocID
          from InvoiceAbstract ,VoucherPrefix    
          where InvoiceAbstract.InvoiceDate Between @FROMDATE AND @TODATE         
                and InvoiceAbstract.Status & 128 = 0        
                and InvoiceAbstract.InvoiceType in (1,3)    
                And VoucherPrefix.TranID = N'INVOICE'     
--                 and InvoiceAbstract.NetValue > 0    
     end    
     else if @LevelOfReport = 'Sales Return'     
     Begin    
          set @ColPrefix = 'Sales Return'    
          insert into #tmpInvoiceAbstract     
          select InvoiceAbstract.InvoiceDate,InvoiceAbstract.InvoiceID,
         Case IsNull(GSTFlag,0) when 0 then VoucherPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'') END as DocumnetID,
                 InvoiceAbstract.CustomerID,InvoiceAbstract.InvoiceType,InvoiceAbstract.Status,    
                 InvoiceAbstract.SalesmanID,InvoiceAbstract.BeatID,    
                 InvoiceAbstract.GrossValue as GrossValue ,InvoiceAbstract.SchemeDiscountAmount,    
                 InvoiceAbstract.DiscountValue,InvoiceAbstract.VatTaxAmount,InvoiceAbstract.NetValue,          
                 InvoiceAbstract.DiscountPercentage , InvoiceAbstract.AdditionalDiscount,    
                 InvoiceAbstract.SchemeDiscountPercentage, 1 as MultFactor,    
                (IsNull(InvoiceAbstract.DiscountPercentage,0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage,0)) as DiscAndScheme,    
                 InvoiceAbstract.Freight,      
                (InvoiceAbstract.NetValue - InvoiceAbstract.Freight) as freightlessnet,         
                 1*InvoiceAbstract.Freight as freightorg,
                 GSTFlag,
                 GSTFullDocID  
          from InvoiceAbstract  ,VoucherPrefix    
          where InvoiceAbstract.InvoiceDate Between @FROMDATE AND @TODATE         
                and InvoiceAbstract.Status & 128 = 0        
                and InvoiceAbstract.InvoiceType in (4)    
                And VoucherPrefix.TranID = N'INVOICE'     
--                 and InvoiceAbstract.NetValue > 0    
     End    
     else if @LevelOfReport = 'Net Sales'     
     Begin    
          set @ColPrefix = 'Net Sales'    
          insert into #tmpInvoiceAbstract   
          select InvoiceAbstract.InvoiceDate,InvoiceAbstract.InvoiceID,
         Case IsNull(GSTFlag,0) when 0 then VoucherPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'') END as DocumnetID,
                 InvoiceAbstract.CustomerID,InvoiceAbstract.InvoiceType,InvoiceAbstract.Status,    
                 InvoiceAbstract.SalesmanID,InvoiceAbstract.BeatID,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.GrossValue                           when InvoiceAbstract.InvoiceType in (4) then -1*InvoiceAbstract.GrossValue     
                 end as GrossValue,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.SchemeDiscountAmount     
                       when InvoiceAbstract.InvoiceType in (4) then -1*InvoiceAbstract.SchemeDiscountAmount     
                 end as SchemeDiscountAmount,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.DiscountValue     
                       when InvoiceAbstract.InvoiceType in (4) then -1*InvoiceAbstract.DiscountValue     
                 end as DiscountValue,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.VatTaxAmount     
                       when InvoiceAbstract.InvoiceType in (4) then -1*InvoiceAbstract.VatTaxAmount    
                 end as VatTaxAmount,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.NetValue     
                       when InvoiceAbstract.InvoiceType in (4) then -1*InvoiceAbstract.NetValue    
                 end  as NetValue,          
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.DiscountPercentage      
                       when InvoiceAbstract.InvoiceType in (4) then 1*InvoiceAbstract.DiscountPercentage      
                 end as DiscountPercentage,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.AdditionalDiscount      
                       when InvoiceAbstract.InvoiceType in (4) then 1*InvoiceAbstract.AdditionalDiscount         
                 end as AdditionalDiscount,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.SchemeDiscountPercentage      
                            when InvoiceAbstract.InvoiceType in (4) then 1*InvoiceAbstract.SchemeDiscountPercentage    
                 end as SchemeDiscountPercentage,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then 1      
                            when InvoiceAbstract.InvoiceType in (4) then -1    
                 end as MultFactor,   
                 case  when InvoiceAbstract.InvoiceType in (1,3) then (IsNull(InvoiceAbstract.DiscountPercentage,0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage,0))    
                           when InvoiceAbstract.InvoiceType in (4) then 1*(IsNull(InvoiceAbstract.DiscountPercentage,0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage,0))    
                 end as DiscAndScheme,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.Freight    
                 when InvoiceAbstract.InvoiceType in (4) then 1*InvoiceAbstract.Freight    
                 end as freight,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then (InvoiceAbstract.NetValue - InvoiceAbstract.Freight)    
                       when InvoiceAbstract.InvoiceType in (4) then 1*(InvoiceAbstract.NetValue - InvoiceAbstract.Freight)    
                 end as freightlessnet  ,       
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.Freight    
                 when InvoiceAbstract.InvoiceType in (4) then -1*InvoiceAbstract.Freight    
                 end as freightorg,
                 GSTFlag,
                 GSTFullDocID  
          from InvoiceAbstract  ,VoucherPrefix    
          where InvoiceAbstract.InvoiceDate Between @FROMDATE AND @TODATE         
                and InvoiceAbstract.Status & 128 = 0        
                and InvoiceAbstract.InvoiceType in (1,3,4)    
                And VoucherPrefix.TranID = N'INVOICE'     
--                 and InvoiceAbstract.NetValue > 0    
     End    
     else if @LevelOfReport = 'All'     
     Begin    
          set @ColPrefix = ''    
          insert into #tmpInvoiceAbstract    
          select InvoiceAbstract.InvoiceDate,InvoiceAbstract.InvoiceID,
         Case IsNull(GSTFlag,0) when 0 then VoucherPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'') END as DocumnetID,    
          InvoiceAbstract.CustomerID,InvoiceAbstract.InvoiceType,InvoiceAbstract.Status,    
                 InvoiceAbstract.SalesmanID,InvoiceAbstract.BeatID,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.GrossValue    
                       when InvoiceAbstract.InvoiceType in (4) then -1*InvoiceAbstract.GrossValue     
                 end as GrossValue,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.SchemeDiscountAmount     
                       when InvoiceAbstract.InvoiceType in (4) then -1*InvoiceAbstract.SchemeDiscountAmount     
                 end as SchemeDiscountAmount,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.DiscountValue     
                       when InvoiceAbstract.InvoiceType in (4) then -1*InvoiceAbstract.DiscountValue     
                 end as DiscountValue,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.VatTaxAmount     
                       when InvoiceAbstract.InvoiceType in (4) then -1*InvoiceAbstract.VatTaxAmount    
                 end as VatTaxAmount,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.NetValue     
                       when InvoiceAbstract.InvoiceType in (4) then -1*InvoiceAbstract.NetValue    
                 end  as NetValue,          
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.DiscountPercentage      
                       when InvoiceAbstract.InvoiceType in (4) then 1*InvoiceAbstract.DiscountPercentage      
                 end as DiscountPercentage,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.AdditionalDiscount      
                       when InvoiceAbstract.InvoiceType in (4) then 1*InvoiceAbstract.AdditionalDiscount         
                 end as AdditionalDiscount,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.SchemeDiscountPercentage      
                            when InvoiceAbstract.InvoiceType in (4) then 1*InvoiceAbstract.SchemeDiscountPercentage      
                 end as SchemeDiscountPercentage,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then 1      
                            when InvoiceAbstract.InvoiceType in (4) then -1    
                 end as MultFactor,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then (IsNull(InvoiceAbstract.DiscountPercentage,0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage,0))    
                           when InvoiceAbstract.InvoiceType in (4) then 1*(IsNull(InvoiceAbstract.DiscountPercentage,0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage,0))    
                 end as DiscAndScheme,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.Freight    
                 when InvoiceAbstract.InvoiceType in (4) then 1*InvoiceAbstract.Freight    
                 end as freight,    
                 case  when InvoiceAbstract.InvoiceType in (1,3) then (InvoiceAbstract.NetValue - InvoiceAbstract.Freight)    
                       when InvoiceAbstract.InvoiceType in (4) then 1*(InvoiceAbstract.NetValue - InvoiceAbstract.Freight)    
                 end as freightlessnet,         
                 case  when InvoiceAbstract.InvoiceType in (1,3) then InvoiceAbstract.Freight    
                 when InvoiceAbstract.InvoiceType in (4) then -1*InvoiceAbstract.Freight    
                 end as freightorg ,
                 GSTFlag,
                 GSTFullDocID  
          from InvoiceAbstract  ,VoucherPrefix    
          where InvoiceAbstract.InvoiceDate Between @FROMDATE AND @TODATE         
                and InvoiceAbstract.Status & 128 = 0        
                and InvoiceAbstract.InvoiceType in (1,3,4)    
                And VoucherPrefix.TranID = N'INVOICE'     
--                 and InvoiceAbstract.NetValue > 0    
     End    
    
    
     --Create the intermediate data    
    select * into #tmpData from    
     (    
--          select InvoiceAbstract.SalesMan_Name,InvoiceAbstract.Company_Name,InvoiceAbstract.Beat,InvoiceAbstract.InvoiceDate,    
         select InvoiceAbstract.SalesMan_Name,InvoiceAbstract.Company_Name,InvoiceAbstract.Beat,dbo.StripTimeFromDate(InvoiceAbstract.InvoiceDate) as InvoiceDate,    
       Case isnull(Invoiceabstract.GSTFlag,0) when 0 then (InvoiceAbstract.DocumentID)  else Isnull(InvoiceAbstract.GSTFullDocID,0) END COLLATE SQL_Latin1_General_CP1_CI_AS as [Invoice No],    
         --(InvoiceAbstract.DocumentID) COLLATE SQL_Latin1_General_CP1_CI_AS as [Invoice No],    
           InvoiceDetail.IDEGrossValue as GrossValue,    
           (    
              (IsNull(InvoiceDetail.IDESchemeDiscAmount,0) + IsNull(InvoiceDetail.IDESplCatDiscAmount,0))        
              +((InvoiceDetail.IDEGrossValue-IsNull(InvoiceDetail.IDEDiscountValue,0)) *  IsNull(InvoiceAbstract.SchemeDiscountPercentage,0)/100.)    
           ) as SchemeDiscountAmount,        
           (     
              (IsNull(InvoiceDetail.IDEDiscountValue,0) - (IsNull(InvoiceDetail.IDESchemeDiscAmount,0) + IsNull(InvoiceDetail.IDESplCatDiscAmount,0)) )        
              +( (InvoiceDetail.IDEDisc)  *((DiscAndScheme)/100.))        
              +((InvoiceDetail.IDEDisc) * IsNull(InvoiceAbstract.AdditionalDiscount,0)/100.)    
           ) as DiscountValue,        
    
           (IsNull(InvoiceDetail.IDECSTPayable,0) + IsNull(InvoiceDetail.IDESTPayable,0)) as VatTaxAmount,    
--            InvoiceDetail.IDENetAmount + (InvoiceAbstract.Freight/(InvoiceAbstract.freightlessnet))*InvoiceDetail.IDENetAmount as NetValue    
          case when InvoiceDetail.IDENetAmount in (0) then InvoiceAbstract.Freightorg else InvoiceDetail.IDENetAmount + (InvoiceAbstract.Freight/(Case InvoiceAbstract.freightlessnet When 0 Then 1 Else InvoiceAbstract.freightlessnet End))*InvoiceDetail.IDENetAmount end as NetValue    
         from     
         (    
                Select isnull(Salesman.SalesMan_Name,'') SalesMan_Name ,customer.Company_Name,isnull(Beat.Description,'') as Beat,    
                       InvoiceAbstract.InvoiceDate,InvoiceAbstract.DocumentID,InvoiceAbstract.InvoiceID,    
                       InvoiceAbstract.GrossValue,InvoiceAbstract.SchemeDiscountAmount,    
                       InvoiceAbstract.DiscountValue,InvoiceAbstract.VatTaxAmount,InvoiceAbstract.NetValue,    
                       InvoiceAbstract.DiscountPercentage, InvoiceAbstract.SchemeDiscountPercentage,    
                       InvoiceAbstract.AdditionalDiscount,InvoiceAbstract.DiscAndScheme,    
                       InvoiceAbstract.Freight,InvoiceAbstract.FreightOrg,InvoiceAbstract.freightlessnet,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID 
                From #tmpInvoiceAbstract as InvoiceAbstract,customer,salesman,Beat          
                where     
                     InvoiceAbstract.CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS = Customer.CustomerID COLLATE SQL_Latin1_General_CP1_CI_AS
                     and InvoiceAbstract.SalesmanID = salesman.SalesmanID                  
                     and InvoiceAbstract.BeatID = Beat.BeatID                         
         ) InvoiceAbstract,    
         (    
                Select InvoiceDetail.InvoiceID,sum (InvoiceAbstract.MultFactor*InvoiceDetail.DiscountValue) as SchemeDiscount,    
                       sum(IsNull(InvoiceAbstract.MultFactor*InvoiceDetail.Quantity,0)) as IDEQuantity,    
                       sum(IsNull(InvoiceAbstract.MultFactor*InvoiceDetail.SalePrice,0)) as IDESalePrice,    
                       sum(InvoiceAbstract.MultFactor*IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)) as IDEGrossValue,    
                       sum(IsNull(InvoiceAbstract.MultFactor*InvoiceDetail.DiscountValue,0)) as IDEDiscountValue,    
                       sum(IsNull(InvoiceAbstract.MultFactor*InvoiceDetail.SchemeDiscAmount,0)) as IDESchemeDiscAmount,    
                       sum(IsNull(InvoiceAbstract.MultFactor*InvoiceDetail.SplCatDiscAmount,0)) as IDESplCatDiscAmount,    
                       sum(IsNull(InvoiceAbstract.MultFactor*InvoiceDetail.CSTPayable,0)) as IDECSTPayable,    
                       sum(IsNull(InvoiceAbstract.MultFactor*InvoiceDetail.STPayable,0)) as IDESTPayable,    
                       sum(IsNull(InvoiceAbstract.MultFactor*( (IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)) + InvoiceDetail.stpayable + InvoiceDetail.cstpayable - InvoiceDetail.discountvalue ),0)) as IDENetAmount,    
                       sum(InvoiceAbstract.MultFactor*(IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0))) as IDEDisc                          
                From InvoiceDetail, items,#tmpInvoiceAbstract as InvoiceAbstract,    
                     --ItemCategories    
                      (    
                          select #tempCategoryTree.CategoryID,isnull(productcategorygroupabstract.GroupName,'') as GroupName    
                          from productcategorygroupabstract, @TempCGCatMapping As productcategorygroupdetail,#tempCategoryTree    
                          where #tempCategoryTree.initParentCategoryID = productcategorygroupdetail.CategoryID    
                                and productcategorygroupabstract.GroupID = productcategorygroupDetail.GroupID    
                          group by #tempCategoryTree.CategoryID,productcategorygroupabstract.GroupName    
                      ) ItemCategories    
                where     
                     InvoiceDetail.Product_Code = Items.product_Code     
                     and InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID    
--                     and ItemCategories.CategoryID in (Select CategoryID from #tempCategory)      
                     and Items.CategoryID = ItemCategories.CategoryID        
--                      and InvoiceDetail.Amount >0              
               group by InvoiceDetail.InvoiceID    
         ) InvoiceDetail    
         where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID        
     ) tmp     

    If Exists(Select Top 1 Company_Name From #tmpData)
	Begin
		Insert Into #tmpCust
		Select c.CustomerID, c.Company_Name, m.Merchandise From #tmpData td, Customer c, CustMerchandise cm, Merchandise m
		Where td.Company_Name = c.Company_Name And c.CustomerID = cm.CustomerID And cm.MerchandiseID = m.MerchandiseID
		Set @Query = ''
		Set @QryStr = ', '
		Declare CurMD Cursor For
		Select Merchandise From Merchandise Order By Merchandise
		Open CurMD
		Fetch From CurMD Into @Merchandise
		While @@Fetch_Status = 0
		Begin
			Set @Query = 'Alter Table #tmpData Add [' + @Merchandise + '] nVarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS'
			Exec sp_executesql @Query
			Set @QryStr = Isnull(@QryStr,' , ') + '[' + @Merchandise + '], '
			Set @Query = 'Update #tmpData Set [' + @Merchandise + '] = ''No'''
			Exec sp_executesql @Query
			Set @Query = 'Update td Set [' + @Merchandise + '] = ''Yes'' From #tmpData td, #tmpCust c 
			Where td.Company_Name = c.CustomerName And c.Merchandise = ''' + @Merchandise + ''''
			Exec sp_executesql @Query
			Fetch From CurMD Into @Merchandise
		End
		Close CurMD
		Deallocate CurMD
	End

     select @RecCnt = count(*) from  #tmpData    
     declare @AllDS   nvarchar(255)      
     set @AllDS = 'All DS/Salesman'    
     if @RecCnt <=0     
     begin    
     	set @AllDS = ''    
     end    
         
     set @RptType = '0'    
    
     --1-ItemWise Only - Yes    
     if @ItemwiseOnly = N'Yes'    
     Begin    
          set @RptType = '1'    
          if @LevelOfReport = 'Sales'     
               begin     
                   select "KeyID" = (@RptType + @Delimiter + '' + @Delimiter + '' + @Delimiter +     
                          '' + @Delimiter + '' + @Delimiter +  ''),    
                          "DS Name" = @AllDS,     
                          "Sales - Gross Amount" = sum(GrossValue), "Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
                          "Sales - Discount" = sum(DiscountValue),"Sales - Vat Amount" = sum(VatTaxAmount), "Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
                   from  #tmpData       
               end    
          else if @LevelOfReport = 'Sales Return'     
               Begin    
                   select "KeyID" = (@RptType + @Delimiter + '' + @Delimiter + '' + @Delimiter +     
                          '' + @Delimiter + '' + @Delimiter +  ''),    
                          "DS Name" = @AllDS,     
                          "Sales Return - Gross Amount" = sum(GrossValue), "Sales Return - Scheme Discount" = sum(SchemeDiscountAmount),    
                          "Sales Return - Discount" = sum(DiscountValue),"Sales Return - Vat Amount" = sum(VatTaxAmount), "Sales Return - Net Amount" = sum(NetValue) - sum(DiscountValue)
                   from  #tmpData       
               End    
          else if @LevelOfReport = 'Net Sales'     
               Begin    
                   select "KeyID" = (@RptType + @Delimiter + '' + @Delimiter + '' + @Delimiter +     
                          '' + @Delimiter + '' + @Delimiter +  ''),    
                          "DS Name" = @AllDS,     
                          "Net Sales - Gross Amount" = sum(GrossValue), "Net Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
                          "Net Sales - Discount" = sum(DiscountValue),"Net Sales- Vat Amount" = sum(VatTaxAmount), "Net Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
    from  #tmpData       
               End    
          else if @LevelOfReport = 'All'     
               Begin    
                   select "KeyID" = (@RptType + @Delimiter + '' + @Delimiter + '' + @Delimiter +     
                          '' + @Delimiter + '' + @Delimiter +  ''),    
                          "DS Name" = @AllDS,     
                          "Gross Amount" = sum(GrossValue), "Scheme Discount" = sum(SchemeDiscountAmount),    
                          "Discount" = sum(DiscountValue),"Vat Amount" = sum(VatTaxAmount), "Net Amount" = sum(NetValue)- sum(DiscountValue)
                   from  #tmpData       
               End    
     End     
     --2-SalesmanWise-Summary/CustomerWise-NA/DateWise-NA     
     else if @ItemwiseOnly = N'No' and (@DSwise = N'Summary' or @DSwise = N'N/A')    
     Begin    
          set @RptType = '2'    
          if @LevelOfReport = 'Sales'     
               begin     
                   select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + '' + @Delimiter +     
                          '' + @Delimiter + '' + @Delimiter +  ''),"DS Name" = SalesMan_Name,    
                          "Sales - Gross Amount" = sum(GrossValue), "Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
                          "Sales - Discount" = sum(DiscountValue),"Sales - Vat Amount" = sum(VatTaxAmount), "Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
                   from  #tmpData   group by SalesMan_Name    
               end    
          else if @LevelOfReport = 'Sales Return'     
               Begin    
                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + '' + @Delimiter +     
                           '' + @Delimiter + '' + @Delimiter +  ''),"DS Name" = SalesMan_Name,    
                           "Sales Return - Gross Amount" = sum(GrossValue), "Sales Return - Scheme Discount" = sum(SchemeDiscountAmount),    
                           "Sales Return - Discount" = sum(DiscountValue),"Sales Return - Vat Amount" = sum(VatTaxAmount), "Sales Return - Net Amount" = sum(NetValue) - sum(DiscountValue)
                    from  #tmpData   group by SalesMan_Name    
               End    
          else if @LevelOfReport = 'Net Sales'     
               Begin    
                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + '' + @Delimiter +     
                           '' + @Delimiter + '' + @Delimiter +  ''),"DS Name" = SalesMan_Name,    
                           "Net Sales - Gross Amount" = sum(GrossValue), "Net Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
                           "Net Sales - Discount" = sum(DiscountValue),"Net Sales - Vat Amount" = sum(VatTaxAmount), "Net Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
                    from  #tmpData   group by SalesMan_Name    
               End    
          else if @LevelOfReport = 'All'     
               Begin    
                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + '' + @Delimiter +     
                           '' + @Delimiter + '' + @Delimiter +  ''),"DS Name" = SalesMan_Name,    
                           "Gross Amount" = sum(GrossValue), "Scheme Discount" = sum(SchemeDiscountAmount),    
                           "Discount" = sum(DiscountValue),"Vat Amount" = sum(VatTaxAmount), "Net Amount" = sum(NetValue) - sum(DiscountValue)
                    from  #tmpData   group by SalesMan_Name    
               End    
     End    
     --3-SalesmanWise-Detail/Beat-Summary/Customerwise-NA/DateWise-NA     
     else if @ItemwiseOnly = N'No' and @DSwise = N'Detail'  and (@Beat = N'Summary' or @Beat = N'N/A')    
     Begin    
          set @RptType = '3'    
          if @LevelOfReport = 'Sales'     
               begin     
                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + '' + @Delimiter +     
                           Beat + @Delimiter + '' + @Delimiter +  ''),"DS Name" = SalesMan_Name,"Beat" = Beat,    
                           "Sales - Gross Amount" = sum(GrossValue), "Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
                           "Sales - Discount" = sum(DiscountValue),"Sales - Vat Amount" = sum(VatTaxAmount), "Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
                    from  #tmpData   group by SalesMan_Name,Beat    
               end    
          else if @LevelOfReport = 'Sales Return'     
               Begin    
                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + '' + @Delimiter +     
                           Beat + @Delimiter + '' + @Delimiter +  ''),"DS Name" = SalesMan_Name,"Beat" = Beat,    
                           "Sales Return - Gross Amount" = sum(GrossValue), "Sales Return - Scheme Discount" = sum(SchemeDiscountAmount),    
                           "Sales Return - Discount" = sum(DiscountValue),"Sales Return - Vat Amount" = sum(VatTaxAmount), "Sales Return - Net Amount" = sum(NetValue) - sum(DiscountValue)
                    from  #tmpData   group by SalesMan_Name,Beat    
               End    
          else if @LevelOfReport = 'Net Sales'     
               Begin    
                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + '' + @Delimiter +     
                           Beat + @Delimiter + '' + @Delimiter +  ''),"DS Name" = SalesMan_Name,"Beat" = Beat,    
                           "Net Sales - Gross Amount" = sum(GrossValue), "Net Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
                           "Net Sales - Discount" = sum(DiscountValue),"Net Sales - Vat Amount" = sum(VatTaxAmount), "Net Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
                    from  #tmpData   group by SalesMan_Name,Beat    
               End    
          else if @LevelOfReport = 'All'     
               Begin    
                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + '' + @Delimiter +     
                           Beat + @Delimiter + '' + @Delimiter +  ''),"DS Name" = SalesMan_Name,"Beat" = Beat,    
                           "Gross Amount" = sum(GrossValue), "Scheme Discount" = sum(SchemeDiscountAmount),    
                           "Discount" = sum(DiscountValue),"Vat Amount" = sum(VatTaxAmount), "Net Amount" = sum(NetValue) - sum(DiscountValue)
                    from  #tmpData   group by SalesMan_Name,Beat    
               End    
     End    
     --4-SalesmanWise-Detail/Beat-Detail/CustomerWise-Summary/DateWise-NA     
     else if @ItemwiseOnly = N'No' and @DSwise = N'Detail' and @Beat = N'Detail' and (@Customerwise = N'Summary' or @Customerwise = N'N/A')    
     Begin    
          set @RptType = '4'    
          if @LevelOfReport = 'Sales'     
               begin
					If Exists(Select Top 1 * From Merchandise)
					Begin
	                    Set @Query = 'select "KeyID" = (''4'' + Char(15) + SalesMan_Name + Char(15) + Company_Name + Char(15) +     
	                           Beat + Char(15) + '''' + Char(15) + ''''),"DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name'+ Isnull(@QryStr,' , ') +'   
	                           "Sales - Gross Amount" = sum(GrossValue), "Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Sales - Discount" = sum(DiscountValue),"Sales - Vat Amount" = sum(VatTaxAmount), "Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData   group by SalesMan_Name,Beat'+ Isnull(@QryStr,' , ') +'Company_Name'
						Exec sp_executesql @Query
					End
					Else
					Begin
	                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + Company_Name + @Delimiter +     
	    Beat + @Delimiter + '' + @Delimiter +  ''),"DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name,    
	                           "Sales - Gross Amount" = sum(GrossValue), "Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Sales - Discount" = sum(DiscountValue),"Sales - Vat Amount" = sum(VatTaxAmount), "Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData   group by SalesMan_Name,Beat,Company_Name    
					End
               end
          else if @LevelOfReport = 'Sales Return'     
               Begin
					If Exists(Select Top 1 * From Merchandise)
					Begin					
	                    Set @Query = 'select "KeyID" = (''4'' + Char(15) + SalesMan_Name + Char(15) + Company_Name + Char(15) +     
	                           Beat + Char(15) + '''' + Char(15) + ''''),"DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name'+ Isnull(@QryStr,' , ') +'    
	                           "Sales Return - Gross Amount" = sum(GrossValue), "Sales Return - Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Sales Return - Discount" = sum(DiscountValue),"Sales Return - Vat Amount" = sum(VatTaxAmount), "Sales Return - Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData group by SalesMan_Name,Beat'+ Isnull(@QryStr,' , ') +'Company_Name'
						Exec sp_executesql @Query
					End
					Else
					Begin
	                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + Company_Name + @Delimiter +     
	                           Beat + @Delimiter + '' + @Delimiter +  ''),"DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name,    
	                           "Sales Return - Gross Amount" = sum(GrossValue), "Sales Return - Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Sales Return - Discount" = sum(DiscountValue),"Sales Return - Vat Amount" = sum(VatTaxAmount), "Sales Return - Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData   group by SalesMan_Name,Beat,Company_Name    
					End
               End    
          else if @LevelOfReport = 'Net Sales'     
               Begin  
					If Exists(Select Top 1 * From Merchandise)
					Begin
				        Set @Query = 'select "KeyID" = (''4'' + Char(15) + SalesMan_Name + Char(15) + Company_Name + Char(15) +
	                           Beat + Char(15) + '''' + Char(15) + ''''),"DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name'+ Isnull(@QryStr,' , ') +'
	                           "Net Sales -  Gross Amount" = sum(GrossValue), "Net Sales -  Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Net Sales -  Discount" = sum(DiscountValue),"Net Sales -  Vat Amount" = sum(VatTaxAmount), "Net Sales -  Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData group by SalesMan_Name,Beat'+ Isnull(@QryStr,' , ') +'Company_Name'
						Exec sp_executesql @Query
					End
					Else
					Begin
				        select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + Company_Name + @Delimiter +     
	                           Beat + @Delimiter + '' + @Delimiter +  ''),"DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name,    
	                           "Net Sales -  Gross Amount" = sum(GrossValue), "Net Sales -  Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Net Sales -  Discount" = sum(DiscountValue),"Net Sales -  Vat Amount" = sum(VatTaxAmount), "Net Sales -  Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData   group by SalesMan_Name,Beat,Company_Name    
					End
               End    
          else if @LevelOfReport = 'All'     
               Begin
					If Exists(Select Top 1 * From Merchandise)
					Begin
	                    Set @Query = 'select "KeyID" = (''4'' + Char(15) + SalesMan_Name + Char(15) + Company_Name + Char(15) +
	                           Beat + Char(15) + '''' + Char(15) + ''''),"DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name'+ Isnull(@QryStr,' , ') +'
	                           "Gross Amount" = sum(GrossValue), "Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Discount" = sum(DiscountValue),"Vat Amount" = sum(VatTaxAmount), "Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData group by SalesMan_Name,Beat'+ Isnull(@QryStr,' , ') +'Company_Name'
						Exec sp_executesql @Query
					End
					Else
					Begin
	                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + Company_Name + @Delimiter +     
	                           Beat + @Delimiter + '' + @Delimiter +  ''),"DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name,    
	                           "Gross Amount" = sum(GrossValue), "Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Discount" = sum(DiscountValue),"Vat Amount" = sum(VatTaxAmount), "Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData   group by SalesMan_Name,Beat,Company_Name    
					End
               End    
     End    
     else if @ItemwiseOnly = N'No' and @DSwise = N'Detail' and @Beat = N'Detail' and @Customerwise = N'Detail'  and (@Datewise = N'Summary' or @Datewise = N'N/A')    
     --5-SalesmanWise-Detail/Beat-Detail/CustomerWise-Detail/DateWise-Summary     
     Begin
          set @RptType = '5'     
          if @LevelOfReport = 'Sales'     
               begin     
					If Exists(Select Top 1 * From Merchandise)
					Begin					
	                    Set @Query = 'select "KeyID" = (''5'' + Char(15) + SalesMan_Name + Char(15) + Company_Name + Char(15) +
	                           Beat + Char(15) + cast(InvoiceDate as varchar(50)) + Char(15) +''''),"DS Name" = SalesMan_Name,Beat,"Customer" = Company_Name'+ Isnull(@QryStr,' , ') +' "Date" = InvoiceDate,    
	                           "Sales - Gross Amount" = sum(GrossValue), "Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Sales - Discount" = sum(DiscountValue),"Sales - Vat Amount" = sum(VatTaxAmount), "Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData group by SalesMan_Name,Beat,Company_Name'+ Isnull(@QryStr,' , ') +'InvoiceDate'
						Exec sp_executesql @Query
					End
					Else
					Begin
	                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + Company_Name + @Delimiter +     
	                           Beat + @Delimiter + cast(InvoiceDate as varchar(50)) + @Delimiter +  ''),"DS Name" = SalesMan_Name,Beat,"Customer" = Company_Name,"Date" = InvoiceDate,    
	                           "Sales - Gross Amount" = sum(GrossValue), "Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Sales - Discount" = sum(DiscountValue),"Sales - Vat Amount" = sum(VatTaxAmount), "Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData   group by SalesMan_Name,Beat,Company_Name,InvoiceDate    
					End
               end    
          else if @LevelOfReport = 'Sales Return'     
               Begin   
					If Exists(Select Top 1 * From Merchandise)
					Begin
	                    Set @Query = 'select "KeyID" = (''5'' + Char(15) + SalesMan_Name + Char(15) + Company_Name + Char(15) +     
	                           Beat + Char(15) + cast(InvoiceDate as varchar(50)) + Char(15) +''''),"DS Name" = SalesMan_Name,Beat,"Customer" = Company_Name'+ Isnull(@QryStr,' , ') +'"Date" = InvoiceDate,    
	                           "Sales Return - Gross Amount" = sum(GrossValue), "Sales Return - Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Sales Return - Discount" = sum(DiscountValue),"Sales Return - Vat Amount" = sum(VatTaxAmount), "Sales Return - Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData group by SalesMan_Name,Beat,Company_Name'+ Isnull(@QryStr,' , ') +' InvoiceDate'
						Exec sp_executesql @Query
					End
					Else
					Begin
	                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + Company_Name + @Delimiter +     
	                           Beat + @Delimiter + cast(InvoiceDate as varchar(50)) + @Delimiter +  ''),"DS Name" = SalesMan_Name,Beat,"Customer" = Company_Name,"Date" = InvoiceDate,    
	                           "Sales Return - Gross Amount" = sum(GrossValue), "Sales Return - Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Sales Return - Discount" = sum(DiscountValue),"Sales Return - Vat Amount" = sum(VatTaxAmount), "Sales Return - Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData   group by SalesMan_Name,Beat,Company_Name,InvoiceDate    
					End
               End    
          else if @LevelOfReport = 'Net Sales'     
               Begin    
					If Exists(Select Top 1 * From Merchandise)
					Begin
	                    Set @Query = 'select "KeyID" = (''5'' + Char(15) + SalesMan_Name + Char(15) + Company_Name + Char(15) + 
	                           Beat + Char(15) + cast(InvoiceDate as varchar(50)) + Char(15) + ''''),"DS Name" = SalesMan_Name,Beat,"Customer" = Company_Name'+ Isnull(@QryStr,' , ') +'"Date" = InvoiceDate,    
	                           "Net Sales -  Gross Amount" = sum(GrossValue), "Net Sales -  Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Net Sales -  Discount" = sum(DiscountValue),"Net Sales -  Vat Amount" = sum(VatTaxAmount), "Net Sales -  Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData group by SalesMan_Name,Beat,Company_Name'+ Isnull(@QryStr,' , ') +'InvoiceDate'
						Exec sp_executesql @Query
					End
					Else
					Begin
	                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + Company_Name + @Delimiter +     
	                           Beat + @Delimiter + cast(InvoiceDate as varchar(50)) + @Delimiter +  ''),"DS Name" = SalesMan_Name,Beat,"Customer" = Company_Name,"Date" = InvoiceDate,    
	                           "Net Sales -  Gross Amount" = sum(GrossValue), "Net Sales -  Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Net Sales -  Discount" = sum(DiscountValue),"Net Sales -  Vat Amount" = sum(VatTaxAmount), "Net Sales -  Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData   group by SalesMan_Name,Beat,Company_Name,InvoiceDate    
					End
          End    
      else if @LevelOfReport = 'All'     
               Begin    
					If Exists(Select Top 1 * From Merchandise)
					Begin
	                    Set @Query = 'select "KeyID" = (''5'' + Char(15) + SalesMan_Name + Char(15) + Company_Name + Char(15) +     
	                           Beat + Char(15) + cast(InvoiceDate as varchar(50)) + Char(15) +  ''''),"DS Name" = SalesMan_Name,Beat,"Customer" = Company_Name'+ Isnull(@QryStr,' , ') +'"Date" = InvoiceDate,    
	                           "Gross Amount" = sum(GrossValue), "Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Discount" = sum(DiscountValue),"Vat Amount" = sum(VatTaxAmount), "Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from #tmpData group by SalesMan_Name,Beat,Company_Name'+ Isnull(@QryStr,' , ') +'InvoiceDate' 
						Exec sp_executesql @Query
					End
					Else
					Begin
	                    select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + Company_Name + @Delimiter +     
	                           Beat + @Delimiter + cast(InvoiceDate as varchar(50)) + @Delimiter +  ''),"DS Name" = SalesMan_Name,Beat,"Customer" = Company_Name,"Date" = InvoiceDate,    
	                           "Gross Amount" = sum(GrossValue), "Scheme Discount" = sum(SchemeDiscountAmount),    
	                           "Discount" = sum(DiscountValue),"Vat Amount" = sum(VatTaxAmount), "Net Amount" = sum(NetValue) - sum(DiscountValue)
	                    from  #tmpData   group by SalesMan_Name,Beat,Company_Name,InvoiceDate    
					End
               End    
     End    
     --6-SalesmanWise-Detail/Beat-Detail/CustomerWise-Detail/DateWise-Detail     
     else if @ItemwiseOnly = N'No' and @DSwise = N'Detail' and @Beat = N'Detail' and @Customerwise = N'Detail'  and @Datewise = N'Detail'         
     Begin    
          set @RptType = '6'     
         if @LevelOfReport = 'Sales'     
              begin     
					If Exists(Select Top 1 * From Merchandise)
					Begin
						Set @Query = 'select "KeyID" = (''6'' + Char(15) + SalesMan_Name + Char(15) + Company_Name + Char(15) +
						      Beat + Char(15) + cast(InvoiceDate as varchar(50)) + Char(15) + cast([Invoice No] as varchar(50))),    
						      "DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name'+ Isnull(@QryStr,' , ') +'"Date" = InvoiceDate,    
						      "InvoiceNo" = cast([Invoice No] as varchar(50)),    
						      "Sales - Gross Amount" = sum(GrossValue), "Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
						      "Sales - Discount" = sum(DiscountValue),"Sales - Vat Amount" = sum(VatTaxAmount), "Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
						from  #tmpData group by SalesMan_Name,Beat,Company_Name'+ Isnull(@QryStr,' , ') +'InvoiceDate,[Invoice No]'
						Exec sp_executesql @Query
					End
					Else
					Begin
						select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + Company_Name + @Delimiter +     
						      Beat + @Delimiter + cast(InvoiceDate as varchar(50)) + @Delimiter +  cast([Invoice No] as varchar(50))),    
						      "DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name,"Date" = InvoiceDate,    
						      "InvoiceNo" = cast([Invoice No] as varchar(50)),    
						      "Sales - Gross Amount" = sum(GrossValue), "Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
						      "Sales - Discount" = sum(DiscountValue),"Sales - Vat Amount" = sum(VatTaxAmount), "Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
						from  #tmpData   group by SalesMan_Name,Beat,Company_Name,InvoiceDate,[Invoice No]    
					End
              end    
         else if @LevelOfReport = 'Sales Return'     
              Begin    
 					If Exists(Select Top 1 * From Merchandise)
					Begin
						Set @Query = 'select "KeyID" = (''6'' + Char(15) + SalesMan_Name + Char(15) + Company_Name + Char(15) +
						      Beat + Char(15) + cast(InvoiceDate as varchar(50)) + Char(15) + cast([Invoice No] as varchar(50))),    
						      "DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name'+ Isnull(@QryStr,' , ') +'"Date" = InvoiceDate,    
						      "InvoiceNo" = cast([Invoice No] as varchar(50)),    
						      "Sales Return - Gross Amount" = sum(GrossValue), "Sales Return - Scheme Discount" = sum(SchemeDiscountAmount),    
						      "Sales Return - Discount" = sum(DiscountValue),"Sales Return - Vat Amount" = sum(VatTaxAmount), "Sales Return - Net Amount" = sum(NetValue) - sum(DiscountValue)
						from  #tmpData group by SalesMan_Name,Beat,Company_Name'+ Isnull(@QryStr,' , ') +'InvoiceDate,[Invoice No]'
						Exec sp_executesql @Query
					End
					Else
					Begin
						select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + Company_Name + @Delimiter +     
						      Beat + @Delimiter + cast(InvoiceDate as varchar(50)) + @Delimiter +  cast([Invoice No] as varchar(50))),    
						      "DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name,"Date" = InvoiceDate,    
						      "InvoiceNo" = cast([Invoice No] as varchar(50)),    
						      "Sales Return - Gross Amount" = sum(GrossValue), "Sales Return - Scheme Discount" = sum(SchemeDiscountAmount),    
						      "Sales Return - Discount" = sum(DiscountValue),"Sales Return - Vat Amount" = sum(VatTaxAmount), "Sales Return - Net Amount" = sum(NetValue) - sum(DiscountValue)
						from  #tmpData   group by SalesMan_Name,Beat,Company_Name,InvoiceDate,[Invoice No]    
					End
              End    
         else if @LevelOfReport = 'Net Sales'     
              Begin    
  					If Exists(Select Top 1 * From Merchandise)
					Begin
						Set @Query = 'select "KeyID" = (''6'' + Char(15) + SalesMan_Name + Char(15) + Company_Name + Char(15) +
						      Beat + Char(15) + cast(InvoiceDate as varchar(50)) + Char(15) + cast([Invoice No] as varchar(50))),    
						      "DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name'+ Isnull(@QryStr,' , ') +'"Date" = InvoiceDate,    
						      "InvoiceNo" = cast([Invoice No] as varchar(50)),    
						      "Net Sales - Gross Amount" = sum(GrossValue), "Net Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
						      "Net Sales - Discount" = sum(DiscountValue),"Net Sales -Net - Vat Amount" = sum(VatTaxAmount), "Net Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
						from  #tmpData group by SalesMan_Name,Beat,Company_Name'+ Isnull(@QryStr,' , ') +'InvoiceDate,[Invoice No]'
						Exec sp_executesql @Query
					End
					Else
					Begin
						select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + Company_Name + @Delimiter +     
						      Beat + @Delimiter + cast(InvoiceDate as varchar(50)) + @Delimiter +  cast([Invoice No] as varchar(50))),    
						      "DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name,"Date" = InvoiceDate,    
						      "InvoiceNo" = cast([Invoice No] as varchar(50)),    
						      "Net Sales - Gross Amount" = sum(GrossValue), "Net Sales - Scheme Discount" = sum(SchemeDiscountAmount),    
						      "Net Sales - Discount" = sum(DiscountValue),"Net Sales -Net - Vat Amount" = sum(VatTaxAmount), "Net Sales - Net Amount" = sum(NetValue) - sum(DiscountValue)
						from  #tmpData   group by SalesMan_Name,Beat,Company_Name,InvoiceDate,[Invoice No]    
					End
              End    
         else if @LevelOfReport = 'All'     
              Begin    
					If Exists(Select Top 1 * From Merchandise)
					Begin
						Set @Query = 'select "KeyID" = (''6'' + Char(15) + SalesMan_Name + Char(15) + Company_Name + Char(15) +
						      Beat + Char(15) + cast(InvoiceDate as varchar(50)) + Char(15) + cast([Invoice No] as varchar(50))),    
						      "DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name'+ Isnull(@QryStr,' , ') +'"Date" = InvoiceDate,    
						      "InvoiceNo" = cast([Invoice No] as varchar(50)),    
						      "Gross Amount" = sum(GrossValue), "Scheme Discount" = sum(SchemeDiscountAmount),    
						      "Discount" = sum(DiscountValue),"Vat Amount" = sum(VatTaxAmount), "Net Amount" = sum(NetValue) - sum(DiscountValue)
						from  #tmpData group by SalesMan_Name,Beat,Company_Name'+ Isnull(@QryStr,' , ') +'InvoiceDate,[Invoice No]'
						Exec sp_executesql @Query
					End
					Else
					Begin
						select "KeyID" = (@RptType + @Delimiter + SalesMan_Name + @Delimiter + Company_Name + @Delimiter +     
						      Beat + @Delimiter + cast(InvoiceDate as varchar(50)) + @Delimiter +  cast([Invoice No] as varchar(50))),    
						      "DS Name" = SalesMan_Name,"Beat" = Beat,"Customer" = Company_Name,"Date" = InvoiceDate,    
						      "InvoiceNo" = cast([Invoice No] as varchar(50)),    
						      "Gross Amount" = sum(GrossValue), "Scheme Discount" = sum(SchemeDiscountAmount),    
						      "Discount" = sum(DiscountValue),"Vat Amount" = sum(VatTaxAmount), "Net Amount" = sum(NetValue) - sum(DiscountValue)
						from  #tmpData   group by SalesMan_Name,Beat,Company_Name,InvoiceDate,[Invoice No]    
					End
End    
     End    
    
----Drop Temporary tables    
Handler:    
drop table #tempCategory    
drop table #tempCategoryGroup    
drop table #tmpData    
drop table #tmpInvoiceAbstract    
drop table #tempCategoryName    
drop table #tempItemhierarchy    
drop table #tempCategoryTree    
drop table #tempCategory2    
drop table #tempCategoryTree2    
drop table #tmpCust
End
