CREATE Procedure [dbo].[SPR_SalesMan_Monthly_Report_Abstract](          
@SalesManName nvarchar(4000),          
@FromDate DateTime,          
@Todate DateTime,          
@Val_Volume nVarchar(50))            
as          
Declare @Delimeter as Char(1)              
Set @Delimeter=Char(15)              
Create table #TmpSalesMan(SalesManid integer)              
          
if @SalesManName='%'               
   Begin      
   Insert into #TmpSalesMan select SalesManid from SalesMan          
   Insert into #TmpSalesman Values (0)    
   end      
Else      
   Begin      
   Insert into #TmpSalesMan     
  Select salesmanid from Salesman where salesman_name in (select * from dbo.sp_SplitIn2Rows(@SalesManName,@Delimeter))              
   end        
    
  
    
 select isnull(invoiceabstract.salesmanid,0),    
 "SalesMan Name" = case isnull(InvoiceAbstract.SalesmanID, 0) when 0 then dbo.LookupDictionaryItem('Others',Default)     
 else Salesman.Salesman_Name end      
 ,"Total Qty "= sum(Case InvoiceType When 4 then 0-Quantity Else Quantity end)          
 ,"Total Value "= sum(Case InvoiceType When 4 then 0-Amount Else Amount end)          
 from invoiceabstract
 Inner Join Invoicedetail on Invoiceabstract.invoiceid = invoicedetail.invoiceid
 Left Outer Join Salesman on Isnull(invoiceabstract.Salesmanid,0) = Salesman.Salesmanid
 WHERE 
 --Invoiceabstract.invoiceid = invoicedetail.invoiceid        
 --And 
 Invoicedate Between @FromDate And @Todate    
 And Invoiceabstract.status & 128 = 0       
 And Invoiceabstract.invoicetype in (1,3,4)     
 --And Isnull(invoiceabstract.Salesmanid,0)*= Salesman.Salesmanid       
 --(Case @COUNT WHEN 1     
 And isnull(invoiceabstract.Salesmanid,0)IN    
 (select SalesManid  from #TmpSalesMan)        
     
 group by     
 isnull(invoiceabstract.Salesmanid,0)    
 ,Salesman.Salesman_Name    
     
Drop table #tmpSalesman    
