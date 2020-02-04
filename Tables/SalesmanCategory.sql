IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'SalesmanCategory')
BEGIN
	DROP TABLE SalesmanCategory
END
GO
Create Table SalesmanCategory(SalesmanCategoryId int Identity(1,1), SalesmanCategoryName Nvarchar(255) Not Null)
GO
TRUNCATE TABLE SalesmanCategory
GO
Insert into SalesmanCategory(SalesmanCategoryName) select 'ATTA'
Insert into SalesmanCategory(SalesmanCategoryName) select 'BINGO'
Insert into SalesmanCategory(SalesmanCategoryName) select 'BISCUIT'
Insert into SalesmanCategory(SalesmanCategoryName) select 'CHEMI'
Insert into SalesmanCategory(SalesmanCategoryName) select 'COM'
Insert into SalesmanCategory(SalesmanCategoryName) select 'ISS'
Insert into SalesmanCategory(SalesmanCategoryName) select 'PCP'
Insert into SalesmanCategory(SalesmanCategoryName) select 'SWD'
GO
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'SalesmanCategoryId' AND OBJECT_ID = OBJECT_ID(N'Salesman'))
BEGIN
    Alter Table Salesman Add SalesmanCategoryId INT NULL Default NULL
END
Go
Update SalesMan Set SalesmanCategoryId = 1 WHERE SalesmanId = 16
Update SalesMan Set SalesmanCategoryId = 1 WHERE SalesmanId = 19
Update SalesMan Set SalesmanCategoryId = 1 WHERE SalesmanId = 20
Update SalesMan Set SalesmanCategoryId = 1 WHERE SalesmanId = 25
Update SalesMan Set SalesmanCategoryId = 1 WHERE SalesmanId = 33
Update SalesMan Set SalesmanCategoryId = 1 WHERE SalesmanId = 93
Update SalesMan Set SalesmanCategoryId = 2 WHERE SalesmanId = 3
Update SalesMan Set SalesmanCategoryId = 2 WHERE SalesmanId = 5
Update SalesMan Set SalesmanCategoryId = 2 WHERE SalesmanId = 6
Update SalesMan Set SalesmanCategoryId = 2 WHERE SalesmanId = 12
Update SalesMan Set SalesmanCategoryId = 2 WHERE SalesmanId = 17
Update SalesMan Set SalesmanCategoryId = 2 WHERE SalesmanId = 26
Update SalesMan Set SalesmanCategoryId = 2 WHERE SalesmanId = 29
Update SalesMan Set SalesmanCategoryId = 3 WHERE SalesmanId = 1
Update SalesMan Set SalesmanCategoryId = 3 WHERE SalesmanId = 14
Update SalesMan Set SalesmanCategoryId = 3 WHERE SalesmanId = 22
Update SalesMan Set SalesmanCategoryId = 3 WHERE SalesmanId = 28
Update SalesMan Set SalesmanCategoryId = 3 WHERE SalesmanId = 89
Update SalesMan Set SalesmanCategoryId = 4 WHERE SalesmanId = 10
Update SalesMan Set SalesmanCategoryId = 5 WHERE SalesmanId = 34
Update SalesMan Set SalesmanCategoryId = 6 WHERE SalesmanId = 11
Update SalesMan Set SalesmanCategoryId = 6 WHERE SalesmanId = 30
Update SalesMan Set SalesmanCategoryId = 6 WHERE SalesmanId = 32
Update SalesMan Set SalesmanCategoryId = 7 WHERE SalesmanId = 8
Update SalesMan Set SalesmanCategoryId = 7 WHERE SalesmanId = 21
Update SalesMan Set SalesmanCategoryId = 7 WHERE SalesmanId = 27
Update SalesMan Set SalesmanCategoryId = 7 WHERE SalesmanId = 90
Update SalesMan Set SalesmanCategoryId = 7 WHERE SalesmanId = 91
Update SalesMan Set SalesmanCategoryId = 7 WHERE SalesmanId = 92
Update SalesMan Set SalesmanCategoryId = 8 WHERE SalesmanId = 23
GO
