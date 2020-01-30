
CREATE Procedure Sp_Save_CampaignCustomers_Chevron
(
	@Code NVarChar(15),
	@CustomerId NVarChar(15),
 @Objective Decimal(18,6),
	@Serial BigInt
) 
As    
Insert InTo CampaignCustomers(CampaignID,CustomerID,Serial,CustomerObjective)
Values(@Code, @Customerid,@Serial,@Objective)    

