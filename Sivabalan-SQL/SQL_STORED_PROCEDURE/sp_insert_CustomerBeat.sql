
CREATE procedure [sp_insert_CustomerBeat]
	(@BeatID 	INT,
	 @CustomerID 	[nvarchar](15))

AS INSERT INTO [Beat_Salesman] 
	 ( [BeatID],
	 [CustomerID])
	  
 
VALUES 
	( @BeatID,
	  @CustomerID)



