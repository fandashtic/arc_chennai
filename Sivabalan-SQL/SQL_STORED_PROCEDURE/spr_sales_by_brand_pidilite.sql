CREATE procedure spr_sales_by_brand_pidilite  
		(@VENDOR nvarchar(2550),
		 @BRANDNAME nVARCHAR (2550),  
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

Create table #tmpVendor(Vendor_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @VENDOR='%'     
 Insert into #tmpVendor select VendorID from Vendors Union Select ''  
Else    
 Insert into #tmpVendor Select VendorID From Vendors Where Vendor_Name In 
 (select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter))
  
Select Items.BrandID,"Division Name" = Brand.BrandName,   
"Net Value (%c)" = sum(Amount)   
from invoicedetail,InvoiceAbstract,Brand,Items
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID
And invoicedate between @FROMDATE and @TODATE  
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)  
And Brand.BrandName In (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv)   
and items.BrandID=Brand.BrandID   
and items.product_Code=invoiceDetail.product_Code  
And Items.Preferred_vendor In (Select Vendor_Name From #tmpVendor)
Group by Items.BrandID,Brand.BrandName  
  
drop table #tmpDiv     
  




