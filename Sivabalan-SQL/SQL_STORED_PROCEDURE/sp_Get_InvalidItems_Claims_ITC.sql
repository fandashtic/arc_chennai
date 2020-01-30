Create PROCEDURE sp_Get_InvalidItems_Claims_ITC (@ClaimNo NVARCHAR(50))
As
Select ClaimsDetailReceived.Product_Code From ClaimsDetailReceived,ClaimsNoteReceived
Where ClaimID = @ClaimNo and 
ClaimsNoteReceived.DocSerial = ClaimsDetailReceived.DocSerial and
ClaimsDetailReceived.ForumCode Not in (Select Alias From Items)
union
Select ClaimsDetailReceived.Product_Code From ClaimsDetailReceived, Items,ClaimsNoteReceived
Where ClaimID = @ClaimNo and 
ClaimsNoteReceived.DocSerial = ClaimsDetailReceived.DocSerial and
ClaimsDetailReceived.ForumCode = Items.Alias and Items.Active = 0
