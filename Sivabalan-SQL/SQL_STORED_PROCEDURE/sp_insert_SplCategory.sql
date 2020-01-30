
CREATE PROCEDURE sp_insert_SplCategory(@CATEGORYTYPE INT, @DESCRIPTION NVARCHAR(255), @ACTIVE INT)

AS

INSERT INTO Special_Category (CategoryType,
			              Description, 
  			              Active)
VALUES
		 	            (@CATEGORYTYPE,
                                                     @DESCRIPTION,
                   		             @ACTIVE)

SELECT @@IDENTITY



