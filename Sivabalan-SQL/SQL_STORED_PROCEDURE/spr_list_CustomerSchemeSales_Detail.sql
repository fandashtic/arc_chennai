Create PROCEDURE spr_list_CustomerSchemeSales_Detail(          
 @SchemeCust NVarchar(2550),          
 @FromDate DateTime,          
 @ToDate DateTime,          
 @CustomerName NVarchar(2550),          
 @SchemeName NVarchar(2550)          
)As          
          
Declare @SchemeID as Integer          
Declare @CustomerID as Nvarchar(30)          
Declare @Prefix as Varchar(2)  
Declare @schID as Integer        
Begin                    
           


select @Prefix = Prefix from VoucherPrefix where TranID = 'INVOICE'                      
set @SchemeID =cast( substring(@SchemeCust,1,CHARINDEX ('|',@SchemeCust)-1)as integer) 
Set @SchemeCust =  substring(@SchemeCust,len(@SchemeID)+2, Len(@SchemeCust))
set @CustomerID = substring(@SchemeCust,1,CHARINDEX ('|',@SchemeCust)-1)    
Set @SchID =  CAST(substring(@SchemeCust,len(@CustomerID)+2, Len(@SchemeCust)) AS Integer)

if @SchemeID=3 or @SchemeID=4 or @SchemeID=97 or @SchemeID=99                   
Begin                          
                          
--InvoiceBased Free Items For Value                                    
Select                 
Schs.product_code,                    
"Invoice no"=@Prefix + Cast(Inv.DocumentID as Varchar),                
"Invoice date"=Inv.InvoiceDate,                
"Free Item Code"=schs.product_code,                    
"Free Item Name"=Itm.ProductName,                    
"Free Qty" = Sum(SchS.Free),            
"Free Item Value (PTS.)" = Sum(Schs.cost)          
From InvoiceAbstract Inv             
inner join Customer Cust on Inv.CustomerID=Cust.CustomerID                    
inner join SchemeSale SchS on Inv.InvoiceId=Schs.InvoiceID                    
inner join Schemes Sch on Schs.Type=sch.Schemeid                    
inner join Items Itm on  Schs.product_code=Itm.product_code                    
where                    
Inv.InvoiceDate BetWeen @FromDate And @ToDate                    
And (IsNull(Inv.Status,0) & 192) =0                                    
And Inv.CustomerId=@CustomerID                    
And Sch.SchemeType=@SchemeID    
And Sch.SchemeID = @SchID        
group by Schs.product_code, schs.product_code,Itm.ProductName                    
,Inv.DocumentID,Inv.InvoiceDate                  
Order by Inv.DocumentID                
            
End                    
                    
If @SchemeID=17 Or @SchemeID=83  
--Item Based Same product free            
Begin                    

Select Distinct Idet.Product_Code,FreeSerial, Idet.InvoiceId, Idet.Serial,
Idet.SchemeId, SalePrice, Inv.InvoiceDate, Itm.productname, Inv.DocumentId 
Into #tmpIdt
From InvoiceDetail Idet, InvoiceAbstract Inv, Items Itm,
Customer Cust, Schemes Sch                        
Where Inv.InvoiceId=Idet.InvoiceId                      
And Idet.product_code=Itm.product_code                      
And Inv.CustomerID=Cust.CustomerID                      
And Idet.Schemeid = sch.Schemeid          
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                    
And Inv.CustomerId=@CustomerID                  
And isnull(saleprice,0) >0 And isnull(Freeserial,'')<>''           
And (IsNull(Inv.Status,0) & 192) =0                    
--And Sch.SchemeType IN (17, 83)
And SchemeType = @SchemeID
And Sch.SchemeID = @SchID
         
