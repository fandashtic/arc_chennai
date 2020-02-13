--select * from dbo.fn_Arc_Get_CustomersListBySalesManBeat('%','%')
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'fn_Arc_Get_CustomersListBySalesManBeat')
BEGIN
    DROP FUNCTION fn_Arc_Get_CustomersListBySalesManBeat
END
GO
Create Function fn_Arc_Get_CustomersListBySalesManBeat(@Salesman Nvarchar(255) = '%', @Beat Nvarchar(255) = '%')
Returns  
	@CustomerIdsFinal Table 
	(Id int Identity(1,1), CustomerID Nvarchar(255), SalesManID Int, BeatId Int)
AS  
BEGIN
	Declare @CustomerIDs AS Table (Id int Identity(1,1), CustomerID Nvarchar(255), SalesManID Int, BeatId Int)	
	Declare @Salesmans AS Table (SalesmanId INT)
	Declare @Beats AS Table (BeatID INT)

	IF(ISNULL(@Salesman, '') = '%' AND ISNULL(@Beat, '') = '%')
	BEGIN
		Insert into @CustomerIdsFinal(CustomerID, SalesManID, BeatId)
		select DISTINCT CustomerID, SalesManID, BeatId
		FROM V_ARC_Customer_Mapping B WITH (NOLOCK)
	END
	ELSE
	BEGIN
		IF(ISNULL(@Salesman, '') <> '%')
		BEGIN
			INSERT INTO @Salesmans SELECT DISTINCT SalesmanID FROM Salesman WITH (NOLOCK) WHERE Salesman_Name IN (SELECT * FROM dbo.sp_SplitIn2Rows(@Salesman, ','))
		END
		ELSE
		BEGIN
			INSERT INTO @Salesmans SELECT DISTINCT SalesmanID FROM Salesman WITH (NOLOCK)
		END	

		Insert into @CustomerIDs(CustomerID, SalesManID, BeatId)
		select DISTINCT CustomerId,SalesManID, BeatId 
		FROM V_ARC_Customer_Mapping B WITH (NOLOCK)
		WHERE SalesmanId IN (SELECT DISTINCT SalesmanId FROM @Salesmans)
	
		IF(ISNULL(@Beat, '') <> '%')
		BEGIN
			INSERT INTO @Beats SELECT DISTINCT BeatID FROM Beat WITH (NOLOCK) WHERE Description IN (SELECT * FROM dbo.sp_SplitIn2Rows(@Beat, ','))
		
			Insert into @CustomerIDs(CustomerID, SalesManID, BeatId)
			select DISTINCT CustomerId,SalesManID, BeatId 
			FROM V_ARC_Customer_Mapping V WITH (NOLOCK)	
			WHERE BeatID IN (SELECT DISTINCT BeatID FROM @Beats)	
			AND CustomerID NOT IN (SELECT DISTINCT CustomerID FROM @CustomerIDs)
		END

		IF EXISTS(SELECT TOP 1 1 FROM @Beats)
		BEGIN
			INSERT INTO @CustomerIdsFinal(CustomerID, SalesManID, BeatId)
			SELECT DISTINCT CustomerID, SalesManID, BeatId FROM @CustomerIDs WHERE BeatID IN (SELECT DISTINCT BeatID FROM @Beats)
		END
		ELSE 
		BEGIN
			INSERT INTO @CustomerIdsFinal(CustomerID, SalesManID, BeatId) SELECT DISTINCT CustomerID, SalesManID, BeatId FROM @CustomerIDs
		END
	END
	RETURN;
END
Go
