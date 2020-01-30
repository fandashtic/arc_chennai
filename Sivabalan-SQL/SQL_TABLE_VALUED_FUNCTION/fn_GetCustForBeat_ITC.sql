CREATE Function fn_GetCustForBeat_ITC
(
@SalesMan_Names nVarChar(4000),
@Beats nvarchar(4000),
@ParamDelimiter Char(1) = ','
)
Returns @CustID Table (CustID nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)
As
Begin
	Declare @Delimiter as Char(1)
	Set @Delimiter = @ParamDelimiter

	--N'%' will come from Rpt Viewer Procedures  
	--N'%%' will come from Rpt Viewer AutoComplete  

If @SalesMan_Names = N'%%' or @SalesMan_Names = N'%'
	Begin
		If @Beats = N'%%' or @Beats = N'%'
			Begin
      	Insert into @CustID Select CustomerID From Customer Where CustomerID Not in ('0')
			End
 		Else         
  		Begin         
  			Insert into @CustID Select Distinct CustomerID From  Beat_SalesMan
    		Where BeatID in 
				(Select BeatID from Beat Where [Description] in 
				(Select * from dbo.sp_SplitIn2Rows(@Beats,@Delimiter)))
  		End
	End
Else
	Begin
		If @Beats = N'%%' or @Beats = N'%'
			Begin
  			Insert into @CustID Select Distinct CustomerID From  Beat_SalesMan
    		Where SalesManID in 
				(Select SalesManID from SalesMan Where SalesMan_Name in 
				(Select * from dbo.sp_SplitIn2Rows(@SalesMan_Names,@Delimiter)))
			End
 		Else         
  		Begin         
  			Insert into @CustID Select Distinct CustomerID From  Beat_SalesMan
    		Where SalesManID in 
				(Select SalesManID from SalesMan Where SalesMan_Name in 
				(Select * from dbo.sp_SplitIn2Rows(@SalesMan_Names,@Delimiter)))
				And BeatID in 
				(Select BeatID from Beat Where [Description] in 
				(Select * from dbo.sp_SplitIn2Rows(@Beats,@Delimiter)))
  		End
	End
 Return          
End
