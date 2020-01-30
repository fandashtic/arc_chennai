CREATE Procedure sp_acc_GetPrevContraDetailNew (@PaymentType As INT,@PartyAccountID As INT,@DocumentID INT)  
As  
Create Table #TempParticular(Particular nvarchar(4000))  
  
Insert #TempParticular  
Select Particular from ARVDetail   
Where DocumentID = @DocumentID And Type = @PaymentType  
And AccountID = @PartyAccountID  
  
Update #TempParticular  
Set Particular = N'1' + Char(1) + Replace(Particular,Char(2),Char(2) + N'1' + Char(1))  
  
Select Particular from #TempParticular  
Drop Table #TempParticular 
