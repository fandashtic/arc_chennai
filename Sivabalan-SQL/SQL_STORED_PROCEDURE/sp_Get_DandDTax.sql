CREATE Procedure sp_Get_DandDTax(@ItemCode nvarchar(30), @DandDDate Datetime)
As
Begin
Declare @TaxCode int

Set DateFormat DMY

IF @DandDDate is Null
Select @DandDDate = GetDate()

Select Top 1 @TaxCode = STaxCode From ItemsSTaxMap
Where Product_Code = @ItemCode and dbo.Striptimefromdate(@DandDDate)
Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))

Select @TaxCode

End
