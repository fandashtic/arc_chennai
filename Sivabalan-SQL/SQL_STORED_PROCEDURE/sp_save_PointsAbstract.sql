
CREATE PROCEDURE sp_save_PointsAbstract             
(@DefinitionType int, @Points int,              
@Value decimal(18,6), @Active int,@DefName nvarchar(25)='',@Customer int=0)              
AS       
Declare @DocID AS Int    
--Updating Document Numbers For CustomerPoints
Begin Tran        
	Update DocumentNumbers Set DocumentID =  DocumentID + 1 Where DocType = 67      
	Select @DocID= DocumentID - 1 From DocumentNumbers where DocType=67  
Commit Tran        
      
INSERT INTO PointsAbstract              
([DefinitionType],              
[Points], [Value], [Active],[DefinitionName],[Customer],[DocumentID])               
VALUES               
(@DefinitionType,              
@Points, @Value, @Active,@DefName,@Customer,@DocID)              
SELECT @@IDENTITY 

