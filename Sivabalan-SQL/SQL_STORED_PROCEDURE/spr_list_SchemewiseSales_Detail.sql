
Create PROCEDURE spr_list_SchemewiseSales_Detail(                  
@Scheme NVarchar(2550),        
@Product_Hierarchy nvarchar(2550),                   
@Category nvarchar(2550),                   
@ItemCode nVarchar(2550),        
@ItemName nVarchar(2550),        
@SchemeName NVarchar(2550),                                      
@FromDate Datetime ,                        
@ToDate DateTime                        
)As                  
                  
Declare @SchemeID as Integer                  
Declare @SchID as Integer                  
Declare @Prefix as Varchar(2)                  
Begin                            
        
Declare @Delimeter as Char(1)                                                            
Set @Delimeter=Char(15)                                                           
        
Create Table #ItemCode (ItemCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #SchemeName (SchemeName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tempCategory(CategoryID int, Status int)                    
        
Exec GetLeafCategories @PRODUCT_HIERARCHY, @CATEGORY             

-- If @SchemeName = '%'             
--  Insert Into #SchemeName Select SchemeName From Schemes 
-- Else            
--  Insert Into #SchemeName Select * From DBO.sp_SplitIn2Rows(@SchemeName,@Delimeter)            
        
If @ItemCode = '%'             
 Insert Into #ItemCode Select Product_Code From Items            
Else            
 Insert Into #ItemCode Select * From DBO.sp_SplitIn2Rows(@ItemCode,@Delimeter)            
                       
select @Prefix = Prefix from VoucherPrefix where TranID = 'INVOICE'                              
set @SchemeID = Cast(Substring(@Scheme, 1, Charindex(@Delimeter, @Scheme, 1) -1) as Integer) --cast( @Scheme as integer)                            
set @SchID = Cast(Substring(@Scheme, Charindex(@Delimeter, @Scheme, 1) + 1, Len(@Scheme)) as Integer) --cast( @Scheme as integer)                            
        
Insert Into #SchemeName Select SchemeName From Schemes Where SchemeID = @SchID

if @SchemeID=3 or @SchemeID=4 or @SchemeID=97 or @SchemeID=99
Begin                                  
--InvoiceBased Free Items For Value                                            
--We can not give the Details for this scheme        
        
 Select                         
 Schs.product_code,                            
 "Code"=schs.product_code,                            
 "Item Name"=Itm.ProductName,                            
 "Quantity" = Sum(SchS.Free),                    
 "Cost(Rs)" = Sum(Schs.cost)                  
 From InvoiceAbstract Inv                     
 left join SchemeSale SchS on Inv.InvoiceId=Schs.InvoiceID                            
 left join Schemes Sch on Schs.Type=sch.Schemeid                            
 left join Items Itm on  Schs.product_code=Itm.product_code                            
         
 where                            
 Inv.InvoiceDate BetWeen @FromDate And @ToDate                            
 And (IsNull(Inv.Status,0) & 192) =0                                            
