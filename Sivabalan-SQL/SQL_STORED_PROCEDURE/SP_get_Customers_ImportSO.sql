Create Procedure SP_get_Customers_ImportSO @BeatID nvarchar(4000)
AS
BEGIN
	Declare @Delimeter as Char(1)   
	declare @Achievementflag as int
	Declare @Scoreflag as int

	Set @Delimeter=','    
	Declare @tmpBeat Table (BeatID int)
	Insert into @tmpBeat select * from dbo.sp_SplitIn2Rows(@BeatID,@Delimeter)  

	Select distinct C.Company_name from Customer C, Beat_salesman BS
	where C.CustomerID = BS.CustomerID and 
	isnull(C.Active,0)=1 and 
	BS.BeatID in (select BeatID from @tmpBeat)
	Order by C.Company_name
END
