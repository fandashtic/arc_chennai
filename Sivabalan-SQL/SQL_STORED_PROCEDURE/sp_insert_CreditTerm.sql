CREATE PROCEDURE sp_insert_CreditTerm(@DESCRIPTION NVARCHAR(50),  
          @TYPE INT,  
          @VALUE Decimal(18,6),
		  @DontReturnRS INT = 0)  
AS  
-- Variable @DontReturnRS is Used to Return the Result Set (Open Statements Like "Select")
-- If and Only if @DontReturnRS is Set to 0

INSERT INTO CreditTerm (Description,  
   Type,  
   Value)  
VALUES  
   (@DESCRIPTION,  
    @TYPE,  
    @VALUE)  

If @DontReturnRS = 0   
    SELECT @@IDENTITY  

