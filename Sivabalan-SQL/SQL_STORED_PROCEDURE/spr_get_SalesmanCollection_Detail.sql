CREATE procedure spr_get_SalesmanCollection_Detail (@SalesMan numeric, @FromDate DateTime, @ToDate DateTime, @CollType nvarchar(25))  
as  
begin  
 select   
 Distinct DBO.StripDateFromTime(Col.DocumentDate),   
 "Date" = DBO.StripDateFromTime(Col.DocumentDate),  
 "Collected Value" = sum(Col.Value)  
 from Collections Col
 Left Outer Join SalesMan SM ON Col.SalesManID = SM.SalesManID 
 where   
 isnull(Col.SalesManID,0) = @SalesMan   
  
 and cast(Col.PaymentMode as nvarchar) like (case @CollType   
 when 'Cash' then '0'   
 when 'Cheque' then '1'   
 when 'DD' then '2'   
 when 'Credit Card' then '3'   
 when 'Bank Transfer' then '4'  
 when 'Coupon' then '5'   
 else '%' end)   
 and Col.DocumentDate between @FromDate and @ToDate  
 and (isnull(Col.Status,0) & 192) = 0  
 group by DBO.StripDateFromTime(Col.DocumentDate)   
end  
      
