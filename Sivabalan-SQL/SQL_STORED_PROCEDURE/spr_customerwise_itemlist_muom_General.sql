Create PROCEDURE spr_customerwise_itemlist_muom_General (@ProductHierarchy nVarchar(255),                
        @Category nVarchar(2550),                 
        @custchannel nvarchar(2550),                 
        @beat nvarchar(2550),
		@Merchandise nVarchar(2550),                
	 	@UOM nVarChar (100),  
        @fromdate datetime,                
        @todate datetime)                   

AS                  

DECLARE @UpdateSQL nvarchar(4000)                  
DECLARE @SelectSQL nvarchar(4000)                  
DECLARE @AlterSQL nvarchar(4000)                  
DECLARE @Cust_Name nvarchar(100)                  
DECLARE @Channel nvarchar(100)                  
DECLARE @Prod_Name nvarchar(100)                  
Declare @cust_temp nvarchar(4000)             
declare @Customer_name nvarchar(100)

DECLARE @Delimeter as Char(1)      
SET @Delimeter=Char(15)   
  
If @UOM = N'Base UOM'   
 Set @UOM = N'Sales UOM'  
   
Create Table #tmpBeat(Beat nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create Table #tmpChannel(Channel nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create Table #tmpChannelType( ChannelType int)  
Create table #tmpMerchandise(Merchandise nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpMerCust(Customer_Name nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)

If @Beat=N'%'       
 Insert into #tmpBeat Select Description from Beat      
Else      
 Insert into #tmpBeat Select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter)   
                
 Create Table #tempCategory(CategoryID int, Status int)                  
 Exec GetLeafCategories @ProductHierarchy, @Category                
  
                
