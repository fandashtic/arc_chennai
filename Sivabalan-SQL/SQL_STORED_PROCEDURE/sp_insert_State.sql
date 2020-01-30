
CREATE PROCEDURE [sp_insert_State]
	(	 @State_2 	[nvarchar](50))

AS INSERT INTO [State] 
	 ( 
	 [State]) 
 
VALUES 
	(@State_2)


select @@identity


