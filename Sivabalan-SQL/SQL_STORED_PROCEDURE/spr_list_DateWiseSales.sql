CREATE Procedure spr_list_DateWiseSales (@FromDate datetime, @ToDate datetime)  
as  
Select dbo.StripDateFromTime(InvoiceDate),   
"Invoice Date" = dbo.StripDateFromTime(InvoiceDate),   
"Amount" = sum(case InvoiceType   
WHEN 4 then   
0 - (Isnull(NetValue,0) - Isnull(Freight,0))   
else   
(Isnull(NetValue,0) - Isnull(Freight,0))   
end)  
From InvoiceAbstract  
WHERE  (Status & 128) = 0 And InvoiceDate Between @FromDate And @ToDate  
and invoicetype in(1,2,3,4)
Group By dbo.StripDateFromTime(InvoiceDate) 