IF @custchannel <> N'%'                                
BEGIN     
 Insert Into #tmpChannel Select * From dbo.Sp_SplitIn2rows(@CustChannel,@Delimeter)  
 Insert into #tmpChannelType Select ChannelType From Customer_Channel   
 Where ChannelDesc IN (Select * From #tmpChannel)    	
END                
                  
If @Merchandise = N'%' Or  @Merchandise = N''      
    Insert into #tmpMerchandise select Merchandise from Merchandise  order by Merchandise     
Else      
    Insert into #tmpMerchandise select * from dbo.sp_SplitIn2Rows(@Merchandise,@Delimeter)

                  
/* creating cursor to store all the retailers with the qty sold */                  
                
if @beat = N'%'                 
begin               
	IF @custchannel = N'%'                                 
	BEGIN                
		DECLARE items_cursor CURSOR FOR                   
		SELECT dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType, Items.ProductName,            
		"Quantity" =           
		Sum(Case InvoiceAbstract.InvoiceType           
		When 4 Then           
		Case  When (InvoiceAbstract.Status & 32) = 0  Then           
		0 -  (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity  
		When N'UOM1' Then  (case IsNull(UOM1_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM1_Conversion end)  
	        When N'UOM2' Then  (case IsNull(UOM2_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM2_Conversion end) End)    
		Else 0           
		End            
	        --Else InvoiceDetail.Quantity            
 		Else (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity  
	        When N'UOM1' Then  (case IsNull(UOM1_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM1_Conversion end)  
	        When N'UOM2' Then  (case IsNull(UOM2_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM2_Conversion end) End)  
		End),             
		Beat.description  
		FROM Customer
		inner join InvoiceAbstract on  	InvoiceAbstract.CustomerID = Customer.CustomerID 
		inner join InvoiceDetail on  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
		 inner join Items on InvoiceDetail.Product_Code = Items.Product_Code 
		inner join ItemCategories on ItemCategories.CategoryID = Items.CategoryID  
		inner join beat on  InvoiceAbstract.BeatID = Beat.BeatID                     
		WHERE  
		InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate AND   
		Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND              
		                
		(InvoiceAbstract.Status & 128) = 0 AND                
		InvoiceAbstract.InvoiceType <> 2 AND                
		ItemCategories.CategoryID in (Select CategoryID from #tempCategory)                 
		
		GROUP BY dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType,Items.ProductName,Beat.description                              
	END                          
	ELSE                                
	BEGIN                  
		DECLARE items_cursor CURSOR FOR                     
		SELECT dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType, Items.ProductName,            
		"Quantity" =           
		sum(Case InvoiceAbstract.InvoiceType           
		When 4 Then           
		case  When (InvoiceAbstract.Status & 32) = 0  Then           
		0 - (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity  
		When N'UOM1' Then  (case IsNull(UOM1_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM1_Conversion end)  
	        When N'UOM2' Then  (case IsNull(UOM2_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM2_Conversion end) End)  
		Else 0           
		End            
		--Else InvoiceDetail.Quantity            
		Else (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity  
		When N'UOM1' Then  (case IsNull(UOM1_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM1_Conversion end)  
	        When N'UOM2' Then  (case IsNull(UOM2_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM2_Conversion end) End)  
		End),          
		Beat.description  
		FROM Customer
		inner join InvoiceAbstract on InvoiceAbstract.CustomerID = Customer.CustomerID  
		inner join InvoiceDetail on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
		inner join Items on InvoiceDetail.Product_Code = Items.Product_Code  
		inner join ItemCategories on ItemCategories.CategoryID = Items.CategoryID  
		left outer join Beat on    InvoiceAbstract.BeatID = Beat.BeatID               
		WHERE   
		InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate AND             
		Customer.ChannelType IN (Select ChannelType From #tmpChannelType) and                  
		Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                        
		(InvoiceAbstract.Status & 128) = 0 AND                
		InvoiceAbstract.InvoiceType <> 2 AND                
		ItemCategories.CategoryID IN (Select CategoryID from #tempCategory)               
		
		GROUP BY Items.ProductName,Customer.ChannelType,dbo.EncodeQuotes(Customer.Company_Name), Beat.description                                  
	END              
end                 
else                
begin                      	                               
	IF @custchannel = N'%'                 
	                
	BEGIN                
	DECLARE items_cursor CURSOR FOR                   
	SELECT dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType, Items.ProductName,            
	"Quantity" =           
	sum(Case InvoiceAbstract.InvoiceType           
	When 4 Then           
	case  When (InvoiceAbstract.Status & 32) = 0  Then           
	0 -  (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity  
	       When N'UOM1' Then  (case IsNull(UOM1_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM1_Conversion end)  
	       When N'UOM2' Then  (case IsNull(UOM2_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM2_Conversion end) End)  
	Else 0           
	End            
	--Else InvoiceDetail.Quantity            
	Else (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity  
	       When N'UOM1' Then  (case IsNull(UOM1_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM1_Conversion end)  
	       When N'UOM2' Then  (case IsNull(UOM2_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM2_Conversion end) End)  
	End),          
	Beat.description  
	FROM Customer
		inner join InvoiceAbstract on InvoiceAbstract.CustomerID = Customer.CustomerID  
		inner join InvoiceDetail on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
		inner join Items on InvoiceDetail.Product_Code = Items.Product_Code  
		inner join ItemCategories on ItemCategories.CategoryID = Items.CategoryID  
		left outer join Beat on    InvoiceAbstract.BeatID = Beat.BeatID         
	WHERE  
	InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate And               
	 Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                
	 (InvoiceAbstract.Status & 128) = 0 AND                
	 InvoiceAbstract.InvoiceType <> 2 AND                
	 ItemCategories.CategoryID in (Select CategoryID from #tempCategory)               
	 
	GROUP BY dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType,Items.ProductName,Beat.description                
	                
	END                
	                
	ELSE                
	                
	BEGIN                  
	DECLARE items_cursor CURSOR FOR                     
	SELECT dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType, Items.ProductName,            
	"Quantity" =           
	sum(Case InvoiceAbstract.InvoiceType           
	When 4 Then           
	case  When (InvoiceAbstract.Status & 32) = 0  Then           
	0 -  (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity  
	       When N'UOM1' Then  (case IsNull(UOM1_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM1_Conversion end)  
	       When N'UOM2' Then  (case IsNull(UOM2_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM2_Conversion end) End)  
	Else 0           
	End            
	--Else InvoiceDetail.Quantity            
	Else (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity  
	       When N'UOM1' Then  (case IsNull(UOM1_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM1_Conversion end)  
	       When N'UOM2' Then  (case IsNull(UOM2_Conversion,0) when 0 then 0 else InvoiceDetail.Quantity / UOM2_Conversion end) End)  
	End),          
	Beat.description  
	FROM Customer,Items,InvoiceDetail,InvoiceAbstract,ItemCategories,Beat                  
	WHERE   
	InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate And 
	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and                  
	InvoiceAbstract.CustomerID = Customer.CustomerID and 
	InvoiceDetail.Product_Code = Items.Product_Code and  
	Customer.ChannelType IN (Select ChannelType From #tmpChannelType) and                  
	 ItemCategories.CategoryID = Items.CategoryID AND                
	 InvoiceAbstract.BeatID = Beat.BeatID AND                 
	 Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                
	 (InvoiceAbstract.Status & 128) = 0 AND                
	 InvoiceAbstract.InvoiceType <> 2 AND                
	 ItemCategories.CategoryID in (Select CategoryID from #tempCategory)
	 
	GROUP BY Items.ProductName,Customer.ChannelType, dbo.EncodeQuotes(Customer.Company_Name), Beat.description                  
	        
	END      
                  
end                  
                
/*  unique product name from invoice table  */                                  
                
if @beat = N'%'                
begin                
                
                
IF @custchannel = N'%'                 
BEGIN                    
DECLARE unique_items CURSOR FOR                   
SELECT distinct Items.ProductName                   
FROM Items
inner join InvoiceDetail on InvoiceDetail.Product_code = Items.Product_Code            
inner join ItemCategories on  ItemCategories.CategoryID = Items.CategoryID  
inner join InvoiceAbstract on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID    
left outer join Beat on InvoiceAbstract.BeatID = Beat.BeatID 
,Customer        
               
WHERE 
InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate And 
 Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                             
 (InvoiceAbstract.Status & 128) = 0 AND      
 InvoiceAbstract.InvoiceType <> 2 AND                
 ItemCategories.CategoryID in (Select CategoryID from #tempCategory) 
 
END                
ELSE                
BEGIN                               
DECLARE unique_items CURSOR FOR                   
SELECT distinct Items.ProductName       
FROM Items
 inner join InvoiceDetail on InvoiceDetail.Product_code = Items.Product_Code   
 inner join Customer on   Customer.ChannelType IN (Select ChannelType From #tmpChannelType)         
 inner join ItemCategories on  ItemCategories.CategoryID = Items.CategoryID  
  inner join InvoiceAbstract on   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID     
left outer join Beat          on    InvoiceAbstract.BeatID = Beat.BeatID   
WHERE 
     InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate And
      Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                 
      (InvoiceAbstract.Status & 128) = 0 AND                
      InvoiceAbstract.InvoiceType <> 2 AND                
      ItemCategories.CategoryID in (Select CategoryID from #tempCategory) 
      
END                
end                
else                
begin                
	IF @custchannel = N'%'                 
	BEGIN                      
		DECLARE unique_items CURSOR FOR                   
		SELECT distinct Items.ProductName                   
		FROM Items
		inner join InvoiceDetail on InvoiceDetail.Product_code = Items.Product_Code  
		inner join ItemCategories on ItemCategories.CategoryID = Items.CategoryID  
		inner join InvoiceAbstract on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
		left outer join Beat on InvoiceAbstract.BeatID = Beat.BeatID  
		,Customer                     
		WHERE 
		InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate And 
		Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                
	        (InvoiceAbstract.Status & 128) = 0 AND                  
	        InvoiceAbstract.InvoiceType <> 2 AND                
	        ItemCategories.CategoryID in (Select CategoryID from #tempCategory) 
	        
	END                
	ELSE                
	BEGIN                
		DECLARE unique_items CURSOR FOR                   
		SELECT distinct Items.ProductName                    
		FROM Items
		inner join InvoiceDetail on InvoiceDetail.Product_code = Items.Product_Code  
		inner join ItemCategories on ItemCategories.CategoryID = Items.CategoryID  
		inner join InvoiceAbstract on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
		left outer join Beat on InvoiceAbstract.BeatID = Beat.BeatID  
		inner join Customer  on  Customer.ChannelType  IN (Select ChannelType From #tmpChannelType)               
		WHERE 
		InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate And                      
		Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                
	        (InvoiceAbstract.Status & 128) = 0 AND                
	        InvoiceAbstract.InvoiceType <> 2 AND                
	        ItemCategories.CategoryID in (Select CategoryID from #tempCategory)  
	END                
end                
              
/* creating temp table and store values */                  
                  
/*CREATE TABLE #final(Cust_Temp_Name nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Customer_Name nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Channel nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    Beat nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)                  */

CREATE TABLE #final(Cust_Temp_Name nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    Customer_Name nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)  

Declare @Merchandise_Name nVarchar(4000)
declare Cur_Merchandise Cursor for Select Merchandise From #tmpMerchandise
Open Cur_Merchandise
FETCH From  Cur_Merchandise into @Merchandise_Name
While @@FETCH_STATUS=0
Begin
	 SET @AlterSQL = 'ALTER TABLE #final Add [' + @Merchandise_Name +  N'] nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS default ''No'' '                   
	 EXEC sp_executesql @AlterSQL                  
	 FETCH From  Cur_Merchandise into @Merchandise_Name 		    	
End 
close Cur_Merchandise
deallocate Cur_Merchandise	

-- "Channel" column name has been renamed to "Customer Type"

CREATE TABLE #OLClassMapping (CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  

Insert Into #OLClassMapping 
Select  olcm.CustomerId, olc.Channel_Type_Desc, olc.Outlet_Type_Desc, 
olc.SubOutlet_Type_Desc 
From tbl_merp_olclass olc, tbl_merp_olclassmapping olcm
Where olc.ID = olcm.OLClassID And
olc.Channel_Type_Active = 1 And olc.Outlet_Type_Active = 1 And olc.SubOutlet_Type_Active = 1 And 
olcm.Active = 1 

SET @AlterSQL = 'ALTER TABLE #final Add [Customer Type] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Beat] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS '                   

EXEC sp_executesql @AlterSQL 

if @beat = N'%'                
begin                            
	IF @custchannel = N'%'                 
	BEGIN                
		INSERT INTO #final (Cust_Temp_Name, Customer_Name, [Customer Type], [Channel Type], [Outlet Type], 
		[Loyalty Program], Beat)                
		SELECT distinct dbo.EncodeQuotes(Customer.Company_Name), dbo.EncodeQuotes(Customer.Company_Name),              
		case isnull(Customer.ChannelType,0)         
		When 0 Then        
			Dbo.LookupDictionaryItem('Others',Default)  
		Else        
			Customer_Channel.ChannelDesc        
		End,               

		Case IsNull(olcm.[Channel Type], '') 
		When '' Then 
			Dbo.LookupDictionaryItem('To be defined',Default)
		Else 
			olcm.[Channel Type]
		End,

		Case IsNull(olcm.[Outlet Type], '') 
		When '' Then 
			Dbo.LookupDictionaryItem('To be defined',Default)
		Else 
			olcm.[Outlet Type]
		End,

		Case IsNull(olcm.[Loyalty Program], '') 
		When '' Then 
			Dbo.LookupDictionaryItem('To be defined',Default)
		Else 
			olcm.[Loyalty Program] 
		End,

		Beat.description                                  
		FROM InvoiceAbstract
		inner join Customer on InvoiceAbstract.CustomerID = Customer.CustomerID   
		left outer join Beat on InvoiceAbstract.BeatID = Beat.BeatID  
		right outer join Customer_Channel on Customer_Channel.ChannelType = Customer.ChannelType 
		right outer join #OLClassMapping olcm on olcm.CustomerID = Customer.CustomerID  
		WHERE 
		InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate And 	
		(InvoiceAbstract.Status & 128) = 0 AND                  
		InvoiceAbstract.InvoiceType <> 2      
		GROUP BY dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType, InvoiceAbstract.CustomerID,Beat.Description, Customer_Channel.ChannelDesc,
		olcm.[Channel Type] ,olcm.[Outlet Type] , olcm.[Loyalty Program]
	END                
	ELSE                
	BEGIN                             
		INSERT INTO #final  (Cust_Temp_Name, Customer_Name, [Customer Type], [Channel Type], [Outlet Type], 
		[Loyalty Program], Beat)                 
		SELECT distinct dbo.EncodeQuotes(Customer.Company_Name), dbo.EncodeQuotes(Customer.Company_Name),               
		case isnull(Customer.ChannelType,0)         
		When 0 Then        
			Dbo.LookupDictionaryItem('Others',Default)  
		Else        
			Customer_Channel.ChannelDesc        
		End,                 

		Case IsNull(olcm.[Channel Type], '') 
		When '' Then 
			Dbo.LookupDictionaryItem('To be defined',Default)
		Else 
			olcm.[Channel Type]
		End,

		Case IsNull(olcm.[Outlet Type], '') 
		When '' Then 
			Dbo.LookupDictionaryItem('To be defined',Default)
		Else 
			olcm.[Outlet Type]
		End,

		Case IsNull(olcm.[Loyalty Program], '') 
		When '' Then 
			Dbo.LookupDictionaryItem('To be defined',Default)
		Else 
			olcm.[Loyalty Program] 
		End,

		Beat.description                                
		FROM InvoiceAbstract
		inner join Customer on InvoiceAbstract.CustomerID = Customer.CustomerID   
		left outer join Beat on InvoiceAbstract.BeatID = Beat.BeatID  
		right outer join Customer_Channel on Customer_Channel.ChannelType = Customer.ChannelType 
		right outer join #OLClassMapping olcm on olcm.CustomerID = Customer.CustomerID  
		WHERE 
		InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate And 
		Customer.ChannelType  IN (Select ChannelType From #tmpChannelType) AND                      
		(InvoiceAbstract.Status & 128) = 0 AND                  
		InvoiceAbstract.InvoiceType <> 2 
		
		GROUP BY dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType, InvoiceAbstract.CustomerID,Beat.Description, Customer_Channel.ChannelDesc,
		olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program] 

	END                                 
end                 
else                
begin                
	IF @custchannel = N'%'                 
	BEGIN                
		INSERT INTO #final (Cust_Temp_Name, Customer_Name, [Customer Type], [Channel Type], [Outlet Type], 
		[Loyalty Program], Beat)                	               
		SELECT distinct dbo.EncodeQuotes(Customer.Company_Name), dbo.EncodeQuotes(Customer.Company_Name),               
		case isnull(Customer.ChannelType,0)         
		When 0 Then        
		Dbo.LookupDictionaryItem('Others',Default)  
		Else        
		Customer_Channel.ChannelDesc        
		End,             

		Case IsNull(olcm.[Channel Type], '') 
		When '' Then 
			Dbo.LookupDictionaryItem('To be defined',Default)
		Else 
			olcm.[Channel Type]
		End,

		Case IsNull(olcm.[Outlet Type], '') 
		When '' Then 
			Dbo.LookupDictionaryItem('To be defined',Default)
		Else 
			olcm.[Outlet Type]
		End,

		Case IsNull(olcm.[Loyalty Program], '') 
		When '' Then 
			Dbo.LookupDictionaryItem('To be defined',Default)
		Else 
			olcm.[Loyalty Program] 
		End,
 
		Isnull(Beat.description,0)                
		                  
	FROM InvoiceAbstract
		inner join Customer on InvoiceAbstract.CustomerID = Customer.CustomerID   
		left outer join Beat on InvoiceAbstract.BeatID = Beat.BeatID  
		right outer join Customer_Channel on Customer_Channel.ChannelType = Customer.ChannelType 
		right outer join #OLClassMapping olcm on olcm.CustomerID = Customer.CustomerID              
		WHERE 
		InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate And              
		 Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) and        
		(InvoiceAbstract.Status & 128) = 0 AND                  
		InvoiceAbstract.InvoiceType <> 2 
		      
		GROUP BY dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType, InvoiceAbstract.CustomerID,Beat.Description, Customer_Channel.ChannelDesc,
		olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program] 

	END                
	ELSE                
	BEGIN                                
		INSERT INTO #final  (Cust_Temp_Name, Customer_Name, [Customer Type], [Channel Type], [Outlet Type], 
		[Loyalty Program], Beat)             		                
		SELECT distinct dbo.EncodeQuotes(Customer.Company_Name), dbo.EncodeQuotes(Customer.Company_Name),               
		case isnull(Customer.ChannelType,0)         
		When 0 Then        
		Dbo.LookupDictionaryItem('Others',Default)  
		Else        
		Customer_Channel.ChannelDesc        
		End,              

		Case IsNull(olcm.[Channel Type], '') 
		When '' Then 
			Dbo.LookupDictionaryItem('To be defined',Default)
		Else 
			olcm.[Channel Type]
		End,

		Case IsNull(olcm.[Outlet Type], '') 
		When '' Then 
			Dbo.LookupDictionaryItem('To be defined',Default)
		Else 
			olcm.[Outlet Type]
		End,

		Case IsNull(olcm.[Loyalty Program], '') 
		When '' Then 
			Dbo.LookupDictionaryItem('To be defined',Default)
		Else 
			olcm.[Loyalty Program] 
		End,

		Beat.description                		                
		FROM InvoiceAbstract
		inner join Customer on InvoiceAbstract.CustomerID = Customer.CustomerID   
		left outer join Beat on InvoiceAbstract.BeatID = Beat.BeatID  
		right outer join Customer_Channel on Customer_Channel.ChannelType = Customer.ChannelType 
		right outer join #OLClassMapping olcm on olcm.CustomerID = Customer.CustomerID  
		WHERE 
		InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate  And 
		Customer.ChannelType  IN (Select ChannelType From #tmpChannelType) AND        
		Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) and        
		(InvoiceAbstract.Status & 128) = 0 AND                  
		InvoiceAbstract.InvoiceType <> 2              
		GROUP BY dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType,               
		InvoiceAbstract.CustomerID,Beat.Description, Customer_Channel.ChannelDesc,
		olcm.[Channel Type] , olcm.[Outlet Type] , olcm.[Loyalty Program] 
      
	END                  
                
end                
              
-- altering the table to insert the item as fields                   
      
                  
OPEN unique_items                  
FETCH FROM unique_items Into @Prod_Name                  
                  
WHILE @@FETCH_STATUS = 0                  
BEGIN                   
 If CHARINDEX('[',@Prod_Name,1) <> 0 or  CHARINDEX(']',@Prod_Name,1) <> 0     
 Begin    
 Set @Prod_Name = Replace(@Prod_Name, '[',' ')    
 Set @Prod_Name = Replace(@Prod_Name, ']',' ')    
 End    
  
 SET @AlterSQL = N'ALTER TABLE #final Add [' + @Prod_Name +  '] Decimal(18,6) null'                   
 EXEC sp_executesql @AlterSQL                  
 FETCH NEXT FROM unique_items INTO @Prod_Name                  
END                  
                
-- updating the table                   
                  
DECLARE @C_Name nvarchar(500)                  
DECLARE @Chan nvarchar(500)                  
DECLARE @ITEM_NAME nvarchar(100)                  
DECLARE @item_Qty Decimal(18,6)                
DECLARE @Product nvarchar(100)                  
DECLARE @BeatName nvarchar(510)                  
                  
OPEN items_cursor                  
        
FETCH FROM items_cursor Into @C_Name, @Chan, @Product, @item_Qty ,@BeatName  
        
IF @@fetch_status <> 0                 
BEGIN                
delete from #final             
select * from #final                
goto exitproc                
END                
Create Table #customer (Customer_Name  nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Beat nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
--set @cust_temp = Isnull (@cust_temp,N'')                
              
Declare @PrevCus nVarchar(255)              
        
WHILE @@FETCH_STATUS = 0                  
BEGIN                    
           
 If IsNull(@PrevCus, N'') <> @C_Name          
 Begin              
  Set @PrevCus = @C_Name              
--  If IsNull(@cust_temp, N'') = N''                  
   Insert Into #customer Values (@C_Name, @BeatName)             
--  else              
--   Insert Into #customer Values (@C_Name, @BeatName)              
 End              
     
 If CHARINDEX(N'[',@Product,1) <> 0 or  CHARINDEX(N']',@Product,1) <> 0     
 Begin    
 Set @Product = Replace(@Product, N'[',N' ')    
 Set @Product = Replace(@Product, N']',N' ')    
 End        
    
 SET @UpdateSQL = N'Update #final Set [' + @Product + N'] = ' + cast (@item_Qty  as varchar) + N' Where Customer_Name collate SQL_Latin1_General_Cp1_CI_AS = '''+ dbo.EncodeQuotes(@C_Name)  + N''' and Isnull(Beat,'''') collate SQL_Latin1_General_Cp1_CI_AS
  =  ''' + dbo.EncodeQuotes(Isnull(@BeatName,N'')) + N''''    
  
 exec sp_executesql @UpdateSQL                 
 FETCH NEXT FROM items_cursor Into @C_Name, @Chan, @Product, @item_Qty, @BeatName                   
END

/* Updating the Merchandise */                 


declare Cur_Uptmerchan Cursor for
select isnull(M.Merchandise,'No'),Cus.Company_name 
from customer Cus,CustMerchandise CM,Merchandise M,#Customer 
where 
M.Merchandise in (select Merchandise COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMerchandise) And 
cus.Company_Name=Customer_name 
and CM.CustomerID=cus.CustomerID
and CM.Merchandiseid=m.MerchandiseID 
Open Cur_Uptmerchan
Fetch From Cur_Uptmerchan into @Merchandise_Name,@Customer_name
While @@Fetch_STATUS=0
Begin
        SET @UpdateSQL = N'Update #final Set [' + @Merchandise_Name + N'] = ''Yes'' Where Customer_Name collate SQL_Latin1_General_Cp1_CI_AS = '''+ dbo.EncodeQuotes(@Customer_name)  + N''''      
	exec sp_executesql @UpdateSQL                 					
	Fetch From Cur_Uptmerchan into @Merchandise_Name,@Customer_name	
End 
Close Cur_Uptmerchan
Deallocate Cur_Uptmerchan

insert into #tmpMerCust
select Cus.Company_name 
from customer Cus,CustMerchandise CM,Merchandise M,#Customer 
where 
M.Merchandise in (select Merchandise COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMerchandise) And
cus.Company_Name=Customer_name 
and CM.CustomerID=cus.CustomerID
and CM.Merchandiseid=m.MerchandiseID 

if @Merchandise=N'%' or @Merchandise=N''      
	Select * From #final Where Customer_Name collate SQL_Latin1_General_Cp1_CI_AS in (Select Customer_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #customer)              
else
	Select * From #final Where Customer_Name collate SQL_Latin1_General_Cp1_CI_AS in (Select Customer_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpMerCust)              

drop table #customer                   
exitproc:                  
Close items_cursor                  
DeAllocate items_cursor                
Close unique_items                
DeAllocate unique_items                
drop table #final                
drop table #tempCategory         
Drop Table #tmpBeat  
Drop Table #tmpChannel       
Drop Table #tmpChannelType  
Drop Table #tmpMerchandise
Drop Table #tmpMerCust
