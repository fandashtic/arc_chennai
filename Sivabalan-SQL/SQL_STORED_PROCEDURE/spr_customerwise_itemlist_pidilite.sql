Create PROCEDURE [dbo].[spr_customerwise_itemlist_pidilite](@ProductHierarchy nVarchar(255),                  
        @Category nVarchar(2550),                   
        @custchannel nvarchar(2550),                   
        @beat nvarchar(2550),    
		@Customer nvarchar(2550),
        @UOM nVarChar(100),                  
        @fromdate datetime,                  
        @todate datetime)                     
                    
AS                    
                    
DECLARE @UpdateSQL nvarchar(4000)                    
DECLARE @SelectSQL nvarchar(4000)                    
DECLARE @AlterSQL nvarchar(4000)                    
DECLARE @Cust_Name nvarchar(100)                    
DECLARE @Channel nvarchar(100)                    
DECLARE @Prod_Name nvarchar(100)                    
--DECLARE @Channel_Type int                   
declare @cust_temp nvarchar(4000)                
                  
DECLARE @Delimeter as Char(1)        
SET @Delimeter=Char(15)      
Create Table #tmpBeat(Beat nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create Table #tmpChannel(Channel nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create Table #tmpChannelType( ChannelType int)    
Create table #tmpCustomer(Customer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
If @Beat=N'%'         
 Insert into #tmpBeat Select Description from Beat        
Else        
 Insert into #tmpBeat Select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter)     
                  
Create Table #tempCategory(CategoryID int, Status int)                    
Exec GetLeafCategories @ProductHierarchy, @Category                  
            
 if @Customer=N'%'       
        Insert into #tmpCustomer select Company_Name from Customer      
   Else      
        Insert into #tmpCustomer select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)      
      
IF @custchannel <> N'%'                  
                  
