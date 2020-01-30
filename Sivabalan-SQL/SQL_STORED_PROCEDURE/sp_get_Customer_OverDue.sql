create procedure sp_get_Customer_OverDue(   
	@CustomerID nvarchar(2550),    
	@CurrDate datetime,  
	@OverDue int = 0)  
as     

if @OverDue = 0  
begin  
	--This block will return Not overdue amount
	create table #temp(NotOverDue Decimal(18,6))    
	
	--Balance from invoice
	insert #temp(NotOverDue)     
		Select Sum(Case Inv.InvoiceType When 4 then 0-Isnull(Inv.Balance,0)   
			When 5 then 0-Isnull(Inv.Balance,0) When 6 then 0-Isnull(Inv.Balance,0)   
			Else IsNull(Inv.Balance,0) End)    
			From InvoiceAbstract As Inv    
			Where Inv.CustomerID = @CustomerID And    
			Inv.PaymentDate >=@CurrDate and    
			Inv.Balance > 0 And    
			Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And    
			Inv.Status & 128 = 0  
	
	--Balance from invoice Creditnote
	insert #temp(NotOverDue)   
		select -sum(Creditnote.Balance)    
		from Creditnote where Creditnote.Customerid = @customerid and    
		Creditnote.Balance > 0     
		group by Creditnote.CustomerID      
	
	--Balance from invoice Debitnote
	insert #temp(NotOverDue)    
		select sum(Debitnote.Balance)    
			from debitnote where Debitnote.Customerid =@customerid  and    
			Debitnote.Balance > 0 group by Debitnote.CustomerID      
	
	--Balance from invoice Collection
	insert #temp(NotOverDue)    
		Select -Sum(Collections.Balance)    
			From Collections Where Collections.CustomerID = @customerid and  
			Collections.Balance > 0 And	IsNull(Collections.Status, 0) & 128 = 0    
			Group By Collections.CustomerID    
	
	select  "Amount" =Sum(NotOverDue) From #temp  
	drop table #temp    
end  
else  
begin  
	--This block will return overdue amount
	select  "Amount" = Sum(Case InvoiceType When 4 then 0-IsNull(Balance,0)  
		When 5 then 0-IsNull(Balance,0) When 6 then 0-IsNull(Balance,0)    
		Else IsNull(Balance,0) End) from InvoiceAbstract Where Invoicetype In (1, 2, 3, 4, 5, 6)   
		And (Status & 128) =0 And CustomerId=@CustomerID And PaymentDate < @CurrDate   
		And Balance <> 0  
end  







