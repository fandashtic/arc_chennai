Create Procedure mERP_SP_getDivisionforOCG @GroupId int
AS
BEGIN
	select Distinct IC2.Category_Name
	from items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2,dbo.Fn_GetOCGSKU(@GroupId) FN where
	IC4.categoryid = i.categoryid 
	And IC4.Parentid = IC3.categoryid 
	And IC3.Parentid = IC2.categoryid 
	And FN.Product_code=I.Product_code
	And FN.CategoryID=IC4.CategoryID
END
