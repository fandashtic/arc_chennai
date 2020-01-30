CREATE procedure sp_ser_autolist_customer(@mode integer,  
@KeyField varchar(30)='%',@Direction int = 0, @BookMark varchar(128) = '')  
as  
IF @mode =1   
begin  
	IF @Direction = 1  
	begin   
		select CustomerID,Company_Name from customer where 
	  	CustomerID like @KeyField and Company_Name > @BookMark  and 
	  	(CustomerCategory = 4 or Active <> 0)
	 	order by Company_Name  
	end  
	Else  
	begin  
		select CustomerID,Company_Name from customer where 
		CustomerID like @KeyField  and (CustomerCategory = 4 or Active <> 0)
		order by Company_Name  
	end     
end  
else if @mode = 2   
begin    
	IF @Direction = 1  
	begin   
		select CustomerID,Company_Name from customer  
		where company_Name like @keyfield and company_Name > @BookMark  and 
		(CustomerCategory = 4 or Active <> 0)
		order by company_name  
	end  
	Else  
	begin  
		select CustomerID,Company_Name from customer  
		where company_Name like @keyfield  and (CustomerCategory = 4 or Active <> 0)
		order by company_name  
	end  
end    

/*   
All active customers and Walkin customer    
Procedures first used in Collection
*/ 


