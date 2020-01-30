CREATE procedure SPRVanToInvoice_Weight_Abstract(      
@VanNo nvarchar(4000),  
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
 Insert into #tmpVan  
 Select VAN from VAN where VAN_Number in (select * from dbo.sp_SplitIn2Rows(@VANNo,@Delimeter))                  
  
      
 select  VanNumber, "Van Number" = VAN.Van_Number,  
 "Van Name" = IA.VanNumber,       
 "Total Weight" = sum(isnull(conversionfactor,0) * isnull(quantity,0))      
 from invoiceabstract ia, invoicedetail idt ,items,VAN      
 where       
 idt.invoiceid = ia.invoiceid       
 And idt.Product_Code=items.Product_Code  
 and vannumber is not null and       
 Ia.Vannumber = Van.Van And  
 ia.vannumber IN (Select VanNumber COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpVan) and      
 ia.invoicedate between @FromDate and @ToDate  and     
 ia.Status & 128 = 0    
 group by ia.vannumber ,Van.Van_Number     
    
 select * from #tmpvan  
 Drop Table #tmpVan    
END      
  
  
  
  
  


