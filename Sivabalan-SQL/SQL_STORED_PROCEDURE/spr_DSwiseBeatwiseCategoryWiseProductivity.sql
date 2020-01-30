Create PROCEDURE spr_DSwiseBeatwiseCategoryWiseProductivity (
           @DS NVARCHAR(255),                  
           @BEAT NVARCHAR(255),
           @DSTYPE NVARCHAR(4000),
           @HIERARCHY NVARCHAR(4000),
           @CATEGORY NVARCHAR(4000),                  
           @FROMDATE DATETIME,
           @TODATE DATETIME)                    
AS               
Declare @Delimeter as Char(1)                  
Set @Delimeter=Char(15)                
              
Create Table #FINALTABLE (           
Categoryid nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,          
Category nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,              
NoOfCust Decimal(18,6),                
InvoicedCust Decimal(18,6),              
NonInvoicedCust Decimal(18,6),           
UOM nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,          
Quantity decimal(18,6),          
InvoicedValue decimal(18,5),          
AvgInvoiceValue decimal(18,5),          
Productivity decimal(18,6))             
          
Create Table #tempCategory(CategoryID int, Status int)                      
-- Declare @tempCategory Table (CategoryID int, Status int)                      
Exec GetLeafCategories @HIERARCHY, @CATEGORY            
Declare @Sman table (Smanname nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)               
Declare @Beattab table (Beatname nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)         
Declare @DSTypetab table (SalesmanID Int, DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)         
Declare @ItemTable table (prodID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)               
Declare @InvTable table (InID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,prodID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,quantity decimal(18,6),amount decimal(18,6))              
Declare @CustTable table (Value Decimal(18,6))               
Declare @CustTable2 table (CustIDcount int)      
Declare @CustTable1 table (Value Decimal(18,6),Netquantity decimal(18,6),UOM nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)               
Declare @Sman1 table (SmanID int)           
Declare @Beat1 table (BeatID int)          
-- Declare @DSSalesman table (SalesmanID int)          
if @DS='%'               
 insert into @Sman select Salesman_name from salesman where salesmanid in (select distinct salesmanid from Beat_Salesman)          
Else              
 Insert into @Sman select * from dbo.sp_SplitIn2Rows(@DS,@Delimeter)           
          
if @BEAT='%'               
 insert into @Beattab select Description from beat where BeatID in (select distinct beatid from Beat_Salesman)          
Else              
 Insert into @Beattab select * from dbo.sp_SplitIn2Rows(@BEAT,@Delimeter)           

if @DSTYPE=N'%' or @DSTYPE=N''               
  Insert into @DSTypetab
  select Salesman.SalesmanID,DSTypeValue from DSType_Master,DSType_Details,Salesman
  Where Salesman.SalesmanID = DSType_Details.SalesmanID
  and DSType_Details.DSTypeID = DSType_Master.DSTypeID 
  and DSType_Master.DSTypeCtlPos = 1 
  Union
  Select SalesmanID,N'' from Salesman where SalesmanID not in (select SalesmanID from DSType_Details Where DSTypeCtlPos = 1)
Else              
  Insert into @DSTypetab
  select SalesmanID,DSTypeValue from DSType_Master,DSType_Details
  Where DSType_Master.DSTypeID = DSType_Details.DSTypeID  
  and DSType_Master.DSTypeCtlPos = 1 
  and DSType_Master.DSTypeValue in (select * from dbo.sp_SplitIn2Rows(@DSType,@Delimeter)) 

          
 insert into @Sman1 select SalesmanID from salesman where salesman_name in (select Smanname from @Sman)          
 insert into @Beat1 select BeatID from Beat where Description in (select Beatname from @Beattab)          
        
 insert into #FinalTable (categoryid,Category,NoOfCust)               
 select itc.categoryid,itc.category_name,      
 (select count(distinct bs.customerid) from beat_salesman bs,customer cu       
 where     
 cu.active=1 and      
 bs.beatid in (select BeatID  from @Beat1) and     
 bs.salesmanid in (select SmanID  from @Sman1)and    
 bs.customerid=cu.customerid and
 bs.Salesmanid in (select salesmanid From @DSTypetab)      
 )      
 from itemcategories itc,invoiceabstract inva,invoicedetail invd,items itm ,  
