Create Procedure sp_Get_CGCustomer_PreDefFlag(@Customer nvarchar(50))
As

	Select isnull(C.PreDefFlag,0) CGPreDefFlag, isnull(B.BeatID,0) CGBeatID, B.Description CGBeatName From Customer C 
		Inner Join Beat B ON C.DefaultBeatID = B.BeatID and B.Active = 1
		Where (C.CustomerID = @Customer Or C.CustomerID = (Select CustomerID From Customer Where Company_Name=@Customer))

