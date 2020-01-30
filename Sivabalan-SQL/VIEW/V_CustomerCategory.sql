CREATE VIEW  [V_CustomerCategory]
([CustomerCategoryID],[CustomerCategoryName],[Active])
AS
SELECT     CategoryID,CategoryName,Active
FROM       Customercategory
where      CategoryID in (1,2,3)
