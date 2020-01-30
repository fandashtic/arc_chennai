CREATE Procedure sp_CombineDataNameFromID (@PInStrSource nvarchar(4000) = NULL,       
 @pInChrSeparator char(1) = ',')          
AS       
Declare @Aware nVarchar(100)
Declare @AwareID nVarchar(100)
Declare @ConcateAwareness nVarchar(500)
Create table #tmp1(Awareness nvarchar(4000))            
Insert into #tmp1 select * from dbo.sp_SplitIn2Rows(@PInStrSource,@pInChrSeparator)
Declare CursorAwareness Cursor For Select Awareness from #Tmp1
Open CursorAwareness
Fetch Next From CursorAwareness Into @Aware
Set @ConcateAwareness = ''
WHILE @@FETCH_STATUS = 0
Begin
	Select @AwareID = AwarenessID from Awareness Where [Description] = @Aware
	If IsNull(@AwareID,0) = 0
	Begin
		Insert into Awareness ([Description]) Values (@Aware)
		Select @AwareID = AwarenessID  From Awareness Where [Description] = @Aware   
	End
	Set @ConcateAwareness = @ConcateAwareness + ',' + @AwareID
	Fetch Next From CursorAwareness Into @Aware
	Set @AwareID = Null
End
IF @PInStrSource <> '' 
Begin
	Set @ConcateAwareness = SubString(@ConcateAwareness,2,len(@ConcateAwareness))
	Insert into #Tmp Values(@ConcateAwareness)
End
Close CursorAwareness
DEALLOCATE CursorAwareness
Drop Table #tmp1


