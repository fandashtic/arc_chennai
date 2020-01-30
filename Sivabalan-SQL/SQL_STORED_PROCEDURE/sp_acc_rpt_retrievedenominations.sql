CREATE Procedure sp_acc_rpt_retrievedenominations(@Denominations nvarchar(2000),@UserName nVarchar(255))
as
Declare @i Int
Declare @Count nVarchar(255)
Create table #TempDenominations1 (UserName nVarchar(255),Thousand Int,FiveHundred Int,
Hundred Int,Fifty Int,Twenty Int,Ten Int,Five Int,Two Int,One Int,Coins Decimal(18,6),
Amount Decimal(18,6),SerialNo Int) 

Declare scandenomination Cursor Keyset for
Select * from sp_acc_SqlSplitDenominations(@Denominations,'|')
Open scandenomination
Set @i =1
Fetch From scandenomination into @Count
While @@Fetch_Status = 0
Begin
	If @i= 1
	Begin
		Insert Into #TempDenominations1(UserName)
		Values(@UserName)
		
		Update #TempDenominations1
		Set Thousand = @Count
		Where UserName = @UserName
	End
	Else if @i=2
	Begin
		Update #TempDenominations1
		Set FiveHundred = @Count
		Where UserName = @UserName
	End
	Else if @i=3
	Begin
		Update #TempDenominations1
		Set Hundred = @Count
		Where UserName = @UserName
	End
	Else if @i=4
	Begin
		Update #TempDenominations1
		Set Fifty = @Count
		Where UserName = @UserName
	End 
	Else if @i=5
	Begin
		Update #TempDenominations1
		Set Twenty = @Count
		Where UserName = @UserName
	End
	Else if @i=6
	Begin
		Update #TempDenominations1
		Set Ten = @Count
		Where UserName = @UserName
	End
	Else if @i=7
	Begin
		Update #TempDenominations1
		Set Five = @Count
		Where UserName = @UserName
	End
	Else if @i= 8
	Begin
		Update #TempDenominations1
		Set Two = @Count
		Where UserName = @UserName
	End
	Else if @i= 9
	Begin
		Update #TempDenominations1
		Set One = Cast(@Count as Int)
		Where UserName = @UserName
	End
	Else if @i= 10
	Begin
		Update #TempDenominations1
		Set Coins = Cast(@Count as Decimal(18,6))
		Where UserName = @UserName
	End
	set @i = @i + 1
Fetch Next From scandenomination into @Count
End
Close scandenomination
Deallocate scandenomination

Update #TempDenominations1
Set Amount = 0
Where UserName = @UserName

Update #TempDenominations1
Set SerialNo = 1
Where UserName = @UserName

Select * from #TempDenominations1
Drop table #TempDenominations1





