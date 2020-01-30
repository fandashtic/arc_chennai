CREATE procedure spr_list_Van_To_Invoice (  
@VanNo nvarchar(2550),   
@FromDate datetime,   
@ToDate datetime)  
AS  
Begin  
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)    
create table #tmpVan(VanNumber nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @VanNo='%'   
	Insert into #tmpVan select Van from Van
Else  
	Insert into #tmpVan select * from dbo.sp_SplitIn2Rows(@VanNo,@Delimeter)  
  
 select "VanNo1" = VanNumber, "Van" = VanNumber,   
 "Total Weight" = sum(isnull(conversionfactor,0) * isnull(quantity,0))  
 from items, invoiceabstract ia, invoicedetail idt  
 where   
 items.product_code = idt.product_code and  
 idt.invoiceid = ia.invoiceid   
 and vannumber is not null and   
 ia.vannumber IN (Select VanNumber COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpVan) and  
 ia.invoicedate between @FromDate and @ToDate  and 
 ia.Status & 192 = 0
 group by vannumber  

 Drop Table #tmpVan
END  



