CREATE PROCEDURE sp_update_staff(@STAFFNAME nvarchar(100),  
			      	@ADDRESS nvarchar(255),  
			      	@PHONE nvarchar(50), 
			      	@COMMISSION Decimal(18,6),
			      	@ACTIVE int) 
			      
AS  
UPDATE salesstaff SET 
     Address = @ADDRESS,  
     Phone = @PHONE,  
     Active = @ACTIVE,  
     Commission = @COMMISSION  

WHERE Staff_Name = @STAFFNAME 
