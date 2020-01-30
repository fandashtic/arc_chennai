
Create procedure [sp_Update_BeatSalesman]
	(@BeatID 	INT,
	 @SalesmanID 	INT,
	 @CustomerID 	[nvarchar](15))

AS Update [Beat_Salesman] 
SET BeatID=@BeatID,SalesmanID=@SalesmanID where CustomerID=@CustomerID



