
CREATE procedure [sp_insert_BeatSalesman]
	(@BeatID 	INT,
	 @SalesmanID 	INT,
	 @CustomerID 	[nvarchar](15))

AS INSERT INTO [Beat_Salesman] 
	 ( [BeatID],
	 [SalesmanID],
	 [CustomerID])
	  
 
VALUES 
	( @BeatID,
	 @SalesmanID,
	 @CustomerID)