customer cu,beat_salesman bs         
 where     
cu.active =1 and     
bs.salesmanid in (select SmanID  from @Sman1) and              
bs.beatid in (select BeatID  from @Beat1)and           
itm.categoryid in (select categoryID From #tempCategory)and          
itc.categoryid=itm.categoryid and     
inva.customerid=cu.customerid and     
inva.invoiceid = invd.invoiceid and     
itm.product_code=invd.product_code and
bs.Salesmanid in (select SalesmanID from @DSTypetab)
group by itc.category_name,itc.Categoryid          
      
DECLARE @CATID NVarchar(255)           
Declare @UOMCount Int    
DECLARE Sman_Cursor CURSOR FOR                 
SELECT  categoryid FROM #FinalTable               
              
OPEN Sman_Cursor             
        
             
FETCH NEXT FROM Sman_Cursor INTO @CATID                
              
WHILE @@FETCH_STATUS = 0                
BEGIN            
 insert into @ItemTable            
 select product_code from items where categoryid = @CATID           
      
 insert into @InvTable          
 select invoiceID,product_code,quantity,amount from invoicedetail where product_code in ( select prodId from @ItemTable)          
      
 insert @CustTable2      
 select count(distinct inva.customerid)from invoiceabstract inva,invoicedetail invd,customer c   
 where     
 ISNULL(STATUS,0) & 128 = 0          
 and inva.InvoiceType in (1,3)     
 and inva.invoicedate between @FROMDATE and @TODATE        
 and c.active=1      
-- and inva.CUSTOMERID IN (SELECT CUSTOMERID FROM BEAT_SALESMAN Bt WHERE
--                         bt.BEATID in (select BEATID from @Beat1) and 
--                         bt.salesmanid in (select SmanID  from @Sman1) and 
--                         bt.salesmanid in (select salesmanId from @DSTypetab)) 
 and inva.BeatID In(Select BeatID From @Beat1) 
 and inva.SalesmanID In(Select SManID From @Sman1) 
 and inva.SalesmanID In(select salesmanId from @DSTypetab)
 and inva.invoiceid in (select InID from @InvTable)      
 and inva.customerid=c.customerid      
  
     
 insert @CustTable         
 Select sum(Amount) from invoicedetail invd,invoiceabstract inva, customer         
 WHERE ISNULL(STATUS,0) & 128 = 0         
 and inva.InvoiceType in (1,3)     
 and inva.invoicedate between @FROMDATE and @TODATE        
 and customer.active = 1 
-- and inva.CUSTOMERID IN (SELECT CUSTOMERID FROM BEAT_SALESMAN Bt WHERE 
--                                bt.BEATID in (select BEATID from @Beat1) and 
--                                Bt.salesmanid in (select SmanID  from @Sman1) and 
--                                Bt.salesmanid in (select salesmanid from @DSTypetab))   
 and inva.BeatID In(Select BeatID From @Beat1) 
 and inva.SalesmanID In(Select SManID From @Sman1) 
 and inva.SalesmanID In(select salesmanId from @DSTypetab)  
 and inva.invoiceid in (select InID from @InvTable)      
 and product_code in (select prodId from @ItemTable)       
 and inva.invoiceid=invd.invoiceid 
 and inva.customerid=customer.customerid      
 and inva.customerid=customer.customerid      
    
 --Finding the UOM Count    
 Select @UOMCOUNT = Count(Distinct Items.UOM)            
 From Items, InvoiceDetail, ItemCategories, InvoiceAbstract            
 WHERE     
 InvoiceAbstract.Status & 128 = 0 AND             
 InvoiceAbstract.InvoiceType in (1, 3) AND           
 InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND            
 ItemCategories.CategoryID = @CATID AND            
 Items.CategoryID = ItemCategories.CategoryID AND            
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND            
 InvoiceDetail.Product_Code = Items.Product_Code  And  
 --InvoiceAbstract.CUSTOMERID IN (SELECT CUSTOMERID FROM BEAT_SALESMAN Bt WHERE bt.BEATID in (select BEATID from @Beat1) and salesmanid in (select SmanID  from @Sman1) and salesmanid in (select salesmanid from @DSTypetab))   
 InvoiceAbstract.BeatID In(Select BeatID From @Beat1) AND
 InvoiceAbstract.SalesmanID In(Select SManID From @Sman1) AND 
 InvoiceAbstract.SalesmanID In(select salesmanId from @DSTypetab)
    
 Insert @CustTable1           
 select Sum(CustTable.Value),sum(InvTable.quantity),    
 Case When @UOMCOUNT = 1     
 Then (Select TOP 1 UOM.Description From Items,UOM     
    Where Items.CategoryID = @CATID And UOM.UOM=Items.UOM And     
    Items.Product_Code=items.Product_Code      
    )     
 Else '' End    
 From @CustTable CustTable,@InvTable InvTable,invoiceabstract, customer     
 where      
 ISNULL(STATUS,0) & 128 = 0  and      
 invoiceabstract.InvoiceType in (1,3) and     
 invoiceabstract.invoicedate between @FROMDATE and @TODATE 
 and customer.active = 1 
 and invoiceabstract.beatid in (select BeatID  from @Beat1) and     
-- invoiceabstract.CUSTOMERID IN   
--(SELECT CUSTOMERID FROM BEAT_SALESMAN Bt   
--WHERE bt.BEATID in (select BEATID from @Beat1) and   
--salesmanid in (select SmanID  from @Sman1) and 
--salesmanid in (select salesmanid from @DSTypetab)) and         
 InvTable.InID=invoiceabstract.invoiceid  and     
 InvoiceAbstract.SalesmanID In(Select SManID From @Sman1) and 
 InvoiceAbstract.SalesmanID In(select salesmanId from @DSTypetab)   
 and InvoiceAbstract.CUSTOMERID  = CUSTOMER.CUSTOMERID 
         
 UPDATE #FINALTABLE SET InvoicedCust = CustTable2.CustIDcount      
 ,InvoicedValue = CustTable.Value,NonInvoicedCust =NoOfCust- CustTable2.CustIDcount      
 ,Quantity=CustTable1.NetQuantity,UOM=CustTable1.UOM      
 ,AvgInvoiceValue=CustTable.Value/CustTable2.CustIDcount,          
  Productivity= (CustTable2.CustIDcount / (CustTable2.CustIDcount + (#finaltable.NoOfCust- CustTable2.CustIDcount)))          
 From @CustTable CustTable,@CustTable1 CustTable1,@CustTable2 CustTable2 WHERE CATEGORYID=@CATID          
        
 Delete From @ItemTable        
 Delete From @InvTable        
 Delete From @CustTable           
 Delete From @CustTable1       
 Delete From @CustTable2       
         
FETCH NEXT FROM Sman_Cursor INTO @CATID              
END                
CLOSE Sman_Cursor                
DEALLOCATE Sman_Cursor               
select Categoryid,"Category"=Category,"Total Customers"=NoOfCust,"Total No. of Customers Invoiced"=InvoicedCust,"No of Customers Not Invoiced"=NonInvoicedCust,"UOM"=UOM,"Qty"=Quantity,"Value (%c)"=InvoicedValue,"Avg Invoice Value (%c)"=AvgInvoiceValue,  
"Productivity"=Productivity  from #FINALTABLE     
         
drop table #FinalTable

