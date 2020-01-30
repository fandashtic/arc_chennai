Create Function [dbo].[Fn_Get_DandDLegendInfo]()
Returns nvarchar(1000)
As
Begin
	Declare @DandDLegend nvarchar(1000)
	Set @DandDLegend = ''

	Select Top 1 @DandDLegend = LegendInfo From DandDAbstract Order By ID Desc
	IF @DandDLegend = ''
		Select Top 1 @DandDLegend = LegendInfo From DandDLegend Order By CreationDate Desc
	
	IF @DandDLegend Is Null
		Set @DandDLegend = '  '
		
	Return @DandDLegend
End 
