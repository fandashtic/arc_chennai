
Create procedure [sp_Update_CustomerBeat]
	(@BeatID 	INT,
	 @CustomerID 	[nvarchar](15))

AS Update [Beat_Salesman] 
SET BeatID=@BeatID where CustomerID=@CustomerID

