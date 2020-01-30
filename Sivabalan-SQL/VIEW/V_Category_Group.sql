CREATE VIEW  [V_Category_Group]
([Group_ID], [Group_Name], [SalesmanID], [Category_ID], [Category_Name], [Creation_Date], [Active])
AS
	Select * from FN_V_Category_Group()
