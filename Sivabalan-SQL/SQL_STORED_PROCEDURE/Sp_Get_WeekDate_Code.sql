CREATE procedure Sp_Get_WeekDate_Code (@SalesmanId nvarchar(30))          
As      
Select Top 1 Code,Weekdate from wcpabstract                       
where salesmanid=@SalesmanId    
And status & 128 = 0  And status & 32 = 0        
order by WeekDate desc

