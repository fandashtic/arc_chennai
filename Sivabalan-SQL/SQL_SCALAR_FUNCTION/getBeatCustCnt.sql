CREATE function getBeatCustCnt (@BeatId int)  
returns Decimal(18,6)  
as  
Begin  
declare @Count Decimal(18,6)  
select @Count = count(distinct beat_salesman.customerid) from beat_salesman,customer where beat_salesman.customerid = customer.customerid and beatid = @beatId  
return @count  
end 
