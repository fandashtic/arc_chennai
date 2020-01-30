CREATE procedure sp_ser_rpt_spareuseage(@Fromdate datetime,@Todate datetime,@SpareName nvarchar(50))
AS
select 'Spare Code' = sparecode,
'Spare Code' = sparecode,
'Spare Name' = productname, 
'Qty' = sum(quantity) from serviceinvoicedetail,serviceinvoiceabstract,items 
where serviceinvoicedetail.sparecode = items.product_code
and ProductName Like @SpareName                                    
and serviceinvoicedetail.serviceinvoiceid = serviceinvoiceabstract.serviceinvoiceid
and (serviceinvoicedate) between @FromDate and @ToDate                                                
and (IsNull(serviceinvoiceabstract.Status,0) & 192) = 0                                      
group by sparecode,productname