And Sch.SchemeType = @SchemeID
And Sch.SchemeName In (Select SchemeName From #SchemeName)
group by Schs.product_code, schs.product_code,Itm.ProductName                            
                    
End                            
        
                            
If @SchemeID=17  Or @SchemeID=83  
--Item Based Same product free                    
Begin                            
        
select         
"Item Code"=[Free Item Code],        
"Item Code"=[Free Item Code],                          
"Item Name"=[Free Item Name],                            
"Quantity" =sum([Free Qty]) ,                            
"Cost(Rs)" =sum([Free Item Value (PTS.)])                            
From (                          
select        
--"Free Item Code" = Idet.product_code,                      
--"Free Item Name" = Itm.productname,                        
"Free Item Code"=(select distinct Product_Code from invoicedetail where  product_code=Idet.Product_code And invoiceid=Idet.InvoiceID  and Saleprice=0 and freeserial =cast(Idet.Serial as varchar) ),                            
"Free Item Name"=(Select ProductName from Items where product_code=(select distinct Product_Code from invoicedetail where  product_code=Idet.Product_code And invoiceid=Idet.InvoiceID  and Saleprice=0 and freeserial =cast(Idet.Serial as varchar) )),       
     
      
        
"Free Qty" = (select sum(quantity)from invoicedetail where  product_code=Idet.Product_code And invoiceid=Idet.InvoiceID  and Saleprice=0 and freeserial =cast(Idet.Serial as varchar) group by product_code),                            
"Free Item Value (PTS.)" =(select sum(cost)  from schemesale where invoiceid=idet.invoiceid and Serial=Idet.freeSerial )                    
from invoicedetail Idet                              
inner join InvoiceAbstract Inv on Inv.InvoiceId=Idet.InvoiceId                            
inner join Items Itm on  Idet.product_code=Itm.product_code                            
left join Schemes Sch on Idet.Schemeid=sch.Schemeid        
where                       
Inv.InvoiceDate BetWeen @FromDate And @ToDate                            
And isnull(saleprice,0) >0 And isnull(Freeserial,'')<>''                   
And (IsNull(Inv.Status,0) & 192) =0                            
and Itm.CategoryID In (Select CategoryID From #tempCategory)          
and Itm.product_Code In (Select ItemCode From #ItemCode)          
and inv.invoicetype in (1,2,3)    
And Sch.SchemeType In (17, 83)
And Sch.SchemeName In (Select SchemeName From #SchemeName))Scheme                            
group by [Free Item Code],[Free Item Name]        
            
End                            
                           
If @SchemeID=18 Or @SchemeID=84  
--Item based diff item free                
Begin                            
              
-- DBO.sp_SplitIn2Rows(@ItemCode,@Delimeter)

select f.invoiceid,f.product_code,s.quantity,s.free,s.cost,f.serial,  
"freeserial" = Case IsNull(f.freeserial, N'') When N'' then f.splcatserial else IsNull(f.freeserial, N'') End  
into #tempSchfree              
from Invoicedetail f,schemesale s,invoiceabstract a, schemes sc
where f.invoiceid=s.invoiceid and f.serial=s.serial              
And f.invoiceid=a.invoiceid              
And (IsNull(a.Status,0) & 192) = 0         
And a.InvoiceDate BetWeen @FromDate And @ToDate                          
And s.type = sc.schemeid
And sc.schemetype in (18, 84)

-- select * from #ItemCode              
--select * from #tempSchfree
select         
"Item Code"=[Free Item Code],        
"Item Code"=[Free Item Code],                        
"Item Name"=[Free Item Name],                          
"Quantity" =sum([Free Qty]) ,                          
"Cost(Rs)" = sum([Free Item Value (PTS.)])                          
From (                        
select  
--"Free Item Code" = Idet.product_code,                        
--"Free Item Name" = Itm.productname,                        
-- idet.serial ,
-- t.serial ,
-- idet.splcatserial ,
-- t.freeserial,
"Free Item Code"=t.product_code,              
"Free Item Name"=(Select ProductName from Items where product_code=t.product_code),              
"Free Qty" = t.free,              
"Free Item Value (PTS.)" = t.cost
from #tempschfree t,              
invoiceabstract inv,               
invoicedetail Idet,items itm,schemes sch              
where               
t.invoiceid=idet.invoiceid               
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                          
And Inv.InvoiceId=Idet.InvoiceId                          
And Idet.product_code=Itm.product_code        
And (Idet.Schemeid=sch.Schemeid Or Idet.splcatschemeid = sch.Schemeid)  
--And isnull(saleprice,0) = 0 
And (isnull(idet.Freeserial,'')<>'' Or isnull(idet.splcatserial,'')<>'')  
And (IsNull(Inv.Status,0) & 192) =0         
and Itm.CategoryID In (Select CategoryID From #tempCategory)          
and Itm.product_Code In (Select ItemCode From #ItemCode)          
And Sch.SchemeType In (18, 84)  
and inv.invoicetype in (1,2,3) 
And Sch.SchemeName In (Select SchemeName From #SchemeName)   
And (idet.serial = t.serial) -- or idet.splcatserial = t.Serial)
--And Idet.SpecialCategoryScheme <> 1              
)Scheme                        
group by [Free Item Code],[Free Item Name]        
          
drop table #tempSchfree              
                
End                            
                            
                            
if @SchemeID=19 or  @SchemeID=81 or @SchemeID=21 or @SchemeID=22  
Begin                            
--ItemBased Percentage                   
                  
Select         
"Item Code" = Schs.product_code,          
"Item Code" = Schs.product_code,                            
"Item Name" = Itm.productname,                            
"Quantity" = sum(Schs.free),                            
"Discount %" = sum(Schs.cost),                            
"Cost(Rs)" = Sum((SchS.Value*SchS.Cost)/100)                                                        
From InvoiceAbstract Inv,SchemeSale SchS,Schemes Sch,Items Itm        
Where                         
Schs.product_code=Itm.product_code                     
And Inv.InvoiceId=Schs.InvoiceID                                                
And Inv.InvoiceDate BetWeen @FromDate And @ToDate        
And (IsNull(Inv.Status,0) & 192) =0                                              
And SchS.Quantity = 0                                              
And Sch.SchemeID= SchS.Type        
and Itm.CategoryID In (Select CategoryID From #tempCategory)          
and Itm.product_Code In (Select ItemCode From #ItemCode)   
And Sch.SchemeName In (Select SchemeName From #SchemeName)       
And Sch.SchemeType in (@SchemeID) --(19, 81, 21, 22)          

-- And SchS.SpecialCategory <> 1                    
and inv.invoicetype in (1,2,3)    
Group by Schs.product_code,Itm.productname        
End                            
                            
if @SchemeID=20 or  @SchemeID=82                            
--ItemBased Amount                                              
Begin                   
                  
select [Item Code],        
[Item Code],[Item Name],                            
"Quantity" = Sum([Quantity]),                            
--"Discount %" ='',        
"Cost(Rs)"=sum([Discount Value])                  
From (                          
Select         
"Item Code" = Schs.product_code,                            
"Item Name" = Itm.productname,                           
"Quantity" = Schs.free,                            
"Discount Value" = Schs.cost                          
From InvoiceAbstract Inv,SchemeSale SchS,Schemes Sch,Items Itm                            
Where                             
Schs.product_code=Itm.product_code                            
And Inv.InvoiceId=Schs.InvoiceID                   
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                                                          
And (IsNull(Inv.Status,0) & 192) =0                                              
And SchS.Quantity = 0                                              
And Sch.SchemeID= SchS.Type          
-- And SchS.SpecialCategory <> 1                                        
and Itm.CategoryID In (Select CategoryID From #tempCategory)          
and Itm.product_Code In (Select ItemCode From #ItemCode)          
and inv.invoicetype in (1,2,3)    
And Sch.SchemeType in ( 20,82)
And Sch.SchemeName In (Select SchemeName From #SchemeName))schemes                   
group by                  
[Item Code],[Item Name]                                                
End                           
        
drop table #ItemCode        
drop table #tempCategory        
        
End                                            
      

