
CREATE PROCEDURE sp_consolidate_credit (@CREDIT nvarchar(50),
	  			    	@TYPE int,
					@VALUE int,
				    	@ACTIVE int)
AS
IF NOT EXISTS (SELECT CreditID FROM CreditTerm WHERE Description = @CREDIT)
BEGIN
Insert CreditTerm(Description, Type, Value, Active)
VALUES(@CREDIT, @TYPE, @VALUE, @ACTIVE)
END


