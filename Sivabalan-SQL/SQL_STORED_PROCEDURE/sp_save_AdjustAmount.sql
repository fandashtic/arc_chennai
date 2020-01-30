
Create Procedure sp_save_AdjustAmount(@PTranID nvarchar(50), @CustID nvarchar(15), @TranID int, @TranType int, @OutStanding decimal(18,6), @Adjusted decimal(18,6), @Balance decimal(18,6), @netaddr as nVarchar(100))
As
Begin
Declare @Str as nVarchar(1000), @Str1 as nVarchar(4000)

Set @Str1 = 'Declare @TableID as int' + char(13)

Set @Str = 'Update ##' + @netaddr + ' Set OutStanding = ' + cast(@OutStanding as nVarchar) + ', Adjusted = ' + cast(@Adjusted as nVarchar) + ', Balance = ' + cast(@Balance as nVarchar) + ', PrevAdj=0  '
Set @Str = @Str + ' Where ParentTranID = ''' + @PTranID + ''' And CustID = ''' + @CustID + ''' And TranID = ' + cast(@TranID as nVarchar) + ' And TranType = ' + cast(@TranType as nVarchar)

Exec sp_executesql @Str

Set @Str1 = @Str1 + 'Select @TableID = TableID From ##' + @netaddr + ' Where ParentTranID = ''' + @PTranID + ''' And CustID = ''' + @CustID + ''' And TranID = ' + cast(@TranID as nVarchar) + ' And TranType = ' + cast(@TranType as nVarchar)
Set @Str1 = char(13) + @Str1 + 'Update ##' + @netaddr + ' Set PrevAdj=(PrevAdj + ' + cast(@Adjusted as nVarchar) + ') Where TableID < @TableID And TranID = ' + cast(@TranID as nVarchar) + ' And TranType = ' + cast(@TranType as nVarchar)
Set @Str1 = char(13) + @Str1 + 'Update ##' + @netaddr + ' Set OutStanding=(Adjusted+' + cast(@Balance as nVarchar) + '),Balance=((Adjusted+' + cast(@Balance as nVarchar) + ')-Adjusted) Where TableID > @TableID And TranID = ' + cast(@TranID as nVarchar) + ' And TranType = ' + cast(@TranType as nVarchar)
Exec sp_executesql @Str

End
