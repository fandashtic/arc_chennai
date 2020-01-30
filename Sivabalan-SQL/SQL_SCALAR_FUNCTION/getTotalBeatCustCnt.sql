CREATE function getTotalBeatCustCnt (@BeatId int,@FromDate datetime,@ToDate datetime )    
returns decimal(18,6)    
as    
Begin    
declare @Count decimal(18,6)    
select @Count = count(distinct customerid) from invoiceabstract,invoicedetail 
where invoicedetail.invoiceid = invoiceabstract.invoiceid  And InvoiceAbstract.InvoiceDate BETWEEN @FromDate AND @ToDate 
and invoiceabstract.invoicetype in (1,3) And (status & 128) = 0 and beatid = @beatId    
return @count    
end 
