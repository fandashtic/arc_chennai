CREATE procedure spr_ser_sales_by_brand(@BRANDNAME VARCHAR (2550),  
                 @FROMDATE DATETIME,  
                 @TODATE DATETIME)  
As  

  
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)    
CREATE Table #DivsionTemp(BrandID int,DivisionName varchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS ,NetValue Decimal(18,6))
 
Create table #tmpDiv(Division varchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)      

if @BRANDNAME='%'      
   Insert into #tmpDiv select BrandName from Brand      
Else      
   Insert into #tmpDiv select * from dbo.sp_SplitIn2Rows(@BRANDNAME,@Delimeter)      

Insert Into #DivsionTemp  
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

Insert Into #DivsionTemp
	Select Items.BrandID,"Division Name" = Brand.BrandName,   
	"Net Value (%c)" = sum(Isnull(serviceinvoicedetail.NetValue,0))   
	from serviceinvoicedetail,serviceInvoiceAbstract,Brand,Items   
	where serviceinvoiceAbstract.serviceInvoiceID=serviceInvoiceDetail.serviceInvoiceID   
	and serviceinvoicedate between @FROMDATE and @TODATE  
	And Isnull(serviceInvoiceAbstract.Status,0)&192=0 
	And Isnull(serviceinvoicedetail.sparecode,'') <> ''
	And serviceInvoiceAbstract.serviceInvoiceType in (1)  
	And Brand.BrandName In (select Division COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpDiv)   
	and items.BrandID=Brand.BrandID   
	and items.product_Code=serviceinvoiceDetail.spareCode  
	Group by Items.BrandID,Brand.BrandName    

drop table #tmpDiv     
select "Brand ID" = BrandId,  "Division Name" = DivisionName, "Net Value (%c)" = sum(NetValue) 
from #DivsionTemp Group by BrandID,DivisionName  
drop table #DivsionTemp




