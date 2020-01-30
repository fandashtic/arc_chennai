

CREATE PROCEDURE spc_tax
AS
select Tax.Tax_Description, 
	Percentage, 
	Active,
	CST_Percentage FROM Tax