Select [Item Code],                
[Invoice no],[Invoice date],[Item Code],[Item Name],                    
"Quantity" = Sum([Quantity]),                    
"Free Item Code"=[Free Item Code],                  
"Free Item Name"=[Free Item Name],                    
"Free Qty" =sum([Free Qty]) ,                    
"Free Item Value (PTS.)" =sum([Free Item Value (PTS.)])                    
From (                  
select Idet.product_code,                    
"Invoice no"=@Prefix + Cast(Idet.DocumentID as Varchar),                
"Invoice date"=Idet.InvoiceDate,                
"Item Code" = Idet.product_code,                    
"Item Name" = Idet.productname,                    
"Quantity" =  (SELECT sum(quantity)from invoicedetail where product_code=Idet.Product_code And invoiceid=Idet.InvoiceID and Saleprice>0 And Serial=Idet.Serial  group by product_code),                    
"Free Item Code"=(select distinct Product_Code from invoicedetail where  product_code=Idet.Product_code And invoiceid=Idet.InvoiceID  and Saleprice=0 and freeserial =cast(Idet.Serial as varchar) ),                    
"Free Item Name"=(Select ProductName from Items where product_code=(select distinct Product_Code from invoicedetail where  product_code=Idet.Product_code And invoiceid=Idet.InvoiceID  and Saleprice=0 and freeserial =cast(Idet.Serial as varchar) )),       

"Free Qty" = (select sum(quantity)from invoicedetail where  product_code=Idet.Product_code And invoiceid=Idet.InvoiceID  and Saleprice=0 and freeserial =cast(Idet.Serial as varchar) group by product_code),                    
"Free Item Value (PTS.)" =(select sum(cost)  from schemesale where invoiceid=idet.invoiceid and Serial=Idet.freeSerial )            
from #tmpIdt Idet                      
-- inner join InvoiceAbstract Inv on Inv.InvoiceId=Idet.InvoiceId                    
-- inner join Items Itm on  Idet.product_code=Itm.product_code                    
-- inner join Customer Cust on Inv.CustomerID=Cust.CustomerID                    
-- left join Schemes Sch on Idet.Schemeid=sch.Schemeid        
-- where                     
-- Inv.InvoiceDate BetWeen @FromDate And @ToDate                    
-- And Inv.CustomerId=@CustomerID                  
-- And isnull(saleprice,0) >0 And isnull(Freeserial,'')<>''           
-- And (IsNull(Inv.Status,0) & 192) =0                    
-- And Sch.SchemeType IN (17, 83)
)Scheme                    
group by [Item Code],[Item Name],  [Free Item Code],[Free Item Name]                
,[Invoice no],[Invoice date]                
Order by [Invoice no]                
    
End                    
                   
If @SchemeID=18 Or @SchemeID=84  
--Item based diff item free        
Begin                    
      
select f.invoiceid,f.product_code,s.quantity,s.free,s.cost,f.serial,  
"freeserial" = Case IsNull(f.freeserial, N'') When N'' then f.splcatserial Else IsNull(f.freeserial, N'') End  
into #tempSchfree      
from Invoicedetail f,schemesale s,invoiceabstract a      
where f.invoiceid=s.invoiceid and f.serial=s.serial   
And f.invoiceid=a.invoiceid 
And ( case when isnull(f.specialcategoryscheme, 0) = 1 then f.splcatschemeid else f.SchemeID end ) = @SchID      
And a.CustomerId=@CustomerID      
      
-------------------------------------  
-- select * from #tempSchfree      
-------------------------------------  
  
-------------------------------------  
-- select        
-- Idet.product_code,                  
-- "Invoice no"=@Prefix + Cast(Inv.DocumentID as Varchar),              
-- "Invoice date"=Inv.InvoiceDate,              
-- "Item Code" = Idet.product_code,                  
-- "Item Name" = Itm.productname,                  
-- "Quantity" =  idet.quantity,      
-- "Free Item Code"=t.product_code,      
-- "Free Item Name"=(Select ProductName from Items where product_code=t.product_code),      
-- "Free Qty" = t.free,      
-- "Free Item Value (PTS.)" = t.cost      
-- from #tempschfree t,      
-- invoiceabstract inv,       
-- invoicedetail Idet,items itm,customer cust,schemes sch      
-- where       
-- t.invoiceid=idet.invoiceid       
-- And Inv.InvoiceDate BetWeen @FromDate And @ToDate                  
-- And Inv.CustomerId=@CustomerID                  
-- And Inv.InvoiceId=Idet.InvoiceId                  
-- And Idet.product_code=Itm.product_code                  
-- And Inv.CustomerID=Cust.CustomerID                  
-- And (Idet.Schemeid=sch.Schemeid Or Idet.splcatschemeid = sch.Schemeid)   
-- And isnull(saleprice,0) >0 And (isnull(idet.Freeserial,'')<>'' Or isnull(idet.splcatserial,'')<>'')  
-- And (IsNull(Inv.Status,0) & 192) =0                  
-- And Sch.SchemeType IN (18)      
-- And idet.serial=t.freeserial  
-- -- And Idet.SpecialCategoryScheme <> 1      
  
-------------------------------------------------  
  
