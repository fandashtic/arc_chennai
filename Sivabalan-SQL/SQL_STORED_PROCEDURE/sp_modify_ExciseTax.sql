CREATE PROCEDURE sp_modify_ExciseTax(@TAXCODE INT,@PERCENTAGE decimal(18,6),@ACTIVE INT)      
AS      
update ExciseTax  set Percentage=@PERCENTAGE ,    
Active = @ACTIVE where Tax_Code = @TAXCODE    
  

