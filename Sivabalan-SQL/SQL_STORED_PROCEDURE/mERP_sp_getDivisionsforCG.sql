
Create Procedure mERP_sp_getDivisionsforCG @CG nvarchar(255), @RFADocID nvarchar(max)
AS
BEGIN
	Declare @Delimeter as Char(1)  
	Set @Delimeter=','    
	Create table #tmpID(ID int)  
    insert into #tmpID select * from dbo.sp_SplitIn2Rows(@RFADocID,@Delimeter)  

	Select Distinct T.division from tblcgdivmapping T where T.categorygroup=@CG
    And T.division in (Select Division from tbl_merp_rfaabstract where rfadocid in (Select ID from #tmpID))
	Drop Table #tmpID
END
