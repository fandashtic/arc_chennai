CREATE Function [dbo].[mERP_fn_GetBeatSalesman_ITC](@CustID nVarchar(256), @BSID Int, @BSC Int)
Returns nVarchar(256)
As 
Begin
	
	Declare @BS nVarchar(256)

	Declare @BeatSalesman Table (IDs Int Identity(1, 1), CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Beat nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	Salesman nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Insert InTo @BeatSalesman (CustomerID, Beat, Salesman)
	Select Distinct bs.CustomerID, bt.Description, sm.Salesman_name 
	From Beat_Salesman bs
	Inner Join Beat bt On bs.BeatID = bt.BeatID
	Left Outer Join Salesman sm On bs.SalesmanID = sm.SalesmanID 
	Where CustomerID Like @CustID

	If @BSID = 1
		Select @BS = Beat From @BeatSalesman Where IDs = @BSC
	Else 
		Select @BS = Salesman From @BeatSalesman Where IDs = @BSC

	Return @BS
End
