CREATE procedure spr_sales_by_brand  
                (@BRANDNAME nVARCHAR (2550),  
                 @FROMDATE DATETIME,  
                 @TODATE DATETIME)  
As  
  
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)    
Create table #tmpDiv(Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @BRANDNAME='%'      
   Insert into #tmpDiv select BrandName from Brand      
Else      
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@BRANDNAME,@Delimeter)      
  
Select Items.BrandID,"Division Name" = Brand.BrandName,   
"Net Value (%c)" = sum(Amount)   
from invoicedetail,InvoiceAbstract,Brand,Items   
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @FROMDATE and @TODATE  
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)  
And Brand.BrandName In (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv)   
and items.BrandID=Brand.BrandID   
and items.product_Code=invoiceDetail.product_Code  
Group by Items.BrandID,Brand.BrandName  
  
drop table #tmpDiv     
  




