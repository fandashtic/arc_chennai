
Create Procedure sp_delete_AdjustmentDocs(@CustID nvarchar(15), @ParentTranID nvarchar(50), @netaddr as nVarchar(100))
As
Begin
	Declare @TableID as int,@Adj_TranID as int,@Adj_TranType as int,@Adj_Adjusted as decimal(18,6),@TotAdj as decimal(18,6)
	Declare @spid as int, @Str as nVarchar(1000)
	Create Table #Tmp1(TabID int)
	Create Table #Tmp2(TableID int,Adj_TranID int,Adj_TranType int,Adj_Adjusted decimal(18,6))
	Create Table #Tmp3(TotAdj Decimal(18,6))
	
	Set @Str='Insert Into #Tmp1 Select TableID From ##' + @netaddr + ' Where CustID = '''+ @CustID +''' And ParentTranID = ''' + @ParentTranID + ''''
	
	Exec sp_executesql @Str
	
	Set @Str='Insert Into #Tmp2 Select TableID,TranID,TranType,Adjusted From ##' + @netaddr + ' Where CustID = ''' + @CustID + ''' And ParentTranID = ''' + @ParentTranID + ''' And Adjusted > 0'
	
	Exec sp_executesql @Str
	
	If Exists(Select * From #Tmp1)
	Begin
		Declare DEL_CURSOR CURSOR STATIC FOR  
		Select * From #Tmp2
		Open DEL_CURSOR  
		Fetch From DEL_CURSOR INTO @TableID,@Adj_TranID,@Adj_TranType,@Adj_Adjusted
		While @@FETCH_STATUS = 0  
		Begin  
			Truncate Table #Tmp3
			Set @Str='Insert Into #Tmp3 Select IsNull(Sum(Adjusted),0) From ##' + @netaddr + ' Where TableID >= ' + @TableID + ' And TranID = ' + @Adj_TranID + ' And TranType = ' + @Adj_TranType

			Exec sp_executesql @Str

			Select @TotAdj = TotAdj From #Tmp3

			Set @Str='Update ##' + @netaddr + ' Set PrevAdj=(PrevAdj-' + @TotAdj + ') Where TableID < ' + @TableID + ' And TranID = ' + @Adj_TranID + ' And TranType = ' + @Adj_TranType + ' And PrevAdj >= ' + @TotAdj
			Exec sp_executesql @Str

			Set @Str='Update ##' + @netaddr + ' Set OutStanding=(OutStanding+' + @Adj_Adjusted + '), Balance=(Balance+' + @Adj_Adjusted + ') Where TableID > ' + @TableID + ' And TranID = ' + @Adj_TranID + ' And TranType = ' + @Adj_TranType
			Exec sp_executesql @Str

			FETCH NEXT FROM DEL_CURSOR INTO @TableID,@Adj_TranID,@Adj_TranType,@Adj_Adjusted
		End
		Close DEL_CURSOR
		Deallocate DEL_CURSOR
	End
	Drop Table #Tmp1
	Drop Table #Tmp2
	Drop Table #Tmp3
End
