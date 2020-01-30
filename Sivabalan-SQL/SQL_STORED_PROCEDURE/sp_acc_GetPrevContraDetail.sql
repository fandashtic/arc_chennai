CREATE Procedure sp_acc_GetPrevContraDetail(@PaymentType as int,@PartyAccountID as int,@DocumentID Integer)
As
Create Table #TempParticular(Particular nvarchar(4000))

Insert #TempParticular
Select Particular from ARVDetail Where DocumentID = @DocumentID And AccountID = @PartyAccountID And Type = @PaymentType

Update #TempParticular
Set Particular = N'Yes' + Char(1) + Replace(Particular,char(2),char(2) + N'Yes' + char(1))

Select Particular from #TempParticular
Drop Table #TempParticular

