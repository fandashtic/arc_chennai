CREATE Procedure sp_Update_ReportData_Disclaimer (@ID int,
					@Header nvarchar(255),
					@Footer nvarchar(255),
					@PageLength int,
					@TopMargin int,
					@BottomMargin int)
As
Update ReportData Set Header = @Header, Footer = @Footer,
PageLength = @PageLength, TopMargin = @TopMargin, BottomMargin = @BottomMargin 
Where ID = @ID
