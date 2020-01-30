create Function fn_GetCGFrmCGtype_Itc_RPT(@GroupNames nvarchar(4000), @Hierarchy NVARCHAR(50), @CGtype nvarchar(100),@Fromdate datetime,@Todate datetime, @ParamDelimiter Char(1) = ',')    
Returns @CatID Table (CatID Int,GroupName nvarchar(255),CombinedGroupName nvarchar(max))    
As    
Begin
/*
set dateformat dmy
Declare @GroupNames nvarchar(4000)
Declare @Hierarchy NVARCHAR(50)
Declare @CGtype nvarchar(100)
Declare @ParamDelimiter Char(1)
declare @Fromdate datetime
Declare @Todate datetime

set @GroupNames='%'
set @Hierarchy='Division'
set @CGtype='Operational'
set @ParamDelimiter=','
set @Fromdate='31 jan 2009 00:00:00:000'
set @Todate='07 jul 2013 23:59:59:000'
Declare @CatID Table (CatID Int,GroupName nvarchar(255))    
*/


Declare @CategoryID int, @groupid int
Declare @Delimiter as Char(1)

IF CHARINDEX(@ParamDelimiter , @GroupNames,1) > 0 
Begin
    Set @Delimiter = @ParamDelimiter  
End
Else
Begin
    Set @Delimiter = Char(15) 
End
  
