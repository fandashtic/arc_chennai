Create PROCEDURE spr_list_CustomerSchemeSales_Abstract(              
@FromDate Datetime ,              
@ToDate DateTime,              
@CustomerName NVarchar(2550),              
@SchemeName NVarchar(2550)                            
) As                        
              
Begin                                              
              
Declare @Delimeter as Char(1)                                                
Set @Delimeter=Char(15)                                               
Create table #tmpSch(SchemeName NVarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)              
Create table #tmpCus(CustomerName NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)              
                                              
If @SchemeName='%'                                                 
   Insert into #tmpSch select SchemeName from Schemes                                                
Else                                                
   Insert into #tmpSch select * from dbo.sp_SplitIn2Rows(@SchemeName,@Delimeter)                                                
              
If @CustomerName= '%'              
   Insert into #tmpCus select Company_Name from Customer              
Else                                                
   Insert into #tmpCus select * from dbo.sp_SplitIn2Rows(@CustomerName,@Delimeter)                                                
            
--InvoiceBased Free Items For Value                           

-----------------------------------------------

-- select * from #tmpSch              
-- select * from #tmpCus              

-----------------------------------------------
      
Select [Scheme Type],          
"Scheme Name"=[Scheme Name],          
"Customer Name"=[Customer Name],          
"Total Invoices"=Count(distinct [Total Invoices]),          
"Cost of Scheme"=sum([Cost of Scheme]),          
"Sales value of the scheme"=sum([Sales value of the scheme])          
From (          
Select       
"Scheme Type" = cast(Sch.SchemeType as varchar) + '|' +Inv.CustomerID + '|' + cast(Sch.SchemeID as varchar),              
"Scheme Name" = sch.schemename,               
"Customer Name"=company_name,              
"Total Invoices"=inv.invoiceid ,              
"Cost of Scheme" = Sum(SchS.Cost),              
"Sales value of the scheme"= Inv.NetValue      
From Schemes Sch,SchemeSale SchS,InvoiceAbstract Inv,customer cus          
Where Sch.SchemeName in (Select SchemeName From #tmpSch)              
And Cus.Company_name in (Select CustomerName from #tmpCus)              
And SchS.Type=Sch.schemeID                                
And Inv.InvoiceID=SchS.InvoiceID                                 
And Inv.customerID=cus.customerID                         
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                                      
And (IsNull(Inv.Status,0) & 192) =0                              
And Sch.SchemeType in (3,4,97,99)
Group by sch.schemeID, sch.schemename, Sch.SchemeType,company_name,Inv.CustomerID             
,inv.invoiceid,inv.netvalue)schemes      
group by [Scheme Type],[Scheme Name],[Customer Name]          
           
Union                              
--Item Based Same Item Free /Item Based Different Item Free     
    
Select [Scheme Type],          
"Scheme Name"=[Scheme Name],          
"Customer Name"=[Customer Name],          
"Total Invoices"=Count(distinct [Total Invoices]),          
"Cost of Scheme"=sum([Cost of Scheme]),          
"Sales value of the scheme"=sum([Sales value of the scheme])          
From (          
Select           
"Scheme Type" = cast(Sch.SchemeType as varchar) + '|' + Inv.CustomerID + '|' + cast(Sch.SchemeID as varchar),      
"Scheme Name" = sch.schemename,               
"Customer Name"=company_name,              
"Total Invoices"=inv.invoiceid,              
"Cost of Scheme"=sum(Schs.cost),      
"Sales value of the scheme"=(select  sum(Amount) from invoicedetail 
where invoiceid=inv.invoiceid and 
(isnull(Freeserial,'')<>'' or isnull(SPLCATSerial, '') <> ''))
From InvoiceAbstract Inv,Customer Cus,SchemeSale SchS,Schemes Sch,Items Itm                
Where                 
Schs.product_code=Itm.product_code                
And Sch.SchemeName in (Select SchemeName From #tmpSch)              
And Cus.Company_name in (Select CustomerName from #tmpCus)              
And Inv.InvoiceId=Schs.InvoiceID                                    
And Inv.CustomerID=Cus.CustomerID                                            
And Inv.InvoiceDate BetWeen @FromDate And @ToDate                                              
And (IsNull(Inv.Status,0) & 192) =0                                  
And Sch.SchemeID= SchS.Type                                    
And Sch.SchemeType in ( 17, 83, 18, 84)      
-- And SchS.SpecialCategory <> 1
group by Sch.SchemeID,Sch.SchemeType,sch.schemename,company_name,inv.invoiceid,Inv.CustomerID,inv.invoiceid      
)Scheme          
group by [Scheme Type],[Scheme Name],[Customer Name]       
              
Union                              
              
--ItemBased Percentage                              
Select [Scheme Type],          
"Scheme Name"=[Scheme Name],          
"Customer Name"=[Customer Name],          
"Total Invoices"=Count(distinct [Total Invoices]),          
"Cost of Scheme"=sum([Cost of Scheme]),          
"Sales value of the scheme"=sum([Sales value of the scheme])          
from (          
Select            
"Scheme Type" = cast(Sch.SchemeType as varchar) + '|' + Inv.CustomerID + '|' + cast(Sch.SchemeID as varchar),              
"Scheme Name" = sch.schemename,          
"Customer Name"=company_name,          
"Total Invoices"=Idet.invoiceid,              
"Cost of Scheme" = (select sum (discountvalue) from invoicedetail where  product_code=Idet.Product_code And invoiceid=Idet.InvoiceID ) ,          
"Sales value of the scheme"= (select sum(Amount) from invoicedetail where  product_code=Idet.Product_code And invoiceid=Idet.InvoiceID)          
from invoicedetail Idet                    
inner join InvoiceAbstract Inv on Inv.InvoiceId=Idet.InvoiceId                  
inner join Customer Cus on Inv.CustomerID=Cus.CustomerID                  
left join Schemes Sch on (Idet.Schemeid=sch.Schemeid Or Idet.SPLCATSCHEMEID = sch.Schemeid)
left join SchemeSale SchS on  schs.InvoiceId=Inv.InvoiceId                  
Where Sch.SchemeName in (Select SchemeName From #tmpSch)          
And Cus.Company_name in (Select CustomerName from #tmpCus)          
And SchS.Type=Sch.schemeID          
And Inv.InvoiceID=SchS.InvoiceID          
And Inv.customerID=cus.customerID         
And Inv.InvoiceDate BetWeen @FromDate And @ToDate          
And (IsNull(Inv.Status,0) & 192) =0          
And SchS.Quantity = 0          
And isnull(Idet.discountvalue,0)>0          
And Sch.SchemeType in (19,81,20,82, 21, 22)          
-- And SchS.SpecialCategory <> 1
Group by sch.schemeid, sch.schemename, Sch.SchemeType ,company_name ,Inv.CustomerID          
,Idet.Product_code,Idet.Invoiceid )dkfk          
Group by [Scheme Type],[Scheme Name],[Customer Name]          
              
drop table #tmpSch              
drop table #tmpCus              
              
End                              
  
