CREATE PROCEDURE spr_DSwiseBeatwiseCategorywiseProductivity_detail(              
               @CATEGORY NVARCHAR(4000),                
               @DS NVARCHAR(255),                
               @BEAT NVARCHAR(255),
               @DSTYPE NVARCHAR(4000),
               @HIERARCHY NVARCHAR(4000),
               @CAT NVARCHAR(4000),                
               @FROMDATE DATETIME,@TODATE DATETIME)                
AS           
Declare @UOMCount as int
Declare @Delimeter as Char(1)              
Declare @Cats nVarChar(255)
Set @Delimeter=Char(15)            

Select @Cats = Category_Name From ItemCategories Where CategoryID = Cast(@CATEGORY As Int)
create table  #tempCategory (CategoryID Int, Status Int)  
Exec GetLeafCategories '%', @Cats

Declare @FinalTable Table  (
CustID nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Beatid nvarchar(20)COLLATE SQL_Latin1_General_CP1_CI_AS,                      
salesmanid nvarchar(20)COLLATE SQL_Latin1_General_CP1_CI_AS,   
BeatName nvarchar(520)COLLATE SQL_Latin1_General_CP1_CI_AS,                      
DSName nvarchar(110)COLLATE SQL_Latin1_General_CP1_CI_AS,
DSType nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,           
NoOfCust integer,            
InvoicedCust integer,          
UOM nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,          
Qty decimal(18,5),          
Value decimal(18,5))  
  
Declare @FinalTable1 Table  (
--CustID nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,  
DSNam nvarchar(110)COLLATE SQL_Latin1_General_CP1_CI_AS,  
DSType nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
BeatNam nvarchar(520)COLLATE SQL_Latin1_General_CP1_CI_AS,           
NoOfCus integer,            
InvoicedCus integer,          
NonInvoicedCus integer,          
UO nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,          
Quant decimal(18,5),          
Val decimal(18,5),      
AvgInv decimal(18,5),      
Product decimal(18,5))                   
Declare @tempProduct table (ProdCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)   
insert into @tempProduct select product_code from items where categoryid =@CATEGORY  
Declare @Sman table (Smanname nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)           
Declare @Beattab table (Beatname nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)   
Declare @DSTypetab table (SalesmanId Int, DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Declare @Sman1 table (SmanID int)       
Declare @Beat1 table (BeatID int)  
  
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
  Select SalesmanID,N'' from Salesman where SalesmanID not in (select SalesmanID from DSType_Details where DSTypeCtlPos = 1)
 Else              
  Insert into @DSTypetab
  select SalesmanID,DSTypeValue from DSType_Master,DSType_Details
  Where DSType_Master.DSTypeID = DSType_Details.DSTypeID  
  and DSType_Master.DSTypeCtlPos = 1 
  and DSType_Master.DSTypeValue in (select * from dbo.sp_SplitIn2Rows(@DSType,@Delimeter))  
  

 insert into @Sman1 select SalesmanID from salesman where salesman_name in (select Smanname from @Sman)      
 insert into @Beat1 select BeatID from Beat where Description in (select Beatname from @Beattab)     

--Finding the UOM Count
	Select @UOMCOUNT = Count(Distinct Items.UOM)        
	From Items, InvoiceDetail, ItemCategories, InvoiceAbstract        
	WHERE InvoiceAbstract.Status & 128 = 0 AND        
	InvoiceAbstract.InvoiceType in (1, 3)and        
	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND        
	ItemCategories.CategoryID = @CATEGORY AND        
	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND        
	Items.CategoryID = ItemCategories.CategoryID AND        
	InvoiceDetail.Product_Code = Items.Product_Code AND
	InvoiceAbstract.BeatID In(Select BeatID From @Beat1) AND
	InvoiceAbstract.SalesmanID In(Select SManID From @Sman1) AND 
	InvoiceAbstract.SalesmanID In(select salesmanId from @DSTypetab)

insert into @FinalTable 
(custid, Beatid,Salesmanid,BeatName,DSName,DsType,NoOfCust,UOM,Qty,Value)   
select inva.CustomerID, 
inva.beatid, inva.Salesmanid,
"db" = (Select [Description] From Beat bt Where bt.BeatId = inva.BeatID),
"sm" = (Select Salesman_Name From Salesman sm Where sm.salesmanid = inva.Salesmanid),
"DSTypeValue" = (select tDS.DSTYpe from @DSTypetab tDS Where tDS.SalesmanID = inva.Salesmanid) ,

-- "noofc" = (SELECT Count(CUSTOMERID) FROM BEAT_SALESMAN Bt 
-- WHERE bt.BEATID in (select BeatID 
-- from beat Where [Description] In (Select BeatName From @Beattab))
--  and bt.salesmanid in (select SalesmanID from salesman where Salesman_Name in 
-- (Select Smanname From @Sman ))) ,

 "noofc" = (SELECT Count(Distinct Bt.CUSTOMERID) FROM BEAT_SALESMAN Bt,Customer C
 WHERE bt.SalesmanID in (select tDS.SalesmanID from @DSTypetab tDS)
 and bt.BEATID in (select BeatID 
 from beat Where [Description] In (Select BeatName From @Beattab))
 and bt.salesmanid in (select SalesmanID from salesman where Salesman_Name in 
 (Select Smanname From @Sman)) And C.Active = 1 And Bt.CustomerID = C.CustomerID) ,


"uom" = Case When @UOMCOUNT = 1 
	 Then (Select TOP 1 UOM.Description From Items, UOM 
	 Where UOM.UOM = Items.UOM And Items.Product_Code = invd.Product_Code) 
	 Else '' End,
"qty" = Sum(invd.Quantity),

"Value" =  Sum(invd.Amount)

 from invoicedetail invd, invoiceabstract inva 
Where
 ISNULL(inva.STATUS,0) & 128 = 0  
 and inva.InvoiceType in (1,3)   
 and inva.invoicedate between  @FROMDATE And @TODATE 
 and inva.BeatID In(Select BeatID From @Beat1) 
 and inva.SalesmanID In(Select SManID From @Sman1) 
 and inva.SalesmanID In(select salesmanId from @DSTypetab)
-- and inva.CUSTOMERID IN (SELECT CUSTOMERID FROM 
-- BEAT_SALESMAN Bt WHERE bt.BEATID in (select BeatID 
--from beat Where [Description] In (Select BeatName From @Beattab)) and 
--bt.SalesmanID in (select tDS.SalesmanID from @DSTypetab tDS) and 
--bt.salesmanid in (select SalesmanID from salesman where Salesman_Name in 
--(Select Smanname From @Sman )))
 and invd.product_code in (Select Product_Code From Items Where CategoryID 
In (Select CategoryID From #tempCategory))     

 and inva.invoiceid=invd.invoiceid   
Group by invd.product_code, inva.salesmanid, inva.beatid, inva.CustomerID

Select DSName, "DS Name" = DSName,"DS Type"=DSType, 
"Beat Name" = BeatName,  
"Total Customers" = NoOfCust, 
"No of customers Invoiced" = Count(custid),
"No of Customers Not Invoiced" = NoOfCust - Count(custid),
"UOM" = UOM,
"Qty" = Sum(Qty),
"Value (%c)" = Sum(Value),
"Avg Invoice Value (%c)" = Sum(Value) / (Case When Count(custid) > 0 Then Count(custid) Else 1 End),
"Productivity" = Cast(Count(custid) As Decimal(18, 6))/ (Case NoOfCust When 0 Then 1 Else NoOfCust End)
From @FinalTable
Group By DSName, BeatName, NoOfCust, UOM,DSType