Declare @TempCGCatMapping Table (GroupID Int, Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CategoryID Int, CategoryName nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

declare @tmpProductCategorygroupAbstract Table(GroupName NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS,GroupID int)  

Declare @ItemsInvoiced Table(Product_code NVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert into @ItemsInvoiced Select distinct Product_code from invoicedetail,invoiceabstract where Invoiceabstract.invoiceid = invoicedetail.invoiceid And
Convert(Nvarchar(10),InvoiceAbstract.InvoiceDate ,103) Between @FromDate And @ToDate and InvoiceAbstract.Status & 128 = 0  and InvoiceAbstract.InvoiceType in (1,3) and isnull(invoiceabstract.netvalue,0)> 0
Declare @TmpOutput Table (CatID Int,GroupName nvarchar(255))   

  
if @GroupNames = N'%%'  or @GroupNames = N'%'  
Begin  
 If @CGtype = 'Operational'  
 Begin  
  Insert into @tmpProductCategorygroupAbstract     
  select GroupName,GroupID From ProductCategorygroupAbstract Where isnull(OCGtype ,0) = 1  
 End  
 Else If @CGtype = 'Regular'  
 Begin  
  Insert into @tmpProductCategorygroupAbstract     
  select GroupName,GroupID From ProductCategorygroupAbstract Where GroupName in (Select distinct CategoryGroup from tblcgdivmapping)  
 End  
End    
Else    
Begin  
    Insert into @tmpProductCategorygroupAbstract   
    select GroupName,GroupID From ProductCategorygroupAbstract  
    Where ProductCategorygroupAbstract.GroupName in    
    (Select * from dbo.sp_SplitIn2Rows(@GroupNames,@Delimiter))    
End    
If @CGtype = 'Regular' 
Begin
    Insert InTo @TempCGCatMapping  
    Select "GroupID" = pcga.GroupID, "GroupName" = cgdm.CategoryGroup, 
    "CategoryID" = icat.CategoryID, "CategoryName" = cgdm.Division
    From tblcgdivmapping cgdm, ProductCategoryGroupAbstract pcga, ItemCategories icat
    Where cgdm.CategoryGroup = pcga.GroupName And cgdm.Division = icat.Category_Name

    declare @tempItemhierarchy Table(HierarchyID int)    

    If @Hierarchy = N'%%' or @Hierarchy = N'%' or @Hierarchy  = 'Division'  
        Insert Into @tempItemhierarchy Select HierarchyID From Itemhierarchy where hierarchyid = 2 --SecondLevel is the default  
    Else
        Insert Into @tempItemhierarchy   
        select HierarchyID From Itemhierarchy    
        where HierarchyName = @Hierarchy  
  
--Find all Category which are parent or Child or same for the Category group  
    Declare @RootToChild Table(CategoryId int,HierarchyID int,GroupName nvarchar(255))        
	
    DECLARE CRootToChild CURSOR KEYSET FOR                                
    SELECT CategoryID from  
    (  
    select distinct CategoryID
    from   
        @tmpProductCategorygroupAbstract as ProductCategorygroupAbstract, @TempCGCatMapping as ProductCategorygroupDetail  
    where ProductCategorygroupAbstract.groupid = ProductCategorygroupDetail.groupid  
    ) tmp  

    Open CRootToChild                                
    Fetch From CRootToChild into @CategoryID                              
    WHILE @@FETCH_STATUS = 0                                
    BEGIN     
        insert into @RootToChild (CategoryId,HierarchyID) 
        select * from sp_get_Catergory_RootToChild(@CategoryID)  
		
        Fetch next From CRootToChild into @CategoryID
    END  
    Deallocate CRootToChild  
  
    Insert @CatID   
    select distinct CategoryID,'','' from @RootToChild  
    where HierarchyID In (Select HierarchyID From @tempItemhierarchy)    
End  
Else    
Begin
    If @Hierarchy = N'%%' or @Hierarchy = N'%' or @Hierarchy  = ''  
        Select @Hierarchy  = 'Division'
	Declare @GroupName nvarchar(255)
    DECLARE GetGrpId CURSOR KEYSET FOR SELECT GroupId,GroupName from @tmpProductCategorygroupAbstract 
    Open GetGrpId
    Fetch From GetGrpId into @GroupId,@GroupName
    WHILE @@FETCH_STATUS = 0
    BEGIN
		If @Hierarchy ='Division'
		Begin
			Insert into @TmpOutput(CatID,GroupName)
			select Distinct IC.CategoryID,@GroupName  From ItemCategories IC, OCGItemMaster FN,@ItemsInvoiced I Where isnull(Level,0)=2
			And FN.Division = IC.Category_Name
			And isnull(FN.Exclusion,0)=0
			And FN.GroupName=@GroupName
			And FN.SystemSKU=I.Product_code
		End
		Else if @Hierarchy='Sub_Category'
			Insert into  @TmpOutput(CatID,GroupName)
			select Distinct IC.CategoryID,@GroupName From ItemCategories IC, OCGItemMaster FN,@ItemsInvoiced I Where isnull(Level,0)=3
			And FN.Subcategory = IC.Category_Name
			And isnull(FN.Exclusion,0)=0
			And FN.GroupName=@GroupName
			And FN.SystemSKU=I.Product_code
		Else if @Hierarchy='Market_SKU'
			Insert into  @TmpOutput(CatID,GroupName)
			select Distinct IC.CategoryID,@GroupName From ItemCategories IC, OCGItemMaster FN,@ItemsInvoiced I Where isnull(Level,0)=4
			And FN.MarketSKU = IC.Category_Name
			And isnull(FN.Exclusion,0)=0
			And FN.GroupName=@GroupName
			And FN.SystemSKU=I.Product_code
		Fetch next from GetGrpId into @GroupId,@GroupName
    END
    Close GetGrpId
    Deallocate GetGrpId

	DECLARE @combinedString VARCHAR(MAX)
	Declare @OCatID int

	Declare ReturnOutput Cursor For Select distinct CatID from @TmpOutput
	Open ReturnOutput
	Fetch from ReturnOutput into @OCatID
	While @@Fetch_status =0
	Begin	
		SELECT @combinedString = COALESCE(@combinedString + ', ', '') + GroupName
		FROM @TmpOutput
		WHERE CatID=@OCatID
		
		insert into @CatID Select @OCatID,GroupName,@combinedString
		FROM @TmpOutput
		WHERE CatID=@OCatID
		set @combinedString=NULL
		Fetch next from ReturnOutput into @OCatID
	End
	Close ReturnOutput
	Deallocate ReturnOutput

End  

Return    
End    
