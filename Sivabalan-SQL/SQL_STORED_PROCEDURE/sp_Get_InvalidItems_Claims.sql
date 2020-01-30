CREATE PROCEDURE sp_Get_InvalidItems_Claims (@ClaimNo integer)
As
Select ClaimsDetailReceived.Product_Code From ClaimsDetailReceived
Where DocSerial = @ClaimNo and ClaimsDetailReceived.ForumCode Not in (Select Alias From Items)
union
Select ClaimsDetailReceived.Product_Code From ClaimsDetailReceived, Items
Where DocSerial = @ClaimNo and ClaimsDetailReceived.ForumCode = Items.Alias and Items.Active = 0