BEGIN       
 Insert Into #tmpChannel Select * From dbo.Sp_SplitIn2rows(@CustChannel,@Delimeter)    
 Insert into #tmpChannelType Select ChannelType From Customer_Channel     
 Where ChannelDesc IN (Select * From #tmpChannel)    
 Drop Table #tmpChannel         
 END                  
                    
                    
/* creating cursor to store all the retailers with the qty sold */                    
                  
if @beat = N'%'                   
begin                  
                  
                  
IF @custchannel = N'%'                   
                  
BEGIN                  



DECLARE items_cursor CURSOR FOR                     
SELECT dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType, Items.ProductName,              
"Quantity" =             
sum(Case InvoiceAbstract.InvoiceType             
When 4 Then             
case  When (InvoiceAbstract.Status & 32) = 0  Then             
0 - (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity      
      When N'Reporting UOM' Then  InvoiceDetail.Quantity / (Case isnull(items.reportingunit, 1) when 0 then 1 Else isnull(items.reportingunit, 1) End)      
      When N'Conversion Factor' Then InvoiceDetail.Quantity * items.Conversionfactor End)    
--InvoiceDetail.Quantity             
Else 0             
End              
Else (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity      
      When N'Reporting UOM' Then  InvoiceDetail.Quantity / (Case isnull(items.reportingunit, 1) when 0 then 1 Else isnull(items.reportingunit, 1) End)      
      When N'Conversion Factor' Then InvoiceDetail.Quantity * items.Conversionfactor End)    
--InvoiceDetail.Quantity              
End),               
Beat.description                  
FROM Customer
Inner Join InvoiceAbstract On Customer.CustomerID = InvoiceAbstract.CustomerID
Inner Join InvoiceDetail On InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID 
Inner Join Items On Items.Product_Code = InvoiceDetail.Product_Code 
Inner Join ItemCategories On  ItemCategories.CategoryID = Items.CategoryID
Left Outer Join beat On InvoiceAbstract.BeatID = Beat.BeatID
WHERE  Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                
 (InvoiceAbstract.Status & 128) = 0 AND                  
 InvoiceAbstract.InvoiceType <> 2 AND                  
  ItemCategories.CategoryID in (Select CategoryID from #tempCategory) AND                    
 Customer.Company_Name In (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer) And
 InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate                      
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
      When N'Reporting UOM' Then  InvoiceDetail.Quantity / (Case isnull(items.reportingunit, 1) when 0 then 1 Else isnull(items.reportingunit, 1) End)      
      When N'Conversion Factor' Then InvoiceDetail.Quantity * items.Conversionfactor End)    
--InvoiceDetail.Quantity             
Else 0             
End              
Else (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity      
      When N'Reporting UOM' Then  InvoiceDetail.Quantity / (Case isnull(items.reportingunit, 1) when 0 then 1 Else isnull(items.reportingunit, 1) End)      
      When N'Conversion Factor' Then InvoiceDetail.Quantity * items.Conversionfactor End)    
--InvoiceDetail.Quantity              
End),            
Beat.description            
FROM Customer
Inner Join InvoiceAbstract On Customer.CustomerID = InvoiceAbstract.CustomerID 
Inner Join InvoiceDetail On InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
Inner Join Items On Items.Product_Code = InvoiceDetail.Product_Code
Inner Join ItemCategories On  ItemCategories.CategoryID = Items.CategoryID
Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID
WHERE  Customer.ChannelType IN (Select ChannelType From #tmpChannelType) and                    
 Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                   
 (InvoiceAbstract.Status & 128) = 0 AND                  
 InvoiceAbstract.InvoiceType <> 2 AND                  
 ItemCategories.CategoryID IN (Select CategoryID from #tempCategory) AND                    
 Customer.Company_Name In (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer) And
 InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate         
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
0 - (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity      
      When N'Reporting UOM' Then  InvoiceDetail.Quantity / (Case isnull(items.reportingunit, 1) when 0 then 1 Else isnull(items.reportingunit, 1) End)      
      When N'Conversion Factor' Then InvoiceDetail.Quantity * items.Conversionfactor End)    
--InvoiceDetail.Quantity             
Else 0             
End              
Else (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity      
      When N'Reporting UOM' Then  InvoiceDetail.Quantity / (Case isnull(items.reportingunit, 1) when 0 then 1 Else isnull(items.reportingunit, 1) End)      
      When N'Conversion Factor' Then InvoiceDetail.Quantity * items.Conversionfactor End)    
--InvoiceDetail.Quantity              
End),            
Beat.description            
FROM Customer,Items,InvoiceDetail,InvoiceAbstract,ItemCategories ,beat                  
WHERE  Customer.CustomerID = InvoiceAbstract.CustomerID AND                    
  Items.Product_Code = InvoiceDetail.Product_Code AND                   
 InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID AND                    
 ItemCategories.CategoryID = Items.CategoryID AND                  
 InvoiceAbstract.BeatID = Beat.BeatID AND                   
 Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                  
 (InvoiceAbstract.Status & 128) = 0 AND                  
 InvoiceAbstract.InvoiceType <> 2 AND                  
  ItemCategories.CategoryID in (Select CategoryID from #tempCategory) AND                    
  Customer.Company_Name In (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer) And
 InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate                      
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
      When N'Reporting UOM' Then  InvoiceDetail.Quantity / (Case isnull(items.reportingunit, 1) when 0 then 1 Else isnull(items.reportingunit, 1) End)      
      When N'Conversion Factor' Then InvoiceDetail.Quantity * items.Conversionfactor End)    
--InvoiceDetail.Quantity             
Else 0             
End              
Else (Case @UOM When N'Sales UOM' Then InvoiceDetail.Quantity      
      When N'Reporting UOM' Then  InvoiceDetail.Quantity / (Case isnull(items.reportingunit, 1) when 0 then 1 Else isnull(items.reportingunit, 1) End)      
      When N'Conversion Factor' Then InvoiceDetail.Quantity * items.Conversionfactor End)    
--InvoiceDetail.Quantity              
End),            
Beat.description            
FROM Customer,Items,InvoiceDetail,InvoiceAbstract,ItemCategories,Beat                    
WHERE   Customer.CustomerID = InvoiceAbstract.CustomerID and                    
  Customer.ChannelType IN (Select ChannelType From #tmpChannelType) and                    
 ItemCategories.CategoryID = Items.CategoryID AND                  
 InvoiceAbstract.BeatID = Beat.BeatID AND                   
 Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                  
 Items.Product_Code = InvoiceDetail.Product_Code and                    
 InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID and                    
 (InvoiceAbstract.Status & 128) = 0 AND                  
 InvoiceAbstract.InvoiceType <> 2 AND                  
 ItemCategories.CategoryID in (Select CategoryID from #tempCategory) AND                    
 Customer.Company_Name In (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer) And
 InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate     
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
Inner Join InvoiceDetail On InvoiceDetail.Product_code = Items.Product_Code 
Inner Join InvoiceAbstract On InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID 
Inner Join ItemCategories On  ItemCategories.CategoryID = Items.CategoryID
Inner Join Customer On Customer.Company_Name In (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer) 
Left Outer Join Beat On  InvoiceAbstract.BeatID = Beat.BeatID
WHERE Items.Product_Code = InvoiceDetail.Product_Code and                    
Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND               
(InvoiceAbstract.Status & 128) = 0 AND        
InvoiceAbstract.InvoiceType <> 2 AND                  
ItemCategories.CategoryID in (Select CategoryID from #tempCategory) AND                    
InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate                      
END                  
ELSE                  
BEGIN                                 
DECLARE unique_items CURSOR FOR                     
SELECT distinct Items.ProductName         
FROM Items
Inner Join InvoiceDetail On InvoiceDetail.Product_code = Items.Product_Code 
Inner Join Customer On Customer.ChannelType IN (Select ChannelType From #tmpChannelType)
Inner Join ItemCategories On ItemCategories.CategoryID = Items.CategoryID
Inner Join InvoiceAbstract On InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID
WHERE Items.Product_Code = InvoiceDetail.Product_Code and                    
 Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                   
 (InvoiceAbstract.Status & 128) = 0 AND                  
 InvoiceAbstract.InvoiceType <> 2 AND                  
 ItemCategories.CategoryID in (Select CategoryID from #tempCategory) AND                    
 Customer.Company_Name In (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer) And
 InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate                      
END                  
                  
                  
end                  
else                  
begin                  
                  
                  
IF @custchannel = N'%'                   
BEGIN                        
DECLARE unique_items CURSOR FOR                     
SELECT distinct Items.ProductName                     
FROM Items
Inner Join InvoiceDetail On InvoiceDetail.Product_code = Items.Product_Code 
Inner Join Customer On Customer.Company_Name In (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer)
Inner Join ItemCategories On ItemCategories.CategoryID = Items.CategoryID
Inner Join InvoiceAbstract On InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID
WHERE Items.Product_Code = InvoiceDetail.Product_Code and                    
 Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                  
      (InvoiceAbstract.Status & 128) = 0 AND                    
      InvoiceAbstract.InvoiceType <> 2 AND                  
      ItemCategories.CategoryID in (Select CategoryID from #tempCategory) AND                    
      InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate                      
END           
ELSE                  
BEGIN                  
DECLARE unique_items CURSOR FOR                     
SELECT distinct Items.ProductName                     
FROM Items
Inner Join InvoiceDetail On InvoiceDetail.Product_code = Items.Product_Code
Inner Join Customer On Customer.ChannelType  IN (Select ChannelType From #tmpChannelType) 
Inner Join ItemCategories On ItemCategories.CategoryID = Items.CategoryID
Inner Join InvoiceAbstract On Items.Product_Code = InvoiceDetail.Product_Code
Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID 
WHERE Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND                  
      InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID and                    
      (InvoiceAbstract.Status & 128) = 0 AND                  
      InvoiceAbstract.InvoiceType <> 2 AND                  
      ItemCategories.CategoryID in (Select CategoryID from #tempCategory) AND                    
      Customer.Company_Name In (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer) And
      InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate                      
END                  
end                  
                
/* creating temp table and store values */                    
                    
CREATE TABLE #final(Cust_Temp_Name varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,Customer_Name varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,Channel varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,   
Beat varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)                    
                  
if @beat = N'%'                  
begin                   
                  
                  
IF @custchannel = N'%'                   
BEGIN                  
INSERT INTO #final (Cust_Temp_Name, Customer_Name, Channel, Beat)                  
SELECT distinct dbo.EncodeQuotes(Customer.Company_Name), dbo.EncodeQuotes(Customer.Company_Name),                
case isnull(Customer.ChannelType,0)           
When 0 Then          
N'Others'          
Else          
Customer_Channel.ChannelDesc          
End,                 
Beat.description                  
                    
FROM InvoiceAbstract
Inner Join Customer On Customer.CustomerID = InvoiceAbstract.CustomerID 
Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID 
Left Outer Join  Customer_Channel On Customer_Channel.ChannelType = Customer.ChannelType
WHERE 
(InvoiceAbstract.Status & 128) = 0 AND                    
InvoiceAbstract.InvoiceType <> 2 AND                    
Customer.Company_Name In (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer) And
InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate                
GROUP BY dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType, InvoiceAbstract.CustomerID,Beat.Description, Customer_Channel.ChannelDesc         
END                  
ELSE                  
BEGIN                  
                  
INSERT INTO #final  (Cust_Temp_Name, Customer_Name, Channel, Beat)                   
SELECT distinct dbo.EncodeQuotes(Customer.Company_Name), dbo.EncodeQuotes(Customer.Company_Name),                 
case isnull(Customer.ChannelType,0)           
When 0 Then          
N'Others'          
Else          
Customer_Channel.ChannelDesc          
End,                   
Beat.description                  
                  
FROM InvoiceAbstract
Inner Join Customer On Customer.CustomerID = InvoiceAbstract.CustomerID
Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID
Left Outer Join  Customer_Channel On Customer_Channel.ChannelType = Customer.ChannelType
WHERE 
Customer.ChannelType  IN (Select ChannelType From #tmpChannelType) AND                  
(InvoiceAbstract.Status & 128) = 0 AND                    
InvoiceAbstract.InvoiceType <> 2 AND                    
Customer.Company_Name In (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer) And
InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate           
GROUP BY dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType, InvoiceAbstract.CustomerID,Beat.Description, Customer_Channel.ChannelDesc         
END                    
                  
                  
end                   
else                  
begin                  
                  
                  
IF @custchannel = N'%'                   
BEGIN                  
INSERT INTO #final (Cust_Temp_Name, Customer_Name, Channel, Beat)                  
                  
SELECT distinct dbo.EncodeQuotes(Customer.Company_Name), dbo.EncodeQuotes(Customer.Company_Name),                 
case isnull(Customer.ChannelType,0)           
When 0 Then          
N'Others'          
Else          
Customer_Channel.ChannelDesc          
End,     
Isnull(Beat.description,0)                  
                    
FROM InvoiceAbstract
Inner Join Customer On Customer.CustomerID = InvoiceAbstract.CustomerID
Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID
Left Outer Join Customer_Channel On Customer_Channel.ChannelType = Customer.ChannelType 
WHERE 
 Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) and          
(InvoiceAbstract.Status & 128) = 0 AND                    
InvoiceAbstract.InvoiceType <> 2 AND        
Customer.Company_Name In (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer) And
InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate           
GROUP BY dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType, InvoiceAbstract.CustomerID,Beat.Description, Customer_Channel.ChannelDesc         
END                  
ELSE                  
BEGIN                  
    
INSERT INTO #final  (Cust_Temp_Name, Customer_Name, Channel, Beat)                  
                  
SELECT distinct dbo.EncodeQuotes(Customer.Company_Name), dbo.EncodeQuotes(Customer.Company_Name),                 
case isnull(Customer.ChannelType,0)           
When 0 Then          
N'Others'          
Else          
Customer_Channel.ChannelDesc          
End,                  
Beat.description                  
                  
FROM InvoiceAbstract
Inner Join Customer On Customer.CustomerID = InvoiceAbstract.CustomerID
Left Outer Join Beat On  InvoiceAbstract.BeatID = Beat.BeatID
Left Outer Join  Customer_Channel On Customer_Channel.ChannelType = Customer.ChannelType
WHERE
Customer.ChannelType  IN (Select ChannelType From #tmpChannelType) AND                  
 Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) and          
(InvoiceAbstract.Status & 128) = 0 AND                    
InvoiceAbstract.InvoiceType <> 2 AND                    
Customer.Company_Name In (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer) And
InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate           
GROUP BY dbo.EncodeQuotes(Customer.Company_Name), Customer.ChannelType,                 
InvoiceAbstract.CustomerID,Beat.Description, Customer_Channel.ChannelDesc         
END                    
                  
end                  
                
/* altering the table to insert the item as fields */                    
        
                    
OPEN unique_items                    
FETCH FROM unique_items Into @Prod_Name                    
                    
WHILE @@FETCH_STATUS = 0                    
BEGIN                     
 If CHARINDEX(N'[',@Prod_Name,1) <> 0 or  CHARINDEX(N']',@Prod_Name,1) <> 0       
 Begin      
 Set @Prod_Name = Replace(@Prod_Name, N'[',N' ')      
 Set @Prod_Name = Replace(@Prod_Name, N']',N' ')      
 End      
      
 SET @AlterSQL = N'ALTER TABLE #final Add [' + @Prod_Name +  N'] Decimal(18,6) null'                     
 EXEC sp_executesql @AlterSQL                    
 FETCH NEXT FROM unique_items INTO @Prod_Name                    
END                    
                  
/* updating the table */                    
                    
DECLARE @C_Name varchar(500)                    
DECLARE @Chan varchar(500)                    
DECLARE @ITEM_NAME varchar(100)                    
DECLARE @item_Qty Decimal(18,6)                  
DECLARE @Product varchar(100)                    
DECLARE @BeatName varchar(255)                    
                    
OPEN items_cursor                    
          
FETCH FROM items_cursor Into @C_Name, @Chan, @Product, @item_Qty ,@BeatName                     
          
IF @@fetch_status <> 0                   
BEGIN                  
delete from #final               
select * from #final                  
goto exitproc                  
END                  
Create Table #customer (Customer_Name  Varchar(255), Beat varchar(255))          
set @cust_temp = Isnull (@cust_temp,N'')                  
                
Declare @PrevCus Varchar(255)                
    
          
WHILE @@FETCH_STATUS = 0                    
BEGIN                      

             
 If IsNull(@PrevCus, N'') <> @C_Name            
 Begin                
  Set @PrevCus = @C_Name                
  If IsNull(@cust_temp, N'') = N''                    
   Insert Into #customer Values (@C_Name, @BeatName)               
  else          
   Insert Into #customer Values (@C_Name, @BeatName)                
 End                

       
 If CHARINDEX('[',@Product,1) <> 0 or  CHARINDEX(N']',@Product,1) <> 0       
 Begin      
 Set @Product = Replace(@Product, N'[',N' ')      
 Set @Product = Replace(@Product, N']',N' ')      
 End          

--select @Product, @item_Qty, @C_Name, @BeatName

 SET @UpdateSQL = N'Update #final Set [' + @Product + N'] = ' + cast (@item_Qty as varchar) + N' Where Customer_Name collate SQL_Latin1_General_Cp1_CI_AS = '''+ dbo.EncodeQuotes(@C_Name)  + N''' and Isnull(Beat,'''') collate SQL_Latin1_General_Cp1_CI_AS  =  ''' + dbo.EncodeQuotes(Isnull(@BeatName,N'')) + N''''  

--select * from #final
            
 exec sp_executesql @UpdateSQL       
 FETCH NEXT FROM items_cursor Into @C_Name, @Chan, @Product, @item_Qty, @BeatName                     
END                   
          
Select * From #final Where Customer_Name collate SQL_Latin1_General_Cp1_CI_AS in (Select Customer_Name From #customer)                
drop table #customer                     
exitproc:                    
Close items_cursor                    
DeAllocate items_cursor                  
Close unique_items                  
DeAllocate unique_items                  
drop table #final                  
drop table #tempCategory           
Drop Table #tmpBeat    
Drop Table #tmpChannelType    
Drop Table #tmpCustomer
    
  
  
