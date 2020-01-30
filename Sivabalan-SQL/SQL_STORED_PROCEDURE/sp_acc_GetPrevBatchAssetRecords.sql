CREATE Procedure sp_acc_GetPrevBatchAssetRecords(@AccountID Integer, @DocumentID Integer)
As
Declare @TYPE_ASSET Integer
SET @TYPE_ASSET = 0
Create Table #TempParticular(Particular nvarchar(4000))

Insert #TempParticular
Select Particular from ARVDetail Where DocumentID = @DocumentID And AccountID = @AccountID And Type = @TYPE_ASSET

Update #TempParticular
Set Particular = N'Yes' + Char(1) + Replace(Particular,char(2),char(2) + N'Yes' + char(1))

Select Particular from #TempParticular
Drop Table #TempParticular