select [Item Code],[Invoice no],[Invoice date],    
[Item Code],[Item Name],                  
"Quantity" = [Quantity],                  
"Free Item Code"=[Free Item Code],                
"Free Item Name"=[Free Item Name],                  
"Free Qty" =sum([Free Qty]) ,                  
"Free Item Value (PTS.)" = sum([Free Item Value (PTS.)])                  
From (                
select        Distinct
Idet.product_code,                  
"Invoice no"=@Prefix + Cast(Inv.DocumentID as Varchar),              
"Invoice date"=Inv.InvoiceDate,              
"Item Code" = Idet.product_code,                  
"Item Name" = Itm.productname,                  
"Quantity" =  idet.quantity,      
"Free Item Code"=t.product_code,      
"Free Item Name"=(Select ProductName from Items where product_code=t.product_code),      
"Free Qty" = t.free,      
"Free Item Value (PTS.)" = t.cost      
from #tempschfree t,      
invoiceabstract inv,       
invoicedetail Idet,items itm,customer cust,schemes sch      
where       
t.invoiceid=idet.invoiceid       
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                  
And Inv.CustomerId=@CustomerID                  
And Inv.InvoiceId=Idet.InvoiceId                
And Idet.product_code=Itm.product_code                  
And Inv.CustomerID=Cust.CustomerID                  
And (Idet.Schemeid=sch.Schemeid Or Idet.splcatschemeid = sch.Schemeid)   
And isnull(saleprice,0) >0 
And (isnull(idet.Freeserial,'')<>'' Or isnull(idet.splcatserial,'')<>'')  
And (IsNull(Inv.Status,0) & 192) =0                  
--And Sch.SchemeType IN (18, 84)      
And Sch.SchemeType = @SchemeID
And Sch.SchemeID = @SchID
--And idet.serial=t.freeserial  
--And (idet.serial = t.serial or idet.splcatserial = t.Serial)  
-- And Idet.SpecialCategoryScheme <> 1      
)Scheme                
group by [Item Code],[Item Name],  [Free Item Code],[Free Item Name]              
,[Invoice no],[Invoice date], [Quantity]      
Order by [Invoice no]              


-- select * from #tempSchfree      
  
drop table #tempSchfree      
        
End                    
                    
                    
if @SchemeID=19 or  @SchemeID=81 Or @SchemeID=21 Or @SchemeID=22  
Begin                    
--ItemBased Percentage           
          
Select Schs.product_code,                    
"Invoice no"=@Prefix + Cast(Inv.DocumentID as Varchar),                
"Invoice date"=Inv.InvoiceDate,                
"Item Code" = Schs.product_code,                    
"Item Name" = Itm.productname,                    
"Quantity" = sum(Schs.free),                    
"Discount %" = sum(Schs.cost),                    
"Cost" = Sum((SchS.Value*SchS.Cost)/100)                                                
From InvoiceAbstract Inv,Customer Cust,SchemeSale SchS,Schemes Sch,Items Itm                    
Where                 
Inv.CustomerId=@CustomerID                    
And Schs.product_code=Itm.product_code                    
And Inv.InvoiceId=Schs.InvoiceID                                        
And Inv.CustomerID=Cust.CustomerID                                                
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                                                  
And (IsNull(Inv.Status,0) & 192) =0                                      
And SchS.Quantity = 0                                      
And Sch.SchemeID= SchS.Type                                        
And Sch.SchemeType in (@SchemeID)--(19, 81, 21, 22)                    
And Sch.SchemeID = @SchID
-- And SchS.SpecialCategory <> 1  
Group by Schs.product_code,Itm.productname,Inv.DocumentID,Inv.InvoiceDate                  
Order by Inv.DocumentID                
End                    
                    
if @SchemeID=20 or  @SchemeID=82                    
--ItemBased Amount                                      
Begin           
          
select [Item Code],[Invoice no],[Invoice date],                
[Item Code],[Item Name],                    
"Quantity" = Sum([Quantity]),                    
"Discount Value" =sum([Discount Value])          
From (                  
Select Schs.product_code,                  
"Invoice no"=@Prefix + Cast(Inv.DocumentID as Varchar),                
"Invoice date"=Inv.InvoiceDate,                
"Item Code" = Schs.product_code,                    
"Item Name" = Itm.productname,                    
"Quantity" = Schs.free,                    
"Discount Value" = Schs.cost                  
From InvoiceAbstract Inv,Customer Cust,SchemeSale SchS,Schemes Sch,Items Itm                    
Where                     
Inv.CustomerId=@CustomerID                    
And Schs.product_code=Itm.product_code                    
And Inv.InvoiceId=Schs.InvoiceID                                        
And Inv.CustomerID=Cust.CustomerID                                                
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                                                  
And (IsNull(Inv.Status,0) & 192) =0                                      
And SchS.Quantity = 0                                      
And Sch.SchemeID= SchS.Type                                        
-- And SchS.SpecialCategory <> 1  
--And Sch.SchemeType in ( 20,82)
And Sch.SchemeType = @SchemeID
And Sch.SchemeID = @SchID
)schemes           
group by          
[Item Code],[Invoice no],[Invoice date],                
[Item Code],[Item Name]                                        
order by [Invoice no]              
          
End                    
End                                    
